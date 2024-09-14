; ==========================
; Group member 01: Name_Surname_student-nr
; ==========================

segment .text
        global calculateMatrixDotProduct

calculateMatrixDotProduct:
  ; float return = rax 
  ; matrix_1 = rdi
  ; matrix_2 = rsi 
  ; rows = rdx 
  ; cols = rcx 

  ;check if row/cols is 0
  cmp rcx, 0
  je .end
  cmp rdx, 0
  je .end
  xor r8, r8  ;clear counter #1
  pxor xmm0, xmm0  ;total row counter for dot product of the row


  .loop:
    mov rax, [rdi+r8*8] ;grab array from the matrix
    mov rbx, [rsi+r8*8] ;get the address of the array in the second matrix
    xor r9, r9  ;second loop counter
    pxor xmm1, xmm1 ;temp holds m1 float
    pxor xmm2, xmm2 ;temp holds m2 float
    .inner_loop:
      movss xmm1, [rax+r9*4]  ;get element in the array of m1  
      movss xmm2, [rbx+r9*4]  ;get the element in the array of m2
      mulss xmm1, xmm2  ; multiply the column values
      addss xmm0, xmm1  ;add to the total of the row
      inc r9
      cmp r9, rcx ;compare to the cols
      jnz .inner_loop
    inc r8 
    cmp r8, rdx  ;compare to row
    jnz .loop

  .end:
    cvtss2si rax, xmm0
    ret
