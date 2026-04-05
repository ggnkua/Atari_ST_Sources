/* from Henry Spencer's stringlib */

#include <stddef.h>
#include <string.h>

/* Modified for MiNTLib by Guido Flohr <guido@freemint.de>.  */

/*
 * memccpy - copy bytes up to a certain char
 */

void*
memccpy(void* dst, const void* src, int ucharstop, size_t size)
{
    register char *d;
    register const char *s;
    register size_t n;

    if (size == 0)
        return(NULL);

    s = (const char *) src;
    d = (char *)dst;
    for (n = size; n > 0; n--)
        if ((*d++ = *s++) == (char) ucharstop)
            return(d);

    return(NULL);
}
