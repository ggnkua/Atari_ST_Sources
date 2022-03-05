#include <stdio.h>
#include <fcntl.h>
#include <malloc.h>
#include <errno.h>

#define	LAST_DEVICE	(-3)		/* lowest character device handle # */

static FILE *_fopen(filename, mode, fp)
	char *filename;
	register char *mode;
	register FILE *fp;
/*
 *	INTERNAL FUNCTION.  Attempt to open <filename> in the given
 *	<mode> and attach it to the stream <fp>
 */
	{
	register char *p = NULL;
	register int h, i, iomode = 0, f = 0;

	while(*mode)
		{
		switch(*mode++)
			{
			case 'r':
				f |= _IOREAD;
				break;
			case 'w':
				f |= _IOWRT;
				iomode |= (O_CREAT | O_TRUNC);
				break;
			case 'a':
				f |= _IOWRT;
				iomode |= (O_CREAT | O_APPEND);
				break;
			case '+':
				f |= (_IOREAD | _IOWRT);
				break;
			case 'b':
				f |= _IOBIN;
				break;
			case 't':
				f &= ~_IOBIN;
				break;
			default:
				fputs("Illegal file mode.\n", stderr);
				return(NULL);
			}
		}
	if((i = (f & (_IOREAD | _IOWRT))) == 0)
		return(NULL);
	else if(i == _IOREAD)
		iomode |= O_RDONLY;
	else if(i == _IOWRT)
		iomode |= O_WRONLY;
	else
		iomode |= O_RDWR;
	h = open(filename, iomode, 0x00);
	if(h < LAST_DEVICE)
		{
		errno = h;
		return(NULL);		/* file open/create error */
		}
	if(isatty(h))
		f |= (_IODEV | _IONBF);
	else
		f |= _IOFBF;
	fp->_file = h;			/* file handle */
	fp->_flag = f;			/* file status flags */
	fp->_base = NULL;		/* base of file buffer */
	fp->_ptr = NULL;		/* current buffer pointer */
	fp->_bsiz = 0;			/* buffer size */
	fp->_cnt = 0;			/* # of bytes in buffer */
	return(fp);
	}

FILE *fopen(filename, mode)
	char *filename, *mode;
	{
	register int i;
	register FILE *fp = NULL;

	for(i=0; (!fp && (i < _NFILE)); ++i)
		if(!(_iob[i]._flag & (_IOREAD | _IOWRT)))   /* empty slot? */
			fp = &_iob[i];
#if 0
	if(fp)
		return(_fopen(filename, mode, fp));
	else
		return(NULL);
#else
	return(fp ? _fopen(filename, mode, fp) : NULL);
#endif
	}

FILE *freopen(filename, mode, fp)
	char *filename, *mode;
	FILE *fp;
	{
#if 0
	if(fclose(fp))
		return(NULL);
	else
		return(_fopen(filename, mode, fp));
#else
	return(fclose(fp) ? NULL : _fopen(filename, mode, fp));
#endif
	}
