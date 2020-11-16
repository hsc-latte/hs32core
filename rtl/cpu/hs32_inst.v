/**************************************
 * Instruction Formatting             *
 * Created with <3 by Anthony & Kevin *
 * Nov 14, 2020                       *
 **************************************/

`ifndef HS32_INST
`define HS32_INST

`define HS32_NULLI     16'b0
`define HS32_NULLS     5'b0
`define HS32_NULLR     4'b0
`define HS32_SHIFT     instd[11:7]
`define HS32_IMM       instd[15:0]
`define HS32_REGDST    instd[23:20]
`define HS32_REGSRC    instd[19:16]
`define HS32_REGOPD    instd[15:12]

`endif