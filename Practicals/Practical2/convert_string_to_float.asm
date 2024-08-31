; ==========================
; Group member 01: Hayley Dodkins u21528790
; ==========================
section .data
result dd 0.0
neg_one dd -1.0
sign db 0
zero dd 0.0

section .text
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
  mov [sign], byte 1 ;sign is neg

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
      inc rdi ;move to first digit of the decimal
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
      cvtsi2sd xmm4, rcx
      movsd xmm5, [zero]
      ucomisd xmm4, xmm5
      ;cmp rcx, 0 ;check if decimal part is 0
      je .store_result;.positive
      cvtsi2ss xmm1, rbx  ;convert fractional part into float
      cvtsi2ss xmm2, rcx  ;convert fractional divide
      divss xmm1, xmm2
      addss xmm0, xmm1  ;add fractional part

  .apply_sign:
      mov r8, [sign]
      CMP r8, 1 ;see if neg
      jne .store_result;.positive
      movss xmm1, [neg_one]
      mulss xmm0, xmm1
      mov [sign], byte 0
      ;movss [result], xmm0
      ;movss xmm3, [result]
      ;movss xmm4 ,[neg_one]
      ;subss xmm3,xmm4
      ;movss [result], xmm3
      ;jmp .done

  ;.positive:
   ;   movss xmm3, [result]
  ;    addss xmm3, xmm0
   ;   movss [result], xmm3

   .store_result
        movss [result], xmm0
        ret

  .done:
      
ret
