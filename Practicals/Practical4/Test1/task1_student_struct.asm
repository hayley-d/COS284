; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
in_id  dd  0;
in_name dq 0;
in_gpa dd 0;
struc Student
    .id:  resd 1 ; 32-bit student id -- 4 bytes
    .name: resb 64 ;64-bit name -- 16 bytes
    align 8 
    .gpa: resd 1  ;32-bit gpa
    align 8 
endstruc
s   dq  0   ; hold a pointer of type Student

extern strcpy
extern malloc
section .text
    global createStudent

createStudent:
push rbp
mov rbp, rsp
sub rsp, 64
mov [rsp + 0], rdi
mov [rsp + 4], rsi
movss [rsp + 12], xmm0
;get params into variables
;mov dword[in_id], edi    ;move param 1 into id
;mov [in_name], rsi ;move param 2 into name variable
;movss dword[in_gpa], xmm0 ;move param 3 into variable
xor rdi, rdi
mov rdi, Student_size 
call malloc
mov [s], rax    ;save the pointer
mov ebx, dword[in_id]
mov [rax + Student.id], ebx ;move value of in_id into id]
lea rdi, qword[rax + Student.name]
mov rsi, qword[rsp + 4]
call strcpy
mov rax, [s]

movss xmm0, [rsp + 12]
movss [rax + Student.gpa], xmm0
mov rax, [s]
leave
ret

