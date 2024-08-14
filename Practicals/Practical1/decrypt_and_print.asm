; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
    fmt db "%c", 0
    text_1 db "Enter cipher text to decrypt: ",0
    text_2 db "The plaintext is: ",0
    new_line_char db 0x0A
    hex_key equ 0x73113777

section .bss
    ciphertext resb 200
    plaintext resb 100

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
    ;prompt for cipher
    mov rax, 4
    mov rbx, 1
    mov rcx, text_1
    mov rdx,30
    int 0x80

    ;read user input
    mov rax, 3
    mov rbx, 0
    mov rcx, ciphertext
    mov rdx, 200
    int 0x80

    call decrypt_cipher

    mov rax, 4
    mov rbx, 1
    mov rcx, text_2
    mov rdx, 18
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, new_line_char
    mov rdx, 2
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, plaintext 
    mov rdx, 100
    int 0x80
    ret

decrypt_cipher:
    mov rsi, ciphertext
    mov rdi, plaintext
    call decrypt_loop

decrypt_loop:
    mov al, byte[rsi]	;load byte from ciphertext
    test al,al	;check if null term
    jz decrypt_end

    xor al, hex_key
    ror al, 4
    mov byte[rdi], al

    inc rsi
    inc rdi
    jmp decrypt_loop

decrypt_end:
    mov byte [rdi], 0
    ret
