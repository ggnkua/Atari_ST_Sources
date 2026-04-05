#include "lib.h"

#undef stdin
#undef stdout
#undef stderr

FILE *__stdio_head;

#ifdef STDIO_MAP_NEWLINE
# define LAST_CHAR_INIT  EOF,
#else
# define LAST_CHAR_INIT
#endif /* defined STDIO_MAP_NEWLINE */

FILE _StdInF =  { _IOMAGIC, (void *)0, EOF, LAST_CHAR_INIT NULL, { 1, 0 }, 0, 0 };
FILE _StdOutF = { _IOMAGIC, (void *)1, EOF, LAST_CHAR_INIT NULL, { 0, 1 }, 0, 0 };
FILE _StdErrF = { _IOMAGIC, (void *)2, EOF, LAST_CHAR_INIT NULL, { 0, 1 }, 0, 0 };

FILE *stdin = &_StdInF;
FILE *stdout = &_StdOutF;
FILE *stderr = &_StdErrF;
