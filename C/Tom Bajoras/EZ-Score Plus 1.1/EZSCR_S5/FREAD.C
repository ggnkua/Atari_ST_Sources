#include <stdio.h>

int fread(ptr, size, nitems, stream)
register char *ptr;
int size, nitems;
FILE *stream;
{
    int c;
    register int cnt = nitems*size;
    register int left = cnt;

    while (left > 0) {
	if ((c = getc(stream)) == EOF)
	    return (cnt-left)/size;
	*ptr++ = c;
	left--;
    }
    return nitems > 0 ? nitems : 0;
}

int fwrite(ptr, size, nitems, stream)
char *ptr;
int size, nitems;
long stream;
{
    register int cnt = nitems*size;
    register int left = cnt;

    while (left > 0) {
	if (fputc(*ptr++, stream) == EOF)
	    return (cnt-left)/size;
	left--;
    }
    return nitems > 0 ? nitems : 0;
}
