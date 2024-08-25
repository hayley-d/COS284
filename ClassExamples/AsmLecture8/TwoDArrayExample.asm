segment .data
  format db "%s",0x0a,0

segment .text
  global main

main:
  push rbp
  mov rbp, rsp
  sub rsp, 16
  mov rcx, rsi  ;move array into rcx
  mov rsi, [rcx]  ;get first char* from array

start_loop:
  lea rdi, [format] ;for printf call
  mov [rsp], rcx  ;save the current array
  call printf

  mov rcx, [rsp] ;restore the array
  add rcx, 8  ;go to the next array
  mov rsi, [rcx] ;load value of char*
  cmp rsi, 0
  jnz start_loop ;end with null terminator

end_loop:

