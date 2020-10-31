/**
 * Register File Module
 */

module hs32_reg (
    input clk,                  // 12 MHz Clock
    input reset,                // Reset

    // Register Control
    input we,                   // Write enable
    input wire [3:0] wadr,      // Write address
    input wire [31:0] din,      // Write Data
    input wire [3:0] radr,      // Read address
    output reg [31:0] dout      // Read Data
);
    parameter addr_width = 4;
    parameter data_width = 32;

    reg[data_width-1:0] regs[(1<<addr_width)-1:0];
    
    integer i;
    initial begin
        for(i = 0; i < (1<<addr_width); i++)
            regs[i] = 0;
`ifdef SIM
        $dumpvars(1, regs[0], regs[1]);
`endif
    end

    always @(posedge clk) begin
        if(we) begin
            regs[wadr] = din;
        end
    end

    always @(posedge clk) begin
        dout <= regs[radr];
    end
endmodule