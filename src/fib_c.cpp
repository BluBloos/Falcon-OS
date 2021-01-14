#include <falcon.h>

void ByteToHex(unsigned char number, char *dest, bool isParent);
extern "C" void Print(char *string);


int fib(int n)
{
	if (n <= 1)
		return n;
	return fib(n - 1) + fib(n - 2);
}

FALCON_PROGRAM(Fib)
{
  for (unsigned int i = 0; i < 10; i++)
  {
	 int result = fib(i);
	 char buffer[256];	 	
	 ByteToHex((char)result, buffer, true);
	 Print(buffer);
	 Print("\n"); 
  }
}
