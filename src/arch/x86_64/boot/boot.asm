;; This code will be called by the bootloader
;; In our case it will be Grub2

global start
global p4_table
global p3_table
global p2_table

extern begin_long_mode
extern boot_error
extern check_cpuid
extern check_long_mode
extern check_multiboot
extern enable_paging
extern setup_page_tables

;; by default, text section is the default section for executable code
section .text
bits 32

start:
  ;; Update stack pointer to our reserved memory
  mov esp, stack_top

  ;; Check if Long Mode is supported
  call check_multiboot
  call check_cpuid
  call check_long_mode

  call setup_page_tables
  call enable_paging

  lgdt [gdt64.pointer]

  mov ax, gdt64.data
  mov ss, ax
  mov ds, ax
  mov es, ax

  jmp gdt64.code:begin_long_mode

;; Reserve memory for stack
section .bss
align 4096
p4_table:
  resb 4096
p3_table:
  resb 4096
p2_table:
  resb 4096
stack_bottom:
  resb 64
stack_top:

section .rodata
gdt64:
  dq 0
.code: equ $ - gdt64
  dq (1 << 44) | (1 << 47) | (1 << 41) | (1 << 43) | (1 << 53)
.data: equ $ - gdt64
  dq (1 << 44) | (1 << 47) | (1 << 41)
.pointer:
  dw $ - gdt64 - 1
  dq gdt64
