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
 * @file   bram_ctl.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 26 2020, 7:12 PM
 */

`ifdef FORMAL
    `include "bram.v"
`else
    `include "soc/bram.v"
`endif

module soc_bram_ctl (
    input   wire clk,
    input   wire[addr_width-1:0] addr,
    output  reg [31:0] dread,
    input   wire[31:0] dwrite,
    input   wire rw,
    input   wire valid,
    output  reg  ready
);
    parameter addr_width = 8;
    initial ready = 0;

    // 4 addresses for each bram
    // Selects between current dword and next dword
    wire [addr_width-3:0] a0, a1, a2, a3;
    assign a0 = (addr[1:0] == 2'b00) ?
        addr[addr_width-1:2] : addr[addr_width-1:2] + 1;
    assign a1 = (addr[1:0] == 2'b00) || (addr[1:0] == 2'b01) ?
        addr[addr_width-1:2] : addr[addr_width-1:2] + 1;
    assign a2 = (addr[1:0] == 2'b11) ?
        addr[addr_width-1:2] + 1 : addr[addr_width-1:2];
    assign a3 = addr[addr_width-1:2];
    //
    // The read buffer shifted over.
    // Regarding the ending 2 bits of the address:
    // x = read, . = ignore
    //       a'  a'+1   -> where a' = addr[addr_width-1:2]
    // 00 [xxxx][....]
    // 01 [.xxx][x...]
    // 10 [..xx][xx..]
    // 11 [...x][xxx.]
    //     0123  0123   -> bram# the byte came from
    // dbuf will always be in the form of [0123]
    // So, an address ending in 11 should be [3012]
    //
    wire[31:0] dout;
    wire[31:0] dbuf, wbuf;
    assign dout =
        (addr[1:0] == 2'b00) ? { dbuf[31:0] } :
        (addr[1:0] == 2'b01) ? { dbuf[23:0], dbuf[31:24] } :
        (addr[1:0] == 2'b10) ? { dbuf[15:0], dbuf[31:16] } :
                               { dbuf[ 7:0], dbuf[31:8] } ;
    assign wbuf =
        (addr[1:0] == 2'b00) ? { dwrite[31:0] } :
        (addr[1:0] == 2'b01) ? { dwrite[ 7:0], dwrite[31:8 ] } :
        (addr[1:0] == 2'b10) ? { dwrite[15:0], dwrite[31:16] } :
                               { dwrite[23:0], dwrite[31:24] } ;

    // Write enable signal
    wire we; assign we = valid & rw;

    // FSM (needed?)
    reg[1:0] state = 0;
    always @(posedge clk) case(state)
        0: begin 
            if(valid) begin
                state <= 1;
            end
            ready <= 1;
            dread <= dout;
        end
        1: begin
            state <= 0;
            ready <= 0;
        end
    endcase

    // 4 brams, each controlled by 1 address line
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram0(
        .clk(clk), .we(we),
        .addr(a3), .din(wbuf[7:0]), .dout(dbuf[7:0])
    );
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram1(
        .clk(clk), .we(we),
        .addr(a2), .din(wbuf[15:8]), .dout(dbuf[15:8])
    );
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram2(
        .clk(clk), .we(we),
        .addr(a1), .din(wbuf[23:16]), .dout(dbuf[23:16])
    );
    soc_bram #(
        .addr_width(addr_width-2),
        .data_width(8)
    ) ice40_bram3(
        .clk(clk), .we(we),
        .addr(a0), .din(wbuf[31:24]), .dout(dbuf[31:24])
    );

`ifdef FORMAL
    // $past gaurd
    reg f_past_valid;
    initial f_past_valid = 0;
    always @(posedge clk)
        f_past_valid <= 1;
    
    // 1. Always assume data valid
    always @(*) begin
        assume(valid);
    end

    // 2. Formal bus interface contract
    always @(posedge clk)
    if(f_past_valid)
        if(!$rose(ready))
            assume($stable(addr) && $stable(dwrite) && $stable(rw));

    // 3. Cover checks if ready resets
    always @(posedge clk)
    if(f_past_valid)
        cover($fell(ready));

    // 4. Formal contract
    // -- if write bytes [1234][5678] to a (BE)
    // -> then read a   == [1234]
    // -> then read a+1 == [2345]
    // -> then read a+2 == [3456]
    // -> then read a+3 == [4567]
    (* anyconst *) reg[addr_width-1:0] f_addr;
    (* anyconst *) reg[31:0] f_data1;
    (* anyconst *) reg[31:0] f_data2;
    reg[5:0] f_state;
    initial f_state = 0;
    always @(posedge clk)
    case(f_state)
        // 1. Write to address (conscutive bytes)
        0: if(rw && f_addr == addr+0 && f_data1 == dwrite)
            f_state <= 1;        
        1: if(ready) begin
            if(rw && f_addr+4 == addr && f_data2 == dwrite)
                f_state <= 2;
            else
                f_state <= 0;
        end
        // 2. Read from same address
        2: if(ready) begin
            if(!rw && f_addr+0 == addr)
                f_state <= 3;
            else
                f_state <= 0;
        end
        // 3. Read from a+1
        3: if(ready) begin
            if(!rw && f_addr+1 == addr)
                f_state <= 4;
            else
                f_state <= 0;
        end
        // 4. Read from a+2
        4: if(ready) begin
            if(!rw && f_addr+2 == addr)
                f_state <= 5;
            else
                f_state <= 0;
        end
        // 5. Read from a+3
        5: if(ready) begin
            if(!rw && f_addr+3 == addr)
                f_state <= 6;
            else
                f_state <= 0;
        end
        // Finished
        6: if(ready) f_state <= 0;
    endcase

    // 2. Check if we read the same data back
    always @(posedge clk)
    if(f_state == 3 && ready) begin
        assert(dread == f_data1);
    end

    // 3. a+1 = 2345
    always @(posedge clk)
    if(f_state == 4 && ready) begin
        assert(dread == { f_data1[23:0], f_data2[31:24] });
    end

    // 4. a+2 = 3456
    always @(posedge clk)
    if(f_state == 5 && ready) begin
        assert(dread == { f_data1[15:0], f_data2[31:16] });
    end

    // 5. a+3 = 4567
    always @(posedge clk)
    if(f_state == 6 && ready) begin
        assert(dread == { f_data1[7:0], f_data2[31:8] });
    end
`endif
endmodule