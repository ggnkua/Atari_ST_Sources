putstruc(ap, s, b)
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
			*b++ = *p++;
			break;
		case '2':
			i = (int) ((char *)&a2.a22 - (char *)&a2) - 1;
			while ((int)(p - ap) & i)
				p++;
			i = *((short *)p); p += sizeof(short);
			if (lsb) {
				b[0] = (char)i;
				i >>= 8;
				b[1] = (char)i;
			} else {
				b[1] = (char)i;
				i >>= 8;
				b[0] = (char)i;
			}
			b += 2; break;
		case '4':
			i = (int) ((char *)&a4.a44 - (char *)&a4) - 1;
			while ((int)(p - ap) & i)
				p++;
			l = *((long *)p); p += sizeof(long);
			if (lsb) {
				b[0] = (char)l;
				l >>= 8;
				b[1] = (char)l;
				l >>= 8;
				b[2] = (char)l;
				l >>= 8;
				b[3] = (char)l;
			} else {
				b[3] = (char)l;
				l >>= 8;
				b[2] = (char)l;
				l >>= 8;
				b[1] = (char)l;
				l >>= 8;
				b[0] = (char)l;
			}
			b += 4; break;
		case 'L':
			lsb = 1; break;
		case 'M':
			lsb = 0; break;
		default:
			abort();
		}
	}
}
