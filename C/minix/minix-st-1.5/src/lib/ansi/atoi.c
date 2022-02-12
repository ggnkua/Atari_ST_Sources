/* atoi.c						ANSI 4.10.1.2
 *	int atoi(const char *nptr);
 *
 *	Converts a numeric string in base 10 to an integer.
 */

#include <lib.h>
#include <ctype.h>
#include <stdlib.h>

#ifdef atoi
#undef atoi
#endif

PUBLIC int atoi(nptr)
register _CONST char *nptr;
{
  register int c;
  int result = 0;
  int negative = 0;

  while ((c = *nptr) && isspace(c))	/* skip leading white space */
	++nptr;

  if (c == '+' || c == '-') {		/* handle signs */
	negative = (c == '-');
	++nptr;
  }

  while ((c = *nptr++ - '0') >= 0 && c < 10)
	result = (result << 1) + (result << 3) + c;

  return (negative) ? 0 - result : result;
}
