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

  // We "sacrifice" 1 word of memory interface bandwidth in order to support
  // realignment at a byte boundary if the access are misaligned.
  localparam Z_BW_ALIGNED = MISALIGNED_ACCESSES === 0 ? BW : BW-32;

  logic[1:0] data_demux_sel;
  logic[META_CHUNK_SIZE-1:0] metadata_buf_d, metadata_buf_q;
  params_schedulers_t params_schedulers_d, params_schedulers_q;
  assign metadata_buf_o = metadata_buf_q;

  // Source and sink flag and control signals
  hci_streamer_ctrl_t source_ctrl_d, source_ctrl_q;
  hci_streamer_ctrl_t sink_ctrl_d, sink_ctrl_q;
  hci_streamer_flags_t source_flags_d, source_flags_q;
  hci_streamer_flags_t sink_flags_d, sink_flags_q;

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
  logic Xsched_proceed, Ysched_proceed;
  logic load_new_X, load_new_Y;
  assign load_new_X = dataX_o.ready & (!meta_used_for_X_i);
  assign load_new_Y = dataY_o.ready & (!meta_used_for_Y_i);
  hci_streamer_ctrl_t X_source_ctrl;
  hci_streamer_ctrl_t Y_source_ctrl;

  // State for the loading FSM
  typedef enum { SOURCE_INACTIVE, SOURCE_IDLE, LOADING_META, LOADING_X, LOADING_Y} source_state;
  source_state source_state_d, source_state_q;

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
    .DATA_WIDTH (BW)
  ) meta_buf_intf (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (BW)
  ) input_demux (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (BW)
  ) output_demux[2:0] (
    .clk(clk_i)
  );

  hwpe_stream_intf_stream #(
    .DATA_WIDTH (Z_BW_ALIGNED)
  ) dataZ_outcoming (
    .clk(clk_i)
  );

  assign meta_buf_intf.valid            = output_demux[0].valid;
  assign meta_buf_intf.data             = output_demux[0].data;
  assign meta_buf_intf.strb             = output_demux[0].strb;
  assign output_demux[0].ready          = meta_buf_intf.ready;

  assign dataX_o.valid           = output_demux[1].valid;
  assign dataX_o.data            = output_demux[1].data;
  assign dataX_o.strb            = output_demux[1].strb;
  assign output_demux[1].ready          = dataX_o.ready;

  assign dataY_o.valid           = output_demux[2].valid;
  assign dataY_o.data            = output_demux[2].data;
  assign dataY_o.strb            = output_demux[2].strb;
  assign output_demux[2].ready          = dataY_o.ready;

  output_stream_accumulator #(
    .BW_IN        (Y_BLOCK_SIZE * Z_ITEM_SIZE),
    .BW_OUT       (Z_BW_ALIGNED)
  ) Z_data_accumulator (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .clear_i     ( clear_i                     ),

    .stream_i    ( dataZ_i            ),

    .stream_o    (  dataZ_outcoming        )
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
  ) demux(
    .clk_i        ( clk_i                         ),
    .rst_ni       ( rst_ni                        ),
    .clear_i      ( clear_i                       ),

    .sel_i        ( data_demux_sel                ),

    .push_i       ( input_demux.sink              ),
    .pop_o        ( output_demux.source           )
  );

  // Standard HCI core source. The DATA_WIDTH parameter is referred to
  // the HWPE-Stream, since the source also performs realignment, it will
  // expose a 32-bit larger HCI TCDM interface.
  hci_core_source #(
    .`HCI_SIZE_PARAM(tcdm) ( `HCI_SIZE_PARAM(tcdm) ),
    .MISALIGNED_ACCESSES(MISALIGNED_ACCESSES)
  ) i_source (
    .clk_i       ( clk_i                         ),
    .rst_ni      ( rst_ni                        ),
    .test_mode_i ( test_mode_i                   ),
    .clear_i     ( clear_i                       ),
    .enable_i    ( 1'b1                          ),
    .tcdm        ( virt_tcdm [0]                 ),
    .stream      ( input_demux.source           ),
    .ctrl_i      ( source_ctrl_q    ),
    .flags_o     ( source_flags_d  )
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
    .ctrl_i      ( sink_ctrl_q   ),
    .flags_o     ( sink_flags_d )
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

    .sched_proceed_i   (  Xsched_proceed             ),
    .meta_used_i (  meta_used_for_X_o          ),
    .meta_used_o (  meta_used_for_X_i          ),

    .metadata_chunk ( metadata_buf_d           ),

    .params_i       ( params_schedulers_q.X_sched_params),

    .config_o    (  X_source_ctrl              )
  );

  Y_data_scheduler #(
    .DATA_SIZE         (Y_ITEM_SIZE),            // Size of each data element in bits
    .META_CHUNK_SIZE   (META_CHUNK_SIZE),          // Size of a metadata chunk in bits
    .Y_BLOCK_SIZE      (Y_BLOCK_SIZE)            // Number of Y columns per block (must match X_elem_size in golden model)
  ) Y_scheduler (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .clear_i     ( clear_i                     ),

    .sched_proceed_i   (  Ysched_proceed             ),
    .meta_used_i (  meta_used_for_Y_o          ),
    .meta_used_o (  meta_used_for_Y_i          ),

    .metadata_chunk ( metadata_buf_d           ),

    .params_i       ( params_schedulers_q.Y_sched_params),

    .config_o     ( Y_source_ctrl              )
  );

  Z_data_scheduler #(
    .DATA_SIZE         (Z_ITEM_SIZE),            // Size of each data element in bits
    .Y_BLOCK_SIZE      (Y_BLOCK_SIZE)            // Number of Y columns per block
  ) Z_scheduler (
    .clk_i       ( clk_i                       ),
    .rst_ni      ( rst_ni                      ),
    .clear_i     ( clear_i                     ),

    .sched_proceed_i   (  Zsched_proceed             ),

    .params_i    ( params_schedulers_q.Z_sched_params),

    .config_o    ( Z_sink_ctrl      )
  );

  // Store FSM: sequential process.
  always_ff @(posedge clk_i or negedge rst_ni)
  begin : store_fsm_seq
    if(~rst_ni) begin
      sink_state_q <= SINK_INACTIVE;
      sink_flags_q <= '0;
      sink_ctrl_q  <= '0;
    end else if(clear_i)begin
      sink_state_q <= SINK_INACTIVE;
      sink_flags_q <= '0;
      sink_ctrl_q  <= '0;
    end else begin
      sink_state_q <= sink_state_d;
      sink_flags_q <= sink_flags_d;
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
      else if(sink_flags_q.ready_start & dataZ_i.valid)
          sink_state_d = STORING_Z;
    end
    else if(sink_state_q == STORING_Z) begin
      if (sink_flags_q.done)
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
    Zsched_proceed = 1'b0;
    if (sink_state_q == SINK_IDLE) begin
      if(sink_flags_q.ready_start & dataZ_i.valid & ~ctrl_i.acc_done)begin
        // Send request to store Z
        sink_ctrl_d = Z_sink_ctrl;
        sink_ctrl_d.req_start = 1'b1;
      end
    end
    else if (sink_state_q == STORING_Z) begin
      sink_ctrl_d = Z_sink_ctrl;
      if(sink_flags_q.done)
        Zsched_proceed = 1'b1;
    end
  end

  // Load FSM: sequential process.
  always_ff @(posedge clk_i or negedge rst_ni) 
  begin: load_fsm_seq
    if (~rst_ni) begin
      source_state_q        <= SOURCE_INACTIVE;
      metadata_buf_q        <= '0;
      params_schedulers_q   <= '0;
      source_flags_q        <= '0;
      source_ctrl_q         <= '0;
    end else begin
      if (clear_i) begin
        source_state_q      <= SOURCE_INACTIVE;
        metadata_buf_q      <= '0;
        params_schedulers_q   <= '0;
        source_flags_q        <= '0;
        source_ctrl_q         <= '0;
      end else begin
        source_state_q      <= source_state_d;
        metadata_buf_q      <= metadata_buf_d;
        params_schedulers_q <= params_schedulers_d;
        source_flags_q      <= source_flags_d;
        source_ctrl_q       <= source_ctrl_d;
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
      else if(source_flags_q.ready_start)begin
          if(need_for_meta)
            source_state_d = LOADING_META;
          else
          if(load_new_X)
            source_state_d = LOADING_X;
          else
          if(load_new_Y)
            source_state_d = LOADING_Y;
      end
    end
    else if(source_state_q == LOADING_META) begin
      if(source_flags_q.done)
        source_state_d = SOURCE_IDLE;
    end
    else if(source_state_q == LOADING_X) begin
      if(source_flags_q.done)
        source_state_d = SOURCE_IDLE;
    end
    else if(source_state_q == LOADING_Y) begin
      if(source_flags_q.done)
        source_state_d = SOURCE_IDLE;
    end
    else begin
      source_state_d = SOURCE_IDLE;
    end
  end

  // Load FSM: combinational output calculation process.
  always_comb
  begin : load_fsm_out_comb
    Xsched_proceed = 1'b0;
    Ysched_proceed = 1'b0;
    data_demux_sel = 2'b00;
    meta_used_for_X_o = 1'b1;
    meta_used_for_Y_o = 1'b1;
    meta_buf_intf.ready = 1'b0;
    source_ctrl_d = source_ctrl_q;

    metadata_buf_d = metadata_buf_q;
    params_schedulers_d = params_schedulers_q;

    if(source_state_q == SOURCE_INACTIVE)begin
      if(ctrl_i.acc_working)
        params_schedulers_d = params_schedulers_i;
    end
    else if(source_state_q == SOURCE_IDLE) begin
      if(source_flags_q.ready_start & ~ctrl_i.acc_done)begin
        if(need_for_meta)begin
          // Send request to load metadata
          source_ctrl_d = X_source_ctrl;
          source_ctrl_d.req_start = 1'b1;
        end else if(load_new_X)begin
          // Send request to load X
          source_ctrl_d = X_source_ctrl;
          source_ctrl_d.req_start = 1'b1;
        end else if(load_new_Y)begin
          // Send request to load Y
          source_ctrl_d = Y_source_ctrl;
          source_ctrl_d.req_start = 1'b1;
        end
      end
    end
    else if(source_state_q == LOADING_META) begin
      data_demux_sel = 2'b00;
      source_ctrl_d = X_source_ctrl;
      meta_buf_intf.ready = 1'b1;
      if (meta_buf_intf.valid)
        metadata_buf_d = meta_buf_intf.data;
      if(source_flags_q.done) begin
        source_ctrl_d = '0;
        meta_used_for_X_o = 1'b0;
        meta_used_for_Y_o = 1'b0;
        Xsched_proceed = 1'b1;
        Ysched_proceed = 1'b1;
      end
    end
    else if(source_state_q == LOADING_X) begin
      data_demux_sel = 2'b01;
      source_ctrl_d = X_source_ctrl;
      source_ctrl_d.req_start = 1'b0;
      if(source_flags_q.done)
          Xsched_proceed = 1'b1;
    end
    else if(source_state_q == LOADING_Y) begin
      data_demux_sel = 2'b10;
      source_ctrl_d = Y_source_ctrl;
      source_ctrl_d.req_start = 1'b0;
      if(source_flags_q.done)
        Ysched_proceed = 1'b1;
    end
  end

endmodule // accelerator_streamer
