import hwpe_ctrl_package::*;
import hci_package::*;

module output_stream_accumulator #(
  parameter int unsigned INPUT_ITEM_SIZE,
  parameter int unsigned BW_IN  = 128,
  parameter int unsigned BW_OUT = 32
)(
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   clear_i,
  input hci_streamer_flags_t flags_sink_i,

  // input stream from the engine
  hwpe_stream_intf_stream.sink   stream_i,

  // output stream of data packages
  hwpe_stream_intf_stream.source stream_o
);

    // how many input beats fit in one output word
    localparam int unsigned STRB_BITS_CYCLE = BW_OUT / 32;
    localparam int unsigned STRB_BITS_CYCLE_LOG = $clog2(STRB_BITS_CYCLE);
    localparam int unsigned N_BEATS = (BW_IN + BW_OUT - 1) / BW_OUT;
    localparam int unsigned DATA_SIZE_BYTES_LOG = $clog2(INPUT_ITEM_SIZE / 8);

    logic [(N_BEATS * BW_OUT)-1:0]  buffer_d, buffer_q;
    logic [15:0]       beat_count_d, beat_count_q;

    typedef enum logic {SENDING_DATA, RECEIVING_DATA} accumulator_state_t;
    accumulator_state_t accumulator_state_q, accumulator_state_d;

    // Combinational: compute next state and outputs
    always_comb 
    begin: output_acc_fsm_ns

        accumulator_state_d  = accumulator_state_q;

        if(accumulator_state_q == SENDING_DATA) begin
            if(flags_sink_i.done)
                accumulator_state_d = RECEIVING_DATA;
        end
        else if(accumulator_state_q == RECEIVING_DATA) begin
            if (flags_sink_i.ready_start && stream_i.ready && stream_i.valid)
                accumulator_state_d = SENDING_DATA;
        end

    end

    always_comb 
    begin: output_acc_fsm_out_comb
        // defaults
        beat_count_d    = beat_count_q;

        stream_i.ready = 1'b0;
        stream_o.valid = 1'b0;

        if(accumulator_state_q == SENDING_DATA) begin

            if(beat_count_q >= N_BEATS)
                stream_o.valid = 1'b0;
            else
                stream_o.valid = 1'b1;

            stream_o.data = buffer_q[(((beat_count_q + 1) * BW_OUT) - 1) -: BW_OUT];
            stream_o.strb = '1;

            if (stream_o.ready && stream_o.valid && beat_count_q < N_BEATS)
                beat_count_d  = beat_count_q + 16'b1;

        end
        else if(accumulator_state_q == RECEIVING_DATA) begin

            stream_i.ready = 1'b1;
            beat_count_d = '0;

        end

    end

    genvar i, j;

    generate
    for (j = 0; j < N_BEATS; j++) begin
        for (i = 0; i < BW_OUT / 32; i = i + 1) begin
            
            localparam int stream_data_idx = (N_BEATS - j) * BW_OUT - i * 32 - 1;
            localparam int buffer_idx      = j * BW_OUT + (i + 1) * 32 - 1;

            if (stream_data_idx < BW_IN && buffer_idx < BW_IN) begin
                assign buffer_d[buffer_idx -: 32] =
                (accumulator_state_q == RECEIVING_DATA && stream_i.valid)
                    ? stream_i.data[stream_data_idx -: 32]
                    : buffer_q[buffer_idx -: 32];
            end else begin
                assign buffer_d[buffer_idx -: 32] = buffer_q[buffer_idx -: 32];
            end
        end
    end
    endgenerate

    always_ff @(posedge clk_i or negedge rst_ni) 
    begin: output_acc_fsm_seq
        if (!rst_ni) begin
            buffer_q                <= '0;
            beat_count_q            <= '0;
            accumulator_state_q     <= RECEIVING_DATA;
        end else if (clear_i) begin
            buffer_q                <= '0;
            beat_count_q            <= '0;
            accumulator_state_q     <= RECEIVING_DATA;
        end else begin
            buffer_q                <= buffer_d;
            beat_count_q            <= beat_count_d;
            accumulator_state_q     <= accumulator_state_d;
        end
    end
    
    endmodule