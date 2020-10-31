module hs32_reg (
    input clk,                       // 12 MHz Clock
    input reset_n,                   // Active Low Reset

    // Register Control
    input enable_n,                  // Active Low Enable
    input wire rsrc,                 // Source Register
    input wire rdst,                 // Destination Register
    input rw,                        // Read or Write
    input wire data,                 // Write Data

    // Memory arbiter interface
    output  reg  [31:0] addr,        // Address
    input   wire [31:0] dtr,         // Data input
    output  reg  reqm,               // Valid address
    input   wire ackm,               // Valid data
);

endmodule