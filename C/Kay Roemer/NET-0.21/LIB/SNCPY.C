/*
 *	Almost like strncpy() except that it returns the length
 *	of the copied string, terminates dst always with exectly
 *	one '\0'.
 */ 

#include <stdio.h>	/* for size_t */
 
int
_sncpy (dst, src, len)
	char *src, *dst;
	size_t len;
{
	int count = len;

	if (count <= 0) return 0;
	while (--count >= 0 && (*dst++ = *src++) != 0);
	if (count < 0) {
		dst[-1] = '\0';
		return (len - 1);
	}
	return (len - count - 1);
}
