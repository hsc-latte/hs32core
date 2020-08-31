## Directory Layout

`machine/` - Contains the Verilog equivalent of physical chips

## Docker

**Build the Docker**

```
docker build -t $(cat destination.txt) .
```

**Run in Docker**

Start a shell in the docker environent:

```
./dev_docker_run bash
```

## Local Environment Setup (without docker)

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

**!! EVERYONE, MAKE SURE YOU RUN ALL COMMANDS FROM THE ROOT DIRECTORY, rtl !!**

To compile:
```
iverilog machine/tb.v -o a.out
```

Then run:
```
vvp a.out
```

You should be able to open the `.vcd` files in something like GTKWave.

## The Toolchain
| Name | Description |
|-|-|
| `iverilog` | We'll be using Icarus Verilog mainly as a simulation tool. <br> iverilog is the Verilog compiler |
| `vvp` | vvp is the Verilog simulation runtime engine |
| `gtkwave` | Tool to visualize waveforms (`.vcd` files) |
