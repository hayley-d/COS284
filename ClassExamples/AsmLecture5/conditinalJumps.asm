section .data


section .text
  global _start

_start:
  mov rax, [a]
  mov rbx, [b]
  cmp rax, rbx  ;if the rax - rbx is >= 0 then jump
  jge in_order
  mov [a], rbx
  mov [b], rax

in_order:
