# FPGA Guide

FPGA Docs [https://www.robot-electronics.co.uk/files/iceWerx.pdf](https://www.robot-electronics.co.uk/files/iceWerx.pdf)

FPGA Website [https://www.robot-electronics.co.uk/products/fpga/icewerx.html](https://www.robot-electronics.co.uk/products/fpga/icewerx.html)

## FPGA Programmer

Just upload your binary file `.bin` onto the FPGA using these programmer or awesome one that [@TheOneKevin](https://github.com/TheOneKevin) made :D and run it.

Windows [https://www.robot-electronics.co.uk/files/iceFUNprog.zip](https://www.robot-electronics.co.uk/files/iceFUNprog.zip)

Linux [https://github.com/devantech/iceFUNprog](https://github.com/devantech/iceFUNprog)

## Examples

Example Projects [FPGA](./FPGA)

iceFUN Example Projects [https://github.com/devantech/iceFUN](https://github.com/devantech/iceFUN)

## Setup

### Linux

1. Run [FPGA Shell Script](/tools/FPGA/README.md)

2. Synthesize Verilog files with `yosys`

3. Route with `nextpnr`

3. Convert to binary stream using `IcePack`

4. Upload binary stream `.bin` file using `iceFUNprog` or [@TheOneKevin](https://github.com/TheOneKevin)'s programmer.

### Windows

1. Get [iCEcube2](http://www.latticesemi.com/iCEcube2) or any other software that can generate a binary stream `.bin` file. Also iCEcube2 require a free license and you'll need a MAC address to get a license.

2. Get [iceFUNprog](https://www.robot-electronics.co.uk/files/iceFUNprog.zip) or [@TheOneKevin](https://github.com/TheOneKevin)'s programmer.

3. Upload binary file to FPGA.