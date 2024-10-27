section .data
align 8
floatConstant:    dq 1071644672   

section .text
global clamp
global applyHistogramEqualisation

clamp:
    push    rbp
    mov     rbp, rsp
    mov     [rbp-4], edi
    cmp     dword [rbp-4], 255
    jle     checkLowerBound
    mov     eax, -1
    jmp     returnClamp
checkLowerBound:
    cmp     dword [rbp-4], 0
    jns     returnInput
    mov     eax, 0
    jmp     returnClamp
returnInput:
    mov     eax, [rbp-4]
returnClamp:
    pop     rbp
    ret

applyHistogramEqualisation:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 40
    mov     [rbp-40], rdi
    cmp     qword [rbp-40], 0
    je      handleNullInput
    mov     rax, [rbp-40]
    mov     [rbp-8], rax
    jmp     outerLoopStart
processNextRow:
    mov     rax, [rbp-8]
    mov     [rbp-16], rax
    jmp     innerLoopStart
processPixel:
    mov     rax, [rbp-16]
    movzx   eax, byte [rax+3]
    movzx   eax, al
    pxor    xmm0, xmm0
    cvtsi2ss xmm0, eax
    movss   [rbp-20], xmm0
    pxor    xmm1, xmm1
    cvtss2sd xmm1, [rbp-20]
    movsd   xmm0, [rel floatConstant]
    addsd   xmm0, xmm1
    cvttsd2si eax, xmm0
    mov     [rbp-24], eax
    mov     eax, [rbp-24]
    mov     edi, eax
    call    clamp
    mov     [rbp-25], al
    mov     rax, [rbp-16]
    movzx   edx, byte [rbp-25]
    mov     [rax], dl
    mov     rax, [rbp-16]
    movzx   edx, byte [rbp-25]
    mov     [rax+1], dl
    mov     rax, [rbp-16]
    movzx   edx, byte [rbp-25]
    mov     [rax+2], dl
    mov     rax, [rbp-16]
    mov     rax, [rax+32]
    mov     [rbp-16], rax
innerLoopStart:
    cmp     qword [rbp-16], 0
    jne     processPixel
    mov     rax, [rbp-8]
    mov     rax, [rax+16]
    mov     [rbp-8], rax
outerLoopStart:
    cmp     qword [rbp-8], 0
    jne     processNextRow
    jmp     returnHistogram
handleNullInput:
    nop
returnHistogram:
    leave
    ret
