; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
    fmt db "%c", 0
    user_req db "Enter plaintext to encrypt:", 0
    hex_num dd 0x73113777
    result_message db "The cipher text is: ",0

section .bss
	input_string resb 100	;reserve 100 bytes for the input string
	encryption_string resb 100

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
    ; ask the user for an input string
    call get_plaintext
    call get_plaintext_input
    call encrypt_plaintext
    ret

get_plaintext:
    mov rax, 4
    mov rbx, 1
    mov rcx, user_req
    mov rdx, 25
    int 0x80
    ret

get_plaintext_input:
    mov rax, 3
    mov rbx, 0
    mov rcx, input_string
    mov rdx, 100
    int 0x80
    mov rsi, input_string	;move the string into the rsi
    ;get the end of the string
    call find_null_term

find_null_term:
    mov al, [rsi]
    cmp al, 0		;check if end of string
    je append_newline	;if found append newline
    inc rsi		;increment ptr
    jmp find_null_term	;repeate until found \0

append_newline:
    mov byte[rsi], 0x0A	;append newline char
    mov byte[rsi + 1], 0
    ret

encrypt_plaintext:
    mov rsi, input_string
    mov rdi, encryption_string
    mov rax, [hex_num]
    jmp encryption_loop

encryption_loop:    
    mov al, [rsi]
    test al, al
    jz print_result	;if null terminate jump to the print func

    cmp al, 0x0A	;compare to \n
    je skip_newline

    rol al, 4
    xor al, byte [rax]
    mov byte [rdi], al	;store in the encrypted_string

    ;go to the next character
    inc rsi
    inc rdi
    jmp encryption_loop

skip_newline:
    inc rsi
    jmp encryption_loop

print_result:
    mov byte [rdi], 0 ;add null terminator
    mov rax, 4	      ;sys write call
    mov rbx, 1	      ; 1 == stdout
    mov rcx, result_message
    mov rdx, 21
    int 0x80

    mov rax, 4
    mov rbx, 1
    mov rcx, encryption_string
    mov rdx, 100
    int 0x80

    ret


