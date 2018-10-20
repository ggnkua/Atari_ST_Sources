/* *	Header for memory management routines */
/* PURE-C */extern	long	_BLKSIZ;	/* malloc() granularity variable */extern	char	*malloc(unsigned int size);extern	void	*calloc(size_t n, size_t size);extern	char	*lalloc(long size);extern	char	*realloc(long *block, unsigned int size);extern	long	msize(void *block);extern	long	memavail();extern	void	*alloca(size_t size);extern	void	*sbrk(int amount);extern	int		brk(void *address);
/* Sozobon 
char *lalloc(long size);
char *malloc(unsigned int size);
char *realloc(long *addr, unsigned int size);
void	free(long *addr);
void	lmemcpy(long *new, long *old, long size);
long	memavail(int i);
long	msize(long *addr);
char *calloc(unsigned int n, int size);
*/
