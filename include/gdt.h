// -------------- GDT ------------
// limit 0:15 2 bytes
// base 0:15 2 bytes
// base 16:23 byte
// access byte
// limit 16:19 half byte
// flags half byte
// base 24:31 byte
// -------------------------------
#pragma pack(1)
struct global_descriptor_table_selector
{
  unsigned short limitLow;
  unsigned short baseLow;
  unsigned char baseLow2;
  unsigned char accessRights;
  unsigned char limitHighAndFlags;
  unsigned char baseHigh;
};
#pragma pop

#pragma pack(1)
struct global_descriptor_table
{
  global_descriptor_table_selector *descriptors;
  unsigned int keys[4];
  /*
  0 = null
  1 = unused
  2 = code
  3 = 4
  */
};
#pragma pop
