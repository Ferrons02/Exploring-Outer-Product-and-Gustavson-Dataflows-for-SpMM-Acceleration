# This script was generated automatically by bender.
set ROOT "/home/sem25f34/PROGETTONE/DATAMOVER"

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/clk_rst_gen.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/sim_timeout.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/stream_watchdog.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/signal_highlighter.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/rand_id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/rand_stream_mst.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/rand_synch_holdable_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/rand_verif_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/rand_synch_driver.sv" \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/src/rand_stream_slv.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/common_verification-d33f9e1d33e4db52/test/tb_clk_rst_gen.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/rtl/tc_sram.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/rtl/tc_sram_impl.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/rtl/tc_clk.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/cluster_pwr_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/generic_memory.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/generic_rom.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/pad_functional.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/pulp_buffer.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/pulp_pwr_cells.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/tc_pwr.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/test/tb_tc_sram.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/pulp_clock_gating_async.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/cluster_clk_cells.sv" \
    "$ROOT/.bender/git/checkouts/tech_cells_generic-712461a608e7f5e9/src/deprecated/pulp_clk_cells.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/include" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/binary_to_gray.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/include" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cb_filter_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cc_onehot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_reset_ctrlr_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cf_math_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/clk_int_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/credit_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/delta_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/ecc_pkg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/edge_propagator_tx.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/exp_backoff.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/fifo_v3.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/gray_to_binary.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/isochronous_4phase_handshake.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/isochronous_spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/lfsr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/lfsr_16bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/lfsr_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/lossy_valid_to_stream.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/mv_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/onehot_to_bin.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/plru_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/passthrough_stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/popcount.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/rr_arb_tree.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/rstgen_bypass.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/serial_deglitch.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/shift_reg.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/shift_reg_gated.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/spill_register_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_demux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_fork.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_intf.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_join_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_mux.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_throttle.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/sub_per_hash.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/unread.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/read.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/addr_decode_dync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_4phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/clk_int_div_static.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/addr_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/addr_decode_napot.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/multiaddr_decode.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/include" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cb_filter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_fifo_2phase.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/clk_mux_glitch_free.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/ecc_decode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/ecc_encode.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/edge_detect.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/lzc.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/max_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/rstgen.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/spill_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_delay.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_fork_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_join.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_reset_ctrlr.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_fifo_gray.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/fall_through_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/id_queue.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_to_mem.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_arbiter_flushable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_fifo_optimal_wrap.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_register.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_xbar.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_fifo_gray_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/cdc_2phase_clearable.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/mem_to_banks_detailed.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_arbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/stream_omega_net.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/mem_to_banks.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/include" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/sram.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/include" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/addr_decode_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/cb_filter_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/cdc_2phase_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/cdc_2phase_clearable_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/cdc_fifo_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/cdc_fifo_clearable_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/fifo_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/graycode_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/id_queue_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/passthrough_stream_fifo_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/popcount_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/rr_arb_tree_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/stream_test.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/stream_register_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/stream_to_mem_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/sub_per_hash_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/isochronous_crossing_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/stream_omega_net_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/stream_xbar_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/clk_int_div_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/clk_int_div_static_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/clk_mux_glitch_free_tb.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/test/lossy_valid_to_stream_tb.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/include" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/clock_divider_counter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/clk_div.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/find_first_one.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/generic_LFSR_8bit.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/generic_fifo.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/prioarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/pulp_sync.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/pulp_sync_wedge.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/rrarbiter.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/clock_divider.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/fifo_v2.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/deprecated/fifo_v1.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/edge_propagator_ack.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/edge_propagator.sv" \
    "$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/src/edge_propagator_rx.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco" \
    "+incdir+$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco" \
    "+incdir+$ROOT/.bender/git/checkouts/common_cells-6a333249e301ab43/include" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/tcdm_interconnect/tcdm_interconnect_pkg.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/tcdm_interconnect/addr_dec_resp_mux.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/tcdm_interconnect/amo_shim.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/variable_latency_interconnect/addr_decoder.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/tcdm_interconnect/xbar.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/variable_latency_interconnect/simplex_xbar.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/tcdm_interconnect/clos_net.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/tcdm_interconnect/bfly_net.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/variable_latency_interconnect/full_duplex_xbar.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/tcdm_interconnect/tcdm_interconnect.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/variable_latency_interconnect/variable_latency_bfly_net.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/variable_latency_interconnect/variable_latency_interconnect.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/FanInPrimitive_Req.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/ArbitrationTree.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/MUX2_REQ.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/AddressDecoder_Resp.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/TestAndSet.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/RequestBlock2CH.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/RequestBlock1CH.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/FanInPrimitive_Resp.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/ResponseTree.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/ResponseBlock.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/AddressDecoder_Req.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/XBAR_TCDM.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/XBAR_TCDM_WRAPPER.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/TCDM_PIPE_REQ.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/TCDM_PIPE_RESP.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/grant_mask.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco/priority_Flag_Req.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/AddressDecoder_PE_Req.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/AddressDecoder_Resp_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/ArbitrationTree_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/FanInPrimitive_Req_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/RR_Flag_Req_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/MUX2_REQ_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/FanInPrimitive_PE_Resp.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/RequestBlock1CH_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/RequestBlock2CH_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/ResponseBlock_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/ResponseTree_PE.sv" \
    "$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco/XBAR_PE.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/hwpe_stream_package.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/hwpe_stream_interfaces.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_assign.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_buffer.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_demux_static.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_deserialize.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_fence.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_merge.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_mux_static.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_serialize.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/basic/hwpe_stream_split.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo_ctrl.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo_scm.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_addressgen.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_addressgen_v2.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_addressgen_v3.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_sink_realign.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_source_realign.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_strbgen.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_streamer_queue.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_assign.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_mux.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_mux_static.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_reorder.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_reorder_static.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo_earlystall.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo_earlystall_sidech.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo_scm_test_wrap.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo_sidech.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_fifo_load_sidech.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/fifo/hwpe_stream_fifo_passthrough.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_source.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_fifo.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_fifo_load.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/tcdm/hwpe_stream_tcdm_fifo_store.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/streamer/hwpe_stream_sink.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/verif/hwpe_stream_traffic_gen.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/verif/hwpe_stream_traffic_recv.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-stream-11876d121d6ecdf0/rtl/verif/tb_fifo.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/l2_tcdm_demux.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/lint_2_apb.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/lint_2_axi.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/axi_2_lint/axi64_2_lint32.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/axi_2_lint/axi_read_ctrl.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/axi_2_lint/axi_write_ctrl.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/axi_2_lint/lint64_to_32.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/AddressDecoder_Req_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/AddressDecoder_Resp_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/ArbitrationTree_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/FanInPrimitive_Req_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/FanInPrimitive_Resp_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/MUX2_REQ_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/RequestBlock_L2_1CH.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/RequestBlock_L2_2CH.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/ResponseBlock_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/ResponseTree_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/RR_Flag_Req_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_L2/XBAR_L2.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/AddressDecoder_Req_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/AddressDecoder_Resp_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/ArbitrationTree_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/FanInPrimitive_Req_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/FanInPrimitive_Resp_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/MUX2_REQ_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/RequestBlock1CH_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/RequestBlock2CH_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/ResponseBlock_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/ResponseTree_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/RR_Flag_Req_BRIDGE.sv" \
    "$ROOT/.bender/git/checkouts/l2_tcdm_hybrid_interco-e3a492f6795b8e6b/RTL/XBAR_BRIDGE/XBAR_BRIDGE.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/low_latency_interco" \
    "+incdir+$ROOT/.bender/git/checkouts/cluster_interconnect-a17539e30e6dc0ae/rtl/peripheral_interco" \
    "+incdir+$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/common" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/common/hci_package.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/common/hci_interfaces.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_assign.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_fifo.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_mux_dynamic.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_mux_static.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_mux_ooo.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_r_valid_filter.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_r_id_filter.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_source.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_split.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/interco/hci_log_interconnect.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/interco/hci_log_interconnect_l2.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/interco/hci_new_log_interconnect.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/interco/hci_arbiter.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/interco/hci_router_reorder.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/core/hci_core_sink.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/interco/hci_router.sv" \
    "$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/hci_interconnect.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_interfaces.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_package.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_regfile_latch.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_partial_mult.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_seq_mult.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_uloop.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_regfile_latch_test_wrap.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_regfile.sv" \
    "$ROOT/.bender/git/checkouts/hwpe-ctrl-6391b99ee5c90b6c/rtl/hwpe_ctrl_slave.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/common" \
    "$ROOT/rtl/datamover_engine.sv" \
    "$ROOT/rtl/datamover_package.sv" \
    "$ROOT/rtl/datamover_streamer.sv" \
    "$ROOT/rtl/datamover_top.sv" \
}]} {return 1}

if {[catch { vlog -incr -sv \
    -svinputport=compat -timescale 1ns/1ps \
    +define+TARGET_RTL \
    +define+TARGET_SIMULATION \
    +define+TARGET_TEST \
    +define+TARGET_VSIM \
    +define+STIMULI_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/initial_memory.txt" \
    +define+GOLDEN_PATH="/home/sem25f34/PROGETTONE/DATAMOVER/verif/python/generated/updated_memory.txt" \
    +define+STIM_READ_BASE_ADDR=0 \
    +define+STIM_READ_D0_STRIDE=4 \
    +define+STIM_READ_D0_LENGTH=4 \
    +define+STIM_READ_D1_STRIDE=16 \
    +define+STIM_READ_D1_LENGTH=4 \
    +define+STIM_READ_TOT_LENGTH=16 \
    +define+STIM_WRITE_BASE_ADDR=128 \
    +define+STIM_WRITE_D0_STRIDE=16 \
    +define+STIM_WRITE_D0_LENGTH=4 \
    +define+STIM_WRITE_D1_STRIDE=64 \
    +define+STIM_WRITE_D1_LENGTH=4 \
    +define+STIM_WRITE_TOT_LENGTH=16 \
    "+incdir+$ROOT/.bender/git/checkouts/hci-9143d5de7363cf81/rtl/common" \
    "$ROOT/rtl/datamover_top_wrap.sv" \
    "$ROOT/verif/tb/tb_package.sv" \
    "$ROOT/verif/tb/tb_dummy_memory.sv" \
    "$ROOT/verif/tb/tb_datamover_top.sv" \
}]} {return 1}

