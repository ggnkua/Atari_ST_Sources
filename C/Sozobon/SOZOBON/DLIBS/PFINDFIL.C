#include <stddef.h>
#include <limits.h>

char *pfindfile(path, afn, ext)
	register char *path;
	register char *afn;
	char *ext;
	{
	static char tmp[PATHSIZE];
	register char *p;
	char *findfile(), *strchr(), *getenv(), *strcpy();

	if(strchr(afn, '\\') || strchr(afn, ':'))	/* file has path */
		return(findfile(afn, ext));
	if((path == NULL)				/* if no path spec */
	&& ((path = getenv("PATH")) == NULL))		/* get PATH from env */
		path = ".";				/* or fake it */
	while(*path)
		{
		p = tmp;
		while((*path != '\0') &&
		      (*path != ';') &&
		      (*path != ','))	/* copy directory */
			*p++ = *path++;
		if(*path)			/* move past delim */
			++path;
		if(p[-1] != '\\')		/* add \ if needed */
			*p++ = '\\';
		strcpy(p, afn);			/* copy filename */
		if(p = findfile(tmp, ext))	/* do search */
			return(p);
		}
	return(NULL);
	}
