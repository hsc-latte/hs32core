## Directory Layout

`machine/` - Contains the Verilog equivalent of physical chips

## Docker

### Build

docker build -t $(cat destination.txt) .

### Run in docker 

Start a shell in the docker environent:

./dev_docker_run bash

## Local Environment Setup (without docker)

but really you want docker...

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

To compile:
```
iverilog tb.v -o a.out
```

Then run:
```
vvp a.out
```

You should be able to open the `.vcd` files in something like GTKWave.
