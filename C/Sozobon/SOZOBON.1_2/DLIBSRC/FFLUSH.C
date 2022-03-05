#include <stdio.h>

extern	FILE	_iob[];

int fflush(fp)
	register FILE *fp;
/*
 *	implementation note:  This function has the side effect of
 *	re-aligning the virtual file pointer (in the buffer) with
 *	the actual file pointer (in the file) and is therefore used
 *	in other functions to accomplish this re-sync operation.
 */
	{
	register int f, i;

 	if(fp)
		return(_fflush(fp));
	else
		{
		for(i=0; i<_NFILE; ++i)
			{
			f = _iob[i]._flag;
			if(f & (_IOREAD | _IOWRT))
				_fflush(&_iob[i]);
			}
		return(0);
		}
	}

static int _fflush(fp)
	register FILE *fp;
	{
	register int f, rv = 0, c;
	register long offset;

 	if(fp == NULL)
		return(0);
	f = fp->_flag;
	if((f & _IODEV)				/* file is a device */
	|| (!(f & (_IOREAD | _IOWRT))))		/* file not open! */
		return(0);
	if(fp->_cnt)				/* data in the buffer */
		{
		if(f & _IORW)				/* writing */
			{
			if(write(fp->_file, fp->_base, fp->_cnt) != fp->_cnt)
				{
				fp->_flag |= _IOERR;
				rv = EOF;
				}
			}
		else					/* reading */
			{
			offset = -(fp->_cnt);
			if(lseek(fp->_file, offset, 1) < 0)
				rv = EOF;
			}
		}
	fp->_ptr = fp->_base;
	fp->_cnt = 0;
	return(rv);
	}
