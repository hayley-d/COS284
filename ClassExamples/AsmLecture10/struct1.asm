  
  mov rdi, 150  ;size of the Customer struct
  call malloc   ;returns the address of the newly allocated memory
  mov [c], rax  ;save the address of the dynamic memory

