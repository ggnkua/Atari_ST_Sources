int strrpos(string, symbol)
	register char *string, symbol;
	{
	register char *p;
	char *strrchr();

	if(p = strrchr(string, symbol))
		return((int) (p - string));
	return(-1);
	}
