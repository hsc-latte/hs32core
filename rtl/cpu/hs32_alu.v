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
 * @file   hs32_alu.v
 * @author Anthony Kung <hi@anth.dev>
 * @author Kevin Dai <kevindai02@outlook.com>
 * @date   Created on October 31 2020, 12:13 PM
 */

`default_nettype none

`include "cpu/hs32_aluops.v"

module hs32_alu (
    input  wire [31:0] i_a,
    input  wire [31:0] i_b,
    input  wire [3:0] i_op,
    output wire [31:0] o_r,
    input  wire [3:0] i_fl, // nzcv in
    output wire [3:0] o_fl  // nzcv out
);
    // Assign output
    wire carry;
    assign { carry, o_r } =
        (i_op == `HS32A_ADD) ? i_a + i_b :
        (i_op == `HS32A_SUB) ? { 1'b0, i_a } - { 1'b0, i_b } :
        (i_op == `HS32A_AND) ? { i_fl[1], i_a & i_b } :
        (i_op == `HS32A_AND) ? { i_fl[1], i_a | i_b } :
        (i_op == `HS32A_XOR) ? { i_fl[1], i_a ^ i_b } :
        (i_op == `HS32A_BIC) ? { i_fl[1], i_a & ~i_b } :
        (i_op == `HS32A_ADC) ? i_a + i_b + { 31'b0, i_fl[1] } :
        (i_op == `HS32A_SBC) ? { 1'b0, i_a } - { 1'b0, i_b } - {32'b0, i_fl[1] } :
`ifdef IMUL
        (i_op == `HS32A_MUL) ? i_a * i_b :
`endif
        { i_fl[1], i_b };
    
    // Compute output flags
    assign o_fl[3] = o_r[31] == 1 && (i_op == `HS32A_SUB);
    assign o_fl[2] = ~(|o_r);
    assign o_fl[1] = carry;
    assign o_fl[0] = { carry, o_r[31] } == 2'b01; // TODO: Calculate carry
endmodule