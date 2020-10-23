module SN74LVC245(
    input DIR,
    input OE,
    inout [7:0] A,
    inout [7:0] B
);
    parameter TEN = 8;
    reg [7:0] buffer;
    // ten = 8 ns from OE to A or B
    assign #(0,0,TEN) A = DIR ? 8'bz : OE ? 8'bz : buffer;
    assign #(0,0,TEN) B = DIR ? OE ? 8'bz : buffer : 8'bz;
    always @(*) begin
        #TEN
        if(DIR) buffer <= A;
        else buffer <= B;
    end
endmodule

`ifndef tb
module SN74LVC245_tb();
    reg [7:0] inp;
    reg dir, oe;
    wire[7:0] A, B;

    assign A = dir ? inp : 8'bz;
    assign B = dir ? 8'bz : inp;

    initial begin
        oe = 0;
        dir = 0;
        inp = 0;

        $dumpfile("SN74LVC245.vcd");
        $dumpvars(0, u1, inp);

        #25
        inp = 8'b11110000;

        #25
        dir = 1;
        inp = 8'b10100101;

        #25
        oe = 1;

        #25
        dir = 0;
        oe = 1;

        #25
        $finish;
    end

    SN74LVC245 u1(dir, oe, A, B);
endmodule
`endif
