#include <stdio.h>
#include <osbind.h>
#include <limits.h>
#include <string.h>

char *fullpath(full, part)
	register char *full;
	register char *part;
	{
	static char buf[PATHSIZE];
	register char *bp = buf;
	register int drv;

	if (*part && (part[1] == ':'))
		{
		drv = *bp++ = *part++;
		drv = ((drv - 1) & 0xF);
		*bp++ = *part++;
		}
	else
		{
		*bp++ = (drv = Dgetdrv()) + 'a';
		*bp++ = ':';
		}
	if (*part == '\\')
		++part;
	else
		{
		Dgetpath(bp, drv+1);	/* 1 BASED drive number here */
		while(*bp++)
			;
		--bp;
		}
	*bp++ = '\\';
	*bp = '\0';
	while(*part)			/* handle dots and copy path & file */
		{
		if (*part == '.')
			{
			if (*++part == '.')
				{
				if ((*++part) && (*part != '\\'))
					return(NULL);	/* illegal pathname */
				else
					{
					--bp;
					while(*--bp != '\\')
						if(*bp == ':')
							{
							++bp;
							break;
							}
					++bp;
					if(*part)
						++part;
					}
				}
			else if ((*part) && (*part != '\\'))
				return(NULL);		/* illegal pathname */
			else
				++part;
			}
		else
			while(*part && ((*bp++ = *part++) != '\\'))
				;
		}
	*bp = '\0';
	if (full == NULL)	/* special case to use local buffer */
		full = buf;
	return(strlwr(strcpy(full, buf)));	/* lowercase and return */
	}
