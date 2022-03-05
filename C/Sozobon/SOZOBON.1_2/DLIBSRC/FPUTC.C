#include <stdio.h>

int fputc(c, fp)
	register unsigned char c;
	register FILE *fp;
	{
	register int f, m, nl = FALSE, rv;

	f = (fp->_flag |= _IORW);
	if(!(f & _IOWRT)			/* not opened for write? */
	|| (f & (_IOERR | _IOEOF)))		/* error/eof conditions? */
		return(EOF);
	if(fp->_base == NULL)	/* allocate a buffer if there wasn't one */
		_getbuf(fp);
	if(!(f & _IOBIN) && (c == '\n'))	/* NL -> CR+LF ? */
		{
		c = '\r';
		nl = TRUE;
		}
_fputc:
	*(fp->_ptr)++ = c;
	if((++(fp->_cnt)) >= fp->_bsiz)
		{
		fp->_cnt = 0;
		fp->_ptr = fp->_base;
		m = fp->_bsiz;
		if((rv = write(fp->_file, fp->_base, m)) != m)
			{
			fp->_flag |= _IOERR;
			return(EOF);
			}
		}
	if(nl && (c == '\r'))			/* NL -> CR+LF ? */
		{
		c = '\n';
		goto _fputc;
		}
	return(c);
	}
