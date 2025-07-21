# This script was generated automatically by bender.
set ROOT "/home/sem25f34/PROGETTONE/AcceleratorDefinitive"
set search_path_initial $search_path

set search_path $search_path_initial

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/tech_cells_generic-f7083ffa12459bc3/src/rtl/tc_sram.sv" \
        "$ROOT/.bender/git/checkouts/tech_cells_generic-f7083ffa12459bc3/src/rtl/tc_sram_impl.sv" \
    ]
]} {return 1}

set search_path $search_path_initial

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/tech_cells_generic-f7083ffa12459bc3/src/rtl/tc_clk.sv" \
    ]
]} {return 1}

set search_path $search_path_initial

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/tech_cells_generic-f7083ffa12459bc3/src/deprecated/pulp_clock_gating_async.sv" \
        "$ROOT/.bender/git/checkouts/tech_cells_generic-f7083ffa12459bc3/src/deprecated/cluster_clk_cells.sv" \
        "$ROOT/.bender/git/checkouts/tech_cells_generic-f7083ffa12459bc3/src/deprecated/pulp_clk_cells.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/include"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/binary_to_gray.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/include"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cb_filter_pkg.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cc_onehot.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_reset_ctrlr_pkg.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cf_math_pkg.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/clk_int_div.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/credit_counter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/delta_counter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/ecc_pkg.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/edge_propagator_tx.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/exp_backoff.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/fifo_v3.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/gray_to_binary.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/isochronous_4phase_handshake.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/isochronous_spill_register.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/lfsr.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/lfsr_16bit.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/lfsr_8bit.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/lossy_valid_to_stream.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/mv_filter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/onehot_to_bin.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/plru_tree.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/passthrough_stream_fifo.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/popcount.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/rr_arb_tree.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/rstgen_bypass.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/serial_deglitch.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/shift_reg.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/shift_reg_gated.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/spill_register_flushable.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_demux.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_filter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_fork.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_intf.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_join_dynamic.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_mux.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_throttle.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/sub_per_hash.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/sync.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/sync_wedge.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/unread.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/read.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/addr_decode_dync.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_2phase.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_4phase.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/clk_int_div_static.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/addr_decode.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/addr_decode_napot.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/multiaddr_decode.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/include"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cb_filter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_fifo_2phase.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/clk_mux_glitch_free.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/counter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/ecc_decode.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/ecc_encode.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/edge_detect.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/lzc.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/max_counter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/rstgen.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/spill_register.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_delay.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_fifo.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_fork_dynamic.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_join.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_reset_ctrlr.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_fifo_gray.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/fall_through_register.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/id_queue.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_to_mem.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_arbiter_flushable.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_fifo_optimal_wrap.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_register.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_xbar.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_fifo_gray_clearable.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/cdc_2phase_clearable.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/mem_to_banks_detailed.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_arbiter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/stream_omega_net.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/mem_to_banks.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/include"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/clock_divider_counter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/clk_div.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/find_first_one.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/generic_LFSR_8bit.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/generic_fifo.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/prioarbiter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/pulp_sync.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/pulp_sync_wedge.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/rrarbiter.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/clock_divider.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/fifo_v2.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/deprecated/fifo_v1.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/edge_propagator_ack.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/edge_propagator.sv" \
        "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/src/edge_propagator_rx.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco"
lappend search_path "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco"
lappend search_path "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/include"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/tcdm_interconnect/tcdm_interconnect_pkg.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/tcdm_interconnect/addr_dec_resp_mux.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/tcdm_interconnect/amo_shim.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/variable_latency_interconnect/addr_decoder.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/tcdm_interconnect/xbar.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/variable_latency_interconnect/simplex_xbar.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/tcdm_interconnect/clos_net.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/tcdm_interconnect/bfly_net.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/variable_latency_interconnect/full_duplex_xbar.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/tcdm_interconnect/tcdm_interconnect.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/variable_latency_interconnect/variable_latency_bfly_net.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/variable_latency_interconnect/variable_latency_interconnect.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/FanInPrimitive_Req.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/ArbitrationTree.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/MUX2_REQ.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/AddressDecoder_Resp.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/TestAndSet.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/RequestBlock2CH.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/RequestBlock1CH.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/FanInPrimitive_Resp.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/ResponseTree.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/ResponseBlock.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/AddressDecoder_Req.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/XBAR_TCDM.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/XBAR_TCDM_WRAPPER.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/TCDM_PIPE_REQ.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/TCDM_PIPE_RESP.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/grant_mask.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco/priority_Flag_Req.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/AddressDecoder_PE_Req.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/AddressDecoder_Resp_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/ArbitrationTree_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/FanInPrimitive_Req_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/RR_Flag_Req_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/MUX2_REQ_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/FanInPrimitive_PE_Resp.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/RequestBlock1CH_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/RequestBlock2CH_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/ResponseBlock_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/ResponseTree_PE.sv" \
        "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco/XBAR_PE.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/hwpe_stream_package.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/hwpe_stream_interfaces.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_assign.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_buffer.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_demux_static.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_deserialize.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_fence.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_merge.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_mux_static.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_serialize.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/basic/hwpe_stream_split.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo_ctrl.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo_scm.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_addressgen.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_addressgen_v2.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_addressgen_v3.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_sink_realign.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_source_realign.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_strbgen.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_streamer_queue.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_assign.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_mux.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_mux_static.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_reorder.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_reorder_static.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo_earlystall.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo_earlystall_sidech.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo_scm_test_wrap.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo_sidech.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_fifo_load_sidech.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/fifo/hwpe_stream_fifo_passthrough.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_source.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_fifo.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_fifo_load.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/tcdm/hwpe_stream_tcdm_fifo_store.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-stream-25cfc4f4c68ef892/rtl/streamer/hwpe_stream_sink.sv" \
    ]
]} {return 1}

set search_path $search_path_initial

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/l2_tcdm_demux.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/lint_2_apb.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/lint_2_axi.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/axi_2_lint/axi64_2_lint32.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/axi_2_lint/axi_read_ctrl.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/axi_2_lint/axi_write_ctrl.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/axi_2_lint/lint64_to_32.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/AddressDecoder_Req_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/AddressDecoder_Resp_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/ArbitrationTree_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/FanInPrimitive_Req_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/FanInPrimitive_Resp_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/MUX2_REQ_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/RequestBlock_L2_1CH.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/RequestBlock_L2_2CH.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/ResponseBlock_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/ResponseTree_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/RR_Flag_Req_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_L2/XBAR_L2.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/AddressDecoder_Req_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/AddressDecoder_Resp_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/ArbitrationTree_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/FanInPrimitive_Req_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/FanInPrimitive_Resp_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/MUX2_REQ_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/RequestBlock1CH_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/RequestBlock2CH_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/ResponseBlock_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/ResponseTree_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/RR_Flag_Req_BRIDGE.sv" \
        "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-45374336ca37b6e8/RTL/XBAR_BRIDGE/XBAR_BRIDGE.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/low_latency_interco"
lappend search_path "$ROOT/.bender/git/checkouts/cluster_interconnect-122365d580cf5b74/rtl/peripheral_interco"
lappend search_path "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/common"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/common/hci_package.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/common/hci_interfaces.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_assign.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_fifo.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_mux_dynamic.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_mux_static.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_mux_ooo.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_r_valid_filter.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_r_id_filter.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_source.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_split.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/interco/hci_log_interconnect.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/interco/hci_log_interconnect_l2.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/interco/hci_new_log_interconnect.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/interco/hci_arbiter.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/interco/hci_router_reorder.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/core/hci_core_sink.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/interco/hci_router.sv" \
        "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/hci_interconnect.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_interfaces.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_package.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_regfile_latch.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_partial_mult.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_seq_mult.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_uloop.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_regfile_latch_test_wrap.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_regfile.sv" \
        "$ROOT/.bender/git/checkouts/hwpe-ctrl-f751b63138d7303d/rtl/hwpe_ctrl_slave.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
lappend search_path "$ROOT/.bender/git/checkouts/common_cells-93d0e85c89b9bf9c/include"
lappend search_path "$ROOT/.bender/git/checkouts/hci-899384a3885b42f1/rtl/common"

if {0 == [analyze -format sv \
    -define { \
        TARGET_SYNOPSYS \
        TARGET_SYNTHESIS \
    } \
    [list \
        "$ROOT/rtl/accelerator_package.sv" \
        "$ROOT/rtl/output_stream_accumulator.sv" \
        "$ROOT/rtl/source_fast.sv" \
        "$ROOT/rtl/X_data_scheduler.sv" \
        "$ROOT/rtl/Y_data_scheduler.sv" \
        "$ROOT/rtl/Z_data_scheduler.sv" \
        "$ROOT/rtl/accelerator_streamer.sv" \
        "$ROOT/rtl/accelerator_streamer_wrap.sv" \
    ]
]} {return 1}

set search_path $search_path_initial
