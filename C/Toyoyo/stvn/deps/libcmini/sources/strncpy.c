/*
 * strncpy.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>

char *strncpy(char *dst, const char *src, size_t max)
{
	char *dscan;
	long count;

	dscan = dst;
	count = max;
	while (--count >= 0 && (*dscan++ = *src++) != '\0')
		continue;
	while (--count >= 0)
		*dscan++ = '\0';
	return dst;
}
