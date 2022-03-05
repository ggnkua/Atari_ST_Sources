#include <errno.h>

extern	long	gemdos();

int write(h, data, len)
	int h;
	char *data;
	unsigned int len;
	{
	register long rv;

	rv = gemdos(0x40, h, ((unsigned long) len), data);
	if(rv < 0)
		errno = ((int) rv);
	return(rv);
	}

long lwrite(h, data, len)
	int h;
	char *data;
	long len;
	{
	register long rv;

	rv = gemdos(0x40, h, len, data);
	if(rv < 0)
		errno = ((int) rv);
	return(rv);
	}
