#include <string.h>

/*
 * mintlib's strcspn.c
 *
 * find length of initial segment of s consisting entirely of characters not from reject
 */

size_t strcspn(const char *s, const char *reject)
{
    const char *scan;
    const char *rscan;
    size_t count;

    count = 0;
    for (scan = s; *scan != '\0'; scan++)
    {
        for (rscan = reject; *rscan != '\0';)
        {
            if (*scan == *rscan++)
                return count;
        }
        count++;
    }
    return count;
}
