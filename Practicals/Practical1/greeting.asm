
section .data
    welcome_message db "Welcome agent. What do you want to do, Encrypt [1] or Decrypt [2]?", 0x0A, 0

section .bss
    user_input resb 1

section .text
    global_start

_start:
    mov eax, 4  ;system call for write
    mov ebx, 1  ;file descriptor 1 = stdout
    mov ecx, welcome_message
    mov edx, 63 ;length of the message
    int 0x80    ; make system call

    mov eax, 3  ;system call for read
    mov ebx, 0 ;file desc for stdin
    mov ecx, user_input
    mov edx, 1 ;number of bytes to read
    int 0x80

    mov eax, 1
    xor ebx, ebx
    int 0x80