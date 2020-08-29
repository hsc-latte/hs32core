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

module SN74F138(
    input A, input B, input C,
    input G2A, input G2B, input G1,
    output [7:0] Y
);
    parameter TPLH = 8;
    reg[7:0] out;
    always @(*) begin
        case({A, B, C})
            3'b000: out <= 8'b1111_1110;
            3'b001: out <= 8'b1111_1101;
            3'b010: out <= 8'b1111_1011;
            3'b011: out <= 8'b1111_0111;
            3'b100: out <= 8'b1110_1111;
            3'b101: out <= 8'b1101_1111;
            3'b110: out <= 8'b1011_1111;
            3'b111: out <= 8'b0111_1111;
        endcase
    end
    // TPLH = 8ns for G1 to Y
    assign #TPLH Y = G2A || G2B || !G1 ? 8'b1111_1111 : out;
endmodule

module SN74F138_tb();
    wire [7:0] out;
    reg A, B, C, G2A, G2B, G1;

    initial begin
        {A, B, C} = 0;
        {G2A, G2B, G1} = 0;

        $dumpfile("SN74F138.vcd");
        $dumpvars(0, u1);

        #25
        {G2A, G2B, G1} = 1;

        #25
        {A, B, C} = 5;

        #25
        {A, B, C} = 3;

        #25
        G2A = 1;

        $finish;
    end

    SN74F138 u1(A, B, C, G2A, G2B, G1, out);
endmodule