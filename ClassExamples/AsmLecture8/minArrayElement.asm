;int min (int* arr, long size)

min: 
  mov eax, [rdi]  ;int = 32bits = 4 bytes
  mov rcx, 1  ;compare with next element

.more mov r8d, [rdi+rcx*4] ;get arr[i]
  cmp r8d, eax
  cmovl eax, r8d  ;move if smaller
  ;d is used for the 32-bit version of r8
  inc rcx
  cmp rcx, rsi
  jl .more  ;while i < size
  ret
