#include <osbind.h>
#include <stdio.h>
#include <errno.h>

int fwrite(data, size, count, fp)
	register char *data;
	int size;
	int count;
	register FILE *fp;
	{
	register long n, m, lsiz;
	register int f, c;

	f = (fp->_flag |= _IORW);
	lsiz = ((long) size);
	n = ((long) count) * lsiz;
	if(f & _IODEV)			/* device i/o */
		{
		for(m=0; m<n; ++m)
			if(fputc(*data++, fp) == EOF)
				break;
		}
	else				/* file i/o */
		{
		fflush(fp);			/* re-sync file pointers */
		m = Fwrite(fp->_file, n, data);
		}
	return((m > 0) ? (m / lsiz) : (errno = ((int) m)));
	}
