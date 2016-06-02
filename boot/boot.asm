;; This code will be called by the bootloader
;; In our case it will be Grub2

;; start will be our entry point to the kernel
global start

;; by default, text section is the default section for executable code
section .text
bits 32

start:
  mov dword [0xB8000], 0x2F4B2F4F
  hlt
