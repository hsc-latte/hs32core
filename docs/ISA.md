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
  <td>INC</td>
  <td>Rd, Rm, 0001</td>
  <td>Post increment</td>
 </tr>
 <tr height=19>
  <td>DEC</td>
  <td>Rd, Rm, 1001</td>
  <td>Post decrement</td>
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
  <td>Rm, Rn</td>
  <td>Flags when Rm - Rn</td>
 </tr>
 <tr height=19>
  <td>CMP</td>
  <td>Rm, imm16</td>
  <td>Flags when Rm - imm16</td>
 </tr>
 <tr height=19>
  <td>TST</td>
  <td>Rm, Rn</td>
  <td>Flags when Rm &amp; Rn</td>
 </tr>
 <tr height=19>
  <td>TST</td>
  <td>Rm, imm16</td>
  <td>Flags when Rm &amp; imm16</td>
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

The remain 24 bits come from these families of encodings:
* Rd Rm imm16
* Rd Rm Rn
* Rd imm16
* Rd <4> Rn
* Rd Rm
* <4> Rm Rn
* Rd Rm 0001
* Rd Rm 1001
* Imm16
* Imm24
