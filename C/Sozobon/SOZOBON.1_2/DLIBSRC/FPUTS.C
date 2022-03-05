#include <stdio.h>

int fputs(data, fp)
	register char *data;
	register FILE *fp;
	{
	register int n = 0;

	while(*data)
		{
		if(fputc(*data++, fp) == EOF)
			return(EOF);
		++n;
		}
	return(n);
	}

int puts(data)
	char *data;
	{
	register int n;

	if(((n = fputs(data, stdout)) == EOF)
	|| (fputc('\n', stdout) == EOF))
		return(EOF);
	return(++n);
	}
