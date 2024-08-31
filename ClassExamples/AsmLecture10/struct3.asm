segment .data
  name db "Hayley",0
  address db "74 Cambridge Road",0
  balance dd 125000

  struc Customer
  .id resd 1
  .name resb 71
  .address resb 71
  .balance resd 1
  endstruc

  c dq 0  ;holds the pointer to the customer struct

  segment .text
  global _start

_start:
  mov rdi, Customer_size  ;get the size of the struct
  call malloc     ;allocate heap space
  mov [c], rax  ;save the pointer to the dynamic memory

  mov [rax+Customer.id], dword 7  ;assign 7 as the id

  lea rdi, [rax + Customer.name]
  lea rsi, [name]
  call strcpy

  mov rax, [c]  ;restore the pointer after function call

  lea rdi, [rax + Customer.address]
  lea rsi, [address]
  call strcpy

  mov rax, [c]

  mov edx, [balance]
  mov [rax + Customer.balance],edx



