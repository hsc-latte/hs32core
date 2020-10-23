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

`ifndef tb
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
`endif
