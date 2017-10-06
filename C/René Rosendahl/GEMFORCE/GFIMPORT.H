/* IMPORT.H zu GEM-Force */

#ifndef __IMPORT__
#define __IMPORT__

/* # include <PORTAB.H> */

#ifdef GLOBAL
#undef GLOBAL
#endif

# define GLOBAL extern
# define LOCAL  static

#ifndef max
# define max(a,b)    (((a) > (b)) ? (a) : (b)) /* Maximum-Funktion */
# define min(a,b)    (((a) < (b)) ? (a) : (b)) /* Minimum Funktion */
#endif

#ifndef BOOLEAN
# define BOOLEAN int
# define TRUE 1
# define FALSE 0
#endif

#endif /* __IMPORT__ */
