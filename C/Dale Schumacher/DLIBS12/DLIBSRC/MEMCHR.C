#include <stddef.h>

char *memchr(buf, c, cnt)
	register char *buf, c;
	register int cnt;
	{
	while(cnt--)
		if(*buf++ == c)
			return(--buf);
	return(NULL);
	}
