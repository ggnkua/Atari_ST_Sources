getstruc(ap, s, b)
char	*ap;		/* structure pointer */
register char	*s;	/* structure format */
register char	*b;	/* sequence of bytes */
{
	register int	i;
	register long	l;
	register char	*p = ap;
	register int	lsb = 1;
	static struct {
		char	a21;
		short	a22;
	} a2;
	static struct {
		char	a41;
		long	a44;
	} a4;

	while (i = *s++) {
		switch (i) {
		case '1':
			*p++ = *b++;
			break;
		case '2':
			i = (int) ((char *)&a2.a22 - (char *)&a2) - 1;
			while ((int)(p - ap) & i)
				p++;
			if (lsb) {
				i = (b[1] & 0xFF);
				i <<= 8;
				i |= (b[0] & 0xFF);
			} else {
				i = (b[0] & 0xFF);
				i <<= 8;
				i |= (b[1] & 0xFF);
			}
			*((short *)p) = i; p += sizeof(short); b += 2;
			break;
		case '4':
			i = (int) ((char *)&a4.a44 - (char *)&a4) - 1;
			while ((int)(p - ap) & i)
				p++;
			if (lsb) {
				l = (b[3] & 0xFF);
				l <<= 8;
				l |= (b[2] & 0xFF);
				l <<= 8;
				l |= (b[1] & 0xFF);
				l <<= 8;
				l |= (b[0] & 0xFF);
			} else {
				l = (b[0] & 0xFF);
				l <<= 8;
				l |= (b[1] & 0xFF);
				l <<= 8;
				l |= (b[2] & 0xFF);
				l <<= 8;
				l |= (b[3] & 0xFF);
			}
			*((long *)p) = l; p += sizeof(long); b += 4;
			break;
		case 'L':
			lsb = 1; break;
		case 'M':
			lsb = 0; break;
		default:
			abort();
		}
	}
}
