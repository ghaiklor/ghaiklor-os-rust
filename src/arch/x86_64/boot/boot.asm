;; This code will be called by the bootloader
;; In our case it will be Grub2

;; start will be our entry point to the kernel
global start
extern begin_long_mode

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

;; Check if Multiboot is loaded properly
;; http://nongnu.askapache.com/grub/phcoder/multiboot.pdf
;; According to the specification, we can check eax register
;; There is must be value 0x36D76289 before loading the kernel
check_multiboot:
  cmp eax, 0x36D76289
  jne check_multiboot_error
  ret

check_multiboot_error:
  mov al, "0"
  jmp boot_error

;; Check if CPUID is supported by attempting to flip the ID bit (bit 21)
;; in the FLAGS register. If we can flip it, CPUID is available.
;; http://wiki.osdev.org/Setting_Up_Long_Mode#Detection_of_CPUID
check_cpuid:
  ;; Copy FLAGS in to EAX via stack
  pushfd
  pop eax

  ;; Copy to ECX as well for comparing later on
  mov ecx, eax

  ;; Flip the ID bit
  xor eax, 1 << 21

  ;; Copy EAX to FLAGS via the stack
  push eax
  popfd

  ;; Copy FLAGS back to EAX (with the flipped bit if CPUID is supported)
  pushfd
  pop eax

  ;; Restore FLAGS from the old version stored in ECX (i.e. flipping the
  ;; ID bit back if it was ever flipped).
  push ecx
  popfd

  ;; Compare EAX and ECX. If they are equal then that means the bit
  ;; wasn't flipped, and CPUID isn't supported.
  cmp eax, ecx
  je check_cpuid_error
  ret

check_cpuid_error:
  mov al, "1"
  jmp boot_error

;; Check if Long Mode is supported by the CPU
;; http://wiki.osdev.org/Setting_Up_Long_Mode#x86_or_x86-64
check_long_mode:
  ;; test if extended processor info in available
  mov eax, 0x80000000
  cpuid
  cmp eax, 0x80000001
  jb check_long_mode_error

  mov eax, 0x80000001
  cpuid
  test edx, 1 << 29
  jz check_long_mode_error
  ret

check_long_mode_error:
  mov al, "2"
  jmp boot_error

;; Setup paging for Long Mode
setup_page_tables:
  ;; map first P4 entry to P3 table
  mov eax, p3_table
  or eax, 0b11
  mov [p4_table], eax

  ;; map first P3 entry to P2 table
  mov eax, p2_table
  or eax, 0b11
  mov [p3_table], eax

  mov ecx, 0

setup_page_tables_loop:
  mov eax, 0x200000
  mul ecx
  or eax, 0b10000011
  mov [p2_table + ecx * 8], eax

  inc ecx
  cmp ecx, 512
  jne setup_page_tables_loop

  ret

enable_paging:
  ;; load P4 to cr3 register
  mov eax, p4_table
  mov cr3, eax

  ;; enable PAE-flag in cr4
  mov eax, cr4
  or eax, 1 << 5
  mov cr4, eax

  ;; set the Long Mode bit in the MSR
  mov ecx, 0xC0000080
  rdmsr
  or eax, 1 << 8
  wrmsr

  ;; enable paging in the cr0 register
  mov eax, cr0
  or eax, 1 << 31
  mov cr0, eax

  ret

;; Sub-routine for printing error code
boot_error:
  mov dword [0xb8000], 0x4f524f45
  mov dword [0xb8004], 0x4f3a4f52
  mov dword [0xb8008], 0x4f204f20
  mov byte [0xb800a], al
  hlt

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
