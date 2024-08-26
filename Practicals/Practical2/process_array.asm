; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; ==========================
section .data

section .bss
  double_array resq 10  ;reserve space for 10 doubles
  arr_size resb 1 ;reseve 1 byte for size

section .text
    global processArray

processArray:
    mov arr_size, byte[rsi] ;store size param
    xor rcx, rcx  ;set counter to 0
    
    .while:
        cvtss2sd xmm1, [xmm0 + rcx * 4] ;store floatArr[i] as double in xmm1
        movsd [double_array+rcx*8], xmm1  ;store the double in the double array
        inc rcx ; ++i
        
        cmp rcx, [arr_size]
        jnz .while
    
    movsd xmm0, double_array  ;store double array for return
    ret

    
