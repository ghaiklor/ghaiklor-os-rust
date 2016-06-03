;; This code will be called by the bootloader
;; In our case it will be Grub2

;; start will be our entry point to the kernel
global start

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

  mov dword [0xB8000], 0x2F4B2F4F
  hlt

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

;; Sub-routine for printing error code
boot_error:
  mov dword [0xb8000], 0x4f524f45
  mov dword [0xb8004], 0x4f3a4f52
  mov dword [0xb8008], 0x4f204f20
  mov byte [0xb800a], al
  hlt

;; Reserve memory for stack
section .bss
stack_bottom:
  resb 64
stack_top:
