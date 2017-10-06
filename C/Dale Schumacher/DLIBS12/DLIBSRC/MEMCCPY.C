#include <stddef.h>

char *memccpy(dst, src, c, cnt)
	register char *dst, *src, c;
	register int cnt;
	{
	while(cnt--)
		if((*dst++ = *src++) == c)
			return(dst);
	return(NULL);
	}
