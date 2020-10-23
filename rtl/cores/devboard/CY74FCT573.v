module CY74FCT573(
    input OE,
    input LE,
    input [7:0] D,
    output[7:0] O
);
    parameter TPLH = 9;
    reg[7:0] out;
    always @(LE) begin
        #TPLH
        out <= D;
    end
    assign #TPLH O = OE ? 8'bz : out; // TPLH = 8.5ns for LE to O
endmodule

`ifndef tb
module CY74FCT573_tb();
    reg [7:0] inp;
    wire [7:0] out;
    reg le, oe;

    initial begin
        le = 0;
        oe = 1;
        inp = 0;

        $dumpfile("CY74FCT573.vcd");
        $dumpvars(0, u1);

        #25
        le = 1;
        inp = 8'b11110000;

        #25
        le = 0;
        inp = 8'b10100101;

        #25
        oe = 0;

        #25
        $finish;
    end

    CY74FCT573 u1(oe, le, inp, out);
endmodule
`endif
