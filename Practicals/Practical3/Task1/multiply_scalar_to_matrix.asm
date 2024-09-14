; ==========================
; Group member 01: Hayley_Dodkins_u21528790 
; ==========================
segment .text
        global multiplyScalarToMatrix
        
multiplyScalarToMatrix:
  ; float** return = rax 
  ; in_matrix = rdi
  ; in_scalar = xmm0 
  ; rows = rsi
  ; cols = rdx

  ;check if row/cols is 0
  cmp rsi, 0
  je .end
  cmp rdx, 0
  je .end

  xor rcx, rcx

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
    ret
