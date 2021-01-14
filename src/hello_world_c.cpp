#include <falcon.h>

extern "C" void Print(char *string);

FALCON_PROGRAM(HelloWorld)
{
  Print("Hello, World!");
}
