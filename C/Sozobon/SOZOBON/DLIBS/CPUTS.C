#include <stdio.h>

extern	int	putch();

void cputs(data)
	register char *data;
	{
	while(*data)
		putch(*data++);
	}
