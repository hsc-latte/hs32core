# FPGA Guide

FPGA Docs [https://www.robot-electronics.co.uk/files/iceWerx.pdf](https://www.robot-electronics.co.uk/files/iceWerx.pdf)

FPGA Website [https://www.robot-electronics.co.uk/products/fpga/icewerx.html](https://www.robot-electronics.co.uk/products/fpga/icewerx.html)

## FPGA Programmer

Just upload your binary file `.bin` onto the FPGA using these programmer or awesome one that [@TheOneKevin](https://github.com/TheOneKevin) made :D and run it.

Windows [https://www.robot-electronics.co.uk/files/iceFUNprog.zip](https://www.robot-electronics.co.uk/files/iceFUNprog.zip)

Linux [https://github.com/devantech/iceFUNprog](https://github.com/devantech/iceFUNprog)

## Examples

Example Projects [https://github.com/devantech/iceFUN](https://github.com/devantech/iceFUN)

Yes their examples are a little weird, I'll make one soon.

## Setup

### Linux

1. Run this in the terminal for Ubuntu/Debian to set up environment

```bash
sudo apt-get install build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev \
                     qt5-default python3-dev libboost-all-dev cmake libeigen3-dev
mkdir hscice40dev
git clone https://github.com/YosysHQ/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
git clone https://github.com/cseed/arachne-pnr.git arachne-pnr
cd arachne-pnr
make -j$(nproc)
sudo make install
git clone https://github.com/YosysHQ/nextpnr nextpnr
cd nextpnr
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
make -j$(nproc)
sudo make install
git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make -j$(nproc)
sudo make install
```

2. Synthesize Verilog files with `yosys`

3. Route with `nextpnr`

3. Convert to binary stream using `IcePack`

4. Upload binary stream `.bin` file using `iceFUNprog` or [@TheOneKevin](https://github.com/TheOneKevin)'s programmer.

### Windows

1. Get [iCEcube2](http://www.latticesemi.com/iCEcube2) or any other software that can generate a binary stream `.bin` file. Also iCEcube2 require a free license and you'll need a MAC address to get a license.

2. Get [iceFUNprog](https://www.robot-electronics.co.uk/files/iceFUNprog.zip) or [@TheOneKevin](https://github.com/TheOneKevin)'s programmer.

3. Upload binary file to FPGA.