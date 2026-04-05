/* functions for manipulating the environment */
/* written by Eric R. Smith and placed in the public domain */
/* 5/5/92 sb -- separated for efficiency, see also putenv.c */

#include <stddef.h>
#include <string.h>
#include <stdlib.h>
#include "lib.h"

char *getenv (const char *tag)
{
	char **var;
	char *name;
	size_t len;

	if (!environ)
		return 0;

	len = strlen (tag);

	for (var = environ; (name = *var) != 0; var++) {
		if (!strncmp(name, tag, len) && name[len] == '=')
			return name+len+1;
	}

	return 0;
}
