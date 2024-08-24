segment .data
  sum dq 0
  data dg 0xfedc

segment .text
  global _start

_start:
  mov rax, [data]
  xor ebx, ebx  ;clear to store bit check
  xor ecx, ecx  ; i = 0 for loop count
  xor edx, edx  ; sum = 0

while:
  cmp rcx, 64 ;while i < 64 
  jge endWhile
  ;bt rax, 0 ;test the bit
  ;setc bl ;extract carry flag
  ;add edx, ebx  ;sum += data AND 1
  mov r8, rax
  and r8, 1
  add rdx, r8

  shr rax, 1  ;to extract next bit after
  inc rcx
  jmp while

endWhile

