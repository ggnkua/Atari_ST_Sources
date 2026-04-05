/*
 * strncmp.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>

int memcmp(const void *s1, const void *s2, size_t size)
{
	register const unsigned char *scan1;
	register const unsigned char *scan2;
	register size_t n;

	scan1 = (const unsigned char *) s1;
	scan2 = (const unsigned char *) s2;
	for (n = size; n > 0; n--)
	{
		if (*scan1 != *scan2)
			return *scan1 - *scan2;
		scan1++;
		scan2++;
	}
	
	return 0;
}


