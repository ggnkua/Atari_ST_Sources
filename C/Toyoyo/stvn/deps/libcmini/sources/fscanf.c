#include <stdarg.h>

#ifndef __USE_ISOC99
# define __USE_ISOC99  /* needed for vfscanf() */
# define TEMP_USE_ISOC99 1
#else
# define TEMP_USE_ISOC99 0
#endif

#include <stdio.h>

#if TEMP_USE_ISOC99 == 1
# undef __USE_ISOC99
#endif


/* Write formatted output to STREAM from the format string FORMAT.  */
/* VARARGS2 */
int
fscanf(FILE* stream, const char* format, ...)
{
    va_list arg;
    int done;

    va_start(arg, format);
    done = vfscanf(stream, format, arg);
    va_end(arg);

    return done;
}
