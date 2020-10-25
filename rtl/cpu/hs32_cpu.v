`include "cpu/hs32_mem.v"
`include "cpu/hs32_fetch.v"
`include "cpu/hs32_exec.v"
`include "cpu/hs32_decode.v"

// NO LATCHES ALLOWED!
module hs32_cpu (
    input clk, input reset,

    // External interface
    output  wire [31:0] addr,
    output  wire rw,
    input   wire[31:0] din,
    output  wire[31:0] dout,
    output  wire wvalid,        // Valid dout
    input   wire rvalid         // Valid din
);
    hs32_mem MEM(
        .clk(clk), .reset(reset),
        // External interface
        .addr(addr), .rw(rw), .din(din), .dout(dout),
        .wvalid(wvalid), .rvalid(rvalid),
        // Channel 0
        // I'm so done with life
    );

    hs32_fetch FETCH(

    );

    hs32_decode DECODE(

    );

    hs32_exec EXEC(
        .clk(clk)
    );
endmodule
