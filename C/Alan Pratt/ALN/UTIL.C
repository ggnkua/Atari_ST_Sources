/*
******************* Revision Control System *****************************
*
* $Author: apratt $
* =======================================================================
*
* $Date: 88/08/23 14:20:35 $
* =======================================================================
*
* $Locker:  $
* =======================================================================
*
* $Log:	util.c,v $
* Revision 1.1  88/08/23  14:20:35  apratt
* Initial revision
* 
* =======================================================================
*
* $Revision: 1.1 $
* =======================================================================
*
* $Source: /u/apratt/work/aln/RCS/util.c,v $
* =======================================================================
*
*************************************************************************
*/
/*
 * util.c: utility functions for the linker.
 * test, path_tail, put_name, make_string, symcmp, usage, panic
 * and getval (which entails atold, atolo, and atolx).
 */

#include "aln.h"

/*
 * this test is used by write_map: it's passed to qsort to sort symbols.
 */

test(a,b)
register char *a,*b;
{
    register int at,bt;
    if (a == 0 || b == 0) {
	printf("Internal error: null pointers in test\n");
	exit(-1);
    }
    at = getword(a+8) & T_SEG;
    bt = getword(b+8) & T_SEG;
    if (at - bt) return at-bt;
    for (at = 8; at--; ++a, ++b) {
	if (*a - *b) return (*a - *b);
    }
    return 0;
}

char *path_tail(name)
register char *name;
{
    register char *temp;

    /* ms-dos pathnames plus '/' for UNIX */
    temp = max(rindex(name,'/'),max(rindex(name,':'),rindex(name,92)));
    if (temp == NULL) temp = name-1;
    return temp+1;
}

put_name(p)
struct OFILE *p;
{
    register int flag = *(p->o_arname);
    printf("%s%s%s",
	   flag ? p->o_arname : "",
	   flag ? ":" : "",
	   p->o_name);
}

/*
 * make_string: takes a symbol which is in object-file format (1-7 bytes
 * with trailing null or 8 bytes/no null) and makes a C string of it.
 * Returns a pointer to a STATIC ARRAY, so only use it once in a given
 * expression!
 */

char *make_string(sym)
register char *sym;
{
    static char buf[SYMLEN];
    symcopy(buf,sym);
    return buf;
}

#ifndef symcmp

/*
 * symcmp(a,b): return TRUE if symbol A == symbol B
 */

symcmp(a,b)
register long *a;
register long *b;
{
    return (*a == *b && *(a+1) == *(b+1));
}
#endif symcmp

usage()
{
    printf("Usage: aln [ option ... ] { [ -x file ] file } ...\n");
    exit(1);
}

panic(string)
char *string;
{
	printf("%s\n",string);
	exit(-1);
}

/*
 * getval: stuff the (long) value of a string into the value argument.
 * RETURNS TRUE if the string doesn't parse.  Parses only as a hex string.
 */

getval(string,value)
char *string;
long *value;
{
	return atolx(string,value);
}

atolx(string,value)
char *string;
long *value;
{
    *value = 0;
    while (isxdigit(*string)) {
	if (isdigit(*string)) {
	    *value = (*value << 4) + (*string++ - '0');
	}
	else {
	    if (isupper(*string)) *string = tolower(*string);
	    *value = (*value << 4) + ((*string++ - 'a') + 10);
	}
    }
    if (*string != '\0') {
	printf("Invalid hexadecimal value");
	return 1;
    }
    else return 0;
}

