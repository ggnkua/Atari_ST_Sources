#include <stdio.h>
#include <osbind.h>
#include <string.h>
#include <stat.h>
#include <limits.h>

static	struct stat	_wilddta;
static	char		_wbuf[PATHSIZE];
static	char		_wdrive[4], _wpath[PATHSIZE], _wbase[10], _wext[4];

char *wildcard(pathname)
	char *pathname;
	{
	register struct stat *olddta;
	register int search;

	olddta = (struct stat *) Fgetdta();
	Fsetdta(&_wilddta);
	if(pathname)				/* get first match */
		{
		_splitpath(pathname, _wdrive, _wpath, _wbase, _wext);
		search = Fsfirst(pathname, 0x07);
		}
	else					/* get next match */
		search = Fsnext();
	Fsetdta(olddta);
	if(search == 0)
		{
		_makepath(_wbuf, _wdrive, _wpath, _wilddta.st_name, NULL);
		return(_wbuf);
		}
	return(NULL);
	}
