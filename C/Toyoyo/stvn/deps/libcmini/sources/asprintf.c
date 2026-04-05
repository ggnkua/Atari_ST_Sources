#include <stdarg.h>
#include <stdlib.h>
#include <mint/osbind.h>


#ifndef __USE_GNU
# define __USE_GNU  /* needed for vasprintf() */
# define TEMP_USE_GNU 1
#else
# define TEMP_USE_GNU 0
#endif

#include <stdio.h>

#if TEMP_USE_GNU == 1
# undef __USE_GNU
#endif


int
asprintf(char** strp, const char* format, ...)
{
    int len;

    va_list ap;
    va_start(ap, format);

    len = vasprintf(strp, format, ap);

    va_end(ap);

    return len;
}
