section .data

section .text
  global _start

_start:

; create an array
; array = create(size)
create:
  push rbp
  mov rbp, rsp

  imul rdi, 4 ;multiply by 4 size*4 each is 4 bytes
  call malloc
  
  leave
  ret

fill: ;fill(int* array, long size)
  .array equ 0
  .size equ 8
  .i equ 16

  push rbp
  mov rbp, rsp

  sub rsp, 32 ;reserve space
  mov [rsp+.array], rdi ;store the array address
  mov [rsp + .size], rsi  ;store the size of the array
  mov rcx, 0  ; index = 0

  .more mov [rsp + .i], rcx ;save current location
        call rand ;call rand function in c
        mov rcx, [rsp+ .i]
        mov rdi, [rsp + .array]
        mov [rdi + rcx*4], eax  ;rand returned an int which is 32 bits stored in eax
        inc rcx
        cmp rcx, [rsp+ .size]
        jl .more  ; jump if not the end of the array
        leave
        ret

print:
  .array equ 0
  .size equ 8
  .i equ 16

  push rbp
  mov rbp, rsp

  sub rsp, 32

  mov [rsp + .array], rdi ;make backup
  mov [rsp + .size], rsi ; make backup
  mov rcx, 0  ; index = 0
  mov [rsp + .i], rcx ;store index

  segment .data
  .format: db "%10d",0xa,0

  segment .text
  .more
    lea rdi, [.format]  ;store the param 1 into rdi
    mov rdx, [rsp + .array] ;extract array from stack
    mov rcx, [rsp + .i] ;get the index  
    mov esi, [rdx+rcx*4] ; store the current element
    mov rax, 0
    call printf
    mov rcx, [rsp+.i] ;store the current index
    inc rcx ;increment the index
    mov [rsp+.i], rcx ;store the index
    cmp rcx, [rsp+.size] ;compare
    jl .more ;if rcx is less than size
    leave
    ret

