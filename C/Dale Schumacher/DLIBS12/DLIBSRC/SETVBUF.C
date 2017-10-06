#include <stdio.h>

void setvbuf(fp, bp, bmode, size)
	register FILE *fp;
	unsigned char *bp;
	int bmode;
	int size;
	{
	fp->_flag &= ~(_IOFBF | _IOLBF | _IONBF | _IOMYBUF);
	fp->_flag |= bmode;
	fp->_cnt = 0;
	if((bmode == _IONBF) || (bp == NULL))		/* unbuffered */
		{
		fp->_base = NULL;
		fp->_bsiz = 0;
		}
	else						/* full buffering */
		{
		fp->_base = bp;
		fp->_bsiz = size;
		}
	fp->_ptr = fp->_base;
	}
