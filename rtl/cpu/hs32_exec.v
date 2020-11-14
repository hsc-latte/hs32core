/**



*/

module hs32_exec (
    input clk,                  // 12 MHz Clock
    input reset,                // Active Low Reset

    // Fetch
    output  reg [31:0] newpc,   // New program
    output  reg flush,          // Flush

    // Decode
    input wire  [2:0]  aluop,   // ALU Operation
    input reg   [4:0]  shift,   // 5-bit shift
    input reg   [15:0] imm,     // Immediate value
    input wire  [3:0]  regdst,  // Register Destination Rd
    input wire  [3:0]  regsrc,  // Register Source Rm
    input wire  [3:0]  regopd,  // Register Operand Rn
    input wire  [15:0] ctlsig,  // Control signals

    // Memory arbiter interface
    output  reg  [31:0] addr,   // Address
    input   wire [31:0] dtr,    // Data input
    output  reg  reqm,          // Valid address
    input   wire ackm,          // Valid data

    // Interrupts
    input   wire intrq,         // Interrupt signal
    input   wire [31:0] addi    // Interrupt address
);

    reg[31:0] src, dst;

endmodule
