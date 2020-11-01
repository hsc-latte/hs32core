module soc_bram (
    input   wire clk,
    input   wire[31:0] addr,
    output  wire[31:0] dread,
    input   wire[31:0] dwrite,
    input   wire rw,
    input   wire valid,
    output  wire done
);

endmodule