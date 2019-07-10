/*
 * crashout() -- print an error message, then exit
 */

#include "ctdl.h"
#include <stdarg.h>

extern char *program;

void
crashout(char *fmt, ...)
{
    va_list arg;

    va_start(arg, fmt);
    fprintf(stderr, "%s: ", program);
    vfprintf(stderr, fmt, arg);
    va_end(arg);
    fputs(".\n", stderr);
    if (fromdesk())
	hitkey();
    exit(CRASH_EXIT);
}
