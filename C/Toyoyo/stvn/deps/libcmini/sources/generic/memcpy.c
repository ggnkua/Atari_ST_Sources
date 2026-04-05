/*
 * memcpy.c/memmove.c
 *
 *  Created on: 16.06.2013
 *      Author: mfro
 *  Rewritten on: 23.03.2014
 *      Author: ardi
 *  Rewritten on: 28.04.2020
 *      Author: tho
 */

#include <stdlib.h>
#include <string.h>

void *memcpy(void *dest, const void *src, size_t n)
{
	unsigned char *pd = (unsigned char *)dest;
	const unsigned char *ps = (const unsigned char *)src;
	if (pd > ps)
	{
		for (pd += n, ps += n; n--;)
			*--pd = *--ps;
	} else if (pd < ps)
	{
		while (n--)
			*pd++ = *ps++;
	}
	return dest;
}

#ifdef __GNUC__
void *memmove(void *dest, const void *src, size_t n) __attribute__((alias("memcpy")));
#endif
