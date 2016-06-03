global begin_long_mode

section .text
bits 64

begin_long_mode:
  mov rax, 0x2F592F412F4B2F4F
  mov qword [0xB8000], rax
  hlt
