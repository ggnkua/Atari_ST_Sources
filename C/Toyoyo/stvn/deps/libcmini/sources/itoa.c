#include <stdlib.h>
#include <stdlib.h>
#include <string.h>

char *itoa(int value, char *buffer, int radix);

extern char const __itoa_numstr[16];

char *itoa(int value, char *buffer, int radix)
{
	char *p;
	int neg = 0;
	char tmpbuf[8 * sizeof(long) + 2];
	short i = 0;

	if (value < 0)
	{
		neg = 1;
		value = -value;
	}
	do {
		tmpbuf[i++] = __itoa_numstr[value % radix];
	} while ((value /= radix) != 0);

	if (neg)
		tmpbuf[i++] = '-';
	p = buffer;
	while (--i >= 0)	/* reverse it back  */
		*p++ = tmpbuf[i];
	*p = '\0';

	return buffer;
}

#if !(defined(__MSHORT__) || defined(__PUREC__) || defined(__AHCC__))
char *ltoa(long value, char *buffer, int radix) __attribute__((alias("itoa")));
#endif
