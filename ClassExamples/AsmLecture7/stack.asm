

_start:
  mov rax, 74
  push rax  ;74 at the top of the stack

  inc rax ;75
  push rax  ;75 -> 74

  inc rax
  push rax ; 76 -> 75 -> 74

  pop rax ; rax = 76

  pop rax ; rax = 75

  pop rax ; rax = 74
