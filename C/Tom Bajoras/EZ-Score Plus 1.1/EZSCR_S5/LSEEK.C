#include <errno.h>
#include <osbind.h>

long lseek(fildes, offset, whence)
int fildes;
long offset;
int whence;
{
    long retval, fpos, leof;
    int temp;

/*myputs("lseek");*/
    if (fildes < 0)	/* can't seek on a device */	/* ST Specific */
	return -1L;

    if ((retval = Fseek(offset, fildes, whence)) >= 0)
	return retval;	/* normal seek */
/*myputs("not a normal seek");*/

    /* Trying to seek past EOF, must extend file */
    fpos = Fseek(0L, fildes, 1);
    leof = Fseek(0L, fildes, 2);
    if (whence == 1) offset = fpos+offset;
    else if (whence == 2) offset = leof+offset;
    else if (whence) return -1L;

    if (offset > leof)	/* extend file with random garbage from stack */
	Fwrite(fildes, offset-leof, &temp);
    if (errno = Fseek(offset, fildes, 0) < 0)
	return -1L;
    else {
	errno = 0;
	return offset;
    }
}
