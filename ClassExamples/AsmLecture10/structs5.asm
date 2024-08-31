segment .data
  struc Customer
  .id resd 1  ;4 bytes in total
  .name resb 65 ;69 bytes in total
  .address resb 65 ; 134 bytes total
  align 4 ;align to 136 bytes
  .balance resd 1; 140 bytes total
  .rand resb 1 ; 141 bytes total
  align 4 ; 144 bytes total
  endstruc

  customers dq 0

  format db "%s %s %d",0x0a,0

  segment .text
  global _start

_start:
  mov rdi, 100 ; for 100 structs
  imul rdi, Customer_size
  call malloc

  mov [customers], rax

  push rbp
  mov rbp, rsp
  push r15
  push r14
  mov r15, 100          ; save the counter though calls
  mov r14, [customers]  ;save the pointer though calls
  ;first customer is in r14

more:
  lea rdi, [format]
  lea rsi, [r14 + Customer.name]  ;pass through the address rather than the value
  lea rdx, [r14 + Customer.address]
  mov ecx, [r14 + Customer.balance]
  call printf

  add r14, Customer_size  ;increment by the number of byte the struct takes 
  dec r15 ;decrement till 0
  jnz more
  pop r14
  pop r15
  leave
  ret
