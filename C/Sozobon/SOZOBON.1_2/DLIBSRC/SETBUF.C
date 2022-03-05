#include <stdio.h>

void setbuf(fp, buf)
	register FILE *fp;
	unsigned char *buf;
	{
	fp->_flag &= ~(_IOFBF | _IOLBF | _IONBF | _IOMYBUF);
	fp->_cnt = 0;
	fp->_ptr = buf;
	if(fp->_base = buf)		/* assignment intentional */
		{
		fp->_flag |= _IOFBF;
		fp->_bsiz = BUFSIZ;
		}
	else
		{
		fp->_flag |= _IONBF;
		fp->_bsiz = 0;
		}
	}
