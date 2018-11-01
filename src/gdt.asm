[BITS 32]
global SetGdt
global gdt_struct

section .data
gdt_struct:
dd gdt ;pointer to gdt data
dd 0 ;first key
dd 0 ;second key
dd 0 ;third key
dd 0 ;fourth key
gdt:
;dq 0 ;space for null
;dq 0 ;space for unused
;dq 0 ;space for code
;dq 0 ;space for data

gdt_null:
  dq 0
gdt_unused:
  dq 0
gdt_code:
  dw 0 ; limit 0:15=0x0000
  dw 0 ; base 0:15=0x0000
  db 0 ; base 16:23=0x00
  db 10011010b ; Pr=1,Privl=0,Ex=1,DC=0,RW=1,Ac=0
  db 11000001b ; Gr=1,Sz=1,limit 16:19=0x1
  db 0 ; base 24:31=0x00
gdt_data:
  dw 0 ; limit 0:15=0x0000
  dw 0 ; base 0:15=0x0000
  db 0 ; base 16:23=0x00
  db 10010010b ; Pr=1,Privl=0,Ex=0,DC=0,RW=1,Ac=0
  db 11000001b ; Gr=1,Sz=1,limit 16:19=0x1
  db 0 ; base 24:31=0x00

section .text
gdtr:
dw 0x20 ; size
dd gdt ; for base storage
; void SetGdt()
SetGdt:
  lgdt [gdtr]
  ret

; -------------- GDT ------------
; limit 0:15 2 bytes
; base 0:15 2 bytes
; base 16:23 byte
; access byte
; limit 16:19 half byte
; flags half byte
; base 24:31 byte
; -------------------------------

; ---- Access Byte and Flags ----

; ---Access Byte-----------------
; 7 ----------------------------- 0
; Pr | Privl | 1 | Ex | DC | RW | Ac

; ---Flags-------
; 7 ----------- 4
; Gr | Sz | 0 | 0

; Pr: Present bit. This must be 1 for all valid seclectors
; Privl: Privilege, 2 bits. Contains the ring level, from 0 to 3
; Ex: Executable bit. If 1 code in this segment can be executed, ie. a code selector. If 0 it is a data selector
; DC: Direction bit / Conforming bit
;   Direction bit for data selectors:
;     Tells the direction. 0 the segment grows up. 1 the segment grows down, ie. the offset has to be greater than the limit
;   Conforming bit for code selectors:
;     If 1 code in this segment can be exectued from an equal or lower priviledge level. For example, code in ring 3 can far-jump to conforming code in a ring 2 segment. Code in ring 0 cannot far-jump to a conforming code segment with privl=0x2, while code in ring 2 and 3 can. Note that the priviledge level remains the same, ie. a far-jump from ring 3 to a privl=2-segment remains in ring 3 after the jump
;     If 0 code in this segment can only be exectued from the ring set in privl
; RW: Readable bit/Writable bit
;   Readable bit for code selectors: Whether read access for this segment is allowed. Write access is never allowed for code sements
;   Writable bit for data selectors: Whether write access for this semgment is allowed. Read access is always allowed for data segments
; Ac: Accessed bit. Just set to 0. The CPU sets this to 1 when the segment is accessed
; Gr: Granularity bit. If 0 the limit is in 1 B blocks (byte granularity), if 1 the limit is in 4 KiB blocks (page granularity)
; Sz: Size bit. If 0 the selector defines 16 bit protected mode. If 1 it defines 32 bit protected mode. You can have both 16 bit and 32 bit selectors at once
; -------------------------------
