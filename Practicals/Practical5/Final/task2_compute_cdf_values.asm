; This code implements image processing functionality for histogram equalization
; It converts RGB values to grayscale and computes CDF (Cumulative Distribution Function) values

section .data
    align 8
    redCoefficients: dq 0.299    ; Red coefficient for grayscale conversion (BT.601 standard)
    greenCoefficients: dq 0.587  ; Green coefficient for grayscale conversion
    blueCoefficients: dq 0.114   ; Blue coefficient for grayscale conversion

section .text
global computeCDFValues

; Function to convert RGB values to grayscale using weighted sum
; Parameters:
;   rdi - Red value
;   rsi - Green value
;   rdx - Blue value
; Returns:
;   eax - Grayscale value (0-255)
computeGrayscaleValue:
    push    rbp
    mov     rbp, rsp
    mov     ecx, esi        ; Store green value in ecx
    mov     eax, edx        ; Store blue value in eax
    mov     edx, edi        ; Store red value in edx
    mov     [rbp-4], dl     ; Save red value on stack
    mov     dl, cl
    mov     [rbp-8], dl     ; Save green value on stack
    mov     [rbp-12], al    ; Save blue value on stack
    
    ; Process red component: grayscale = 0.299 * red
    movzx   eax, byte [rbp-4]
    pxor    xmm1, xmm1
    cvtsi2sd xmm1, eax      ; Convert red to double
    movsd   xmm0, [rel redCoefficients]
    mulsd   xmm1, xmm0      ; Multiply by coefficient
    
    ; Add green component: += 0.587 * green
    movzx   eax, byte [rbp-8]
    pxor    xmm2, xmm2
    cvtsi2sd xmm2, eax      ; Convert green to double
    movsd   xmm0, [rel greenCoefficients]
    mulsd   xmm0, xmm2      ; Multiply by coefficient
    addsd   xmm1, xmm0      ; Add to result
    
    ; Add blue component: += 0.114 * blue
    movzx   eax, byte [rbp-12]
    pxor    xmm2, xmm2
    cvtsi2sd xmm2, eax      ; Convert blue to double
    movsd   xmm0, [rel blueCoefficients]
    mulsd   xmm0, xmm2      ; Multiply by coefficient
    addsd   xmm0, xmm1      ; Add to result
    
    ; Convert final result back to integer (0-255)
    cvttsd2si eax, xmm0
    pop     rbp
    ret

; Function to compute histogram of grayscale values
; Parameters:
;   rdi - Image data pointer
;   rsi - Histogram array pointer (256 integers)
;   rdx - Total count pointer
computeHistogram:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 56
    mov     [rbp-40], rdi   ; Store image data pointer
    mov     [rbp-48], rsi   ; Store histogram array pointer
    mov     [rbp-56], rdx   ; Store total count pointer
    mov     rax, [rbp-40]
    mov     [rbp-8], rax    ; Initialize outer loop pointer
    
; Outer loop traverses through image rows
.histogramOuterLoop:
    cmp     qword [rbp-8], 0
    je      .histogramOuterLoopEnd
    
    mov     rax, [rbp-8]
    mov     [rbp-16], rax   ; Initialize inner loop pointer
    
; Inner loop processes each pixel in the row
.histogramInnerLoop:
    cmp     qword [rbp-16], 0
    je      .histogramInnerLoopEnd
    
    ; Extract RGB values and compute grayscale
    mov     rax, [rbp-16]
    movzx   eax, byte [rax+2]   ; Get blue value
    movzx   edx, al
    mov     rax, [rbp-16]
    movzx   eax, byte [rax+1]   ; Get green value
    movzx   ecx, al
    mov     rax, [rbp-16]
    movzx   eax, byte [rax]     ; Get red value
    movzx   eax, al
    mov     esi, ecx
    mov     edi, eax
    call    computeGrayscaleValue
    
    mov     [rbp-17], al        ; Store grayscale result
    
    ; Update pixel's alpha channel with grayscale value
    mov     rax, [rbp-16]
    movzx   edx, byte [rbp-17]
    mov     [rax+3], dl
    
    ; Increment histogram count for this grayscale value
    movzx   eax, byte [rbp-17]
    lea     rdx, [rax*4]
    mov     rax, [rbp-48]
    add     rax, rdx
    mov     edx, [rax]
    add     edx, 1
    mov     [rax], edx
    
    ; Increment total pixel count
    mov     rax, [rbp-56]
    mov     eax, [rax]
    lea     edx, [rax+1]
    mov     rax, [rbp-56]
    mov     [rax], edx
    
    ; Move to next pixel
    mov     rax, [rbp-16]
    mov     rax, [rax+32]
    mov     [rbp-16], rax
    jmp     .histogramInnerLoop
    
.histogramInnerLoopEnd:
    ; Move to next row
    mov     rax, [rbp-8]
    mov     rax, [rax+16]
    mov     [rbp-8], rax
    jmp     .histogramOuterLoop
    
.histogramOuterLoopEnd:
    leave
    ret

; Function to compute cumulative histogram (running sum)
; Parameters:
;   rdi - Histogram array pointer
;   rsi - Cumulative histogram array pointer
; Returns:
;   eax - First non-zero cumulative value
computeCumulativeHistogram:
    push    rbp
    mov     rbp, rsp
    mov     [rbp-24], rdi   ; Store histogram array pointer
    mov     [rbp-32], rsi   ; Store cumulative histogram array pointer
    mov     dword [rbp-4], 0    ; Initialize first_nonzero
    mov     dword [rbp-8], 0    ; Initialize running sum
    mov     dword [rbp-12], 0   ; Initialize loop counter
    
; Process each histogram value (0-255)
.cumulativeLoop:
    cmp     dword [rbp-12], 255
    jg      .cumulativeLoopEnd
    
    ; Add current histogram value to running sum
    mov     eax, [rbp-12]
    cdqe
    lea     rdx, [rax*4]
    mov     rax, [rbp-24]
    add     rax, rdx
    mov     eax, [rax]
    add     [rbp-8], eax
    
    ; Store cumulative sum in output array
    mov     eax, [rbp-12]
    cdqe
    lea     rdx, [rax*4]
    mov     rax, [rbp-32]
    add     rdx, rax
    mov     eax, [rbp-8]
    mov     [rdx], eax
    
    ; Check if this is first non-zero value
    mov     eax, [rbp-12]
    cdqe
    lea     rdx, [rax*4]
    mov     rax, [rbp-24]
    add     rax, rdx
    mov     eax, [rax]
    test    eax, eax
    jz      .cumulativeNextTraversal
    
    cmp     dword [rbp-4], 0
    jne     .cumulativeNextTraversal
    mov     eax, [rbp-8]
    mov     [rbp-4], eax    ; Store first non-zero cumulative value
    
.cumulativeNextTraversal:
    add     dword [rbp-12], 1
    jmp     .cumulativeLoop
    
.cumulativeLoopEnd:
    mov     eax, [rbp-4]    ; Return first non-zero value
    pop     rbp
    ret

; Function to normalize CDF values and apply to image
; Parameters:
;   rdi - Image data pointer
;   rsi - CDF values array pointer
;   edx - First non-zero CDF value
;   ecx - Maximum CDF value (total pixel count)
normalizeCDFValues:
    push    rbp
    mov     rbp, rsp
    mov     [rbp-40], rdi   ; Store image data pointer
    mov     [rbp-48], rsi   ; Store CDF values pointer
    mov     [rbp-52], edx   ; Store first non-zero value
    mov     [rbp-56], ecx   ; Store maximum value
    mov     rax, [rbp-40]
    mov     [rbp-8], rax    ; Initialize outer loop pointer
    
; Outer loop traverses through image rows
.normalizeOuterLoop:
    cmp     qword [rbp-8], 0
    je      .normalizeOuterLoopEnd
    
    mov     rax, [rbp-8]
    mov     [rbp-16], rax   ; Initialize inner loop pointer
    
; Inner loop processes each pixel
.normalizeInnerLoop:
    cmp     qword [rbp-16], 0
    je      .normalizeInnerLoopEnd
    
    ; Get current grayscale value
    mov     rax, [rbp-16]
    movzx   eax, byte [rax+3]
    movzx   eax, al
    mov     [rbp-24], eax
    
    ; Compute normalized value using formula:
    ; normalized = (cdf[value] - cdf_min) * 255 / (max - min)
    mov     eax, [rbp-24]
    cdqe
    lea     rdx, [rax*4]
    mov     rax, [rbp-48]
    add     rax, rdx
    mov     eax, [rax]
    sub     eax, [rbp-52]
    mov     edx, eax
    mov     eax, edx
    sal     eax, 8
    sub     eax, edx
    mov     ecx, eax
    mov     eax, [rbp-56]
    sub     eax, [rbp-52]
    mov     esi, eax
    mov     eax, ecx
    cdq
    idiv    esi
    mov     [rbp-20], eax
    
    ; Clamp value between 0 and 255
    cmp     dword [rbp-20], 0
    jns     .upperBoundCheck
    mov     dword [rbp-20], 0
.upperBoundCheck:
    cmp     dword [rbp-20], 255
    jle     .pixelValuesUpdate
    mov     dword [rbp-20], 255
.pixelValuesUpdate:
    
    ; Update all channels with normalized value
    mov     eax, [rbp-20]
    mov     edx, eax
    mov     rax, [rbp-16]
    mov     [rax+3], dl     ; Update alpha
    mov     rax, [rbp-16]
    movzx   edx, byte [rax+3]
    mov     rax, [rbp-16]
    mov     [rax+2], dl     ; Update blue
    mov     rax, [rbp-16]
    movzx   edx, byte [rax+2]
    mov     rax, [rbp-16]
    mov     [rax+1], dl     ; Update green
    mov     rax, [rbp-16]
    movzx   edx, byte [rax+1]
    mov     rax, [rbp-16]
    mov     [rax], dl       ; Update red
    
    ; Move to next pixel
    mov     rax, [rbp-16]
    mov     rax, [rax+32]
    mov     [rbp-16], rax
    jmp     .normalizeInnerLoop
    
.normalizeInnerLoopEnd:
    ; Move to next row
    mov     rax, [rbp-8]
    mov     rax, [rax+16]
    mov     [rbp-8], rax
    jmp     .normalizeOuterLoop
    
.normalizeOuterLoopEnd:
    pop     rbp
    ret

; Main entry point function
; Parameter:
;   rdi - Image data pointer
computeCDFValues:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 2096       ; Allocate stack space for local arrays
    mov     [rbp-2088], rdi ; Store image data pointer
    
    ; Initialize histogram array to zeros
    lea     rdx, [rbp-1040]
    xor     eax, eax
    mov     ecx, 128
    mov     rdi, rdx
    rep stosq
    
    ; Initialize cumulative histogram array to zeros
    lea     rdx, [rbp-2064]
    xor     eax, eax
    mov     ecx, 128
    mov     rdi, rdx
    rep stosq
    
    mov     dword [rbp-2068], 0  ; Initialize total pixel count
    
    ; Step 1: Compute histogram of grayscale values
    lea     rdx, [rbp-2068]
    lea     rcx, [rbp-1040]
    mov     rax, [rbp-2088]
    mov     rsi, rcx
    mov     rdi, rax
    call    computeHistogram
    
    ; Step 2: Compute cumulative histogram
    lea     rdx, [rbp-2064]
    lea     rax, [rbp-1040]
    mov     rsi, rdx
    mov     rdi, rax
    call    computeCumulativeHistogram
    mov     [rbp-4], eax    ; Store first non-zero value
    
    ; Step 3: Normalize CDF values and apply to image
    mov     ecx, [rbp-2068]
    mov     edx, [rbp-4]
    lea     rsi, [rbp-2064]
    mov     rax, [rbp-2088]
    mov     rdi, rax
    call    normalizeCDFValues
    
    leave
    ret