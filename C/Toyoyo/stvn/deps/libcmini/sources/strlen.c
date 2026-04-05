/*
 * strlen.c
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#include <string.h>

size_t strlen(const char *s)
{
	const char *start = s;

	while (*s++)
		;

	return s - start - 1;
}
