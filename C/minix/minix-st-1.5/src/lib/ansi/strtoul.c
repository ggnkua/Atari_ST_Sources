/* strtoul.c						ANSI 4.10.1.6
 *	unsigned long int strtoul(const char *nptr, char **endptr, int base);
 *
 *	Converts a numeric string, in various bases, to an unsigned long.
 */

#include <lib.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>
#include <stdlib.h>

#ifdef strtoul
#undef strtoul
#endif

PUBLIC unsigned long int strtoul(nptr, endptr, base)
_CONST char *nptr;
char **endptr;
int base;
{
  register int c;
  unsigned long int result = 0L;
  unsigned long int limit;
  int negative = 0;
  int overflow = 0;
  int saw_a_digit = 0;			/* it's not a number without a digit */

  if (endptr != (char **) NULL)		/* set up default final pointer */
	*endptr = nptr;

  while ((c = *nptr) && isspace(c))	/* skip leading white space */
	++nptr;

  if (c == '+' || c == '-') {		/* handle signs */
	negative = (c == '-');
	++nptr;
  }

  if (base == 0) {			/* determine base if unknown */
	base = 10;
	if (*nptr == '0') {
		base = 8;
		++nptr;
		if ((c = *nptr) == 'x' || c == 'X') {
			base = 16;
			++nptr;
		}
	}
  }
  else
  if (base == 16 && *nptr == '0') {	/* discard 0x/0X prefix if hex */
	++nptr;
	if ((c = *nptr == 'x') || c == 'X')
		++nptr;
  }

  limit = ULONG_MAX / base;		/* ensure no overflow */

  --nptr;				/* convert the number */
  while ((c = *++nptr) != 0) {
	if (isdigit(c))
		c -= '0';
	else
		c -= isupper(c) ? ('A' - 10) : ('a' - 10);
	if (c < 0 || c >= base)
		break;
	saw_a_digit = 1;
	if (result > limit)
		overflow = 1;
	if (!overflow) {
		result = base * result;
		if (c > ULONG_MAX - result)
			overflow = 1;
		else	
			result += c;
	}
  }
  if (!saw_a_digit)
	return 0;

  if (negative && !overflow)	/* BIZARRE, but ANSI says we should do this! */
	result = 0L - result;
  if (overflow) {
	errno = ERANGE;
	result = ULONG_MAX;
  }

  if (endptr != (char **) NULL)		/* record good final pointer */
	*endptr = nptr;
  return result;
}
