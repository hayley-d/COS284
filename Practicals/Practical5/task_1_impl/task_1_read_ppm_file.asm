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


extern fscanf
extern malloc
extern open
extern read
extern lseek
extern close
section .text
    global  readPPM

readPPM:
    ; Open file
    mov rax, 2                          ; 2 for Open
    mov rsi, 0                          ; read only
    syscall                             ; Call system
    mov [fileDescriptor], eax           ; Store file descriptor    
    
    ; Read file
    mov rdi , rax                       ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store file in header
    mov rdx, 512                        ; Load 512 bytes into header
    syscall                             ; Call system

    cmp eax , 0                         ; Check value
    jl .nullReturn                      ; Return NULL

    ; Get size of file
    mov edi , [fileDescriptor]          ; Move file descriptor
    mov rsi , 0                         ; Offset equal to 0
    mov rdx , 2                         ; Whence equal to 2 (End of file)
    call lseek                          ; System call to lseek
    mov [fileSize] , rax                ; Store file size

    ; Reset Offset
    mov edi , [fileDescriptor]          ; Move file descriptor
    mov rsi , 0                         ; Offset equal to 0
    mov rdx , 0                         ; Whence equal to 0 (Start of file)
    call lseek

    mov rcx , -1                        ; Set index
    mov rbx , 0                         
    ; Values are already 0?
    ;mov dword[width] , 0                ; Initialize fields to 0
    ;mov dword[height] , 0
    ;mov dword[maxColourValue] , 0
    ;jmp .getFormat                     ; No need to jump here?
    
.getFormat
    inc rcx                             ; Increment to next byte
    mov al, [header+rcx]                ; Load byte into AL
    cmp al, 0x0A                           
    je .getWidth                        ; If byte is a newline, go to getWidth

    cmp al,'#'                          ; Hashtag -> skip line
    je .formatComment

    mov [format+rbx],al                 ; Load AL into format
    
    inc rbx                             ; Increment to next byte in the format
    jmp .getFormat                      ; Loop

.formatComment:
    inc rcx                             ; Increment to next byte
    mov al, [header+rcx]                ; Load byte into AL

    cmp al, 0x0A                           ; If byte is a newline, go to getFormat  
    je .getFormat

    jmp .formatComment

.getWidth:
    inc rcx                             ; Increment to next byte
    mov al, [header+rcx]                ; Load byte into AL

    cmp al , 0x0A                       ; If byte is not a digit, go to getHeight
    je .getHeight
    cmp al , 0x20
    je .getHeight
    cmp al , '0'                        ; If byte is not a digit, go to getHeight
    jb .getHeight
    cmp al , '9'
    ja .getHeight

    sub al, '0'                         ; Convert to integer

    mov eax, [width]                    ; Multiply currnet width by 10, to allow new digit
    imul eax, eax, 10
    mov [width], eax

    mov al, [header+rcx]                ; Reload byte into AL
    sub al, '0'                     
    add [width], al                     ; Add AL to width
    
    jmp .getWidth                       ; Loop

.getHeight
    inc rcx                             ; Increment to next byte
    mov al, [header+rcx]                ; Load byte into AL

    cmp al , 0x0A                       ; If byte is not a digit, go to getMax
    je .getMax
    cmp al , 0x20
    je .getMax
    cmp al , '0'                        ; If byte is not a digit, go to getMax
    jb .getMax
    cmp al , '9'
    ja .getMax

    sub al, '0'                         ; Convert to integer

    mov eax, [height]                    ; Multiply currnet width by 10, to allow new digit
    imul eax, eax, 10
    mov [height], eax

    mov al, [header+rcx]                ; Reload byte into AL
    sub al, '0'                     
    add [height], al                     ; Add AL to width
    
    jmp .getHeight                       ; Loop


.getMax
    inc rcx                             ; Increment to next byte
    mov al, [header+rcx]                ; Load byte into AL

    cmp al , 0x0A                       ; If byte is not a digit, go to getMax
    je .validate
    cmp al , 0x20
    je .validate
    cmp al , '0'                        ; If byte is not a digit, go to getMax
    jb .validate
    cmp al , '9'
    ja .validate

    sub al, '0'                         ; Convert to integer

    mov eax, [maxColourValue]                    ; Multiply currnet width by 10, to allow new digit
    imul eax, eax, 10
    mov [maxColourValue], eax

    mov al, [header+rcx]                ; Reload byte into AL
    sub al, '0'                     
    add [maxColourValue], al                     ; Add AL to width
    
    jmp .getMax                       ; Loop

.validate:
    ; Validate Metadata
    cmp dword[width] , 0                 ; Check width
    jl .nullReturn                       ; Return NULL

    cmp dword[height] , 0                ; Check height
    jl .nullReturn                       ; Return NULL

    cmp dword[maxColourValue] , 0        ; Check maxColourValue
    jl .nullReturn                       ; Return NULL


    ; Linked List creation
    jmp create_list 

    ; Close file
    mov rdi , [fileDescriptor]          ; Mov the file descriptor     
    call close                          ; Close file

    ;mov rax , headptr
    ret

.nullReturn:
    mov rax, 0                          ; Return NULL
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
    mov rdi, dword[height]                          ; Load height into rdi
    imul rdi, 8                                     ; Multiply height by 8 (Size of a pointer in bytes)
    call malloc
    mov [list], rax                                 ; Store the pointer to the list

    ; Allocate memory for each row
    xor rcx, rcx                                    ; Initialize counter to 0
    .loop:
        cmp ecx, dword[height]                      ; Check if in bounds
        je .end_loop                                ; If not in bounds end the loop
        xor rdi, rid                                ; Clear the rdi
        movzx rdi, dword[width]                     ; Load the width into rdi
        imul rdi, 8                                 ; Multiply by 8 (Size of a pointer in bytes)
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
            cmp e14, dword[width]                   ; Cpmapre counter to width
            je .end_loop_columns                    ; End loop if out of bounds

            mov [rsp + 0], rcx                      ; Store ecx to keep constant through function call
            mov [rsp + 4], r14                      ; Store e14 to keep constant through function call

            ; Get Red
            mov rdi, qword[file]                    ; Load the file pointer into rdi
            call fgetc
            cmp rax, -1                             ; Test is EOF
            je .end_loop_rows                       ; Stop the loop
            mov [rsp + 8], rax                      ; Store red value on stack

            ; Get green
            mov rdi, qword[file]                    ; Load file into rdi
            call fgetc
            cmp rax, -1
            je .end_loop_rows
            mov [rsp + 9], rax                      ; Store green

            ; Get blue
            mov rdi, qword[file]                    ; Load file into rdi
            call fgetc
            cmp rax, -1
            je .end_loop_rows
            mov [rsp + 10], rax                     ; Store blue 

            ; Create Pixel
            movzx rdi, [rsp + 8]                    ; Load Red into rdi for fuction call
            movzx rsi, [rsp + 9]                    ; Load Green into rsi
            movzx rdx, [rsp + 10]                   ; Load Blue into rdx
            mov rcx, 0                              ; Up ptr is NULL
            mov r8, 0                               ; Down ptr is NULL
            mov r9, 0                               ; Left ptr is NULL
            mov r11, 0                              ; Right ptr is NULL
            call createPixel
            movzx r14, [rsp + 4]                    ; Load r14 from stack
            movzx rcx, [rsp + 0]                    ; Load rcx from stack
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
            cmp e14, dword[width]                   ; Check if in bounds
            je .end_loop_ref_columns
            
            mov rax, qword[list]                    ; Load the list
            mov rbx, [rax + rcx * 8]                ; Load list[row]
            mov rdx, [rbx + r14 * 8]                ; Load list[row][col]
            
            cmp r14, [width]-1
            je .no_right_link
            mov rsi, [rbx + r14 * 8 + 8]            ; Load list[row][col+1]
            mov [rdx + 32], rsi                     ; Set Right refrence
            .no_right_link:
            
            cmp rcx, [height]-1                     
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
