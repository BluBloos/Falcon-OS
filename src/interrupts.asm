; ----- INTERRUPTS 101 ------------
; Alright let me lay down some straight facts
; 1. Make space for the intterupt descriptor table
; 2. Tell the CPU where that space is (lidt)
; 3. Tell the PIC that you no longer want to use the BIOS defaults
; 4. Write a couple of ISR handlers for both IRQs and exceptions
; 5. Put the addresses of the ISR handles in the appropriate descriptors
; 6. Enable all supported interrupts in the IRQ mask (of the PIC)
; ---------------------------------


[BITS 32]
global InterruptIgnore
global HandleInterruptRequest0x00
global HandleInterruptRequest0x01
global SetupPIC
global LaunchInterruptTable
global GetInterruptDescriptorTable
global EnableInterrupts

extern Print
extern HandleKey

section .data
msg_interrupt:
db "INTERRUPT",0
idt_start:
times 2048 db 0
idt_end:

section .text
EnableInterrupts:
	sti
	ret

;extern "C" interrupt_descriptor *GetInterruptDescriptorTable();
GetInterruptDescriptorTable:
  mov eax, idt_start
  ret

InterruptIgnore:
  iret

HandleInterruptRequest0x00:
  pusha

  ;Print("INTERRUPT")
  ;mov eax, msg_interrupt
  ;push eax
  ;call Print
  ;pop eax

  ;tell the pic that we recieved the interrupt
  mov al, 0x20
  out 0x20, al

  popa
  iret

HandleInterruptRequest0x01:
  pusha

  ;Print("INTERRUPT")
  ;mov eax, msg_interrupt
  ;push eax
  ;call Print
  ;pop eax

  ;fetch the key strike
  in al, 0x60

  ;print the key strike
	push eax
  call HandleKey
	pop eax


  ;tell the pic that we recieved the interrupt
  mov al, 0x20
  out 0x20, al

  popa
  iret

SetupPIC:
  ;initialize the master and slave PIC
  mov al, 0x11
  out 0x20, al ;picMasterCommand.write(0x11)
  out 0xA0, al ;picSlaveCommand.write(0x11)
  ;remap them
  mov al, 0x20
  out 0x21, al ;picMasterData.write(0x20)
  mov al, 0x28
  out 0xa1, al ;picSlaveData.write(0xa1)
  ;don't ask me what these next ones do
  mov al, 0x4
  out 0x21, al ;picMasterData.write(0x4)
  mov al, 0x2
  out 0xa1, al ;picSlaveData.write(0x2)
  ;set to 8086 mode
  mov al, 1
  out 0x21, al
  out 0xa1, al
  ;yeah,not sure
  xor eax, eax
  out 0x21, al
  out 0xa1, al
  ret

idtr:
  dw 0x07FF ; size
  dd idt_start ; base
LaunchInterruptTable:
  lidt [idtr]
  ret

; struct IDTDescr {
; short offset_1; //pointer to isr
; short selector; //must point to valid entry in descriptor
; char zero;
; char type_attr; p,dpl,s,gatetype
; short offset_2
;}

; gateype: 4 bits
;   0x5 80386 32 bit task gate
;   0x6 80286 16 bit interrupt gate
;   0x7 80286 16 bit trap gate
;   0xe 80386 32 bit interrupt gate
;   0xf 80386 32 bit trap gate
; s: This is the storage segment. 1 bit. Set to 0 for interrupt and trap gates
; dpl: 2 bits. Descriptor Privilege Level. Specefies which priviledge level the calling descriptor minimum should have.
; p: 1 bit. Set to 0 for unused interrupts
