#include <stdio.h>

int fgetpos(fp, pos)
	FILE *fp;
	fpos_t *pos;
	{
	register long rv;

	rv = ftell(fp);
	if((rv >= 0) && pos)
		{
		*pos = rv;
		return(0);
		}
	return(ERROR);
	}

int fsetpos(fp, pos)
	FILE *fp;
	fpos_t *pos;
	{
	register long rv;

	if(pos)
		{
		rv = fseek(fp, *pos, SEEK_SET);
		if(rv >= 0)
			{
			fp->_flag &= ~(_IOEOF|_IOERR);
			return(0);
			}
		}
	return(ERROR);
	}
