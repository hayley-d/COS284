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
	input_string resb 4
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
    ; Ask user for input
    mov rax, 4
    mov rbx, 1
    mov rcx, user_req
    mov rdx, 29
    int 0x80

    ; get input string
    mov rax, 3
    mov rbx, 0
    mov rcx, input_string
    mov rdx, 4
    int 0x80

    ; add null terminator
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

    ;call encrypt_plaintext
    mov rcx, 0  ;length of input string
;    mov rsi, input_string
    xor rax,rax
    mov rbx, 0x73113777
    call encryption_loop

    ret

encryption_loop:    
    ; move first char into al
    mov al, byte[input_string+rcx]
    ; check if null terminator
    test al,al 
    jz print_result	;if null terminate jump to the print func

    rol eax, 4
    xor eax,ebx
;    call print_char_32
    mov rsi, rax
    mov rdi, fmt
    xor rax, rax
    call printf
 
    ;go to the next character
    inc rcx
    jmp encryption_loop

print_result:
    mov rax, 0
    ret

