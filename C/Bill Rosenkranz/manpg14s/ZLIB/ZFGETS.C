#include "zdef.h"

/*------------------------------*/
/*	zfgets			*/
/*------------------------------*/
#ifndef __STDC__
char *zfgets (line, len, zfp)
char   *line;
int     len;
ZFILE  *zfp;
#else
char *zfgets (char *line, int len, ZFILE *zfp)
#endif
{

/*
 *	I *hope* this is what fgets does - I only added it
 *	here when I came across a program that needed it; I'm
 *	including the '\n' in the string.
 */

	int     c,
	        pos = 0;

	for (;;)
	{
		c = zfgetc (zfp);
		if (c == EOF)
			return ((char *) NULL);

		c &= 255;
		line[pos] = (char) c;
		if (pos + 1 == len)	/* Too long! */
			break;
		pos++;
		if (c == '\n')
			break;
	}
	line[pos] = '\0';

	return ((char *) line);
}



