`include "cpu/hs32_aluops.v"

module hs32_alu (
    input  wire [31:0] a_i,
    input  wire [31:0] b_i,
    input  wire [3:0] op_i,
    output wire [31:0] r_o,
    input  wire [3:0] fl_i, // nzcv in
    output wire [3:0] fl_o  // nzcv out
);
    // Assign output
    wire carry;
    assign { carry, r_o } =
        (op_i == `HS32A_ADD) ? a_i + b_i :
        (op_i == `HS32A_SUB) ? { 1'b0, a_i } - { 1'b0, b_i } :
        { fl_i[1], b_i };
    
    // Compute output flags
    assign fl_o[3] = r_o[31] == 1 && (op_i == `HS32A_SUB);
    assign fl_o[2] = ~(|r_o);
    assign fl_o[1] = carry;
    assign fl_o[0] = { carry, r_o[31] } == 2'b01; // TODO: Calculate carry
endmodule