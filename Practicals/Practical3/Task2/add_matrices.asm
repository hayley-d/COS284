; ==========================
; Group member 01: Name_Surname_student-nr
; ==========================

extern malloc
section .text
    global addMatrices

addMatrices:
  ;setup stack frame
  push rbp
  mov rbp, rsp

  sub rsp, 32 ;store all 4 variables on stack
  mov [rsp], rdi  ;store the m1 matrix
  mov [rsp+8], rsi
  mov [rsp+16], rdx
  mov [rsp+20], rcx

  xor rdi, rdi
  add rdi, 8
  imul rdi, rdx ;multiply num rows by 8 bytes per row
  call malloc
  ;memory of new array in rax

  mov r8, [rsp] ;store m1
  mov r9, [rsp+8] ; store m2
  mov r10, [rsp+16]  ;store rows
  mov r11, [rsp+20] ;store cols

  ;check if row/cols is 0
  cmp r10, 0
  je .end
  cmp r11, 0
  je .end

  xor rcx, rcx  ;make counter = 0

  .loop:
    mov rax, [rdi+rcx*8] ;grab array from the matrix
    xor r9, r9  ;second loop counter
    .inner_loop:
      movss xmm1, [rax+r9*4]  ;get element in the array   
      mulss xmm1, xmm0 ; multiply by the scalar value
      movss [rax+r9*4], xmm1 ;store back into the array
      inc r9
      cmp r9, rdx ;compare to the cols
      jnz .inner_loop
    inc rcx
    cmp rcx, rsi  ;compare to row
    jnz .loop

  .end:
    leave ;restore stack frame
    ret
    ret
