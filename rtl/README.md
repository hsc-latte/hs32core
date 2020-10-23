## Table of Contents
- [Table of Contents](#table-of-contents)
- [VSCode Users](#vscode-users)
- [Building](#building)
- [Docker Setup](#docker-setup)
- [Setup without Docker](#setup-without-docker)
---
## Get iceFUNprog (console version)
Located in the tools folder, a **dotnet core** distribution for
Windows users only (for now). Linux and Mac support should be
easy if the need arises. Add the executable to your PATH.

## VSCode Users
Install the following recommended extensions (all optional):
- spmeesseman.vscode-taskexplorer
- theonekevin.icarusext
- fredericbonnet.cmake-test-adapter

Ensure you have all the tools needed under your environment PATH variable, this includes:
`yosys`, `nextpnr-ice40`, `icepack`, `iverilog`, `vvp`, `gtkwave`, `verilator`. Windows users, ensure you have WSL enabled with `cmake` and the GNU toolchain installed.

## Building

Instructions are for if you are not using vscode.

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

## Docker Setup

Build image
```
docker build -t $(cat destination.txt) .
```
Run shell
```
./dev_docker_run bash
```

## Setup without Docker

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
