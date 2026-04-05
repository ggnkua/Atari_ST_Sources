#include <string.h>

size_t strxfrm(char *dest, const char *src, size_t n)
{
	if (n > 0) {
    	strncpy(dest, src, n);
		dest[n] = '\0';
    	n = strlen(dest);
	}

    return n;
}
