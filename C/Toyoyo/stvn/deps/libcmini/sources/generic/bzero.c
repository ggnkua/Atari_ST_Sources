/*
 * bzero.c
 *
 *  Created on: 16.06.2013
 *      Author: mfro
 */

#include <stdlib.h>
#include <string.h>

void bzero(void *_s, size_t n)
{
	size_t i;
	unsigned char *s = (unsigned char *)_s;

	for (i = 0; i < n; i++)
		s[i] = '\0';
}
