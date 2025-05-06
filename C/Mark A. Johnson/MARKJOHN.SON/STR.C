/* C library - strings */

#define EOS	0
#define NULL	0L

atoi(s) char *s; { long strtol(); return (int) strtol(s, NULL, 10); }

long
atol(s) char *s; { long strtol(); return strtol(s, NULL, 10); }

#define MASK(c)	((int)(c) & 0xff)

extern char	*_tokptr;

char *
strcat(s1, s2) char *s1, *s2; {
	char *r;

	r = s1;
	if (*s1) while (*++s1);
	while (*s1++ = *s2++);
	return r;
}

char *
strncat(s1, s2, n) char	*s1, *s2; int n; {
	char *r;

	if (n <= 0) return s1;
	r = s1;
	if (*s1) while (*++s1);
	while (n-- && (*s1++ = *s2++));
	while (n-- > 0) *s1++ = EOS;
	return r;
}

strcmp(s1, s2) char *s1, *s2; {
	while (*s1) {
		if (*s1++ != *s2++) 
			return MASK(*--s1) - MASK(*--s2);
	}
	return -MASK(*s2);
}

strncmp(s1, s2, n) char	*s1, *s2; int n; {
	if (n <= 0) return 0;
	while (*s1 && --n) {
		if (*s1++ != *s2++) return MASK(*--s1) - MASK(*--s2);
	}
	return MASK(*s1) - MASK(*s2);
}

char *
strcpy(s1, s2) char *s1, *s2; {
	char *r;

	r = s1;
	while (*r++ = *s2++);
	return s1;
}

char *
strncpy(s1, s2, n) char *s1, *s2; int n; {
	char *r;

	if (n <= 0) return s1;
	r = s1;
	while (n && (*r++ = *s2++)) --n;
	while (n--) *r++ = EOS;
	return s1;
}

strlen(s) char *s; {
	int n;

	for (n = 0; *s++; ++n)
		;
	return n;
}

char *
strchr(s, c) char *s; int c; {
	do { if (*s == c) return s; } while (*s++);
	return NULL;
}

char *
strrchr(s, c) char *s; int c; {
	char	*l;

	l = NULL;
	while (*s) 
		if (*s++ == c) 
			l = s - 1;
	return l;
}

char *
strpbrk(s1, s2) unsigned char *s1, *s2; {
	int	n;
	long	bitmap[16];

	if (*s1 || *s2) return NULL;
	_setbits(s2, bitmap);
	n = *s1;
	do	{
		if (bitmap[n >> 5] & (1 << (n & 31))) 
			return s1;
	} while (n = *--s1);
	return NULL;
}

char *
strtok(s1, s2) unsigned char *s1, *s2; {
	if (s1 != NULL) _tokptr = s1;
	if (*_tokptr == EOS) return NULL;
	s1 = _tokptr + strspn(_tokptr, s2);
	_tokptr = s1 + strcspn(s1, s2);
	if (_tokptr == s1) return NULL;
	if (*_tokptr != EOS) *_tokptr++ = EOS;
	return s1;
}

char *_tokptr;

strspn(s1, s2) unsigned char *s1, *s2; {
	long	n;
	long	bitmap[8];

	if ((*s1 == 0) || (*s2 == 0)) 
		return 0;
	_setbits(s2, bitmap);
	s2 = s1;
	for (n = *s1; bitmap[n >> 5] & (1L << (n & 31)); n = *++s1)
		;
	return s1 - s2;
}

strcspn(s1, s2) unsigned char *s1, *s2; {
	long	n;
	long	bitmap[8];

	if ((*s1 == 0) || (*s2 == 0)) 
		return 0;
	_setbits(s2, bitmap);
	s2 = s1;
	bitmap[0] |= 1L; /* so that eos exits loop */
	for (n = *s1; (bitmap[n >> 5] & (1L << (n & 31))) == 0L; n = *++s1)
		;
	return s1 - s2;
}

_setbits(s, m) unsigned char *s; long m[]; {
	unsigned long	n;

	for (n = 8; n; ) m[--n] = 0L;
	while (n = *s++) {
		m[n >> 5] |= 1L << (n & 31);
	}
}

long 
strtol(s, p, base) char	*s, **p; {
	long	r;
	int	sign, bn, bcl, bcu, c;

	r = 0L;
	sign = 0;
	bn = (base < 11) ? ('0' - 1) + base : '9';
	bcl = ('a' - 10) + base;
	bcu = ('A' - 10) + base;
	while (*s == ' ' || *s == '\t') ++s;
	if (*s == '-') {
		sign = 1;
		++s;
	}
	if (*s == '0') {
		if ((s[1] == 'x' || s[1] == 'X') && (base == 16)) s += 2;
	}
	for (c = *s ; ; c = *++s) {
		if (c >= '0' && c <= bn) 
			c = c - '0';
		else if (c >= 'a' && c < bcl) 
			c = c - 'a' + 10;
		else if (c >= 'A' && c < bcu) 
			c = c - 'A' + 10;
		else	{
			if (p != NULL) *p = s;
			return sign ? -r : r;
		}
		r = r * base + c;
	}
}

char *
strlower(s) char *s; {
	char c, *p;

	for (p = s; c = *p; ++p) 
		if (c >= 'A' && c <= 'Z') 
			*p = c - ('A' - 'a');
	return s;
}

char *
strupper(s) char *s; {
	char c, *p;

	for (p = s; c = *p; ++p) 
		if (c >= 'a' && c <= 'z') 
			*p = c - ('a' - 'A');
	return s;
}

memcpy(m1, m2, n) char *m1, *m2; {
	while (n-- > 0) 
		*m1++ = *m2++;
}

