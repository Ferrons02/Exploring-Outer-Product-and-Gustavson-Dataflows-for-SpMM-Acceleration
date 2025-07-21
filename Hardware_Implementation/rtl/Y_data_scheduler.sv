import accelerator_package::*;
import hci_package::*;
import hwpe_stream_package::*;

`ifndef Y_DATA_SCHEDULER_SV
`define Y_DATA_SCHEDULER_SV

module Y_data_scheduler #(
    parameter DATA_SIZE           = 32,          // Size of each data element in bits
    parameter META_CHUNK_SIZE     = 512,         // Size of a metadata chunk in bits (bitmap of X’s row)
    parameter Y_BLOCK_SIZE        = 4
)(
    input  logic                 clk_i,
    input  logic                 rst_ni,
    input  logic                 clear_i,
    input  logic                 working_i,
    input  logic                 done_i,

    input  logic                 meta_used_i,      // Indicates new metadata_chunk is ready
    output logic                 meta_used_o,      // Raises high to request new metadata

    input  logic [META_CHUNK_SIZE-1:0] metadata_chunk, // Bitmap for one row of X

    input  Y_param_t             params_i,
    output logic                 request_ready_o,

    hwpe_stream_intf_stream.source addr_o
);

    // ---------------------------------------------------------------------------------------------
    // Y_data_scheduler Module (Gustavson-Z adaptation)
    //
    // Streams dense matrix Y in blocks, driven by the bitmap of X’s current row. 
    // For each '1' bit in metadata_chunk (i.e. each nonzero X(i,k)), 
    // iterate over all Y-column-blocks of Y[k,*]. Each block is Y_BLOCK_SIZE consecutive columns.
    // Does NOT issue memory requests for metadata; instead raises meta_used_o=1 to indicate 
    // "please load next metadata_chunk." Assumptions:
    //  - metadata_chunk is a full X_COLUMNS-wide bitmap for the current X-row.
    //  - params_i.base_address refers to the base of Y in memory (in bytes).
    //  - DATA_SIZE_BYTES = DATA_SIZE/8, row-major storage.
    //  - Y blocks are stored contiguously per row: 
    //       Y[k, b*Y_BLOCK_SIZE + 0 .. Y_BLOCK_SIZE-1] are consecutive elements.
    //  - When a new metadata_chunk arrives (meta_used_i=1), we clear all scanning state 
    //    and start at scanned_columns=0 for the next X row.
    //  - ADDRESS calculation may use multiplication by Y_COLUMNS; left as straightforward "*".
    //  - We issue one block-load request per sched_proceed_i tick (within bandwidth limits).
    //  - We do not attempt to pack multiple Y blocks into one request; each request is exactly Y_BLOCK_SIZE elements.
    //----------------------------------------------------------------------------------------------

    // State registers
    logic chunk_done;
    logic [15:0] previous_meta_addr_q, previous_meta_addr_d;
    logic [15:0]  x_row_q, x_row_d;                                 // Actual row of X
    logic [15:0]  scanned_rows_q, scanned_rows_d;                   // Current row index in Y-column block being scanned
    logic [15:0]  y_col_block_q, y_col_block_d;                     // Which block (0..params_i.y_row_iters-1) of Y[*] we're loading
    logic [15:0]  meta_chunk_used_bits_q, meta_chunk_used_bits_d;   // Counts come many bits of the metadata chunk have been used
    logic [META_CHUNK_SIZE - 1 : 0] meta_portion_tocheck;
    logic [$clog2(META_CHUNK_SIZE) - 1 : 0] meta_position;
    logic           needing_meta_q, needing_meta_d;                   // High if we need a fresh metadata_chunk
    Y_param_t       params_q, params_d;
    flags_fifo_t    flags_addr_fifo;

    assign meta_portion_tocheck = (metadata_chunk << meta_chunk_used_bits_q);

    // Derived constants
    localparam int DATA_SIZE_BYTES      = DATA_SIZE >> 3;
    localparam int DATA_SIZE_BYTES_LOG  = $clog2(DATA_SIZE_BYTES);
    localparam int Y_BLOCK_SIZE_LOG     = $clog2(Y_BLOCK_SIZE);
    localparam int META_CHUNK_SIZE_LOG  = $clog2(META_CHUNK_SIZE);
    localparam int META_CHUNK_SIZE_BYTE = META_CHUNK_SIZE / 8;
    localparam int META_CHUNK_SIZE_BYTES_LOG = $clog2(META_CHUNK_SIZE_BYTE);

    lzc #(
        .WIDTH (META_CHUNK_SIZE),
        .MODE (1)
    ) meta_searcher (
        .in_i               (meta_portion_tocheck),
        .cnt_o              (meta_position),
        .empty_o            (chunk_done)
    );

    hwpe_stream_intf_stream #(
        .DATA_WIDTH (48)
    ) push_addr (
        .clk(clk_i)
    );

    assign push_addr.strb = '1;

    hwpe_stream_fifo #(
        .DATA_WIDTH (48),
        .FIFO_DEPTH (2)
    ) Y_addr_fifo (
        .clk_i       ( clk_i                       ),
        .rst_ni      ( rst_ni                      ),
        .clear_i     ( clear_i                     ),

        .flags_o    (flags_addr_fifo),
        .push_i     (push_addr),
        .pop_o      (addr_o)
    );

    always_comb
    begin

        // Default: hold current state
        x_row_d                 = x_row_q;
        scanned_rows_d          = scanned_rows_q;
        y_col_block_d           = y_col_block_q;
        needing_meta_d          = needing_meta_q;
        meta_chunk_used_bits_d  = meta_chunk_used_bits_q;
        params_d                = params_q;
        previous_meta_addr_d    = previous_meta_addr_q;

        push_addr.valid = 1'b0;

        if (working_i) begin

            if (needing_meta_q)
                needing_meta_d = meta_used_i;
            else
                needing_meta_d = needing_meta_q;

            if (!flags_addr_fifo.full && ((needing_meta_q && !meta_used_i) || !needing_meta_q) ) begin

                // For the next request
                scanned_rows_d         = scanned_rows_q + meta_position + 1;
                meta_chunk_used_bits_d = meta_chunk_used_bits_q + meta_position + 1;

                // If the whole column doesn't have dense elements it simply gets skipped
                if((scanned_rows_q == '0) && ((scanned_rows_q + meta_position) >= params_q.y_rows)) begin
                    x_row_d = x_row_q + 1;
                    meta_chunk_used_bits_d = meta_chunk_used_bits_q + params_q.y_rows;
                    scanned_rows_d = '0;
                    if(previous_meta_addr_q != (params_q.x_base_address + ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))) begin
                        needing_meta_d = 1;
                        previous_meta_addr_d = params_q.x_base_address + ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG);
                        meta_chunk_used_bits_d = '0;
                    end
                end else if (scanned_rows_q + meta_position >= params_q.y_rows || ((needing_meta_q && !meta_used_i) && chunk_done && (scanned_rows_q + meta_position + 1) >= params_q.y_rows)) begin

                    //Can you keep using the previous metadata chunk?
                    if(previous_meta_addr_q != (params_q.x_base_address + (((x_row_q << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))) begin
                        needing_meta_d = 1;
                        previous_meta_addr_d = params_q.x_base_address + (((x_row_q << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG);
                    end
                    
                    scanned_rows_d            = '0;
                    y_col_block_d             = y_col_block_q + 16'b1;
                    meta_chunk_used_bits_d    = (x_row_q << params_q.x_columns_log) - (((x_row_q << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_LOG);

                    // Next row of X? Hence restart of the matrix Y
                    if (y_col_block_q + 1 >= params_q.y_row_iters) begin

                        if(previous_meta_addr_q != (params_q.x_base_address + ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG))) begin
                            needing_meta_d = 1;
                            previous_meta_addr_d = params_q.x_base_address + ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_BYTES_LOG);
                        end

                        meta_chunk_used_bits_d    = ((x_row_q + 1) << params_q.x_columns_log) - ((((x_row_q + 1) << params_q.x_columns_log) >> META_CHUNK_SIZE_LOG) << META_CHUNK_SIZE_LOG);
                        y_col_block_d             = '0;
                        x_row_d                   = x_row_q + 16'b1;

                    end
                end else if (chunk_done)begin

                    scanned_rows_d            = scanned_rows_q + (META_CHUNK_SIZE - meta_chunk_used_bits_q);
                    needing_meta_d            = 1;
                    previous_meta_addr_d      = previous_meta_addr_q + META_CHUNK_SIZE_BYTE;
                    meta_chunk_used_bits_d    = '0;

                end
            end

            //REQUEST PUSH
            if(push_addr.ready && !needing_meta_q && scanned_rows_q != '0) begin

                push_addr.valid = 1'b1;
                push_addr.data = {((y_col_block_q << Y_BLOCK_SIZE_LOG) + Y_BLOCK_SIZE) > params_q.y_columns ? (params_q.y_columns - (y_col_block_q << Y_BLOCK_SIZE_LOG)): Y_BLOCK_SIZE, params_q.base_address + ((((scanned_rows_q - 1) << params_q.y_columns_log) + (y_col_block_q << Y_BLOCK_SIZE_LOG)) << DATA_SIZE_BYTES_LOG)};
            
            end 
        
        end else begin

            previous_meta_addr_d = params_q.x_base_address;
            params_d = params_i;

        end

    end

    always_ff @(posedge clk_i or negedge rst_ni)
    begin
        if(~rst_ni) begin

            params_q                    <= '0;
            x_row_q                     <= '0;
            scanned_rows_q              <= '0;
            y_col_block_q               <= '0;
            needing_meta_q              <= 1'b1;
            meta_chunk_used_bits_q      <= '0;
            previous_meta_addr_q        <= '0;

        end else if(clear_i)begin

            params_q                    <= '0;
            x_row_q                     <= '0;
            scanned_rows_q              <= '0;
            y_col_block_q               <= '0;
            needing_meta_q              <= 1'b1;
            meta_chunk_used_bits_q      <= '0;
            previous_meta_addr_q        <= '0;

        end else begin

            params_q                    <= params_d;
            x_row_q                     <= x_row_d;
            scanned_rows_q              <= scanned_rows_d;
            y_col_block_q               <= y_col_block_d;
            meta_chunk_used_bits_q      <= meta_chunk_used_bits_d;
            needing_meta_q              <= needing_meta_d;
            previous_meta_addr_q        <= previous_meta_addr_d;
            
        end
    end

    assign meta_used_o     = needing_meta_q && flags_addr_fifo.empty;
    assign request_ready_o = !flags_addr_fifo.empty;

endmodule

`endif // Y_DATA_SCHEDULER_SV
