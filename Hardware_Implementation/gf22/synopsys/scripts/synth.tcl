sh rm -rf WORK/*

set NAME accelerator_streamer

# set link_library   [list  GF22FDX_SC8T_104CPP_BASE_CSC20L_SSG_0P72V_0P00V_0P00V_0P00V_125C.db \
#                              GF22FDX_SC8T_104CPP_BASE_CSC24L_SSG_0P72V_0P00V_0P00V_0P00V_125C.db \
#                              GF22FDX_SC8T_104CPP_BASE_CSC28L_SSG_0P72V_0P00V_0P00V_0P00V_125C.db  \
#                              GF22FDX_SC8T_104CPP_BASE_CSC20SL_SSG_0P72V_0P00V_0P00V_0P00V_125C.db \
#                              GF22FDX_SC8T_104CPP_BASE_CSC24SL_SSG_0P72V_0P00V_0P00V_0P00V_125C.db \
#                              GF22FDX_SC8T_104CPP_BASE_CSC28SL_SSG_0P72V_0P00V_0P00V_0P00V_125C.db \
#                              IN22FDX_ROMI_FRG_W00128B064M08C064_104cpp_SSG_0P720V_0P720V_0P000V_0P000V_125C.db \
#                              IN22FDX_ROMI_FRG_W00128B032M08C064_104cpp_SSG_0P720V_0P720V_0P000V_0P000V_125C.db \
#                              IN22FDX_ROMI_FRG_W00256B016M08C064_104cpp_SSG_0P720V_0P720V_0P000V_0P000V_125C.db ]

source ./scripts/bender_syn.tcl

check_design >> reports/report_check_design_${NAME}.rpt

elaborate accelerator_streamer_wrap

link

report_timing -loop >> reports/report_timing_loop_${NAME}.rpt

check_design

set CLK_PERIOD {5000}

create_clock clk_i
create_clock clk_i -period ${CLK_PERIOD}
set_clock_uncertainty 100 [all_clocks]
set_dont_touch_network [all_clocks]
set RST rst_ni
remove_driving_cell $RST
set_drive 0 $RST
set_dont_touch_network $RST

set LIB GF22FDX_SC8T_104CPP_BASE_CSC28L_SSG_0P72V_0P00V_0P00V_0P00V_125C
set DRIV_CELL SC8T_BUFX4_CSC28L
set DRIV_PIN  Z
set LOAD_CELL SC8T_BUFX4_CSC28L
set LOAD_PIN  A

set_driving_cell  -no_design_rule -library ${LIB} -lib_cell ${DRIV_CELL} -pin ${DRIV_PIN} [all_inputs]
set_load [load_of ${LIB}/${LOAD_CELL}/${LOAD_PIN}] [all_outputs]

compile_ultra -no_autoungroup -timing_high_effort_script -gate_clock

report_timing -loop >> reports/report_timing_loop_post_synth_${NAME}.rpt

    report_timing       >  reports/report_timing_${NAME}.rpt
    report_area         >> reports/report_area_${NAME}.rpt
    report_qor          >> reports/report_qor_${NAME}.rpt
    check_design        >> reports/check_design_${NAME}.rpt
    report_design       >> reports/report_design_${NAME}.rpt
    report_area -hier   >  reports/report_area_hier_${NAME}.rpt
    # Write Verilog netlist.
    write -hierarchy -format verilog -output netlists/${NAME}.v

