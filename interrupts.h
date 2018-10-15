#pragma pack(1)
struct interrupt_descriptor
{
  unsigned short handlerAddressLowBits;
  unsigned short gdt_codeSegmentSelector;
  unsigned char reserved;
  unsigned char accessRights;
  unsigned short handlerAddressHighBits;
};
#pragma pop
