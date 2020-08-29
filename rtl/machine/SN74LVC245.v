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