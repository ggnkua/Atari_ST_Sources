/*
 * strcat.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>

char *strcat(char *dst, const char *src)
{
	char *ret = dst;

    while (*dst != '\0')
        ++dst;

    do {} while ((*dst++ = *src++) != '\0');

	return ret;
}
