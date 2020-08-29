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