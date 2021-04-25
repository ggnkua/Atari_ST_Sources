#include <osbind.h>
#include <stdio.h>

int fclose(fp)
	register FILE *fp;
	{
	register int f, frv;

	if(fp == NULL)
		return(EOF);		/* NULL file pointer file */
	f = fp->_flag;
	if((f & (_IOREAD | _IOWRT)) == 0)
		return(EOF);		/* file not open! */
	frv = fflush(fp);		/* flush and save return value */
	if(fp->_bsiz != BUFSIZ)		/* throw away non-standard buffer */
		{
		fp->_base = NULL;
		fp->_ptr = NULL;
		fp->_bsiz = 0;
		}
	fp->_flag = 0;			/* clear status */
	f = ((f & _IODEV) ? 0 : close(fp->_file));
	return((frv || f) ? EOF : 0);
	}
