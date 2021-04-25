/*
 *	Header for memory management routines
 */

extern	long	_BLKSIZ;	/* malloc() granularity variable */

extern	char	*malloc();
extern	char	*calloc();
extern	char	*lalloc();
extern	char	*realloc();
extern	long	msize();
extern	long	memavail();

extern	char	*alloca();

extern	char	*sbrk();
extern	int	brk();
