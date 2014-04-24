#include <stdio.h>
extern long lseek();

int fseek(stream, offset, ptrname)
register FILE *stream;
long offset;
int ptrname;
{
    if (fflush(stream))     /* error during flush */
	return -1;
    stream->_flag &= ~_EOF;    /* reset eof condition */
    stream->_mark = lseek(stream->_fd, offset, ptrname);
    return 0;
}

rewind(stream)
FILE *stream;
{
    fseek(stream, 0L, 0);
    return 0;
}

long ftell(stream)
register FILE *stream;
{
    return stream->_mark + (long)stream->_ptr - (long)stream->_base;
}
