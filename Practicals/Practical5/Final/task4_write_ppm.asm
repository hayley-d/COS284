; ==========================
; Group member 01: W.J. van der Walt- 22790919
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

    width dq 0                          ; Used to store the wifth of the image
    height dq 0                         ; Used to store the height of the image
    width_length equ 8            ; Length of the variables for file-writing
    space db ' ', 0                     ; Space for between width and height
    space_length equ 1            ; Length of the space
    height_length equ 8          ; Length of the height
    p db 'P6', 0x0A, 0                  ; P6 for the header of the file
    p_length equ $-p                    ; And it's length
    new_line db 0x0A                    ; New-line character for file-writing
    max_colour db 255

section .bss

    curr_height: resb 8                 ; Buffer to store the current height when traversing through the list

section .text
    global writePPM

writePPM:
    
    mov rsi, [rsp+8]                    ; Get the argv array
    mov r15, [rsi+8]                    ; Store the filename in r15, since rdi will be used

    mov rbx, [rsi+16]                        ; Move the pointer to the first PixelNode into rbx for width traversal
    mov rdx, [rsi+16]                        ; Move the pointer to the first PixelNode into rdx for height traversal
    mov r8, [rsi+16]                         ; Move pointer into r8 for later traversal

    xor rax, rax                        ; Register for counts
    xor rdi, rdi
    mov rdi, r8                         ; Set the first argument for the width_loop function (needs the pointer to first PixelNode)
    call width_loop                     ; Get width 
    mov [width], rax                    ; return value will be in rax, store this in the with variable

    xor rax, rax                        
    xor rdi, rdi
    mov rdi, r8                         ; Set the first argument for the height_loop function
    call height_loop                    ; Get height
    mov [height], rax                   ; Store the return value inside the height variable
    xor rax, rax

    xor rsi, rsi

    ; Open the file
    mov rdi, r15                        ; Specify where the file name is stored
    mov rsi, 1                          ; Use code 1 for binary write
    mov rax, 2                          ; Use code 2 to specify that we want to open the file
    syscall                             ; Make syscall to open the file

    mov rbx, rax                        ; Save the file descriptor
    cmp rax, -1                         ; Check whether the open call was successful
    je open_err                         ; If not leave

    xor rax, rax

    ; Write P6, width, space, height and maxcolorval to the file

    mov rax, 1                          ; Specify that we want to write to the file
    mov rsi, p                          ; Specify what we want to write
    mov rdx, p_length                   ; Specify the length of what will be written
    syscall 

    mov rax, 1                          
    mov rsi, width
    mov rdx, width_length
    syscall

    mov rax, 1
    mov rsi, space
    mov rdx, space_length
    syscall

    mov rax, 1
    mov rsi, height
    mov rdx, height_length
    syscall

    mov rax, 1
    mov rsi, new_line
    mov rdx, 1
    syscall

    mov rax, 1
    mov rsi, maxcolour
    mov rdx, 1
    syscall

    mov rax, 1
    mov rsi, new_line
    mov rdx, 1
    syscall

    ; Now we traverse the linked list and store the rgb values
    xor rdi, rdi
    mov rdi, r8                            ; Store the pointer to the first Pixel-node in rdi (first argument)
    xor r12, r12 
    mov qword [curr_height], 0             ; Set curr_height to 0
    call go_right                          ; Call traversal function

    ; Close the file
    xor rax, rax
    mov rax, 3                              ; Code 3 used to specify that we want to close the file
    syscall

    ; Exit
    mov rax, 60                             ; Code 60 the exit
    xor rdi, rdi                            ; With status code 0
    syscall                 

; Used to traverse to the right and to write the rgb values
go_right:

    mov r13, rdi                            ; Store the pointer in r13, since rdi will be used as argument in write_byte      
    mov rdi, [r13 + Pixel.red]              ; Retrieve the red value
    call write_byte                         ; Call write_byte to write the byte stored in rdi to the file
                                                    
    mov rdi, [r13 + Pixel.green]
    call write_byte

    mov rdi, [r13 + Pixel.blue]
    call write_byte
    mov rdi, r13                            ; Restore rdi to contain the pointer

    xor r8, r8                              ; Ensure r8 is zero (this will be the counter for the left traversal)
    inc r12                                 ; Increase the r12 (the counter for the right traversal)
    cmp r12, width                          ; Check whether we have reached the end of the row
    je go_left                              ; If so, traverse left (and then go down to start the left traversal of the next row)
    mov rdi, [rdi + Pixel.right]            ; Otherwise, go to the next pixelnode onthe right
    jmp go_right                            ; Repeat the above
    
; Used to resest the pointer in rdi to the beginning of the row
go_left:

    xor r12, r12
    inc r8                                  ; Increase value in r8
    cmp r8, width                           ; Compare it with the now known width of the linked list (check if we are at the left-end of the list)
    je go_down                              ; If so go down to the next row
    mov rdi, [rdi + Pixel.left]             ; Else go to the next pixelnode on the left
    jmp go_left                             ; Repeat

; Used to go one row down
go_down:
               
    cmp [curr_height], height               ; Check if we have reached the bottom of the linked list
    je end_loop                             ; If so we are done
    mov rdi, [rdi + Pixel.down]             ; Else go to the next pixelnode in the row below
    inc qword [curr_height]                 ; Increase the curr_height counter
    jmp go_right                            ; Start the right traversal again

; Used to write one byte to the opened file
write_byte:

    mov rax, 1                              ; Specify that we want to write to the file
    mov rsi, rdi                            ; Specify we want to write the value in rdi
    mov rdi, rbx                            ; Load file descriptor
    mov rdx, 1                              ; Specify that we are writing one byte
    syscall                         
    ret 

; Used to count the columns
width_loop:

   test rdi, rdi                            ; Check if we have reached the end of row
   jz end_loop                              ; If so end the traversal
   inc rax                                  ; Otherwise inc the col count
   mov rdi, [rdi + Pixel.right]             ; Go to the next pixelnode on the right
   jmp width_loop                           ; Repeat

; Used to count the rows
height_loop:

    test rdi, rdi                              ; Check if we reached the end of the col
    jz end_loop                             ; If so return
    inc rax
    mov rdi, [rdi + Pixel.down]             ; Go to the next pixelnode in the row below
    jmp height_loop                         ; Repeat

; Used to return to the calling function 
end_loop:
    ret

; Used to exit if the opening of the file failed
open_err:
    mov rax, 60                             ; Code to exit
    xor rdi, rdi                            ; With status code 0
    syscall
    