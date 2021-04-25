/* C library for MJC 2.0 - floating point and long arithmetic */

/* 
 * my floating point routines 
 *
 * 32 bit floating point format
 *	bit	function
 *	31	sign
 *	24-30	exponent (excess 64)
 *	0-23	fraction
 */

#define NULL	0L

#define EXCESS	64
#define DIGITS	24
#define MAXFRAC	0xFFFFFF
#define MAXEXP	0x7F
#define MAXBITS	32

#define sign(x) ((x >> 31) & 1)
#define exp(x) (((x >> 24) & MAXEXP) - EXCESS)
#define frac(x) (x & MAXFRAC)
#define negate(x) (x ^ 0x80000000L)

/* long to float */ 

long
_ltof(n) long n; {
	int s;
	long _fnorm();
	if (s = (n < 0L)) n = -n;
	return _fnorm(s, DIGITS, n);
}

/* float to long */

long
_ftol(u) long u; {
	int e, s;
	long f;
	s = sign(u);
	e = exp(u);
	f = frac(u);
	if (e <= 0) { /* no fractional part */
		return 0L;
	}
	else if (e < DIGITS) {
		f = f >> (DIGITS - e);
	}
	else if (e == DIGITS) {
		/* already there! */
	}
	else if (e < MAXBITS) {
		f = f << (e - DIGITS);
	}
	else	{
		_ferr("ftol overflow\n\r");
		f = 0x7FFFFFFF;
	}
	return s ? -f : f;
}

long
_fcmp(x, y) long x, y; {
	return (sign(x) && sign(y)) ? y - x : x - y;
}

long
_fneg(x) long x; {
	return negate(x);
}

long
_fsub(u, v) long u, v; { 
	long _fadd();
	return _fadd(u, negate(v)); 
}

long
_fadd(u, v) long u, v; {
	int t, sw, eu, ev, ew;
	long fu, fv, fw, _fnorm();
	if (u == 0L) return v;
	if (v == 0L) return u;
	eu = exp(u);
	ev = exp(v);
	fu = sign(u) ? -frac(u) : frac(u);
	fv = sign(v) ? -frac(v) : frac(v);
	t = eu - ev;
	if (t <= -DIGITS) { /* u << v */
		fw = fv;
		ew = ev;
	}
	else if (t <= 0) { /* u <= v */
		if (t) fu >>= -t;
		fw = fv + fu;
		ew = ev;
	}
	else if (t < DIGITS) { /* u > v */
		fv >>= t;
		fw = fv + fu;
		ew = eu;
	}
	else	{ /* u >> v */
		fw = fu;
		ew = eu;
	}
	if (sw = (fw < 0))
		fw = -fw;
	return _fnorm(sw, ew, fw);
}

long
_fmul(u, v) long u, v; {
	int sw, ew, eu, ev;
	long fu, fv, fw, _fnorm();
	if ((fu = frac(u)) == 0)
		return 0L;
	if ((fv = frac(v)) == 0)
		return 0L;
	eu = exp(u);
	ev = exp(v);
	sw = sign(u) ^ sign(v);
	ew = eu + ev - 8;
	fw = (fu >> 8) * (fv >> 8);
	return _fnorm(sw, ew, fw);
}

long
_fdiv(u, v) long u, v; {
	int sw, ew;
	long _fnorm();
	long b, fu, fv, fw;
	if ((fu = frac(u)) == 0)
		return 0L;
	if ((fv = frac(v)) == 0)
		return 0L;
	sw = sign(u) ^ sign(v);
	ew = exp(u) - exp(v) + 1;
	fw = 0L;
	b = 1L << (DIGITS - 1);
	while (b) {
		if (fu >= fv) {
			fw += b;
			fu -= fv;
		}
		b >>= 1;
		fv >>= 1;
	}
	return _fnorm(sw, ew, fw);
}

/* ascii to float, needs no other support routines */

long 
atof(s) char *s; {
	int e, i, c, sgn;
	unsigned long ipart, fpart, f, bit, div;
	long _fnorm();
	/* get to the start of the digits */
	while (*s && *s <= ' ')
		s++;
	if ((sgn = (*s == '-')) || *s == '+')
		s++;
	/* get the integer and fraction parts */
	ipart = 0L;
	while (*s >= '0' && *s <= '9')
		ipart = ipart * 10L + (*s++ - '0');
	fpart = 0L;
	if (*s == '.') {
		s++;
		/* 9 digits of precision please */
		for (i = 0; i < 9; i++) {
			if (*s >= '0' && *s <= '9')
				c = *s++ - '0';
			else	c = 0;
			fpart = fpart * 10L + c;
		}
		div = 500000000;
	}
	/* normalize the integer part, then work in the fraction */
	if (ipart) {
		f = _fnorm(sgn, DIGITS, ipart);
		e = exp(f);
	}
	else	e = f = 0L;
	if (fpart && e < DIGITS) { /* room for the fraction part */
		f = frac(f);
		bit = 1L << (DIGITS - 1 - e);
		/* add the fraction's bits to f */
		while (bit && fpart) {
			if (fpart >= div) {
				fpart -= div;
				f |= bit;
			}
			bit >>= 1;
			div >>= 1;
		}
		if (fpart) f++; /* round up */
		f = _fnorm(sgn, e, f);
	}
	/* now handle an exponent factor, if any */
	if (f && (*s == 'e' || *s == 'E')) {
		i = 0;
		s++;
		if ((c = (*s == '-')) || *s == '+')
			s++;
		for (i = 0; *s >= '0' && *s <= '9'; s++)
			i = i * 10 + (*s - '0');
		if (c) i = -i;
		while (i > 0) {
			e = exp(f);
			f = frac(f);
			f = _fnorm(sgn, e, f * 10L);
			i--;
		}
		while (i < 0) {
			e = exp(f);
			f = frac(f);
			f = _fnorm(sgn, e, f / 10L);
			i++;
		}
	}
	return f;
}

long
_fnorm(s, e, f) int s, e; unsigned long f; {
	if (f == 0) {
		return 0L;
	}
	else	{
		while (f & 0xFF000000L) {
			f = (f >> 1) + (f & 1);
			e++;
		}
		while ((f & 0x800000L) == 0) {
			f = f << 1;
			e--;
		}
	}
	if (e >= EXCESS) {
		_ferr("float overflow\n\r");
		return ((long)s << 31) | 0x7FFFFFFFL;
	}
	else if (e < -EXCESS) {
		_ferr("float underflow\n\r");
		return 0L;
	}
	/* pack the result */
	return 	((long)s << 31) | 
		(((long)(e + EXCESS) & MAXEXP) << DIGITS) | 
		(f & MAXFRAC);
}

_ferr(s) char *s; { while (*s) trap(1, 2, *s++); }

/* 
 * stuff for long binary ops (both signed and unsigned)
 *	a and b are the left and right arguments to the binary operator
 *
 * div and mod are done by long division, shift b up until >= a, then
 * back down, subtracting when appropriate
 *
 * mul is done by shifts and adds
 */

long
_lmul(a, b) long a, b; {
	int neg = 0;
	long _ulmul();
	if (a < 0L) { neg++; a = -a; }
	if (b < 0L) { neg++; b = -b; }
	a = _ulmul(a, b);
	return neg & 1 ? -a : a;
}

long
_ldiv(a, b) long a, b; {
	int neg = 0;
	long _ldivmod();
	if (a < 0L) { neg++; a = -a; }
	if (b < 0L) { neg++; b = -b; }
	a = _ldivmod(a, b, 0);
	return neg & 1 ? -a : a;
}

long
_lmod(a, b) long a, b; {
	long _ldivmod();
	if (a < 0L) a = -a;
	if (b < 0L) b = -b;
	return _ldivmod(a, b, 1);
}

long
_ulmul(a, b) unsigned long a, b; {
	long result;
	result = 0L;
	while (a) {
		if (a & 1L)
			result += b;
		a >>= 1L;
		b <<= 1L;
	}
	return result;
}

long
_uldiv(a, b) long a, b; {
	long _ldivmod();
	return _ldivmod(a, b, 0);
}

long 
_ulmod(a, b) long a, b; {
	long _ldivmod();
	return _ldivmod(a, b, 1);
}

long
_ldivmod(a, b, rem) unsigned long a, b; int rem; {
	int i = 0;
	unsigned long result = 0L;
	if (b) {
		while ((a > b) && !(b & 0x80000000L)) {
			i++;
			b <<= 1L;
		}
		while (1) {
			if (a >= b) {
				a -= b;
				result++;
			}
			if (i == 0) break;
			i--;
			result <<= 1L;
			b >>= 1L;
		}
		return rem ? a : result;
	}
	else	i/0;	/* should case a "divide zero" trap */
}
