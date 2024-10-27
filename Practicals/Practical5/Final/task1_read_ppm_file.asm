; ==========================
; Group member 01: Name_Surname_student-nr
; Group member 02: Name_Surname_student-nr
; Group member 03: Name_Surname_student-nr
; Group member 04: Name_Surname_student-nr
; Group member 05: Name_Surname_student-nr
; ==========================

; Reads binary P6 format PPM files and creates a linked pixel structure 
; Each pixel connects to adjacent pixels (above, below, left, right)

; External C library function declarations
extern fgetc    ; Read single character (uses rdi for FILE*)
extern ungetc   ; Push character back (uses edi for char, rsi for FILE*)
extern fopen    ; Open file (uses rdi for filename, rsi for mode)
extern fscanf   ; Read formatted input (uses rdi for FILE*, rsi for format)
extern strcmp   ; Compare strings (uses rdi and rsi for strings)
extern malloc   ; Allocate memory (uses rdi for size)
extern fread    ; Read binary data (uses rdi, rsi, rdx, rcx)
extern free     ; Free memory (uses rdi for pointer)
extern fclose   ; Close file (uses rdi for FILE*)

section .data
    rb_mode     db "rb", 0       ; Binary read mode for fopen
    fmt_str     db "%s", 10, 0   ; Format for reading magic number
    fmt_nums    db "%d %d", 10, "%d", 10, 0  ; Format for dimensions and max value
    magic_p6    db "P6", 0       ; PPM P6 format identifier

section .text
global skipComments
global readPPM

; Function: skipComments
; Purpose: Skips comment lines (starting with #) in PPM file
; Parameters: rdi - FILE* pointer to open PPM file
; Local variables (stack-based):
;   rbp-24: FILE* storage
;   rbp-1:  Current character
skipComments:
    push    rbp                 ; Save old base pointer
    mov     rbp, rsp           ; Set up new stack frame
    sub     rsp, 32            ; Allocate 32 bytes local storage
    mov     [rbp-24], rdi      ; Store FILE* for later use

.read_char:                     ; Loop to read characters
    mov     rax, [rbp-24]      ; rax = FILE*
    mov     rdi, rax           ; rdi = parameter for fgetc
    call    fgetc              ; Read one character
    mov     [rbp-1], al        ; Store character (al = lower byte of rax)
    cmp     byte [rbp-1], 35   ; Compare with '#' (ASCII 35)
    je      .skip_comment_line
    movsx   eax, byte [rbp-1]  ; Sign-extend char for ungetc
    mov     rdx, [rbp-24]      
    mov     rsi, rdx           ; rsi = FILE* for ungetc
    mov     edi, eax           ; edi = character to push back
    call    ungetc
    jmp     .skip_comments_end

.skip_comment_line:            
.read_until_newline:          
    mov     rax, [rbp-24]      
    mov     rdi, rax           ; rdi = FILE* for fgetc
    call    fgetc              
    mov     [rbp-1], al        ; Store read character
    cmp     byte [rbp-1], 10   ; Compare with newline (ASCII 10)
    je      .read_char         
    cmp     byte [rbp-1], -1   ; Compare with EOF (-1)
    jne     .read_until_newline
    jmp     .read_char

.skip_comments_end:           
    leave                      ; Restore stack frame
    ret

; Function: readPPM
; Purpose: Reads PPM file and builds linked pixel structure
; Parameters: rdi - filename string pointer
; Returns: rax - pointer to first pixel or NULL if error
; Pixel Structure (40 bytes):
;   Bytes 0-2:   RGB values
;   Byte 3:      Padding
;   Bytes 4-11:  Above pixel pointer
;   Bytes 12-19: Below pixel pointer
;   Bytes 20-27: Left pixel pointer
;   Bytes 28-35: Right pixel pointer
; Local variables:
;   rbp-88: Filename
;   rbp-80: Max color value
;   rbp-76: Height
;   rbp-72: Width
;   rbp-67: Magic number buffer
;   rbp-64: Current pixel
;   rbp-56: First pixel
;   rbp-48: Row pointers array
;   rbp-40: FILE pointer
;   rbp-28: Column counter
;   rbp-24: Previous pixel
;   rbp-12: Row counter
;   rbp-8:  Above pixel
readPPM:
    push    rbp
    mov     rbp, rsp
    sub     rsp, 96            ; Allocate local variables space

    mov     [rbp-88], rdi      ; Store filename pointer

    ; Open file in binary read mode
    mov     rax, [rbp-88]      ; rax = filename
    mov     rsi, rb_mode       ; rsi = "rb"
    mov     rdi, rax           ; rdi = filename for fopen
    call    fopen
    mov     [rbp-40], rax      ; Store FILE*
    
    ; Check file open success
    cmp     qword [rbp-40], 0  ; Compare FILE* with NULL
    jne     .process_file
    xor     eax, eax           ; Return NULL if open failed
    jmp     .readPPM_end

.process_file:                 
    ; Read PPM magic number
    lea     rdx, [rbp-67]      ; rdx = buffer for magic number
    mov     rax, [rbp-40]      ; rax = FILE*
    mov     rsi, fmt_str       ; rsi = format string
    mov     rdi, rax           ; rdi = FILE* for fscanf
    xor     eax, eax           ; Clear AL (varargs count)
    call    fscanf

    ; Skip header comments
    mov     rax, [rbp-40]      
    mov     rdi, rax           ; rdi = FILE* for skipComments
    call    skipComments

    ; Read image dimensions and max value
    lea     rsi, [rbp-80]      ; Max color value address
    lea     rcx, [rbp-76]      ; Height address
    lea     rdx, [rbp-72]      ; Width address
    mov     rax, [rbp-40]      ; FILE*
    mov     r8, rsi            ; r8 = max value ptr for fscanf
    mov     rsi, fmt_nums      ; rsi = format string
    mov     rdi, rax           ; rdi = FILE*
    xor     eax, eax           ; Clear AL (varargs count)
    call    fscanf

    ; Verify PPM format
    lea     rax, [rbp-67]      ; Magic number buffer
    mov     rsi, magic_p6      ; "P6" string
    mov     rdi, rax           ; Compare parameters
    call    strcmp
    test    eax, eax           ; Check if strings match
    jne     .close_invalid_file
    
    mov     eax, [rbp-80]      
    cmp     eax, 255           ; Verify max color value
    je      .process_valid_file

.close_invalid_file:          
    mov     rax, [rbp-40]      
    mov     rdi, rax           ; rdi = FILE* to close
    call    fclose
    xor     eax, eax           ; Return NULL
    jmp     .readPPM_end

.process_valid_file:          
    ; Allocate row pointer array
    mov     eax, [rbp-76]      ; eax = height
    cdqe                       ; Sign-extend to 64-bit
    sal     rax, 3             ; Multiply by 8 (pointer size)
    mov     rdi, rax           ; rdi = size for malloc
    call    malloc
    mov     [rbp-48], rax      ; Store row pointers array

    mov     qword [rbp-56], 0  ; Initialize first pixel ptr
    mov     qword [rbp-8], 0   ; Initialize above pixel ptr
    mov     dword [rbp-12], 0  ; Initialize row counter

.row_loop:
    mov     dword [rbp-28], 0  ; Reset column counter
    mov     qword [rbp-24], 0  ; Reset previous pixel ptr

.pixel_loop:
    ; Allocate pixel structure
    mov     edi, 40            ; 40 bytes for pixel struct
    call    malloc
    mov     [rbp-64], rax      ; Store new pixel ptr

    ; Read RGB values
    mov     rax, [rbp-64]      ; Destination for red
    mov     rdx, [rbp-40]      ; FILE*
    mov     rcx, rdx           ; rcx = FILE* for fread
    mov     edx, 1             ; Read 1 byte
    mov     esi, 1             ; Read 1 time
    mov     rdi, rax           ; rdi = destination
    call    fread              ; Read red value

    mov     rax, [rbp-64]
    lea     rdi, [rax+1]       ; Destination for green
    mov     rax, [rbp-40]
    mov     rcx, rax           ; rcx = FILE*
    mov     edx, 1
    mov     esi, 1
    call    fread              ; Read green value

    mov     rax, [rbp-64]
    lea     rdi, [rax+2]       ; Destination for blue
    mov     rax, [rbp-40]
    mov     rcx, rax           ; rcx = FILE*
    mov     edx, 1
    mov     esi, 1
    call    fread              ; Read blue value

    ; Initialize pixel pointers
    mov     rax, [rbp-64]
    mov     byte [rax+3], 0    ; Set padding byte
    mov     rax, [rbp-64]
    mov     qword [rax+32], 0  ; Clear right ptr
    mov     rax, [rbp-64]
    mov     rdx, [rax+32]
    mov     qword [rax+24], rdx ; Clear left ptr
    mov     rax, [rbp-64]
    mov     rdx, [rax+24]
    mov     qword [rax+16], rdx ; Clear below ptr
    mov     rax, [rbp-64]
    mov     rdx, [rax+16]
    mov     qword [rax+8], rdx  ; Clear above ptr

    ; Handle row start
    cmp     dword [rbp-28], 0  ; First pixel in row?
    jne     .skip_row_start
    mov     eax, [rbp-12]      ; Current row number
    cdqe
    lea     rdx, [rax*8]       ; Calculate offset
    mov     rax, [rbp-48]      ; Row pointers array
    add     rdx, rax           ; Add base address
    mov     rax, [rbp-64]      ; Current pixel
    mov     [rdx], rax         ; Store row start

.skip_row_start:
    ; Link horizontal pixels
    cmp     qword [rbp-24], 0  ; Previous pixel exists?
    je      .skip_horizontal
    mov     rax, [rbp-24]
    mov     rdx, [rbp-64]
    mov     [rax+32], rdx      ; Link previous->current
    mov     rax, [rbp-64]
    mov     rdx, [rbp-24]
    mov     [rax+24], rdx      ; Link current->previous

.skip_horizontal:
    ; Link vertical pixels
    cmp     qword [rbp-8], 0   ; Above pixel exists?
    je      .skip_vertical
    mov     rax, [rbp-8]
    mov     rdx, [rbp-64]
    mov     [rax+16], rdx      ; Link above->current
    mov     rax, [rbp-64]
    mov     rdx, [rbp-8]
    mov     [rax+8], rdx       ; Link current->above
    mov     rax, [rbp-8]
    mov     rax, [rax+32]      ; Move to next above pixel
    mov     [rbp-8], rax

.skip_vertical:
    ; link horizontal pixels
    mov     rax, [rbp-64]
    mov     [rbp-24], rax      ; Update previous pixel
    inc     dword [rbp-28]     ; Next column

    mov     eax, [rbp-72]      ; Check column limit
    cmp     [rbp-28], eax
    jl      .pixel_loop        ; Continue if more columns

    ; Prepare next row
    mov     eax, [rbp-12]
    cdqe
    lea     rdx, [rax*8]
    mov     rax, [rbp-48]
    add     rax, rdx
    mov     rax, [rax]         ; Get row start
    mov     [rbp-8], rax       ; Store for vertical linking
    inc     dword [rbp-12]     ; Next row

    mov     eax, [rbp-76]      ; Check row limit
    cmp     [rbp-12], eax
    jl      .row_loop          ; Continue if more rows

    ; Cleanup and return
    mov     rax, [rbp-48]
    mov     rax, [rax]
    mov     [rbp-56], rax      ; Store first pixel

    mov     rax, [rbp-48]
    mov     rdi, rax           ; Free row pointers
    call    free

    mov     rax, [rbp-40]
    mov     rdi, rax           ; Close file
    call    fclose

    mov     rax, [rbp-56]      ; Return first pixel pointer

.readPPM_end:                
    leave                      ; Restore stack frame
    ret