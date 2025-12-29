/* General purpose header file - rf 12/90 */

#ifndef _H_general
#define _H_general

/* Macintosh specific */
#ifdef THINK_C

#define const					/* THINK C doesn't know about these identifiers */
#define signed
#define volatile

#else /* not Macintoshs */

typedef int Boolean;			/* Is already defined in THINK_C */

#endif /* ifdef THINK_C */

/* definitions for all machines */

#undef TRUE						/* Boolean values; first undef them, just in case */
#undef FALSE
#define TRUE 1
#define FALSE 0

#define EOS '\0'				/* End-Of-String */
#define MAXLINE 512			/* Max. line length */

#ifdef VAX
#define signed
#endif

#ifdef UNIX
#ifdef        SYSTEM_FIVE
#define       RAND_MAX 32767
#else
#define       RAND_MAX 2147483647
#endif
#endif

#endif /* ifndef _H_general */
