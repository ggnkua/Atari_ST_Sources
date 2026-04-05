#include <stdarg.h>
#include <stdlib.h>
#include <stdio.h>
#include <mint/osbind.h>
#include <limits.h>


int
vasprintf(char** strp, const char* format, va_list ap)
{
    int size = vsnprintf(NULL, 0, format, ap);

    if (size >= 0 && size < INT_MAX) {
        *strp = malloc(size + 1);

        if (*strp != NULL) {
            int len = vsnprintf(*strp, size + 1, format, ap);

            if (len < 0 || len > size) {
                free(*strp);
            } else {
                return len;
            }
        }
    }

    *strp = NULL;

    return -1;
}
