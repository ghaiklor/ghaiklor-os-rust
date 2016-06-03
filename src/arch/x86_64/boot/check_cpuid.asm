global check_cpuid

extern boot_error

section .text
bits 32

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
  je check_cpuid.error
  ret

.error:
  mov al, "1"
  jmp boot_error
