/**
 * Decode Cycle: Determine how to pass
 *               instruction to Execute Cycle
*/

/* Include OP Codes Definitions */
`include "hs32_opcodes.v"

/* Include ALU OP Codes Definitions */
`include "hs32_aluops.v"

`define HS32_NULLI     16'b0
`define HS32_NULLS     5'b0
`define HS32_SHIFT     instd[15:11]
`define HS32_SHIFTDIR  instd[10:9]
`define HS32_BANK      instd[8:7]
`define HS32_IMM       instd[15:0]
`define HS32_RD        instd[23:20]
`define HS32_RM        instd[19:16]
`define HS32_RN        instd[15:12]

module hs32_decode (
    input clk,                  // 12 MHz Clock
    input reset,                // Reset

    // Fetch
    input   wire [31:0] instd,  // Next instruction
    output  reg  reqd,          // Valid input
    input   wire ackd,          // Valid output

    // Execute
    output  reg  [2:0]  aluop,  // ALU Operation
    output  reg  [4:0]  shift,  // 5-bit shift
    output  reg  [15:0] imm,    // Immediate value
    output  reg  [3:0]  rd,     // Register Destination Rd
    output  reg  [3:0]  rm,     // Register Source Rm
    output  reg  [3:0]  rn,     // Register Operand Rn
    output  reg  [1:0]  bank,   // Bank (bb)
    output  reg  [15:0] ctlsig  // Control signals
);

    always @ (posedge clk) begin
        if (ackd) begin
            casez (instd[31:28])
                /* LDR     Rd <- [Rm + imm] */
                `HS32_LDRI: begin
                    aluop <= `HS32_ADD;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b10_010_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* LDR     Rd <- [Rm] */
                `HS32_LDR: begin
                    aluop <= `HS32_ADD;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b10_010_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* LDR     Rd <- [Rm + sh(Rn)] */
                `HS32_LDRA: begin
                    aluop <= `HS32_ADD;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b10_011_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* STR     [Rm + imm] <- Rd */
                `HS32_STRI: begin
                    aluop <= `HS32_ADD;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b11_101_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* STR     [Rm] <- Rd */
                `HS32_STR: begin
                    aluop <= `HS32_ADD;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b11_101_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* STR     [Rm + sh(Rn)] <- Rd */
                `HS32_STRA: begin
                    aluop <= `HS32_ADD;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b11_110_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* MOV     Rd <- imm */
                `HS32_MOVI: begin
                    aluop <= `HS32_MOV;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_IMM;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b01_001_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* MOV     Rd <- sh(Rn) */
                `HS32_MOVN: begin
                    aluop <= `HS32_MOV;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b01_100_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
                /* MOV     Rd <- Rm */
                `HS32_MOVN: begin
                    aluop <= `HS32_MOV;
                    shift <= `HS32_NULLS;
                    imm <= `HS32_NULLI;
                    rd <= `HS32_RD;
                    rm <= `HS32_RM;
                    rn <= `HS32_RN;
                    ctlsig <= { 12'b01_010_0000_000, `HS32_SHIFTDIR, 1'b0 };
                end
            endcase
        end
    end
endmodule