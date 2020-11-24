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
 * @file   hs32_aluops.v
 * @author Anthony Kung <hi@anth.dev>
 * @date   Created on November 14 2020, 5:24 PM
 */

// ALU Operation Codes
// Created with <3 by Anthony & Kevin

`ifndef HS32_ALUOPS
`define HS32_ALUOPS

`define HS32A_NOP       4'b0000
`define HS32A_MOV       4'b0001
`define HS32A_ADD       4'b0010
`define HS32A_SUB       4'b0011
`define HS32A_AND       4'b0100
`define HS32A_OR        4'b0101
`define HS32A_XOR       4'b0110
`define HS32A_BIC       4'b0111

`define HS32A_MUL       4'b1000
`define HS32A_ADC       4'b1010
`define HS32A_SBC       4'b1011

`endif
