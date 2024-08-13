; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .bss
	user_input resb 1

section .text
    global get_user_choice

extern greeting             

get_user_choice:
    ; Call the greeting function to print the welcome message
    call greeting
    
    mov eax, 3	;sys call for read
    mov ebx, 0  ; 0==stdin
    mov ecx, user_input
    mov edx, 1
    int 0x80	;make call
    ret
