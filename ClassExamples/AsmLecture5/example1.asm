  mov rax, 0x12345678
  mov rbx, rax
  and rbx, 0xf

  mov rax, 0x1124
  or rax, 1 ;make the number odd

  mov rax, 0x1000
  or rax, 0xff00  ; rax = 0xff00

  mov rax, 0x10aa
  or rax, 0xff00 ; rax = 0xffaa

  mov rax,0 ;uses 7 bytes
  xor rax, rax ;uses 3 bytes

  mov rax, 0x12345678
  xor eax,eax ;for efficiency same as xor rax

  mov rax, 0x1234
  xor rax, 0xf  ;flips all the bits in 4 so rax = 0x123b

  xor rax, rbx
  xor rbx, rax
  xor rax, rbx  ;swaps two values without using intermediate register
  
  mov rax, 1100011110010110
  shr rax, 3    ;shift 3 bits
  and rax, 0x7f ;AND 0x7f

  mov rax 1100011110010110
  mov rbx, 63
  sub rbx, 9  ; bits 9-3
  shl rax, rbx
  shr rax, rbx
  shr rax, 3

  ;replace bits 6-3
  mov rax, 1100011110010100
  mov rbx, 0xf  ;mask 1111 6-3+1 = 4
  mov rcx, 1101 ; new value
  shl rcx, 3
  shl rbx, 3
  not rbx
  and rax,rbx
  or rax, rcx;fill in new value

  mov rax, 1100011110010100
  ror rax, 3
  shr rax, 4
  shl rax, 4
  or rax, 1101 ; new value
  rol rax, 3

  bt ax, 12 ;bit 12 in Carry register

  mov rax, 101
  bt rax, 0
  setc dl ; 1 will be stored in dl

  bts qword [a], 7  ;sets bit 7 to 1

