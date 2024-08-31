; ==========================
; Group member 01: Hayley Dodkins 21528790
; ==========================
section .data
prompt: db "Enter values seporated by whitespace and enclosed in pipes (|): ",0
float_array dq  0    ;holds the pointer to the float array
counter dd 0    ;counter for offset
offset dd 0
c db ''

section .bss
input resb  100
current resb 100 ;reserve space for a 10 digit number

section .text
  extern convertStringToFloat
  extern malloc
  global extractAndConvertFloats

extractAndConvertFloats:
  push rbp
  mov rbp, rsp

  ;make sys out call
  mov rax, 4
  mov rbx, 1
  mov rcx, prompt
  mov rdx, 65
  int 0x80

  ;make sys in call
  mov rax, 3
  mov rbx, 0
  mov rcx, input
  mov rdx, 100
  int 0x80

  ;rax has number of bytes read?
  mov byte[input+rax], 0  ;add null terminate to the string

  mov rdi, 4    ;size of 1 float
  imul rdi, 15  ; number of floats to store
  call malloc
  mov [float_array], rax    ;store address in float array

  xor rax, rax
  xor rbx, rbx
  xor rcx, rcx
  xor r8,r8
  mov rcx,2
  xor r14,r14   ;counter for float offset
  

  jmp parse_loop

  leave
  ret

parse_loop:

    ;.find_next_delimiter:
        mov al, byte[input+rcx]
        cmp al,' '  ;check for delimiter
        je .delimiter_found
        cmp al,'|'  ;check for delimiter
        je .done_parsing

        mov [current + r8], al ;move the character into the temp string
        inc r8
        inc rcx
        jmp parse_loop;.find_next_delimiter

    .delimiter_found:
        mov byte[current+r8], 0  ;null terminate string
        mov rdi, current
        inc rcx ;move past the delimiter
        mov dword[counter], ecx  ;store value for function call
        call convertStringToFloat

        xor r8,r8
        xor al,al
        xor rcx, rcx    ;clear the counter register

        mov r14d, dword[offset]
        mov [float_array + r14*4],rax   ;move return into the array
        inc r14 ; increment the counter
        mov dword[offset], r14d
        mov rcx, [counter]  ;restore the counter
        jmp parse_loop;.find_next_delimiter

    .done_parsing:
        mov rax, float_array




