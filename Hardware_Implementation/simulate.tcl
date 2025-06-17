vlib work
vlog -sv rtl/my_module.v tb/my_module_tb.v
vsim my_module_tb
add wave *
run -all

