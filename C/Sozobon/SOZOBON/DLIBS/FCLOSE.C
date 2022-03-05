#include <osbind.h>
#include <stdio.h>

int fclose(fp)
	register FILE *fp;
	{
	register int f;

	if(fp == NULL)
		return(EOF);		/* NULL file pointer file */
	f = fp->_flag;
	if((f & (_IOREAD | _IOWRT)) == 0)
		return(EOF);		/* file not open! */
	fflush(fp);
	if(fp->_bsiz != BUFSIZ)		/* throw away non-standard buffer */
		{
		fp->_base = NULL;
		fp->_ptr = NULL;
		fp->_bsiz = 0;
		}
	fp->_flag = 0;			/* clear status */
	if(f & _IODEV)			/* leave tty's alone */
		return(0);
	f = close(fp->_file);
	return(f ? EOF : 0);
	}
