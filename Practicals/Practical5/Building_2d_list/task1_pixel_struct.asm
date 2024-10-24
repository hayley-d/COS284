
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

width   dd  0                           ; Variable to store width
height  dd  0                           ; Variable to store height
file    dq  0                           ; Reserve space for the file piointer
p       dq  0                           ; Temp variable to hold the new allocated memory
list    dq  0                           ; Pointer to the list

; External c functions
extern fopen
extern fscanf
extern fclose
extern printf
extern malloc
section .text
    global  _start 

_start:
; File is opend and header is read

    xor rdi, rdi

    ; Allocate memory for the columns
    mov rdi, [height]                   ; Move the height into the rax
    imul rdi, 8                         ; Multiply by 8 (size of a pointer)
    call malloc
    mov [list], rax                     ; Store the pointer to the list

    ; Allocate memory for each row
    xor rcx, rcx                        ; Counter initialzed to 0
    .loop:
        cmp rcx, [height]
        je .end_loop 
        mov rdi, [width]                ; Store width in rdi
        imul rdi, 8                     ; Multiply by 8
        call malloc
        mov rdx, [list]                 ; Load the list pointer
        mov [rdx + rcx * 8], rax        ; Store the column pointer in the row
        inc rcx                         ; Increment the counter
        jmp .loop                       ; Repeate

    .end_loop:

    ; Loop through rows 
    xor rcx, rcx                        ; Initialize counter to 0
    .loop_rows:
        cmp rcx, [height]               ; Check if finished loop
        je .end_loop_rows
        xor r14, r14                    ; Reset row counter
        .loop_columns:
            cmp r14, [width]            ; Check if finished rows
            je .end_loop_columns
            ; Processing
            inc r14                     ; Increment column counter
            jmp .loop_columns
        .end_loop_columns:
        inc rcx                         ; Increment row counter
        jmp .loop_rows
    .end_loop_rows:  

    ; Fill in the right and down references
    xor rcx, rcx                        ; Initialize counter to 0
    .loop2_rows:
        cmp rcx, [height]               ; Check if finished
        je .end_loop2_rows              ; Break loop
        xor r14, r14                    ; Initialize counter to 0
        .loop2_columns:
            cmp r14, [width]            ; Check if finshed
            je .end_loop2_columns       ; Break loop
            ; Processing
            inc r14                     ; Increment counter
            jmp .loop2_columns          ; loop
        .end_loop2_columns:
        int rcx                         ; Increment counter
        jmp .loop2_rows
    .end_loop2_rows:

    ; Close the file



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

