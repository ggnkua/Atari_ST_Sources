#include <stdio.h>

int fflush(FILE *stream)
{
	stream->__pushback = EOF;
#ifdef STDIO_MAP_NEWLINE
    stream->__last_char = EOF;
#endif /* defined STDIO_MAP_NEWLINE */
	return 0;
}

