#include <stdio.h>

int fgetc(fp)
	register FILE *fp;
	{
	register int c, f, m, look = FALSE;

	f = (fp->_flag &= ~_IORW);
	if(!(f & _IOREAD) || (f & (_IOERR | _IOEOF)))
		return(EOF);
	if(fp->_base == NULL)	/* allocate a buffer if there wasn't one */
		_getbuf(fp);
_fgetc1:
	if(--(fp->_cnt) < 0)
		{
		if(f & _IODEV)
			m = _tttty(fp);
		else
			m = read(fp->_file, fp->_base, fp->_bsiz);
		if(m <= 0)
			{
			fp->_flag |= ((m == 0) ? _IOEOF : _IOERR);
			c = EOF;
			goto _fgetc2;
			}
		fp->_cnt = (m - 1);
		fp->_ptr = fp->_base;
		}
	c = *(fp->_ptr)++;
_fgetc2:
	if(!(f & _IOBIN))		/* TRANSLATED STREAM PROCESSING */
		{
		if(look)			/* process lookahead */
			{
			if(c != '\n')		/* if not CR+LF.. */
				{
				if(c == EOF)	/* ..undo EOF.. */
					{
					fp->_flag &= ~(_IOERR | _IOEOF);
					}
				else		/* ..or unget character */
					{
					*--(fp->_ptr) = c;
					++(fp->_cnt);
					}
				c = '\r';	/* return CR */
				}
			}
		else if(c == '\r')		/* found CR */
			{
			if(f & _IODEV)		/* return it for tty */
				c = '\n';
			else			/* else lookahead for LF */
				{
				look = TRUE;
				goto _fgetc1;
				}
			}
		else if(c == 0x00)		/* Ignore NUL's */
			goto _fgetc1;
		else if(c == 0x1A)		/* ^Z becomes EOF */
			{
			fp->_flag |= _IOEOF;
			c = EOF;
			}
		}
	return(c);
	}

int fungetc(c, fp)
	char c;
	register FILE *fp;
	{
	if((fp->_flag & (_IOERR | _IOEOF))	/* error or eof */
	|| (fp->_ptr <= fp->_base))		/* or too many ungets */
		return(EOF);
	++(fp->_cnt);
	return(*--(fp->_ptr) = c);
	}
