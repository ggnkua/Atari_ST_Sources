#include <stdio.h>
#include <errno.h>

long lseek(h, where, how)
	int h;
	long where;
	int how;
	{
	register long rv;

	rv = gemdos(0x42, where, h, how);
	if(rv < 0)
		errno = ((int) rv);
	return(rv);
	}

long tell(h)
	int h;
	{
	return(lseek(h, 0L, SEEK_CUR));
	}
