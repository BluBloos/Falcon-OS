//so what I want to do now is I want to save the location of the thing. So that when I print, it prints like after where the last thing was printed
#include "gdt.h"

extern "C" void GetCaret(unsigned short *row, unsigned short *column);
extern "C" void SetCaret(unsigned short row, unsigned short column);

void ByteToHex(unsigned char number, char *dest, bool isParent)
{
  if(isParent)
  {
    *dest++ = '0';
    *dest++ = 'x';
  }

  unsigned char bits = (number >> 4) & 0xF;
  if (bits < 10){
    *dest++ = bits + '0';
  }else{
    *dest++ = (bits - 10) + 'A';
  }
  bits = number & 0xF;
  if (bits < 10){
    *dest++ = bits + '0';
  }else{
    *dest++ = (bits - 10) + 'A';
  }

  if(isParent)
  {
    *dest = 0;
  }
}

void ShortToHex(unsigned short number, char *dest, bool isParent)
{
  if(isParent)
  {
    *dest++ = '0';
    *dest++ = 'x';
  }

  unsigned char charNumber = (number >> 8) & 0xFF;

  unsigned char bits = (charNumber >> 4) & 0xF;
  if (bits < 10){
    *dest++ = bits + '0';
  }else{
    *dest++ = (bits - 10) + 'A';
  }
  bits = charNumber & 0xF;
  if (bits < 10){
    *dest++ = bits + '0';
  }else{
    *dest++ = (bits - 10) + 'A';
  }

  charNumber = number & 0xFF;

  bits = (charNumber >> 4) & 0xF;
  if (bits < 10){
    *dest++ = bits + '0';
  }else{
    *dest++ = (bits - 10) + 'A';
  }
  bits = charNumber & 0xF;
  if (bits < 10){
    *dest++ = bits + '0';
  }else{
    *dest++ = (bits - 10) + 'A';
  }

  if(isParent)
  {
    *dest = 0;
  }
}

extern "C" void Print(char *str)
{
  unsigned short *videoMemory = (unsigned short *)0xb8000;

  unsigned short row = 0;
  unsigned short column = 0;
  GetCaret(&row, &column);

  for (unsigned int i= 0;str[i] != 0;i++)
  {
    unsigned char character = str[i];

    if (character == '\n')
    {
      column = 0;
      row++;
      if (row > 25)
      {
        row = 0;
      }
      continue;
    }

    //write the character
    videoMemory[row * 80 + column] = (videoMemory[row * 80 + column] & 0xFF00) | character;

    //advance the caret
    column++;
    if(column > 80)
    {
      row++;
      if (row > 25)
      {
        row = 0;
      }
      column = 0;
    }
  }

  SetCaret(row, column);
}

extern "C" void PrintError()
{
  Print("ERROR!");
}

extern "C" void DebugHexFunctions()
{
  Print("Printing byte values:\n");

  unsigned char newChar = 255;
  unsigned short newShort = 0xFF34;
  //create and clear the string buffer
  char stringBuffer[256];
  for (unsigned int i = 0; i < 256; i++)
  {
    stringBuffer[i] = 0;
  }

  ByteToHex(newChar, stringBuffer, true);
  Print(stringBuffer);
  Print("\n");

  newChar = 0x34;
  ByteToHex(newChar, stringBuffer, true);
  Print(stringBuffer);
  Print("\n");

  Print("Printing short values:\n");

  ShortToHex(newShort, stringBuffer, true);
  Print(stringBuffer);
  Print("\n");

  ByteToHex(newChar, stringBuffer, true);
  Print(stringBuffer);
  Print("\n");

}

extern "C" void DebugPrintShort(unsigned short value)
{
  char stringBuffer[256];
  for (unsigned int i = 0; i < 256; i++)
  {
    stringBuffer[i] = 0;
  }
  ShortToHex(value, stringBuffer, true);
  Print(stringBuffer);
}

extern "C" void DebugPrintByte(unsigned char value)
{
  char stringBuffer[256];
  for (unsigned int i = 0; i < 256; i++)
  {
    stringBuffer[i] = 0;
  }
  ByteToHex(value, stringBuffer, true);
  Print(stringBuffer);
}

extern "C" void DebugPrintGdt(global_descriptor_table *gdt)
{
  //create and clear the string buffer
  char stringBuffer[256];
  for (unsigned int i = 0; i < 256; i++)
  {
    stringBuffer[i] = 0;
  }

  Print("GDT:\n");

  for (unsigned int i = 0; i < 4; i++)
  {
    switch (gdt->keys[i]) {
      case 0:
        Print("NULL DESCRIPTOR:\n");
        break;
      case 1:
        Print("UNUSED DESCRIPTOR:\n");
        break;
      case 2:
        Print("CODE DESCRIPTOR:\n");
        break;
      case 3:
        Print("DATA DESCRIPTOR:\n");
        break;
      default:
        Print("NULL DESCRIPTOR:\n");
        break;
    }

    ShortToHex(gdt->descriptors[i].limitLow, stringBuffer, true);
    Print(stringBuffer);
    Print(", ");
    //Print("\n");


    ShortToHex(gdt->descriptors[i].baseLow, stringBuffer, true);
    Print(stringBuffer);
    Print(", ");
    //Print("\n");

    ByteToHex(gdt->descriptors[i].baseLow2, stringBuffer, true);
    Print(stringBuffer);
    Print(", ");
    //Print("\n");

    ByteToHex(gdt->descriptors[i].accessRights, stringBuffer, true);
    Print(stringBuffer);
    Print(", ");
    //Print("\n");

    ByteToHex(gdt->descriptors[i].limitHighAndFlags, stringBuffer, true);
    Print(stringBuffer);
    Print(", ");
    //Print("\n");

    ByteToHex(gdt->descriptors[i].baseHigh, stringBuffer, true);
    Print(stringBuffer);
    Print("\n");
  }
}
