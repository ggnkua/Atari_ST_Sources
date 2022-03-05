int strpos(string, symbol)
	register char *string, symbol;
	{
	register char *p;
	char *strchr();
	
	if(p = strchr(string, symbol))
		return((int) (p - string));
	return(-1);
	}
