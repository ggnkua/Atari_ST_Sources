#include <stdio.h>
#include <stdarg.h>
#include "lib.h"


static int getchar_func(void *fp);


int
vsscanf(const char* str, const char* format, va_list va)
{
    struct _mem_stream stream;

    stream.xstring  = (char *)NO_CONST(str);
    stream.xestring = NULL;

    return doscan(getchar_func, NULL, &stream, format, va);
}


int
getchar_func(void* fp)
{
    struct _mem_stream* stream = fp;
    int ch = *stream->xstring;

    if (ch == '\0') {
        ch = EOF;
    } else {
        ++stream->xstring;
    }

    return ch;
}
