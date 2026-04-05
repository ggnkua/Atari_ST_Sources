/*
 * bcopy.c
 *
 *  Created on: 16.06.2013
 *      Author: mfro
 */

#include <string.h>

void bcopy(const void *s1, void *s2, size_t n)
{
	int i;

	for (i = 0; i < n; i++)
		((char *) s1)[i] = ((char *) s2)[i];
}

