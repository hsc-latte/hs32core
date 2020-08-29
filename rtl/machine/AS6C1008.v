// MIT License
// 
// Copyright (c) 2020 Kevin Dai
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

module AS6C1008(
    input [16:0] A,
    output [7:0] DQ,
    input CE, CE2, WE, OE
);
    parameter TWC = 55;
    parameter TWHZ = 20;

    reg[7:0] mem[0:1024-1]; // 128K x 8
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

    assign #(0, 0, TWHZ) DQ = (!CE && CE2 && !OE && WE) ? out : 8'bz;
endmodule

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