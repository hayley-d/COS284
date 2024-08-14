; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
    fmt db "%c", 0
    user_req db "Enter plaintext to encrypt: ", 0
    hex_num equ 0x73113777
    result_message db "The cipher text is: ",0
    new_line_char db 0x0A

section .bss
	input_string resb 100	;reserve 100 bytes for the input string
	encryption_string resb 100
	input_length resq 1

section .text
    global encrypt_and_print

extern printf

;When using the below function, be sure to place whatever you want to print in the rax register first
print_char_32:
    mov rsi, rax
    mov rdi, fmt
    xor rax, rax
    call printf
    ret

encrypt_and_print:
    ; Print input req string
    mov rax, 4
    mov rbx, 1
    mov rcx, user_req
    mov rdx, 29
    int 0x80

    ; make sys in call
    mov rax, 3
    mov rbx, 0
    mov rcx, input_string
    mov rdx, 100
    int 0x80

    mov [input_length],rax
    mov byte[input_string + rax],0

    ;print user input
    mov rax,4
    mov rbx,1
    mov rcx,input_string
    mov rdx,[input_length]
    int 0x80

    ;add new line char
    mov rax,4
    mov rbx,1
    mov rcx,new_line_char
    mov rdx,1
    int 0x80

    ;print response message
    mov rax,4
    mov rbx,1
    mov rcx,result_message
    mov rdx,21
    int 0x80

    call encrypt_plaintext

    mov rax,1
    mov rbx,0
    int 0x80
    ret

encrypt_plaintext:
    mov rsi, input_string
    mov rdi, encryption_string
    mov rax, [hex_num]
    jmp encryption_loop

encryption_loop:    
    mov al,byte [rsi]
    test al, al
    jz print_result	;if null terminate jump to the print func

    rol al, 4
    xor al,[hex_num]
    mov byte [rdi], al	;store in the encrypted_string

    ;go to the next character
    inc rsi
    inc rdi
    jmp encryption_loop

print_result:
    mov byte[rdi],0x00
    ;print encrypted string
    mov rbx, 1
    mov rcx, encryption_string
    mov rdx, [input_string]
    mov rax, 4
    int 0x80

    ret

