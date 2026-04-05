/*
 * memset.c
 *
 *  Created on: 16.06.2013
 *      Author: mfro
 */


#include <stdlib.h>
#include <string.h>

void *memset(void *_s, int c, size_t len)
{
	size_t i;
	unsigned char *s = (unsigned char *)_s;

	for (i = 0; i < len; i++)
		s[i] = c;

	return s;
}
