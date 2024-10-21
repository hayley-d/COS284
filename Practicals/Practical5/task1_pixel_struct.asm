
section .data

struc Pixel
    .red:  resb 1       ; Reserve 1 byte for Red, Green and Blue 
    .green: resb 1  
    .blue: resb 1
    .cdfValue: resb 1   ; Reserve 1 byte for char
    align 8
    .up: resq 1         ; Reserve 1 qword for ptr
    .down: resq 1       ; Reserve 1 qword for ptr
    .left: resq 1       ; Reserve 1 qword for ptr
    .right: resq 1      ; Reserve 1 qword for ptr
    align 8 
endstruc

p   dq  0               ; Temp variable to hold the new allocated memory

extern strcpy
extern malloc
section .text
    global  createPixel 

createPixel:
; Set up stack frame
push rbp                
mov rbp, rsp
sub rsp, 64             ; Reserve 64 bytes

; Get values for struct
mov [rsp + 0], rdi      ; Store rdi = red
mov [rsp + 1], rsi      ; Store rsi = green
mov [rsp + 2], rdx      ; Store rdx = blue
mov [rsp + 3], rcx      ; Store rcx = up ptr 
mov [rsp + 11], r8      ; Store r8 = down ptr
mov [rsp + 19], r9      ; Store r9 = left
mov [rsp + 27], r11     ; Store r11 = right

; Allocate memory for the struct
xor rdi, rdi
mov rdi, Pixel_size 
call malloc
mov [p], rax    ;save the pointer

; Store values in the struct
mov bl, byte[rsp + 0]                  ; Retrieve value for red
mov [rax + Pixel.red], bl              ; Store the value for red
mov bl, byte[rsp + 1]                  ; Retrieve value for green
mov [rax + Pixel.green], bl              ; Store the value for green 
mov bl, byte[rsp + 2]                  ; Retrieve value for blue
mov [rax + Pixel.blue], bl             ; Store the value for blue

mov bl, 0
mov [rax + Pixel.cdfValue], bl         ; Inital value for cdf value os 0

mov rbx, qword[rsp + 3]                 ; Retrieve ptr for up 
mov [rax + Pixel.up], rbx               ; Store the address for up 
mov rbx, qword[rsp + 11]                ; Retrieve ptr for down 
mov [rax + Pixel.down], rbx             ; Store the address for down 
mov rbx, qword[rsp + 19]                ; Retrieve ptr for left
mov [rax + Pixel.left], ebx             ; Store the address for left
mov rbx, qword[rsp + 27]                ; Retrieve ptr for right 
mov [rax + Pixel.right], ebx            ; Store the address for right 
mov rax, [p]                            ; Move ptr to the struct into rax
leave
ret

