/**
 * Register File Module
 */

module hs32_reg (
    input clk,                       // 12 MHz Clock
    input reset_n,                   // Active Low Reset

    // Register Control
    input enable_n,                  // Active Low Enable
    input wire [3:0] rsrc,           // Source Register
    input wire [3:0] rdst,           // Destination Register
    input rw,                        // Read or Write
    input wire [31:0] din,           // Write Data
    output reg [31:0] dout,          // Read Data

    // Memory arbiter interface
    output  reg  [31:0] addr,        // Address
    input   wire [31:0] dtr,         // Data input
    output  reg  reqm,               // Valid address
    input   wire ackm,               // Valid data
);

    always @ (posedge clk) begin
        // Identify Source Register
        case (rsrc)
          4'h0: begin
              addr = ;
          end
          default: 
        endcase

        // Identify Destination Register
        case (rdst)
          4'h0: begin
              addr = ;
          end
          default: 
        endcase
    end

endmodule