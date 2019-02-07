/* util: utility functions for Score music layout program
 * phil comeau 30-jan-88
 * last edited 12-jul-89 0002
 *
 * Copyright 1988 by Phil Comeau
 * Copyright 1989, 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <mylib.h>

/* Emalloc: Attempt to allocate memory. If memory is not available,
 * an alert is displayed and NULL returned.
 */

char *Emalloc(size)
int size;
{
	char *p;

	if ((p = malloc(size)) == NULL) {
		Warning("Out of memory!");
	}

	return (p);
}
