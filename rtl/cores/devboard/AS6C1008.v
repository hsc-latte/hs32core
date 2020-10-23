module AS6C1008(
    input [16:0] A,
    output [7:0] DQ,
    input CE, CE2, WE, OE
);
    parameter TWC = 55;
    parameter TWHZ = 20;
    parameter init = "";

    reg[7:0] mem[1024-1:0]; // 128K x 8
    reg[7:0] out;

    always @(*) begin
        if(!CE && CE2 && !WE) begin
            #TWC
            mem[A] = DQ;
        end
        if(!CE && CE2 && WE) begin
            #TWC
            out = mem[A];
        end
    end

    initial begin
        $readmemh(init, mem);
    end

    assign #(0, 0, TWHZ) DQ = (!CE && CE2 && !OE && WE) ? out : 8'bz;
endmodule

`ifndef tb
module AS6C1008_tb();
    reg [16:0] A;
    reg [7:0] inp;
    reg ce2, we, oe, ce;
    wire[7:0] DQ;

    assign DQ = !we ? inp : 8'bz;

    initial begin
        oe = 0;
        ce = 0;
        ce2 = 1;
        we = 1;
        A = 0;
        inp = 0;

        $dumpfile("AS6C1008.vcd");
        $dumpvars(0, u1, inp);

        #100
        A = 0;
        inp = 8'b11110000;
        we = 0;

        #100
        we = 1;

        #100
        A = 1;
        we = 0;
        inp = 8'b10100101;

        #100
        we = 1;

        #100
        oe = 1;

        #100
        $finish;
    end

    AS6C1008 u1(A, DQ, ce, ce2, we, oe);
endmodule
`endif
