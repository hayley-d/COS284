; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
    fmt db "%d ", 0
    user_req db "Enter plaintext to encrypt: ", 0
    hex_key equ 0x73113777
    result_message db "The cipher text is: ",0
    new_line_char db 0x0A
    space_char db 0x20

section .bss
	input_string resb 5
	input_length resq 1

section .text
    global encrypt_and_print

extern printf



encrypt_and_print:
    ; Ask user for input
    mov rax, 4
    mov rbx, 1
    mov rcx, user_req
    mov rdx, 29
    int 0x80

    mov rsi, rdi
    mov rdi, input_string
    mov rcx, 4
    rep movsb
    mov byte[input_string+4],0

    ;print user input
    mov rax,4
    mov rbx,1
    mov rcx,input_string
    mov rdx,4
    int 0x80
    
    ;print new line
    mov rax,4
    mov rbx,1
    mov rcx, new_line_char
    mov rdx,1
    int 0x80
    
    ;print response message
    mov rax,4
    mov rbx,1
    mov rcx,result_message
    mov rdx,21
    int 0x80

    mov rbx, input_string
    mov rcx, 4
    call encryption_loop
   
    ret

encryption_loop:    
    mov al, byte[rbx]
    movzx rdx, byte[rbx]
    test al,al 
    jz print_result	;if null terminate jump to the print func

    rol rdx,4
    mov rax, rdx
    xor eax, hex_key

    
    mov rsi, rax
    mov rdi, fmt
    xor rax, rax
    call printf
 
    ;go to the next character
    inc rbx
    jmp encryption_loop

print_result:
    ret
    
;When using the below function, be sure to place whatever you want to print in the rax register first
print_char_32:
    mov rsi, rax
    mov rdi, fmt
    xor rax, rax
    call printf
    ret

