; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
struc Student
    .id:  resd 1 ; 32-bit student id -- 4 bytes
    .name: resb 64 ;64-bit name -- 16 bytes
    align 8 
    .gpa: resd 1  ;32-bit gpa
    align 8 
endstruc
s   dq  0   ; hold a pointer of type Student
id: dd 0
arr: dq 0

extern malloc
extern strcpy
extern createStudent
section .text
    global addStudent

addStudent:
push rbp
mov rbp, rsp
sub rsp, 64
mov [rsp + 0], rdi    ;move array pointer
mov [rsp + 8], rsi   ;store size
mov [rsp + 12], rdx   ;store name
movss [rsp + 20], xmm0 ;store gpa
mov r9, rsi
dec r9
mov [id], r9    ;store id
xor rdi, rdi
mov rdi, Student_size 
call malloc
mov [s], rax    ;save the pointer   
mov ebx, [id] 
mov [rax + Student.id], ebx ;move value of in_id into id]
lea rdi, qword[rax + Student.name]
mov rsi, qword[rsp + 12]
call strcpy
mov rax, [s]
movss xmm0, [rsp + 20]
movss [rax + Student.gpa], xmm0
mov r9, [id]
dec r9
mov rbx, [rsp + 0]
mov [rbx + r9*8], rax  ;add student to the end

leave
ret
