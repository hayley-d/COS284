segment .data
  switch: dq case0
          dq case1  ; switch + 1*8 each element is 8bytes
          dq case2
  i: dq 2

segment .text
  global main

main:
  mov rax, [i] ;move the value of i into rax
  jmp [switch + rax*8]  ; move to i index in the array dq = 8 bytes

case0:
  mov rbx, 100  ;go here if i==0
  jmp end

case1:
  mov rbx, 101
  jmp end

case2:
  mov rbx, 102
  jmp end

end:
  xor eax, eax
  ret
