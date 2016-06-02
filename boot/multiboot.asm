;; Header definition for Multiboot specification
;; http://wiki.osdev.org/Multiboot
;; http://nongnu.askapache.com/grub/phcoder/multiboot.pdf

section .multiboot

;; 0..31 bits is a magic number 0xE85250D6
;; 32..63 bits is an architecture (0 means 32-bit of i386, 4 means 32-bit MIPS)
;; 64..95 bits is a Multiboot header length in bytes including magic fields
;; 96..127 bits is a checksum (Magic Number + architecture + Header length)
;; 128..X bits is a tags
header_start:
  dd 0xE85250D6
  dd 0
  dd header_end - header_start
  dd 0x100000000 - (0xE85250D6 + 0 + (header_end - header_start))
  dw 0
  dw 0
  dd 8
header_end:
