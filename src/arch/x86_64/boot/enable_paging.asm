global enable_paging

extern p4_table

section .text
bits 32

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
