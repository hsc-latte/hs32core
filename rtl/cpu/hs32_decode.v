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
`define HS32_NULLR     4'b0
`define HS32_SHIFT     instd[11:7]
`define HS32_IMM       instd[15:0]
`define HS32_REGDST    instd[23:20]
`define HS32_REGSRC    instd[19:16]
`define HS32_REGOPD    instd[15:12]

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
    output  reg  [3:0]  regdst, // Register Destination Rd
    output  reg  [3:0]  regsrc, // Register Source Rm
    output  reg  [3:0]  regopd, // Register Operand Rn
    output  reg  [15:0] ctlsig  // Control signals
);
    always @ (posedge clk) begin
        if (ackd) begin
            casez (instd[31:28])
                `HS32_LDRI: begin
                    aluop = `HS32_ADD;
                    shift = `HS32_NULLS;
                    imm = `HS32_IMM;
                    regdst = `HS32_REGDST;
                    regsrc = `HS32_REGSRC;
                    regopd = `HS32_NULLR;
                    ctlsig = 14'b10_010_01_0000_001;
                end
                `HS32_LDR: begin
                    aluop = `HS32_ADD;
                    shift = `HS32_NULLS;
                    imm = `HS32_NULLI;
                    regdst = `HS32_REGDST;
                    regsrc = `HS32_REGSRC;
                    regopd = `HS32_NULLR;
                    ctlsig = 14'b10_010_01_0000_001;
                end
                `HS32_LDRA: begin
                    aluop = `HS32_ADD;
                    shift = `HS32_SHIFT;
                    imm = `HS32_NULLI;
                    regdst = `HS32_REGDST;
                    regsrc = `HS32_REGSRC;
                    regopd = `HS32_REGOPD;
                    ctlsig = 14'b10_011_01_0000_001;
                end
                `HS32_STRI: begin
                    aluop = `HS32_ADD;
                    shift = `HS32_NULLS;
                    imm = `HS32_NULLI;
                    regdst = `HS32_REGDST;
                    regsrc = `HS32_REGSRC;
                    regopd = `HS32_NULLR;
                    ctlsig = 14'b11_101_10_0000_001;
                end
                `HS32_STR: begin
                    aluop = `HS32_ADD;
                    shift = `HS32_NULLS;
                    imm = `HS32_NULLI;
                    regdst = `HS32_REGDST;
                    regsrc = `HS32_REGSRC;
                    regopd = `HS32_NULLR;
                    ctlsig = 14'b11_101_10_0000_001;
                end
                `HS32_STRA: begin
                    aluop = `HS32_ADD;
                    shift = `HS32_SHIFT;
                    imm = `HS32_NULLI;
                    regdst = `HS32_REGDST;
                    regsrc = `HS32_REGSRC;
                    regopd = `HS32_REGOPD;
                    ctlsig = 14'b11_101_10_0000_001;
                end
            endcase
        end
    end

endmodule
