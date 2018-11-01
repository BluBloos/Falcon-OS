#define INTERNAL static
#define NULL 0

#define FALCON_EVENT(name) void name(unsigned char code)
typedef FALCON_EVENT(falcon_event);

#define FALCON_PROGRAM(name) void name(int id, int argc, char **argv)
typedef FALCON_PROGRAM(falcon_program);

struct program
{
  int id;
  falcon_program *Entry;
  falcon_event *PassKeyEvent;
};

struct command_result
{
  program exec;
  unsigned char msg;
};
