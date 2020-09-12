FROM python:3.8.5
RUN pip3 install apio==0.5.4
# DO NOT install verilator with APIO, its all out of date
RUN apio install -l yosys system scons iverilog ice40 examples ecp5

# add the packages apio installed to PATH

#for d in /root/.apio/packages/*/bin/; do
#    PATH+=":$d"
#done
RUN  cp --backup=numbered -R /root/.apio/packages/*/* /usr/local
#ENV PATH=/root/.apio/packages/toolchain-ecp5/bin/:/root/.apio/packages/toolchain-ice40/bin/:/root/.apio/packages/toolchain-iverilog/bin/:/root/.apio/packages/toolchain-verilator/bin/:/root/.apio/packages/toolchain-yosys/bin/:/root/.apio/packages/tools-system/bin/:$PATH


RUN apt-get update && apt-get install -y build-essential git make autoconf g++ flex bison libfl2 libfl-dev

# Prerequisites for verilator:
#sudo apt-get install git make autoconf g++ flex bison
#sudo apt-get install libfl2  # Ubuntu only (ignore if gives error)
#sudo apt-get install libfl-dev  # Ubuntu only (ignore if gives error)

RUN git clone https://github.com/verilator/verilator
RUN cd verilator && git checkout v4.100 && unset VERILATOR_ROOT && autoconf && ./configure && make && make install

RUN apt-get install -y ctags

#
## Every time you need to build:
#unsetenv VERILATOR_ROOT  # For csh; ignore error if on bash
#unset VERILATOR_ROOT  # For bash
#cd verilator
#git pull        # Make sure git repository is up-to-date
#git tag         # See what versions exist
##git checkout master      # Use development branch (e.g. recent bug fixes)
##git checkout stable      # Use most recent stable release
##git checkout v{version}  # Switch to specified release version
#
#autoconf        # Create ./configure script
#./configure
#make
#sudo make install