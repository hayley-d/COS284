; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
	welcome_message db "Welcome agent. What do you want to do, Encrypt [1] or Decrypt [2]?", 0x0A, 0

section .text
    global greeting

greeting:
    mov rax, 4	;sys call for a write
    mov rbx, 1	;1==stdout
    mov rcx, welcome_message
    mov rdx, 68
    int 0x80	;make sys call

    mov rax, 0
    ret
