global check_multiboot

extern boot_error

section .text
bits 32

;; Check if Multiboot is loaded properly
;; http://nongnu.askapache.com/grub/phcoder/multiboot.pdf
;; According to the specification, we can check eax register
;; There is must be value 0x36D76289 before loading the kernel
check_multiboot:
  cmp eax, 0x36D76289
  jne check_multiboot.error
  ret

.error:
  mov al, "0"
  jmp boot_error
