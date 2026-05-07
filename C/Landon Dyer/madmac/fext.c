/*
 *  Filename twiddling
 *
 *  This version will work for UNIX and Atari GEMDOS.
 *
 */
#include "as.h"


/*
 *  Manipulate file extension.
 *
 *  `name' must be large enough to hold any possible filename.
 *
 *  If `stripp' is nonzero, any old extension is removed.
 *
 *  Then, if the file does not already have an extension,
 *  `extension' is appended to the filename.
 *
 */
char *fext(name, extension, stripp)
char *name;		/* -> buffer */
char *extension;		/* extension to replace with */
int stripp;		/* nonzero: clobber extension */
{
	register char *s, *beg;

	/*
	 *  Find beginning of "real" name
	 *  If the name ends in a colon, leave the name undisturbed [ST only].
	 */
	beg = name + strlen(name)-1;
#ifdef ST
	if (*beg == ':')
		return;
#endif
	for (; beg > name; --beg)
		if (*beg == SLASHCHAR)
		{
			++beg;
			break;
		}

	if (stripp)
	{				/* clobber any old extension */
		for (s = beg; *s && *s != '.'; ++s)
			;
		*s = '\0';
	}

	for (s = beg; *s != '.'; ++s)
		if (!*s)
		{				/* append the new extension */
			strcat(beg, extension);
			break;
		}

	return name;
}
