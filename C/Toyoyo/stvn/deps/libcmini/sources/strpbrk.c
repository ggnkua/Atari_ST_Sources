#include <string.h>

/*
 * Mintlib's strpbrk()
 *
 * find first occurence of any char from breakat in s
 */

char *strpbrk(const char *s, const char *breakat)
{
    const char *sscan;
    const char *bscan;

    for (sscan = s; *sscan != '\0'; sscan++)
    {
        for (bscan = breakat; *bscan != '\0';)
        {
            if (*sscan == *bscan++)
                return (char *) sscan;
        }
    }
    return NULL;
}
