/*
 * strcmp.c
 *
 *  Created on: 28.11.2013
 *      Author: mfro
 */

#include <string.h>

#if defined(__GNUC__) && __GNUC__ >= 7
#pragma GCC diagnostic ignored "-Wnonnull-compare"
#endif

int strcmp(const char *scan1, const char *scan2)
{
	unsigned char c1, c2;

	if (!scan1)
		return scan2 ? -1 : 0;
	if (!scan2) return 1;

	do {
		c1 = (unsigned char) *scan1++; c2 = (unsigned char) *scan2++;
	} while (c1 && c1 == c2);

	/*
	 * The following case analysis is necessary so that characters
	 * which look negative collate low against normal characters but
	 * high against the end-of-string NUL.
	 */
	if (c1 == c2)
		return 0;
	if (c1 == '\0')
		return -1;
	if (c2 == '\0')
		return 1;
	return c1 - c2;
}
