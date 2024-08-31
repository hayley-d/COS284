; ==========================
; Group member 01: Hayley Dodkins u21528790
; ==========================
section .data
double_sum: dq 0
array_size: db 0

section .text
    global processArray

processArray:
    ;mov [array_size], byte[rsi] ;store size param
    xor rcx, rcx  ;set counter to 0
    xorps xmm3, xmm3 ; set the sum to 0
    .while:
        cmp rcx, rsi
        jge .end_loop
        cvtss2sd xmm1, dword [rdi + rcx * 4] ;store floatArr[i] as double in xmm1
        inc rcx ; ++i
        cvtss2sd xmm2, [rdi + rcx * 4] ; store floatArr[i+1] in xmm2
        mulsd xmm1, xmm2  ; multiply float 1 with float 2
        addsd xmm3, xmm1  ; add to the total sum

        inc rcx ; ++i

        jmp .while

    .end_loop:

    movsd xmm0, xmm3  ;move into xmm0 for return
    cvtss2si rax, xmm0
    ret