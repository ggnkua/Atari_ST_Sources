/*
 * strncat.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>

char *strncat(char *dst, const char *src, size_t max)
{
	char *ret = dst;

	while (*dst != '\0')
		++dst;

	while (max-- > 0 && *src != '\0')
		*dst++ = *src++;

	*dst = '\0';

	return ret;
}

