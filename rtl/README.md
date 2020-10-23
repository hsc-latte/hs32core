## Building
**!! MAKE SURE YOU RUN ALL COMMANDS FROM THE ROOT DIRECTORY, `rtl` !!**

Synthesis
```
yosys -p "synth_ice40 -json build/hardware.json" main.v
```
PnR
```
nextpnr-ice40 --hx8k --package cb132 --json build/hardware.json --pcf pins.pcf --asc build/hardware.asc
```
Packing
```
icepack build/hardware.asc build/hardware.bin
```
Finally, upload `hardware.bin` to the iceWerx board.

To simulate, compile:
```
iverilog machine/tb.v -o a.out
```

Then run:
```
vvp a.out
```

You should be able to open the `.vcd` files in something like GTKWave.


## Docker

Build image
```
docker build -t $(cat destination.txt) .
```
Run shell
```
./dev_docker_run bash
```

## Local Environment Setup (without Docker)

Install the APIO toolchain:

```
pip3 install apio
```

Install the drivers:

```
apio install -a
```

You should add yosys, iverilog and gtkwave to your path. The binaries are located in subdirectories under:
```
~/.apio/packages
```
(or equivalent Windows directories).
