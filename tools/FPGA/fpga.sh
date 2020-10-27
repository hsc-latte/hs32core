#!/bin/sh

# HSC iceWerx iCE40-HX8K FPGA Ubuntu/Debian Development Environment
# https://github.com/HomebrewSiliconClub/Processor
# Created with <3 by Anthony Kung <hi@anth.dev>
# Using resources available for IceStorm http://www.clifford.at/icestorm/

# Run this with sudo privilege

# Update repositories
sudo apt-get update

# Install dependencies
sudo apt-get install build-essential clang bison flex libreadline-dev \
                     gawk tcl-dev libffi-dev git mercurial graphviz   \
                     xdot pkg-config python python3 libftdi-dev \
                     qt5-default python3-dev libboost-all-dev cmake libeigen3-dev

# Create directory
mkdir hscice40dev

# Move to directory
cd hscice40dev

# Install IceStorm
git clone https://github.com/YosysHQ/icestorm.git icestorm
cd icestorm
make -j$(nproc)
sudo make install
cd ..

# Install nextpnr
git clone https://github.com/YosysHQ/nextpnr nextpnr
cd nextpnr
cmake -DARCH=ice40 -DCMAKE_INSTALL_PREFIX=/usr/local .
make -j$(nproc)
sudo make install
cd ..

# Install yosys
git clone https://github.com/YosysHQ/yosys.git yosys
cd yosys
make -j$(nproc)
sudo make install
cd ..

# Installation Complete
echo "HSC iceWerx iCE40-HX8K Development Environment Set Up Completed"