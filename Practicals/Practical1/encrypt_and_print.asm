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

    ret

get_plaintext:
    mov eax, 4
    mov ebx, 1
    mov ecx, user_req
    mov edx, 25
    int 0x80
    ret

get_plaintext_input:
    mov eax, 3
    mov ebx, 0
    mov ecx, input_string
    mov edx, 100
    int 0x80
    mov esi, input_string	;move the string into the esi
    ;get the end of the string

find_null_term:
    mov al, [esi]
    cmp al, 0		;check if end of string
    je append_newline	;if found append newline
    inc esi		;increment ptr
    jmp find_null_term	;repeate until found \0

append_newline:
    mov byte[esi], 0x0A	;append newline char
    mov byte[esi + 1], 0
    ret
encrypt_plaintext:
    mov esi, input_string
    mov edi, encryption_string
    mov eax, [hex_num]

encryption_loop:    
    mov al, [esi]
    test al, al
    jz print_result	;if null terminate jump to the print func

    rol al, 4
    xor al, byte [eax]
    mov byte [edi], al	;store in the encrypted_string

    ;go to the next character
    inc esi
    inc edi
    jmp encryption_loop

print_result:
    mov byte [edi], 0 ;add null terminator
    mov eax, 4	      ;sys write call
    mov ebx, 1	      ; 1 == stdout
    mov ecx, result_message
    mov edx, 21
    int 0x80

    mov eax, 4
    mov ebx, 1
    mov ecx, encryption_string
    mov edx, 100
    int 0x80

    ret


