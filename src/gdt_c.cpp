#include "gdt.h"

extern "C" void SetGdt();

void WriteDescriptor(global_descriptor_table_selector *gdt, unsigned int index, unsigned int limit, unsigned int base, unsigned char privil, bool ex, bool dc, bool rw, bool gr)
{
  //calculate the limit based on the granularity
  unsigned int limitCalc = 0;
  if (gr) {
    limitCalc = limit / 4096;
  } else {
    limitCalc = limit;
  }

  //caluclate accessRights
  unsigned char accessRights = 0;
  if (privil > 2) {
    accessRights = (1 << 7) | (1 << 6) | (1 << 4) | (ex << 3) | (dc << 2) | (rw << 1);
  }else {
    accessRights = (1 << 7) | (privil << 5) | (1 << 4) | (ex << 3) | (dc << 2) | (rw << 1);
  }

  gdt[index].limitLow = limitCalc & 0xFFFF;
  gdt[index].baseLow = base & 0xFFFF;
  gdt[index].baseLow2 = (base >> 16) & 0xFF;
  gdt[index].accessRights = accessRights;
  gdt[index].limitHighAndFlags = (gr << 7) | (1 << 6) | ((limitCalc >> 16) & 0xF);
  gdt[index].baseHigh = (base >> 24) & 0xFF;
}

extern "C" void SetupGlobalDescriptorTable(global_descriptor_table *gdt)
{
  //WriteDescriptor(gdt->descriptors,0,0,0,0,0,0,0,0); //null
  //WriteDescriptor(gdt->descriptors,1,0,0,0,0,0,0,0); //unused
  //WriteDescriptor(gdt->descriptors,2,64*1024*1024,0,0,1,0,1,1); //code
  //WriteDescriptor(gdt->descriptors,3,64*1024*1024,0,0,0,0,1,1); //data

  //setup keys
  for (unsigned int i = 0; i < 4; i++)
  {
    gdt->keys[i] = i;
  }

  SetGdt();
}
