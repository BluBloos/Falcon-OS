[BITS 32]
global InitializeKeyboard

section .text
InitializeKeyboard:
  InitializeKeyboard_ping:
    in al, 0x64  ;read commandport
    cmp al, 1
    jne InitializeKeyboard_ping_complete
    in al, 0x60 ;read dataport
    jmp InitializeKeyboard_ping
  InitializeKeyboard_ping_complete:
  ; tell the keyboard to start sending scan codes
  mov al, 0xF4
  out 0x64, al
  ret
