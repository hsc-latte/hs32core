/**
 * Decode Cycle: Determine how to pass
 *               instruction to Execute Cycle
*/
module hs32_decode (
    input clk,                  // 12 MHz Clock
    input reset,                // Reset

    // Fetch
    input   wire [31:0] instd,  // Next instruction
    output  reg  reqd,          // Valid input
    input   wire ackd,          // Valid output

    // Execute
    output  reg  [2:0]  aluop,  // ALU Operation
    output  reg  [15:0] imm16,  // Immidiate 16 bits
    output  reg  [15:0] imm5,  // Immidiate 5 bits
    output  reg  [15:0] imm24,  // Immidiate 24 bits
    output  reg  [3:0]  regdst, // Register Destination Rd
    output  reg  [3:0]  regsrc, // Register Source Rm
    output  reg  [3:0]  regopd, // Register Operand Rn
    output  reg  [15:0] ctlsig  // Control signals
);

    always @ (posedge clk) begin
        if (ackd) begin
            case (instd[31:28])
               4'h0: begin
                   // Instruction Prefix: Imm16
                   reqd = 1;                    // Activate Execute Input
                   aluop = instd[27:24];
                   regdst = instd[23:20];
                   regsrc = instd[19:16];
                   imm16 = instd[15:0];
               end
               4'h1: begin
                   // Instruction Prefix: Shift
                   reqd = 1;                    // Activate Execute Input
                   aluop = instd[27:24];
                   regdst = instd[23:20];
                   regsrc = instd[19:16];
                   regopd = instd[15:12];
                   imm5 = instd[11:7];
                   ctlsig = instd[6:0];
               end
               4'h2: begin
                   // Instruction Prefix: Imm24
                   reqd = 1;                    // Activate Execute Input
                   ctlsig = instd[27:24];
                   imm24 = instd[23:0];
               end
               4'h3: begin
                   // Instruction Prefix: Register Type
                   reqd = 1;                    // Activate Execute Input
                   aluop = instd[27:24];
                   regdst = instd[23:20];
                   regsrc = instd[19:16];
                   regopd = instd[15:12];
                   ctlsig = instd[11:0];
               end
               4'h4: begin
                   // Instruction Prefix: Jump Type
                   reqd = 1;                    // Activate Execute Input
                   ctlsig = instd[27:24];
                   regdst = instd[23:20];
                   aluop = instd[19:16];
                   imm16 = instd[15:0];
               end
               default: begin
                   // IDK
                   reqd = 0;                    // Deactivate Execute Input
               end
            endcase
        end
    end

endmodule
