#define INTERNAL static

extern "C" void InterruptIgnore();
extern "C" void HandleInterruptRequest0x00();
extern "C" void HandleInterruptRequest0x01();
extern "C" void SetupPIC();
extern "C" void LaunchInterruptTable();

#include "interrupts.h"
#include "gdt.h"

INTERNAL void SetupInterruptDescriptorTableEntry(interrupt_descriptor *idt, unsigned char interruptNumber, unsigned short codeSegmentSelectorOffset, void *handler, unsigned char descriptorPriviledgeLevel, unsigned char descriptorType)
{
  idt[interruptNumber].handlerAddressLowBits = (unsigned int)handler & 0xFFFF;
  idt[interruptNumber].handlerAddressHighBits = ((unsigned int)handler >> 16) & 0xFFFF;
  idt[interruptNumber].gdt_codeSegmentSelector = codeSegmentSelectorOffset;
  idt[interruptNumber].reserved = 0;
  idt[interruptNumber].accessRights = 0x80 | descriptorType | ((descriptorPriviledgeLevel&3) << 5);
}

extern "C" void SetupInterrupts(global_descriptor_table *gdt, interrupt_descriptor *idt)
{
  //get the code segment
  unsigned short codeSegment = 0;
  for (unsigned int i = 0; i < 4; i++)
  {
    if (gdt->keys[i] == 2){
      codeSegment = i * 0x8;
    }
  }

  unsigned char IDT_INTERRUPT_GATE = 0xF;

  //set all the interrupts to interrupt ignore
  for (unsigned int i = 0; i < 256; i++)
  {
    SetupInterruptDescriptorTableEntry(idt, i, codeSegment, (void *)InterruptIgnore, 0, IDT_INTERRUPT_GATE);
  }

  //set up timer interrupt
  SetupInterruptDescriptorTableEntry(idt, 0x20, codeSegment, (void *)HandleInterruptRequest0x00, 0, IDT_INTERRUPT_GATE);

  //set up keyboard interrupt
  SetupInterruptDescriptorTableEntry(idt, 0x21, codeSegment, (void *)HandleInterruptRequest0x01, 0, IDT_INTERRUPT_GATE);

  SetupPIC();
  LaunchInterruptTable();
}
