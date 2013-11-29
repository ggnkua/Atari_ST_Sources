#include <stdio.h>

puts(s)
char *s;
{
    fputs(s, stdout);
    fputc('\n', stdout);
}

fputs(s, stream)
char *s;
FILE *stream;
{
    while (*s)
	fputc(*s++, stream);
}

