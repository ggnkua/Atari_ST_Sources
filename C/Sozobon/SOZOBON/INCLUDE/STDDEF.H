/*
 * STDDEF.H	standard definitions
 */

#ifndef STDDEF_H
#define STDDEF_H

#define	dLibs		(0x1200)	/* dLibs identifier (also vsn #) */

#ifndef	NULL
#define	NULL		(0L)
#endif

typedef	int		size_t;		/* sizeof() value type */
typedef	long		ptrdiff_t;	/* pointer subtraction result type */

/* offset in bytes of 'membr' in structure 'typ' */
#define offsetof(T,m) \
	((size_t) (((char *) &(((T *) 256)->m)) - ((char *) ((T *) 256))))

#endif STDDEF_H
