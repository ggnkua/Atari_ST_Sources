#include <errno.h>

extern	long	gemdos();

int read(h, data, len)
	int h;
	char *data;
	unsigned int len;
	{
	register long rv;

	rv = gemdos(0x3F, h, ((unsigned long) len), data);
	if(rv < 0)
		errno = ((int) rv);
	return(rv);
	}

long lread(h, data, len)
	int h;
	char *data;
	long len;
	{
	register long rv;

	rv = gemdos(0x3F, h, len, data);
	if(rv < 0)
		errno = ((int) rv);
	return(rv);
	}
