; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
	welcome_message db "Welcome agent. What do you want to do, Encrypt [1] or Decrypt [2]?", 0x0A, 0

section .text
    global greeting

greeting:
    mov eax, 4	;sys call for a write
    mov ebx, 1	;1==stdout
    mov ecx, welcome_message
    mov edx, 63
    int 0x80	;make sys call
	
    ret                         ; return from function
