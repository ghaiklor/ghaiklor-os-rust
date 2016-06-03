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

section .text
bits 32

start:
  ;; Update stack pointer to our reserved memory
  mov esp, stack_top

  ;; Check if Long Mode is supported
  call check_multiboot
  call check_cpuid
  call check_long_mode

  ;; In case if Long Mode is supported we can set up paging
  call setup_page_tables
  call enable_paging

  ;; Install GDT (Global Descriptor Table)
  lgdt [gdt64.pointer]

  mov ax, gdt64.data
  mov ss, ax
  mov ds, ax
  mov es, ax

  ;; Far jump to begin_long_mode routing for actually switching to x64 mode
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

;; Structure for Global Descriptor Table
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
