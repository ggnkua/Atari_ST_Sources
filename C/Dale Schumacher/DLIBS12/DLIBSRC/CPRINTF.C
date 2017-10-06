#include <stdio.h>

extern	int	putch();

cprintf(fmt, arg)
	char *fmt;
	int arg;
	{
	return(_printf(NULL, putch, fmt, &arg));
	}
