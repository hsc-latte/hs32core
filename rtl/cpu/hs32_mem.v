/**
 * Internal Memory Arbiter (IMA):
 * Schedules and arbitrates memory requests.
 *
 * Note: channel0 gets priority over channel1
 * When channel0 wants access, it drives req0 HIGH.
 * When channel1 wants access, it drives req1 HIGH.
 *
 * IMA will then drive the respective ack0 or ack1 high
 * when the operation is COMPLETE. The module on each channel
 * only needs to wait for the ack0/ack1 signals
 *
*/

module hs32_mem (
    input clk, input reset,

    // External interface
    output  reg [31:0] addr,    // Output address
    output  reg rw,             // Read/write signal
    input   wire[31:0] din,     // Data input from memory
    output  reg [31:0] dout,    // Data output to memory
    output  reg  wvalid,        // Valid dout
    input   wire done,          // Operation completed (valid din too)

    // Channel 0
    input   reg [31:0] addr0,   // Address request from
    input   wire rw0,           // Read/write signal from
    output  reg [31:0] dtr0,    // Data to read
    input   wire[31:0] dtw0,    // Data to write
    input   wire req0,          // Valid input
    output  reg  ack0,          // Valid output

    // Channel 1
    input   reg [31:0] addr1,   // Address request from
    input   wire rw1,           // Read/write signal from
    output  reg [31:0] dtr1,    // Data to read
    input   wire[31:0] dtw1,    // Data to write
    input   wire req1,          // Valid input
    output  reg  ack1           // Valid output
);
endmodule
