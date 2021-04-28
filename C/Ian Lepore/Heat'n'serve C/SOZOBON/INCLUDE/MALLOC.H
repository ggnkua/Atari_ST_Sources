/*
 *	Header for memory management routines
 */

#ifndef MALLOC_H
#define MALLOC_H

extern	unsigned long	_BLKSIZ;	/* malloc() granularity variable */

extern	void	*malloc();
extern	void	*calloc();
extern	void	*lalloc();
extern	void	*realloc();
extern	long	msize();
extern	long	memavail();

extern	void	*alloca();

extern	void	*sbrk();
extern	int	brk();

#endif
