/**



*/
module hs32_decode (
    input clk, input reset,

    // Fetch
    input   wire [31:0] instd,  // Next instruction
    output  reg  reqd,          // Valid input
    input   wire ackd,          // Valid output

    // Execute
    output  reg  [2:0]  aluop,  // ALU Operation
    output  reg  [15:0] imm16,  // Immidiate
    output  reg  [3:0]  regsrc, // Register Source
    output  reg  [3:0]  regdst, // Register Destination
    output  reg  [15:0] ctlsig  // Control signals
);

endmodule
