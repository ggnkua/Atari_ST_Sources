#include <stdio.h>
#include <errno.h>

int chdir(pathname)
	char *pathname;
	{
	return(errno = gemdos(0x3B, pathname));
	}
