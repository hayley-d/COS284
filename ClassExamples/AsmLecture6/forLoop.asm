section .data



section .text
  global _start

_start:
;have 3 arrays of size n containing longs (quad words)
  mov rdx, [n] ; load the size
  xor ecx, ecx  ; i = 0

for:
  cmp rcx, rdx  ; i < 0
  je end_for
  mov rax, [a+rcx*8] ; get a[i]
  add rax, [c+rcx*8] ; a[i] + b[i]
  mov [c+rcx*8], rax ; c[i] = a[i] + b[i]
  inc rcx
  jmp for

end_for:
  ret
