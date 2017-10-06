#include <osbind.h>
#include <stdio.h>
#include <stat.h>
#include <errno.h>

int creat(filename, pmode)
	register char *filename;
	register int pmode;
	{
	register int rv;

	rv = Fdelete(filename);
	if((rv == 0) || (rv == EFILNF))    /* SUCCESS or FILE-NOT-FOUND */
		rv = Fcreate(filename, (pmode & 0x0F));
	return(errno = rv);
	}
