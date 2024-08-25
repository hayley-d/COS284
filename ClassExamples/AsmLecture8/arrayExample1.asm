section .data
a: dq 123
c: dq 4,1,5,2,7,8

section .text
  global _start

_start:
  lea rcx, [c]  ;move the address of the array into rcx
  mov qword[rax], [rcx] ;move 4 into rax

  lea rcx, [a]  ;moves the address of a into rcx
  mov rdi, 4
  mov qword[rax], [8 + rcx + 8*rdi] ;7 is loaded
  ; start at [a] 
  ; 8 + rcx = [c]
  ; [c] + 8*4 is the 4th element
