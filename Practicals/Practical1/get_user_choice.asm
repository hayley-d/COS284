; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================
section .data
    choice_text db "Choice: ",0

section .bss
	user_input resb 1

section .text
    global get_user_choice

extern greeting             

get_user_choice:
    ; Call the greeting function to print the welcome message
    call greeting

    mov rax, 4
    mov rbx, 1
    mov rcx, choice_text
    mov rdx, 9
    int 0x80

   
    mov rax, 3
    mov rbx, 0
    mov rcx, user_input
    mov rdx, 1
    int 0x80	

    mov rax, 4
    mov rbx, 1
    mov rcx, user_input
    mov rdx, 1
    int 0x80
    
    ;mov rax, [user_input]
    ret
