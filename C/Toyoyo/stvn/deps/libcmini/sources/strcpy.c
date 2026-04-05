/*
 * strcpy.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>

char *strcpy(char *dst, const char *src)
{
	char *ptr = dst;

	while ((*dst++ = *src++) != '\0')
		;
	return ptr;
}
