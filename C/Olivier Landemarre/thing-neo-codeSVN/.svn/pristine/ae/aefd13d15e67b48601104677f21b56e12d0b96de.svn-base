/* derived from strcmp from Henry Spencer's stringlib */
/* modified by ERS */
/* i-changes by Alexander Lehmann */


 
#include "..\include\globdef.h"

#include "..\include\types.h"




/*
 * stricmp - compare string s1 to s2 without case sensitivity
 *           result is equivalent to strcmp(strupr(s1),s2)),
 *           but doesn't change anything
 */

int                             /* <0 for <, 0 for ==, >0 for > */
strcasecmp(const char *scan1, const char *scan2)
{
        char c1, c2;

        if (!scan1)
                return scan2 ? -1 : 0;
        if (!scan2) return 1;

        do {
                c1 = *scan1++; c1=nkc_toupper(c1);
                c2 = *scan2++; c2=nkc_toupper(c2);
        } while (c1 && c1 == c2);

        /*
         * The following case analysis is necessary so that characters
         * which look negative collate low against normal characters but
         * high against the end-of-string NUL.
         */
        if (c1 == c2)
                return(0);
        else if (c1 == '\0')
                return(-1);
        else if (c2 == '\0')
                return(1);
        else
                return(c1 - c2);
}

/*
 * strnicmp - compare at most n characters of string s1 to s2 without case
 *           result is equivalent to strcmp(strupr(s1),s2)),
 *           but doesn't change anything
 */

int                             /* <0 for <, 0 for ==, >0 for > */
strnicmp(const char *scan1, const char *scan2, size_t n)
{
        char c1, c2;
        long count;

        if (!scan1) {
                return scan2 ? -1 : 0;
        }
        if (!scan2) return 1;
        count = n;
        do {
                c1 = *scan1++; c1=nkc_toupper(c1);
                c2 = *scan2++; c2=nkc_toupper(c2);
        } while (--count >= 0 && c1 && c1 == c2);

        if (count < 0)
                return(0);

        /*
         * The following case analysis is necessary so that characters
         * which look negative collate low against normal characters but
         * high against the end-of-string NUL.
         */
        if (c1 == c2)
                return(0);
        else if (c1 == '\0')
                return(-1);
        else if (c2 == '\0')
                return(1);
        else
                return(c1 - c2);
}

#ifndef __GNUC__
int strncmpi(const char *scan1, const char *scan2, size_t n)
{
	return strnicmp(scan1, scan2, n);
}

int strncasecmp(const char *scan1, const char *scan2, size_t n)
{
	return strnicmp(scan1, scan2, n);
}
#endif
