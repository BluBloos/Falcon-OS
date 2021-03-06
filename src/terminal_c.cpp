#include <falcon.h>
#include <falcon_messages.h>
#include <strings.h>

extern "C" void Print(char *string);
extern "C" void GetCaret(unsigned short *row, unsigned short *column);
extern "C" void SetCaret(unsigned short row, unsigned short column);

void RegisterForMessages(int p, falcon_event event);
program CreateProgram(falcon_program *function);

FALCON_PROGRAM(HelloWorld);
FALCON_PROGRAM(Fib);

static char terminalBuffer[2000];
short offset;
unsigned short region_row;
unsigned short region_column;

void Reset()
{
  for (unsigned int i = 0;i < 2000; i++)
  {
    terminalBuffer[i] = 0;
  }
  offset = 0;
}

void UpdateRegion()
{
  GetCaret(&region_row, &region_column);
}

void UpdateCaret()
{
  short newRow = region_row;
  short newColumn = region_column;

  for (unsigned int i=0;i<offset;i++) //go for offsert many times
  {
    newColumn++;
    if(newColumn > 79)
    {
      newRow++;
      if(newRow>24)
      {
        newRow = region_row;
      }
      newColumn = 0;
    }
  }

  SetCaret(newRow, newColumn);
}

command_result Submit(char *buffer)
{
  command_result result;
  result.msg = FM_ERROR;
  if(StringEquals(buffer, "hello"))
  {
    result.msg = FM_SUCCESS;
    result.exec = CreateProgram(HelloWorld);
  } else if (StringEquals(buffer, "fib"))
  {
    result.msg = FM_SUCCESS;
    result.exec = CreateProgram(Fib);
  }
  return result;
}

FALCON_EVENT(TerminalMessageProc)
{
  switch (code)
  {
    case FM_ENTER_PRESS:
    {
      command_result result = Submit(terminalBuffer);
      Print("\n");
      if(result.msg != FM_SUCCESS) {
        Print("command not found\nroot:/>");
      } else
      {
        // TODO(Noah): Add ability for parameters
        result.exec.Entry(result.exec.id, 0, NULL);
        Print("\nroot:/>");
      }
      UpdateRegion();
      Reset();
    }
    break;
    case FM_SPACE_PRESS:
      offset++;
      UpdateCaret();
    break;
    case FM_BACKSPACE_PRESS:
      offset--;
      if(offset < 0){
        offset = 0;
      }
      UpdateCaret();
    break;
    case FM_NULL:
      //do nothing
    break;
    default:
    {
      char ascii = code + 'a';
      char stringBuffer[2];
      stringBuffer[0] = ascii;
      stringBuffer[1] = 0;
      Print(stringBuffer);
      terminalBuffer[offset++] = ascii;
      UpdateCaret();
    }
    break;
  }
}

FALCON_PROGRAM(Terminal)
{
  Reset();
  UpdateRegion();

  RegisterForMessages(id, TerminalMessageProc);
  while(1)
  {
    //main terminal loop
  }
}
