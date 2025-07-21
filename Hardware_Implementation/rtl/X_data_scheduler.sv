import accelerator_package::*;
import hci_package::*;
import hwpe_stream_package::*;

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
    input  logic                 working_i,
    input  logic                 done_i,

    input  logic                 meta_used_i,
    output logic                 meta_used_o,

    input  logic [META_CHUNK_SIZE-1:0] metadata_chunk,

    input  X_param_t             params_i,

    output logic                 request_ready_o,
    hwpe_stream_intf_stream.source elem_num_o,
    hwpe_stream_intf_stream.source addr_o
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

    logic needing_meta_nextcycle_q, needing_meta_nextcycle_d;
    logic chunk_done;
    logic [15:0] previous_meta_addr_q, previous_meta_addr_d;
    logic [15:0] x_row_q, x_row_d;                                      // Actual row of X
    logic [15:0] y_col_block_q, y_col_block_d;                          // Actual column block of Y
    logic [15:0] scanned_columns_q, scanned_columns_d;                  // Actual column of X
    logic [15:0] meta_chunk_used_bits_q,   meta_chunk_used_bits_d;      // Counts come many bits of the metadata chunk have been used
    logic [31:0] nonzero_counter_q,        nonzero_counter_d;           // Counts how many nonzero elements of X has been used overall
    logic [31:0] nonzero_counter_row_q,  nonzero_counter_row_d;         // Counts how many nonzero elements of X has been used in the current row
    logic [31:0] nonzero_counter_cycle_q,  nonzero_counter_cycle_d;     // Counts how many nonzero elements of X has been used in the current cycle
    logic [META_CHUNK_SIZE - 1 : 0] meta_portion_tocheck;
    logic [$clog2(META_CHUNK_SIZE) - 1 : 0] meta_position;
    logic needing_meta_q, needing_meta_d;                               // It goes to 1 if metadata are finished 
    X_param_t params_q, params_d;
    flags_fifo_t flags_addr_fifo;
    flags_fifo_t flags_elem_num_fifo;

    assign meta_portion_tocheck = (metadata_chunk << meta_chunk_used_bits_q);

    localparam int DATA_SIZE_BYTES       = DATA_SIZE >> 3;
    localparam int DATA_SIZE_BYTES_LOG   = $clog2(DATA_SIZE_BYTES);
    localparam int META_CHUNK_SIZE_BYTES = META_CHUNK_SIZE >> 3;
    localparam int META_CHUNK_SIZE_BYTES_LOG = $clog2(META_CHUNK_SIZE_BYTES);
    localparam int META_CHUNK_SIZE_LOG   = $clog2(META_CHUNK_SIZE);
    localparam int MAX_ELEMS_PER_REQ     = (BW / DATA_SIZE) > 0 ? $floor(BW / DATA_SIZE) : 1;

    lzc #(
        .WIDTH (META_CHUNK_SIZE),
        .MODE (1)
    ) meta_searcher (
        .in_i               (meta_portion_tocheck),
        .cnt_o              (meta_position),
        .empty_o            (chunk_done)
    );

    hwpe_stream_intf_stream #(
        .DATA_WIDTH (32)
    ) push_addr (
        .clk(clk_i)
    );

    assign push_addr.strb = '1;

    hwpe_stream_fifo #(
        .DATA_WIDTH (32),
        .FIFO_DEPTH (2)
    ) X_addr_fifo (
        .clk_i       ( clk_i                       ),
        .rst_ni      ( rst_ni                      ),
        .clear_i     ( clear_i                     ),

        .flags_o    (flags_addr_fifo),
        .push_i     (push_addr),
        .pop_o      (addr_o)
    );

    hwpe_stream_intf_stream #(
        .DATA_WIDTH (8)
    ) push_elem_num (
        .clk(clk_i)
    );

    assign push_elem_num.strb = '1;

    hwpe_stream_fifo #(
        .DATA_WIDTH (8),
        .FIFO_DEPTH (2)
    ) elem_num_fifo (
        .clk_i       ( clk_i                       ),
        .rst_ni      ( rst_ni                      ),
        .clear_i     ( clear_i                     ),

        .flags_o    (flags_elem_num_fifo),
        .push_i     (push_elem_num),
        .pop_o      (elem_num_o)
    );

    always_comb
    begin

        // Default: hold current state
        x_row_d                 = x_row_q;
        y_col_block_d           = y_col_block_q;
        scanned_columns_d       = scanned_columns_q;
        meta_chunk_used_bits_d  = meta_chunk_used_bits_q;
        nonzero_counter_d       = nonzero_counter_q;
        nonzero_counter_row_d   = nonzero_counter_row_q;
        nonzero_counter_cycle_d = nonzero_counter_cycle_q;
        params_d                = params_q;
        previous_meta_addr_d    = previous_meta_addr_q;
        needing_meta_nextcycle_d = needing_meta_nextcycle_q;

        push_addr.valid = 1'b0;
        push_elem_num.valid = 1'b0;

        if (working_i) begin

            if (needing_meta_q)
                needing_meta_d = meta_used_i;
            else
                needing_meta_d = needing_meta_q;

            if (((needing_meta_q && !meta_used_i) || !needing_meta_q) && !flags_addr_fifo.full && !flags_elem_num_fifo.full) begin

                if (needing_meta_q && !meta_used_i) begin
                    //Config to load X
                    push_addr.valid = 1;
                    push_addr.data = params_q.base_address + (params_q.total_meta_words << 2) + (nonzero_counter_q << DATA_SIZE_BYTES_LOG);
                end

                // If the whole row doesn't have dense elements it simply gets skipped
                if((scanned_columns_q == '0) && ((scanned_columns_q + meta_position) >= params_q.x_columns)) begin
                    x_row_d = x_row_q + 1;
                    meta_chunk_used_bits_d = meta_chunk_used_bits_q + params_q.x_columns;
                    if(previous_meta_addr_q != (params_q.base_address + ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))) begin
                        needing_meta_d = 1;
                        needing_meta_nextcycle_d = 1;
                        meta_chunk_used_bits_d = '0;
                    end
                end else if (scanned_columns_q + meta_position >= params_q.x_columns || (needing_meta_q && !meta_used_i && chunk_done && (scanned_columns_q + meta_position + 1)>= params_q.x_columns)) begin
                    
                    push_elem_num.valid = 1;
                    push_elem_num.data = nonzero_counter_cycle_q;

                    if ((nonzero_counter_cycle_q >= 1) && !(previous_meta_addr_q != (params_q.base_address + (((x_row_q << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))) && !((y_col_block_q + 1 >= params_q.y_row_iters) && (chunk_done || (previous_meta_addr_q != (params_q.base_address + ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))))))begin
                        //Config to load X
                        push_addr.valid = 1;
                        if (y_col_block_q + 1 >= params_q.y_row_iters)
                            push_addr.data = params_q.base_address + (params_q.total_meta_words << 2) + (nonzero_counter_q << DATA_SIZE_BYTES_LOG);
                        else
                            push_addr.data = params_q.base_address + (params_q.total_meta_words << 2) + ((nonzero_counter_q - nonzero_counter_row_q) << DATA_SIZE_BYTES_LOG);
                    end

                    //Can you keep using the previous metadata chunk?
                    if(previous_meta_addr_q != (params_q.base_address + (((x_row_q << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))) begin
                        needing_meta_d = 1;
                        needing_meta_nextcycle_d = 1;
                    end 

                    scanned_columns_d         = '0;
                    nonzero_counter_cycle_d   = '0;
                    nonzero_counter_d         = nonzero_counter_q - nonzero_counter_row_q;
                    nonzero_counter_row_d     = '0;
                    y_col_block_d             = y_col_block_q + 16'b1;
                    meta_chunk_used_bits_d = (x_row_q << params_q.x_columns_log) - (((x_row_q << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_LOG);
                    
                    // Next X row?
                    if (y_col_block_q + 1 >= params_q.y_row_iters) begin

                        if(previous_meta_addr_q != (params_q.base_address + ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))) begin
                            needing_meta_d = 1;
                            needing_meta_nextcycle_d = 1;
                        end
                        
                        nonzero_counter_d         = nonzero_counter_q;
                        y_col_block_d             = '0;
                        x_row_d                   = x_row_q + 16'b1;
                        meta_chunk_used_bits_d    = ((x_row_q + 1) << params_q.x_columns_log) - ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_LOG);

                    end

                end else if (chunk_done)begin

                    push_elem_num.valid = 1;
                    push_elem_num.data = nonzero_counter_cycle_q;

                    needing_meta_d = 1;
                    needing_meta_nextcycle_d = 1;

                    meta_chunk_used_bits_d = '0;

                    scanned_columns_d           = scanned_columns_q + (META_CHUNK_SIZE - meta_chunk_used_bits_q);
                    nonzero_counter_cycle_d     = '0;
                    
                end else begin

                    if (nonzero_counter_cycle_q >= MAX_ELEMS_PER_REQ)begin
                        //Config to load X
                        nonzero_counter_cycle_d = 1;
                        push_addr.valid = 1'b1;
                        push_addr.data = params_q.base_address + (params_q.total_meta_words << 2) + (nonzero_counter_q << DATA_SIZE_BYTES_LOG);
                        push_elem_num.valid = 1;
                        push_elem_num.data = MAX_ELEMS_PER_REQ;
                    end else 
                        nonzero_counter_cycle_d     = nonzero_counter_cycle_q + 1;

                    scanned_columns_d           = scanned_columns_q + meta_position + 1;
                    meta_chunk_used_bits_d      = meta_chunk_used_bits_q + meta_position + 1;
                    nonzero_counter_row_d       = nonzero_counter_row_q + 1;
                    nonzero_counter_d           = nonzero_counter_q + 1;

                end
            end

            //Pushing a metadata request
            if(needing_meta_nextcycle_q && push_addr.ready)begin

                //Config to load meta
                needing_meta_nextcycle_d = 0;
                push_addr.valid = 1'b1;
                previous_meta_addr_d = params_q.base_address + ((((x_row_q << params_q.x_columns_log) + scanned_columns_q ) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG);
                push_addr.data = params_q.base_address + ((((x_row_q << params_q.x_columns_log) + scanned_columns_q ) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG);

            end  

        end else begin

            params_d = params_i;
            needing_meta_d = 1;

            if (flags_addr_fifo.empty & push_addr.ready)begin

                push_addr.valid = 1'b1;

                //Config to load meta
                previous_meta_addr_d = params_q.base_address;
                push_addr.data = params_q.base_address;

            end

        end
    end 

    always_ff @(posedge clk_i or negedge rst_ni)
    begin
        if(~rst_ni) begin

            params_q                    <= '0;
            x_row_q                     <= '0;
            y_col_block_q               <= '0;
            scanned_columns_q           <= '0;
            meta_chunk_used_bits_q      <= '0;
            nonzero_counter_q           <= '0;
            nonzero_counter_cycle_q     <= '0;
            nonzero_counter_row_q       <= '0;
            needing_meta_q          <= 1'b1;     
            previous_meta_addr_q        <= '0;
            needing_meta_nextcycle_q    <= '0;

        end else if(clear_i)begin

            params_q                    <= '0;
            x_row_q                     <= '0;
            y_col_block_q               <= '0;
            scanned_columns_q           <= '0;
            meta_chunk_used_bits_q      <= '0;
            nonzero_counter_q           <= '0;
            nonzero_counter_cycle_q     <= '0;
            nonzero_counter_row_q       <= '0;
            needing_meta_q          <= 1'b1;
            previous_meta_addr_q        <= '0;
            needing_meta_nextcycle_q    <= '0;

        end else begin

            params_q                    <= params_d;
            x_row_q                     <= x_row_d;
            y_col_block_q               <= y_col_block_d;
            scanned_columns_q           <= scanned_columns_d;
            meta_chunk_used_bits_q      <= meta_chunk_used_bits_d;
            nonzero_counter_q           <= nonzero_counter_d;
            nonzero_counter_cycle_q     <= nonzero_counter_cycle_d;
            nonzero_counter_row_q       <= nonzero_counter_row_d;
            needing_meta_q              <= needing_meta_d;
            previous_meta_addr_q        <= previous_meta_addr_d;
            needing_meta_nextcycle_q    <= needing_meta_nextcycle_d;

        end
    end           

    assign meta_used_o = needing_meta_q && flags_addr_fifo.almost_empty;
    assign request_ready_o = !needing_meta_q && !flags_addr_fifo.empty || needing_meta_q && (!flags_addr_fifo.almost_empty && !flags_addr_fifo.empty);
 
endmodule
`endif // X_DATA_SCHEDULER_SV
