/*
 * xfuncs.c -- various do-something-or-die functions
 *
 * 90Nov06 AA	Make xmalloc() a void * function.  Wheee!
 * 90Aug27 AA	Split from libdep.c
 */

#include "ctdl.h"

int
xopen(char *filename)
{
    register int fd;

    if ((fd = dopen(filename, O_RDWR)) < 0)
	crashout("No %s", filename);
    return fd;
}

void *
xmalloc(unsigned int size)
{
    void *memory, *malloc();

    if (memory = malloc(size))
	return memory;
    crashout("out of memory");
}

char *
xstrdup(char *string)
{
    char *memory, *strdup();

    if (memory = strdup(string))
	return memory;
    crashout("out of memory");
}
