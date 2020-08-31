FROM python:3.8.5
RUN pip3 install apio==0.5.4
RUN apio install -a

# add the packages apio installed to PATH

#for d in /root/.apio/packages/*/bin/; do
#    PATH+=":$d"
#done

ENV PATH=/root/.apio/packages/toolchain-ecp5/bin/:/root/.apio/packages/toolchain-ice40/bin/:/root/.apio/packages/toolchain-iverilog/bin/:/root/.apio/packages/toolchain-verilator/bin/:/root/.apio/packages/toolchain-yosys/bin/:/root/.apio/packages/tools-system/bin/:$PATH


