#include <string.h>
#include <stdlib.h>

char *strdup(const char *s1)
{
    char *dup;

    dup = malloc(strlen(s1) + 1);
    if (dup) strcpy(dup, s1);

    return dup;
}

