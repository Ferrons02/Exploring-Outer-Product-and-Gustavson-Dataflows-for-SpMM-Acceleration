import accelerator_package::*;
import hci_package::*;

`ifndef X_DATA_SCHEDULER_SV
`define X_DATA_SCHEDULER_SV

module X_data_scheduler #(
    parameter BW                  = 128,         // Total interface bandwidth in bits
    parameter DATA_SIZE           = 32,          // Size of each data element in bits
    parameter META_CHUNK_SIZE     = 32
)(
    input  logic                 clk_i,
    input  logic                 rst_ni,
    input  logic                 clear_i,

    input  logic                 sched_proceed_i,    // renamed from new_req_i
    input  logic                 meta_used_i,
    output logic                 meta_used_o,

    input  logic [META_CHUNK_SIZE-1:0] metadata_chunk,

    input  X_param_t             params_i,

    output hci_streamer_ctrl_t   config_o
);

    // ---------------------------------------------------------------------------------------------
    // X_data_scheduler Module (Gustavson-Z reuse)
    //
    // Streams sparse matrix X (bitmap + nonzeros) for Gustavson dataflow.
    // Advances on rising edge when sched_proceed_i=1.
    // Removed meta_used_i; always proceeds if sched_proceed_i asserted.
    // All registered signals split into _d (next) and _q (current).
    // Multiplications replaced with additions or shifts where possible.
    //----------------------------------------------------------------------------------------------

    logic [15:0] x_row_q, x_row_d;                                      // Actual row of X
    logic [15:0] y_col_block_q, y_col_block_d;                          // Actual column block of Y
    logic [15:0] scanned_columns_q, scanned_columns_d;                  // Actual column of X
    logic [15:0] meta_chunk_used_bits_q,   meta_chunk_used_bits_d;      // Counts come many bits of the metadata chunk have been used
    logic [31:0] nonzero_counter_q,        nonzero_counter_d;           // Counts how many nonzero elements of X has been used overall
    logic [31:0] nonzero_counter_row_q,  nonzero_counter_row_d;         // Counts how many nonzero elements of X has been used in the current row
    logic [31:0] nonzero_counter_cycle_q,  nonzero_counter_cycle_d;     // Counts how many nonzero elements of X has been used in the current cycle
    hci_streamer_ctrl_t config_o_q, config_o_d;

    logic needing_meta_q, needing_meta_d;                               // It goes to 1 if metadata are finished 

    localparam int DATA_SIZE_BYTES       = DATA_SIZE >> 3;
    localparam int DATA_SIZE_BYTES_LOG   = $clog2(DATA_SIZE_BYTES);
    localparam int META_CHUNK_SIZE_BYTES = META_CHUNK_SIZE >> 3;
    localparam int MAX_ELEMS_PER_REQ     = (BW / DATA_SIZE) > 0 ? $floor(BW / DATA_SIZE) : 1;

    // ---------------------------------------------------------------------------------------------
    // Combinatorial logic: next-state and config generation
    // ---------------------------------------------------------------------------------------------
    always_comb begin

        // Default: hold current state
        x_row_d                 = x_row_q;
        y_col_block_d           = y_col_block_q;
        scanned_columns_d       = scanned_columns_q;
        meta_chunk_used_bits_d  = meta_chunk_used_bits_q;
        nonzero_counter_d       = nonzero_counter_q;
        nonzero_counter_row_d   = nonzero_counter_row_q;
        nonzero_counter_cycle_d = nonzero_counter_cycle_q;
        needing_meta_d          = needing_meta_q;
        config_o_d              = config_o_q;

        if (needing_meta_q)
            needing_meta_d = meta_used_i;
        else
            needing_meta_d = needing_meta_q;
            
        if (sched_proceed_i) begin
            
            // First we check if we need metadata
            // End of row?
            if (scanned_columns_q >= params_i.x_columns) begin

                scanned_columns_d         = '0;
                nonzero_counter_d         = nonzero_counter_q - nonzero_counter_row_q;
                nonzero_counter_row_d     = '0;
                meta_chunk_used_bits_d    = 16'd8 - ((META_CHUNK_SIZE - meta_chunk_used_bits_q) & 3'b111);  // The next tile of metadata might have the first byte that shares bits with the previous row
                needing_meta_d            = 1'b1;
                y_col_block_d             = y_col_block_q + 16'b1;

                // Next X row?
                if (y_col_block_d >= params_i.y_row_iters) begin

                    nonzero_counter_d         = nonzero_counter_q;
                    meta_chunk_used_bits_d    = '0;
                    y_col_block_d             = '0;
                    x_row_d                   = x_row_q + 16'b1;

                end

            end else if (meta_chunk_used_bits_q >= META_CHUNK_SIZE) begin

                meta_chunk_used_bits_d      = '0;
                needing_meta_d              = 1'b1;

            end else begin

                nonzero_counter_cycle_d = '0;

                // Loop to create the block of dense elements
                while ((meta_chunk_used_bits_d < META_CHUNK_SIZE) &&
                       (nonzero_counter_cycle_d < MAX_ELEMS_PER_REQ) &&
                       (scanned_columns_d < params_i.x_columns)) begin
                    if (metadata_chunk[meta_chunk_used_bits_d])
                        nonzero_counter_cycle_d = nonzero_counter_cycle_d + 1'b1;
                    meta_chunk_used_bits_d   = meta_chunk_used_bits_d + 1'b1;
                    scanned_columns_d        = scanned_columns_d + 1'b1;
                end

                // If there's not even one element to load, we generate a request for new metadata; else we generate a request for X
                if (nonzero_counter_cycle_d == '0)begin

                    // End of row?
                    if (scanned_columns_d >= params_i.x_columns) begin

                        scanned_columns_d         = '0;
                        nonzero_counter_d         = nonzero_counter_q - nonzero_counter_row_q;
                        nonzero_counter_row_d     = '0;
                        meta_chunk_used_bits_d    = 16'd8 - ((META_CHUNK_SIZE - meta_chunk_used_bits_q) & 3'b111);  // The next tile of metadata might have the first byte that shares bits with the previous row
                        needing_meta_d            = 1'b1;
                        y_col_block_d             = y_col_block_q + 16'b1;

                        // Next X row?
                        if (y_col_block_d >= params_i.y_row_iters) begin

                            nonzero_counter_d         = nonzero_counter_q;
                            meta_chunk_used_bits_d    = '0;
                            y_col_block_d             = '0;
                            x_row_d                   = x_row_q + 16'b1;

                        end

                    end else if (meta_chunk_used_bits_d >= META_CHUNK_SIZE) begin

                        meta_chunk_used_bits_d      = '0;
                        needing_meta_d              = 1'b1;

                    end

                end

                // We either send a request for new metadata or a request for new X
                if(needing_meta_d)begin
                    
                    if (x_row_d >= params_i.x_rows) begin

                        // The calculation is finished and everything starts again
                        x_row_d                     = '0;
                        y_col_block_d               = '0;
                        scanned_columns_d           = '0;
                        meta_chunk_used_bits_d      = '0;
                        nonzero_counter_d           = '0;
                        nonzero_counter_cycle_d     = '0;
                        nonzero_counter_row_d       = '0;
                        needing_meta_d              = 1'b1;

                        config_o_d.req_start        = 1'b0;
                        config_o_d.addressgen_ctrl.base_addr        = params_i.base_address;
                        config_o_d.addressgen_ctrl.tot_len          = 32'b1;
                        config_o_d.addressgen_ctrl.d0_len           = 32'b1;
                        config_o_d.addressgen_ctrl.d0_stride        = META_CHUNK_SIZE_BYTES;
                        config_o_d.addressgen_ctrl.d1_len           = '0;
                        config_o_d.addressgen_ctrl.d1_stride        = '0;
                        config_o_d.addressgen_ctrl.d2_len           = '0;
                        config_o_d.addressgen_ctrl.d2_stride        = '0;
                        config_o_d.addressgen_ctrl.d3_stride        = '0;
                        config_o_d.addressgen_ctrl.dim_enable_1h    = 4'b0000;

                    end else begin

                        // Config to load metadata
                        config_o_d.req_start = 1'b0;
                        config_o_d.addressgen_ctrl.base_addr = params_i.base_address + (((x_row_d << params_i.x_columns_log) + scanned_columns_d) >> 3); // By doing ">>3" we are rounding to the lowest byte
                        config_o_d.addressgen_ctrl.tot_len   = 32'b1;
                        config_o_d.addressgen_ctrl.d0_len    = 32'b1;
                        if(x_row_d == params_i.x_rows - 16'b1 && (params_i.x_columns - scanned_columns_d) < META_CHUNK_SIZE_BYTES)
                            config_o_d.addressgen_ctrl.d0_stride = (params_i.x_columns - scanned_columns_d + 16'd7) >> 3;
                        else
                            config_o_d.addressgen_ctrl.d0_stride = META_CHUNK_SIZE_BYTES;
                    end

                end else begin

                    // Config to load X
                    config_o_d.req_start = 1'b0;
                    config_o_d.addressgen_ctrl.base_addr = params_i.base_address + META_CHUNK_SIZE_BYTES + (nonzero_counter_d << DATA_SIZE_BYTES_LOG);
                    config_o_d.addressgen_ctrl.tot_len   = nonzero_counter_cycle_d;
                    config_o_d.addressgen_ctrl.d0_len    = nonzero_counter_cycle_d;
                    config_o_d.addressgen_ctrl.d0_stride = DATA_SIZE_BYTES;

                end

                nonzero_counter_row_d = nonzero_counter_row_q + nonzero_counter_cycle_d;
                nonzero_counter_d     = nonzero_counter_q + nonzero_counter_cycle_d;

            end
        end
    end

    // ---------------------------------------------------------------------------------------------
    // Sequential logic: update registers on rising clock
    // ---------------------------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin

            x_row_q                     <= '0;
            y_col_block_q               <= '0;
            scanned_columns_q           <= '0;
            meta_chunk_used_bits_q      <= '0;
            nonzero_counter_q           <= '0;
            nonzero_counter_cycle_q     <= '0;
            nonzero_counter_row_q       <= '0;
            needing_meta_q              <= 1'b1;

            // Config to load metadata
            config_o_q.req_start        <= 1'b0;
            config_o_q.addressgen_ctrl.base_addr        <= params_i.base_address;
            config_o_q.addressgen_ctrl.tot_len          <= 32'b1;
            config_o_q.addressgen_ctrl.d0_len           <= 32'b1;
            config_o_q.addressgen_ctrl.d0_stride        <= META_CHUNK_SIZE_BYTES;
            config_o_q.addressgen_ctrl.d1_len           <= '0;
            config_o_q.addressgen_ctrl.d1_stride        <= '0;
            config_o_q.addressgen_ctrl.d2_len           <= '0;
            config_o_q.addressgen_ctrl.d2_stride        <= '0;
            config_o_q.addressgen_ctrl.d3_stride        <= '0;
            config_o_q.addressgen_ctrl.dim_enable_1h    <= 4'b0000;

        end else begin
            if (clear_i) begin

                x_row_q                     <= '0;
                y_col_block_q               <= '0;
                scanned_columns_q           <= '0;
                meta_chunk_used_bits_q      <= '0;
                nonzero_counter_q           <= '0;
                nonzero_counter_cycle_q     <= '0;
                nonzero_counter_row_q       <= '0;
                needing_meta_q              <= 1'b1;

                // Config to load metadata
                config_o_q.req_start        <= 1'b0;
                config_o_q.addressgen_ctrl.base_addr        <= params_i.base_address;
                config_o_q.addressgen_ctrl.tot_len          <= 32'b1;
                config_o_q.addressgen_ctrl.d0_len           <= 32'b1;
                config_o_q.addressgen_ctrl.d0_stride        <= META_CHUNK_SIZE_BYTES;
                config_o_q.addressgen_ctrl.d1_len           <= '0;
                config_o_q.addressgen_ctrl.d1_stride        <= '0;
                config_o_q.addressgen_ctrl.d2_len           <= '0;
                config_o_q.addressgen_ctrl.d2_stride        <= '0;
                config_o_q.addressgen_ctrl.d3_stride        <= '0;
                config_o_q.addressgen_ctrl.dim_enable_1h    <= 4'b0000;

            end else begin

                x_row_q                     <= x_row_d;
                y_col_block_q               <= y_col_block_d;
                scanned_columns_q           <= scanned_columns_d;
                meta_chunk_used_bits_q      <= meta_chunk_used_bits_d;
                nonzero_counter_q           <= nonzero_counter_d;
                nonzero_counter_cycle_q     <= nonzero_counter_cycle_d;
                nonzero_counter_row_q       <= nonzero_counter_row_d;
                needing_meta_q              <= needing_meta_d;
                config_o_q                  <= config_o_d;

            end
        end
    end

    assign config_o    = config_o_q;
    assign meta_used_o = needing_meta_q;

endmodule

`endif // X_DATA_SCHEDULER_SV
