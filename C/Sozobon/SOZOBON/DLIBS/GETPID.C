extern char	*_base;

int getpid()
	{
	register unsigned long n;

	n = (unsigned long) _base;	/* load process base address */
	return(0x7FFF & (n >> 8));	/* create unique pid from it */
	}
