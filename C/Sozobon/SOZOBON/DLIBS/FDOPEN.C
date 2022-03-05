#include <stdio.h>
#include <fcntl.h>

extern	FILE	_iob[];

FILE *fdopen(h, mode)
	register int h;
	register char *mode;
	{
	register char *p = NULL;
	register int i, iomode = 0, f = 0;
	register FILE *fp = NULL;

	for(i=0; (!fp && (i < _NFILE)); ++i)
		if(!(_iob[i]._flag & (_IOREAD | _IOWRT)))   /* empty slot? */
			fp = &_iob[i];
	if(!fp)
		return(NULL);
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
				fputs(stderr, "Illegal file mode.\n");
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
