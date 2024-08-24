section .data


section .text
  global _start

_start:
  mov rax, [a]
  mov rbx, [b]
  cmp rax, rbx
  jl set_max
  mov [max], rax
  jmp exit

set_max:
  mov [max], rbx

exit:
  ret
