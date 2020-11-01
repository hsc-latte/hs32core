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
 * only needs to wait for the ack0/ack1 signals.
 *
 * >> MODULE OUTPUTS MUST REMAIN VALID UNTIL THE ACK SIGNAL <<
 *
*/

module hs32_mem (
    // External interface
    output  wire[31:0] addr,    // Output address
    output  wire rw,            // Read/write signal
    input   wire[31:0] din,     // Data input from memory
    output  wire[31:0] dout,    // Data output to memory
    output  wire valid,         // Valid outputs
    input   wire done,          // Operation completed (valid din too)

    // Channel 0
    input   wire[31:0] addr0,   // Address request from
    input   wire rw0,           // Read/write signal from
    output  wire[31:0] dtr0,    // Data to read
    input   wire[31:0] dtw0,    // Data to write
    input   wire req0,          // Valid input
    output  wire ack0,          // Valid output

    // Channel 1
    input   wire[31:0] addr1,   // Address request from
    input   wire rw1,           // Read/write signal from
    output  wire[31:0] dtr1,    // Data to read
    input   wire[31:0] dtw1,    // Data to write
    input   wire req1,          // Valid input
    output  wire ack1           // Valid output
);
    // LUT Count:
    // 32 addr + 32 dout + 1 rw + 1 ack0 + 1 ack1 + 1 valid
    // Total, 68 LUT4s, 1 layer of logic
    assign addr = req0 ? addr0 : addr1;
    assign rw   = req0 ? rw0 : rw1;
    assign dtr0 = din;
    assign dtr1 = din;
    assign dout = req0 ? dtw0 : dtw1;
    assign valid = req0 || req1;
    assign ack0 = req0 ? done : 0;
    assign ack1 = req0 ? 0 : (req1 ? done : 0);
endmodule
