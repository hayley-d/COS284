; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; ==========================
segment .text
        global multiplyScalarToMatrix
        
multiplyScalarToMatrix:
  ; float** return = rax 
  ; in_matrix = rdi
  ; in_scalar = xmm0 
  ; rows = rsi
  ; cols = rdx

  ;push rdi
  ;push rsi
  ;sub rsp, 16
  ;movdqu [rsp], xmm1

  ;check if row/cols is 0
  cmp rsi, 0
  je .end
  cmp rdx, 0
  je .end

  imul rsi, rdx  ;multiply row*cols to get the total number of elements in the array

  .loop:
    movsd xmm1, [rdi] ;grab elemnt from the matrix
    mulsd xmm1, xmm0 ; multiply by the scalar value
    movsd [rdi], xmm1 ;store back into the matrix
    add rdi, 4 ; increment to next index
    dec rsi
    jnz .loop

  .end:
    ;movdqu xmm1, [rsp]
    ;add rsp, 16
    ;pop rsi
    ;pop rdi
    ret
