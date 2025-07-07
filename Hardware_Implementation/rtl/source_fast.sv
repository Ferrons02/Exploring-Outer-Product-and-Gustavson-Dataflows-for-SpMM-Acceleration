/*
 * hci_core_source.sv
 * Francesco Conti <f.conti@unibo.it>
 * Arpan Suravi Prasad <prasadar@iis.ee.ethz.ch>
 *
 * Copyright (C) 2014-2022 ETH Zurich, University of Bologna
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

/**
 * The **hci_core_source** module is the high-level source streamer
 * performing a series of loads on a HCI-Core interface
 * and producing a HWPE-Stream data stream to feed a HWPE engine/datapath.
 * The source streamer is a composite module that makes use of many other
 * fundamental IPs.
 *
 * Fundamentally, a source streamer acts as a specialized DMA engine acting
 * out a predefined pattern from an **hwpe_stream_addressgen_v3** to perform
 * a burst of loads via a HCI-Core interface, producing a HWPE-Stream
 * data stream from the HCI-Core `r_data` field.
 * By default, the HCI-Core streamer supports delayed accesses using a HCI-Core 
 * interface.
 *
 * Misaligned accesses are supported by widening the HCI-Core data width of 32
 * bits compared to the HWPE-Stream that gets produced by the streamer.
 * Unused bytes are simply ignored. This feature can be deactivated by unsetting
 * the `MISALIGNED_ACCESS` parameter; in this case, the sink will
 * only work correctly if all data is aligned to a word boundary.
 *
 * In principle, the source streamer is insensitive to latency.
 * However, when configured to support misaligned memory accesses, the address FIFO
 * depth sets the maximum supported latency.
 * This parameter can be controlled by the `ADDR_MIS_DEPTH` parameter (default 8).
 *
 * .. tabularcolumns:: |l|l|J|
 * .. _hci_core_source_params:
 * .. table:: **hci_core_source** design-time parameters.
 *
 *   +---------------------+-------------+--------------------------------------------------------------------------------------------------------------------------+
 *   | **Name**            | **Default** | **Description**                                                                                                          |
 *   +---------------------+-------------+--------------------------------------------------------------------------------------------------------------------------+
 *   | *LATCH_FIFO*        | 0           | If 1, use latches instead of flip-flops (requires special constraints in synthesis).                                     |
 *   +---------------------+-------------+--------------------------------------------------------------------------------------------------------------------------+
 *   | *TRANS_CNT*         | 16          | Number of bits supported in the transaction counter of the address generator, which will overflow at 2^ `TRANS_CNT`.     |
 *   +---------------------+-------------+--------------------------------------------------------------------------------------------------------------------------+
 *   | *ADDR_MIS_DEPTH*    | 8           | Depth of the misaligned address FIFO. This **must** be equal to the max-latency between the HCI-Core `gnt` and `r_valid`.|
 *   +---------------------+-------------+--------------------------------------------------------------------------------------------------------------------------+
 *   | *MISALIGNED_ACCESS* | 1           | If set to 0, the source will not support non-word-aligned HCI-Core accesses.                                             |
 *   +---------------------+-------------+--------------------------------------------------------------------------------------------------------------------------+
 *   | *PASSTHROUGH_FIFO*  | 0           | If set to 1, the address FIFO will be capable of fall-through operation (i.e., skipping the FIFO latency entirely).      |
 *   +---------------------+-------------+--------------------------------------------------------------------------------------------------------------------------+
 *
 * .. tabularcolumns:: |l|l|J|
 * .. _hci_core_source_ctrl:
 * .. table:: **hci_core_source** input control signals.
 *
 *   +-------------------+------------------------+----------------------------------------------------------------------------+
 *   | **Name**          | **Type**               | **Description**                                                            |
 *   +-------------------+------------------------+----------------------------------------------------------------------------+
 *   | *req_start*       | `logic`                | When 1, the source streamer operation is started if it is ready.           |
 *   +-------------------+------------------------+----------------------------------------------------------------------------+
 *   | *addressgen_ctrl* | `ctrl_addressgen_v3_t` | Configuration of the address generator (see **hwpe_stream_addresgen_v3**). |
 *   +-------------------+------------------------+----------------------------------------------------------------------------+
 *
 * .. tabularcolumns:: |l|l|J|
 * .. _hci_core_source_flags:
 * .. table:: **hci_core_source** output flags.
 *
 *   +--------------------+------------------------+-----------------------------------------------------------------------------------------------+
 *   | **Name**           | **Type**               | **Description**                                                                               |
 *   +--------------------+------------------------+-----------------------------------------------------------------------------------------------+
 *   | *ready_start*      | `logic`                | 1 when the source streamer is ready to start operation, from the first IDLE state cycle on.   |
 *   +--------------------+------------------------+-----------------------------------------------------------------------------------------------+
 *   | *done*             | `logic`                | 1 for one cycle when the streamer ends operation, in the cycle before it goes to IDLE state . |
 *   +--------------------+------------------------+-----------------------------------------------------------------------------------------------+
 *   | *addressgen_flags* | `flags_addressgen_v3_t`| Address generator flags (see **hwpe_stream_addresgen_v3**).                                   |
 *   +--------------------+------------------------+-----------------------------------------------------------------------------------------------+
 *
 */

`include "hci_helpers.svh"

module source_fast
  import hwpe_stream_package::*;
  import hci_package::*;
#(
  // Stream interface params
  parameter int unsigned LATCH_FIFO  = 0,
  parameter int unsigned TRANS_CNT = 16,
  parameter int unsigned ADDR_MIS_DEPTH = 8, // Beware: this must be >= the maximum latency between TCDM gnt and TCDM r_valid!!!
  parameter int unsigned MISALIGNED_ACCESSES = 1,
  parameter int unsigned PASSTHROUGH_FIFO = 0,
  parameter hci_size_parameter_t `HCI_SIZE_PARAM(tcdm) = '0,
  parameter bit [2:0] DIM_ENABLE_1H = 3'b011 // Number of dimensions enabled in the address generator
)
(
  input logic clk_i,
  input logic rst_ni,
  input logic test_mode_i,
  input logic clear_i,
  input logic enable_i,
  input logic req_start,

  hci_core_intf.initiator        tcdm,
  hwpe_stream_intf_stream.source stream,

  // control plane
  hwpe_stream_intf_stream.sink   addr_i,
  output hci_streamer_flags_t  flags_o
);

  localparam int unsigned DATA_WIDTH = `HCI_SIZE_GET_DW(tcdm);
  localparam int unsigned EHW        = `HCI_SIZE_GET_EHW(tcdm);

  logic [DATA_WIDTH-1:0] stream_data_misaligned;
  logic [DATA_WIDTH-1:0] stream_data_aligned;

  logic ready_start_d, ready_start_q;
  assign ready_start_d = (stream.valid & stream.ready) || (ready_start_q && !req_start) || (!ready_start_q && req_start);

  // this is simply exploiting the fact that we can make a wider data access than strictly necessary!
  assign stream_data_misaligned = tcdm.r_valid ? tcdm.r_data : '0;
  assign addr_i.ready = stream.ready & tcdm.gnt;

  if (MISALIGNED_ACCESSES==1 ) begin : missaligned_access_gen
    always_comb
    begin
      stream_data_aligned = '0;
      case(addr_i.data[1:0])
        2'b00: begin
          stream_data_aligned[DATA_WIDTH-1:0] = stream_data_misaligned[DATA_WIDTH-1:0];
        end
        2'b01: begin
          stream_data_aligned[DATA_WIDTH-32-1:0] = stream_data_misaligned[DATA_WIDTH-24-1:8];
        end
        2'b10: begin
          stream_data_aligned[DATA_WIDTH-32-1:0] = stream_data_misaligned[DATA_WIDTH-16-1:16];
        end
        2'b11: begin
          stream_data_aligned[DATA_WIDTH-32-1:0] = stream_data_misaligned[DATA_WIDTH-8-1:24];
        end
      endcase
    end
  end
  else begin
    assign stream_data_aligned[DATA_WIDTH-1:0] = stream_data_misaligned[DATA_WIDTH-1:0];
  end

  assign tcdm.r_ready = stream.ready;
  assign tcdm.req     = req_start & stream.ready & addr_i.valid;
  assign tcdm.add     = addr_i.data;
  assign tcdm.wen     = 1'b1;
  assign tcdm.be      = 4'h0;
  assign tcdm.data    = '0;
  assign tcdm.user    = '0;
  assign tcdm.id      = '0;
  assign tcdm.ecc     = '0;
  assign stream.strb  = '1;
  assign stream.data  = stream_data_aligned;
  assign stream.valid = enable_i & tcdm.r_valid;

  assign flags_o.done = tcdm.gnt;
  assign flags_o.ready_start = ready_start_q || (stream.valid & stream.ready);
  
  always_ff @(posedge clk_i or negedge rst_ni)
  begin
    if(~rst_ni) begin
      ready_start_q <= 1;
    end else if(clear_i)begin
      ready_start_q <= 1;
    end else begin
      ready_start_q <= ready_start_d;
    end
  end

/*
 * ECC Handshake signals
 */
  if(EHW > 0) begin : ecc_handshake_gen
    assign tcdm.ereq     = '{default: {tcdm.req}};
    assign tcdm.r_eready = '{default: {tcdm.r_ready}};
  end
  else begin : no_ecc_handshake_gen
    assign tcdm.ereq     = '0;
    assign tcdm.r_eready = '1; // assign all gnt's to 1 
  end

/*
 * Interface size asserts
 */
`ifndef SYNTHESIS
`ifndef VERILATOR
`ifndef VCS
  if(MISALIGNED_ACCESSES == 0) begin
    initial
      dw :  assert(stream.DATA_WIDTH == tcdm.DW);
  end
  else begin
    initial
      dw :  assert(stream.DATA_WIDTH <= tcdm.DW);
  end
  
  `HCI_SIZE_CHECK_ASSERTS(tcdm);
`endif
`endif
`endif

endmodule // hci_core_source