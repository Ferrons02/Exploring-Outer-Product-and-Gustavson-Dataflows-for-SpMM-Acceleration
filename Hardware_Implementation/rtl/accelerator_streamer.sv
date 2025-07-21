/*
 * Copyright (C) 2020 ETH Zurich and University of Bologna
 *
 * Copyright and related rights are licensed under the Solderpad Hardware
 * License, Version 0.51 (the "License"); you may not use this file except in
 * compliance with the License.  You may obtain a copy of the License at
 * http://solderpad.org/licenses/SHL-0.51. Unless required by applicable law
 * or agreed to in writing, software, hardware and materials distributed under
 * this License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 */

/*
 * Authors:  Francesco Conti <f.conti@unibo.it>
 */

import hwpe_stream_package::*;
import hwpe_ctrl_package::*;
import hci_package::*;
import accelerator_package::*;

`include "hci_helpers.svh"

module accelerator_streamer #(
  parameter int unsigned BW = 32,                     // total width of the tcdm
  parameter int unsigned TCDM_FIFO_DEPTH = 2,
  parameter int unsigned MISALIGNED_ACCESSES = 0,
  parameter int unsigned META_CHUNK_SIZE = 32,        // size of the metadata chunk that will be loaded
  parameter int unsigned X_ITEM_SIZE = 32,            // size in bit of one entry of the X matrix
  parameter int unsigned Y_ITEM_SIZE = 32,            // size in bit of one entry of the Y matrix
  parameter int unsigned Z_ITEM_SIZE = 64,            // size in bit of one entry of the Z matrix
  parameter int unsigned Y_BLOCK_SIZE = 4,
  // X elem size is fixed to be 1 in order to avoid non contiguous accesses

  parameter hci_size_parameter_t `HCI_SIZE_PARAM(tcdm) = '0
) (
  // global signals
  input  logic                   clk_i,
  input  logic                   rst_ni,
  input  logic                   test_mode_i,
  // local clear
  input  logic                   clear_i,
  // output data stream (towards engine) + handshake
  hwpe_stream_intf_stream.source dataX_o,
  hwpe_stream_intf_stream.source dataY_o,
  // input data stream (from the engine) + handshake
  hwpe_stream_intf_stream.sink   dataZ_i,
  // TCDM ports
  hci_core_intf.initiator        tcdm,
  // Metadata output port
  output logic[META_CHUNK_SIZE-1:0] metadata_buf_o,
  // control channel
  input  params_schedulers_t     params_schedulers_i,
  input  ctrl_streamer_t         ctrl_i
);

  localparam int unsigned UW  = `HCI_SIZE_GET_UW(tcdm);
  localparam int unsigned IW  = `HCI_SIZE_GET_IW(tcdm);
  localparam int unsigned EW  = `HCI_SIZE_GET_EW(tcdm);
  localparam int unsigned EHW = `HCI_SIZE_GET_EHW(tcdm);

  localparam int MAX_ELEMS_PER_REQ     = (BW / X_ITEM_SIZE) > 0 ? $floor(BW / X_ITEM_SIZE) : 1;
  localparam int unsigned X_ITEM_SIZE_LOG = $clog2(X_ITEM_SIZE);
  localparam int unsigned Y_ITEM_SIZE_LOG = $clog2(Y_ITEM_SIZE);
  // We "sacrifice" 1 word of memory interface bandwidth in order to support
  // realignment at a byte boundary if the access are misaligned.
  localparam Z_BW_ALIGNED = MISALIGNED_ACCESSES === 0 ? BW : BW-32;

  logic passed_from_y_d, passed_from_y_q;
  logic [BW - 1 : 0] X_buf_d, X_buf_q;
  logic [7:0] elem_cnt_d, elem_cnt_q;
  logic meta_in_buf_d, meta_in_buf_q;
  logic [15:0] Y_mask_d, Y_mask_q;
  logic req_start_source;
  logic[1:0] data_demux_sel_d, data_demux_sel_q;
  logic req_mux_sel;
  logic[META_CHUNK_SIZE-1:0] metadata_buf_data_d, metadata_buf_data_q;

  // Source and sink flag and control signals
  hci_streamer_ctrl_t sink_ctrl, sink_ctrl_d, sink_ctrl_q;
  hci_streamer_flags_t source_flags;
  hci_streamer_flags_t sink_flags;

  // Signals for the storing FSM
  hci_streamer_ctrl_t Z_sink_ctrl;
  logic Zsched_proceed;

  // State for the storing FSM
  typedef enum { SINK_INACTIVE, SINK_IDLE, STORING_Z } sink_state;
  sink_state sink_state_d, sink_state_q;

  // Signals for the loading FSM
  logic meta_used_for_X_i, meta_used_for_X_o;
  logic meta_used_for_Y_i, meta_used_for_Y_o;
  logic need_for_meta;
  assign need_for_meta = meta_used_for_X_i & meta_used_for_Y_i;
  logic X_request_ready, Y_request_ready;
  logic load_new_X, load_new_Y;
  assign load_new_X = dataX_o.ready & (!meta_used_for_X_i) &  X_request_ready;
  assign load_new_Y = dataY_o.ready & (!meta_used_for_Y_i) & Y_request_ready;

  // State for the loading FSM
  typedef enum { SOURCE_INACTIVE, SOURCE_IDLE, LOADING_META, LOADING_X, LOADING_Y} source_state;
  source_state source_state_d, source_state_q;

  assign Y_mask_d = (Y_source_req.valid && Y_source_req.ready && !need_for_meta) ? Y_source_req.data[47:32] : Y_mask_q;

  // "Virtual" HCI TCDM interfaces. Interface [0] maps loads (coming from
  // and HCI source) and interface [1] maps stores (coming from an HCI sink).
  hci_core_intf #(
    .DW  ( BW ),
    .BW  ( 32 ),
    .UW  ( UW ),
    .IW  ( IW ),
    .EW  ( EW ),
    .EHW ( EHW)
  ) virt_tcdm [1:0] (
    .clk ( clk_i )
  );
  
  // "Virtual" TCDM interface, used to embody data after the TCDM FIFO
  // (if present) but before the load filter. Notice this is technically
  // an array of interfaces, with one single instance inside. This is
  // useful because HCI muxes expect an array of output interfaces.
  hci_core_intf #(
    .DW  ( BW ),
    .BW  ( 32 ),
    .UW  ( UW                        ),
    .IW  ( IW                        ),
    .EW  ( EW                        ),
    .EHW ( EHW                       )
  ) tcdm_prefilter [0:0] (
    .clk ( clk_i )
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (48)
  ) X_source_req (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (48)
  ) Y_source_req (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (32)
  ) source_req (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (BW)
  ) input_data_demux (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (BW)
  ) output_data_demux[2:0] (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (Z_BW_ALIGNED)
  ) dataZ_outcoming (
    .clk(clk_i)
  ); 

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (8)
  ) elem_num (
    .clk(clk_i)
  );

  genvar i,j;

  assign X_buf_d = output_data_demux[1].valid ? output_data_demux[1].data : X_buf_q;
  assign output_data_demux[1].ready = 1;

  assign dataX_o.data = (X_buf_q >> (elem_cnt_q << X_ITEM_SIZE_LOG)) & {X_ITEM_SIZE{1'b1}};
  assign dataX_o.valid                  = dataY_o.valid;
  assign dataX_o.strb                   = '1;

  assign output_data_demux[2].ready          = dataY_o.ready;
  assign dataY_o.data = output_data_demux[2].data & ( {BW{1'b1}} >> (BW - (Y_mask_q << Y_ITEM_SIZE_LOG)) );
  assign dataY_o.valid                  = output_data_demux[2].valid;
  assign dataY_o.strb                   = output_data_demux[2].strb;

  assign meta_in_buf_d = output_data_demux[0].ready && output_data_demux[0].valid;
  assign output_data_demux[0].ready   = 1'b1;
  assign metadata_buf_o = metadata_buf_data_q;
  generate
    for (j = 0; j < META_CHUNK_SIZE / 32; j++) begin
      for (i = 0; i < 32; i = i + 1) begin
        assign metadata_buf_data_d[i + j * 32] = 
          (output_data_demux[0].valid)
          ? output_data_demux[0].data[i + (META_CHUNK_SIZE / 32 - 1 - j) * 32]
          : metadata_buf_data_q[i + j * 32];
      end
    end
  endgenerate

  output_stream_accumulator #(
    .INPUT_ITEM_SIZE (Z_ITEM_SIZE),
    .BW_IN        (Y_BLOCK_SIZE * Z_ITEM_SIZE),
    .BW_OUT       (Z_BW_ALIGNED)
  ) Z_data_accumulator (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .clear_i     ( clear_i                     ),

    .flags_sink_i (sink_flags),
    .stream_i    ( dataZ_i            ),

    .stream_o    (  dataZ_outcoming.source        )
  );

  // If not using a FIFO, it is possible to use a standard mux instead
  // of a mixer.
  hci_core_mux_dynamic #(
    .NB_IN_CHAN  ( 2  ),
    .NB_OUT_CHAN ( 1  ),
    .`HCI_SIZE_PARAM(in)(( `HCI_SIZE_PARAM(tcdm) ))
  ) memory_requests_mux (
    .clk_i   ( clk_i          ),
    .rst_ni  ( rst_ni         ),
    .clear_i ( clear_i        ),
    .in      ( virt_tcdm ),
    .out     ( tcdm_prefilter )
  );

  // The HCI core filter is meant to filter out r_valid strobes that the
  // cluster may generate even when the TCDM access is a write. These 
  // pollute HCI TCDM FIFOs and mixers, and it is better to remove them
  // altogether.
  hci_core_r_valid_filter #(
    .`HCI_SIZE_PARAM(tcdm_target)(( `HCI_SIZE_PARAM(tcdm) ))
  ) i_tcdm_filter (
    .clk_i         ( clk_i                ),
    .rst_ni        ( rst_ni               ),
    .clear_i       ( clear_i              ),
    .enable_i      ( 1'b1                 ),
    .tcdm_target   ( tcdm_prefilter[0].target ),
    .tcdm_initiator( tcdm                 )
  );

  // This is a demultiplexer that conveys the data of the source either towards
  // dataX_o, dataY_o, dataZ_o or meta_incoming
  hwpe_stream_demux_static #(
    .NB_OUT_STREAMS (3)
  ) data_demux(
    .clk_i        ( clk_i                         ),
    .rst_ni       ( rst_ni                        ),
    .clear_i      ( clear_i                       ),

    .sel_i        ( data_demux_sel_q                ),

    .push_i       ( input_data_demux.sink              ),
    .pop_o        ( output_data_demux.source           )
  );

  hwpe_stream_mux_static req_mux(
    .clk_i        ( clk_i                         ),
    .rst_ni       ( rst_ni                        ),
    .clear_i      ( clear_i                       ),

    .sel_i        ( req_mux_sel                ),

    .push_0_i       ( X_source_req.sink              ),
    .push_1_i       ( Y_source_req.sink              ),
    .pop_o        ( source_req.source           )
  );

  // Standard HCI core source. The DATA_WIDTH parameter is referred to
  // the HWPE-Stream, since the source also performs realignment, it will
  // expose a 32-bit larger HCI TCDM interface.
  source_fast #(
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm) ),
    .MISALIGNED_ACCESSES(MISALIGNED_ACCESSES)
  ) i_source (
    .clk_i       ( clk_i                         ),
    .rst_ni      ( rst_ni                        ),
    .test_mode_i ( test_mode_i                   ),
    .clear_i     ( clear_i                       ),
    .enable_i    ( 1'b1                          ),
    .req_start   ( req_start_source             ),
    .tcdm        ( virt_tcdm [0]                 ),
    .stream      ( input_data_demux.source           ),
    .addr_i      ( source_req.sink    ),
    .flags_o     ( source_flags  )
  );

  // Standard HCI core sink. The DATA_WIDTH parameter is referred to
  // the HWPE-Stream, since the sink also performs realignment, it will
  // expose a 32-bit larger HCI TCDM interface.
  hci_core_sink #(
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm) ),
    .MISALIGNED_ACCESSES(MISALIGNED_ACCESSES)
  ) i_sink (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .test_mode_i ( test_mode_i                 ),
    .clear_i     ( clear_i                     ),
    .enable_i    ( 1'b1                        ),
    .tcdm        ( virt_tcdm [1]               ),
    .stream      ( dataZ_outcoming.sink                    ),
    .ctrl_i      ( sink_ctrl   ),
    .flags_o     ( sink_flags )
  );

  // Scheduler for X
  X_data_scheduler #(
    .BW                (BW),     // Total interface bandwidth in bits
    .DATA_SIZE         (X_ITEM_SIZE),            // Size of each data element in bits
    .META_CHUNK_SIZE   (META_CHUNK_SIZE)         // Size of a metadata chunk in bits
  ) X_scheduler (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .clear_i     ( clear_i                     ),
    .working_i    ( ctrl_i.acc_working ),
    .done_i       ( ctrl_i.acc_done ),

    .meta_used_i (  meta_used_for_X_o          ),
    .meta_used_o (  meta_used_for_X_i          ),

    .metadata_chunk ( metadata_buf_data_q           ),

    .params_i       ( params_schedulers_i.X_sched_params),

    .request_ready_o (X_request_ready),
    .elem_num_o     (elem_num),
    .addr_o    (  X_source_req              )
  );

  Y_data_scheduler #(
    .DATA_SIZE         (Y_ITEM_SIZE),            // Size of each data element in bits
    .META_CHUNK_SIZE   (META_CHUNK_SIZE),          // Size of a metadata chunk in bits
    .Y_BLOCK_SIZE      (Y_BLOCK_SIZE)            // Number of Y columns per block (must match X_elem_size in golden model)
  ) Y_scheduler (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .clear_i     ( clear_i                     ),
    .working_i    ( ctrl_i.acc_working ),
    .done_i       ( ctrl_i.acc_done ),

    .meta_used_i (  meta_used_for_Y_o          ),
    .meta_used_o (  meta_used_for_Y_i          ),

    .metadata_chunk ( metadata_buf_data_q           ),

    .params_i       ( params_schedulers_i.Y_sched_params),

    .request_ready_o (Y_request_ready),
    .addr_o     ( Y_source_req              )
  );

  Z_data_scheduler #(
    .BW                (Z_BW_ALIGNED),
    .DATA_SIZE         (Z_ITEM_SIZE),            // Size of each data element in bits
    .Y_BLOCK_SIZE      (Y_BLOCK_SIZE)            // Number of Y columns per block
  ) Z_scheduler (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .clear_i     ( clear_i                     ),
    .working_i    ( ctrl_i.acc_working ),
    .done_i       ( ctrl_i.acc_done ),
    .sched_proceed_i   (  Zsched_proceed             ),

    .params_i    ( params_schedulers_i.Z_sched_params),

    .config_o    ( Z_sink_ctrl      )
  );

  // Store FSM: sequential process.
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : store_fsm_seq
    if(~rst_ni) begin
      sink_state_q <= SINK_INACTIVE;
      sink_ctrl_q  <= '0;
    end else if(clear_i)begin
      sink_state_q <= SINK_INACTIVE;
      sink_ctrl_q  <= '0;
    end else begin
      sink_state_q <= sink_state_d;
      sink_ctrl_q  <= sink_ctrl_d;
    end
  end

  // Store FSM: combinational next-state calculation process.
  always_comb
  begin : store_fsm_ns_comb
    sink_state_d = sink_state_q;
    if(sink_state_q == SINK_INACTIVE) begin
      if(ctrl_i.acc_working)
        sink_state_d = SINK_IDLE;
    end
    if(sink_state_q == SINK_IDLE) begin
      if(ctrl_i.acc_done)
        sink_state_d = SINK_INACTIVE;
      else if(sink_flags.ready_start & dataZ_i.valid)
          sink_state_d = STORING_Z;
    end
    else if(sink_state_q == STORING_Z) begin
      if (sink_flags.done)
        sink_state_d = SINK_IDLE;
    end
    else begin
      sink_state_d = SINK_IDLE;
    end
  end

  // Store FSM: combinational output calculation process.
  always_comb
  begin : store_fsm_out_comb
    sink_ctrl_d = sink_ctrl_q;
    sink_ctrl = '0;
    Zsched_proceed = 1'b0;
    if (sink_state_q == SINK_IDLE) begin
      if(sink_flags.ready_start & dataZ_i.valid & ~ctrl_i.acc_done)begin
        // Send request to store Z
        sink_ctrl = Z_sink_ctrl;
        sink_ctrl.req_start = 1'b1;
      end
    end
    else if (sink_state_q == STORING_Z) begin
      sink_ctrl = Z_sink_ctrl;
      if(sink_flags.done)
        Zsched_proceed = 1'b1;
    end
  end

  // Load FSM: sequential process.
  always_ff @(posedge clk_i or negedge rst_ni) 
  begin: load_fsm_seq
    if (~rst_ni) begin
      source_state_q        <= SOURCE_INACTIVE;
      metadata_buf_data_q  <= '0;
      data_demux_sel_q      <= '0;
      meta_in_buf_q         <= '0;
      elem_cnt_q            <= '0;
      X_buf_q               <= '0;
      Y_mask_q              <= '0;
      passed_from_y_q       <= 1;
    end else begin
      if (clear_i) begin
        source_state_q      <= SOURCE_INACTIVE;
        metadata_buf_data_q  <= '0;
        data_demux_sel_q      <= '0;
        meta_in_buf_q         <= '0;
        elem_cnt_q            <= '0;
        X_buf_q               <= '0;
        Y_mask_q              <= '0;
        passed_from_y_q       <= 1;
      end else begin
        source_state_q      <= source_state_d;
        metadata_buf_data_q  <= metadata_buf_data_d;
        data_demux_sel_q      <= data_demux_sel_d;
        meta_in_buf_q         <= meta_in_buf_d;
        elem_cnt_q            <= elem_cnt_d;
        X_buf_q               <= X_buf_d;
        Y_mask_q              <= Y_mask_d;
        passed_from_y_q       <= passed_from_y_d;
      end
    end
  end

  // Load FSM: combinational next-state calculation process.
  always_comb
  begin : load_fsm_ns_comb
    source_state_d = source_state_q;
    if(source_state_q == SOURCE_INACTIVE) begin
      if(ctrl_i.acc_working)
        source_state_d = SOURCE_IDLE;
    end
    if(source_state_q == SOURCE_IDLE) begin
      if(ctrl_i.acc_done)
        source_state_d = SOURCE_INACTIVE;
      else if(source_flags.ready_start)begin
          if(need_for_meta)
            source_state_d = LOADING_META;
          else if(!passed_from_y_q && load_new_Y)
            source_state_d = LOADING_Y;
          else if(passed_from_y_q && load_new_X)
            source_state_d = LOADING_X;
      end
    end
    else if(source_state_q == LOADING_META) begin
      if(meta_in_buf_q)
        source_state_d = SOURCE_IDLE;
    end
    else if(source_state_q == LOADING_X) begin
      if(output_data_demux[1].valid) begin
        if(need_for_meta)
          source_state_d = LOADING_META;
        else if(load_new_Y)
          source_state_d = LOADING_Y;
        else
          source_state_d = SOURCE_IDLE;
      end else
        source_state_d = LOADING_X;
    end
    else if(source_state_q == LOADING_Y) begin
      if(!load_new_Y || (dataY_o.ready && dataY_o.valid) && ((elem_cnt_q + 1) >= (elem_num.valid ? elem_num.data : MAX_ELEMS_PER_REQ))) begin
        if(need_for_meta)
          source_state_d = LOADING_META;
        else if(load_new_X)
          source_state_d = LOADING_X;
        else 
          source_state_d = SOURCE_IDLE;
      end
    end
    else begin
      source_state_d = SOURCE_IDLE;
    end
  end

  // Load FSM: combinational output calculation process.
  always_comb
  begin : load_fsm_out_comb
    meta_used_for_X_o = 1'b1;
    meta_used_for_Y_o = 1'b1;
    req_mux_sel = 0;
    req_start_source = 0;

    passed_from_y_d  = passed_from_y_q;
    elem_cnt_d       = elem_cnt_q;
    data_demux_sel_d = data_demux_sel_q;
    elem_num.ready   = 0;

    if(source_state_q == SOURCE_IDLE) begin
      data_demux_sel_d = '0;
      if(!passed_from_y_q)
        req_mux_sel = 1;
      if(source_flags.ready_start & ~ctrl_i.acc_done)begin
        if(need_for_meta)begin
          // Send request to load metadata
          data_demux_sel_d = 2'b00;
          req_mux_sel = 0;
          req_start_source = 1'b1;
        end else if (!passed_from_y_q && load_new_Y) begin
          // Send request to load Y
          data_demux_sel_d = 2'b10;
          req_mux_sel = 1;
          req_start_source = 1'b1;
        end else if(passed_from_y_q && load_new_X)begin
          // Send request to load X
          data_demux_sel_d = 2'b01;
          req_mux_sel = 0;
          req_start_source = 1'b1;
        end
      end
    end
    else if(source_state_q == LOADING_META) begin
      req_mux_sel = 0;
      req_start_source = 1'b1;
      data_demux_sel_d = 2'b00;
      if(meta_in_buf_q) begin
        meta_used_for_X_o = 1'b0;
        meta_used_for_Y_o = 1'b0;
        req_start_source = 1'b0;
      end
    end
    else if(source_state_q == LOADING_X) begin
      passed_from_y_d = 0;
      req_mux_sel = 0;
      req_start_source = 1'b1;
      data_demux_sel_d = 2'b01;
      if(output_data_demux[1].valid) begin
        if(need_for_meta)begin
          // Send request to load metadata
          data_demux_sel_d = 2'b00;
          req_mux_sel = 0;
        end else if(load_new_Y)begin
          // Send request to load Y
          data_demux_sel_d = 2'b10;
          req_mux_sel = 1;
        end else begin
          req_start_source = 1'b0;
          req_mux_sel = 1;
        end
      end else begin
        req_mux_sel = 0;
        req_start_source = 1'b1;
        data_demux_sel_d = 2'b01;
      end
    end
    else if(source_state_q == LOADING_Y) begin
      passed_from_y_d = 1;
      req_mux_sel = 1;
      req_start_source = 1'b1;
      data_demux_sel_d = 2'b10;
      elem_cnt_d = (dataY_o.ready && dataY_o.valid) ? (elem_cnt_q + 1) : elem_cnt_q;
      if(!load_new_Y || (dataY_o.ready && dataY_o.valid) && ((elem_cnt_q + 1) >= (elem_num.valid ? elem_num.data : MAX_ELEMS_PER_REQ)))begin
        elem_cnt_d = '0;
        elem_num.ready = 1;
        if(need_for_meta)begin
          // Send request to load metadata
          data_demux_sel_d = 2'b00;
          req_mux_sel = 0;
        end else if(load_new_X)begin
          // Send request to load X
          data_demux_sel_d = 2'b01;
          req_mux_sel = 0;
        end else begin
          req_start_source = 1'b0;
          req_mux_sel = 0;
        end
      end else begin
        req_mux_sel = 1;
        req_start_source = 1'b1;
        elem_cnt_d = (dataY_o.ready && dataY_o.valid) ? (elem_cnt_q + 1) : elem_cnt_q;
      end
    end
  end

endmodule // accelerator_streamer
