/* Subroutines needed by GCC output code for the 68000/20. 

   Compile using -O flag with gcc. 
   Use the -m68000 flag if you have a 68000

   This package includes 32 bit integer and 64-bit floating
   point routines.

   WARNING: alpha-test version (July 1988) -- probably full of bugs.
   If you find a bug, send bugs reports to jsm@phoenix.princeton.edu,
   or

	   Scott McCauley
	   PPPL P. O. Box 451
	   Princeton NJ 08543

   Known bugs/features:

   1) Depending on the version of GCC, this may produce a lot of
      warnings about conversion clashes, etc. It should still compile
      as is. Also, there appears to be a bug in the register-allocation
      parts of gcc that makes the compiler sometimes core dump
      or run into an infinite loop. This version works -- if you
      decide to change routines these compiler bugs can bite very hard....

   2) all single-precision gets converted to double precision in the
      math routines (in accordance with K&R), so doing things in
      double precision is faster than single precision....

   3) double precision floating point division may not be accurate to
      the last four or so bits. Most other routines round to the
      lsb.

   4) no support of NaN and Inf

   5) beware of undefined operations: i.e. a float to integer conversion
      when the float is larger than MAXIINT.
     
*/

#include <stdio.h>
#include <math.h>


#include "config.h"

/* These definitions work for machines where an SF value is
   returned in the same register as an int.  */

#ifndef SFVALUE  
#define SFVALUE int
#endif

#ifndef INTIFY
#define INTIFY(FLOATVAL)  (intify.f = (FLOATVAL), intify.i)
#endif

union double_di { double d; int i[2]; };
union flt_or_int { int i; float f; };

#ifdef WORDS_BIG_ENDIAN
#define HIGH 0
#define LOW 1
#else
#define HIGH 1
#define LOW 0
#endif

/* start of symbolic asm definitions */

/* you may have to change the g's to d's if you start getting
   illegal operands from as */

#define MUL(a, b) asm("mulu %2,%0" : "=d" (b) : "0" (b) , "g" (a))
#define DIV(a, b) asm("divu %2,%0" : "=d" (b) : "0" (b) , "g" (a))
#define SWAP(a) asm("swap %0" : "=r" (a) : "r" (a) , "r" (a) )

#define ASL(r1, r2) { asm("asll #1,%0" : "=d" (r2) : "d" (r2));\
		      asm("roxll #1,%0" : "=d" (r1) : "d" (r1)); }
#define ASR(r1, r2) { asm("asrl #1,%0" : "=d" (r1) : "d" (r1));\
		      asm("roxrl #1,%0" : "=d" (r2) : "d" (r2)); }
#define ADD(r1, r2, r3, r4) \
	{ asm("addl %2,%0": "=g" (r4) : "0" (r4) , "g" (r2)); \
	  asm("addxl %2,%0": "=g" (r3) : "0" (r3) , "g" (r1)); }

#define NEG(r1, r2) { asm("negl %0" : "=d" (r2) : "d" (r2)); \
		      asm("negxl %0" : "=d" (r1) : "d" (r1)); } 
			
#define umultl _umulsi
#define multl _mulsi3
#define udivl _udivsi3 
#define divl _divsi3
#define ddiv _divdf3
#define qmult _qmult
#define dmult _muldf3
#define dneg _negdf2
#define dadd _adddf3
#define dcmp _cmpdf2
#define dtoul _fixunsdfsi
#define dtol _fixdfsi
#define ltod _floatsidf

/* quasi-IEEE floating point number definitions */

struct bitfloat {
	unsigned sign : 1;
	unsigned exp : 8;
	unsigned mant : 23;
} abfp;

struct bitdouble {
	unsigned sign : 1;
	unsigned exp : 11;
	unsigned mant1 : 20;
	unsigned long mant2;
};

#ifdef L_eprintf
#include <stdio.h>
/* This is used by the `assert' macro.  */
void
_eprintf (string, line)
     char *string;
     int line;
{
  fprintf (stderr, string, line);
}
#endif

#ifdef L_umulsi3

/*_umulsi3 (a, b) unsigned a, b; { return a * b; } */

unsigned long umultl(a,b)
unsigned long a, b;
{
	register unsigned long d7, d6, d5, d4;
	
	d7 = a;
	d6 = b;
	d5 = d6;
	d4 = d6;
	/* without the next line, gcc may core dump. Gcc sometimes
	   gets confused if you have too many registers */

	&a; &b;

	/*printf("a %u b %u\n", a, b);*/

	/* low word */
	MUL(d7, d6);
	SWAP(d5);
	MUL(d7, d5);
	SWAP(d7);
	MUL(d7, d4);
	d4 += d5;
	SWAP(d4);
	d4 &= 0xFFFF0000;
	d4 += d6;
	return(d4);
}
#endif

#ifdef L_mulsi3
/* _mulsi3 (a, b) int a, b; { return a * b; } */

long multl(a, b)
long a, b;
{
	int sign = 0;
	long umultl();
	if ((a ^ b) < 0) sign = 1;
	if (a < 0) a = -a;
	if (b < 0) b = -b;
	/*printf("a is %d b is %d\n", a, b);*/
	if (sign) return(- umultl(a,b));
	else return(umultl(a,b));
}

#endif

#ifdef L_udivsi3
/*_udivsi3 (a, b) unsigned a, b; { return a / b; } */

/*
 this routine based on one in the PD forth package for the sun by Mitch Bradley
*/

unsigned udivl(u, v)
register unsigned long u, v;
{
	register unsigned short um, ul, vm, vl;
	unsigned long ans;
	unsigned long u1, v1;
	long i;
	long rem;

	if (v == 0) {
		/* should cause an exception condition */
		DIV(u, v);
		fprintf(stderr, "division by zero\n");
	}
	if (v > u) return(0);

	ul = u; SWAP(u); um = u;
	vl = v; SWAP(v); vm = v;
	if (vm == 0) {
		u = vl; v = um;
		DIV(u, v);
		/* note -- if you delete the next line, gcc goes into
		   an infinite loop */
		if (vm) printf("result is %d\n", v);
		vm = v & 0xFFFF; /* dividend is in low word */
		v &= 0xFFFF0000; /* remainder is in high word */
		v += ul;
		DIV(vl, v);
		v &= 0xFFFF; /* dividend is in low word */
		u = vm;
		SWAP(u);
		return(v + u);
		/*ans = ((um / vl) << 16) + ((((um % vl) << 16) + ul) / vl);
		return(ans);*/
	}

	if (vl == 0) return(um / vm);
	SWAP(u); SWAP(v);
	if ( (u >> 3) < v) {
		for(i = 0; u >= v; i++, u -= v);
		/*printf("lt 8\n");*/
		return(i);
	}
	u1 = u; v1 = v;

	/* scale divisor */
	v1--;
	for(i = 0; ((unsigned) v1) >= 0xFFFF; v1 >>= 1, i++);
	if (++v1 > 0xFFFF) {
		i++; v1 >>=1;
	}
	u1 >>= i;
	/*printf("i is %d, u1 is %x, v1 is %x\n", i, u1, v1);*/
	ans = u1 / v1;
	rem = u - (ans * v);
	if (rem > v) {ans++; rem -= v; }
	if (rem > v) {printf("oops\n");}
	return(ans);
}
#endif

#ifdef L_divsi3

long divl(a, b)
long a, b;
{
	int sign = 0;
	if ((a ^ b) < 0) sign = 1;
	if (a < 0) a = -a;
	if (b < 0) b = -b;
	if (sign) return(-udivl(a,b));
	else return(udivl(a,b));
}
#endif

#ifdef L_umodsi3
_umodsi3 (a, b)
     unsigned a, b;
{
  /*return a % b;*/
  return (a - ((a/b)*b));
}
#endif

#ifdef L_modsi3
_modsi3 (a, b)
     int a, b;
{
  /*return a % b;*/
  return( a - ((a/b) * b));
}
#endif

#ifdef L_lshrsi3
_lshrsi3 (a, b)
     unsigned a, b;
{
  return a >> b;
}
#endif

#ifdef L_lshlsi3
_lshlsi3 (a, b)
     unsigned a, b;
{
  return a << b;
}
#endif

#ifdef L_ashrsi3
_ashrsi3 (a, b)
     int a, b;
{
  return a >> b;
}
#endif

#ifdef L_ashlsi3
_ashlsi3 (a, b)
     int a, b;
{
  return a << b;
}
#endif

#ifdef L_divdf3

/*double _divdf3 (a, b) double a, b; { return a / b; } */

double drecip1(f1)
double f1;
{
	struct bitdouble *bdp = &f1;
	unsigned m1, m2;
	if (bdp->exp == 0 ) return(0L);
	if (bdp->mant1 == 0L) {
		bdp->exp = 0x3ff + 0x3ff - bdp->exp;
		bdp->mant2 = 0L;
		return(f1);
	}
	bdp->exp = 0x3ff + 0x3ff - bdp->exp - 1;
	m1 = (0x00100000 + bdp->mant1) >> 5;
	m2 = (0x80000000 / m1);
	/*printf("m1 %x m2 %x\n", m1, m2);*/
	m2 <<= 5;
	m2 &= 0xFFFFF;
	/*printf("exp %x mant %x\n", bdp->exp, m2);*/
	bdp->mant1 = m2;
	bdp->mant2 = 0L;
	return(f1);
}

double drecip(f)
double f;
{
	struct bitdouble *bdp;
	double quotient, remainder;
	quotient = drecip1(f);
	remainder = 1.0 - quotient * f;
	bdp = &remainder;
	for(; bdp->exp > 0x3ca; ) {
		remainder = 1.0 - (quotient*f);
		quotient = quotient + (drecip1(f)*remainder);
	}
	return(quotient);
}


double ddiv(f1, f2)
double f1, f2;
{
	return(f1 * drecip(f2));
}
#endif

#ifdef L_muldf3
/*double _muldf3 (a, b) double a, b; { return a * b; } */
qmult(m11, m12, m21, m22, p1, p2)
unsigned long m11, m12, m21, m22, *p1, *p2;
{
	register long d2 = m11;
	register unsigned long d3 = m12, d4 = m21, d5 = m22, d6 =0, d7 = 0;
	int i;
	/* guess what happens if you delete the next line.... */
	&i;
	for (i = 0; i < 11; i++) ASL(d2, d3);
	for (i = 0; i < 9; i++) ASL(d4, d5)
	
	for (i = 0; i < 64; i++) {
		if (d2 < 0) { ADD(d4, d5, d6, d7);}
		ASL(d2, d3);
		ASR(d4, d5);
	}
	d2 = d6;
	d3 = d7;
	for (i = 0; i < 9; i++) ASR(d2, d3);
	*p1 = d2; *p2 = d3;
}

double dmult(f1, f2)
double f1, f2;
{
	register long d2;
	register unsigned d3, d4, d5, d6, d7;
	unsigned long p1, p2;

	struct bitdouble *bdp1 = &f1, *bdp2 = &f2;
	int exp1, exp2, i;

	exp1 = bdp1->exp; exp2 = bdp2->exp;
	/* check for zero */
	if (! exp1) return(0.0);
	if (! exp2) return(0.0);
	d2 = 0x00100000 + bdp1->mant1;
	d3 = bdp1->mant2;
	d4 = 0x00100000 + bdp2->mant1;
	d5 = bdp2->mant2;
	qmult(d2, d3, d4, d5, &p1, &p2);
	d6 = p1; d7 = p2;

	if (d6 & 0x00200000) {
		ASR(d6, d7);
		exp1++;
	}

	if (bdp1->sign == bdp2->sign) bdp1->sign = 0;
	else bdp1->sign = 1;
	bdp1->exp = exp1 + exp2 - 0x3ff;
	bdp1->mant1 = d6;
	bdp1->mant2 = d7;
	return(f1);
}
#endif

#ifdef L_negdf2
/*double _negdf2 (a) double a; { return -a; } */

double dneg(num)
double num;
{
	long *i = &num;
	*i ^= 0x80000000;
	return(num);
}
#endif

#ifdef L_adddf3
/*double _adddf3 (a, b) double a, b; { return a + b; } */

double dadd(f1, f2)
double f1, f2;
{

	register long d4, d5, d6, d7;
	struct bitdouble *bdp1 = &f1, *bdp2 = &f2;
	int exp1, exp2, sign1, sign2, howmuch, temp;

	exp1 = bdp1->exp; exp2 = bdp2->exp;

	/* check for zero */
	if (! exp1) return(f2); if (! exp2) return(f1);

	/* align them */
	if (exp1 < exp2) {
		bdp1 = &f2; bdp2 = &f1;
		exp1 = bdp1->exp; exp2 = bdp2->exp;
	}
	howmuch = exp1 - exp2;
	if (howmuch > 53) return(f1);

	d7 = bdp2->mant1 + 0x00100000;
	d6 = bdp2->mant2;

	d5 = bdp1->mant1 + 0x00100000;
	d4 = bdp1->mant2;

	for (temp = 0; temp < howmuch; temp++) ASR(d7, d6);

	/* take care of negative signs */
	if (bdp1->sign) NEG(d5, d4);
	if (bdp2->sign) NEG(d7, d6);

	ADD(d7, d6, d5, d4);

	bdp1 = &f1;

	if (d5 < 0) {
		NEG(d5, d4);
		bdp1->sign = 1;
	} else bdp1->sign = 0;

	if (d5 == 0 && d4 == 0) return(0.0);

	for(howmuch = 0; d5 >= 0; howmuch++) ASL(d5, d4);

	ASL(d5, d4);
	for (temp = 0; temp < 12; temp++) ASR(d5, d4);
	bdp1->mant1 = d5;
	bdp1->mant2 = d4;
	bdp1->exp = exp1 + 11 - howmuch;
	return(f1); 
}

#endif

#ifdef L_subdf3
double
_subdf3 (a, b)
     double a, b;
{
  return a+(-b);
}
#endif

#ifdef L_cmpdf2 /*int _cmpdf2 (a, b) double a, b; { if (a > b) return 1;
  else if (a < b) return -1; return 0; } */

int dcmp(f1, f2)
double f1, f2;
{
	struct bitdouble *bdp1, *bdp2;
	unsigned int s1, s2;
	bdp1 = &f1;
	bdp2 = &f2;
	s1 = bdp1->sign;
	s2 = bdp2->sign;
	if (s1 > s2) return(-1);
	if (s1 < s2) return(1);
	/* if sign of both negative, switch them */
	if (s1 != 0) {
		bdp1 = &f1;
		bdp2 = &f2;
	}
	s1 = bdp1->exp;
	s2 = bdp2->exp;
	if (s1 > s2) return(1);
	if (s1 < s2) return(-1);
	/* same exponent -- have to compare mantissa */
	s1 = bdp1->mant1;
	s2 = bdp2->mant1;
	if (s1 > s2) return(1);
	if (s1 < s2) return(-1);
	s1 = bdp1->mant2;
	s2 = bdp2->mant2;
	if (s1 > s2) return(1);
	if (s1 < s2) return(-1);
	return(0); /* the same! */
}
#endif

#ifdef L_fixunsdfsi
/*_fixunsdfsi (a) double a; { return (unsigned int) a; } */

/* #ifdef L_fixdfsi _fixdfsi (a) double a; { return (int) a; } #endif */

unsigned long dtoul(f)
double f;
{
	struct bitdouble *bdp;
	int si, ex, mant1, mant2;
	bdp = &f;
	si = bdp->sign;
	ex = bdp->exp;
	mant1 = bdp->mant1 + 0x00100000;
	mant2 = bdp->mant2;

	/* zero value */
	if (ex == 0) return(0L);
	/* less than 1 */
	if (ex < 0x3ff) return(0L);
	/* less than 0 */
	if (si ) return(0L);
	mant1 <<= 10;
	mant1 += (mant2 >> 22);
	mant1 >>= 30 + (0x3ff - ex);
	return(mant1);
}

long dtol(f)
double f;
{
	struct bitdouble *bdp = &f;

	if (bdp->sign) {
		bdp->sign = 0;
		return( - dtoul(f));
	}
	return(dtoul(f));
}
#endif

#ifdef L_fixunsdfdi

/*double _fixunsdfdi (a) double a; { union double_di u;
  u.i[LOW] = (unsigned int) a; u.i[HIGH] = 0; return u.d; } */
#endif


#ifdef L_fixdfdi
double
_fixdfdi (a)
     double a;
{
  union double_di u;
  u.i[LOW] = (int) a;
  u.i[HIGH] = (int) a < 0 ? -1 : 0;
  return u.d;
}
#endif

#ifdef L_floatsidf
/* double _floatsidf (a) int a; { return (double) a; } */

double ltod(i)
long i;
{
	int expo, shift;
	double retval;
	struct bitdouble *bdp = &retval;
	if (i == 0) {
		long *t = &retval;
		t[0] = 0L;
		t[1] = 0L;
		return(retval);
	}
	if (i < 0) {
		bdp->sign = 1;
		i = -i;
	} else bdp->sign = 0;
	shift = i;
	for (expo = 0x3ff + 31 ; shift > 0; expo--, shift <<= 1);
	shift <<= 1;
	bdp->exp = expo;
	bdp->mant1 = shift >> 12;
	bdp->mant2 = shift << 20;
	return(retval);
}

#endif

#ifdef L_floatdidf
/* ok as is -- will call other routines */
double
_floatdidf (u)
     union double_di u;
{
  register double hi
    = ((double) u.i[HIGH]) * (double) 0x10000 * (double) 0x10000;
  register double low = (unsigned int) u.i[LOW];
  return hi + low;
}
#endif

#ifdef L_addsf3
SFVALUE
_addsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify; return INTIFY ((double) a.f + (double) b.f);
}
#endif

#ifdef L_negsf2
SFVALUE
_negsf2 (a)
     union flt_or_int a;
{
  union flt_or_int intify;
  return INTIFY (-((double) a.f));
}
#endif

#ifdef L_subsf3
SFVALUE
_subsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  return INTIFY (((double) a.f - (double) b.f));
}
#endif

#ifdef L_cmpsf2
SFVALUE
_cmpsf2 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  double a1, b1;
  a1 = a.f; b1 = b.f;
  if ( a1 > b1)
    return 1;
  else if (a1 < b1)
    return -1;
  return 0;
}
#endif

#ifdef L_mulsf3
SFVALUE
_mulsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  return INTIFY (((double) a.f * (double) b.f));
}
#endif

#ifdef L_divsf3
SFVALUE
_divsf3 (a, b)
     union flt_or_int a, b;
{
  union flt_or_int intify;
  return INTIFY (((double) a.f / (double) b.f));
}
#endif

#ifdef L_truncdfsf2
float dtof(d)
double d;
{
	struct bitdouble *bdp = &d;
	float retval;
	struct bitfloat *bfp = &retval;
	int tempval;

	bfp->sign = bdp->sign;
	if (bdp->exp == 0) return ((float) 0.0);
	bfp->exp = bdp->exp - 0x400 + 0x80;
	tempval = (bdp->mant1 << 4 ) + ((0xF0000000 & bdp->mant2) >> 28);
	/* round */
	tempval++;
	if (tempval == 0x01000000) bfp->exp++;
	bfp->mant = tempval >> 1;
	printf("d is %f, tempval is %x\n",d, tempval);
	printf("exp is %d\n", bfp->exp);
	return(retval);
}

SFVALUE
_truncdfsf2 (a)
     double a;
{
  union flt_or_int intify;
  return INTIFY (dtof(a));
}
#endif

#ifdef L_extendsfdf2
double ftod(f)
union flt_or_int f;
{
	double retval;
	struct bitfloat *bfp = &f.f;
	struct bitdouble *bdp = &retval;
	if (bfp->exp == 0) return(0.0);
	bdp->sign = bfp->sign;
	bdp->exp = 0x400 - 0x80 + bfp->exp;
	bdp->mant1 = bfp->mant >> 3;
	bdp->mant2 = (bfp->mant & 0x7) << 29;
	/*printf("returning %f from extendsfdf2\n", retval);*/
	return(retval);
}

double
_extendsfdf2 (a)
     union flt_or_int a;
{
  union flt_or_int intify;
  double retval;
  return (ftod(a));
}
#endif



