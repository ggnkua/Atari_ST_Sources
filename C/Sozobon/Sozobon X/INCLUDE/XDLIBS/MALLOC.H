/*
 *	Header for memory management routines
 */

extern	long	_BLKSIZ;	/* malloc() granularity variable */

extern	void	*malloc(size_t size);
extern	void	*calloc(size_t n, size_t size);
extern	void	*lalloc(long size);
extern	void	*realloc(void *block, size_t size);
extern	long	msize(void *block);
extern	long	memavail(void);

extern	void	*alloca(size_t size);

extern	void	*sbrk(int amount);
extern	int	brk(void *address);
