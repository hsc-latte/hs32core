/**
 * Copyright (c) 2020 The HSC Core Authors
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     https://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * 
 * @file   hs32_mem.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 24 2020, 10:09 PM
 */

 `default_nettype none

// Internal Memory Arbiter (IMA):
// Schedules and arbitrates memory requests.
//
// Note: channel0 gets priority over channel1
// When channel0 wants access, it drives req0 HIGH.
// When channel1 wants access, it drives req1 HIGH.
//
// IMA will then drive the respective rdy high
// when the operation is COMPLETE. The module on each channel
// only needs to wait for the rdy signals.
//
// >> MODULE OUTPUTS MUST REMAIN VALID UNTIL THE RDY SIGNAL <<

module hs32_mem (
    // External interface
    output  wire[31:0] addr,    // Output address
    output  wire rw,            // Read/write signal
    input   wire[31:0] din,     // Data input from memory
    output  wire[31:0] dout,    // Data output to memory
    output  wire valid,         // Valid outputs
    input   wire ready,          // Operation completed (valid din too)

    // Channel 0
    input   wire[31:0] addr0,   // Address request from
    input   wire rw0,           // Read/write signal from
    output  wire[31:0] dtr0,    // Data to read
    input   wire[31:0] dtw0,    // Data to write
    input   wire req0,          // Valid input
    output  wire rdy0,          // Valid output

    // Channel 1
    input   wire[31:0] addr1,   // Address request from
    input   wire rw1,           // Read/write signal from
    output  wire[31:0] dtr1,    // Data to read
    input   wire[31:0] dtw1,    // Data to write
    input   wire req1,          // Valid input
    output  wire rdy1           // Valid output
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
    assign rdy0 = req0 ? ready : 0;
    assign rdy1 = req0 ? 0 : (req1 ? ready : 0);

`ifdef FORMAL
    // 1. Assume conditions to make proof simple
    always @(*) begin
        assume(addr0 != addr1);
        assume(dtw0 != dtw1);
    end

    // 2. Assume a request will always be responded to
    always @(*)
    if(valid)
        assume property(s_eventually ready);
    
    // 3. Invariant of priority
    // - req0 will always have priority
    // - If ready is set, only one of rdy0 and rdy1 will be active
    always @(*) begin
        if(req0) begin
            assert(dout == dtw0);
            assert(addr == addr0);
            assert(rw == rw0);
            assert(ready == rdy0);
            assert(valid);
        end else if(req1) begin
            assert(dout == dtw1);
            assert(addr == addr1);
            assert(rw == rw1);
            assert(ready == rdy1);
            assert(valid);
        end
        assert(!(rdy0 && rdy1));
    end
`endif
endmodule
