#include <osbind.h>
#include <stdio.h>
#include <types.h>
#include <stat.h>
#include <errno.h>

static	struct stat	_dta;		/* local DTA buffer */

int access(name, amode)
	char *name;
	int amode;
	{
	register struct stat *_pdta;		/* pointer to old DTA */

	_pdta = (struct stat *) Fgetdta();
	Fsetdta(&_dta);
	amode = ((amode & 0x02) ? 0x16 : 0x17);
	errno = ((int) Fsfirst(name, amode));
	Fsetdta(_pdta);
	return((errno == 0) ? 0 : (-1));
	}

int stat(name, statbuf)
	register char *name;
	register struct stat *statbuf;
	{
	if(access(name, 0x00) == 0)
		{
		*statbuf = _dta;
		statbuf->st_mode |= ((statbuf->st_mode & S_ISRO) ?
			S_IREAD : (S_IREAD | S_IWRITE));
		statbuf->st_dev = ((name[1] == ':') ?
			((name[0] | 0x20) - 'a') : ((dev_t) Dgetdrv()));
		statbuf->st_nlink = 1;
		return(0);
		}
	return(ERROR);
	}

long fsize(name)
	char *name;
	{
	if(access(name, 0x00) == 0)
		return(_dta.st_size);
	return(ERROR);
	}
