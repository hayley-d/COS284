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
format db 'P3', 0                             ; Format (p6) is stored
height dd 0                             ; The height of the file
width dd 0                              ; The width of the file
maxColourValue dd 0                     ; The max colour value
list dq 0                               ; Pointer for the list
red db 0
green db 0
blue db 0
outerCounter dq 0
innerCounter dq 0

extern createPixel
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
    mov rdx, 1                          ; Load 512 bytes into header
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
     
    lea rsi , [header]                  
    mov dword[width] , 0                ; Initialize fields to 0
    mov dword[height] , 0
    mov dword[maxColourValue] , 0
    jmp .getFormat
    
; Loop until a character that can be the format is found
.getFormat
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store file in header
    mov rdx, 1                          ; Load byte into header
    syscall                                

    mov al, [header]                    ; Load byte into AL

    cmp al, 32  
    je .getFormat                       ; If byte is a space, loop

    cmp al, 35  
    je .formatComment                   ; If byte is a hashtag, go to next line

    jmp .fixFormat                      ; Byte cointains the format so store value

.formatComment:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall                           
    
    mov al, [header]                    ; Load byte into AL

    cmp al, 10
    je .getFormat                       ; If byte is new line, go back to getFormat

    jmp .formatComment                  ; Loop

; Add format
.fixFormat:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall                                

    mov al, [header]                    ; Load AL into format
    mov [format+1], al                  ; Load format  number (PPM can only be P6 or P3)                              
    mov byte [format+2], 0              ; Add null to format

    jmp .getWidth                       ; Get Width

; Find width
.getWidth:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall   

    mov al, [header]                    ; Load byte into AL

    cmp al, 45                          ; Negative sign, return 0 and close file
    je .nullReturn

    cmp al,48                           ; If byte is a below 0, loop
    jb .getWidth

    cmp al,57                           ; If byte is above 9, loop
    ja .getWidth

    jmp .storeWidth                     ; Character is a digit so store width

; Handle comment (Loop until newline)
.widthComment:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall                           
    
    mov al, [header]                    ; Load byte into AL

    cmp al, 10
    je .getWidth                       ; If byte is new line, go back to getWidth

    jmp .widthComment 

; Store Width (Loop until byte is not a digit)
.storeWidth
    mov al, [header]                    ; Load byte into AL
    
    cmp al , 32                         ; If byte is not a digit, go to getHeight
    je .setUpHeight
    cmp al , 10                         
    je .setUpHeight
    cmp al , 13
    je .setUpHeight
    cmp al , '0'                        
    jb .setUpHeight
    cmp al , '9'
    ja .setUpHeight 

    sub al, '0'                         ; Convert to integer

    mov eax, [width]                    ; Multiply currnet width by 10, to allow new digit
    imul eax, eax, 10
    mov [width], eax

    mov al, [header]                    ; Reload byte into AL
    sub al, '0'                         ; Convert to integer
    add [width],al                      ; Add AL to width
   
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall   

    jmp .storeWidth                     ; Loop

.setUpHeight:
    mov dword[height] , 0               ; Initialize height to 0 (Safety)
    jmp .getHeight

; Find Height
.getHeight:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall               

    mov al, [header]                    ; Load byte into AL

    cmp al, 45                          ; Negative sign , return 0 and close file
    je .nullReturn

    cmp al,48                           ; If byte is a below 0, loop
    jb .getHeight

    cmp al,57                           ; If byte is above 9, loop
    ja .getHeight

    jmp .storeHeight                   ; Character is a digit so store height

; Handle comment for height
.heightComment:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall                           
    
    mov al, [header]                    ; Load byte into AL

    cmp al, 10
    je .getHeight                       ; If byte is new line, go back to getHeight

    jmp .heightComment 

; Store height
.storeHeight
    mov al, [header]                    ; Load byte into AL
    
    cmp al , 32                         ; If byte is not a digit, go to getHeight
    je .getMax
    cmp al , 10                       
    je .getMax
    cmp al , 13
    je .getMax
    cmp al , '0'                        
    jb .getMax
    cmp al , '9'
    ja .getMax 

    sub al, '0'                         ; Convert to integer

    mov eax, [height]                   ; Multiply currnet height by 10, to allow new digit
    imul eax, eax, 10
    mov [height], eax

    mov al, [header]                    ; Reload byte into AL
    sub al, '0'                         ; Convert to integer
    add [height],al                     ; Add AL to height
   
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall   
    jmp .storeHeight                    ; Loop

; Find Max
.getMax:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall                             

    mov al, [header]                    ; Load byte into AL

    cmp al, 45                          ; Negative sign, so return 0 and close file
    je .nullReturn

    cmp al,48                           ; If byte is below 0, loop
    jb .getMax

    cmp al,57                           ; If byte is above 9, loop
    ja .getMax

    jmp .storeMax                       ; Character is not space so store max

; Handle max comment
.maxComment:
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall                           
    
    mov al, [header]                    ; Load byte into AL

    cmp al, 10
    je .getMax                          ; If byte is new line, go back to getMax

    jmp .maxComment 

; Store Max
.storeMax
    mov al, [header]                    ; Load byte into AL
    
    cmp al , 32                         ; If byte is not a digit, go to finish
    je .finishMetadata
    cmp al , 10                         
    je .finishMetadata
    cmp al , 13
    je .finishMetadata
    cmp al , '0'                        
    jb .finishMetadata
    cmp al , '9'
    ja .finishMetadata 

    sub al, '0'                         ; Convert to integer

    mov eax, [maxColourValue]           ; Multiply currnet max by 10, to allow new digit
    imul eax, eax, 10
    mov [maxColourValue], eax

    mov al, [header]                    ; Reload byte into AL
    sub al, '0'                     
    add [maxColourValue],al             ; Add AL to max
   
    mov rdi , [fileDescriptor]          ; Load file descriptor
    mov rax, 0                          ; 0 for Read
    mov rsi, header                     ; Store byte in header
    mov rdx, 1                          ; Load byte into header
    syscall   
    jmp .storeMax                       ; Loop

.finishMetadata:
    ; Linked List creation

    jmp create_list
    ; Close file
    mov rdi , [fileDescriptor]          ; Mov the file descriptor     
    call close                          ; Close file

    
    ret

.nullReturn:
    mov rdi , [fileDescriptor]          ; Mov the file descriptor     
    call close                          ; Close file
    mov rax, 0                          ; Return NULL
    ret



create_list:
    ; Assuming File is open and file, height, width and max should be stored.
    ; Set up stack frame
    push rbp                
    mov rbp, rsp
    sub rsp, 64                                     ; Reserve 64 bytes

    ; Allocate memory for list
    xor rdi, rdi                                    ; Make sure rdi is clear
    mov edi, dword[height]                          ; Load height into rdi
    imul edi, 8                                     ; Multiply height by 8 (Size of a pointer in bytes)
    call malloc
    mov [list], rax                                 ; Store the pointer to the list

    ; Allocate memory for each row
    xor rcx, rcx                                    ; Initialize counter to 0
    .loop:
        cmp ecx, [height]                           ; Check if in bounds
        je .end_loop                                ; If not in bounds end the loop
        xor rdi, rdi                                ; Clear the rdi
        mov edi, [width]                            ; Load the width into rdi
        imul edi, 8                                 ; Multiply by 8 (Size of a pointer in bytes)
        ;mov [rsp + 0], rcx
        mov [outerCounter], rcx
        call malloc
        ;mov rcx, [rsp + 0]
        mov rcx, [outerCounter]
        mov [list + rcx * 8], rax                   ; Store the pointer in the correct row
        inc rcx                                     ; Increment counter
        jmp .loop                                   ; Repeate loop
    .end_loop:

    ; Loop through rows
    xor rcx, rcx                                    ; Clear rcx register
    .loop_rows:
        cmp ecx, [height]                           ; Compare counter to height
        je .end_loop_rows                           ; End loop if out of bounds
        xor r14, r14                                ; Clear e14 (used as counter for second loop)
        .loop_columns:
            
            cmp r14, [width]                        ; Compare counter to width
            je .end_loop_columns                    ; End loop if out of bounds

            mov [outerCounter], rcx                      ; Store ecx to keep constant through function call
            mov [innerCounter], r14                      ; Store e14 to keep constant through function call

            xor rdi, rdi
            xor rax, rax

            ; Get Red
            mov rax, 0                              ; system call for read
            mov edi, [fileDescriptor]               
            lea rsi, [red]                          ; Store red
            mov rdx, 1                              ; Read one byte
            syscall

            ; Get green
            xor rdi, rdi
            mov rax, 0                              ; system call for read
            mov edi, [fileDescriptor]               
            lea rsi, [green]                        ; Store green
            mov rdx, 1                              ; Read one byte
            syscall


            ; Get blue
            xor rdi, rdi
            mov rax, 0                              ; system call for read
            mov edi, [fileDescriptor]               
            lea rsi, [blue]                         ; Store blue
            mov rdx, 1                              ; Read one byte
            syscall

            ; Create Pixel
            movzx rdi, byte[red]                    ; Load Red into rdi for fuction call
            movzx rsi, byte[green]                  ; Load Green into rsi
            movzx rdx, byte[blue]                   ; Load Blue into rdx
            mov rcx, 0                              ; Up ptr is NULL
            mov r8, 0                               ; Down ptr is NULL
            mov r9, 0                               ; Left ptr is NULL
            mov r11, 0                              ; Right ptr is NULL

            ; Allocate memory for the struct
            xor rdi, rdi
            mov rdi, Pixel_size 
            call malloc
            mov [p], rax                            ;save the pointer

            ; Store values in the struct
            mov bl, [red]
            mov [rax + Pixel.red], bl               ; Store the value for red
            mov bl, [green]
            mov [rax + Pixel.green], bl             ; Store the value for green 
            mov bl, [blue]
            mov [rax + Pixel.blue], bl              ; Store the value for blue
            mov bl, 0
            mov [rax + Pixel.cdfValue], bl          ; Inital value for cdf value os 0
            xor rbx, rbx
            mov [rax + 8], rbx                      ; Store the address for up 
            mov [rax + 16], rbx                     ; Store the address for down 
            mov [rax + 24], rbx                     ; Store the address for left
            mov [rax + 32], rbx                     ; Store the address for right 
            mov rax, [p]
            ;call createPixel
            xor r14, r14
            xor rcx, rcx
            mov r14, [innerCounter]                      ; Load r14 from stack
            mov rcx, [outerCounter]                      ; Load rcx from stack
            ;mov rbx, qword[list]
            mov rdi, qword[list + rcx * 8]           ; Load row
            mov [rdi + r14 * 8], rax                ; Store ptr to pixel

            ; Create Refrences
            cmp rcx, 0                           ; If row > 0
            je .no_up_ref
            mov rdi, [list]
            mov rdi, [rdi + rcx * 8 - 8]            ; list[row-1]
            mov rdi, [rdi + r14 * 8]                ; list[row-1][col]
            mov [rax + 8], rdi                      ; Store up pointer
            .no_up_ref:

            cmp r14, 0                           ; If col > 0
            je .no_left_ref
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
        cmp ecx, [height]                      ; Check if in bounds
        je .end_loop_ref_rows
        xor r14, r14                                ; Clear inner loop counter
        .loop_ref_columns:
            xor rdx,rdx
            mov edx, [width]
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
