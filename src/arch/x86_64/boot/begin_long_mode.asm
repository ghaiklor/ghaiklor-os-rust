global begin_long_mode

section .text
bits 64

;; When all checks and operations needed for Long Mode are done
;; We can actually execute code in 64-bit Long Mode
begin_long_mode:
  mov rax, 0x2F592F412F4B2F4F
  mov qword [0xB8000], rax
  hlt
