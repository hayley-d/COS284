; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; ==========================
section .data
double_sum: dq 0

section .bss
  double_array resq 10  ;reserve space for 10 doubles
  arr_size resb 1 ;reseve 1 byte for size

section .text
    global processArray

processArray:
    mov [arr_size], byte[rsi] ;store size param
    xor rcx, rcx  ;set counter to 0
    
    .while:
        cvtss2sd xmm1, [xmm0 + rcx * 4] ;store floatArr[i] as double in xmm1
        movsd [double_array+rcx*8], xmm1  ;store the double in the double array
        inc rcx ; ++i
        
        cmp rcx, [arr_size]
        jl .while
    
    xor rcx, rcx  ; initinize i = 0
    movzx r9, 1  ;initilize j = 1
    .multiply_loop
        cmp rcx, [arr_size];check rcx is within size
        jge .end_multiply
        
        cmp r9, [arr_size] ;check rcx is within size
        jge .end_multiply       

        movsd xmm2, [double_array+rcx*8]
        movsd xmm3, [double_array+r9*8]
        
        mulsd xmm2, xmm3          ;multiply double_array[i] * double_array[i+1]
        addsd [double_sum], xmm2  ;add the result of the multiplication to the sum

        inc rcx
        inc r9  ;increment counter varaibles
        jmp .multiply_loop
    
