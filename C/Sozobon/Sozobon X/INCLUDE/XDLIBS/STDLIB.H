/* 
 * @(#)stdlib.h, SozobonX, 1994/11/20, XdLibs include file   
 *
 * stdlib.h replaces malloc.h and contains some more standard functions
 * from xdlibs; it is an ANSI compatible header file.
 * See chapter stdlib in xdlibs.txt.
 *
 * IT IS INCLUDED by stdio.h, so have to include it only
 * if you don't use stdio.h
 * -jerry-
 * last changes by 
 *  -VS: 1995/08/28
 */

#ifndef _STDLIB_H
#define	_STDLIB_H
#define	_STDLIB	"XDLIBS"

#ifndef _TYPES_H
#include <types.h>
#endif /* _TYPES_H */

#ifndef _STDDEF_H
#include <stddef.h>
#endif /* _STDDEF_H */

#ifndef _SUPPORT_H
#include <support.h>
#endif /* _SUPPORT_H */

/*
 * some standard macros
 */
#define EXIT_FAILURE	(1)		/* failure return value for exit() */
#define EXIT_SUCCESS	(0)	 	/* success return value for exit() */

#ifdef __MSHORT__
# define RAND_MAX	(0x7FFF)	/* maximum value from rand() */
#else
# define RAND_MAX	(0x7FFFFFFF)	/* maximum value from rand() */
#endif /* __MSHORT__ */

/* some library dependent stuff:
 *   these variables are evaluated usually by startup code
 */
extern	int	errno;

extern	char	*etext;
extern	char	*edata;
extern	char	*end;

extern	short	_argc;
extern	char	**_argv;
extern	short	_ARGV;
extern	short	_intsize;	/* sizeof(int) */

extern	short	_app;		/* app or acc ? */
extern	short	_mint;		/* mintvers or 0 */
extern	short	_magx;		/* MagiC version or 0 */
extern	short	_geneva;	/* ??? */

/* some compatibility macros are included */
#define sync()			/* sync() not possible, no operation */

extern	double	atof(const char *s);
extern	int	atoi(const char *s);
extern	long	atol(const char *s);
/* missing ??:*/
extern  double    strtod(char *number, char **nptr);
/* of course double won't work but float would */

extern  long    strtol(char *number, char **nptr, int base);
extern  unsigned long   strtoul(char *number, char **nptr, int base);

extern	int	rand(void);
/* extern	void	srand(); */
#define srand(seed) 		/* no random seeding required */

extern	void	*calloc(size_t nobj, size_t size);
extern	void	*malloc(size_t size);
extern	void	*realloc(void *p, size_t size);
#ifdef __MSHORT__
extern	void	*lalloc(long size);
extern	void	*lrealloc(void *p, long size);
#else
#define lalloc	malloc
#define lrealloc realloc
#endif
extern	void	free(void *p);

extern	long	msize(void *block);
extern	long	memavail(void);

extern	void	*alloca(size_t size);

extern	void	*sbrk(int amount);
extern	int	brk(void *address);

extern	void	abort(void);
extern	void	exit(int status);
extern	void	atexit( void (*fnc)());

extern	int	system(const char *s);
extern	char	*getenv(const char *name);
extern	int	putenv(const char *name);

extern	void	*bsearch(const void *key, const void *base, size_t num, size_t size,
					int (*cmp)(const void * keyval, const void *datum));
extern	void	qsort(void *base, size_t num, size_t size,
					int (*cmp)(const void * keyval, const void *datum));
extern	int	abs(int x);
extern	long	labs(long x);

#define	_abs(x)		((x)<0?(-(x)):(x))
#define _labs(x)	_abs(x)

typedef struct {
    int		quot;	/* quotient	*/
    int		rem;	/* remainder 	*/
} div_t;

typedef struct {
    long	quot;	/* quotient	*/
    long	rem;	/* remainder 	*/
} ldiv_t;

extern	div_t	div(int num, int denom);
extern	ldiv_t	ldiv(long num, long denom);


#endif /* _STDLIB_H */
