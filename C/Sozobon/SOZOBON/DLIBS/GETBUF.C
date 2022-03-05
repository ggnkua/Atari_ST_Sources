#include <stdio.h>
#include <malloc.h>

static unsigned long	_blksiz = (1<<14);	/* 16K initial heap size */

static unsigned char *_malloc(size)
	int size;
	{
	register unsigned long _oldsiz;
	register unsigned char *rv;

	_oldsiz = _BLKSIZ;
	_BLKSIZ = _blksiz;
	rv = ((unsigned char *) malloc(size));
	_BLKSIZ = _blksiz = _oldsiz;
	return(rv);
	}

_getbuf(fp)		/* allocate a buffer for a stream */
	register FILE *fp;
	{
	if((fp->_flag & _IONBF)
	|| ((fp->_base = _malloc(fp->_bsiz = BUFSIZ)) == NULL))
		{
		fp->_flag &= ~(_IOFBF | _IOLBF | _IONBF);
		fp->_flag |= _IONBF;
		fp->_base = &(fp->_ch);			/* use tiny buffer */
		fp->_bsiz = 1;
		}
	else
		fp->_flag |= _IOMYBUF;			/* use big buffer */
	fp->_ptr = fp->_base;
	fp->_cnt = 0;		/* start out with an empty buffer */
	}
