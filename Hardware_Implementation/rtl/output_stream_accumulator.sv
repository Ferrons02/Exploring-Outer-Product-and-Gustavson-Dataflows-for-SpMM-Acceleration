import hwpe_ctrl_package::*;

module output_stream_accumulator #(
  parameter int unsigned BW_IN  = 128,
  parameter int unsigned BW_OUT = 32
)(
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   clear_i,

  // input stream from the engine
  hwpe_stream_intf_stream.sink   stream_i,

  // output stream of data packages
  hwpe_stream_intf_stream.source stream_o
);

    // how many input beats fit in one output word
    localparam int unsigned STRB_BITS_CYCLE = BW_IN / 8;
    localparam int unsigned N_BEATS = BW_OUT / BW_IN;

    logic [BW_IN/8-1:0] strb_d, strb_q;
    logic [BW_IN-1:0]  buffer_d, buffer_q;
    logic [15:0]       data_beat_count_d, data_beat_count_q;
    logic [15:0]       strb_count_d, strb_count_q;

    typedef enum logic {SENDING_DATA, RECEIVING_DATA} accumulator_state_t;
    accumulator_state_t accumulator_state_q, accumulator_state_d;

    // Combinational: compute next state and outputs
    always_comb begin
        // defaults
        buffer_d             = buffer_q;
        data_beat_count_d    = data_beat_count_q;
        accumulator_state_d  = accumulator_state_q;
        strb_d               = strb_q;
        strb_count_d         = strb_count_q;

        stream_o.valid = 1'b0;
        stream_i.ready = 1'b0;

        if(accumulator_state_q == SENDING_DATA) begin
            
            stream_o.valid = 1'b1;

            if (stream_o.ready) begin
                
                stream_o.data = buffer_q[data_beat_count_q * BW_OUT +: BW_OUT];
                stream_o.strb = strb_d[strb_count_q * STRB_BITS_CYCLE +: STRB_BITS_CYCLE];
                data_beat_count_d  = data_beat_count_q + 16'b1;
                strb_count_d  = strb_count_q + 16'b1;
                
            end

            if(data_beat_count_d >= N_BEATS) begin
                stream_o.valid    = 1'b0;
                accumulator_state_d = RECEIVING_DATA;
            end

        end
        else if(accumulator_state_q == RECEIVING_DATA) begin

            stream_i.ready = 1'b1;

            if (stream_i.valid == 1'b1) begin
                buffer_d          = stream_i.data;
                strb_d            = stream_i.strb;
                data_beat_count_d = '0;
                strb_count_d      = '0;
                accumulator_state_d = SENDING_DATA;
            end

        end

    end

    always_ff @(posedge clk_i or negedge rst_ni) begin
        if (!rst_ni) begin
            buffer_q                <= '0;
            data_beat_count_q       <= 0;
            accumulator_state_q     <= RECEIVING_DATA;
            strb_q                  <= '0;
            strb_count_q            <= '0;
        end
        else begin
            if (clear_i) begin
                buffer_q                <= '0;
                data_beat_count_q       <= 0;
                accumulator_state_q     <= RECEIVING_DATA;
                strb_q                  <= '0;
                strb_count_q            <= '0;
            end
            else begin
                buffer_q                <= buffer_d;
                data_beat_count_q       <= data_beat_count_d;
                accumulator_state_q     <= accumulator_state_d;
                strb_q                  <= strb_d;
                strb_count_q            <= strb_count_d;
            end
        end
    end
    
    endmodule
