section .data
msg: db "Hello World", 0x0a, 0

section .text
  global _start:
  extern printf

_start:
  ;stack frame construction
  push rbp      ; restore 16 byte boundry
  mov rbp, rsp  ; 

  mov rdi, msg  ; param 1 for printf call
  mov rax, 0    ; 0 floating point params
  call printf

  mov rax, 0    ;return 0
  ;stack frame destruction
  mov rsp, rbp
  pop rbp       ;return to the correct location
  ret
