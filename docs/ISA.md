# Instruction Set

## Overview

Legend:
- imm12/16/24 = 12/16/24-bit immediate value
- Rd, Rn and Rm specify the way each register is wired to the ALU. In this case,
  Rd represents the read/write source/destination, Rm and Rn represents the 2 operands fed into the ALU; note that Rn will always have a barrel
  shifter in front of it.
   - naming a register with Rd Rn Rm is always 4 bits
- [xxx] = Dereference pointer, address is stored in xxx
- sh(Rn) shifts contents of Rn left or right by an 8-bit amount

<table border=0 cellpadding=0 cellspacing=0 width=703>
 <tr height=19>
   <td height=19 colspan=6><center><h3>Full Instruction Listing (Draft)</h3></center></td>
 </tr>
 <tr height=19>
  <td>Mnemonic</td>
  <td>Operands</td>
  <td>Description</td>
  <td>Operation</td>
 </tr>
 <tr height=19>
  <td colspan=3><center><b>Load Instsructions</b></center></td>
 </tr>
 <tr height=19>
  <td>LDR</td>
  <td>Rd, [Rm+imm16]</td>
  <td>Load from memory immed</td>
 </tr>
 <tr height=19>
  <td>LDR</td>
  <td>Rd, [Rm+sh(Rn)]</td>
  <td>Load from memory</td>
 </tr>
 <tr height=19>
 <td colspan=3><center><b>Store Instructions</center></td>
 </tr>
 <tr height=19>
  <td>STR</td>
  <td>[Rm+imm16], Rd</td>
  <td>Store to memory immed</td>
 </tr>
 <tr height=19>
  <td>STR</td>
  <td>[Rm+sh(Rn)], Rd</td>
  <td>Store to memory</td>
 </tr>
 <tr height=19>
  <td colspan=3><center><b>Movement Instructions</center></td>
 </tr>
 <tr height=19>
  <td>MOV</td>
  <td>Rd, imm16</td>
  <td>Move immed</td>
 </tr>
 <tr height=19>
  <td>MOV</td>
  <td>Rd, sh(Rn)</td>
  <td>Move</td>
 </tr>
 <tr height=19>
  <td>MOVT</td>
  <td>Rd, imm16</td>
  <td>Move to top word immed</td>
 </tr>
 <tr height=19>
  <td colspan=3><center><b>Arithmetic Instructions</center></td>
 </tr>
 <tr height=19>
  <td>ADD(?C)</td>
  <td>Rd, Rm, sh(Rn)</td>
  <td>Add (with carry)</td>
 </tr>
 <tr height=19>
  <td>ADD(?C)</td>
  <td>Rd, Rm, imm16</td>
  <td>Add (with carry) immed</td>
 </tr>
 <tr height=19>
  <td>(?R)SUB(?C)</td>
  <td>Rd, Rm, sh(Rn)</td>
  <td>(Reverse) sub (with c)</td>
 </tr>
 <tr height=19>
  <td>(?R)SUB(?C)</td>
  <td>Rd, Rm, imm16</td>
  <td>(Reverse) sub (with c) immed</td>
 </tr>
 <tr height=19>
  <td>MUL</td>
  <td>Rd, Rm, sh(Rn)</td>
  <td>Signed multiply</td>
 </tr>
 <tr height=19>
  <td colspan=3><center><b>Logic Instructions</center></td>
 </tr>
 <tr height=19>
  <td>AND</td>
  <td>Rd, Rm, sh(Rn)</td>
  <td>And</td>
 </tr>
 <tr height=19>
  <td>AND</td>
  <td>Rd, Rm, imm16</td>
  <td>And immed</td>
 </tr>
 <tr height=19>
  <td>OR</td>
  <td>Rd, Rm, sh(Rn)</td>
  <td>Or</td>
 </tr>
 <tr height=19>
  <td>OR</td>
  <td>Rd, Rm, imm16</td>
  <td>Or immed</td>
 </tr>
 <tr height=19>
  <td>XOR</td>
  <td>Rd, Rm, sh(Rn)</td>
  <td>XOR</td>
 </tr>
 <tr height=19>
  <td>XOR</td>
  <td>Rd, Rm, imm16</td>
  <td>XOR immed</td>
 </tr>
 <tr height=19>
  <td>NOT</td>
  <td>Rd, Rm</td>
  <td>Invert Rm</td>
 </tr>
 <tr height=19>
  <td colspan=3><center><b>Compare and Test</center></td>
 </tr>
 <tr height=19>
  <td>CMP</td>
  <td>Rd, Rn</td>
  <td>Flags when Rd - Rn</td>
 </tr>
 <tr height=19>
  <td>CMP</td>
  <td>Rd, imm16</td>
  <td>Flags when Rd - imm16</td>
 </tr>
 <tr height=19>
  <td>TST</td>
  <td>Rd, Rn</td>
  <td>Flags when Rd &amp; Rn</td>
 </tr>
 <tr height=19>
  <td>TST</td>
  <td>Rd, imm16</td>
  <td>Flags when Rd &amp; imm16</td>
 </tr>
 <tr height=19>
   <td colspan=3><center><b>Branch and Jump</center></td>
 </tr>
 <tr height=19>
  <td>B&lt;cond&gt;L</td>
  <td>imm16</td>
  <td>Branch and link to PC+imm</td>
 </tr>
 <tr height=19>
  <td>B&lt;cond&gt;</td>
  <td>imm16</td>
  <td>Branch to PC+imm</td>
 </tr>
 <tr height=19>
  <td colspan=3><center><b>System Instructions</center></td>
 </tr>
 <tr height=19>
  <td>INT</td>
  <td>imm24</td>
  <td>Invoke software interrupt</td>
 </tr>
</table>

## System Details

There are 16 (r0-r15) general-purpose registers plus 4 privileged registers.
In supervisor mode, r12-15 is separate from user-mode r12-15. In all modes, r14 and r15 will be used as the link register and stack pointer respectively.

<table border=0 cellpadding=0 cellspacing=0 width=543>
 <tr height=19>
  <td rowspan=2 height=38 width=64>Register</td>
  <td colspan=3 width=287>Alias/Description</td>
 </tr>
 <tr height=19>
  <td height=19>User</td>
  <td>IRQ</td>
  <td>Supervisor</td>
 </tr>
 <tr height=19>
  <td height=19>r0-r11</td>
  <td colspan=3><center>Shared general purpose registers</center></td>
 </tr>
 <!--<tr height=19>
  <td height=19>r10</td>
  <td>General</td>
  <td>General</td>
  <td>General</td>
 </tr>-->
 <tr height=19>
  <td height=19>r12</td>
  <td>General</td>
  <td colspan=2><center>Interrupt Vector Table</center></td>
 </tr>
 <tr height=19>
  <td height=19>r13</td>
  <td>General</td>
  <td colspan=2><center>Machine Configuration Register</center></td>
 </tr>
 <tr height=19>
  <td height=19>r14</td>
  <td>User LR</td>
  <td>IRQ LR</td>
  <td>Super LR</td>
 </tr>
 <tr height=19>
  <td height=19>r15</td>
  <td>User SP</td>
  <td>IRQ SP</td>
  <td>Super SP</td>
 </tr>
</table>

---

### Operation

During a mode switch, the return address will be stored in the appropriate LR and the return stack pointer will be stored in the appropriate SP.

For instance, an interrupt call from User mode will prompt a switch to IRQ mode.
The return address and stack pointer of the caller will be stored in IRQ LR (r14) and IRQ SP (r15) respectively.

## Encoding

These are the different encodings that instructions come in. 
All instructions are 32 bit.
The first 8 bits is opcode.
Rd, Rm, Rn are always in the same position in the instruciton if present
<X> indicates unused spacer value of X bits

- Field Sizes:
  - Rd : 4 bit register name
  - Rm : 4 bit register name
  - Rn : 4 bit register name
  - Shift: 5 bit shift amount applied to Rn
  - ImmX: X bit literal field

We have these unique encodings then

<!-- Unindent??? >:[ -->

<div class="ritz grid-container" dir="ltr"><table class="waffle" cellspacing="0" cellpadding="0"><thead><tr><th class="row-header freezebar-origin-ltr"></th><th id="1092009867C0" style="width:121px" class="column-headers-background">A</th><th id="1092009867C1" style="width:100px" class="column-headers-background">B</th><th id="1092009867C2" style="width:100px" class="column-headers-background">C</th><th id="1092009867C3" style="width:100px" class="column-headers-background">D</th><th id="1092009867C4" style="width:100px" class="column-headers-background">E</th><th id="1092009867C5" style="width:100px" class="column-headers-background">F</th><th id="1092009867C6" style="width:100px" class="column-headers-background">G</th><th id="1092009867C7" style="width:100px" class="column-headers-background">H</th><th id="1092009867C8" style="width:100px" class="column-headers-background">I</th></tr></thead><tbody><tr style='height:20px;'><th id="1092009867R0" style="height: 20px;" class="row-headers-background"><div class="row-header-wrapper" style="line-height: 20px;">1</div></th><td class="s0" dir="ltr">Encoding Name</td><td class="s0" dir="ltr">Bits 0-3</td><td class="s0" dir="ltr">Bits 4-7</td><td class="s0" dir="ltr">Bits 8-11</td><td class="s0" dir="ltr">Bits 12-15</td><td class="s0" dir="ltr">Bits 16-19</td><td class="s0" dir="ltr">Bits 20-23</td><td class="s0" dir="ltr">Bits 24-27</td><td class="s0" dir="ltr">Bits 28-31</td></tr><tr style='height:20px;'><th id="1092009867R1" style="height: 20px;" class="row-headers-background"><div class="row-header-wrapper" style="line-height: 20px;">2</div></th><td class="s1" dir="ltr">Rd Rm Imm16</td><td class="s0" dir="ltr" colspan="2">Opcode</td><td class="s0" dir="ltr">Rd</td><td class="s0" dir="ltr">Rm</td><td class="s0" dir="ltr" colspan="4">Imm16</td></tr><tr style='height:20px;'><th id="1092009867R2" style="height: 20px;" class="row-headers-background"><div class="row-header-wrapper" style="line-height: 20px;">3</div></th><td class="s1" dir="ltr">Rd Rm Rn Shift</td><td class="s0" dir="ltr" colspan="2">Opcode</td><td class="s0" dir="ltr">Rd</td><td class="s0" dir="ltr">Rm</td><td class="s0" dir="ltr">Rn</td><td class="s0" dir="ltr" colspan="2">Shift(5 bits)</td><td class="s0" dir="ltr">Unused</td></tr>

<tr style='height:20px;'>
  <th id="1092009867R3" style="height: 20px;" class="row-headers-background">
    <div class="row-header-wrapper" style="line-height: 20px;">4</div>
  </th>
  <td class="s0" dir="ltr">Imm24</td>
  <td class="s0" dir="ltr" colspan="2">Opcode</td>
  <td class="s0" dir="ltr" colspan="6">Imm24</td>
</tr>

<tr style='height:20px;'>
  <th id="1092009867R3" style="height: 20px;" class="row-headers-background">
    <div class="row-header-wrapper" style="line-height: 20px;">5</div>
  </th>
  <td class="s0" dir="ltr">Register Type (R-Type)</td>
  <td class="s0" dir="ltr" colspan="2">Opcode</td>
  <td class="s0" dir="ltr" colspan="1">Rd</td>
  <td class="s0" dir="ltr" colspan="1">Rm</td>
  <td class="s0" dir="ltr" colspan="1">Rn</td>
  <td class="s0" dir="ltr" colspan="3">Unused</td>
</tr>

<tr style='height:20px;'>
  <th id="1092009867R3" style="height: 20px;" class="row-headers-background">
    <div class="row-header-wrapper" style="line-height: 20px;">6</div>
  </th>
  <td class="s0" dir="ltr">Jump Type (J-Type)</td>
  <td class="s0" dir="ltr" colspan="2">Opcode</td>
  <td class="s0" dir="ltr" colspan="1">Rd</td>
  <td class="s0" dir="ltr" colspan="4">16-bit Address or first half of 32-bit Address</td>
  <td class="s0" dir="ltr" colspan="1">Unused</td>
</tr>
</tbody></table></div>