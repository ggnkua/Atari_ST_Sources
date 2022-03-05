_prtfld(op, put, buf, ljustf, sign, pad, width, preci)
	register char *op;
	register int (*put)();
	register unsigned char *buf;
	int ljustf;
	register char sign;
	char pad;
	register int width;
	int preci;
/*
 *	Output the given field in the manner specified by the arguments.
 *	Return the number of characters output.
 */
	{
	register int cnt = 0, len;
	register unsigned char ch;

	len = strlen(buf);

	if (*buf == '-')
		sign = *buf++;
	else if (sign)
		len++;

	if ((preci != -1) && (len > preci))	/* limit max data width */
		len = preci;

	if (width < len)	/* flexible field width or width overflow */
		width = len;

/* at this point:
 *	width = total field width
 *	len   = actual data width (including possible sign character)
 */
	cnt = width;
	width -= len;

	while (width || len)
		{
		if (!ljustf && width)		/* left padding */
			{
			if (len && sign && (pad == '0'))
				goto showsign;
			ch = pad;
			--width;
			}
		else if (len)
			{
			if (sign)
				{
showsign:			ch = sign;	/* sign */
				sign = '\0';
				}
			else
				ch = *buf++;	/* main field */
			--len;
			}
		else
			{
			ch = pad;		/* right padding */
			--width;
			}
		(*put)(ch, op);
		}

	return(cnt);
	}
