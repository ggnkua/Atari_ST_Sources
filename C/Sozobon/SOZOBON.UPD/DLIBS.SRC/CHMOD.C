#include <osbind.h>
#include <stdio.h>
#include <errno.h>

int chmod(filename, pmode)
	char *filename;
	int pmode;
	{
	register int rv;

	if((rv = Fattrib(filename, 1, (pmode & 0x0F))) < 0)
		return(errno = rv);
	return(0);
	}
