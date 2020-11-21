/**
 * Register File Module
 */

module hs32_reg (
    input clk,                  // 12 MHz Clock
    input reset,                // Reset

    // Register Control
    input we,                   // Write enable
    input wire [3:0]    wadr,   // Write address
    input wire [31:0]   din,    // Write data
    input wire [3:0]    radr1,  // Read address 1
    output reg [31:0]   dout1,  // Read data 1
    input wire [3:0]    radr2,  // Read address 2
    output reg [31:0]   dout2   // Read data 2
);
    parameter addr_width = 4;
    parameter data_width = 32;

    reg[data_width-1:0] regs[15:0];
    integer i;
    initial begin
        for(i = 0; i < (1<<addr_width); i++)
            regs[i] = 0;
`ifdef SIM
        $dumpvars(1, regs[0], regs[1]);
`endif
    end
    always @(negedge clk) if(we) begin
        regs[wadr] <= din;
    end

    always @(negedge clk) if(!we) begin
        dout1 <= regs[radr1];
        dout2 <= regs[radr2];
    end
endmodule
