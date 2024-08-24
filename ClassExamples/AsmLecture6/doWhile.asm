section .data
  data db "Hello world",0
  n dq 0  ;use to store char looking for
  x db 'w'

section .text
  global _start

_start:
  mov bl, [x] ;load value looking for into register
  mov rcx, 0  ; set i = 0
  moc al, [data+rcx] ; c = data[i] so data[0]
  cmp al, 0 ; check that its not hull terminator
  jz end_do_while

do_while:
  cmp al, bl  ; if c==x
  je found
  inc rcx
  mov al, [data+rcx]  ;move to next character
  cmp al, 0 ;check its not null terminator
  jnz do_while

end_do_while:
  mov rcx, -1 ;not found

found:
  mov [n], rcx ;store index where it was found

  cmp
  je do_while

exit:
  ret
