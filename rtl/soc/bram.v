module soc_bram (
    input clk,
    input we,
    input wire [addr_width-1:0] addr,
    input wire [data_width-1:0] din,
    output reg [data_width-1:0] dout
);
    parameter addr_width = 8;
    parameter data_width = 8;

    reg[data_width-1:0] mem[(1<<addr_width)-1:0];
    
    integer i;
    initial begin
        for(i = 0; i < (1<<addr_width); i++)
            mem[i] = 0;
    end

    always @(posedge clk) begin
        if(we) begin
            mem[addr] <= din;
        end else begin
            dout <= mem[addr];
        end
    end
endmodule