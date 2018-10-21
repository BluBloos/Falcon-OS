;dataPort = portBase;
;errorPort = portBase + 1;
;sectorCountPort = portBase + 2;
;lbaLowPort = portBase + 3;
;lbaMidPort = portBase + 4;
;lbaHiPort = portBase + 5;
;devicePort = portBase + 6;
;commandPort = portBase + 7
;controlPort = portBase + 0x206;

[BITS 32]
global ReadATA
global WriteATA
global FlushATA
global IdentifyATA
extern PrintError
extern Print
global ataStorage
extern DebugPrintShort

section .data
ataStorage:
  db "This is a test",0
ataStorageStringEnd:
  times 512-($ - ataStorage) db 0
msg_master:
  db "Master",0
msg_slave:
  db "Slave",0
msg_flush_error:
  db "Flsh: ERR",0


section .text

; NOTE(Noah): this function assumes that the ATA is already selected
PollATA:
  mov edx, 0x1F7 ; set port to status port
  ; here we are testing the values while also waitng the required 400ns
  mov ecx, 4
  PollATA_wait:
    in al, dx ; grab a status byte lmao
    test al, 0x80 ; is the BSY flag set?
    jne PollATA_retry
    test al, 8 ; what about that DRQ bro? ; NOTE(Noah): this also clears the carry flag
    jne PollATA_done
  PollATA_retry:
    dec ecx ; we have exausted a turn if you will
    jg PollATA_wait

  ; okay so here we need to wait some more. We are going to loop
  ; until BSY clears or ERR sets
  PollATA_wait2:
    in al, dx ; grab a status byte again
    test al, 0x80 ; check the BSY flag
    jne PollATA_wait2
    test al, 0x21 ; ERR or DF set?
    je PollATA_done

  PollATA_fail:
    stc
  PollATA_done:
    ret

; void IdentifyATA(bool master)
IdentifyATA:
  mov edx, 0x1F6 ; select the appropriate
  mov ecx, [esp + 0x4]
  test ecx, ecx
  jz IdentifyATA_slave

  mov eax, msg_master
  push eax
  call Print
  pop eax
  mov eax, 0xA0

  jmp IdentifyATA_select
  IdentifyATA_slave:

    mov eax, msg_slave
    push eax
    call Print
    pop eax
    mov eax, 0xB0
  IdentifyATA_select:
  out dx, al

  mov edx, 0x1F7
  in al, dx
  cmp al, 0xFF ; test if the drive is "floating"
  jne IdentifyATA_no_error
  IdentifyATA_error:
    call PrintError
    jmp IdentifyATA_end

  IdentifyATA_no_error:

  mov edx, 0x1F6 ; select the appropriate
  mov ecx, [esp + 0x4]
  test ecx, ecx
  jz IdentifyATA_slave2
  mov eax, 0xA0
  jmp IdentifyATA_select2
  IdentifyATA_slave2:
    mov eax, 0xB0
  IdentifyATA_select2:
  out dx, al

  xor eax, eax ; eax = 0
  ; set sectorCount, lbalo, lbamid, and lbahi
  ; IO ports to 0
  mov edx, 0x1F2
  out dx, al
  add edx, 1
  out dx, al
  add edx, 1
  out dx, al
  add edx, 1
  out dx, al

  ; send IDENTIFY command to Command IO port
  mov eax, 0xEC
  mov edx, 0x1F7
  out dx, al
  in al, dx
  and al, 0x000000FF
  test eax, eax
  jz IdentifyATA_error

  IdentifyATA_end:
  ret

;void FlushATA()
FlushATA:
  mov edx, 0x1F6 ; drive select port
  mov eax, 0xA0 ; select the master
  out dx, al

  add edx, 1 ; command port
  mov eax, 0xE7 ; send flush command
  out dx, al

  FlushATA_wait:
    in al, dx ; grab a status byte lmao
    test al, 0x80 ; is the BSY flag set?
    jne FlushATA_wait

  test al, 0x1 ; is the error flag set?
  jne FlushATA_error
  jmp FlushATA_done
  FlushATA_error:
    mov eax, msg_flush_error
    push eax
    call Print
    pop eax
  FlushATA_done:
    ret

; NOTE(Noah): This function expects an entire 512 bytes bro!
; ecx = LBA
; edi = bytes to write!
WriteATA:
  bswap ecx
  mov al, cl ; bits 24 to 32 of LBA
  and al, 0x0F ; snag only bits 24 to 28
  or al, 0xE0 ; we are going to select the master ATA
  mov edx, 0x1F6 ; port 1f6 which is the drive select port
  out dx, al
  bswap ecx

  mov edx, 0x1F2 ; dx = sectorcount port
  mov al, 1 ; set al = sector count ; NOTE(Noah): 0 means 256 sectors
  out dx, al

  mov al, cl
  inc edx ; port 1f3 which is lba_low
  out dx, al

  mov al, ch
  inc edx ; port 1f4 which is lba_mid
  out dx, al

  ; BSWAP - Byte Swap
  ; Reverses the byte order of a 32-bit or 64-bit (destination) register.
  ; This instruction is provided for converting litte-endian values to
  ; big -endian format and vise versa
  ; Isn't that awesome!?

  bswap ecx
  mov al, ch ; bits 16 to 23 of LBA
  inc edx ; port 1f5 which is lba_high
  out dx, al

  add edx, 2 ; command port
  mov al, 0x30 ; write command
  out dx, al

  call PollATA
  jc WriteATA_fail

  mov edx, 0x1F0 ; set the port to the dataPort
  mov ecx, 256
  WriteATA_write:
    mov ax, [edi]; get the data to write
    out dx, ax ; write short
    add edi, 2; increment data pointer
    dec ecx
    jg WriteATA_write

  or dl, 7 ; point dx back at the status register
  in al, dx ; delay 400ns to allow drive to set new values of BSY and DRQ
  in al, dx
  in al, dx
  in al, dx

    ; after each DRQ data block it's mandatory to either:
    ; recieve and ack the IRQ -- or poll the status port all over again
  test al, 0x21
  je WriteATA_done

  WriteATA_fail:
    stc
  WriteATA_done:
    ret


; NOTE(Noah): This function will always read 512 bytes, you were warned!
; param:
; ecx = LBA
; edi = storageLocation
ReadATA:
  bswap ecx
  mov al, cl ; bits 24 to 32 of LBA
  and al, 0x0F ; snag only bits 24 to 28
  or al, 0xE0 ; we are going to select the master ATA
  mov edx, 0x1F6 ; port 1f6 which is the drive select port
  out dx, al
  bswap ecx

  mov edx, 0x1F2 ; dx = sectorcount port
  mov al, 1 ; set al = sector count ; NOTE(Noah): 0 means 256 sectors
  out dx, al

  mov al, cl
  inc edx ; port 1f3 which is lba_low
  out dx, al

  mov al, ch
  inc edx ; port 1f4 which is lba_mid
  out dx, al

  ; BSWAP - Byte Swap
  ; Reverses the byte order of a 32-bit or 64-bit (destination) register.
  ; This instruction is provided for converting litte-endian values to
  ; big -endian format and vise versa
  ; Isn't that awesome!?

  bswap ecx
  mov al, ch ; bits 16 to 23 of LBA
  inc edx ; port 1f5 which is lba_high
  out dx, al

  add edx, 2 ; port 1f7 which is the command / status port
  mov al, 0x20 ; send "read" command to drive
  out dx, al

  ; so we are going to ignore the error bit for the first 4 status reads --
  ; ie. implement 400ns delay on ERR only
  ; here, we wait for BSY clean and DRQ set

  ; TEST - logical compare
  ; Computes the bit-wise logical AND of first operand and the second
  ; operand and sets the SF, ZF, and PF status flags according to the
  ; result. The result is then discarded

  call PollATA
  jc ReadATA_fail

  ReadATA_data_ready:
    mov edx, 0x1F0 ; read from data port (0x1f0)
    mov cx, 256
    rep insw ; gulp one 512b sector into edi?
    or dl, 7 ; point dx back at the status register
    in al, dx ; delay 400ns to allow drive to set new values of BSY and DRQ
    in al, dx
    in al, dx
    in al, dx

    ; after each DRQ data block it's mandatory to either:
    ; recieve and ack the IRQ -- or poll the status port all over again
    test al, 0x21
    je ReadATA_done

  ReadATA_fail:
    stc ; set the carry flag
  ReadATA_done:
    ret
