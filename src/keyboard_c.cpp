#include <falcon.h>
#include <falcon_messages.h>

#define SPACE 0x39
#define BACKSPACE 0x0E
#define ENTER 0x1C

extern "C" void Print(char *string);
extern "C" void *GetPrograms(unsigned int *length);

void AdvanceCaret();
void DecrementCaret();
void NewLine();

//this function returns ascii rep
//it really is just a mapping
//also we don't support capitals right now
/*
unsigned char ProcessSSC1(unsigned char code)
{
  switch (code) {
    case 0x1E:
      return 'a';
    case 0x30:
      return 'b';
    case 0x2E:
      return 'c';
    case 0x20:
      return 'd';
    case 0x12:
      return 'e';
    case 0x21:
      return 'f';
    case 0x22:
      return 'g';
    case 0x23:
      return 'h';
    case 0x17:
      return 'i';
    case 0x24:
      return 'j';
    case 0x25:
      return 'k';
    case 0x26:
      return 'l';
    case 0x32:
      return 'm';
    case 0x31:
      return 'n';
    case 0x18:
      return 'o';
    case 0x19:
      return 'p';
    case 0x10:
      return 'q';
    case 0x13:
      return 'r';
    case 0x1F:
      return 's';
    case 0x14:
      return 't';
    case 0x16:
      return 'u';
    case 0x2F:
      return 'v';
    case 0x11:
      return 'w';
    case 0x2D:
      return 'x';
    case 0x15:
      return 'y';
    case 0x2C:
      return 'z';
    case SPACE:
      AdvanceCaret(); //moves it one space
      return 0;
    case BACKSPACE:
      DecrementCaret();
      return 0;
    case ENTER:
      SubmitBuffer();
      return 0;
    default:
      return 0;
  }
  return 0;
}
*/

unsigned char ProcessSSC1(unsigned char code)
{
  switch (code) {
    case 0x1E:
      return FM_A_PRESS;
    case 0x30:
      return FM_B_PRESS;
    case 0x2E:
      return FM_C_PRESS;
    case 0x20:
      return FM_D_PRESS;
    case 0x12:
      return FM_E_PRESS;
    case 0x21:
      return FM_F_PRESS;
    case 0x22:
      return FM_G_PRESS;
    case 0x23:
      return FM_H_PRESS;
    case 0x17:
      return FM_I_PRESS;
    case 0x24:
      return FM_J_PRESS;
    case 0x25:
      return FM_K_PRESS;
    case 0x26:
      return FM_L_PRESS;
    case 0x32:
      return FM_M_PRESS;
    case 0x31:
      return FM_N_PRESS;
    case 0x18:
      return FM_O_PRESS;
    case 0x19:
      return FM_P_PRESS;
    case 0x10:
      return FM_Q_PRESS;
    case 0x13:
      return FM_R_PRESS;
    case 0x1F:
      return FM_S_PRESS;
    case 0x14:
      return FM_T_PRESS;
    case 0x16:
      return FM_U_PRESS;
    case 0x2F:
      return FM_V_PRESS;
    case 0x11:
      return FM_W_PRESS;
    case 0x2D:
      return FM_X_PRESS;
    case 0x15:
      return FM_Y_PRESS;
    case 0x2C:
      return FM_Z_PRESS;
    case SPACE:
      return FM_SPACE_PRESS;
    case BACKSPACE:
      return FM_BACKSPACE_PRESS;
    case ENTER:
      return FM_ENTER_PRESS;
    default:
      return FM_NULL;
  }
  return 0;
}

extern "C" void HandleKey(unsigned char code)
{
  // parse the message
  unsigned char character = ProcessSSC1(code);

  // send off the parsed message
  unsigned int length = 0;
  program *programs = (program *)GetPrograms(&length);
  for (unsigned int i = 0; i < length; i++)
  {
    program p = programs[i];
    if(p.PassKeyEvent)
    {
      p.PassKeyEvent(character);
    }
  }
}
