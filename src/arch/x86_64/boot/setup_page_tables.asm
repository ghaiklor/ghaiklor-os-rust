global setup_page_tables

extern p4_table
extern p3_table
extern p2_table

section .text
bits 32

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

.loop:
  mov eax, 0x200000
  mul ecx
  or eax, 0b10000011
  mov [p2_table + ecx * 8], eax

  inc ecx
  cmp ecx, 512
  jne setup_page_tables.loop

  ret
