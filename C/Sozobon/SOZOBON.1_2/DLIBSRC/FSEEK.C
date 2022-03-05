#include <osbind.h>
#include <stdio.h>
#include <errno.h>

long ftell(fp)
	register FILE *fp;
	{
	register long rv;

	fflush(fp);
	rv = Fseek(0L, fp->_file, 1);
	return((rv < 0) ? ((errno = ((int) rv)), (-1)) : rv);
	}

int fseek(fp, offset, origin)
	register FILE *fp;
	long offset;
	int origin;
	{
	register long rv;

	fflush(fp);
	rv = Fseek(offset, fp->_file, origin);
	return((rv < 0) ? ((errno = ((int) rv)), (-1)) : 0);
	}

void rewind(fp)
	register FILE *fp;
	{
	register long rv;

	fflush(fp);
	rv = Fseek(0L, fp->_file, SEEK_SET);
	if(rv < 0)
		errno = ((int) rv);
	fp->_flag &= ~(_IOEOF|_IOERR);
	}
