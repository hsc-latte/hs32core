FROM ubuntu:latest

COPY install-packages.sh .
RUN ./install-packages.sh

ENTRYPOINT ["yosys"]
