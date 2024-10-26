; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; Group member 04: Name_Surname_student-nr
; Group member 05: Name_Surname_student-nr
; ==========================

section .data

struc Pixel
    .red:  resb 1                       ; Reserve 1 byte for Red, Green and Blue 
    .green: resb 1  
    .blue: resb 1
    .cdfValue: resb 1                   ; Reserve 1 byte for char
    align 8 
    .up: resq 1                         ; Reserve 1 qword for ptr
    .down: resq 1                       ; Reserve 1 qword for ptr
    .left: resq 1                       ; Reserve 1 qword for ptr
    .right: resq 1                      ; Reserve 1 qword for ptr
endstruc

p   dq  0                               ; Temp variable to hold the new allocated memory
fileDescriptor  dd 0                    
fileSize  dq 0                          
header dq  512                          ; Where data from the file is stored
format db 2                             ; Format (p6) is stored
height dd 0                             ; The height of the file
width dd 0                              ; The width of the file
maxColourValue dd 0                     ; The max colour value
list dq 0                               ; Pointer for the list

extern fgetc
extern fscanf
extern malloc
extern open
extern read
extern lseek
extern close
section .text
    global  readPPM

readPPM:
    mov [fileDescriptor], rdi    ; Store the file in the variable
    mov [width], rsi             ; Store the width
    mov [height], rdx            ; Store the height

    ; Linked List creation
    jmp create_list 

    mov rax, qword[list]                ; Load the pointer to the list into rax
    ret

; Function to create a new Pixel struc and return the pointer in the RAX register
createPixel:
; Set up stack frame
push rbp                
mov rbp, rsp
sub rsp, 64                             ; Reserve 64 bytes

; Get values for struct
mov [rsp + 0], rdi                      ; Store rdi = red
mov [rsp + 1], rsi                      ; Store rsi = green
mov [rsp + 2], rdx                      ; Store rdx = blue
mov [rsp + 3], rcx                      ; Store rcx = up ptr 
mov [rsp + 11], r8                      ; Store r8 = down ptr
mov [rsp + 19], r9                      ; Store r9 = left
mov [rsp + 27], r11                     ; Store r11 = right

; Allocate memory for the struct
mov r15, Pixel_size
xor rdi, rdi
mov rdi, Pixel_size 
call malloc
mov [p], rax                            ;save the pointer

; Store values in the struct
mov bl, byte[rsp + 0]                   ; Retrieve value for red
mov [rax + Pixel.red], bl               ; Store the value for red
mov bl, byte[rsp + 1]                   ; Retrieve value for green
mov [rax + Pixel.green], bl             ; Store the value for green 
mov bl, byte[rsp + 2]                   ; Retrieve value for blue
mov [rax + Pixel.blue], bl              ; Store the value for blue

mov bl, 0
mov [rax + Pixel.cdfValue], bl          ; Inital value for cdf value os 0
xor rbx, rbx

mov rbx, qword[rsp + 3]                 ; Retrieve ptr for up 
mov [rax + 8], rbx                      ; Store the address for up 
mov rbx, qword[rsp + 11]                ; Retrieve ptr for down 
mov [rax + 16], rbx                     ; Store the address for down 
mov rbx, qword[rsp + 19]                ; Retrieve ptr for left
mov [rax + 24], rbx                     ; Store the address for left
mov rbx, qword[rsp + 27]                ; Retrieve ptr for right 
mov [rax + 32], rbx                     ; Store the address for right 
mov rax, [p]                            ; Move ptr to the struct into rax
leave
ret

create_list:
    ; Assuming File is open and file, height, width and max should be stored.
    ; Set up stack frame
    push rbp                
    mov rbp, rsp
    sub rsp, 64                                     ; Reserve 64 bytes

    ; Allocate memory for list
    xor rdi, rdi                                    ; Make sure rdi is clear
    mov edi, dword[height]                        ; Load height into rdi
    imul edi, 8                                     ; Multiply height by 8 (Size of a pointer in bytes)
    call malloc
    mov [list], rax                                 ; Store the pointer to the list

    ; Allocate memory for each row
    xor rcx, rcx                                    ; Initialize counter to 0
    .loop:
        cmp ecx, dword[height]                      ; Check if in bounds
        je .end_loop                                ; If not in bounds end the loop
        xor rdi, rdi                                ; Clear the rdi
        mov edi, dword[width]                          ; Load the width into rdi
        imul edi, 8                                 ; Multiply by 8 (Size of a pointer in bytes)
        call malloc
        mov [list + ecx * 8], rax                   ; Store the pointer in the correct row
        inc rcx                                     ; Increment counter
        jmp .loop                                   ; Repeate loop
    .end_loop:

    ; Loop through rows
    xor rcx, rcx                                    ; Clear rcx register
    .loop_rows:
        cmp ecx, dword[height]                      ; Compare counter to height
        je .end_loop_rows                           ; End loop if out of bounds
        xor r14, r14                                ; Clear e14 (used as counter for second loop)
        .loop_columns:
            cmp r14, [width]                   ; Cpmapre counter to width
            je .end_loop_columns                    ; End loop if out of bounds

            mov [rsp + 0], rcx                      ; Store ecx to keep constant through function call
            mov [rsp + 4], r14                      ; Store e14 to keep constant through function call

            ; Get Red
            xor rdi,rdi
            mov edi, dword[fileDescriptor]        ; Load the file pointer into rdi
            call fgetc
            cmp rax, -1                             ; Test is EOF
            je .end_loop_rows                       ; Stop the loop
            mov [rsp + 8], rax                      ; Store red value on stack

            ; Get green
            xor rdi, rdi
            mov edi, dword[fileDescriptor]        ; Load file into rdi
            call fgetc
            cmp rax, -1
            je .end_loop_rows
            mov [rsp + 9], rax                      ; Store green

            ; Get blue
            xor rdi, rdi
            mov edi, dword[fileDescriptor]        ; Load file into rdi
            call fgetc
            cmp rax, -1
            je .end_loop_rows
            mov [rsp + 10], rax                     ; Store blue 

            ; Create Pixel
            movzx rdi, byte[rsp + 8]               ; Load Red into rdi for fuction call
            movzx rsi, byte[rsp + 9]                    ; Load Green into rsi
            movzx rdx, byte[rsp + 10]                   ; Load Blue into rdx
            mov rcx, 0                              ; Up ptr is NULL
            mov r8, 0                               ; Down ptr is NULL
            mov r9, 0                               ; Left ptr is NULL
            mov r11, 0                              ; Right ptr is NULL
            call createPixel
            xor r14, r14
            xor rcx, rcx
            mov r14, [rsp + 4]                    ; Load r14 from stack
            mov rcx, [rsp + 0]                    ; Load rcx from stack
            mov rbx, qword[list]
            mov rdi, qword[rbx + rcx * 8]           ; Load row
            mov [rdi + r14 * 8], rax                ; Store ptr to pixel

            ; Create Refrences
            test rcx, rcx                           ; If row > 0
            jz .no_up_ref
            mov rdi, [list]
            mov rdi, [rdi + rcx * 8 - 8]            ; list[row-1]
            mov rdi, [rdi + r14 * 8]                ; list[row-1][col]
            mov [rax + 8], rdi                      ; Store up pointer
            .no_up_ref:

            test r14, r14                           ; If col > 0
            jz .no_left_ref
            mov rdi, [list]
            mov rdi, [rdi + rcx * 8]                ; list[row]
            mov rdi, [rdi + r14 * 8 - 8]            ; list[row][col-1]
            mov [rax + 24], rdi                     ; Set left ptr             
            .no_left_ref:

            inc r14                                 ; Increment counter (inner loop)
            jmp .loop_columns                       ; Repeate loop columns
        .end_loop_columns:
        inc rcx                                     ; Increment counter (outer loop)
        jmp .loop_rows
    .end_loop_rows:

    ; Fill in the right and down references
    xor rcx, rcx                                    ; Clear outer loop counter
    .loop_ref_rows:
        cmp ecx, dword[height]                      ; Check if in bounds
        je .end_loop_ref_rows
        xor r14, r14                                ; Clear inner loop counter
        .loop_ref_columns:
            xor rdx,rdx
            mov edx, dword[width]
            cmp r14, rdx                            ; Check if in bounds
            je .end_loop_ref_columns
            
            mov rax, qword[list]                    ; Load the list
            mov rbx, [rax + rcx * 8]                ; Load list[row]
            mov rdx, [rbx + r14 * 8]                ; Load list[row][col]

            mov r11, [width]
            dec r11
            cmp r14, r11 
            je .no_right_link
            mov rsi, [rbx + r14 * 8 + 8]            ; Load list[row][col+1]
            mov [rdx + 32], rsi                     ; Set Right refrence
            .no_right_link:
            
            mov r11, [width]
            dec r11
            cmp rcx, r11                     
            je .no_down_link
            mov rsi, [rax + rcx * 8 + 8]            ; Load list[row+1]
            mov [rdx + 16], rsi                     ; Set down pointer
            .no_down_link:
            
            inc r14                                 ; Increment inner counter
            jmp .loop_ref_columns
        .end_loop_ref_columns:
        inc rcx                                     ; Increment outer counter
        jmp .loop_ref_rows
    .end_loop_ref_rows:
    ; Finished processing
    leave
    ret
