#include <stdlib.h>
#include <string.h>

extern char const __itoa_numstr[16];

char *ultoa(unsigned long value, char *buffer, int radix)
{
	char *p = buffer;
	short i = 0;
	char tmpbuf[8 * sizeof(long) + 2];

	do {
		tmpbuf[i++] = __itoa_numstr[value % radix];
	} while ((value /= radix) != 0);

	p = buffer;
	while (--i >= 0)	/* reverse it back  */
		*p++ = tmpbuf[i];
	*p = '\0';

	return buffer;
}
