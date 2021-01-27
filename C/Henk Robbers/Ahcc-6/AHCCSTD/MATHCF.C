#if sizeof(double) != 8
#error size of double must be 8 (use AHCCCF)
#else

#define WITH_68881 0

#include <stdio.h>

#define and &&
#define or ||
#define eq ==
#define ne !=
#define elif else if
#define othw }else{
#define global


#define M_E             2.71828182845904523536
#define M_LOG2E         1.44269504088896340736
#define M_LOG10E        0.434294481903251827651
#define M_LN2           0.693147180559945309417
#define M_LN10          2.30258509299404568402
#define M_PI            3.14159265358979323846
#define M_PI_2          1.57079632679489661923
#define M_PI_4          0.785398163397448309116
#define M_1_PI          0.318309886183790671538
#define M_2_PI          0.636619772367581343076
#define M_1_SQRTPI      0.564189583547756286948
#define M_2_SQRTPI      1.12837916709551257390
#define M_SQRT2         1.41421356237309504880
#define M_SQRT_2        0.707106781186547524401
#define M_SQRT_3		1.73205080756887729353
#define M_SQRT_3M1		0.73205080756887729353

#define sqrt(x)       __FSQRT__(x)
#define fabs(x)       __FABS__(x)

extern short errno;

/* float.h */

#define DOFF 4

#define FINITE -1
#define INF 1
#define NAN 2

#define DBIAS 0x3fe
#define DSIGN 0x8000

/* xmath.h */

#define DFRAC ((1<<DOFF)-1)
#define DMASK (0x7fff&~DFRAC)
#define DMAX  ((1<<(15-DOFF))-1)
#define DNAN  (0x8000|DMAX<<DOFF|1<<(DOFF-1))

#define Dsign(x) (((unsigned short *)&(x))[0] & DSIGN)

#define HUGE_RAD 3.14e30
#define HUGE_EXP (DMAX * 900L / 1000)
#define SAFE_EXP (DMAX >> 1)

typedef const union
{
	unsigned short w[4];
	double d;
} Dconst;

/* xvalues.c */

#define NBITS (48+DOFF)

#define INIT(w0) {w0,0,0,0}

Dconst Hugeval = {INIT((DMAX-1) << DOFF)};
Dconst Inf     = {INIT(DMAX << DOFF)};
Dconst Nan     = {INIT(DNAN)};
Dconst Rteps   = {INIT((DBIAS-NBITS/2)<<DOFF)};
Dconst Xbig    = {INIT((DBIAS+NBITS/2)<<DOFF)};
Dconst Half    = {INIT(0x3fe0)};

#define x_to_s unsigned short *s = (unsigned short *)x
#define d_xchar	short xchar = (s[0] & DMASK) >> DOFF
#define allor ((s[0] & DFRAC) or s[1] or s[2] or s[3])

extern FILE *dp;

int tus1, tus2;
double sfint, slog10;

static
double zero = 0.0, half = 0.5, one = 1.0, two = 2.0;

void psf(char *opm, void *v), ps(void *v);

static
short Test(double *x)
{
	x_to_s;
	d_xchar;

	if (xchar eq DMAX)
		return    allor ? NAN : INF;

	if (0 < xchar or allor)
		return FINITE;

	return 0;
}

static
short Tint(double *x, short xexp)
{
	/* Test and drop (scaled) fractional bits */
	x_to_s;
	unsigned short frac = allor;
	d_xchar;

	if (xchar eq 0 and !frac)
		return 0;
	elif (xchar ne DMAX)
		;
	elif (!frac)
		return INF;
	else
	{
		errno = EDOM;
		return NAN;
	}

	xchar = (DBIAS+48+DOFF+1) - xchar - xexp;

	if (xchar <= 0)
		return 0;			/* No bits to drop */
	elif (DOFF + 48 < xchar)
	{						/* All frac bits */
		s[0] = 0, s[1] = 0, s[2] =0, s[3] =0;
		return FINITE;
	othw
						/* strip out frac bits */
		static const unsigned short mask[] =
		{
			0x0000,0x0001,0x0003,0x0007,
			0x000f,0x001f,0x003f,0x007f,
			0x00ff,0x01ff,0x03ff,0x07ff,
			0x0fff,0x1fff,0x3fff,0x7fff
		};
		static const size_t sub[] = {3,2,1,0};

		frac = mask[xchar & 0xf];
		xchar >>= 4;
		frac &= s[sub[xchar]];
		s[sub[xchar]] ^= frac;
		switch (xchar)
		{					/* cascade through */
		case 3:
			frac |= s[1]; s[1] = 0;
		case 2:
			frac |= s[2]; s[2] = 0;
		case 1:
			frac |= s[3]; s[3] = 0;
		}

		return frac ? FINITE : 0;
	}
}

static
short Dnorm(unsigned short *s)
{
	short xchar = 0;
	unsigned short sign = s[0] & DSIGN;

	if ((s[0] &= DFRAC) ne 0 or s[1] or s[2] or s[3])
	{
		while (s[0] eq 0)	/* shift left by 16 */
		{
			s[0] = s[1];
			s[1] = s[2];
			s[2] = s[3];
			s[3] = 0;
			xchar -= 16;
		}

		while (s[0] < 1 << DOFF)	/* shift left by 1 */
		{
			s[0] = s[0]<<1 | s[1] >> 15;
			s[1] = s[1]<<1 | s[2] >> 15;
			s[2] = s[2]<<1 | s[3] >> 15;
			s[3] <<= 1;
			xchar--;
		}

		while (1 << DOFF+1 <= s[0])
		{
			s[3] = s[3]>>1 | s[2] << 15;
			s[2] = s[2]>>1 | s[1] << 15;
			s[1] = s[1]>>1 | s[0] << 15;
			s[0] >>= 1;
			xchar++;
		}

		s[0] &= DFRAC;
	}

	s[0] |= sign;
	return xchar;
}

/* Separate *x to 1/2 <= |frac| < 1 and 2^-ex */
static
short Dunscale(short *ex, double *x)
{
	x_to_s;
	d_xchar;

	if (xchar eq DMAX)
	{
		*ex = 0;
		return allor ? NAN : INF;
	}

	if (0 < xchar or (xchar = Dnorm(s)) ne 0)
	{
		s[0] = (s[0] & ~DMASK) | (DBIAS << DOFF);
		*ex = xchar - DBIAS;
		return FINITE;
	}

	*ex = 0;
	return 0;
}

static
short Dscale(double *x, short xexp)
{
	long lexp;
	x_to_s;
	d_xchar;

	if (xchar eq DMAX)
		return allor ? NAN : INF;
	elif (0 < xchar)
		;
	elif ((xchar = Dnorm(s)) eq 0)
		return 0;

	lexp = xexp + xchar;
	if (lexp > DMAX)		/* overflow, return +/- INF */
	{
		*x = (s[0] & DSIGN) ? -Inf.d : +Inf.d;
		return INF;
	}
	elif (0 < lexp)		/* finite result, repack */
	{
		s[0] = (s[0] & ~DMASK) | (short)lexp << DOFF;
		return FINITE;
	othw
		unsigned short sign = s[0] & DSIGN;

		s[0] = 1 << DOFF | s[0] & DFRAC;
		if (lexp < -(48+DOFF+1))
			xexp = -1;		/* certain underflow */
		else
		{					/* might not underflow */
			for (xexp = lexp; xexp <= -16; xexp += 16)
			{
				s[3] = s[2];	/* scale by words */
				s[2] = s[1];
				s[1] = s[0];
				s[0] = 0;
			}

			if ((xexp = -xexp) ne 0)	/* scale by bits */
			{
				s[3] = s[3] >> xexp | s[2] << 16-xexp;
				s[2] = s[2] >> xexp | s[1] << 16-xexp;
				s[1] = s[1] >> xexp | s[0] << 16-xexp;
				s[0] >>= xexp;
			}

			if (0 <= xexp  and (s[0] or s[1] or s[2] or s[3]))
			{							/* denormalized */
				s[0] |= sign;
				return FINITE;
			othw
				s[0] = sign;
				s[1] = 0;
				s[2] = 0;
				s[3] = 0;
			}
		}
	}
	return 0;
}

#ifndef fabs
double fabs(double x)
{
	switch (Test(&x))		/* Test for special codes */
	{
	case NAN:	errno = EDOM; return x;
	case INF:	errno = ERANGE; return Inf.d;
	case 0:		return zero;
	default:	return x < 0 ? -x : x;
	}
}
#endif

global
double ceil(double x)
{
	return  (Tint(&x, 0) < 0 and 0 < x) ? x + one : x;
}

global
double floor(double x)
{
	return (Tint(&x, 0) < 0 and x < 0) ? x - one : x;
}

global
double modf(double x, double *pint)
{
	*pint = x;
	switch (Tint(pint, 0))
	{
	case NAN: return x;
	case INF:
	case 0:   return zero;
	default:  return x - *pint;
	}
}

global
double frexp(double x, int *exp)
{
	short binexp;

	switch (Dunscale(&binexp, &x))
	{
	case NAN:
	case INF:
		errno = EDOM;
		*exp = 0;
		return x;
	case 0:
		*exp = 0;
		return zero;
	default:
		*exp = binexp;
		return x;
	}
}


global
double ldexp(double x, int xexp)
{
	switch (Test(&x))
	{
	case NAN:	errno = EDOM;	break;
	case INF:	errno = ERANGE;	break;
	case 0:						break;
	default:	Dscale(&x,xexp);
	}
	return x;
}

global
double fmod(double x, double y)
{
	short errx = Test(&x),
	      erry = Test(&y);

	if (errx eq NAN or erry eq NAN or errx eq INF or erry eq 0)
	{
		errno = EDOM;
		return errx eq NAN ? x : erry eq NAN ? y : Nan.d;
	}

	if (errx eq 0 or erry eq INF)
		return x;
	else
	{
		double t;
		short n = 0, neg = 0, ychar;

		if (y < zero)
			y = -y;
		if (x < zero)
			x = -x, neg = 1;

		t = y;
		Dunscale(&ychar, &t);

		do
		{
			short xchar;

			t = x;

			if (   n < 0
			    or Dunscale(&xchar, &t) eq 0
			    or (n = xchar - ychar) < 0
			   )
				return neg ? -x : x;

			while (0 <= n)
			{
				t = y;
				Dscale(&t, n);
				if (t <= x)
				{
					x -= t;
					break;
				}
				--n;
			}
		} while (1);
	}
}

static
double poly(double x, const double *tab, int n)
{
	double y;
	for (y=*tab; 0 <= --n;)
		y = y * x + *++tab;

	return y;
}

static
double
dc[] =
{
	-0.000000000011470879,
	 0.000000002087712071,
	-0.000000275573192202,
	 0.000024801587292937,
	-0.001388888888888893,
	 0.041666666666667325,
	-0.50000000000000001,
	 1.0
},
ds[] =
{
	-0.000000000000764723,
	 0.000000000160592578,
	-0.000000025052108383,
	 0.000002755731921890,
	-0.000198412698412699,
	 0.008333333333333372,
	-0.166666666666666667,
	 1.0
};

static const double
	c1 = 3294198.0 / 2097152.0,
	c2 = 3.1391647866504813217e-7,
	twobypi = M_2_PI,
	twopi   = 2*M_PI;


static
double Sin(double x, unsigned int qoff)
{
	double g, y; long quad = 0;

	switch (Test(&x))
	{
	case NAN:	errno = EDOM; return x;
	case INF:	errno = EDOM; return Nan.d;
	case 0:		return qoff ? one : zero;
	}

	if (x < -HUGE_RAD or HUGE_RAD < x)
	{
		g = x / twopi;
		Tint(&g, 0);
		x -= g * twopi;
	}

	g = x * twobypi;
	quad = (long)(0 < g ? g + Half.d : g - Half.d);
	qoff += (unsigned long)quad & 3;
	g = quad;
	g = (x - g * c1) - g * c2;

#if 1
	if (g < 0)
		y = -g;
	else
		y = g;
	if (y < Rteps.d)
#else
	if (( g < 0 ? -g : g) < Rteps.d)
#endif
	{
		if (qoff & 1)		/* cos */
			g = 1;
	}
	elif (qoff & 1)
		g = poly(g * g, dc, 7);	/* cos */
	else
		g *= poly(g * g, ds, 7);	/* sin */

	return (qoff & 2 ? -g : +g);
}

global
double cos(double x)
{
#if WITH_68881
{
	double y = __FCOS__ x;
	fprintf(dp, "fcos: %g\n", y);
}
#endif
	return Sin(x, 1);
}

global
double sin(double x)
{
#if WITH_68881
{
	double y = __FSIN__ x;
	fprintf(dp, "fsin: %g\n", y);
}
#endif
	return Sin(x, 0);
}

static const double
tp[] =
{
	-0.17861707342254426711e-4,
	 0.34248878235890589960e-2,
	-0.13338350006421960681e+0
},
tq[] =
{
	 0.49819433993786512270e-6,
	-0.31181531907010027307e-3,
	 0.25663832289440112864e-1,
	-0.46671683339755294240e+0
};

global
double tan(double x)
{
	double g, gd, y;
	long quad;

#if WITH_68881
{
	double y = __FTAN__ x;
	fprintf(dp, "ftan: %g\n", y);
}
#endif

	switch (Test(&x))
	{
	case NAN:	errno = EDOM; return x;
	case INF:	errno = EDOM; return Nan.d;
	case 0:		return zero;
	}

	if (x < -HUGE_RAD or HUGE_RAD < x)
	{
		g = x / twopi;
		Tint(&g, 0);
		x -= g * twopi;
	}

	g = x * twobypi;
	quad = (long)(0 < g ? g + Half.d : g - Half.d);
	g = quad;
	g = (x - g * c1) - g * c2;
	gd = one;

	if (Rteps.d < (g < 0 ? -g : +g))
	{
		double y = g * g;
		gd += (((tq[0] * y + tq[1]) * y + tq[2]) * y + tq[3]) * y;
		g += ((tp[0] * y +tp[1]) * y + tp[2]) * y * g;
	}

	return (quad & 1) ? -gd/g : g/gd;
}


static const double
ap[] =
{
	-0.69674573447350646411e+0,
	 0.10152522233806463645e+2,
	-0.39688862997504877339e+2,
	 0.57208227877891731407e+2,
	-0.27368494524164255994e+2
},
aq[] =
{
	 0.10000000000000000000e+1,
	-0.23823859153670238830e+2,
	 0.15095270841030604719e+3,
	-0.38186303361750149284e+3,
	 0.41714430248260412556e+3,
	-0.16421096714498560795e+3
};

static const double
	piby2 = M_PI_2,
	piby4 = M_PI_4;

static
double Asin(double x, int idx)
{
	double g, y;
	const short errx = Test(&x);

	if (0 < errx)
	{
		errno = EDOM;
		return errx eq NAN ? x : Nan.d;
	}

	if (x < 0)
		y = -x, idx |= 2;
	else
		y = x;

	if (y < Rteps.d)
		;
	elif (y < Half.d)
	{
		g = y * y;
		y += y * g * poly(g, ap, 4) / poly(g, aq, 5);
	}
	elif (y < one)
	{
		idx |= 4;
		g = (one - y) / two;
		y = sqrt(g);
		y += y;
		y += y * g * poly(g, ap, 4) / poly(g, aq, 5);
	}
	elif (y eq one)
		idx |= 4, y = zero;
	else
	{
		errno = EDOM;
		return Nan.d;
	}

	switch(idx)
	{
		default:
		case 0:
		case 5:
			return y;
		case 1:
		case 4:
			return (piby4 - y) + piby4;
		case 2:
			return -y;
		case 3:
			return (piby4 + y) + piby4;
		case 6:
			return (-piby4 + y) - piby4;
		case 7:
			return (piby2 - y) + piby2;
	}
}

global
double acos(double x)
{
#if WITH_68881
{
	double y = __FACOS__ x;
	fprintf(dp, "facos: %g\n", y);
}
#endif
	return Asin(x, 1);
}

global
double asin(double x)
{
#if WITH_68881
{
	double y = __FASIN__ x;
	fprintf(dp, "fasin: %g\n", y);
}
#endif
	return Asin(x, 0);
}

static const double
a[] =
{
	0.0,
	0.52359877559829887308,
	M_PI_2,
	1.04719755119659774615,
	M_PI_2,
	2.09439510239319549231,
	M_PI,
	2.61799387799149436538
},
atp[] =
{
	-0.83758299368150059274e+0,
	-0.84946240351320683534e+1,
	-0.20505855165861651981e+2,
	-0.13688768894191926929e+2
},
atq[] =
{
	0.10000000000000000000e+1,
	0.15024001160028576121e+2,
	0.59578436142597344465e+2,
	0.86157349597130242515e+2,
	0.41066306682575781263e+2
};

static const double
	fold    = 0.26794919243112270647,
	sqrt3   = M_SQRT_3,
	sqrt3m1 = M_SQRT_3M1;

static
double Atan(double x, unsigned short idx)
{
	if (fold < x)
	{
		x = (((sqrt3m1 * x - Half.d) - Half.d) + x) / (sqrt3 + x);
		idx |= 1;
	}

	if (x < Rteps.d or Rteps.d < x)
	{
		const double g = x * x;
		x +=  x * g / poly(g, atq, 4)
		      * (((atp[0] * g + atp[1]) * g + atp[2]) * g + atp[3]);
	}

	if (idx & 2)
		x = -x;

	x += a[idx & 7];

	return (idx & 8) ? -x : +x;
}

global
double atan(double x)
{
	unsigned short hex = 0;

#if WITH_68881
{
	double y = __FATAN__ x;
	fprintf(dp, "fatan: %g\n", y);
}
#endif
	switch(Test(&x))
	{
	case NAN:	errno = EDOM; return x;
	case INF:	return Dsign(x) ? -piby2 : piby2;
	case 0:		return zero;
	}

	if (x < 0)
		x = -x, hex = 8;

	if (one < x)
		x = one / x, hex ^= 2;

	return Atan(x, hex);
}

global
double atan2(double x, double y)
{
	double z;
	short errx , erry;
	unsigned short hex = 0;

	errx = Test(&x);
	erry = Test(&y);

	if (errx <= 0 and erry <= 0)
	{
		if (y < 0)
			y = -y, hex = 8;

		if (x < 0)
			x = -x, hex ^= 6;
		elif (x < y)
			z = x / y, hex ^= 2;
		elif (0 < x)
			z = y / x;
		else
			return zero;
	}
	elif (errx eq NAN or erry eq NAN)
	{
		errno = EDOM;
		return errx eq NAN ? x : y;
	othw
		z = errx eq erry ? one : zero;
		hex = Dsign(y) ? 8 : 0;
		if (Dsign(x))
			hex ^= 6;
		if (erry eq INF)
			hex ^= 2;
	}

	return Atan(z, hex);
}

static const double
	sqrt2 = M_SQRT2;

#ifndef sqrt
global
double sqrt(double x)
{
	short xexp; double y;
#if WITH_68881
{
	double y = __FSQRT__ x;
	fprintf(dp, "fsqrt: %g\n", y);
}
#endif

	switch(Dunscale(&xexp, &x))
	{
	case 0: return zero;
	case NAN: errno = EDOM; return Nan.d;
	case INF:
		if (Dsign(x))
		{
			errno = EDOM;
			return Nan.d;
		othw
			errno = ERANGE;
			return Inf.d;
		}
	}

	if (x < 0)
	{
		errno = EDOM;
		return Nan.d;
	}

	y = (-0.1984742 * x + 0.8804894) * x + 0.3176687;
	y = Half.d * (y + x / y);
	y += x / y;
	x = 0.25 * y + x / y;
	if (xexp & 1)
		x *= sqrt2, --xexp;
	Dscale(&x, xexp / 2);
	return x;
}
#endif

static const double
pp[] =
{
	0.31555192765684646356e-4,
	0.75753180159422776666e-2,
	0.25000000000001000000e+0
},
pq[] =
{
	0.75104028399870046114e-6,
	0.63121894374398503557e-3,
	0.56817302698551221787e-1,
	0.50000000000000000000e+0
};

static const double
	ec1 = 22713.0 / 32768.0,
	ec2 = 1.428606820309417232e-6,
	hugexp =
#if 0
	        (double)		/* todo:: correction, should be acceptable */
#endif
                    HUGE_EXP,
	invln2 = 1.0 / M_LN2;

static
short Exp(double *x, short eoff)
{
	int neg = 0;

	if (*x < 0)
		*x = -*x, neg = 1;

	if (hugexp < *x)
		if (neg)
			return *x = zero, 0;
		else
			return *x = Inf.d, INF;
	else
	{
		 double g = *x * invln2;
		 short xexp = g + Half.d;

		 g = xexp;
		 g = (*x -g *ec1) - g * ec2;

		 if (-Rteps.d < g and g < Rteps.d)
		 	*x = one;
		 else
		 {
		 	const double y = g*g;

		 	g *= (pp[0] * y + pp[1]) * y + pp[2];
		 	*x = Half.d + g /(((pq[0] * y + pq[1])
		 	                        * y + pq[2])
		 	                        * y + pq[3] - g);
			++xexp;
		 }

		 if (neg)
		 	*x = one / *x, xexp = -xexp;

		 return Dscale(x, eoff + xexp);
	}
}

global
double exp(double x)
{
#if WITH_68881
{
	double y = __FGETEXP__ x;
	fprintf(dp, "fgetexp: %g\n", y);
}
#endif
	switch (Test(&x))
	{
	case NAN:	errno = EDOM;   return x;
	case INF:	errno = ERANGE; return Dsign(x) ? zero : Inf.d;
	case 0: return one;
	}

	if (0 <= Exp(&x, 0))
		errno = ERANGE;

	return x;
}

global
double cosh(double x)
{
#if WITH_68881
{
	double y = __FCOSH__ x;
	fprintf(dp, "fcosh: %g\n", y);
}
#endif
	switch (Test(&x))
	{
	case NAN:	errno = EDOM;   return x;
	case INF:	errno = ERANGE; return Inf.d;
	case 0: return one;
	}

	if (x < 0)
		x = -x;

	if (0 <= Exp(&x, -1))
		errno = ERANGE;
	elif (x < Xbig.d)
		x += 0.25 / x;

	return x;
}

static const double
shp[] =
{
	-0.78966127417357099479e+0,
	-0.16375798202630751372e+3,
	-0.11563521196851768270e+5,
	-0.35181283430177117881e+6
},
shq[] =
{
	 1.0,
	-0.27773523119650701667e+3,
	 0.36162723109421836460e+5,
	-0.21108770058106271242e+7
};

global
double sinh(double x)
{
	short neg = 0;

#if WITH_68881
{
	double y = __FSINH__ x;
	fprintf(dp, "fsinh: %g\n", y);
}
#endif
	switch (Test(&x))
	{
	case NAN:	errno = EDOM;   return x;
	case INF:	errno = ERANGE; return Dsign(x) ? -Inf.d : +Inf.d;
	case 0: return zero;
	}

	if (x < 0)
		x = -x, neg = 1;

	if (x < Rteps.d)
		;
	elif (x < one)
	{
		const double y = x * x;
		x += x * y
			   * (((shp[0] * y + shp[1]) * y + shp[2]) * y + shp[3])
			   / (((shq[0] * y + shq[1]) * y + shq[2]) * y + shq[3]);

	}
	elif (0 <= Exp(&x, -1))
		errno = ERANGE;
	elif (x < Xbig.d)
		x -= 0.25 / x;

	return neg ? -x : +x;
}

static const double
thp[] =
{
	-0.96437492777225469787e+0,
	-0.99225929672236083313e+2,
	-0.16134119023996228053e+4
},
thq[] =
{
	0.10000000000000000000e+1,
	0.11274474380534949335e+3,
	0.22337720718962312926e+4,
	0.48402357071988688686e+4
},
ln3by2 = 0.54930614433405484570;

global
double tanh(double x)
{
	short neg = 0;
#if WITH_68881
{
	double y = __FTANH__ x;
	fprintf(dp, "ftanh: %g\n", y);
}
#endif

	switch(Test(&x))
	{
	case NAN: errno = EDOM; return x;
	case INF: return Dsign(x) ? -one : +one;
	case 0:   return zero;
	}

	if (x < 0)
		x = -x, neg = 1;

	if (x < Rteps.d)
		;
	elif (x < ln3by2)
	{
		const double g = x * x;

		x += x * g
		       *  ((thp[0] * g + thp[1]) * g + thp[2])
		       / (((thq[0] * g + thq[1]) * g + thq[2]) * g + thq[3]);
	}
	elif (Exp(&x, 0) < 0)
		x = one - two/(x * x + one);
	else
		x = one;
	return neg ? -x : +x;
}

static const double
lp[] =
{
	-0.78956112887491257267e+0,
	 0.16383943563021534222e+2,
	-0.64124943423745581147e+2
},
lq[] =
{
	-0.35667977739034646171e+2,
	 0.31203222091924532844e+3,
	-0.76949932108494879777e+3
},
loge = M_LOG10E,
rthalf = M_SQRT_2;

global
double log(double x)	/* compute ln x */
{
	short xexp;
	double z, w;

	switch(Dunscale(&xexp, &x))
	{
	case NAN:         return errno = EDOM,   x;
	case INF:
		if (Dsign(x)) return errno = EDOM,   Nan.d;
	    else          return errno = ERANGE, Inf.d;
	case 0:           return errno = ERANGE, -Inf.d;
	}

	if (x < 0)
		return errno = EDOM, Nan.d;

	z = x - Half.d;

	if (rthalf < x)
	{
		z = (z - Half.d) / (x * Half.d + Half.d);
	}
	else
	{
		z /= (z * Half.d + Half.d), --xexp;
	}

	w  = z * z;

	z += z * w
	       * ((lp[0] * w + lp[1]) * w + lp[2])
	       / (((w + lq[0]) * w + lq[1]) * w + lq[2]);

	if (xexp)
	{
		double xn = xexp;
		z = (xn * ec2 + z) + xn * ec1;
	}

	return z;
}

global
double log10(double x)
{
#if WITH_68881
{
	double y = __FLOG10__ x;
	fprintf(dp, "flog10: %g\n", y);
}
#endif
	return loge * log(x);
}

double  __POW__( double x, double y );

global
double pow(double x, double y)
{
	double yi = y, yx, z, tx = x, ty = y;
	short n, xexp, zexp, neg = 0, errx = Dunscale(&xexp, &x);
	const short erry = Tint(&yi, 0);
	static const short shuge = HUGE_EXP;
	static const double
		dhuge  = (double)HUGE_EXP,
		ln2    = M_LN2,
		rthalf = M_SQRT_2;

#if WITH_68881
{
	double my = __POW__(tx,ty);
	fprintf(dp, "fpow: %g\n", my);
}
#endif

	if (0 <= errx or 0 < erry)
	{
		z = Nan.d;
		if (errx eq NAN or erry eq NAN)
			z = errx eq NAN ? x : y, errx = NAN;
		elif (erry eq INF)
			if (errx eq INF)
				errx = INF;
#if 1
			else
				errx =   xexp <= 0
				       ? (  Dsign(y)
				          ? INF
				          : 0
				         )
				       :   xexp eq 1 and (x eq Half.d or x eq -Half.d)
				         ? NAN
				         :   Dsign(y)
				           ? 0
				           : INF;
#else			/* wil niet werken */
			else
			{
				if (xexp <= 0)
					if (Dsign(y))
						errx = INF;
					else
					{
						errx = 0;
					}
				elif (xexp eq 1 and (x eq Half.d or x eq -Half.d))
					errx = NAN;
				else
					if (Dsign(y))
					{
						errx = 0;
					}
					else
						errx = INF;
			}
#endif
		elif (y eq 0)
			return one;


		if (errx eq INF)
		{
			if (y < 0)
			{
				errx = 0;
			}
			else
				errx =  INF;
			neg = Dsign(x) and erry eq 0 and Tint(&y, -1) < 0;
		}
		elif (y < 0)
			errx = INF;
		else
		{
			errx = 0;
		}

		if (errx eq 0)
		{
			return zero;
		}

		if (errx eq INF)
		{
			errno = ERANGE;
			return neg ? -Inf.d : Inf.d;
		othw
			errno = EDOM;
			return z;
		}
	}

	if (y eq 0)
		return one;

	if (0 < x)
		neg = 0;
	elif (erry < 0)
		return errno = EDOM, Nan.d;
	else
		x = -x, neg = Tint(&yi, -1) < 0;

#if 1
	yx = log(tx);
/*	fprintf(dp, "ln %g: %g\n", tx, yx); */
	yx *= ty;
	yi = yx;
	errx = Exp(&yx, 0);
/*	fprintf(dp, "e ^ %g = %g\n", yi, yx); */
	return neg ? -yx : +yx;
#else				/* wil niet werken */

fprintf(dp, "[0] x %g, y %g, yi %g\n", x, y, yi);
	if (x < rthalf)
		x *= two, --xexp;

	n = 0;
	yx = zero;

	if (y <= -dhuge)
		zexp = xexp < 0 ? shuge : xexp eq 0 ? 0 : -shuge;
	elif (dhuge <= y)
		zexp = xexp < 0 ? -shuge : xexp eq 0 ? 0 : shuge;
	else
	{
		double dexp = xexp;
		long z1;

fprintf(dp, "xexp %d yx %g y %g, dexp %g\n", xexp, yx, y, dexp);
		z1 = (long)(yx = y * dexp);

fprintf(dp, "-= 1 =- yx %g z1 %ld\n", yx, z1);
		if (z1)
		{
			yx = y, Tint(&yx, 16);
fprintf(dp, "-= 2 =- y %g yx %g dexp %g z1 %ld\n", y, yx, dexp, z1);
			yx = (yx * dexp - z1) + (y - yx) * dexp;
fprintf(dp, "-= 3 =- yx %g y %g\n", yx, y);
		}

		yx *= ln2;
		xexp = z1 <= -shuge ? -shuge : z1 < shuge ? z1 : shuge;
		n = y;
		if (n < -SAFE_EXP or SAFE_EXP < n)
		{
			n = 0;
fprintf(dp, "-= 4 =-\n");
		}
	}

	z = one;
	if (x ne one)
	{
		yi = y - n;
fprintf(dp, "-= 5 =- yi %g\n", yi);

		if (yi)
			yx += log(x) * yi;

		if (n < 0)
			n = -n;

fprintf(dp, "-= 6 =- yx %g\n", yx);
		for (yi = x; ; )
		{
			if (n & 1)
				z *= yi;
			if ((n >>= 1) eq 0)
				break;
			yi *= yi;
fprintf(dp, "-= 7 yi %g=-\n", yi);
		}

		if (y < 0)
			z = one / z;
fprintf(dp, "-= 9 =-\n");
	}

fprintf(dp, "[2] z %g, yx %g\n", z, yx);

	if (yx)
		if (Exp(&yx, 0) < 0)
		{
			z *= yx;
fprintf(dp, "-= 10 =-\n");
		}
		else
		{
			z = yx;
fprintf(dp, "-= 11 =-\n");
		}

fprintf(dp, "[3] z %g, yx %g\n", z, yx);
	if (0 <= Dscale(&z, zexp))
		errno = ERANGE;
fprintf(dp, "[4] z %g yx %g\n", z, yx);
	return neg ? -z : +z;
#endif
}

static const double
pows[] = { 1e1, 1e2, 1e4, 1e8, 1e16, 1e32, 1e64, 1e128, 1e256 };
#define npows 8

static short dmul(double *x, double y)
{
	short xexp;

	Dunscale(&xexp, x);
	*x *= y;
	return Dscale(x, xexp);
}

static
double Dtento(double x, short n)
{
	double fac = one;
	short errx;
	size_t i;

	if (n eq 0)
		return one;
	if (x eq 0)
		return x;

	if (n < 0)
	{
		unsigned int nu = -n;

		for (i = 0; 0 < nu and i < npows; nu >>= 1, ++i)
			if (nu & 1)
				fac *= pows[i];

		errx = dmul(&x, one / fac);

		if (errx < 0 and 0 < nu)
		{
			for (fac = one / pows[npows]; 0 < nu; --nu)
				if (0 <= (errx = dmul(&x, fac)))
					break;
		}
	othw
		for (i = 0; n > 0 and i < npows; n >>= 1, ++i)
			if (n & 1)
				fac *= pows[i];
		errx = dmul(&x, fac);
		if (errx < 0 and 0 < n)
		{
			for (fac = pows[npows]; 0 < n; --n)
				if (0 < (errx = dmul(&x, fac)))
					break;
		}
	}

	if (0 <= errx)
		errno = ERANGE;

	return x;
}

global
double pow10(int i)
{
#if WITH_68881
{
	double y = __FTENTOX__ (double)i;
	fprintf(dp, "ftentox: %g\n", y);
}
#endif
	return Dtento(1, i);
}

static
double hyper(double x, int i)
{
	return sqrt((x*x)+i)+x;
}

double acosh( double x )
{
	return log(hyper(x, -1));
}

double asinh( double x )
{
	return log(hyper(x, 1));
}

#endif	/* double != 8 */