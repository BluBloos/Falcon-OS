#include <gdt.h>
#include <interrupts.h>
#include <falcon.h>
#include <falcon_messages.h>
#include <strings.h>

extern "C" void *GetPrograms(unsigned int *length);
extern "C" void Print(char *string);
extern "C" void SetupGlobalDescriptorTable(global_descriptor_table *gdt);
extern "C" void SetupInterrupts(global_descriptor_table *gdt, interrupt_descriptor *idt);
extern "C" interrupt_descriptor *GetInterruptDescriptorTable();
extern "C" void EnableInterrupts();

FALCON_PROGRAM(Terminal);

program CreateProgram(falcon_program *function)
{
  program newProgram;
  newProgram.id = 0;
  newProgram.PassKeyEvent = 0;
  newProgram.Entry = function;
  return newProgram;
}

void Run(program p, int argc, char **argv)
{
  p.Entry(p.id, argc, argv);
}

void RegisterForMessages(int id, falcon_event event)
{
  unsigned int length = 0;
  program *programs =  (program *)GetPrograms(&length);
  programs[id].PassKeyEvent = event;
}

extern "C" void Kernel()
{
  //Print("Initializing Falcon OS version 0.0.1\n");

  global_descriptor_table gdt;
  SetupGlobalDescriptorTable(&gdt);

  interrupt_descriptor *idt = GetInterruptDescriptorTable();
  SetupInterrupts(&gdt, idt);
  EnableInterrupts();

  Print("root:/>");

  program terminal = CreateProgram(Terminal);
  Run(terminal, 0, NULL);

  while(1); //Here we do an inifinite loop since it wouldn't make sense for
  //the kernel to return
}
