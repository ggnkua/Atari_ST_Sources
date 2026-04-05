/* from Dale Schumacher's dLibs library */

/* if you chage the behaviour so that it does not reverse in-place
 * please change mktemp.c too (it assumes rev is in-place)
 */

#include <string.h>

char *strrev(char *string)
{
	char *p = string;
	char *q;

	if (*(q = p) != '\0') /* non-empty string? */
	{
		while (*++q)
			;

		while (--q > p)
		{
			char c;

			c = *q;
			*q = *p;
			*p++ = c;
		}
	}

	return string;
}
