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
 * @file   mmio.v
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on November 29 2020, 9:04 PM
 */

 `default_nettype none

module mmio(
    input wire clk,
    input wire reset,

    // Memory interface in
    input wire valid,
    output wire ready,
    input wire[31:0] addr,
    input wire[31:0] dtw,
    output wire[31:0] dtr,
    input wire rw,

    // SRAM Interface
    output wire sval,
    input wire srdy,
    output wire[31:0] saddr,
    output wire[31:0] sdtw,
    input wire[31:0] sdtr,
    output wire srw
    
);

endmodule
