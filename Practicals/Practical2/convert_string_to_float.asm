; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; ==========================
section .data
result: db 0.0

    global convertStringToFloat

convertStringToFloat:
  ;clear registers
  xor rax, rax
  xor rbx, rbx
  xor rcx, rcx
  xor rdx, rdx

  ;check sign
  mov al, byte[rdi] ;move first char into al
  cmp al, '-' ;see if neg sign
  jne parse_int
  inc rdi ;move to next char
  mov r8b, 1 ;sign is neg

parse_int:
  xor rdx, rdx
  .parse_int_loop:
      mov al, byte[rdi] ;move char into al
      cmp al, 0 ;check for null terminator
      je .check_fraction  ;jump if finished
      cmp al, '.' ;check if decimal point
      je .parse_fraction
      sub al, '0'   ;convert char into int
      imul rdx, 10  ;multiply by 10
      add rdx, rax
      inc rdi
      jmp .parse_int_loop

  .check_fraction:
  ;no decimal point
  jmp .final_ans

  .parse_fraction:
      inc rdi ;move to first digit of the dicmal
      mov rcx, 1
      .parse_fraction_loop:
          mov al, byte[rdi] ;load current char
          cmp al, 0
          je .final_ans
          sub al, '0' ;convert to int
          imul rbx, 10
          add rbx, rax
          imul rcx, 10
          inc rdi
          jmp .parse_fraction_loop

  .final_ans:
      cvtsi2ss xmm0, rdx  ;convert integer part into float
      test rcx, rcx ;check if decimal part is 0
      jz .apply_sign
      cvtsi2ss xmm1, rbx  ;convert fractional part into float
      cvtsi2ss xmm2, rcx  ;convert fractional divide
      divss xmm1, xmm2
      addss xmm0, xmm1  ;add fractional part

  .apply_sign:
      test r8b, r8b ;see if neg
      jz .postive
      subss result, xmm0  ;make negative
      jmp .done

  .positive:
      addss result, xmm0

  .done:
      ret
      
