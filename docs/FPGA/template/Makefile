# HSC iceWerx iCE40-HX8K FPGA Ubuntu/Debian Example Makefile
# https://github.com/HomebrewSiliconClub/Processor
# Created with <3 by Anthony Kung <hi@anth.dev>

# Configuration
EXEC = hsc
TYPE = hx8k
PKG = cb132
PINS = hsc.pcf
VERILOG = hsc.v
MODULE = hsc

# Set commands
.PHONY: hsc clean prog

# Main executable
hsc:
	# Synthesize Verilog file with Yosys
	yosys -p "synth_ice40 -top $(MODULE) -json $(EXEC).json" $(VERILOG)
	# Map PINs with nextpnr
	nextpnr-ice40 -r --$(TYPE) --json $(EXEC).json --package $(PKG) --asc $(EXEC).asc --opt-timing --pcf $(PINS)
	# Convert to .bin file using IcePack
	icepack $(EXEC).asc $(EXEC).bin

# Program FPGA with iceFUNprog
prog:
	iceFUNprog $(EXEC).bin

# Clean up project
clean:
	rm *.asc *.bin *blif