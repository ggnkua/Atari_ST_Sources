char	_numstr[] = "0123456789ABCDEF";

char *ultoa(n, buffer, radix)
	register unsigned long n;
	register char *buffer;
	register int radix;
	{
	register char *p = buffer;
	char *strrev();

	do
		{
		*p++ = _numstr[n % radix];	/* grab each digit */
		}
		while((n /= radix) > 0);
	*p = '\0';
	return(strrev(buffer));			/* reverse and return it */
	}

char *ltoa(n, buffer, radix)
	register long n;
	register char *buffer;
	int radix;
	{
	register char *p = buffer;

	if (n < 0)
		{
		*p++ = '-';
		n = -n;
		}
	ultoa(n, p, radix);
	return(buffer);
	}

char *itoa(n, buffer, radix)
	int n;
	char *buffer;
	int radix;
	{
	char *ltoa();

	return(ltoa(((long) n), buffer, radix));
	}
