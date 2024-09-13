; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; ==========================
segment .data
rows dd 0 ; number of rows in the matrix
cols dd 0 ;number of columns in the matrix
matrix dq 0 ; holds the first address of the matrix
num dd 0 ;holds the value of the scalar

segment .text
        global multiplyScalarToMatrix
        
multiplyScalarToMatrix:
  ;get the parameters
  mov [matrix], rdi ; store address of matrix
  mov [num], rsi ;get the scalar value
  mov [rows], rdx ;get the rows (param3)
  mov [cols], rcx ;get the cols (param4)
