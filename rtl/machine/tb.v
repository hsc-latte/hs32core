// I will change this later - Kevin

`include "machine/CY74FCT573.v"
`include "machine/SN74F138.v"
`include "machine/SN74LVC245.v"
`include "machine/AS6C1008.v"
`include "main.v"

`timescale 1ns/1ns

module tb();
    parameter PERIOD = 62;
    reg clk;
    always #(PERIOD/2) clk=~clk;

    wire [7:0] ad1;
    wire [7:0] ad2;
    wire [7:0] ad3;

    wire io1, io2, io3, io4, io5, io6, io7, io8, io9, io10, io11, io12, io13, io14, io15, io16;
    wire io17, io18, io19, io20;
    wire pio, oe, ale, we;

    reg [15:0] io;
    reg [3:0] st;

    wire [7:0] Y;
    wire [7:0] data_lo;
    wire [7:0] data_hi;

    initial begin
        clk = 0;
        $dumpfile("tb.vcd");
        $dumpvars(0, u0, u1, u2, u3, u4, u5, u6, u7, u8, ad1, ad2, ad3, data_hi, data_lo);

        #PERIOD
        #PERIOD
        #PERIOD
        #PERIOD
        #PERIOD
        #PERIOD
        #PERIOD
        #PERIOD
        $finish;
    end

    CPU u0(clk,,, io1, io2, io3, io4, io5, io6, io7, io8, io9, io10, io11, io12, io13, io14, io15, io16,
           io17, io18, io19, io20, pio, oe, ale, we,,);
    CY74FCT573  #(0)    u1(1'b0, ale, { io1, io2, io3, io4, io5, io6, io7, io8 }, ad1);
    CY74FCT573  #(0)    u2(1'b0, ale, { io9, io10, io11, io12, io13, io14, io15, io16 }, ad2);
    CY74FCT573  #(0)    u3(1'b0, ale, { io17, io18, io19, io20, 4'b0 }, ad3);
    SN74F138    #(0)    u4(io18, io19, io20, 1'b0, 1'b0, pio, Y);
    SN74LVC245  #(0)    u5(we, oe, data_lo, { io1, io2, io3, io4, io5, io6, io7, io8 });
    SN74LVC245  #(0)    u6(we, oe, data_hi, { io9, io10, io11, io12, io13, io14, io15, io16 });
    AS6C1008    #(0,0)  u7({ 9'b0, ad1 }, data_lo, Y[0:0], 1'b1, we, 1'b0);
    AS6C1008    #(0,0)  u8({ 9'b0, ad1 }, data_hi, Y[0:0], 1'b1, we, 1'b0);
endmodule