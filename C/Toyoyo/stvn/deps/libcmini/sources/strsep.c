/*
 *	strsep() - TeSche
 */

#include <string.h>

#undef strsep

char *strsep(char **s, const char *sep)
{
	register char	*ptr, *this = *s;

	if (*s) {
		if ((ptr = strpbrk(*s, sep))) {
			*ptr++ = 0;
			*s = ptr;
		} else {
			*s = NULL;
		}

		return this;
	}

	return NULL;
}
