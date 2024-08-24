section .data
  data db "Hello world",0
  n dq 0
  x db 'w'

section .text
  global _start

_start:
  movzx rbx, byte[x]  ;move char into register (pad with 0s)
  mov rcx, 0
  movzx rax, byte[data+rcx] ;move char into rax (pad with 0s)
  cmp rax, 0
  jz end_do_while

do_while:
  cmp rax, rbx
  je found
  inc rcx
  movzx rax, byte[data+rcx]
  cmp rax, 0
  jnz do_while

end_do_while
  mov rcx, -1

found:
  mov [n], rcx
