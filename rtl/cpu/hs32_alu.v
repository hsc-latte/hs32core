/**
 * ALU Module
 */

module hs32_alu (
    // ALU Operators
    input wire [2:0] aluop,          // ALU Operation
    input wire [15:0] imm16,         // Immidiate 16 bits
    input wire [15:0] imm5,          // Immidiate 5 bits
    input wire [15:0] imm24,         // Immidiate 24 bits
    input wire [3:0] rm,
    input wire [3:0] rn,
    output reg [3:0] rd,

    // Register File
    input enable_n,                  // Active Low Enable
    input wire [3:0] rsrc,           // Source Register
    input wire [3:0] rdst,           // Destination Register
    input rw,                        // Read or Write
    input wire [31:0] din,           // Write Data
    output reg [31:0] dout,          // Read Data
);



endmodule