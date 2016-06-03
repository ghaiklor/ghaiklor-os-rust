global setup_sse

extern boot_error

section .text
bits 32

;; Check for SSE and enable it
;; If it's not supported throw an error
;; http://wiki.osdev.org/SSE#Checking_for_SSE
setup_sse:
  ;; Check if SSE supports
  mov eax, 0x1
  cpuid
  test edx, 1 << 25
  jz setup_sse.error

  ;; Enable SSE
  mov eax, cr0
  and ax, 0xFFFB
  or ax, 0x2
  mov cr0, eax
  mov eax, cr4
  or ax, 3 << 9
  mov cr4, eax

  ret

.error:
  mov al, "a"
  jmp boot_error