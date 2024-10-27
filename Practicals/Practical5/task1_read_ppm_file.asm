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

; New variables
innerCounter dd 0
outerCounter dd 0
rowHeads dq 0
head dq 0
prevRow dq 0
prev dq 0
node dq 0

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
    imul edi, 8                                    
    call malloc
    mov [rowHeads], rax                             ; Store the pointer 
    mov [head], rax

    xor rcx, rcx
    .while_loop_1:
        ;xor rdi, rdi
        ;mov edi, [height]
        cmp ecx,[height];edi
        jge .end_while_loop_1

        xor r15, r15
        mov [prev], r15                               ; prev = NULL 

        xor r14, r14
        .while_loop_2:
            
            mov [outerCounter], ecx
            mov [innerCounter], r14d

            ;xor rdi, rdi
            ;mov edi, [width]
            cmp r14d,[width];edi
            jge .end_while_loop_2

            xor rdi, rdi
            mov rdi, Pixel_size 
            call malloc
            mov [node], rax                         ; node = malloc(new pixel)
            
            ; Read in red
            mov rax, 0                          
            mov edi, [fileDescriptor]               
            lea rsi, [node + Pixel.red]                       
            mov rdx, 1                            
            syscall
            ; Read in green
            mov rax, 0                             
            mov edi, [fileDescriptor]               
            lea rsi, [node + Pixel.green]                        
            mov rdx, 1                              
            syscall
            ; Read in blue
            mov rax, 0                        
            mov edi, [fileDescriptor]          
            lea rsi, [node + Pixel.blue]                  
            mov rdx, 1                      
            syscall 
            
            xor rbx, rbx
            mov [node + Pixel.cdfValue], bl 

            mov [node + 8], rbx                        ; Store the null ptr for up 
            mov [node + 16], rbx                       ; Store the null ptr for down 
            mov [node + 24], rbx                       ; Store the null ptr for left
            mov [node + 32], rbx                       ; Store the null ptr for right

            xor rcx, rcx
            xor r14, r14
            mov r14d, [innerCounter]
            mov ecx, [outerCounter]
        
            cmp r14, 0
            jg .skip_1
            mov rax, [node]
            mov [rowHeads + rcx * 8], rax 
            .skip_1:
            xor rbx, rbx
            mov rbx, [prev]
            cmp rbx, 0
            je .skip_2
            xor r15,r15
            mov r15, [node]
            mov [prev + 32], r15
            xor r15, r15
            mov r15, [prev]
            mov [node + 24], r15
            .skip_2:
            xor rbx, rbx
            mov rbx, [prevRow]
            cmp rbx, 0
            je .skip_3
            xor r15, r15
            mov r15, [node]
            mov [prevRow + 16], r15
            xor r15, r15
            mov r15, [prevRow]
            mov [node + 8], r15
            xor rbx, rbx
            mov rbx, [prevRow + 32]
            mov [prevRow], rbx
            .skip_3:
            xor rbx, rbx
            mov rbx, [node]
            mov [prev], rbx
            inc r14
            jmp .while_loop_2
        .end_while_loop_2:
        xor rbx, rbx
        mov rbx, [rowHeads + rcx]
        mov [prevRow], rbx
        inc rcx
        jmp .while_loop_1
    .end_while_loop_1:
    xor rbx, rbx
    mov rbx, [rowHeads]
    
    ; Close file
    mov rdi , [fileDescriptor]          ; Mov the file descriptor     
    call close                          ; Close file

    mov rax, [rowHeads]
    leave
    ret
