global GetCaret
global SetCaret
global GetPrograms

[BITS 32]

section .text

; void *GetPrograms(unsigned int *length)
GetPrograms:
  mov eax, [esp + 0x4]
  mov ecx, 1
  mov [eax], ecx  ; there is only one program for now

  mov eax, programs ; move the pointer to the registered programs
  ; into the return register
  ret

; void GetCaret(unsigned short *row, unsigned short *column)
GetCaret:
  mov eax, caret
  mov dx, [eax]
  mov ecx, [esp + 0x4]
  mov [ecx], dx
  add eax, 2
  mov dx, [eax]
  mov ecx, [esp + 0x8]
  mov [ecx], dx
  ret

; void SetCaret(unsigned short row, unsigned short column)
SetCaret:
  mov ax, [esp + 0x4]
  xor edx, edx ; edx = 0
  mov dx, ax
  mov ax, [esp + 0x8]
  shl eax, 0x10 ;unsigned shift of eax by 16 left
  or edx, eax

  mov eax, caret
  mov [eax], edx

  ; mov hardware vga cursor
  mov ax, [esp + 0x4] ;get row
  mov cl, 80
  mul cl

  mov cx, [esp + 0x8] ; get column
  add ax, cx ; + column
  mov cx, ax

  ;cursor LOW port to vga INDEX register
  mov al, 0xF
  mov dx, 0x3D4 ; VGA port
  out dx, al

  mov ax, cx
  mov dx, 0x3D5
  out dx, al

  ;cursor HIGH port to vga INDEX register
  mov al, 0xE
  mov dx, 0x3D4
  out dx, al

  mov ax, cx
  shr ax, 8 ; get high byte in 'position'
  mov dx, 0x3D5
  out dx, al

  ret

section .data
caret:
dd 0 ; the caret is a 32 bit integer, low word is row, hight word is column
programs: ; note, for now we can only have one program
dq 0
dd 0
