/**



*/

module hs32_exec (
    input clk, input reset,

    // Fetch
    output  reg [31:0] newpc,   // New program
    output  reg flush,          // Flush

    // Decode
    output  reg  reqd,          // Valid input
    input   wire acke,          // Valid output
    input   wire [2:0]  aluop,  // ALU Operation
    input   wire [15:0] imm16,  // Immidiate
    input   wire [3:0]  regsrc, // Register Source
    input   wire [3:0]  regdst, // Register Destination
    input   wire [15:0] ctlsig, // Control signals

    // Interrupts
    input   wire intrq,         // Interrupt signal
    input   wire [31:0] addi    // Interrupt address
);

endmodule
