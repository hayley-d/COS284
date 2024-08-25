section .data
  sum dq 0
  N dq 5

section .text
  global _start:

_start:
  xor ecx, ecx
  mov rbx, [N] ; outer counter
  mov rax, 0  ;sum = 0
  mov r8,1  ;i=1 used as counting register

loop1:
  cmp r8, rbx ; i <= N
  jg in_loop1
  mov rcx, 1  ; j = 1 inner counter
  
loop2:
  cmp rcx, r8
  jg in_loop2 ; j <= i
  add rax, rcx  ; sum + j
  inc rcx
  jmp loop2

in_loop2:
  inc r8
  jmp loop1

in_loop1:
  mov [sum], rax

