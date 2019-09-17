/*
 *	Header for dynamic memory management routines
 */

extern	unsigned long	_BLKSIZ;	/* malloc() granularity variable */

extern	char	*malloc();
extern	char	*calloc();
extern	char	*lalloc();
extern	char	*realloc();
extern	long	msize();
extern	long	memavail();
