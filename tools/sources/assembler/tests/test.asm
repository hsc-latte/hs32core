; This is meaningless code to test the assembler and decoder. Please don't run this

test:

ldr r1, [r2 + 32]
ldr lr, [sp + r3 << 2]

str  [r2 + 32], r1
str [r2 + r3 >> 2], r1

mov r0, 20
mov r0, r3 << 3    

movt r10, 0x12
; The formatting issues are on purpose
 add sp, lr, r14  
   add r12,      r8, 0b1001 ; same line!

addc sp, lr, r14
addc r12, r8, 0b1001

sub r8, r6, r4 << 3
sub r12, r8, 100

rsub r8, r6, r4 >> 6
rsub r12, r8, 100

subc r8, r6, r4
subc r12, r8, 100

rsubc r8, r6, r4
rsubc r12, r8, 100

mul r8, r6, r4 >> 6

and r8, r6, r4 << 3
and r12, r8, 100

or r8, r6, r4 << 3
or r12, r8, 100

xor r8, r6, r4 << 3
xor r12, r8, 100

not r8, r6

cmp r0, r8
cmp r0, 0x0

cmp r0, r1
cmp r0, 0x8

int 0xf213

jmp label ; Is the jump correct?
jmp test

label:

mov r0, 'a'
int "b"
