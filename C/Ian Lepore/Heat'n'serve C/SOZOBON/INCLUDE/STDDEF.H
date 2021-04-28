#pragma idempotent

/*
 * STDDEF.H standard definitions
 */

#ifndef STDDEF_H
#define STDDEF_H

#ifndef dLibs
  #define	dLibs		(0x1201)		/* dLibs identifier (also vsn #) */
#endif

#ifndef NULL
  #define NULL			((void*)0)		/* NULL pointer */
#endif

typedef unsigned long	off_t;			/* offset in file */  
typedef unsigned short	size_t; 		/* sizeof() value type */
typedef long			ptrdiff_t;		/* pointer subtraction result type */
typedef unsigned char	wchar_t;		/* not really supported properly */

/* offset in bytes of 'membr' in structure 'typ' */
#define offsetof(T,m) \
	((size_t) (((char *) &(((T *) 256)->m)) - ((char *) ((T *) 256))))

#endif STDDEF_H
