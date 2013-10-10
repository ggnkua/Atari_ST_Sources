#include <errno.h>
#include <osbind.h>
#include <stdio.h>

int close(fildes)
int fildes;
{
    _binrem(fildes);
    if (fildes <= STDIN)
	return 0;

    if (errno = Fclose(fildes)) -1; else 0;
}
