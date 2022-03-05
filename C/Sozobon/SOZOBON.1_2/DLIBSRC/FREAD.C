#include <osbind.h>
#include <stdio.h>
#include <errno.h>

int fread(data, size, count, fp)
	register char *data;
	int size;
	int count;
	register FILE *fp;
	{
	register long n, m, lsiz;
	register int f, c;

	f = (fp->_flag &= ~_IORW);
	lsiz = ((long) size);
	n = ((long) count) * lsiz;
	if(f & _IODEV)			/* device i/o */
		{
		for(m = 0; (m < n); ++m)
			{
			if((c = fgetc(fp)) == EOF)
				break;
			*data++ = c;
			} 
		}
	else				/* file i/o */
		{
		fflush(fp);			/* re-sync file pointers */
		m = Fread(fp->_file, n, data);
		}
	return((m > 0) ? (m / lsiz) : (errno = ((int) m)));
	}
