section .data
  sum  dq  0

section .text
  global _start

_start:
  mov rcx, 100  ;how much we want to repeate

while:
  cmp rcx, 100  ;compare the counter with target
  jg endWhile ;if rcx > 100
  add [sum], rcx  ;sum 
  inc rcx ; ++rcx
  jmp while

endWhile:
  ret
