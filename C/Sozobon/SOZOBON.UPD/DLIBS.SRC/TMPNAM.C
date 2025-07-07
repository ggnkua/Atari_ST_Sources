#include <stdio.h>
#include <string.h>

static int	_tmpcnt = 0;
static char	_tmpnam[L_tmpnam];
static char	_tmppfx[] = "TEMP$";

char *tmpnam(s)
	char *s;
	{
	do
		{
		sprintf(_tmpnam, "%.5s%03d.TMP", _tmppfx, _tmpcnt);
		_tmpcnt = (_tmpcnt + 1) % TMP_MAX;
		}
		while(exists(_tmpnam));
	if(s == NULL)
		return(strdup(_tmpnam));
	else
		return(strcpy(s, _tmpnam));
	}

char *tempnam(dir, pfx)
	char *dir;
	register char *pfx;
	{
	register char *p;
	char path[L_tmpnam];
	char *getenv();

	if(p = getenv("TMPDIR"))
		fullpath(path, p);
	else if(dir)
		fullpath(path, dir);
	else
		fullpath(path, "");
	p = strrchr(path, '\0');
	if(pfx == NULL)
		pfx = _tmppfx;
	do
		{
		sprintf(p, "%.5s%03d.TMP", pfx, _tmpcnt);
		_tmpcnt = (_tmpcnt + 1) % TMP_MAX;
		}
		while(exists(path));
	return(strdup(path));
	}
