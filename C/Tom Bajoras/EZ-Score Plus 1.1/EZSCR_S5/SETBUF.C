#include <stdio.h>

setbuf(stream, buf)
FILE *stream;
char *buf;
{
    if (buf == NULL)
	stream->_flag |= _UNBUF;
    else
	stream->_base = buf;
}
