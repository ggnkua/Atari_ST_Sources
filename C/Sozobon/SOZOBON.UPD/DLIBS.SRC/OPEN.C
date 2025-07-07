#include <osbind.h>
#include <stdio.h>
#include <fcntl.h>
#include <errno.h>

int open(filename, iomode, pmode)
	register char *filename;
	register int iomode, pmode;
	{
	register int rv;

	if(access(filename, 0x00))		/* file exists */
		{
		if((iomode & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
			return(errno = EEXIST);
		if(iomode & O_TRUNC)
			rv = creat(filename, 0x00);
		else
			rv = Fopen(filename, (0x03 & iomode));
		}
	else					/* file doesn't exist */
		{
		if(iomode & O_CREAT)
			rv = creat(filename, pmode);
		else
			rv = EFILNF;
		}
	if((rv >= 0) && (iomode & O_APPEND))
		lseek(rv, 0L, SEEK_END);
	if(rv < (-3))
		errno = rv;
	return(rv);
	}

int close(handle)
	int handle;
	{
	return(errno = ((int) Fclose(handle)));
	}
