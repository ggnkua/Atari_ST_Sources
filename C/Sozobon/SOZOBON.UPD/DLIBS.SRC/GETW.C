#include <stdio.h>

int getw(fp)
	register FILE *fp;
	{
	register int n, c;

	if((c = fgetc(fp)) == EOF)
		return(EOF);
	n = (c << 8);
	if((c = fgetc(fp)) == EOF)
		return(EOF);
	n |= (c & 0xFF);
	return(n);
	}

int putw(n, fp)
	register int n;
	register FILE *fp;
	{
	register int m;

	m = (n >> 8);
	if(fputc((m & 0xFF), fp) == EOF)
		return(EOF);
	if(fputc((n & 0xFF), fp) == EOF)
		return(EOF);
	return(n);
	}

long getl(fp)
	register FILE *fp;
	{
	register long n, c;

	if((c = getw(fp)) == EOF)
		return(EOF);
	n = (c << 16);
	if((c = getw(fp)) == EOF)
		return(EOF);
	n |= (c & 0xFF);
	return(n);
	}

long putl(n, fp)
	register long n;
	register FILE *fp;
	{
	register long m;

	m = (n >> 16);
	if(putw((m & 0xFFFFL), fp) == EOF)
		return(EOF);
	if(putw((n & 0xFFFFL), fp) == EOF)
		return(EOF);
	return(n);
	}
