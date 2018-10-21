; ------------------- TODO -------------------------
; We need to implement the enabled of the a20 register upon it not being enabled as per the gracious effort of the BIOS
; Upon doing the implemenation of the enabling of the a20 register we should make sure to attempt all of the methods of enabling it:
; 1. Test if a20 is already enabled, if it is we don't have to do anything
; 2. Try the BIOS function
; 3. Test if enabled
; 4. Otherwise try the keyboard controller method
; 5. test if a20 is enabled in a loop with a time-out as the keyboard controller may work slowly
; 6. try the fast a20 method
; 7. test if a20 is enabled in a loop with a time-out as the keyboard controller may work slowly
; 8. If none of these worked then we give up
; --------------------------------------------------

; -------------- cdecl -----------------
; Subroutine arguments are passed on the stack
; Integer values and memory addresses are returned in the EAX register, and floating point values are returned in the ST0 x87 register.
; Registers EAX, ECX, and EDX are caller-saved, and the rest are callee-saved.
; The x87 floating point registers ST0 to ST7 must be empty (popped or freed) when calling a new function
; ST1 to ST7 must be empty on exiting a function
; ST0 must also be empty when not used for returning a value.
; In the context of the C programming language, function arguments are pushed on the stack in the right-to-left order, i.e. the last argument is pushed first.
; ---------------------------------------

; -------------- caller-saved and callee-saved ----------
; callee-saved registers are the registers that a function is not allowed to touch (non-volatile).
; caller-saved registers are the ones that a function may use (volatile)
; -------------------------------------------------------

[BITS 16]
section .text
main:
  ; initialise essential segment registers
  xor ax, ax
  mov ds, ax
  mov es, ax
  ; set up a stack
  mov ax, 0x0050
  mov ss, ax
  mov sp, 0x03FF

  ; next we check if a20 is enabled
  call check_a20
  cmp eax, 0
  je main_print_a20_disabled
  jmp main_print_a20_cont
  main_print_a20_disabled:
  mov eax, 0x0
  push eax
  call bios_print ; print "A20 disabled!"
  jmp hang
  main_print_a20_cont:

  ; mov ax, 0xF000
  ; mov es, ax
  mov bx, 0x7E00 ; kernel goes into 0xF000:0xFFFF
  mov al, 1 ; we are going to read 1 sector
  mov dl, 0x80 ; we are going to read from the first hard drive
  mov cx, 0x0002 ; cylinder 0, sector 2
  xor dh, dh ; head 0
  call bios_read_drive
  cmp eax, 0
  jne main_print_drive_good
  main_print_drive_bad:
  mov eax, 0x1
  push eax
  call bios_print
  jmp hang
  main_print_drive_good:
  ; reset es
  xor ax, ax
  mov es, ax

  ; here we want to enable the appropriate video mode
  mov ah, 0x0
  mov al, 0x03 ; set the video mode to 80x25 video mode
  int 0x10

  ; -------------------- TEST PRINT ---------------
  ; mov eax, 0x07690748
  ; mov ebx, 0xb8000
  ; mov [ebx], eax
  ; -------------------- TEST PRINT ---------------

  ; jmp hang

  cli ; clear interrupts

  ; jmp 0xF000:0xFFFF
  ; tell the cpu about the gdt thing
  ; mov ax, 0x07C0
  ; mov ds, ax
  ; lgdt [gdt_desc]

  ; set PE bit
  ; mov eax, cr0
  ; or eax, 1
  ; mov cr0, eax

  jmp 0x0000:0x7E00 ; jump into debug kernel

hang:
  jmp hang

check_a20:

  ; Wait, hold up, what is the a20 line?
  ; I'm kind of confused here.
  ; Okay, let's clear this up

  ; The a20 is an address line
  ; The line is a physical representation of the 21st bit (it's called a20 since the line indices begin at 0) of any memory access.

  ; The IBM-AT (Intel 286) was introduced, and it was able to access up to sixteen megabytes of memory (as opposed to the 1 MBytes of the 8086).
  ; It disabled the A20 line, since it had to remain compatible with the 8086, who had a quirk in it's architecture (memory wraparound).

  ; Due to segmented memory model of the 8086, it could effectively address up to 1 megabytes and 64 kilobytes (minus 16 bytes).
  ; However, since there are only 20 address lines on the 8086 (a0 - a19), any address above the 1 megabyte mark wraps around to zero.

  ; So since the a20 line is disabled by default, we have to, as an operating system developer (or bootloader developer), enabled it.

  ; Sometime the bios does it for us.
  ; Okay so how do we check if a20 is enabled?

  ; When in real mode, we can compare the bootsector identifier at address 0000:7DFE with the value 1 megabyte higher (at address FFFF:7E0E). If these two values are different it means that the A20 line is enabled, this is because the wrapping behaviour is clearly not present, otherwise the two values would be the same.
  ; If these values are the same, we have to ensure that they are not the same by some voodoo magic shit.
  ; How do we do this?
  ; We have to change the bootsector identifier to something different, and then we must compare the two values again. If these values are still the same, then the a20 line is disabled and therefore we must enable it!


  push ds
  mov ax, [0x7DFE]
  mov dx, 0xFFFF
  mov ds, dx
  mov dx, [0x7E0E]
  cmp ax, dx
  je check_a20_further
  check_a20_enabled:
  pop ds
  mov eax, 1 ; return True since a20 is all good!
  ret
  check_a20_further:
  mov dx, 0x0000
  mov ds, dx
  sal ax, 2
  mov [0x7DFE], ax
  mov dx, 0xFFFF
  mov ds, dx
  mov dx, [0x7E0E]
  cmp ax, dx
  je check_a20_disabled
  jmp check_a20_enabled
  check_a20_disabled:
  pop ds
  mov eax, 0 ; return False since a20 is disabled!
  ret

bios_print:
  push ebp ; save frame pointer
  mov ebp, esp ; init new frame pointer
  mov ecx, [ebp + 0x8] ; add the address of msg
  mov dl, 0
  cmp eax, 0
  je bios_print_a
  mov ecx, msg1
  add ecx, 0x7c00 ; add the base address
  bios_print_loop:
    mov ah, 0x0e ; select teletype sub function
    cmp [ecx], dl ; check if we reached the end of string
    je bios_print_exit ; if so exit
    mov al, [ecx] ; set al equal to the current character
    add ecx, 1 ; advance the character
    int 0x10 ; print character
    jmp bios_print_loop
  bios_print_a:
    mov ecx, msg2
    add ecx, 0x7c00 ; add the base address
    jmp bios_print_loop
  bios_print_exit:
  mov esp, ebp
  pop ebp
  ret

; Reads sectors from disk into memory using BIOS services

; input:
;           dl      = drive
;           ch      = cylinder[7:0]
;           cl[7:6] = cylinder[9:8]
;           dh      = head
;           cl[5:0] = sector (1-63)
;           es:bx  -> destination
;           al      = number of sectors
;
; output: eax (0 = failure, 1 = success)

bios_read_drive:
  push esi
  mov si, 0x02 ; maximum attempts - 1
  bios_read_drive_top:
  mov ah, 0x02
  int 0x13
  jnc bios_read_drive_end_success ; jump if the read was successful
  dec si ; decrement remaining attempts
  jc bios_read_drive_end_failure ; exit if maximum attempts exceeded
  xor ah, ah ; reset disk system (int 0x13, ah = 0x00)
  int 0x13
  jnc bios_read_drive_top ; retry if reset succeeded, otherwise exit
  bios_read_drive_end_failure:
  mov eax, 0 ; return False
  jmp bios_read_drive_end
  bios_read_drive_end_success:
  mov eax, 1 ; return True
  bios_read_drive_end:
  pop esi
  ret

msg1:
  db 'A20 is disabled!',0
msg2:
  db 'Drive bad',0

gdt:
gdt_null:
  dq 0
gdt_code:
  dw 0xFFFF ; set the limit to 4GB
  dw 0 ; set the base address to 0
  db 0 ; continuation of base address
  db 10011010b ; ton of complicated shit
  db 11001111b ; more complicated shit
  db 0
gdt_data:
  dw 0xFFFF
  dw 0
  db 0
  db 10010010b
  db 11001111b
  db 0
gdt_desc:
  db gdt_desc - gdt
  dw gdt

; just for a brief moment, let's analyze times 510-($-$$)
; "$" stands for here and "$$" stands for the start of the code
; so "$-$$" results in the length of the code
; and we do 510-lengthOfCode to compute hom many bytes to actually write

; below is the steps required to put the magic number, such that the image is bootable

times 510-($-$$) db 0
db 0x55
db 0xAA
