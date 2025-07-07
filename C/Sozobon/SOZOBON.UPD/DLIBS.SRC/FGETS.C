#include <stdio.h>

char *fgets(data, limit, fp)
	char *data;
	register int limit;
	register FILE *fp;
	{
	register char *p = data;
	register int c;

	while((--limit > 0) && ((c = fgetc(fp)) != EOF))
		if((*p++ = c) == '\n')
			break;
	*p = '\0';
	return((c == EOF && p == data) ? NULL : data);	/* NULL == EOF */
	}
