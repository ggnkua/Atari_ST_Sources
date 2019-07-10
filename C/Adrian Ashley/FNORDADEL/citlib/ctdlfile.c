/*
 * ctdlfile.c -- construct a filename in a Fnordadel directory
 *
 * 90Aug27 AA	Split from libdep.c
 */

#include "ctdl.h"
#include "config.h"
#include "citlib.h"
#include <stdarg.h>

char *
ENDOFSTR(s)
char *s;
{
    while (*s)
	++s;
    return s;
}

void
ctdlfile(char *dest, OFFSET dir, char *fmt, ...)	/* varargs! */
{
    va_list ptr;

    sprintf(dest, "%s\\", &cfg.codeBuf[dir]);
    va_start(ptr, fmt);
    vsprintf(ENDOFSTR(dest), fmt, ptr);
    va_end(ptr);
}
