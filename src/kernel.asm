global kernel
global GetCaret
global SetCaret

extern Print
extern SetupInterrupts
extern gdt_struct
extern idt_start
extern SetupGlobalDescriptorTable
extern InitializeKeyboard
extern DebugPrintGdt
extern DebugPrintShort
extern DebugHexFunctions
extern IdentifyATA
extern ataStorage
extern FlushATA
extern WriteATA
extern ReadATA
extern PrintError
[BITS 32]

; ----------- first MB table ---------------
; 0 -3FF        RAM       Real mode, IVT (Interrupt Vector Table)
; 400 -4FF      RAM       BDA (BIOS data area)
; 500 - 9FFFF   RAM       Free memory, 7C00 used for boot sector
; A0000 - BFFFF Video RAM Video memory
; C0000 - C7FFF Video ROM Video BIOS
; C8000 - EFFFF ?         BIOS shadow area
; F0000 - FFFFF ROM       System BIOS
; ------------------------------------------


section .kernel
kernel:
  ;mov esp, 0x0100000 ; setup stack

  ; -------------------- TEST PRINT ---------------
  ; mov eax, 0x07690748
  ; mov ebx, 0xb8000
  ; mov [ebx], eax
  ; -------------------- TEST PRINT ---------------

  mov eax, msg
  push eax
  call Print
  pop eax

  ; ------------ SUPPOSEDLY THIS WORKS -----------
  mov eax, gdt_struct
  push eax
  call SetupGlobalDescriptorTable
  ; ----------------------------------------------

  call DebugHexFunctions
  mov eax, gdt_struct
  push eax
  call DebugPrintGdt

  ; setup segment registers
  mov eax, 0x18
  mov es, eax

  mov eax, idt_start
  push eax
  mov eax, gdt_struct
  push eax
  call SetupInterrupts
  ;call InitializeKeyboard
  sti ;activate interrupts

  xor eax, eax
  push eax
  call IdentifyATA
  pop eax

  mov eax, 1
  push eax
  call IdentifyATA
  pop eax

  mov eax, ataStorage
  push eax
  call Print
  pop eax

  ;mov edi, ataStorage
  ;xor ecx, ecx
  ;call WriteATA
  ;jc read_ata_fail
  ;call FlushATA

  mov eax, msg_read_event
  push eax
  call Print
  pop eax

  mov edi, ataStorage
  xor ecx, ecx
  call ReadATA
  jnc read_ata_succ
  read_ata_fail:
  mov eax, msg_read_fail
  push eax
  call Print
  pop eax
  read_ata_succ:
    mov eax, ataStorage
    push eax
    call Print
    pop eax

  kernel_hang:
    jmp kernel_hang

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
  ret

section .data
msg_read_event:
db "ReadATA: ", 0
msg_read_fail:
db "ReadATA: ERR", 0
msg:
db "Initializing Falcon OS version 2.43.2", 0xA, 0
caret:
dd 0 ; the caret is a 32 bit integer, low word is row, hight word is column
