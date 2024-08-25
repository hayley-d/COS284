section .data


section .text
  global _start

_start:
  lea rdi, [source] ; first param
  lea rsi, [destination]  ;second param
  mov rdx, 3  ; number of dwords to copy from source to dest
  ;would be faster to use rep movsd but for examples sake

copy_array:
  xor ecx, ecx  ; index = 0

more:
  ; dword = 4 bytes
  mov eax, [rsi + 4*rcx]  ;move source[index] to temp
  mov [rdi+4*rcx], eax    ; move  value into destination[index]
  inc rcx
  cmp rcx, rdx
  jne more
  xor eax, eax
  ret
