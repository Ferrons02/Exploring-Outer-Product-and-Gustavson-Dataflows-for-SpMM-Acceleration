onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/clk_i
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/rst_ni
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/enable_i
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/clear_i
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/presample_i
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/ctrl_i
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/flags_o
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d0_stride
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d1_stride
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d2_stride
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d3_stride
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/gen_addr_int
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/done
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/overall_counter_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d0_counter_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d1_counter_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d2_counter_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d3_counter_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d0_addr_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d1_addr_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d2_addr_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d3_addr_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/overall_counter_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d0_counter_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d1_counter_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d2_counter_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d3_counter_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d0_addr_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d1_addr_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d2_addr_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/d3_addr_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/addr_valid_d
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/addr_valid_q
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/addr_o/clk
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/addr_o/valid
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/addr_o/ready
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/addr_o/data
add wave -noupdate /tb_accelerator_streamer/streamer_i/i_source/i_addressgen/addr_o/strb
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {468 ps}
