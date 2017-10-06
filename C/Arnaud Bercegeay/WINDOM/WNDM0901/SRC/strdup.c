/*
 * strdup: return a duplicate of a string
 * Written by Eric R. Smith and placed in the public domain.
 */

/* fonction remplace la fonction bugg‚e de xdlibs 1.13
 * fait partie de la version SOZOBONX de WINDOM.
 */

#include <stdlib.h>
#include <string.h>

char * strdup(s)
	const char *s;
{
	char *dup;

	dup = (char *) malloc(strlen(s)+1);
	if (dup)
		strcpy(dup, s);
	return dup;
}
