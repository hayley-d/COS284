
  sub rsp, 16 ;subtract 16 bytes 
  mov qword[rsp+8], 123  ; set frist qword to 123
  mov qword[rsp], 24 ;set second qword to 24
  add rsp, 16


