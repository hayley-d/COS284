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
    mov rdx,4
    int 0x80
    
    ;print response message
    mov rax,4
    mov rbx,1
    mov rcx,result_message
    mov rdx,21
    int 0x80

    mov ecx, 0  
    xor rax,rax
    call encryption_loop

    ret

encryption_loop:    
    movzx rax, byte[input_string+ecx]
    test al,al 
    jz print_result	;if null terminate jump to the print func

    rol rax, 4
    xor rax,0x73113777

    ; print char function
    mov rsi, rax
    mov rdi, fmt
    xor rax, rax
    call printf
 
    ;go to the next character
    inc ecx
    jmp encryption_loop

print_result:
    ret

