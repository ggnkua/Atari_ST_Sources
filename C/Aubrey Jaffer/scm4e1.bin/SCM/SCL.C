/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992, 1993 Aubrey Jaffer.

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

The author can be reached at jaffer@ai.mit.edu or
Aubrey Jaffer, 84 Pleasant St., Wakefield MA 01880
*/

#include "scm.h"

#ifdef FLOATS
# include <math.h>

static char s_makrect[] = "make-rectangular", s_makpolar[] = "make-polar",
	    s_magnitude[] = "magnitude", s_angle[] = "angle",
	    s_real_part[] = "real-part", s_imag_part[] = "imag-part",
	    s_in2ex[] = "inexact->exact";
static char s_expt[] = "$expt", s_atan2[] = "$atan2";
static char s_memv[] = "memv",s_assv[] = "assv";
#endif

SCM sys_protects[NUM_PROTECTS];
sizet num_protects = NUM_PROTECTS;

char		s_inexactp[] = "inexact?";
static char     s_zerop[] = "zero?",
		s_positivep[] = "positive?", s_negativep[] = "negative?";
static char     s_eqp[] = "=", s_lessp[] = "<", s_grp[] = ">";
static char     s_leqp[] = "<=", s_greqp[] = ">=";
static char     s_max[] = "max", s_min[] = "min";
char		s_sum[] = "+", s_difference[] = "-", s_product[] = "*",
		s_divide[] = "/";
static char     s_number2string[] = "number->string",
		s_str2number[] = "string->number";

static char s_list_tail[] = "list-tail";
static char s_str2list[] = "string->list";
static char s_st_copy[] = "string-copy", s_st_fill[] = "string-fill!";
static char s_vect2list[] = "vector->list", s_ve_fill[] = "vector-fill!";

/*** NUMBERS -> STRINGS ***/
#ifdef FLOATS
int dblprec;
static double fx[] = {0.0, 5e-1, 5e-2, 5e-3, 5e-4, 5e-5,
			   5e-6, 5e-7, 5e-8, 5e-9, 5e-10,
			   5e-11,5e-12,5e-13,5e-14,5e-15,
			   5e-16,5e-17,5e-18,5e-19,5e-20};

static sizet idbl2str(f,a)
double f;
char *a;
{
  int efmt, dpt, d, i, wp = dblprec;
  sizet ch = 0;
  int exp = 0;

  if (f == 0.0) goto zero;	/*{a[0]='0'; a[1]='.'; a[2]='0'; return 3;}*/
  if (f < 0.0) {f = -f;a[ch++]='-';}
  else if (f > 0.0) ;
  else goto funny;
  if IS_INF(f) {
    if (ch == 0) a[ch++]='+';
  funny: a[ch++]='#'; a[ch++]='.'; a[ch++]='#'; return ch;
  }
#ifdef FLT_MIN_10_EXP		/* Prevent unnormalized values, as from 
			make-uniform-vector, from causing infinite loops. */
  while (f < 1.0) {f *= 10.0;  if (exp-- < FLT_MIN_10_EXP) goto funny;}
  while (f > 10.0) {f *= 0.10; if (exp++ > FLT_MAX_10_EXP) goto funny;}
#else
  while (f < 1.0) {f *= 10.0; exp--;}
  while (f > 10.0) {f /= 10.0; exp++;}
#endif
  if (f+fx[wp] >= 10.0) {f = 1.0; exp++;}
 zero:
#ifdef ENGNOT
  dpt = (exp+9999)%3;
  exp -= dpt++;
  efmt = 1;
#else
  efmt = (exp < -3) || (exp > wp+2);
  if (!efmt)
    if (exp < 0) {
      a[ch++] = '0';
      a[ch++] = '.';
      dpt = exp;
      while (++dpt)  a[ch++] = '0';
    } else
      dpt = exp+1;
  else
    dpt = 1;
#endif

  do {
    d = f;
    f -= d;
    a[ch++] = d+'0';
    if (f < fx[wp])  break;
    if (f+fx[wp] >= 1.0) {
      a[ch-1]++;
      break;
    }
    f *= 10.0;
    if (!(--dpt))  a[ch++] = '.';
  } while (wp--);

  if (dpt > 0)
#ifndef ENGNOT
    if ((dpt > 4) && (exp > 6)) {
      d = (a[0]=='-'?2:1);
      for (i = ch++; i > d; i--)
	a[i] = a[i-1];
      a[d] = '.';
      efmt = 1;
    } else
#endif
      {
	while (--dpt)  a[ch++] = '0';
	a[ch++] = '.';
      }
  if (a[ch-1]=='.')  a[ch++]='0'; /* trailing zero */
  if (efmt && exp) {
    a[ch++] = 'e';
    if (exp < 0) {
      exp = -exp;
      a[ch++] = '-';
    }
    for (i = 10; i <= exp; i *= 10);
    for (i /= 10; i; i /= 10) {
      a[ch++] = exp/i + '0';
      exp %= i;
    }
  }
  return ch;
}

static sizet iflo2str(flt,str)
     SCM flt;
     char *str;
{
  sizet i;
# ifdef SINGLES
  if SINGP(flt) i = idbl2str(FLO(flt),str);
  else
# endif
    i = idbl2str(REAL(flt),str);
  if CPLXP(flt) {
              if(0 <= IMAG(flt)) /* jeh */
                str[i++] = '+'; /* jeh */
    i += idbl2str(IMAG(flt),&str[i]);
    str[i++] = 'i';
  }
  return i;
}
#endif				/* FLOATS */

sizet iint2str(num,rad,p)
     long num;
     int rad;
     char *p;
{
  sizet j;
  register int i = 1,d;
  register long n = num;
  if (n < 0) {n = -n; i++;}
  for (n /= rad;n > 0;n /= rad) i++;
  j = i;
  n = num;
  if (n < 0) {n = -n; *p++ = '-'; i--;}
  while (i--) {
    d = n % rad;
    n /= rad;
    p[i] = d + ((d < 10) ? '0' : 'a' - 10);
  }
  return j;
}
#ifdef BIGDIG
static SCM big2str(b,radix)
     SCM b;
     register unsigned int radix;
{
  SCM t = copybig(b, 0);	/* sign of temp doesn't matter */
  register BIGDIG *ds = BDIGITS(t);
  sizet i = NUMDIGS(t);
  sizet j = radix==16 ? (BITSPERDIG*i)/4+2
    : radix >= 10 ? (BITSPERDIG*i*241L)/800+2
      : (BITSPERDIG*i)+2;
  sizet k = 0;
  sizet radct = 0;
      sizet ch; /* jeh */
  BIGDIG radpow = 1, radmod = 0;
  SCM ss = makstr((long)j);
  char *s = CHARS(ss), c;
  while ((long) radpow * radix < BIGRAD) {
    radpow *= radix;
    radct++;
  }
  s[0] = tc16_bigneg==TYP16(b) ? '-' : '+';
  while ((i || radmod) && j) {
    if (k == 0) {
      radmod = (BIGDIG)divbigdig(ds,i,radpow);
      k = radct;
      if (!ds[i-1]) i--;
    }
    c = radmod % radix; radmod /= radix; k--;
    s[--j] = c < 10 ? c + '0' : c + 'a' - 10;
  }
      ch = s[0] == '-' ? 1 : 0; /* jeh */
  if (ch < j) { /* jeh */
    for(i = j;j < LENGTH(ss);j++) s[ch+j-i] = s[j]; /* jeh */
    resizuve(ss,(SCM)MAKINUM(ch+LENGTH(ss)-i)); /* jeh */
  }
  return ss;
}
#endif
SCM number2string(x,radix)
SCM x,radix;
{
  if UNBNDP(radix) radix=MAKINUM(10L);
  else ASSERT(INUMP(radix),radix,ARG2,s_number2string);
#ifdef FLOATS
  if NINUMP(x) {
    char num_buf[FLOBUFLEN];
# ifdef BIGDIG
    ASRTGO(NIMP(x),badx);
    if BIGP(x) return big2str(x,(unsigned int)INUM(radix));
#  ifndef RECKLESS
    if (!(INEXP(x)))
    badx: wta(x,(char *)ARG1,s_number2string);
#  endif
# else
    ASSERT(NIMP(x) && INEXP(x),x,ARG1,s_number2string);
# endif
    return makfromstr(num_buf,iflo2str(x,num_buf));
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_number2string);
    return big2str(x,(unsigned int)INUM(radix));
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_number2string);
# endif
#endif
  {
    char num_buf[INTBUFLEN];
    return makfromstr(num_buf,iint2str(INUM(x),(int)INUM(radix),num_buf));
  }
}
/* These print routines are stubbed here so that repl.c doesn't need
   FLOATS or BIGDIGs conditionals */
int floprint(sexp,port,writing)
     SCM sexp;
     SCM port;
     int writing;
{
#ifdef FLOATS
  char num_buf[FLOBUFLEN];
  lfwrite(num_buf,(sizet)sizeof(char),iflo2str(sexp,num_buf),port);
#else
  ipruk("float",sexp,port);
#endif
  return !0;
}
int bigprint(exp,port,writing)
     SCM exp;
     SCM port;
     int writing;
{
#ifdef BIGDIG
  exp = big2str(exp,(unsigned int)10);
  lfwrite(CHARS(exp),(sizet)sizeof(char),(sizet)LENGTH(exp),port);
#else
  ipruk("bignum",exp,port);
#endif
  return !0;
}
/*** END nums->strs ***/

/*** STRINGS -> NUMBERS ***/
#ifdef BIGDIG
SCM istr2int(str,len,radix)
     char *str;
     long len;
     register long radix;
{
  sizet j;
  register sizet k, blen = 1;
  sizet i = 0;
  int c;
  SCM res;
  register BIGDIG *ds;
  register unsigned long t2;

  if (0 >= len) return BOOL_F;	/* zero length */
  if (16==radix) j = 1+(4*len*sizeof(char))/(BITSPERDIG);
  else if (10 <= radix)
    j = 1+(84*len*sizeof(char))/(BITSPERDIG*25);
  else j = 1+(len*sizeof(char))/(BITSPERDIG);
  switch (str[0]) {		/* leading sign */
  case '-':
  case '+': if (++i==len) return BOOL_F; /* bad if lone `+' or `-' */
  }
  res = mkbig(j, '-'==str[0]);
  ds = BDIGITS(res);
  for (k = j;k--;) ds[k] = 0;
  do {
    switch (c = str[i++]) {
    case DIGITS:
      c = c - '0';
      goto accumulate;
    case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
      c = c-'A'+10;
      goto accumulate;
    case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
      c = c-'a'+10;
    accumulate:
      if (c >= radix) return BOOL_F; /* bad digit for radix */
      k = 0;
      t2 = c;
    moretodo:
      while(k < blen) {
/*	printf("k = %d, blen = %d, t2 = %ld, ds[k] = %d\n",k,blen,t2,ds[k]);*/
	t2 += ds[k]*radix;
	ds[k++] = BIGLO(t2);
	t2 = BIGDN(t2);
      }
      ASSERT(blen <= j, (SCM)MAKINUM(blen), OVFLOW, "bignum");
      if (t2) {blen++; goto moretodo;}
      break;
    default:
      return BOOL_F;		/* not a digit */
    }
  } while (i < len);
  if (blen * BITSPERDIG/CHAR_BIT <= sizeof(SCM))
    if INUMP(res = big2long(res,blen)) return res;
  if (j==blen) return res;
  return adjbig(res,blen);
}
#else
SCM istr2int(str,len,radix)
register char *str;
long len;
register long radix;
{
  register long n = 0, ln;
  register int c;
  register int i = 0;
  int lead_neg = 0;
  if (0 >= len) return BOOL_F;	/* zero length */
  switch (*str) {		/* leading sign */
  case '-': lead_neg = 1;
  case '+': if (++i==len) return BOOL_F; /* bad if lone `+' or `-' */
  }

  do {
    switch (c = str[i++]) {
    case DIGITS:
      c = c - '0';
      goto accumulate;
    case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
      c = c-'A'+10;
      goto accumulate;
    case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
      c = c-'a'+10;
    accumulate:
      if (c >= radix) return BOOL_F; /* bad digit for radix */
      ln = n;
      n = n * radix - c;
      /* Negation is a workaround for HP700 cc bug */
      if (n > ln || (-n > -MOST_NEGATIVE_FIXNUM)) goto ovfl;
      break;
    default:
      return BOOL_F;		/* not a digit */
    }
  } while (i < len);
  if (!lead_neg) if ((n = -n) > MOST_POSITIVE_FIXNUM) goto ovfl;
  return MAKINUM(n);
 ovfl:				/* overflow scheme integer */
  return BOOL_F;
}
#endif

#ifdef FLOATS
SCM istr2flo(str,len,radix)
register char *str;
register long len;
register long radix;
{
  register int c, i = 0;
  double lead_sgn;
  double res = 0.0, tmp = 0.0;
  int flg = 0;
  int point = 0;
  SCM second;

  if (i >= len) return BOOL_F;	/* zero length */

  switch (*str) {		/* leading sign */
  case '-': lead_sgn = -1.0; i++; break;
  case '+': lead_sgn = 1.0; i++; break;
    default : lead_sgn = 0.0;
  }
  if (i==len) return BOOL_F;	/* bad if lone `+' or `-' */

  if (str[i]=='i' || str[i]=='I') { /* handle `+i' and `-i'   */
    if (lead_sgn==0.0) return BOOL_F; /* must have leading sign */
    if (++i < len) return BOOL_F; /* `i' not last character */
    return makdbl(0.0,lead_sgn);
  }
  do {				/* check initial digits */
    switch (c = str[i]) {
    case DIGITS:
      c = c - '0';
      goto accum1;
    case 'D': case 'E': case 'F':
      if (radix==10) goto out1; /* must be exponent */
    case 'A': case 'B': case 'C':
      c = c-'A'+10;
      goto accum1;
    case 'd': case 'e': case 'f':
      if (radix==10) goto out1;
    case 'a': case 'b': case 'c':
      c = c-'a'+10;
    accum1:
      if (c >= radix) return BOOL_F; /* bad digit for radix */
      res = res * radix + c;
      flg = 1;			/* res is valid */
      break;
    default:
      goto out1;
    }
  } while (++i < len);
 out1:

  /* if true, then we did see a digit above, and res is valid */
  if (i==len) goto done;

  /* By here, must have seen a digit,
     or must have next char be a `.' with radix==10 */
  if (!flg)
    if (!(str[i]=='.' && radix==10))
      return BOOL_F;

  while (str[i]=='#') {		/* optional sharps */
    res *= radix;
    if (++i==len) goto done;
  }

  if (str[i]=='/') {
    while (++i < len) {
      switch (c = str[i]) {
      case DIGITS:
	c = c - '0';
	goto accum2;
      case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
	c = c-'A'+10;
	goto accum2;
      case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
	c = c-'a'+10;
      accum2:
	if (c >= radix) return BOOL_F;
	tmp = tmp * radix + c;
	break;
      default:
	goto out2;
      }
    }
  out2:
    if (tmp==0.0) return BOOL_F; /* `slash zero' not allowed */
    if (i < len)
      while (str[i]=='#') {	/* optional sharps */
	tmp *= radix;
	if (++i==len) break;
      }
    res /= tmp;
    goto done;
  }

  if (str[i]=='.') {		/* decimal point notation */
    if (radix != 10) return BOOL_F; /* must be radix 10 */
    while (++i < len) {
      switch (c = str[i]) {
      case DIGITS:
	point--;
	res = res*10.0 + c-'0';
	flg = 1;
	break;
      default:
	goto out3;
      }
    }
  out3:
    if (!flg) return BOOL_F;	/* no digits before or after decimal point */
    if (i==len) goto adjust;
    while (str[i]=='#') {	/* ignore remaining sharps */
      if (++i==len) goto adjust;
    }
  }

  switch (str[i]) {		/* exponent */
  case 'd': case 'D':
  case 'e': case 'E':
  case 'f': case 'F':
  case 'l': case 'L':
  case 's': case 'S': {
    int expsgn = 1, expon = 0;
    if (radix != 10) return BOOL_F; /* only in radix 10 */
    if (++i==len) return BOOL_F; /* bad exponent */
    switch (str[i]) {
    case '-':  expsgn=(-1);
    case '+':  if (++i==len) return BOOL_F; /* bad exponent */
    }
    if (str[i] < '0' || str[i] > '9') return BOOL_F; /* bad exponent */
    do {
      switch (c = str[i]) {
      case DIGITS:
	expon = expon*10 + c-'0';
	if (expon > MAXEXP)  return BOOL_F; /* exponent too large */
	break;
      default:
	goto out4;
      }
    } while (++i < len);
  out4:
    point += expsgn*expon;
  }
  }

 adjust:
  if (point >= 0)
    while (point--)  res *= 10.0;
  else
#ifdef _UNICOS
    while (point++)  res *= 0.1; 
#else
    while (point++)  res /= 10.0;
#endif

 done:
  /* at this point, we have a legitimate floating point result */
  if (lead_sgn==-1.0)  res = -res;
  if (i==len) return makdbl(res,0.0);

  if (str[i]=='i' || str[i]=='I') { /* pure imaginary number  */
    if (lead_sgn==0.0) return BOOL_F; /* must have leading sign */
    if (++i < len) return BOOL_F; /* `i' not last character */
    return makdbl(0.0,res);
  }

  switch (str[i++]) {
  case '-':  lead_sgn = -1.0; break;
  case '+':  lead_sgn = 1.0;  break;
  case '@': {			/* polar input for complex number */
    /* get a `real' for angle */
    second = istr2flo(&str[i],(long)(len-i),radix);
    if (!(INEXP(second))) return BOOL_F; /* not `real' */
    if (CPLXP(second))    return BOOL_F; /* not `real' */
    tmp = REALPART(second);
    return makdbl(res*cos(tmp),res*sin(tmp));
  }
  default: return BOOL_F;
  }

  /* at this point, last char must be `i' */
  if (str[len-1] != 'i' && str[len-1] != 'I') return BOOL_F;
  /* handles `x+i' and `x-i' */
  if (i==(len-1))  return makdbl(res,lead_sgn);
  /* get a `ureal' for complex part */
  second = istr2flo(&str[i],(long)((len-i)-1),radix);
  if (!(INEXP(second))) return BOOL_F; /* not `ureal' */
  if (CPLXP(second))    return BOOL_F; /* not `ureal' */
  tmp = REALPART(second);
  if (tmp < 0.0)	return BOOL_F; /* not `ureal' */
  return makdbl(res,(lead_sgn*tmp));
}
#endif				/* FLOATS */


SCM istring2number(str,len,radix)
char *str;
long len;
long radix;
{
  int i = 0;
  char ex = 0;
  char ex_p = 0,rx_p = 0;	/* Only allow 1 exactness and 1 radix prefix */
  SCM res;
  if (len==1)
    if (*str=='+' || *str=='-') /* Catches lone `+' and `-' for speed */
      return BOOL_F;

  while ((len-i) >= 2  &&  str[i]=='#' && ++i)
    switch (str[i++]) {
    case 'b': case 'B':  if (rx_p++) return BOOL_F; radix = 2;  break;
    case 'o': case 'O':  if (rx_p++) return BOOL_F; radix = 8;  break;
    case 'd': case 'D':  if (rx_p++) return BOOL_F; radix = 10; break;
    case 'x': case 'X':  if (rx_p++) return BOOL_F; radix = 16; break;
    case 'i': case 'I':  if (ex_p++) return BOOL_F; ex = 2;     break;
    case 'e': case 'E':  if (ex_p++) return BOOL_F; ex = 1;     break;
    default:  return BOOL_F;
    }

  switch (ex) {
  case 1:
    return istr2int(&str[i],len-i,radix);
  case 0:
    res = istr2int(&str[i],len-i,radix);
    if NFALSEP(res) return res;
#ifdef FLOATS
  case 2: return istr2flo(&str[i],len-i,radix);
#endif
  }
  return BOOL_F;
}


SCM string2number(str,radix)
SCM str,radix;
{
  if UNBNDP(radix) radix=MAKINUM(10L);
  else ASSERT(INUMP(radix),radix,ARG2,s_str2number);
  ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_str2number);
  return istring2number(CHARS(str),LENGTH(str),INUM(radix));
}
/*** END strs->nums ***/

#ifdef FLOATS
SCM makdbl (x,y)
double x,y;
{
  SCM z;
  if ((y==0.0) && (x==0.0)) return flo0;
  NEWCELL(z);
  DEFER_INTS;
  if (y==0.0) {
# ifdef SINGLES
    float fx = x;
#ifndef SINGLESONLY
    if ((-FLTMAX < x) && (x < FLTMAX) && (fx==x))
#endif
      {
	CAR(z) = tc_flo;
	FLO(z) = x;
	ALLOW_INTS;
	return z;
      }
# endif				/* def SINGLES */
    CDR(z) = (SCM)must_malloc(1L*sizeof(double),"real");
    CAR(z) = tc_dblr;
  }
  else {
    CDR(z) = (SCM)must_malloc(2L*sizeof(double),"complex");
    CAR(z) = tc_dblc;
    IMAG(z) = y;
  }
  REAL(z) = x;
  ALLOW_INTS;
  return z;
}

SCM eqv(x,y)
SCM x,y;
{
  if (x==y) return BOOL_T;
  if IMP(x) return BOOL_F;
  if IMP(y) return BOOL_F;
  /* this ensures that types and length are the same. */
  if (CAR(x) != CAR(y)) return BOOL_F;
  if NUMP(x) {
#ifdef BIGDIG
    if BIGP(x) return (0==bigcomp(x,y)) ? BOOL_T : BOOL_F;
#endif
    if (REALPART(x) != REALPART(y)) return BOOL_F;
    if (CPLXP(x) && (IMAG(x) != IMAG(y))) return BOOL_F;
    return BOOL_T;
  }
  return BOOL_F;
}
SCM memv(x,lst)			/* m.borza  12.2.91 */
SCM x,lst;
{
  for(;NIMP(lst);lst = CDR(lst)) {
    ASRTGO(CONSP(lst),badlst);
    if NFALSEP(eqv(CAR(lst),x)) return lst;
  }
#ifndef RECKLESS
  if (!(NULLP(lst)))
    badlst: wta(lst,(char *)ARG2,s_memv);
#endif
  return BOOL_F;
}
SCM assv(x,alist)		/* m.borza  12.2.91 */
SCM x,alist;
{
  SCM tmp;
  for(;NIMP(alist);alist = CDR(alist)) {
    ASRTGO(CONSP(alist),badlst);
    tmp = CAR(alist);
    ASRTGO(NIMP(tmp) && CONSP(tmp),badlst);
    if NFALSEP(eqv(CAR(tmp),x)) return tmp;
  }
#ifndef RECKLESS
  if (!(NULLP(alist)))
    badlst: wta(alist,(char *)ARG2,s_assv);
#endif
  return BOOL_F;
}
#endif				/* FLOATS */

SCM list_tail(lst,k)
SCM lst, k;
{
  register long i;
  ASSERT(INUMP(k),k,ARG2,s_list_tail);
  i = INUM(k);
  while (i-- > 0) {
    ASSERT(NIMP(lst) && CONSP(lst),lst,ARG1,s_list_tail);
    lst = CDR(lst);
  }
  return lst;
}

SCM string2list(str)
SCM str;
{
  long i;
  SCM res = EOL;
  unsigned char *src;
  ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_str2list);
  src = UCHARS(str);
  for(i = LENGTH(str)-1;i >= 0;i--) res = cons((SCM)MAKICHR(src[i]),res);
  return res;
}
SCM string_copy(str)
SCM str;
{
  ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_st_copy);
  return makfromstr(CHARS(str),(sizet)LENGTH(str));
}
SCM string_fill(str,chr)
SCM str,chr;
{
  register char *dst,c;
  register long k;
  ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_st_fill);
  ASSERT(ICHRP(chr),chr,ARG2,s_st_fill);
  c = ICHR(chr);
  dst = CHARS(str);
  for(k = LENGTH(str)-1;k >= 0;k--) dst[k] = c;
  return UNSPECIFIED;
}
SCM vector2list(v)
SCM v;
{
  SCM res = EOL;
  long i;
  SCM *data;
  ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_vect2list);
  data = VELTS(v);
  for(i = LENGTH(v)-1;i >= 0;i--) res = cons(data[i],res);
  return res;
}
SCM vector_fill(v,fill)
SCM v,fill;
{
  register long i;
  register SCM *data;
  ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_ve_fill);
  data = VELTS(v);
  for(i = LENGTH(v)-1;i >= 0;i--) data[i] = fill;
  return UNSPECIFIED;
}
static SCM vector_equal(x,y)
     SCM x,y;
{
  long i;
  for(i = LENGTH(x)-1;i >= 0;i--)
    if FALSEP(equal(VELTS(x)[i],VELTS(y)[i])) return BOOL_F;
  return BOOL_T;
}
SCM bigequal(x,y)
     SCM x,y;
{
#ifdef BIGDIG
  if (0==bigcomp(x,y)) return BOOL_T;
#endif
  return BOOL_F;
}
SCM floequal(x,y)
     SCM x,y;
{
#ifdef FLOATS
  if (REALPART(x) != REALPART(y)) return BOOL_F;
  if (!(CPLXP(x) && (IMAG(x) != IMAG(y)))) return BOOL_T;
#endif
  return BOOL_F;
}
SCM equal(x,y)
     SCM x,y;
{
  CHECK_STACK;
 tailrecurse: POLL;
	if (x==y) return BOOL_T;
	if IMP(x) return BOOL_F;
	if IMP(y) return BOOL_F;
	if (CONSP(x) && CONSP(y)) {
		if FALSEP(equal(CAR(x),CAR(y))) return BOOL_F;
		x = CDR(x);
		y = CDR(y);
		goto tailrecurse;
	}
	/* this ensures that types and length are the same. */
	if (CAR(x) != CAR(y)) return BOOL_F;
	switch (TYP7(x)) {
        default: return BOOL_F;
	case tc7_string: return st_equal(x,y);
	case tc7_vector: return vector_equal(x,y);
	case tc7_smob: {
	        int i = SMOBNUM(x);
	        if (!(i < numsmob)) return BOOL_F;
	        if (smobs[i].equalp) return (smobs[i].equalp)(x, y);
	      }
	case tc7_bvect: case tc7_uvect: case tc7_ivect:
	case tc7_fvect:	case tc7_cvect: case tc7_dvect:
		return array_equal(x,y);
	}
	return BOOL_F;
}

SCM numberp(x)
SCM x;
{
  if INUMP(x) return BOOL_T;
#ifdef FLOATS
  if (NIMP(x) && NUMP(x)) return BOOL_T;
#else
# ifdef BIGDIG
  if (NIMP(x) && NUMP(x)) return BOOL_T;
# endif
#endif
  return BOOL_F;
}
#ifdef FLOATS
SCM realp(x)
     SCM x;
{
  if INUMP(x) return BOOL_T;
  if IMP(x) return BOOL_F;
  if REALP(x) return BOOL_T;
#ifdef BIGDIG
  if BIGP(x) return BOOL_T;
#endif
  return BOOL_F;
}
SCM intp(x)
     SCM x;
{
  double r;
  if INUMP(x) return BOOL_T;
  if IMP(x) return BOOL_F;
#ifdef BIGDIG
  if BIGP(x) return BOOL_T;
#endif
  if (!INEXP(x)) return BOOL_F;
  if CPLXP(x) return BOOL_F;
  r = REALPART(x);
  if (r==floor(r)) return BOOL_T;
  return BOOL_F;
}
#endif				/* FLOATS */

SCM inexactp(x)
SCM x;
{
#ifdef FLOATS
  if (NIMP(x) && INEXP(x)) return BOOL_T;
#endif
  return BOOL_F;
}
SCM eqp(x,y)
     SCM x,y;
{
#ifdef FLOATS
  SCM t;
  if NINUMP(x) {
# ifdef BIGDIG
#  ifndef RECKLESS
    if (!(NIMP(x)))
    badx: wta(x,(char *)ARG1,s_eqp);
#  endif
    if BIGP(x) {
      if INUMP(y) return BOOL_F;
      ASRTGO(NIMP(y),bady);
      if BIGP(y) return (0==bigcomp(x,y)) ? BOOL_T : BOOL_F;
      ASRTGO(INEXP(y),bady);
    bigreal:
      return (REALP(y) && (big2dbl(x)==REALPART(y))) ? BOOL_T : BOOL_F;
    }
    ASRTGO(INEXP(x),badx);
# else
    ASSERT(NIMP(x) && INEXP(x),x,ARG1,s_eqp);
# endif
    if INUMP(y) {t = x; x = y; y = t; goto realint;}
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) {t = x; x = y; y = t; goto bigreal;}
    ASRTGO(INEXP(y),bady);
# else
    ASRTGO(NIMP(y) && INEXP(y),bady);
# endif
    if (REALPART(x) != REALPART(y)) return BOOL_F;
    if CPLXP(x)
      return (CPLXP(y) && (IMAG(x)==IMAG(y))) ? BOOL_T : BOOL_F;
    return CPLXP(y) ? BOOL_F : BOOL_T;
  }
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return BOOL_F;
#  ifndef RECKLESS
    if (!(INEXP(y)))
    bady: wta(y,(char *)ARG2,s_eqp);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && INEXP(y)))
    bady: wta(y,(char *)ARG2,s_eqp);
#  endif
# endif
  realint:
    return (REALP(y) && (((double)INUM(x))==REALPART(y))) ? BOOL_T : BOOL_F;
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_eqp);
    if INUMP(y) return BOOL_F;
    ASRTGO(NIMP(y) && BIGP(y),bady);
    return (0==bigcomp(x,y)) ? BOOL_T : BOOL_F;
  }
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_eqp);
#  endif
    return BOOL_F;
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_eqp);
  ASSERT(INUMP(y),y,ARG2,s_eqp);
# endif
#endif
  return ((long)x==(long)y) ? BOOL_T : BOOL_F;
}
SCM lessp(x,y)
     SCM x,y;
{
#ifdef FLOATS
  if NINUMP(x) {
# ifdef BIGDIG
#  ifndef RECKLESS
    if (!(NIMP(x)))
    badx: wta(x,(char *)ARG1,s_lessp);
#  endif
    if BIGP(x) {
      if INUMP(y) return BIGSIGN(x) ? BOOL_T : BOOL_F;
      ASRTGO(NIMP(y),bady);
      if BIGP(y) return (1==bigcomp(x,y)) ? BOOL_T : BOOL_F;
      ASRTGO(REALP(y),bady);
      return (big2dbl(x) < REALPART(y)) ? BOOL_T : BOOL_F;
    }
    ASRTGO(REALP(x),badx);
# else
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_lessp);
# endif
    if INUMP(y) return (REALPART(x) < ((double)INUM(y))) ? BOOL_T : BOOL_F;
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return (REALPART(x) < big2dbl(y)) ? BOOL_T : BOOL_F;
    ASRTGO(REALP(y),bady);
# else
    ASRTGO(NIMP(y) && REALP(y),bady);
# endif
    return (REALPART(x) < REALPART(y)) ? BOOL_T : BOOL_F;
  }
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return BIGSIGN(y) ? BOOL_F : BOOL_T;
#  ifndef RECKLESS
    if (!(REALP(y)))
    bady: wta(y,(char *)ARG2,s_lessp);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && REALP(y)))
    bady: wta(y,(char *)ARG2,s_lessp);
#  endif
# endif
    return (((double)INUM(x)) < REALPART(y)) ? BOOL_T : BOOL_F;
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_lessp);
    if INUMP(y) return BIGSIGN(x) ? BOOL_T : BOOL_F;
    ASRTGO(NIMP(y) && BIGP(y),bady);
    return (1==bigcomp(x,y)) ? BOOL_T : BOOL_F;
  }
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_lessp);
#  endif
    return BIGSIGN(y) ? BOOL_F : BOOL_T;
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_lessp);
  ASSERT(INUMP(y),y,ARG2,s_lessp);
# endif
#endif
  return ((long)x < (long)y) ? BOOL_T : BOOL_F;
}
SCM greaterp(x,y)
SCM x,y;
{
  return lessp(y,x);
}
SCM leqp(x,y)
     SCM x,y;
{
  return BOOL_NOT(lessp(y,x));
}
SCM greqp(x,y)
     SCM x,y;
{
  return BOOL_NOT(lessp(x,y));
}
SCM zerop(z)
SCM z;
{
#ifdef FLOATS
  if NINUMP(z) {
# ifdef BIGDIG
    ASRTGO(NIMP(z),badz);
    if BIGP(z) return BOOL_F;
#  ifndef RECKLESS
    if (!(INEXP(z)))
      badz: wta(z,(char *)ARG1,s_zerop);
#   endif
# else
    ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_zerop);
# endif
    return (z==flo0) ? BOOL_T : BOOL_F;
  }
#else
# ifdef BIGDIG
  if NINUMP(z) {
    ASSERT(NIMP(z) && BIGP(z),z,ARG1,s_zerop);
    return BOOL_F;
  }
# else
  ASSERT(INUMP(z),z,ARG1,s_zerop);
# endif
#endif
  return (z==INUM0) ? BOOL_T: BOOL_F;
}
SCM positivep(x)
SCM x;
{
#ifdef FLOATS
  if NINUMP(x) {
# ifdef BIGDIG
    ASRTGO(NIMP(x),badx);
    if BIGP(x) return TYP16(x)==tc16_bigpos ? BOOL_T : BOOL_F;
#  ifndef RECKLESS
    if (!(REALP(x)))
      badx: wta(x,(char *)ARG1,s_positivep);
#  endif
#else
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_positivep);
# endif
    return (REALPART(x) > 0.0) ? BOOL_T : BOOL_F;
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_positivep);
    return TYP16(x)==tc16_bigpos ? BOOL_T : BOOL_F;
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_positivep);
# endif
#endif
  return (x > INUM0) ? BOOL_T : BOOL_F;
}
SCM negativep(x)
SCM x;
{
#ifdef FLOATS
  if NINUMP(x) {
# ifdef BIGDIG
    ASRTGO(NIMP(x),badx);
    if BIGP(x) return TYP16(x)==tc16_bigpos ? BOOL_F : BOOL_T;
#  ifndef RECKLESS
    if (!(REALP(x)))
      badx: wta(x,(char *)ARG1,s_negativep);
#  endif
#else
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_negativep);
# endif
    return (REALPART(x) < 0.0) ? BOOL_T : BOOL_F;
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_negativep);
    return (TYP16(x)==tc16_bigneg) ? BOOL_T : BOOL_F;
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_negativep);
# endif
#endif
  return (x < INUM0) ? BOOL_T : BOOL_F;
}

SCM lmax(x,y)
     SCM x,y;
{
#ifdef FLOATS
  double z;
#endif
  if UNBNDP(y) {
#ifndef RECKLESS
    if (!(NUMBERP(x)))
    badx: wta(x,(char *)ARG1,s_max);
#endif
    return x;
  }
#ifdef FLOATS
  if NINUMP(x) {
# ifdef BIGDIG
    ASRTGO(NIMP(x),badx);
    if BIGP(x) {
      if INUMP(y) return BIGSIGN(x) ? y : x;
      ASRTGO(NIMP(y),bady);
      if BIGP(y) return (1==bigcomp(x,y)) ? y : x;
      ASRTGO(REALP(y),bady);
      z = big2dbl(x);
      return (z < REALPART(y)) ? y : makdbl(z,0.0);
    }
    ASRTGO(REALP(x),badx);
# else
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_max);
# endif
    if INUMP(y) return (REALPART(x) < (z = INUM(y))) ? makdbl(z,0.0) : x;
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return (REALPART(x) < (z = big2dbl(y))) ? makdbl(z,0.0) : x;
    ASRTGO(REALP(y),bady);
# else
    ASRTGO(NIMP(y) && REALP(y),bady);
# endif
    return (REALPART(x) < REALPART(y)) ? y : x;
  }
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return BIGSIGN(y) ? x : y;
#  ifndef RECKLESS
    if (!(REALP(y)))
    bady: wta(y,(char *)ARG2,s_max);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && REALP(y)))
    bady: wta(y,(char *)ARG2,s_max);
#  endif
# endif
    return ((z = INUM(x)) < REALPART(y)) ? y : makdbl(z,0.0);
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_max);
    if INUMP(y) return BIGSIGN(x) ? y : x;
    ASRTGO(NIMP(y) && BIGP(y),bady);
    return (1==bigcomp(x,y)) ? y : x;
  }
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_max);
#  endif
    return BIGSIGN(y) ? x : y;
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_max);
  ASSERT(INUMP(y),y,ARG2,s_max);
# endif
#endif
  return ((long)x < (long)y) ? y : x;
}

SCM lmin(x,y)
     SCM x,y;
{
#ifdef FLOATS
  double z;
#endif
  if UNBNDP(y) {
#ifndef RECKLESS
    if (!(NUMBERP(x)))
    badx: wta(x,(char *)ARG1,s_min);
#endif
    return x;
  }
#ifdef FLOATS
  if NINUMP(x) {
# ifdef BIGDIG
    ASRTGO(NIMP(x),badx);
    if BIGP(x) {
      if INUMP(y) return BIGSIGN(x) ? x : y;
      ASRTGO(NIMP(y),bady);
      if BIGP(y) return (-1==bigcomp(x,y)) ? y : x;
      ASRTGO(REALP(y),bady);
      z = big2dbl(x);
      return (z > REALPART(y)) ? y : makdbl(z,0.0);
    }
    ASRTGO(REALP(x),badx);
# else
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_min);
# endif
    if INUMP(y) return (REALPART(x) > (z = INUM(y))) ? makdbl(z,0.0) : x;
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return (REALPART(x) > (z = big2dbl(y))) ? makdbl(z,0.0) : x;
    ASRTGO(REALP(y),bady);
# else
    ASRTGO(NIMP(y) && REALP(y),bady);
# endif
    return (REALPART(x) > REALPART(y)) ? y : x;
  }
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return BIGSIGN(y) ? y : x;
#  ifndef RECKLESS
    if (!(REALP(y)))
    bady: wta(y,(char *)ARG2,s_min);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && REALP(y)))
    bady: wta(y,(char *)ARG2,s_min);
#  endif
# endif
    return ((z = INUM(x)) > REALPART(y)) ? y : makdbl(z,0.0);
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_min);
    if INUMP(y) return BIGSIGN(x) ? x : y;
    ASRTGO(NIMP(y) && BIGP(y),bady);
    return (-1==bigcomp(x,y)) ? y : x;
  }
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_min);
#  endif
    return BIGSIGN(y) ? y : x;
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_min);
  ASSERT(INUMP(y),y,ARG2,s_min);
# endif
#endif
  return ((long)x > (long)y) ? y : x;
}

SCM sum(x,y)
     SCM x,y;
{
  if UNBNDP(y) {
    if UNBNDP(x) return INUM0;
#ifndef RECKLESS
    if (!(NUMBERP(x)))
    badx: wta(x,(char *)ARG1,s_sum);
#endif
    return x;
  }
#ifdef FLOATS
  if NINUMP(x) {
    SCM t;
# ifdef BIGDIG
    ASRTGO(NIMP(x),badx);
    if BIGP(x) {
      if INUMP(y) {t = x; x = y; y = t; goto intbig;}
      ASRTGO(NIMP(y),bady);
      if BIGP(y) {
	if (NUMDIGS(x) > NUMDIGS(y)) {t = x; x = y; y = t;}
	return addbig(BDIGITS(x),NUMDIGS(x),BIGSIGN(x),y,0);
      }
      ASRTGO(INEXP(y),bady);
    bigreal: return makdbl(big2dbl(x)+REALPART(y),CPLXP(y)?IMAG(y):0.0);
    }
    ASRTGO(INEXP(x),badx);
# else
    ASRTGO(NIMP(x) && INEXP(x),badx);
# endif
    if INUMP(y) {t = x; x = y; y = t; goto intreal;}
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) {t = x; x = y; y = t; goto bigreal;}
#  ifndef RECKLESS
    else if (!(INEXP(y)))
    bady: wta(y,(char *)ARG2,s_sum);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && INEXP(y)))
    bady: wta(y,(char *)ARG2,s_sum);
#  endif
# endif
    { double i = 0.0;
      if CPLXP(x) i = IMAG(x);
      if CPLXP(y) i += IMAG(y);
      return makdbl(REALPART(x)+REALPART(y),i); }
  }
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y)
    intbig: {
#ifndef DIGSTOOBIG
      long z = pseudolong(INUM(x));
      return addbig(&z,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0);
#else
      BIGDIG zdigs[DIGSPERLONG];
      longdigs(INUM(x), zdigs);
      return addbig(zdigs,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0);
#endif
    }
    ASRTGO(INEXP(y),bady);
# else
    ASRTGO(NIMP(y) && INEXP(y),bady);
# endif
  intreal: return makdbl(INUM(x)+REALPART(y),CPLXP(y)?IMAG(y):0.0);
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    SCM t;
    ASRTGO(NIMP(x) && BIGP(x),badx);
    if INUMP(y) {t = x; x = y; y = t; goto intbig;}
    ASRTGO(NIMP(y) && BIGP(y),bady);
    if (NUMDIGS(x) > NUMDIGS(y)) {t = x; x = y; y = t;}
    return addbig(BDIGITS(x),NUMDIGS(x),BIGSIGN(x),y,0);
  }
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_sum);
#  endif
    intbig: {
#ifndef DIGSTOOBIG
      long z = pseudolong(INUM(x));
      return addbig(&z,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0);
#else
      BIGDIG zdigs[DIGSPERLONG];
      longdigs(INUM(x), zdigs);
      return addbig(zdigs,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0);
#endif
    }
  }
# else
  ASRTGO(INUMP(x),badx);
  ASSERT(INUMP(y),y,ARG2,s_sum);
# endif
#endif
  x = INUM(x)+INUM(y);
  if FIXABLE(x) return MAKINUM(x);
#ifdef BIGDIG
  return long2big(x);
#else
# ifdef FLOATS
  return makdbl((double)x,0.0);
# else
  wta(y,(char *)OVFLOW,s_sum);
# endif
#endif
}

SCM difference(x,y)
SCM x,y;
{
#ifdef FLOATS
  if NINUMP(x) {
# ifndef RECKLESS
    if (!(NIMP(x)))
    badx: wta(x,(char *)ARG1,s_difference);
# endif
    if UNBNDP(y) {
# ifdef BIGDIG
      if BIGP(x) {
	x = copybig(x,!BIGSIGN(x));
	return NUMDIGS(x) * BITSPERDIG/CHAR_BIT <= sizeof(SCM) ?
	  big2long(x,NUMDIGS(x)) : x;
      }
# endif
      ASRTGO(INEXP(x),badx);
      return makdbl(-REALPART(x),CPLXP(x)?-IMAG(x):0.0);
    }
    if INUMP(y) return sum(x,MAKINUM(-INUM(y)));
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(x) {
      if BIGP(y) return (NUMDIGS(x) < NUMDIGS(y)) ?
		   addbig(BDIGITS(x),NUMDIGS(x),BIGSIGN(x),y,0x0100) :
		   addbig(BDIGITS(y),NUMDIGS(y),BIGSIGN(y) ^ 0x0100,x,0);
      ASRTGO(INEXP(y),bady);
      return makdbl(big2dbl(x)-REALPART(y),CPLXP(y)?-IMAG(y):0.0);
    }
    ASRTGO(INEXP(x),badx);
    if BIGP(y) return makdbl(REALPART(x)-big2dbl(y),CPLXP(x)?IMAG(x):0.0);
    ASRTGO(INEXP(y),bady);
# else
    ASRTGO(INEXP(x),badx);
    ASRTGO(NIMP(y) && INEXP(y),bady);
# endif
    if CPLXP(x)
      if CPLXP(y)
	return makdbl(REAL(x)-REAL(y), IMAG(x)-IMAG(y));
      else
	return makdbl(REAL(x)-REALPART(y), IMAG(x));
    return makdbl(REALPART(x)-REALPART(y), CPLXP(y)?-IMAG(y):0.0);
  }
  if UNBNDP(y) {x = -INUM(x); goto checkx;}
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) {
#ifndef DIGSTOOBIG
      long z = pseudolong(INUM(x));
      return addbig(&z,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0x0100);
#else
      BIGDIG zdigs[DIGSPERLONG];
      longdigs(INUM(x), zdigs);
      return addbig(zdigs,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0x0100);
#endif
    }
#  ifndef RECKLESS
    if (!(INEXP(y)))
    bady: wta(y,(char *)ARG2,s_difference);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && INEXP(y)))
    bady: wta(y,(char *)ARG2,s_difference);
#  endif
# endif
    return makdbl(INUM(x)-REALPART(y), CPLXP(y)?-IMAG(y):0.0);
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_difference);
    if UNBNDP(y) {
      x = copybig(x,!BIGSIGN(x));
      return NUMDIGS(x) * BITSPERDIG/CHAR_BIT <= sizeof(SCM) ?
		big2long(x,NUMDIGS(x)) : x;
    }
    if INUMP(y) {
#ifndef DIGSTOOBIG
      long z = pseudolong(INUM(y));
      return addbig(&z,DIGSPERLONG,(y < 0) ? 0 : 0x0100,x,0);
#else
      BIGDIG zdigs[DIGSPERLONG];
      longdigs(INUM(x), zdigs);
      return addbig(zdigs,DIGSPERLONG,(y < 0) ? 0 : 0x0100,x,0);
#endif
    }
    ASRTGO(NIMP(y) && BIGP(y),bady);
    return (NUMDIGS(x) < NUMDIGS(y)) ?
		   addbig(BDIGITS(x),NUMDIGS(x),BIGSIGN(x),y,0x0100) :
		   addbig(BDIGITS(y),NUMDIGS(y),BIGSIGN(y) ^ 0x0100,x,0);
  }
  if UNBNDP(y) {x = -INUM(x); goto checkx;}
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_difference);
#  endif
    {
#ifndef DIGSTOOBIG
      long z = pseudolong(INUM(x));
      return addbig(&z,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0x0100);
#else
      BIGDIG zdigs[DIGSPERLONG];
      longdigs(INUM(x), zdigs);
      return addbig(zdigs,DIGSPERLONG,(x < 0) ? 0x0100 : 0,y,0x0100);
#endif
    }
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_difference);
  if UNBNDP(y) {x = -INUM(x); goto checkx;}
  ASSERT(INUMP(y),y,ARG2,s_difference);
# endif
#endif
  x = INUM(x)-INUM(y);
 checkx:
  if FIXABLE(x) return MAKINUM(x);
#ifdef BIGDIG
  return long2big(x);
#else
# ifdef FLOATS
  return makdbl((double)x,0.0);
# else
  wta(y, (char *)OVFLOW, s_difference);
# endif
#endif
}

SCM product(x,y)
     SCM x,y;
{
  if UNBNDP(y) {
    if UNBNDP(x) return MAKINUM(1L);
#ifndef RECKLESS
    if (!(NUMBERP(x)))
    badx: wta(x,(char *)ARG1,s_product);
#endif
    return x;
  }
#ifdef FLOATS
  if NINUMP(x) {
    SCM t;
# ifdef BIGDIG
    ASRTGO(NIMP(x),badx);
    if BIGP(x) {
      if INUMP(y) {t = x; x = y; y = t; goto intbig;}
      ASRTGO(NIMP(y),bady);
      if BIGP(y) return mulbig(BDIGITS(x),NUMDIGS(x),BDIGITS(y),NUMDIGS(y),
			       BIGSIGN(x) ^ BIGSIGN(y));
      ASRTGO(INEXP(y),bady);
    bigreal: {
      double bg = big2dbl(x);
      return makdbl(bg*REALPART(y),CPLXP(y)?bg*IMAG(y):0.0); }
    }
    ASRTGO(INEXP(x),badx);
# else
    ASRTGO(NIMP(x) && INEXP(x),badx);
# endif
    if INUMP(y) {t = x; x = y; y = t; goto intreal;}
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) {t = x; x = y; y = t; goto bigreal;}
#  ifndef RECKLESS
    else if (!(INEXP(y)))
    bady: wta(y,(char *)ARG2,s_product);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && INEXP(y)))
    bady: wta(y,(char *)ARG2,s_product);
#  endif
# endif
    if CPLXP(x)
      if CPLXP(y)
	return makdbl(REAL(x)*REAL(y)-IMAG(x)*IMAG(y),
		      REAL(x)*IMAG(y)+IMAG(x)*REAL(y));
      else
	return makdbl(REAL(x)*REALPART(y), IMAG(x)*REALPART(y));
    return makdbl(REALPART(x)*REALPART(y),
		  CPLXP(y)?REALPART(x)*IMAG(y):0.0);
  }
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) {
    intbig: if (INUM0==x) return x; if (MAKINUM(1L)==x) return y;
      {
#ifndef DIGSTOOBIG
	long z = pseudolong(INUM(x));
	return mulbig(&z,DIGSPERLONG,BDIGITS(y),NUMDIGS(y),
		      BIGSIGN(y) ? (x>0) : (x<0));
#else
	BIGDIG zdigs[DIGSPERLONG];
	longdigs(INUM(x), zdigs);
	return mulbig(zdigs,DIGSPERLONG,BDIGITS(y),NUMDIGS(y),
		      BIGSIGN(y) ? (x>0) : (x<0));
#endif
      }
    }
    ASRTGO(INEXP(y),bady);
# else
    ASRTGO(NIMP(y) && INEXP(y),bady);
# endif
  intreal: return makdbl(INUM(x)*REALPART(y), CPLXP(y)?INUM(x)*IMAG(y):0.0);
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    ASRTGO(NIMP(x) && BIGP(x),badx);
    if INUMP(y) {SCM t = x; x = y; y = t; goto intbig;}
    ASRTGO(NIMP(y) && BIGP(y),bady);
    return mulbig(BDIGITS(x),NUMDIGS(x),BDIGITS(y),NUMDIGS(y),
		  BIGSIGN(x) ^ BIGSIGN(y));
  }
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_product);
#  endif
  intbig: if (INUM0==x) return x; if (MAKINUM(1L)==x) return y;
    {
#ifndef DIGSTOOBIG
      long z = pseudolong(INUM(x));
      return mulbig(&z,DIGSPERLONG,BDIGITS(y),NUMDIGS(y),
		    BIGSIGN(y) ? (x>0) : (x<0));
#else
      BIGDIG zdigs[DIGSPERLONG];
      longdigs(INUM(x), zdigs);
      return mulbig(zdigs,DIGSPERLONG,BDIGITS(y),NUMDIGS(y),
		    BIGSIGN(y) ? (x>0) : (x<0));
#endif
    }
  }
# else
  ASRTGO(INUMP(x),badx);
  ASSERT(INUMP(y),y,ARG2,s_product);
# endif
#endif
  {
    long i, j, k;
    i = INUM(x);
    if (0==i) return x;
    j = INUM(y);
    k = i * j;
    y = MAKINUM(k);
    if (k != INUM(y) || k/i != j)
#ifdef BIGDIG
      { int sgn = (i < 0) ^ (j < 0);
#ifndef DIGSTOOBIG
	i = pseudolong(i);
	j = pseudolong(j);
	return mulbig(&i,DIGSPERLONG,&j,DIGSPERLONG,sgn);
#else  /* DIGSTOOBIG */
	BIGDIG idigs[DIGSPERLONG];
	BIGDIG jdigs[DIGSPERLONG];
	longdigs(i, idigs);
	longdigs(j, jdigs);
	return mulbig(idigs,DIGSPERLONG,jdigs,DIGSPERLONG,sgn);
#endif
      }
#else
# ifdef FLOATS
    return makdbl(((double)i)*((double)j),0.0);
# else
    wta(y, (char *)OVFLOW, s_product);
# endif
#endif
    return y;
  }
}

SCM divide(x,y)
SCM x,y;
{
#ifdef FLOATS
  double d,r,i,a;
  if NINUMP(x) {
# ifndef RECKLESS
    if (!(NIMP(x)))
    badx: wta(x,(char *)ARG1,s_divide);
# endif
    if UNBNDP(y) {
# ifdef BIGDIG
      if BIGP(x) return makdbl(1.0/big2dbl(x),0.0);
# endif
      ASRTGO(INEXP(x),badx);
      if REALP(x) return makdbl(1.0/REALPART(x),0.0);
      r = REAL(x);  i = IMAG(x);  d = r*r+i*i;
      return makdbl(r/d,-i/d);
    }
# ifdef BIGDIG
    if BIGP(x) {
      SCM z;
      if INUMP(y) {
        z = INUM(y);
        ASSERT(z, y, OVFLOW, s_divide);
	if (1==z) return x;
        if (z < 0) z = -z;
        if (z < BIGRAD) {
          SCM w = copybig(x, BIGSIGN(x) ? (y>0) : (y<0));
          return divbigdig(BDIGITS(w), NUMDIGS(w), (BIGDIG)z) ?
	    makdbl(big2dbl(x)/INUM(y),0.0) : normbig(w);
	}
#ifndef DIGSTOOBIG
        z = pseudolong(z);
        z = divbigbig(BDIGITS(x), NUMDIGS(x), &z, DIGSPERLONG,
                      BIGSIGN(x) ? (y>0) : (y<0), 3);
#else
	{ BIGDIG zdigs[DIGSPERLONG];
	  longdigs(z, zdigs);
	  z = divbigbig(BDIGITS(x), NUMDIGS(x), zdigs, DIGSPERLONG,
			BIGSIGN(x) ? (y>0) : (y<0), 3);}
#endif
        return z ? z : makdbl(big2dbl(x)/INUM(y),0.0);
      }
      ASRTGO(NIMP(y),bady);
      if BIGP(y) {
	z = divbigbig(BDIGITS(x), NUMDIGS(x), BDIGITS(y), NUMDIGS(y),
		      BIGSIGN(x) ^ BIGSIGN(y), 3);
	return z ? z : makdbl(big2dbl(x)/big2dbl(y),0.0);
      }
      ASRTGO(INEXP(y),bady);
      if REALP(y) return makdbl(big2dbl(x)/REALPART(y),0.0);
      a = big2dbl(x);
      goto complex_div;
    }
# endif
    ASRTGO(INEXP(x),badx);
    if INUMP(y) {d = INUM(y); goto basic_div;}
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) {d = big2dbl(y); goto basic_div;}
    ASRTGO(INEXP(y),bady);
# else
    ASRTGO(NIMP(y) && INEXP(y),bady);
# endif
    if REALP(y) {
      d = REALPART(y);
    basic_div: return makdbl(REALPART(x)/d, CPLXP(x)?IMAG(x)/d:0.0);
    }
    a = REALPART(x);
    if REALP(x) goto complex_div;
    r = REAL(y);  i = IMAG(y);  d = r*r+i*i;
    return makdbl((a*r+IMAG(x)*i)/d,(IMAG(x)*r-a*i)/d);
  }
  if UNBNDP(y) {
    if ((MAKINUM(1L)==x) || (MAKINUM(-1L)==x)) return x;
    return makdbl(1.0/((double)INUM(x)),0.0);
  }
  if NINUMP(y) {
# ifdef BIGDIG
    ASRTGO(NIMP(y),bady);
    if BIGP(y) return makdbl(INUM(x)/big2dbl(y),0.0);
#  ifndef RECKLESS
    if (!(INEXP(y)))
    bady: wta(y,(char *)ARG2,s_divide);
#  endif
# else
#  ifndef RECKLESS
    if (!(NIMP(y) && INEXP(y)))
    bady: wta(y,(char *)ARG2,s_divide);
#  endif
# endif
    if REALP(y) return makdbl(INUM(x)/REALPART(y),0.0);
    a = INUM(x);
  complex_div:
    r = REAL(y);  i = IMAG(y);  d = r*r+i*i;
    return makdbl((a*r)/d,(-a*i)/d);
  }
#else
# ifdef BIGDIG
  if NINUMP(x) {
    SCM z;
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_divide);
    if UNBNDP(y) goto ov;
    if INUMP(y) {
      z = INUM(y);
      if (!z) goto ov;
      if (1==z) return x;
      if (z < 0) z = -z;
      if (z < BIGRAD) {
        SCM w = copybig(x, BIGSIGN(x) ? (y>0) : (y<0));
        if (divbigdig(BDIGITS(w), NUMDIGS(w), (BIGDIG)z)) goto ov;
        return w;
      }
#ifndef DIGSTOOBIG
      z = pseudolong(z);
      z = divbigbig(BDIGITS(x), NUMDIGS(x), &z, DIGSPERLONG,
		    BIGSIGN(x) ? (y>0) : (y<0), 3);
#else
      { BIGDIG zdigs[DIGSPERLONG];
	longdigs(z, zdigs);
	z = divbigbig(BDIGITS(x), NUMDIGS(x), zdigs, DIGSPERLONG,
		      BIGSIGN(x) ? (y>0) : (y<0), 3);}
#endif
    } else {
      ASRTGO(NIMP(y) && BIGP(y),bady);
      z = divbigbig(BDIGITS(x), NUMDIGS(x), BDIGITS(y), NUMDIGS(y),
		    BIGSIGN(x) ^ BIGSIGN(y), 3);
    }
    if (!z) goto ov;
    return z;
  }
  if UNBNDP(y) {
    if ((MAKINUM(1L)==x) || (MAKINUM(-1L)==x)) return x;
    goto ov;
  }
  if NINUMP(y) {
#  ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_divide);
#  endif
    goto ov;
  }
# else
  ASSERT(INUMP(x),x,ARG1,s_divide);
  if UNBNDP(y) {
    if ((MAKINUM(1L)==x) || (MAKINUM(-1L)==x)) return x;
    goto ov;
  }
  ASSERT(INUMP(y),y,ARG2,s_divide);
# endif
#endif
  {
    long z = INUM(y);
    if ((0==z) || INUM(x)%z) goto ov;
    z = INUM(x)/z;
    if FIXABLE(z) return MAKINUM(z);
#ifdef BIGDIG
    return long2big(z);
#endif
#ifdef FLOATS
  ov: return makdbl(((double)INUM(x))/((double)INUM(y)),0.0);
#else
  ov: wta(x, (char *)OVFLOW, s_divide);
#endif
  }
}

#ifdef FLOATS
double lasinh(x)
     double x;
{
  return log(x+sqrt(x*x+1));
}

double lacosh(x)
     double x;
{
  return log(x+sqrt(x*x-1));
}

double latanh(x)
     double x;
{
  return 0.5*log((1+x)/(1-x));
}

double ltrunc(x)
     double x;
{
  if (x < 0.0) return -floor(-x);
  return floor(x);
}
double round(x)
     double x;
{
  return floor(x+0.5);
}

struct dpair {double x,y;};

void two_doubles(z1,z2,sstring,xy)
     SCM z1,z2;
     char *sstring;
     struct dpair *xy;
{
  if INUMP(z1) xy->x = INUM(z1);
  else {
#ifdef BIGDIG
    ASRTGO(NIMP(z1),badz1);
    if BIGP(z1) xy->x = big2dbl(z1);
    else {
# ifndef RECKLESS
      if (!(REALP(z1)))
      badz1: wta(z1,(char *)ARG1,sstring);
# endif
      xy->x = REALPART(z1);}
#else
    {ASSERT(NIMP(z1) && REALP(z1),z1,ARG1,sstring);
     xy->x = REALPART(z1);}
#endif
  }
  if INUMP(z2) xy->y = INUM(z2);
  else {
#ifdef BIGDIG
    ASRTGO(NIMP(z2),badz2);
    if BIGP(z2) xy->y = big2dbl(z2);
    else {
# ifndef RECKLESS
      if (!(REALP(z2)))
      badz2: wta(z2,(char *)ARG2,sstring);
# endif
      xy->y = REALPART(z2);}
#else
    {ASSERT(NIMP(z2) && REALP(z2),z2,ARG2,sstring);
     xy->y = REALPART(z2);}
#endif
  }
}

SCM expt(z1,z2)
     SCM z1,z2;
{
  struct dpair xy;
  two_doubles(z1,z2,s_expt,&xy);
  return makdbl(pow(xy.x,xy.y),0.0);
}
SCM latan2(z1,z2)
     SCM z1,z2;
{
  struct dpair xy;
  two_doubles(z1,z2,s_atan2,&xy);
  return makdbl(atan2(xy.x,xy.y),0.0);
}
SCM makrect(z1,z2)
     SCM z1,z2;
{
  struct dpair xy;
  two_doubles(z1,z2,s_makrect,&xy);
  return makdbl(xy.x,xy.y);
}
SCM makpolar(z1,z2)
     SCM z1,z2;
{
  struct dpair xy;
  two_doubles(z1,z2,s_makpolar,&xy);
  return makdbl(xy.x*cos(xy.y),xy.x*sin(xy.y));
}

SCM real_part(z)
     SCM z;
{
  if NINUMP(z) {
#ifdef BIGDIG
    ASRTGO(NIMP(z),badz);
    if BIGP(z) return z;
# ifndef RECKLESS
    if (!(INEXP(z)))
    badz: wta(z,(char *)ARG1,s_real_part);
# endif
#else
    ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_real_part);
#endif
    if CPLXP(z) return makdbl(REAL(z),0.0);
  }
  return z;
}
SCM imag_part(z)
     SCM z;
{
  if INUMP(z) return INUM0;
#ifdef BIGDIG
  ASRTGO(NIMP(z),badz);
  if BIGP(z) return INUM0;
# ifndef RECKLESS
  if (!(INEXP(z)))
  badz: wta(z,(char *)ARG1,s_imag_part);
# endif
#else
  ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_imag_part);
#endif
  if CPLXP(z) return makdbl(IMAG(z),0.0);
  return flo0;
}
SCM magnitude(z)
     SCM z;
{
  if INUMP(z) return absval(z);
#ifdef BIGDIG
  ASRTGO(NIMP(z),badz);
  if BIGP(z) return absval(z);
# ifndef RECKLESS
  if (!(INEXP(z)))
  badz: wta(z,(char *)ARG1,s_magnitude);
# endif
#else
  ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_magnitude);
#endif
  if CPLXP(z)
    {
      double i = IMAG(z),r = REAL(z);
      return makdbl(sqrt(i*i+r*r),0.0);
    }
  return makdbl(fabs(REALPART(z)),0.0);
}

SCM angle(z)
     SCM z;
{
  double x, y = 0.0;
  if INUMP(z) {x = (z>=INUM0) ? 1.0 : -1.0; goto do_angle;}
#ifdef BIGDIG
  ASRTGO(NIMP(z),badz);
  if BIGP(z) {x = (TYP16(z)==tc16_bigpos) ? 1.0 : -1.0; goto do_angle;}
# ifndef RECKLESS
  if (!(INEXP(z))) {
    badz: wta(z,(char *)ARG1,s_angle);}
# endif
#else
  ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_angle);
#endif
  if REALP(z) {x = REALPART(z); goto do_angle;}
  x = REAL(z); y = IMAG(z);
do_angle:
  return makdbl(atan2(y,x),0.0);
}

double floident(z)
double z;
{
  return z;
}
SCM in2ex(z)
     SCM z;
{
  if INUMP(z) return z;
#ifdef BIGDIG
  ASRTGO(NIMP(z),badz);
  if BIGP(z) return z;
# ifndef RECKLESS
  if (!(REALP(z)))
    badz: wta(z,(char *)ARG1,s_in2ex);
# endif
#else
  ASRTGO(NIMP(z) && REALP(z),badz);
#endif
#ifdef BIGDIG
  {
    double u = floor(REALPART(z)+0.5);
    if ((u <= MOST_POSITIVE_FIXNUM) && (-u <= -MOST_NEGATIVE_FIXNUM)) {
      /* Negation is a workaround for HP700 cc bug */
      SCM ans = MAKINUM((long)u);
      if (INUM(ans)==(long)u) return ans;
    }
    ASRTGO(!IS_INF(u),badz);
    return dbl2big(u);
  }
#else
  return MAKINUM((long)floor(REALPART(z)+0.5));
#endif
}
#else				/* ~FLOATS */
static char s_trunc[] = "truncate";
SCM numident(x)
     SCM x;
{
  ASSERT(INUMP(x),x,ARG1,s_trunc);
  return x;
}
#endif				/* FLOATS */

#ifdef BIGDIG
# ifdef FLOATS
SCM dbl2big(d)
     double d;			/* must be integer */
{
  sizet i = 0;
  long c;
  BIGDIG *digits;
  SCM ans;
  double u = (d < 0)?-d:d;
  while (0 != floor(u)) {u /= BIGRAD;i++;}
  ans = mkbig(i, d < 0);
  digits = BDIGITS(ans);
  while (i--) {
    u *= BIGRAD;
    c = floor(u);
    u -= c;
    digits[i] = c;
  }
  ASSERT(0==u,INUM0,OVFLOW,"dbl2big");
  return ans;
}
double big2dbl(b)
     SCM b;
{
  double ans = 0.0;
  sizet i = NUMDIGS(b);
  BIGDIG *digits = BDIGITS(b);
  while (i--) ans = digits[i] + BIGRAD*ans;
  if (tc16_bigneg==TYP16(b)) return -ans;
  return ans;
}
# endif
#endif

unsigned long hasher(obj, n, d)
     SCM obj;
     unsigned long n;
     sizet d;
{
  switch (7 & (int) obj) {
  case 2: case 6:		/* INUMP(obj) */
    return INUM(obj) % n;
  case 4:
    if ICHRP(obj)
      return (unsigned)(downcase[ICHR(obj)]) % n;
    switch ((int) obj) {
#ifndef SICP
    case (int) EOL: d = 256; break;
#endif
    case (int) BOOL_T: d = 257; break;
    case (int) BOOL_F: d = 258; break;
    case (int) EOF_VAL: d = 259; break;
    default: d = 263;		/* perhaps should be error */
    }
    return d % n;
  default: return 263 % n;	/* perhaps should be error */
  case 0:
    switch TYP7(obj) {
    default: return 263 % n;
    case tc7_smob:
      switch TYP16(obj) {
      case tcs_bignums:
      bighash: return INUM(modulo(obj,MAKINUM(n)));
      default: return 263 % n;
#ifdef FLOATS
      case tc16_flo:
	if REALP(obj) {
	  double r = REALPART(obj);
	  if (floor(r)==r) {
	    obj = in2ex(obj);
	    if IMP(obj) return INUM(obj) % n;
	    goto bighash;
	  }
	}
	obj = number2string(obj, MAKINUM(10));
#endif
      }
    case tcs_symbols: case tc7_string:
      return strhash(CHARS(obj), (sizet) LENGTH(obj), n);
    case tc7_vector: {
      sizet len = LENGTH(obj);
      SCM *data = VELTS(obj);
      if (len>5) {
	sizet i = d/2;
	unsigned long h = 1;
	while (i--) h = ((h<<8) + (hasher(data[h % len], n, 2))) % n;
	return h;
      }
      else {
	sizet i = len;
	unsigned long h = (n)-1;
	while (i--) h = ((h<<8) + (hasher(data[i], n, d/len))) % n;
	return h;
      }
    }
    case tcs_cons_imcar: case tcs_cons_nimcar:
      if (d) return (hasher(CAR(obj), n, d/2)+hasher(CDR(obj), n, d/2)) % n;
      else return 1;
    case tc7_port:
      return ((RDNG & CAR(obj)) ? 260 : 261) % n;
    case tcs_closures: case tc7_contin: case tcs_subrs:
      return 262 % n;
    }
  }
}

static char s_hashv[] = "hashv", s_hashq[] = "hashq";
extern char s_obunhash[];
#define s_hash (&s_obunhash[9])

SCM hash(obj, n)
     SCM obj;
     SCM n;
{
  ASSERT(INUMP(n) && 0 <= n,n,ARG2,s_hash);
  return MAKINUM(hasher(obj, INUM(n), 10));
}

SCM hashv(obj, n)
     SCM obj;
     SCM n;
{
  ASSERT(INUMP(n) && 0 <= n,n,ARG2,s_hashv);
  if ICHRP(obj) return MAKINUM((unsigned)(downcase[ICHR(obj)]) % INUM(n));
  if (NIMP(obj) && NUMP(obj)) return MAKINUM(hasher(obj, INUM(n), 10));
  else return MAKINUM(obj % INUM(n));
}

SCM hashq(obj, n)
     SCM obj;
     SCM n;
{
  ASSERT(INUMP(n) && 0 <= n,n,ARG2,s_hashq);
  return MAKINUM((((unsigned) obj) >> 1) % INUM(n));
}

char s_getenv[] = "getenv";
char s_system[] = "system";

SCM lsystem(cmd)
SCM cmd;
{
  ASSERT(NIMP(cmd) && STRINGP(cmd),cmd,ARG1,s_system);
  ignore_signals();
#ifdef AZTEC_C
  cmd = MAKINUM(Execute(CHARS(cmd),0,0));
#else
  cmd = MAKINUM(0L+system(CHARS(cmd)));
#endif
  unignore_signals();
  return cmd;
}
char *getenv();
SCM lgetenv(nam)
SCM nam;
{
  char *val;
  ASSERT(NIMP(nam) && STRINGP(nam),nam,ARG1,s_getenv);
  val = getenv(CHARS(nam));
  if (!val) return BOOL_F;
  return makfromstr(val, (sizet)strlen(val));
}

#ifdef vms
#define SYSTNAME "vms"
#endif
#ifdef unix
#define SYSTNAME "unix"
#endif
#ifdef MWC
#define SYSTNAME "coherent"
#endif
#ifdef MSDOS
#define SYSTNAME "msdos"
#endif
#ifdef __EMX__
#define SYSTNAME "os/2"
#endif
#ifdef THINK_C
#define SYSTNAME "thinkc"
#endif
#ifdef AMIGA
#define SYSTNAME "amiga"
#endif
#ifdef atarist
#define SYSTNAME "atarist"
#endif
#ifdef mach
#define SYSTNAME "mach"
#endif
#ifdef ARM_ULIB
#define SYSTNAME "archimedes"
#endif

SCM softtype()
{
#ifdef nosve
  return CAR(intern("nosve", 5));
#else
  return CAR(intern(SYSTNAME, sizeof SYSTNAME/sizeof(char) -1));
#endif
}

#ifdef vms
#include <descrip.h>
#include <ssdef.h>
char s_ed[] = "ed";
SCM ed(fname)
SCM fname;
{
  struct dsc$descriptor_s d;
  ASSERT(NIMP(fname) && STRINGP(fname),fname,ARG1,s_ed);
  d.dsc$b_dtype = DSC$K_DTYPE_T;
  d.dsc$b_class = DSC$K_CLASS_S;
  d.dsc$w_length = LENGTH(fname);
  d.dsc$a_pointer = CHARS(fname);
  /* I don't know what VMS does with signal handlers across the
     edt$edit call. */
  ignore_signals();
  edt$edit(&d);
  unignore_signals();
  return fname;
}
SCM vms_debug()
{
  lib$signal(SS$_DEBUG);
  return UNSPECIFIED;
}
#endif

static iproc subr0s[] = {
	{"software-type",softtype},
#ifdef vms
	{"vms-debug",vms_debug},
#endif
	{0,0}};

static iproc subr1s[] = {
	{"number?",numberp},
	{"complex?",numberp},
	{s_inexactp,inexactp},
#ifdef FLOATS
	{"real?",realp},
	{"rational?",realp},
	{"integer?",intp},
	{s_real_part,real_part},
	{s_imag_part,imag_part},
	{s_magnitude,magnitude},
	{s_angle,angle},
	{s_in2ex,in2ex},
#else
	{"real?",numberp},
	{"rational?",numberp},
	{"integer?",exactp},
	{"floor",numident},
	{"ceiling",numident},
	{s_trunc,numident},
	{"round",numident},
#endif
	{s_zerop,zerop},
	{s_positivep,positivep},
	{s_negativep,negativep},
	{s_str2list,string2list},
	{"list->string",string},
	{s_st_copy,string_copy},
	{"list->vector",vector},
	{s_vect2list,vector2list},
	{s_system,lsystem},
	{s_getenv,lgetenv},
#ifdef vms
	{s_ed,ed},
#endif
	{0,0}};

static iproc asubrs[] = {
	{s_difference,difference},
	{s_divide,divide},
	{s_max,lmax},
	{s_min,lmin},
	{s_sum,sum},
	{s_product,product},
	{0,0}};

static iproc subr2s[] = {
#ifdef FLOATS
	{s_makrect,makrect},
	{s_makpolar,makpolar},
	{s_memv,memv},
	{s_assv,assv},
	{s_atan2,latan2},
	{s_expt,expt},
#else
	{"memv",memq},
	{"assv",assq},
#endif
	{s_list_tail,list_tail},
	{s_ve_fill,vector_fill},
	{s_st_fill,string_fill},
	{s_hash,hash},
	{s_hashv,hashv},
	{s_hashq,hashq},
	{0,0}};

static iproc subr2os[] = {
	{s_str2number,string2number},
	{s_number2string,number2string},
	{0,0}};

static iproc rpsubrs[] = {
#ifdef FLOATS
	{"eqv?",eqv},
#else
	{"eqv?",eq},
#endif
	{s_eqp,eqp},
	{s_lessp,lessp},
	{s_grp,greaterp},
	{s_leqp,leqp},
	{s_greqp,greqp},
	{0,0}};

#ifdef FLOATS
static dblproc cxrs[] = {
	{"floor",floor},
	{"ceiling",ceil},
	{"truncate",ltrunc},
	{"round",round},
	{"$sqrt",sqrt},
	{"$abs",fabs},
	{"$exp",exp},
	{"$log",log},
	{"$sin",sin},
	{"$cos",cos},
	{"$tan",tan},
	{"$asin",asin},
	{"$acos",acos},
	{"$atan",atan},
	{"$sinh",sinh},
	{"$cosh",cosh},
	{"$tanh",tanh},
	{"$asinh",lasinh},
	{"$acosh",lacosh},
	{"$atanh",latanh},
	{"exact->inexact",floident},
	{0,0}};
#endif

#ifdef FLOATS
#ifndef DBL_DIG
static void add1(f, fsum)
     double f, *fsum;
{
  *fsum = f + 1.0;
}
#endif
#endif

void init_scl()
{
  init_iprocs(subr0s,tc7_subr_0);
  init_iprocs(subr1s,tc7_subr_1);
  init_iprocs(subr2os,tc7_subr_2o);
  init_iprocs(subr2s,tc7_subr_2);
  init_iprocs(asubrs,tc7_asubr);
  init_iprocs(rpsubrs,tc7_rpsubr);
#ifdef vms
  add_feature(s_ed);
#endif
#ifdef FLOATS
  init_iprocs(cxrs,tc7_cxr);
  NEWCELL(flo0);
# ifdef SINGLES
  CAR(flo0) = tc_flo;
  FLO(flo0) = 0.0;
# else
  CDR(flo0) = (SCM)must_malloc(1L*sizeof(double),"real");
  REAL(flo0) = 0.0;
  CAR(flo0) = tc_dblr;
# endif
#ifdef DBL_DIG
  dblprec = (DBL_DIG > 20) ? 20 : DBL_DIG;
#else
  {				/* determine floating point precision */
    double f = 0.1;
    double fsum = 1.0+f;
    while (fsum != 1.0) {
      f /= 10.0;
      if (++dblprec > 20) break;
      add1(f,&fsum);
    }
    dblprec = dblprec-1;
  }
#endif /* DBL_DIG */
#endif
}
