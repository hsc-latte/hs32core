`include "frontend/sram.v"
module main (
    input CLK,
    // I/O Bus
    inout IO0, inout IO1, inout IO2, inout IO3, inout IO4,
    inout IO5, inout IO6, inout IO7, inout IO8, inout IO9,
    inout IO10, inout IO11, inout IO12, inout IO13,
    inout IO14, inout IO15,
    // Control signals
    output OE_N, output WE_N, output ALE0, output ALE1, output BHE_N
);
    wire we, oe, oe_neg, ale0_neg, ale1_neg, bhe, isout;
    wire[15:0] data_in;
    wire[15:0] data_out;
    wire[15:0] io;
    assign { IO15, IO14, IO13, IO12, IO11, IO10, IO9, IO8,
             IO7, IO6, IO5, IO4, IO3, IO2, IO1, IO0 } = io[15:0];
    assign OE_N = !(oe && oe_neg);
    assign WE_N = !we;
    assign ALE0 = ale0_neg;
    assign ALE1 = ale1_neg;
    assign BHE_N = !bhe;
    assign io = isout ? data_out : 16'bz;
    assign data_in = io;

    EXT_SRAM ext_sram (
        .clk(CLK),
        // Memory requests

        // External IO interface, active >> HIGH <<
        .din(data_in), .dout(data_out),
        .we(we), .oe(oe), .oe_negedge(oe_neg),
        .ale0_negedge(ale0_neg),
        .ale1_negedge(ale1_neg),
        .bhe(bhe), .isout(isout)
    );
endmodule