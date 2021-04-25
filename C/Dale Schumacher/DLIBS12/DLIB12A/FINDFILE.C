#include <osbind.h>
#include <stdio.h>
#include <stat.h>

static char *_findext(p, q, ext)
	register char *p, *q, *ext;
	{
	if(ext == NULL)
		ext = ".";
	while(p < q)
		{
		if(!stricmp(p, ext))
			return(p);
		while(*p++)
			;
		}
	return(NULL);
	}

char *findfile(afn, ext)
	char *afn, *ext;
	{
	char *fullpath(), *strrchr(), *strchr(), *strcpy();
	register char *p, *q, *e;
	struct stat dta, *pdta;

	afn = fullpath(NULL, afn);
	if((p = strrchr(afn, '\\')) &&
	   (p = strchr(p, '.')))		/* .EXT specified */
		return(access(afn, 0x00) ? NULL : afn);
	/*
	 * No extension specified, search directory for any extension
	 * and try to match with the list.
	 */
	p = strrchr(afn, '\0');
	p[0] = '.';
	p[1] = '*';
	p[2] = '\0';
	q = ext;
	while(*q)				/* q = end of exts / match */
		while(*q++)
			;
	pdta = ((struct stat *) Fgetdta());
	Fsetdta(&dta);
	if(Fsfirst(afn, 0x00) == 0)
		{
		do
			{
			e = strchr(dta.st_name, '.');
			if(e = _findext(ext, q, e))
				q = e;
			}
			while(Fsnext() == 0);
		}
	Fsetdta(pdta);
	if(*q)
		{
		strcpy(p, q);
		return(afn);
		}
	return(NULL);
	}
