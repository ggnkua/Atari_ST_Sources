/*
 * Atod converts the string `num' to a double and returns the value.
 * Note, that if there is a non-digit in the string, or if there is
 * an overflow, then it exits with an appropriate error message.
 * Also note that atod accepts leading zero for octal and leading
 * 0x for hexidecimal, and that in the latter case, a-f and A-F are
 * both accepted as digits.
 */
double
atod(num)
char	*num;
{
	register char	*str;
	register int	i;
	double		res	= 0,
			base	= 10;

	str = num;
	i = *str++;
	if (i == '0')
		if ((i=*str++) == 'x') {
			i = *str++;
			base = 0x10;
		} else
			base = 010;
	for (; i != '\0'; i=*str++) {
		i = todigit(i);
		if (i >= base)
			die("bad number `%s'", num);
		res = res * base + i;
		if (res+1 == res)
			die("Number too big `%s'", num);
	}
	return (res);
}
