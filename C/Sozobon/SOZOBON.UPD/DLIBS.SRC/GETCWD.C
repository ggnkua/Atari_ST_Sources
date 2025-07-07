#include <stdio.h>
#include <limits.h>
#include <malloc.h>

char *getcwd(buf, limit)
	char *buf;
	register int limit;
	{
	char cwd[PATHSIZE], *strcpy();

	if((buf == NULL)
	&& ((buf = malloc(limit)) == NULL))
		return(NULL);
	fullpath(cwd, "");
	if(strlen(cwd) < limit)
		return(strcpy(buf, cwd));
	return(NULL);
	}
