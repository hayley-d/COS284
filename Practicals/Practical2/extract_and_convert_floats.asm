; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; ==========================
section .data
prompt: db "Enter values seporated by whitespace and enclosed in pipes (|): ",0

section .bss
  input resb 64 ;reseve space for a 64 byte input
  float_array resd 10 ;reserve space for 10 floats

section .text
  extern convertStringToFloat
  global extractAndConvertFloats

extractAndConvertFloats:
  push rbp
  mov rbp, rsp

  ;make sys out call
  mov rax, 4
  mov rbx, 1
  mov rcx, prompt
  mov rdx, 65
  int 0x80

  ;make sys in call
  mov rax, 3
  mov rbx, 0
  mov rcx, input
  mov rdx, 100

  ;rax has number of bytes read?
  mov byte[input+rax], 0  ;add null terminate to the string

  xor rax, rax
  xor rbx, rbx
  xor rcx, rcx
  mov rcx, 2  ;first char is '|' second char is a ' '
  mov r8, 0 ; index for rdi
  mov r9, 0 ; index for float array

  .do_while:
      mov al, byte[input+rcx]
      cmp al, 0  ;make sure not end of string
      jz .end_do_while
      mov byte[rdi + r8], al ; load char into rdi
      inc r8    ; incrmenent counter for rdi offset
      inc rcx   ; go to next char in the input
      mov al, byte[input+rcx] ;move char into al
      cmp al, ' '   ;see if end of substring
      jnz .do_while

      ; if next char is a ' '
      ;rdi should contain substring
      call convertStringToFloat     ; call to convert str into float
      movss [float_array + r9], xmm0 ;store float in the float array  
      inc r9  ;incement the index
      inc rcx ; go to next char
      jmp .do_while

  .end_do_while:
      movss xmm0, [float_array] ;return float array in xmm0

  leave
  ret
