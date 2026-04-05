#include "locale.h"
#include "string.h"

/*
 * this is basically a dummy function as standard TOS doesn't 
 * know about locales
 */
char *setlocale(int category, const char *locale)
{
    static char slocale[100];

    strncpy(slocale, locale, 100);

    return slocale;
}

