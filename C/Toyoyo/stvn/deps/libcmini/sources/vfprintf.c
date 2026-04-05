#include <stdio.h>
#include <stdarg.h>
#include "lib.h"


static int fpc(int c, void *fp)
{
    FILE* stream = fp;
    return (putc(c, stream) == EOF) ? 0 : 1;
}

int vfprintf(FILE *stream, const char *format, va_list ap)
{
    return doprnt(fpc, stream, format, ap);
}
