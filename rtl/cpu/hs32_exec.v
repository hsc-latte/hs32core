/**



*/

`include "./cpu/hs32_reg.v"

// Control signals
`define CTL_D   12:11
`define CTL_S   10:8
`define CTL_M   7:6
`define CTL_B   5:2
`define CTL_I   1
`define CTL_F   0

// FSM States
`define IDLE    0
`define TB1     1
`define TB2     2
`define TR1     3
`define TR2     4
`define TW1     5
`define TM1     6
`define TM2     7
`define TW2     8

module hs32_exec (
    input clk,                  // 12 MHz Clock
    input reset,                // Active Low Reset
    input req,                  // Request line

    // Fetch
    output  reg [31:0] newpc,   // New program
    output  reg flush,          // Flush

    // Decode
    input wire  [2:0]  aluop,   // ALU Operation
    input wire  [4:0]  shift,   // 5-bit shift
    input wire  [15:0] imm,     // Immediate value
    input wire  [3:0]  rd,      // Register Destination Rd
    input wire  [3:0]  rm,      // Register Source Rm
    input wire  [3:0]  rn,      // Register Operand Rn
    input wire  [15:0] ctlsig,  // Control signals

    // Memory arbiter interface
    output  reg  [31:0] addr,   // Address
    input   wire [31:0] dtrm,   // Data input
    output  reg  reqm,          // Valid address
    input   wire ackm,          // Valid data

    // Interrupts
    input   wire intrq,         // Interrupt signal
    input   wire [31:0] addi    // Interrupt address
);
    wire [31:0] ibus1, ibus2, obus;
    reg  [31:0] mar, dtw, dtr, pc, ivt, mcr;

    wire reg_we;
    wire [31:0] regouta, regoutb, reginp;
    wire [3:0] regadra, regadrb, regwadr;

    reg[2:0] state;

    always @(posedge clk) case(state)
        `IDLE:
        if(req) begin
            state <= `TR1;
        end
        
        `TR1:
        if(ctlsig[`CTL_S] == 3'b110 || ctlsig[`CTL_S] == 3'b111) begin
            state <= `TR2;
        end else begin
            state <= `TW1;
        end

        `TW1:
        if(ctlsig[`CTL_D] == 2'b01) begin
            state <= `IDLE;
        end
    endcase

    assign ibus1 = regouta;
    assign ibus2 =
        ctlsig[`CTL_S] == 3'b001
        || ctlsig[`CTL_S] == 3'b010
        || ctlsig[`CTL_S] == 3'b101
        ? { 16'b0, imm } : regoutb;
    assign reginp = obus;
    assign regadra =
        state == `TR1 && (ctlsig[`CTL_S] == 3'b110 || ctlsig[`CTL_S] == 3'b111)
        ? rd : rm;
    assign regadrb = rn;
    assign regwadr = rd;
    assign reg_we = (state == `TW1 && ctlsig[`CTL_D] == 2'b01);

    hs32_reg regfile (
        .clk(clk), .reset(reset),
        .we(reg_we),
        .wadr(regwadr), .din(reginp),
        .dout1(regouta), .radr1(regadra),
        .dout2(regoutb), .radr2(regadrb)
    );

endmodule
