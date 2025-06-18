import accelerator_package::*;
import hci_package::*;

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

    input  logic                 sched_proceed_i,    // Advance scheduler
    input  logic                 meta_used_i,      // Indicates new metadata_chunk is ready
    output logic                 meta_used_o,      // Raises high to request new metadata

    input  logic [META_CHUNK_SIZE-1:0] metadata_chunk, // Bitmap for one row of X

    input  Y_param_t             params_i,

    output hci_streamer_ctrl_t   config_o           // Configuration to load Y blocks
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
    logic [15:0]  x_row_q, x_row_d;                                 // Actual row of X
    logic [15:0]  scanned_rows_q, scanned_rows_d;                   // Current row index in Y-column block being scanned
    logic [15:0]  y_col_block_q, y_col_block_d;                     // Which block (0..params_i.y_row_iters-1) of Y[*] we're loading
    logic [15:0]  meta_chunk_used_bits_q, meta_chunk_used_bits_d;   // Counts come many bits of the metadata chunk have been used
    logic [15:0]  row_to_load_q, row_to_load_d;                     // Keeps the index of the Y row to load
    logic         needing_meta_q, needing_meta_d;                   // High if we need a fresh metadata_chunk

    hci_streamer_ctrl_t config_o_q, config_o_d;

    // Derived constants
    localparam int DATA_SIZE_BYTES      = DATA_SIZE >> 3;
    localparam int DATA_SIZE_BYTES_LOG  = $clog2(DATA_SIZE_BYTES);
    localparam int Y_BLOCK_SIZE_LOG     = $clog2(Y_BLOCK_SIZE);

    // ---------------------------------------------------------------------------------------------
    // Combinatorial logic: next-state and config generation
    // ---------------------------------------------------------------------------------------------
    always_comb begin
        // Default: hold current state
        x_row_d                 = x_row_q;
        scanned_rows_d          = scanned_rows_q;
        y_col_block_d           = y_col_block_q;
        needing_meta_d          = needing_meta_q;
        meta_chunk_used_bits_d  = meta_chunk_used_bits_q;
        row_to_load_d           = row_to_load_q;
        config_o_d              = config_o_q;

        if (needing_meta_q)
            needing_meta_d = meta_used_i;
        else
            needing_meta_d = needing_meta_q;

        if (sched_proceed_i) begin
            
            // First we check if we need metadata
            // End of row?
            if (scanned_rows_q >= params_i.y_rows) begin

                scanned_rows_d            = '0;
                meta_chunk_used_bits_d    = 16'd8 - ((META_CHUNK_SIZE - meta_chunk_used_bits_q) & 3'b111);  // The next tile of metadata might have the first byte that shares bits with the previous row
                needing_meta_d            = 1'b1;
                y_col_block_d             = y_col_block_q + 16'b1;

                // Next X row?
                if (y_col_block_d >= params_i.y_row_iters) begin

                    meta_chunk_used_bits_d    = '0;
                    y_col_block_d             = '0;
                    x_row_d                   = x_row_q + 16'b1;

                end

            end else if (meta_chunk_used_bits_q >= META_CHUNK_SIZE) begin

                meta_chunk_used_bits_d      = '0;
                needing_meta_d              = 1'b1;

            end else begin

                // Loop to search for the next tile of Y to load
                while ((meta_chunk_used_bits_d < META_CHUNK_SIZE) && (scanned_rows_d < params_i.y_rows) && (row_to_load_d == row_to_load_q)) begin
                    if (metadata_chunk[meta_chunk_used_bits_d])
                        row_to_load_d = scanned_rows_d;
                    meta_chunk_used_bits_d   = meta_chunk_used_bits_d + 1'b1;
                    scanned_rows_d           = scanned_rows_d + 1'b1;
                end

                // Check if there is indeed a new row chunk to load or the metadata chunk/ Y column is just finished
                if (row_to_load_d == row_to_load_q)begin

                    // End of row?
                    if (scanned_rows_d >= params_i.y_rows) begin

                        scanned_rows_d            = '0;
                        meta_chunk_used_bits_d    = 16'd8 - ((META_CHUNK_SIZE - meta_chunk_used_bits_q) & 3'b111);  // The next tile of metadata might have the first byte that shares bits with the previous row
                        needing_meta_d            = 1'b1;
                        y_col_block_d             = y_col_block_q + 16'b1;

                        // Next X row?
                        if (y_col_block_d >= params_i.y_row_iters) begin

                            meta_chunk_used_bits_d    = '0;
                            y_col_block_d             = '0;
                            x_row_d                   = x_row_q + 16'b1;

                        end

                    end else if (meta_chunk_used_bits_d >= META_CHUNK_SIZE) begin

                        meta_chunk_used_bits_d      = '0;
                        needing_meta_d              = 1'b1;

                    end

                end else begin

                    if (x_row_d >= params_i.x_rows) begin

                        // The calculation is finished and everything starts again
                        x_row_d                     = '0;
                        scanned_rows_d              = '0;
                        y_col_block_d               = '0;
                        needing_meta_d              = '1;
                        meta_chunk_used_bits_d      = '0;
                        row_to_load_d               = '0;

                        config_o_d                  = '0;

                    end else begin

                        // Config to load Y
                        config_o_d.req_start = 1'b0;
                        config_o_d.addressgen_ctrl.base_addr = params_i.base_address + ((((y_col_block_q << Y_BLOCK_SIZE_LOG) << params_i.y_rows_log) + row_to_load_d) << DATA_SIZE_BYTES_LOG);
                        config_o_d.addressgen_ctrl.tot_len   = (((y_col_block_q << Y_BLOCK_SIZE_LOG) + Y_BLOCK_SIZE) <= params_i.y_columns) ? Y_BLOCK_SIZE : (params_i.y_columns - (y_col_block_q << Y_BLOCK_SIZE_LOG));
                        config_o_d.addressgen_ctrl.d0_len    = (((y_col_block_q << Y_BLOCK_SIZE_LOG) + Y_BLOCK_SIZE) <= params_i.y_columns) ? Y_BLOCK_SIZE : (params_i.y_columns - (y_col_block_q << Y_BLOCK_SIZE_LOG));
                        config_o_d.addressgen_ctrl.d0_stride = DATA_SIZE_BYTES;

                    end
                end
            end
        end
    end

    // ---------------------------------------------------------------------------------------------
    // Sequential logic: update registers on rising clock
    // ---------------------------------------------------------------------------------------------
    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin

            x_row_q                     <= '0;
            scanned_rows_q              <= '0;
            y_col_block_q               <= '0;
            needing_meta_q              <= 1'b1;
            meta_chunk_used_bits_q      <= '0;
            row_to_load_q               <= '0;
            config_o_q                  <= '0;

        end else begin
            if (clear_i) begin

                x_row_q                     <= '0;
                scanned_rows_q              <= '0;
                y_col_block_q               <= '0;
                needing_meta_q              <= '1;
                meta_chunk_used_bits_q      <= '0;
                row_to_load_q               <= '0;
                config_o_q                  <= '0;

            end else begin

                x_row_q                     <= x_row_d;
                scanned_rows_q              <= scanned_rows_d;
                y_col_block_q               <= y_col_block_d;
                meta_chunk_used_bits_q      <= meta_chunk_used_bits_d;
                row_to_load_q               <= row_to_load_d;
                needing_meta_q              <= needing_meta_d;
                config_o_q                  <= config_o_d;

            end
        end
    end

    assign config_o    = config_o_q;
    assign meta_used_o = needing_meta_q;

endmodule

`endif // Y_DATA_SCHEDULER_SV
