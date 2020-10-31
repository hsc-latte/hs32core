/**



*/

module hs32_exec (
    input clk,                       // 12 MHz Clock
    input reset_n,                   // Active Low Reset

    // Fetch
    output  reg [31:0] newpc,   // New program
    output  reg flush,          // Flush

    // Decode
    input wire  [2:0]  aluop,  // ALU Operation
    input wire  [15:0] imm16,  // Immidiate 16 bits
    input wire  [15:0] imm5,  // Immidiate 5 bits
    input wire  [15:0] imm24,  // Immidiate 24 bits
    input wire  [3:0]  regdst, // Register Destination Rd
    input wire  [3:0]  regsrc, // Register Source Rm
    input wire  [3:0]  regopd, // Register Operand Rn
    input wire  [15:0] ctlsig  // Control signals

    // Interrupts
    input   wire intrq,         // Interrupt signal
    input   wire [31:0] addi    // Interrupt address
);

    

endmodule
