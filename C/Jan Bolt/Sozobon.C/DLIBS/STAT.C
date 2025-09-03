/* stat.c 030690 modified by Jan Bolt */
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
	errno = Fsfirst(name, 0);
	Fsetdta(_pdta);
	if (errno == 0)
	   if (amode & 0x02)
		 errno = (_dta.st_mode & 1) ? EACCDN : 0;
	return(errno == 0);
	}

int stat(name, statbuf)
	register char *name;
	register struct stat *statbuf;
	{
	if(access(name, 0x00))
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
	if(access(name, 0x00))
		return(_dta.st_size);
	return(ERROR);
	}
