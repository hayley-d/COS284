segment .data
  name db "Bob",0
  address db "22 Cambridge Road",0
  balance dd 123

  segment .text
  global _start

_start:
  mov [rax], dword 7  ;set the id to 7
  lea rdi, [rax+4]    ; store the address of the name field
  lea rsi, [name]     ;copy the name to struct
  call strcpy         ; with params

  mov rax, [c]        ;place the struct back into the rax after function call
  lea rdi, [rax+75] ;address field
  lea rsi, [address]
  call strcpy

  mov rax, [c]      ;restore the rax back to the struct
  mov edx, [balance]
  mov [rax+146], edx
