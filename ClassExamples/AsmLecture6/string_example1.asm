section .data
  msg db "abcdefg",0
  msg2 db "123456",0

section .text
  global _start

_start:
  ; movsb = move string byte works with an array where elements are 1 byte each
  mov rsi, msg
  mov rdi, msg2
  movsb
  ; msg2 = "a23456 and rsi = [msg + 1] and rdi = [msg2 + 1]

  movsb
  ;msg2 = "ab3456"
