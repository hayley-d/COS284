section .data
a: equ 0
b: equ 8
max: equ 16

section .text
  global _start

_start:
  push rbp
  mov rbp, rsp

  ;print max (100,200)
  mov qword[rdi], 100
  mov qword[rsi], 200
  call print_max
  mov rax, 0  ; return 0
  leave
  ret

print_max:
  push rbp
  mov rbp, rsp

  sub rsp, 32 ;reserve space for a,b and max
  mov [rsp+a], rdi  ;save param 1
  mov [rsp+b], rsi  ;save param 2
  mov [rsp+max], rdi  ; max = a
  cmp rsi, rdi    ;compare a and b
  jng skip  ;if a > b
  mov [rsp+max], rsi  ;set max = b

skip:
  segment .data
  fmt db "max(%ld,%ld) = %ld",0xa,0

  segment .text
    mov qword[rdi], fmt   ;first param load
    mov qword[rsi], [rsp+a] ; load second param
    mov qword[rdx], [rsp+b] ; oad third param 
    mov qword[rcx], [rsp+max] ; load 4th param
    mov rax, 0
    call printf
    leave
    ret
