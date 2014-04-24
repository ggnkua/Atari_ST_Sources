#include <stdio.h>
#include <osbind.h>

_exit(result)
int result;
{
	Pterm(result);
}

exit(result)
int result;
{
    int i;
    register FILE *fp;
    extern struct {
	int refnum;
	int flag;   /* 1=binary mode, 0=translated mode. +9 for devices */
    } _binary[];

    for (fp = _iob; fp<_iob+_NFILE; fp++)	/* close all streams */
	if (fp->_flag & (_READ | _WRITE))
	    fclose(fp);

/*   for (i=0; i<12+9; i++)   /* close all open file descriptors */
/*	if (_binary[i].refnum > 0)	/* don't close devices */
/*	    Fclose(_binary[i].refnum);   /* ignore any errors */

    _exit(result);
}
