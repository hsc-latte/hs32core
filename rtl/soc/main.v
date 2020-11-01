`include "cpu/hs32_cpu.v"
`include "soc/bram.v"

module main (
    input   wire CLK,
    input   wire RX,
    output  wire TX,
    output  wire LEDR_N,
    output  wire LEDG_N
);
    wire[31:0] addr, dread, dwrite;
    wire rw, valid, done;
    hs32_cpu cpu(
        .clk(CLK), .reset(0),
        // External interface
        .addr(addr), .rw(rw),
        .din(dread), .dout(dwrite),
        .valid(valid), .done(done)
    );
    soc_bram bram(
        .clk(CLK),
        .addr(addr), .rw(rw),
        .dread(dread), .dwrite(dwrite),
        .valid(valid), .done(done)
    );
endmodule