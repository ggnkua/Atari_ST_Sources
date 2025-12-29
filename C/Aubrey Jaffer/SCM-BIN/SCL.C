/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992 Aubrey Jaffer.

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
#include <math.h>

static char s_makrect[]="make-rectangular",s_makpolar[]="make-polar",
	    s_magnitude[]="magnitude",s_angle[]="angle",
	    s_real_part[]="real-part",s_imag_part[]="imag-part",
	    s_in2ex[]="inexact->exact";
#endif
char	s_inexactp[]="inexact?";
static char	s_expt[]="expt",s_zerop[]="zero?",
	s_positivep[]="positive?",s_negativep[]="negative?";
static char	s_eqp[]="=",s_lessp[]="<",s_grp[]=">",
	s_lesseqp[]="<=",s_greqp[]=">=";
static char s_max[]="max",s_min[]="min";
static char s_sum[]="+",s_difference[]="-",s_product[]="*",s_divide[]="/";
static char s_number2string[]="number->string",
	s_str2number[]="string->number";

static char s_list_tail[]="list-tail";
static char s_str2list[]="string->list";
static char s_st_copy[]="string-copy", s_st_fill[]="string-fill!";
static char s_vect2list[]="vector->list", s_ve_fill[]="vector-fill!";

#ifdef FLOATS
static char	s_memv[]="memv",s_assv[]="assv";
SCM eqv(x,y)
SCM x,y;
{
	if (x == y) return BOOL_T;
	if IMP(x) return BOOL_F;
	if IMP(y) return BOOL_F;
	/* this ensures that types and length are the same. */
	if (CAR(x) != CAR(y)) return BOOL_F;
	if INEXP(x) return eqp(x,y,EOL);
	return BOOL_F;
}
SCM memv(x,lst)			/* m.borza  12.2.91 */
SCM x,lst;
{
	for(;NIMP(lst);lst = CDR(lst)) {
		ASSERT(CONSP(lst),lst,ARG2,s_memv);
		if (eqv(CAR(lst),x) == BOOL_T) return lst;
	}
	ASSERT(NULLP(lst),lst,ARG2,s_memv);
	return BOOL_F;
}
SCM assv(x,alist)		/* m.borza  12.2.91 */
SCM x,alist;
{
	SCM tmp;
	for(;NIMP(alist);alist=CDR(alist)) {
		ASSERT(CONSP(alist),alist,ARG2,s_assv);
		tmp = CAR(alist);
		ASSERT(CONSP(tmp),alist,ARG2,s_assv);
		if (eqv(CAR(tmp),x) == BOOL_T) return tmp;
	}
	ASSERT(NULLP(alist),alist,ARG2,s_assv);
	return BOOL_F;
}
#endif /* FLOATS */

SCM list_tail(lst,k)
SCM lst, k;
{
	register long i;
	ASSERT(INUMP(k),k,ARG2,s_list_tail);
	i = INUM(k);
	while (i-- > 0) {
		ASSERT(NIMP(lst) && CONSP(lst),lst,ARG1,s_list_tail);
		lst=CDR(lst);
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
	src = (unsigned char *)CHARS(str);
	for(i=LENGTH(str)-1;i>=0;i--) res = cons(MAKICHR(src[i]),res);
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
	for(k=LENGTH(str)-1;k>=0;k--) dst[k] = c;
	return UNSPECIFIED;
}
SCM vector2list(v)
SCM v;
{
	SCM res = EOL;
	long i;
	SCM *data;
	ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_vect2list);
	data=VELTS(v);
	for(i=LENGTH(v)-1;i>=0;i--) res = cons(data[i],res);
	return res;
}
SCM vector_fill(v,fill)
SCM v,fill;
{
	register long i;
	register SCM *data;
	ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_ve_fill);
	data = VELTS(v);
	for(i=LENGTH(v)-1;i>=0;i--) data[i] = fill;
	return UNSPECIFIED;
}

SCM numberp(x)
SCM x;
{
	if INUMP(x) return BOOL_T;
#ifdef FLOATS
	if (NIMP(x) && INEXP(x)) return BOOL_T;
#endif
	return BOOL_F;
}
#ifdef FLOATS
#define NUMBERP(x) (INUMP(x) || (NIMP(x) && INEXP(x)))
SCM realp(x)
     SCM x;
{
  if INUMP(x) return BOOL_T;
  if IMP(x) return BOOL_F;
  if REALP(x) return BOOL_T;
  return BOOL_F;
}
SCM intp(x)
     SCM x;
{
  double r;
  if INUMP(x) return BOOL_T;
  if IMP(x) return BOOL_F;
  if (!INEXP(x)) return BOOL_F;
  if CPLXP(x) return BOOL_F;
  r = REALPART(x);
  if (r == floor(r)) return BOOL_T;
  return BOOL_F;
}
#else
#define NUMBERP(x) INUMP(x)
#endif /* FLOATS */

SCM inexactp(x)
SCM x;
{
#ifdef FLOATS
	if (NIMP(x) && INEXP(x)) return BOOL_T;
#endif
	return BOOL_F;
}
SCM eqp(x,y,args)
SCM x,y,args;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && INEXP(x),x,ARG1,s_eqp);
    for(;;) {
      if INUMP(y) {
	if (REALPART(x) != ((double)INUM(y))) return BOOL_F;
	if CPLXP(x) return BOOL_F;
	if NULLP(args) return BOOL_T;
	x = y;
	y = CAR(args);
	args = CDR(args);
	goto do_int;
      }
      ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_eqp);
      if (REALPART(x) != REALPART(y)) return BOOL_F;
      if CPLXP(x)
	if CPLXP(y) {
	  if (IMAG(x) != IMAG(y))  return BOOL_F;
	} else return BOOL_F;
      else
	if CPLXP(y) return BOOL_F;
      if NULLP(args) return BOOL_T;
      y = CAR(args);
      args = CDR(args);
    }
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_eqp);
#endif
  for(;;) {
#ifdef FLOATS
do_int:
    if NINUMP(y) {
      ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_eqp);
      if (((double)INUM(x)) != REALPART(y)) return BOOL_F;
      if CPLXP(y) return BOOL_F;
    } else
#else
    ASSERT(INUMP(y),y,ARG2,s_eqp);
#endif
    if ((long)x != (long)y) return BOOL_F;
    if NULLP(args) return BOOL_T;
    y = CAR(args);
    args = CDR(args);
  }
}
SCM lessp(x,y,args)
SCM x,y,args;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_lessp);
    for(;;) {
do_flt:
      if INUMP(y) {
	if (REALPART(x) >= ((double)INUM(y))) return BOOL_F;
	if NULLP(args) return BOOL_T;
	x = y;
	y = CAR(args);
	args = CDR(args);
	goto do_int;
      }
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_lessp);
      if (REALPART(x) >= REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
    }
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_lessp);
#endif
  for(;;) {
#ifdef FLOATS
do_int:
    if NINUMP(y) {
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_lessp);
      if (((double)INUM(x)) >= REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
      goto do_flt;
    }
#else
    ASSERT(INUMP(y),y,ARG2,s_lessp);
#endif
    if ((long)x >= (long)y) return BOOL_F;
    if NULLP(args) return BOOL_T;
    x = y;
    y = CAR(args);
    args = CDR(args);
  }
}
SCM greaterp(x,y,args)
SCM x,y,args;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_grp);
    for(;;) {
do_flt:
      if INUMP(y) {
	if (REALPART(x) <= ((double)INUM(y))) return BOOL_F;
	if NULLP(args) return BOOL_T;
	x = y;
	y = CAR(args);
	args = CDR(args);
	goto do_int;
      }
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_grp);
      if (REALPART(x) <= REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
    }
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_grp);
#endif
  for(;;) {
#ifdef FLOATS
do_int:
    if NINUMP(y) {
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_grp);
      if (((double)INUM(x)) <= REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
      goto do_flt;
    }
#else
    ASSERT(INUMP(y),y,ARG2,s_grp);
#endif
    if ((long)x <= (long)y) return BOOL_F;
    if NULLP(args) return BOOL_T;
    x = y;
    y = CAR(args);
    args = CDR(args);
  }
}
SCM lesseqp(x,y,args)
SCM x,y,args;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_lesseqp);
    for(;;) {
do_flt:
      if INUMP(y) {
	if (REALPART(x) > ((double)INUM(y))) return BOOL_F;
	if NULLP(args) return BOOL_T;
	x = y;
	y = CAR(args);
	args = CDR(args);
	goto do_int;
      }
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_lesseqp);
      if (REALPART(x) > REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
    }
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_lesseqp);
#endif
  for(;;) {
#ifdef FLOATS
do_int:
    if NINUMP(y) {
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_lesseqp);
      if (((double)INUM(x)) > REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
      goto do_flt;
    }
#else
    ASSERT(INUMP(y),y,ARG2,s_lesseqp);
#endif
    if ((long)x > (long)y) return BOOL_F;
    if NULLP(args) return BOOL_T;
    x = y;
    y = CAR(args);
    args = CDR(args);
  }
}
SCM greatereqp(x,y,args)
SCM x,y,args;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_greqp);
    for(;;) {
do_flt:
      if INUMP(y) {
	if (REALPART(x) < ((double)INUM(y))) return BOOL_F;
	if NULLP(args) return BOOL_T;
	x = y;
	y = CAR(args);
	args = CDR(args);
	goto do_int;
      }
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_greqp);
      if (REALPART(x) < REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
    }
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_greqp);
#endif
  for(;;) {
#ifdef FLOATS
do_int:
    if NINUMP(y) {
      ASSERT(NIMP(y) && REALP(y),y,ARG2,s_greqp);
      if (((double)INUM(x)) < REALPART(y)) return BOOL_F;
      if NULLP(args) return BOOL_T;
      x = y;
      y = CAR(args);
      args = CDR(args);
      goto do_flt;
    }
#else
    ASSERT(INUMP(y),y,ARG2,s_greqp);
#endif
    if ((long)x < (long)y) return BOOL_F;
    if NULLP(args) return BOOL_T;
    x = y;
    y = CAR(args);
    args = CDR(args);
  }
}

SCM zerop(z)
SCM z;
{
#ifdef FLOATS
  if NINUMP(z) {
    ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_zerop);
    return (z == flo0) ? BOOL_T : BOOL_F;
  }
#else
  ASSERT(INUMP(z),z,ARG1,s_zerop);
#endif
  return (z==INUM0) ? BOOL_T: BOOL_F;
}
SCM positivep(x)
SCM x;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_positivep);
    return (REALPART(x)>0.0) ? BOOL_T : BOOL_F;    
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_positivep);
#endif
  return (x>INUM0) ? BOOL_T : BOOL_F;
}
SCM negativep(x)
SCM x;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_negativep);
    return (REALPART(x)<0.0) ? BOOL_T : BOOL_F;    
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_negativep);
#endif
  return (x<INUM0) ? BOOL_T : BOOL_F;
}

SCM lmax(x,y)
SCM x,y;
{
#ifdef FLOATS
  if NINUMP(y) {
    if UNBNDP(y) {
      ASSERT(NUMBERP(x),x,ARG1,s_max);
      return x;
    }
    ASSERT(NIMP(y) && REALP(y),y,ARG2,s_max);
    if INUMP(x)
      return (INUM(x)<REALPART(y))?y:makdbl((double)INUM(x),0.0);
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_max);
    return (REALPART(x) < REALPART(y)) ? y : x;
  }
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_max);
    return (REALPART(x)<INUM(y))?makdbl((double)INUM(y),0.0):x;
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_max);
  if NINUMP(y)
    if UNBNDP(y) return x;
    else ASSERT(INUMP(y),y,ARG2,s_max);
#endif
  return ((long)x < (long)y) ? y : x;
}

SCM lmin(x,y)
SCM x,y;
{
#ifdef FLOATS
  if NINUMP(y) {
    if UNBNDP(y) {
      ASSERT(NUMBERP(x),x,ARG1,s_min);
      return x;
    }
    ASSERT(NIMP(y) && REALP(y),y,ARG2,s_min);
    if INUMP(x)
      return (INUM(x)>REALPART(y))?y:makdbl((double)INUM(x),0.0);
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_min);
    return (REALPART(x) > REALPART(y)) ? y : x;
  }
  if NINUMP(x) {
    ASSERT(NIMP(x) && REALP(x),x,ARG1,s_min);
    return (REALPART(x)>INUM(y))?makdbl((double)INUM(y),0.0):x;
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_min);
  if NINUMP(y)
    if UNBNDP(y) return x;
    else ASSERT(INUMP(y),y,ARG2,s_min);
#endif
  return ((long)x > (long)y) ? y : x;
}

SCM sum(x,y)
     SCM x,y;
{
  if UNBNDP(y) {
    if UNBNDP(x) return INUM0;
    ASSERT(NUMBERP(x),x,ARG1,s_sum);
    return x;
  }
#ifdef FLOATS
  if NINUMP(x) {
    double i=0.0;
    ASSERT(NIMP(x) && INEXP(x),x,ARG1,s_sum);
    if INUMP(y) {SCM t=x; x=y; y=t; goto intx;}
    ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_sum);
    if CPLXP(x) i = IMAG(x);
    if CPLXP(y) i += IMAG(y);
    return makdbl(REALPART(x) + REALPART(y),i);
  }
  if NINUMP(y) {
    ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_sum);
  intx:
    return makdbl(INUM(x)+REALPART(y),CPLXP(y)?IMAG(y):0.0);
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_sum);
  ASSERT(INUMP(y),y,ARG2,s_sum);
#endif
  {
    long z;
    z = INUM(x)+INUM(y);
    y = MAKINUM(z);
    ASSERT(INUM(y) == z,y,OVFLOW,s_sum);
    return y;
  }
}
SCM difference(x,y)
SCM x,y;
{
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x),x,ARG1,s_difference);
    if UNBNDP(y) {
      ASSERT(INEXP(x),x,ARG1,s_difference);
      return makdbl(-REALPART(x),CPLXP(x)?-IMAG(x):0.0);
    }
    if INUMP(y) return sum(x,MAKINUM(-INUM(y)));
    ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_difference);
    if CPLXP(x)
      if CPLXP(y)
	return makdbl(REAL(x)-REAL(y), IMAG(x)-IMAG(y));
      else
	return makdbl(REAL(x)-REALPART(y), IMAG(x));
    return makdbl(REALPART(x)-REALPART(y), CPLXP(y)?-IMAG(y):0.0);
  }
  if NINUMP(y)
    if UNBNDP(y) {y = x; x = INUM0;}
    else {
      ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_difference);
      return makdbl(INUM(x)-REALPART(y), CPLXP(y)?-IMAG(y):0.0);
    }
#else
  ASSERT(INUMP(x),x,ARG1,s_difference);
  if UNBNDP(y) {y = x; x = INUM0;}
  else ASSERT(INUMP(y),y,ARG2,s_difference);
#endif
  x = INUM(x)-INUM(y);
  y = MAKINUM(x);
  ASSERT(INUM(y) == x,y,OVFLOW,s_difference);
  return y;
}

SCM product(x,y)
     SCM x,y;
{
  if UNBNDP(y) {
    if UNBNDP(x) return MAKINUM(1L);
    ASSERT(NUMBERP(x),x,ARG1,s_product);
    return x;
  }
#ifdef FLOATS
  if NINUMP(x) {
    ASSERT(NIMP(x) && INEXP(x),x,ARG1,s_product);
    if INUMP(y) {SCM t=x; x=y; y=t; goto intx;}
    ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_product);
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
    ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_product);
  intx:
    return makdbl(INUM(x)*REALPART(y), CPLXP(y)?INUM(x)*IMAG(y):0.0);
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_product);
  ASSERT(INUMP(y),y,ARG2,s_product);
#endif
  {
    long i, j, k;
    i = INUM(x);
    if (0 == i) return x;
    j = INUM(y);
    k = i * j;
    y = MAKINUM(k);
    ASSERT((k == INUM(y)) && (k/i == j),y,OVFLOW,s_product);
    return y;
  }
}
SCM divide(x,y)
SCM x,y;
{
#ifdef FLOATS
  if NINUMP(x){
    double d;
    ASSERT(NIMP(x) && INEXP(x),x,ARG1,s_divide);
    if UNBNDP(y) {
      if REALP(x) return makdbl(1.0/REALPART(x),0.0);
      ASSERT(CPLXP(x),x,ARG1,s_divide);
      {
	double r=REAL(x),i=IMAG(x);
	d=r*r+i*i;
	return makdbl(r/d,-i/d);
      }
    }
    if INUMP(y) return makdbl(REALPART(x)/INUM(y),
			      CPLXP(x)?IMAG(x)/INUM(y):0.0);
    ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_divide);
    if CPLXP(y) {
      double r=REAL(y),i=IMAG(y),a=REALPART(x);
      d=r*r+i*i;
      if CPLXP(x)
	return makdbl((a*r+IMAG(x)*i)/d,(IMAG(x)*r-a*i)/d);
      return makdbl((a*r)/d,(-a*i)/d);
    }
    d=REALPART(y);
    return makdbl(REALPART(x)/d, CPLXP(x)?IMAG(x)/d:0.0);
  }
  if NINUMP(y)
    if UNBNDP(y) return makdbl(1.0/INUM(x),0.0);
    else {
      ASSERT(NIMP(y) && INEXP(y),y,ARG2,s_divide);
      if CPLXP(y) {
	double r=REAL(y),i=IMAG(y);
	long a=INUM(x);
	double d=r*r+i*i;
	if CPLXP(x)
	  return makdbl((a*r+IMAG(x)*i)/d,(IMAG(x)*r-a*i)/d);
	return makdbl((a*r)/d,(-a*i)/d);
      }
      return makdbl(INUM(x)/REALPART(y) ,0.0);
    ov: return makdbl(INUM(x)/(double)INUM(y),0.0);
    }
#else
  ASSERT(INUMP(x),x,ARG1,s_divide);
  if UNBNDP(y) {
    ASSERT(((x== MAKINUM(1L)) || (x== MAKINUM(-1L))), x,OVFLOW,s_divide);
    return x;
  ov: wta(y,OVFLOW,s_divide);
  }
  ASSERT(INUMP(y),y,ARG2,s_divide);
#endif
  {
    long z;
    z = INUM(y);
    ASRTGO(z && !(INUM(x)%z),ov);
    z = INUM(x)/z;
    y = MAKINUM(z);
    ASRTGO(INUM(y) == z,ov);
    return y;
  }
}
#ifdef FLOATS
static char s_exp[]="exp",s_log[]="log";
SCM lexp(z)
     SCM z;
{
  if NINUMP(z) {
    ASSERT(NIMP(z),z,ARG1,s_exp);
    if REALP(z)
      return makdbl(exp(REALPART(z)),0.0);
    ASSERT(CPLXP(z),z,ARG1,s_exp);
    {
      double m=exp(REAL(z));
      return makdbl(m*cos(IMAG(z)),m*sin(IMAG(z)));
    }
  }
  return makdbl(exp((double)INUM(z)),0.0);
}
SCM llog(z)
     SCM z;
{
  if NINUMP(z) {
    ASSERT(NIMP(z),z,ARG1,s_log);
    if REALP(z)
      if (REALPART(z)>0.0) return makdbl(log(REALPART(z)),0.0);
      else return makdbl(log(-REALPART(z)),atan(-1.0));
    ASSERT(CPLXP(z),z,ARG1,s_log);
    {
      double i=IMAG(z),r=REAL(z);
      return makdbl(log(sqrt(i*i+r*r)),atan2(IMAG(z),REAL(z)));
    }
  }
  if (z>INUM0) return makdbl(log((double)INUM(z)),0.0);
  else return makdbl(log(-(double)INUM(z)),atan(-1.0));
}
#endif
SCM expt(z1,z2)
     SCM z1,z2;
{
#ifdef FLOATS
  double d1;
 tloop:
  if NINUMP(z2) {
    ASSERT(NIMP(z2),z2,ARG2,s_expt);
    if INUMP(z1) d1=(double)INUM(z1);
    else {
      ASSERT(NIMP(z1),z1,ARG1,s_expt);
      if REALP(z1) d1=REALPART(z1);
      else return lexp(product(z2,llog(z1)));
    }
    if REALP(z2) {
      if (d1<0.0) return makdbl(0.0,pow(-d1, REALPART(z2)));
      else return makdbl(pow(d1, REALPART(z2)),0.0);
    }
    ASSERT(CPLXP(z2),z2,ARG2,s_expt);
    if (d1<0.0) {
      double mag=pow(-d1,REAL(z2));
      double l=IMAG(z2)*log(-d1);
      return makdbl(mag*sin(l),mag*cos(l));
    }
    else {
      double mag=pow(d1,REAL(z2));
      double l=IMAG(z2)*log(d1);
      return makdbl(mag*cos(l),mag*sin(l));
    }
  }
#else
 tloop:
  ASSERT(INUMP(z2),z2,ARG2,s_expt);
  ASSERT(INUMP(z1),z1,ARG1,s_expt);
#endif
  if (z2<INUM0) {
    z2=MAKINUM(-INUM(z2));
    z1=divide(z1,UNDEFINED);
    goto tloop;
  }
  {
    SCM acc=MAKINUM(1L);
  ipow_by_squaring:
    if (INUM0==z2) return acc;
    else if (MAKINUM(1L)==z2) return product(acc, z1);
    if (INUM(z2) & 1) acc = product(acc, z1);
    z1 = product(z1, z1);
    z2 = MAKINUM(INUM(z2)/2);
    goto ipow_by_squaring;
  }
}

#ifdef FLOATS
double ltrunc(x)
     double x;
{
  if (x<0.0) return -floor(-x);
  return floor(x);
}
double round(x)
     double x;
{
  return floor(x+0.5);
}
SCM makrect(x,y)
     SCM x,y;
{
  ASSERT(NIMP(x) && REALP(x),x,ARG1,s_makrect);
  ASSERT(NIMP(y) && REALP(y),y,ARG2,s_makrect);
  return makdbl(REALPART(x), REALPART(y));
}
SCM makpolar(x,y)
     SCM x,y;
{
  double s,e;
  ASSERT(NIMP(x) && REALP(x),x,ARG1,s_makpolar);
  ASSERT(NIMP(y) && REALP(y),y,ARG2,s_makpolar);
  s=REALPART(x);
  e=REALPART(y);
  return makdbl(s*cos(e),s*sin(e));
}
SCM real_part(z)
     SCM z;
{
  if NINUMP(z) {
    ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_real_part);
    if CPLXP(z) return makdbl(REAL(z),0.0);
  }
  return z;
}
SCM imag_part(z)
     SCM z;
{
  if INUMP(z) return INUM0;
  ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_imag_part);
  if CPLXP(z) return makdbl(IMAG(z),0.0);
  return flo0;
}
SCM magnitude(z)
     SCM z;
{
  if INUMP(z) return absval(z);
  ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_magnitude);
  if CPLXP(z)
    {
      double i=IMAG(z),r=REAL(z);
      return makdbl(sqrt(i*i+r*r),0.0);
    }
  return makdbl(fabs(REALPART(z)),0.0);
}
SCM angle(z)
     SCM z;
{
  if INUMP(z) return MAKINUM(1L);
  ASSERT(NIMP(z) && INEXP(z),z,ARG1,s_angle);
  if CPLXP(z) return makdbl(atan2(IMAG(z),REAL(z)),0.0);
  return makdbl(1.0,0.0);
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
  ASSERT(NIMP(z) && REALP(z),z,ARG1,s_in2ex);
  return MAKINUM((long)floor(REALPART(z)+0.5));
}
#else
static char s_trunc[]="truncate";
SCM numident(x)
SCM x;
{
	ASSERT(INUMP(x),x,ARG1,s_trunc);
	return x;
}
#endif /* FLOATS */

sizet iint2str(num,rad,p)
     long num;
     int rad;
     char *p;
{
  sizet j;
  register int i=1,d;
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

#ifdef FLOATS
SCM istr2flo(str,len)
     char *str;
     long len;
{
  char *p = str;
  int c,j=0,prec=0,point= -999;
  double r=0.0,n=0.0;		/* r is real part; n is current part */
 lp:
  if (len > 1)
    if ((p[1]=='i') || (p[1]=='I')) {
      if (len!=2) return BOOL_F;
      switch (p[0]) {
      case '-': return makdbl(r,-1.0);
      case '+': return makdbl(r,1.0);
      default: return BOOL_F;
      }
    }
  if (len > 0)
    switch (p[0]) {
    case '-': case '+': j++;
    default:;
    }
  while(j < len)
    switch(c = p[j++]) {
    case '.':
      if (len == 1) return BOOL_F;
      if (point> -900) return BOOL_F;
      point = 0;
      continue;
    case 'e': case 'E': case 'd': case 'D': case 'l': case 'L':
    case 's': case 'S': case 'f': case 'F':
      prec=2;
      {
	int xpo=0,sgn=1;
	if ((len-j) > 1) switch (p[j]) {
	case '-': sgn= -1;
	case '+': j++;
	default:;
	}
	while(j < len) switch(c = p[j++]) {
	case DIGITS: xpo = xpo * 10 + c - '0'; continue;
	case '+': case '-': case 'i': case 'I': j--; goto out;
	default: return BOOL_F;
	}
      out:
	point=((point< -900)?0:point)-xpo*sgn;
	if (point<0) for(;point;point++) n*=10.0;
      outq: continue;
      }
    case '/': {
      int xpo=0;
      if (point >= -900) return BOOL_F;
      while(j < len) {
	switch(c = p[j++]) {
	case DIGITS: xpo = xpo * 10 + c - '0'; continue;
	default: return BOOL_F;
	case '+': case '-': case 'i': case 'I': j--;
	}
	break;
      }
      if (!xpo) return BOOL_F;
      n /= xpo;
      goto outq;
    }
    case '+': case '-':
      if (point>0) while(point--) n/=10.0;
      r=(p[0]=='-')?-n:n;n=0.0;point= -999;prec=3;
      p += --j;len -= j;j = 0;
      goto lp;
    case 'i': case 'I':
      if (j!=len) return BOOL_F;
      if (point>0) while(point--) n/=10.0;
      return makdbl(r,(p[0]=='-')?-n:n);
    case '#': c = '0';
    case DIGITS:
      point++;
      n = n * 10.0 + c - '0';
      continue;
    default: return BOOL_F;
    }
  if (point>0) while(point--) n/=10.0;
  if (p[0]=='-') n = -n;
  switch (prec) {
  default:
  case 2: return makdbl(n,0.0);
  case 3: return BOOL_F;
  }
}
#endif /* FLOATS */

SCM number2string(x,radix)
SCM x,radix;
{
  if UNBNDP(radix) radix=MAKINUM(10L);
  else ASSERT(INUMP(radix),radix,ARG2,s_number2string);
#ifdef FLOATS
  if NINUMP(x) {
    char num_buf[FLOBUFLEN];
    ASSERT(NIMP(x) && INEXP(x),x,ARG1,s_number2string);
    return makfromstr(num_buf,iflo2str(x,num_buf));
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_number2string);
#endif
  {
    char num_buf[INTBUFLEN];
    return makfromstr(num_buf,iint2str(INUM(x),(int)INUM(radix),num_buf));
  }
}

SCM istr2int(str,len,radix)
char *str;
long len;
long radix;
{
  SCM res;
  register char *p = str;
  register int c,rad = radix,i = 0;
  register long n = 0;
  if ((len) > 1) switch (p[0]) {
  case '-': case '+': i++;
  default:;}
  while(i < len) switch(c = p[i++]) {
  case DIGITS:
    c = c - '0';
    goto accumulate;
  case 'A': case 'B': case 'C': case 'D': case 'E': case 'F':
    c = c-'A'+10;
    goto accumulate;
  case 'a': case 'b': case 'c': case 'd': case 'e': case 'f':
    c = c-'a'+10;
  accumulate:
    if ((c<0)||(c>=rad)) return BOOL_F;
    res = n;
    n = n * rad - c;
    if ((n + c)/rad != res) return BOOL_F;
    continue;
  default: return BOOL_F;}
  if (p[0]!='-') n = -n;
  res = MAKINUM(n);
  if (INUM(res) != n) return BOOL_F;
  return res;
}
SCM istring2number(str,len,radix)
char *str;
long len;
long radix;
{
  char ex = 0;
  int i = 0;
  switch ((int)len) {
  case 0: return BOOL_F;
  case 1: switch (str[0]) {
  case '-': case '+': return BOOL_F;
  default:;}
  default:;}
  while (((len-i) > 2) && str[i] == '#' && ++i) switch (str[i++]) {
  case 'b': case 'B':
    radix = 2;
    break;
  case 'o': case 'O':
    radix = 8;
    break;
  case 'd': case 'D':
    radix = 10;
    break;
  case 'x': case 'X':
    radix = 16;
    break;
  case 'i': case 'I':
    ex = 2;
    break;
  case 'e': case 'E':
    ex = 1;
  }
  switch (ex) {
  case 1: return istr2int(&str[i],len-i,radix);
  case 0: {
	  SCM res=istr2int(&str[i],len-i,radix);
	  if ((res!=BOOL_F) || (radix!=10)) return res;
  }
#ifdef FLOATS
  case 2: return istr2flo(&str[i],len-i);
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

char s_getenv[]="getenv";
char s_system[]="system";

SCM lsystem(cmd)
SCM cmd;
{
	ASSERT(NIMP(cmd) && STRINGP(cmd),cmd,ARG1,s_system);
	ignore_signals();
#ifdef AZTEC_C
	cmd = MAKINUM(Execute(CHARS(cmd),0,0));
#else
	cmd = MAKINUM(system(CHARS(cmd)));
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
	return makfromstr(val, strlen(val));
}
SCM softtype()
{
  return
#ifdef nosve
        intern("nosve", 5);
#endif
#ifdef MSDOS
	intern("msdos", sizeof "msdos" -1);
#endif
#ifdef vms
	intern("vms", sizeof "vms" -1);
#endif
#ifdef unix
	intern("unix", sizeof "unix" -1);
#endif
#ifdef MWC
	intern("coherent", sizeof "coherent" -1);
#endif
#ifdef THINK_C
	intern("thinkc", (sizet)(sizeof "thinkc" -1));
#endif
#ifdef AMIGA
	intern("amiga", (sizet)(sizeof "amiga" -1));
#endif
#ifdef atarist
	intern("atarist", (sizet)(sizeof "atarist" -1));
#endif
}

#ifdef vms
#include <descrip.h>
#include <ssdef.h>
static char s_ed[]="ed";
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

static iproc subr0s[]={
	{"software-type",softtype},
#ifdef vms
	{"vms-debug",vms_debug},
#endif
	{0,0}};

static iproc subr1s[]={
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
	{s_exp,lexp},
	{s_log,llog},
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

static iproc asubrs[]={
	{s_max,lmax},
	{s_min,lmin},
	{s_sum,sum},
	{s_product,product},
	{0,0}};

static iproc subr2s[]={
	{s_expt,expt},
#ifdef FLOATS
	{s_makrect,makrect},
	{s_makpolar,makpolar},
	{"eqv?",eqv},
	{s_memv,memv},
	{s_assv,assv},
#else
	{"eqv?",eq},
	{"memv",memq},
	{"assv",assq},
#endif
	{s_list_tail,list_tail},
#ifndef PURE_FUNCTIONAL
	{s_ve_fill,vector_fill},
	{s_st_fill,string_fill},
#endif
	{0,0}};

static iproc subr2os[]={
	{s_difference,difference},
	{s_divide,divide},
	{s_str2number,string2number},
	{s_number2string,number2string},
	{0,0}};

static iproc lsubr2s[]={
  {s_eqp,eqp},
  {s_lessp,lessp},
  {s_grp,greaterp},
  {s_lesseqp,lesseqp},
  {s_greqp,greatereqp},
  {0,0}};

#ifdef FLOATS
static dblproc cxrs[] = {
	{"floor",floor},
	{"ceiling",ceil},
	{"truncate",ltrunc},
	{"round",round},
	{"sin",sin},
	{"cos",cos},
	{"tan",tan},
	{"asin",asin},
	{"acos",acos},
	{"atan",atan},
	{"sqrt",sqrt},
	{"exact->inexact",floident},
	{0,0}};
#endif

void init_scl()
{
#ifdef FLOATS
  init_iprocs(cxrs, tc7_cxr);
#endif /* FLOATS */
  init_iprocs(subr0s, tc7_subr_0);
  init_iprocs(subr1s,tc7_subr_1);
  init_iprocs(subr2os,tc7_subr_2o);
  init_iprocs(subr2s,tc7_subr_2);
  init_iprocs(asubrs, tc7_asubr);
  init_iprocs(lsubr2s,tc7_lsubr_2);
}
