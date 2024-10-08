; ==========================
; Group member 01: Hayley_Dodkins_u21528790
; ==========================

section .data
in_id  dd  0;
in_name dq 0;
in_gpa dd 0;
    struc Student
id  resd 1 ; 32-bit student id
name resq 1 ;64-bit name
gpa resd q  ;32-bit gpa
    endstruc
s   dq  0   ; hold a pointer of type Student

extern malloc
section .text
    global createStudent

createStudent:
;get params into variables
mov [in_id], dword[rdi]    ;move param 1 into id
lea [in_name], [rsi] ;move param 2 into name variable
move [in_gpa], dword[rdx]  ;move param 3 into variable
mov rdi, Student_size
call malloc
mov [s], rax    ;save the pointer
mov [rax+id], [in_id] ;move value of in_id into id]
mov [rax+name], [in_name] ;move the value of the name into name
mov [rac+gpa], [in_gpa] ;store the gpa
ret

