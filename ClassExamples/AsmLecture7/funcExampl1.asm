;leaf function -> does not call any other functions

_start:
  mov qword[rdi], 123   ;load param 1
  mov qword[rsi], 742 ; load param 2
  call max

max:
  mov rax, rdi  ;move param 1 to rax
  cmp rax, rsi  ; compare to param2
  cmovl rax, rsi  ; if param2 > rax then rax = param 2
  ret



