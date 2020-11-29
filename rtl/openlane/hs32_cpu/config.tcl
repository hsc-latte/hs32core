set script_dir [file dirname [file normalize [info script]]]

set ::env(ROUTING_CORES) 4

set ::env(PDK) sky130A
set ::env(STD_CELL_LIBRARY) sky130_fd_sc_hd

set ::env(DESIGN_NAME) hs32_cpu

set ::env(DESIGN_IS_CORE) 0
set ::env(GLB_RT_MAXLAYER) 5

set ::env(SYNTH_STRATEGY) 1
set ::env(DIODE_INSERTION_STRATEGY) 1

set ::env(VERILOG_FILES) "\
	$script_dir/../../cpu/hs32_cpu.v"

set	::env(VERILOG_INCLUDE_DIRS) "\
	$script_dir/../../ \
	$script_dir/../../cpu"

set ::env(CLOCK_PORT) "i_clk"
set ::env(CLOCK_PERIOD) "30"

# set ::env(FP_PIN_ORDER_CFG) $script_dir/pin_order.cfg
set ::env(FP_SIZING) absolute
set ::env(FP_PDN_CORE_RING) 0
set ::env(DIE_AREA) "0 0 1010 850"
set ::env(PL_TARGET_DENSITY) 0.35
