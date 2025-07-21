import accelerator_package::*;
import hci_package::*;

`ifndef Z_DATA_SCHEDULER_SV
`define Z_DATA_SCHEDULER_SV

module Z_data_scheduler #(
    parameter BW                  = 128,
    parameter DATA_SIZE           = 32,          // Size of each data element in bits
    parameter Y_BLOCK_SIZE         = 4            // Number of Y columns per block
)(
    input  logic                 clk_i,
    input  logic                 rst_ni,
    input  logic                 clear_i,
    input  logic                 working_i,
    input  logic                 done_i,
    input  logic                 sched_proceed_i,  // Advance scheduler

    input  Z_param_t             params_i,

    output hci_streamer_ctrl_t   config_o        // Configuration to load Y blocks
);

    // ---------------------------------------------------------------------------------------------
    // Z_data_scheduler Module
    //
    // Generates a sequence of block‐store requests for the Z matrix, iterating over Y in fixed‐size
    // blocks of Y_BLOCK_SIZE columns. On each rising edge when sched_proceed_i=1, it advances to the
    // next Y‐column block, computes the corresponding byte offset from params_i.base_address, and issues a
    // single hci_streamer_ctrl_t configuration (config_o) to store that block. When y_col_block
    // reaches params_i.y_row_iters, it wraps back to 0. 
    // 
    // Behavior and assumptions:
    //  - There is no metadata_bitmap input; this scheduler simply steps through Y blocks in order.
    //  - params_i.base_address refers to the byte‐address base of Z in memory.
    //  - DATA_SIZE_BYTES = DATA_SIZE/8, row-major layout.
    //  - Each Y block covers Y_BLOCK_SIZE consecutive columns, except for the final block, which may
    //    be smaller if params_i.y_columns is not a multiple of Y_BLOCK_SIZE.
    //  - On reset or clear_i, the scheduler returns to block 0 and issues a config_o for the first block.
    //  - On each sched_proceed_i tick, the scheduler:
    //      • Increments y_col_block (wraps to 0 when reaching params_i.y_row_iters).
    //      • Updates current_offset_address = prior_offset + (size_of_previous_block × DATA_SIZE_BYTES).
    //      • Outputs config_o with:
    //           – req_start = 1′b1
    //           – base_addr = params_i.base_address + current_offset_address
    //           – tot_len = d0_len = min(Y_BLOCK_SIZE, params_i.y_columns – (y_col_block << Y_BLOCK_SIZE_LOG))
    //           – d0_stride = DATA_SIZE_BYTES
    //  - No attempt is made to pack multiple blocks per request; each request handles exactly one block.
    //---------------------------------------------------------------------------------------------

    // State registers
    logic sched_proceed_q, sched_proceed_d;
    assign sched_proceed_d = sched_proceed_i;
    logic [15:0]  x_row_q, x_row_d;                                       // Actual row of X
    logic [31:0]  current_offset_address_q, current_offset_address_d;     // Current address of the block
    logic [15:0]  y_col_block_q, y_col_block_d;                           // Current column block
    Z_param_t params_q, params_d;

    hci_streamer_ctrl_t config_o_q, config_o_d;

    // Derived constants
    localparam int DATA_SIZE_LOG      = $clog2(DATA_SIZE);
    localparam int DATA_SIZE_BYTES      = DATA_SIZE >> 3;
    localparam int DATA_SIZE_BYTES_LOG  = $clog2(DATA_SIZE_BYTES);
    localparam int Y_BLOCK_SIZE_LOG     = $clog2(Y_BLOCK_SIZE);
    localparam int BW_BYTES             = BW / 8;

    typedef enum { Z_SCHED_INACTIVE, Z_SCHED_WORKING } z_scheduler_state;
    z_scheduler_state z_scheduler_state_d, z_scheduler_state_q;

    always_ff @(posedge clk_i or negedge rst_ni) 
    begin: z_scheduler_fsm_seq
        if (!rst_ni) begin

            params_q                    <= '0;
            z_scheduler_state_q         <= Z_SCHED_INACTIVE;
            sched_proceed_q             <= '0;
            current_offset_address_q    <= '0;
            y_col_block_q               <= '0;
            x_row_q                     <= '0;

        end else if (clear_i) begin

            params_q                    <= '0;
            z_scheduler_state_q         <= Z_SCHED_INACTIVE;
            sched_proceed_q             <= '0;
            current_offset_address_q    <= '0;
            y_col_block_q               <= '0;
            x_row_q                     <= '0;

        end else begin

            params_q                    <= params_d;
            z_scheduler_state_q         <= z_scheduler_state_d;
            sched_proceed_q             <= sched_proceed_d;
            x_row_q                     <= x_row_d;
            current_offset_address_q    <= current_offset_address_d;
            y_col_block_q               <= y_col_block_d;
            config_o_q                  <= config_o_d;
                  
        end
    end

    always_comb
    begin: z_scheduler_fsm_ns_comb
        z_scheduler_state_d = z_scheduler_state_q;

        if(z_scheduler_state_q == Z_SCHED_INACTIVE)
            if(working_i)
                z_scheduler_state_d = Z_SCHED_WORKING;
        else if(z_scheduler_state_q == Z_SCHED_WORKING)
            if(done_i)
                z_scheduler_state_d = Z_SCHED_INACTIVE;
    end

    always_comb 
    begin: z_scheduler_fsm_out_comb

        // Default: hold current state
        params_d                 = params_q;
        current_offset_address_d = current_offset_address_q;
        y_col_block_d            = y_col_block_q;
        x_row_d                  = x_row_q;
        config_o_d               = config_o_q;

        if (z_scheduler_state_q == Z_SCHED_INACTIVE) begin

            params_d = params_i;
            current_offset_address_d = Y_BLOCK_SIZE << DATA_SIZE_BYTES_LOG;
            y_col_block_d = 1;
            
            config_o_d.req_start        = 1'b0;
            config_o_d.addressgen_ctrl.base_addr        = params_i.base_address;
            config_o_d.addressgen_ctrl.tot_len          = ((Y_BLOCK_SIZE << DATA_SIZE_LOG) + BW - 1) / BW;
            config_o_d.addressgen_ctrl.d0_len           = ((Y_BLOCK_SIZE << DATA_SIZE_LOG) + BW - 1) / BW;
            config_o_d.addressgen_ctrl.d0_stride        = BW_BYTES;
            config_o_d.addressgen_ctrl.d1_len           = '0;
            config_o_d.addressgen_ctrl.d1_stride        = '0;
            config_o_d.addressgen_ctrl.d2_len           = '0;
            config_o_d.addressgen_ctrl.d2_stride        = '0;
            config_o_d.addressgen_ctrl.d3_stride        = '0;
            config_o_d.addressgen_ctrl.dim_enable_1h    = 4'b0000;

        end else if (z_scheduler_state_q == Z_SCHED_WORKING & sched_proceed_q) begin

            current_offset_address_d = current_offset_address_q + ((((y_col_block_q << Y_BLOCK_SIZE_LOG) + Y_BLOCK_SIZE) <= params_q.y_columns) ? Y_BLOCK_SIZE << DATA_SIZE_BYTES_LOG : ((params_q.y_columns - (y_col_block_q << Y_BLOCK_SIZE_LOG))) << DATA_SIZE_BYTES_LOG);
            
            // Config to store Z
            config_o_d.req_start = 1'b0;
            config_o_d.addressgen_ctrl.base_addr = params_q.base_address + current_offset_address_q;
            config_o_d.addressgen_ctrl.tot_len   = (((y_col_block_q << Y_BLOCK_SIZE_LOG) + Y_BLOCK_SIZE) <= params_q.y_columns) ? ((Y_BLOCK_SIZE << DATA_SIZE_LOG) + BW - 1) / BW : (((params_q.y_columns - (y_col_block_q << Y_BLOCK_SIZE_LOG)) << DATA_SIZE_LOG) + BW - 1) / BW;
            config_o_d.addressgen_ctrl.d0_len    = (((y_col_block_q << Y_BLOCK_SIZE_LOG) + Y_BLOCK_SIZE) <= params_q.y_columns) ? ((Y_BLOCK_SIZE << DATA_SIZE_LOG) + BW - 1) / BW : (((params_q.y_columns - (y_col_block_q << Y_BLOCK_SIZE_LOG)) << DATA_SIZE_LOG) + BW - 1) / BW;
            config_o_d.addressgen_ctrl.d0_stride = BW_BYTES;
            
            if (y_col_block_q + 1 >= params_q.y_row_iters)begin
                y_col_block_d = '0;
                x_row_d = x_row_q + 1;
            end else
                y_col_block_d = y_col_block_q + 1;
                
        end
    end

    assign config_o    = config_o_q;

endmodule

`endif // Z_DATA_SCHEDULER_SV
