/**
 * HSC FPGA Verilog Template
 * https://github.com/HomebrewSiliconClub/Processor
 * Created with <3 by Anthony Kung <hi@anth.dev>
 */

module hsc (
    // FPGA
    input wire clk,         // 12 MHz Clock
    output reg ledr,        // LED Red
    output reg ledg,        // LED Green

    // FPGA UART
    output reg icetx,       // UART Tx
    input wire icerx,       // UART Rx

    // FPGA SPI Flash
    output reg icecs,       // Chip Select
    output reg icesck,      // Serial Clock
    input wire icesdi,      // Data input
    output reg icesdo,      // Data output

    // Buttons
    input wire reset_n,     // FPGA Reset
    // input wire mcu_n,    // MCU Reset
    input wire sw3,         // GPIO SW 3

    // GPIO - Out
    output reg gpio0,
    output reg gpio1,
    output reg gpio2,
    output reg gpio3,
    output reg gpio4,
    output reg gpio5,
    output reg gpio6,
    output reg gpio7,
    output reg gpio8,

    // GPIO - In
    input wire gpio0,
    input wire gpio1,
    input wire gpio2,
    input wire gpio3,
    input wire gpio4,
    input wire gpio5,
    input wire gpio6,
    input wire gpio7,
    input wire gpio8,

    // IO Bus Outputs - 16 bits
    output reg io0,
    output reg io1,
    output reg io2,
    output reg io3,
    output reg io4,
    output reg io5,
    output reg io6,
    output reg io7,
    output reg io8,
    output reg io9,
    output reg io10,
    output reg io11,
    output reg io12,
    output reg io13,
    output reg io14,
    output reg io15,

    // IO Bus Inputs - 16 bits
    input wire io0,
    input wire io1,
    input wire io2,
    input wire io3,
    input wire io4,
    input wire io5,
    input wire io6,
    input wire io7,
    input wire io8,
    input wire io9,
    input wire io10,
    input wire io11,
    input wire io12,
    input wire io13,
    input wire io14,
    input wire io15,

    // UART
    output reg tx,
    input wire rx,

    // SPI
    output reg sck,         // Serial Clock
    input wire miso,        // Data input
    output reg mosi,        // Data output

    // I2C / TWI
    output reg scl,         // Clock Line
    output reg sda,         // Data Line

    // Memory
    output reg ale0,        // Address Enable Latch 0
    output reg ale1,        // Address Enable Latch 1
    output reg oe0,         // output Enable Byte 0
    output reg oe1,         // output Enable Byte 1
    output reg oe2,         // output Enable Byte 2
    output reg oe3,         // output Enable Byte 3
);

    reg [24:0] second = 24'b0;
    reg [9:0] gpio = 10'd1;

    assign ledg = second[24] ^ 1'b1;
    assign ledr = ~ledg;
    assign {gpio0, gpio1, gpio2, gpio3, gpio4, gpio5, gpio6, gpio7, gpio8} = gpio[9:1] ^ 9'h000;

    always @(posedge clk) begin
        second <= second + 1;
    end

    always @(posedge second[24]) begin
        if (gpio == 10'd0) begin
            gpio = 10'd1;
        end
        gpio <= gpio << 1;
    end

endmodule