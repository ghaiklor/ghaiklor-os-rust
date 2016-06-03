global check_long_mode

extern boot_error

section .text
bits 32

;; Check if Long Mode is supported by the CPU
;; http://wiki.osdev.org/Setting_Up_Long_Mode#x86_or_x86-64
check_long_mode:
  mov eax, 0x80000000
  cpuid
  cmp eax, 0x80000001
  jb check_long_mode.error

  mov eax, 0x80000001
  cpuid
  test edx, 1 << 29
  jz check_long_mode.error
  ret

.error:
  mov al, "2"
  jmp boot_error
