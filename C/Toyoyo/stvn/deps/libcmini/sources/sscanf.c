#include <stdarg.h>

#ifndef __USE_ISOC99
# define __USE_ISOC99  /* needed for vsscanf() */
# define TEMP_USE_ISOC99 1
#else
# define TEMP_USE_ISOC99 0
#endif

#include <stdio.h>

#if TEMP_USE_ISOC99 == 1
# undef __USE_ISOC99
#endif


int
sscanf(const char* str, const char* format, ...)
{
    int ret;
    va_list va;

    va_start(va, format);
    ret = vsscanf(str, format, va);
    va_end(va);

    return ret;
}
