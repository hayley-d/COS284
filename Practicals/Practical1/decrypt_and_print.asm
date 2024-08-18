; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
    fmt db "%c", 0
    ;text_1 db "Enter cipher text to decrypt: ",0
    text_2 db "The plaintext is: ",0
    new_line_char db 0x0A
    hex_key equ 0x73113777

section .bss
    ciphertext resb 4 
    ;plaintext resb 4

section .text
global decrypt_and_print

extern printf

;When using the below function, be sure to place whatever you want to print in the rax register first
print_char_32:
    mov rsi, rax
    mov rdi, fmt
    xor rax, rax
    call printf
    ret

decrypt_and_print:
    mov rax, 4
    mov rbx, 1
    mov rcx, text_2
    mov rdx, 18
    syscall

    mov ecx, 0
    mov eax, dword[edi]
    mov [ciphertext], eax
    mov ebx, 0x73113777
    xor rax, rax

    call decrypt_loop

    mov rax, 4
    mov rbx, 1
    mov rcx, new_line_char
    mov rdx, 2
    syscall

   ret

decrypt_loop:
    mov al, byte[ciphertext+ecx]	;load byte from ciphertext
    test al,al	;check if null term
    jz decrypt_end

    xor eax, ebx
    ror eax, 4
;    call print_char_32
    mov rsi, rax
    mov rdi, fmt
    xor rax, rax
    call printf
 
    inc ecx
    jmp decrypt_loop

decrypt_end:
    ret
