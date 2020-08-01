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

#include <ctype.h>
#include "scm.h"

#define	s_length (s_st_length+7)
#define s_append (s_st_append+7)

char	s_make_string[] = "make-string";
char	s_list[] = "list";

static char	s_setcar[] = "set-car!", s_setcdr[] = "set-cdr!",
	s_reverse[] = "reverse", s_list_ref[] = "list-ref";
static char	s_memq[] = "memq",s_member[] = "member",
	s_assq[] = "assq",s_assoc[] = "assoc";
static char	s_symbol2string[] = "symbol->string",
	s_str2symbol[] = "string->symbol";
extern char s_inexactp[];
#define s_exactp (s_inexactp+2)
static char	s_oddp[] = "odd?",s_evenp[] = "even?";
static char	s_abs[] = "abs", s_quotient[] = "quotient",
	s_remainder[] = "remainder",s_modulo[] = "modulo";
static char	s_gcd[] = "gcd";

static char s_logand[] = "logand", s_lognot[] = "lognot",
	    s_logior[] = "logior", s_logxor[] = "logxor",
	    s_ash[] = "ash", s_logcount[] = "logcount",
	    s_intlength[] = "integer-length", s_intexpt[] = "integer-expt",
	    s_bitextract[] = "bit-extract";

static char s_ci_eq[] = "char-ci=?",
	s_ch_lessp[] = "char<?", s_ch_leqp[] = "char<=?",
	s_ci_lessp[] = "char-ci<?", s_ci_leqp[] = "char-ci<=?",
	s_ch_grp[] = "char>?", s_ch_geqp[] = "char>=?",
	s_ci_grp[] = "char-ci>?", s_ci_geqp[] = "char-ci>=?";
static char	s_ch_alphap[] = "char-alphabetic?",
	s_ch_nump[] = "char-numeric?",
	s_ch_whitep[] = "char-whitespace?",
	s_ch_upperp[] = "char-upper-case?",
	s_ch_lowerp[] = "char-lower-case?";
static char	s_char2int[] = "char->integer",s_int2char[] = "integer->char",
	s_ch_upcase[] = "char-upcase",s_ch_downcase[] = "char-downcase";

static char	s_st_length[] = "string-length",
	s_st_ref[] = "string-ref",s_st_set[] = "string-set!";
static char	s_st_equal[] = "string=?",s_stci_equal[] = "string-ci=?",
	s_st_lessp[] = "string<?",s_stci_lessp[] = "string-ci<?";
static char	s_substring[] = "substring",s_st_append[] = "string-append";

static char	s_ve_length[] = "vector-length",
	s_ve_ref[] = "vector-ref",s_ve_set[] = "vector-set!";

SCM lnot(x)
SCM x;
{
	return FALSEP(x) ? BOOL_T : BOOL_F;
}
SCM booleanp(obj)
SCM obj;
{
	if (BOOL_F==obj) return BOOL_T;
	if (BOOL_T==obj) return BOOL_T;
	return BOOL_F;
}
SCM eq(x,y)
SCM x,y;
{
	if (x==y) return BOOL_T;
	else return BOOL_F;
}

SCM consp(x)
SCM x;
{
	if IMP(x) return BOOL_F;
	return CONSP(x) ? BOOL_T : BOOL_F;
}
SCM setcar(pair,value)
SCM pair, value;
{
	ASSERT(NIMP(pair) && CONSP(pair),pair,ARG1,s_setcar);
	CAR(pair) = value;
	return UNSPECIFIED;
}
SCM setcdr(pair,value)
SCM pair, value;
{
	ASSERT(NIMP(pair) && CONSP(pair),pair,ARG1,s_setcdr);
	CDR(pair) = value;
	return UNSPECIFIED;
}
SCM nullp(x)
SCM x;
{
	return NULLP(x) ? BOOL_T : BOOL_F;
}
long ilength(sx)
SCM sx;
{
	register long i = 0;
	register SCM x = sx;
	do {
		if IMP(x) return NULLP(x) ? i : -1;
		if NCONSP(x) return -1;
		x = CDR(x);
		i++;
		if IMP(x) return NULLP(x) ? i : -1;
		if NCONSP(x) return -1;
		x = CDR(x);
		i++;
		sx = CDR(sx);
	}
	while (x != sx);
	return -1;
}
SCM listp(x)
SCM x;
{
	if (ilength(x)<0) return BOOL_F;
	else return BOOL_T;
}
SCM list(objs)
SCM objs;
{
	return objs;
}
SCM length(x)
SCM x;
{
	SCM i = MAKINUM(ilength(x));
	ASSERT(i >= INUM0,x,ARG1,s_length);
	return i;
}
SCM append(args)
SCM args;
{
	SCM res = EOL;
	SCM *lloc = &res, arg;
	if IMP(args) {
		ASSERT(NULLP(args),args,ARG1,s_append);
		return res;
		}
	ASSERT(CONSP(args),args,ARG1,s_append);
	while (1) {
		arg = CAR(args);
		args = CDR(args);
		if IMP(args) {
			*lloc = arg;
			ASSERT(NULLP(args),args,ARG1,s_append);
			return res;
		}
		ASSERT(CONSP(args),args,ARG1,s_append);
		for(;NIMP(arg);arg = CDR(arg)) {
			ASSERT(CONSP(arg),args,ARG1,s_append);
			*lloc = cons(CAR(arg),EOL);
			lloc = &CDR(*lloc);
		}
	}
}
SCM reverse(lst)
SCM lst;
{
	SCM res = EOL;
	SCM p = lst;
	for(;NIMP(p);p = CDR(p)) {
		ASSERT(CONSP(p),lst,ARG1,s_reverse);
		res = cons(CAR(p),res);
	}
	ASSERT(NULLP(p),lst,ARG1,s_reverse);
	return res;
}
SCM list_ref(lst,k)
SCM lst, k;
{
	register long i;
	ASSERT(INUMP(k),k,ARG2,s_list_ref);
	i = INUM(k);
	ASSERT(i >= 0,k,ARG2,s_list_ref);
	while (i-- > 0) {
		ASRTGO(NIMP(lst) && CONSP(lst), erout);
		lst = CDR(lst);
	}
erout:	ASSERT(NIMP(lst) && CONSP(lst),
	       NULLP(lst)?k:lst, NULLP(lst)?OUTOFRANGE:ARG1, s_list_ref);
	return CAR(lst);
}
SCM memq(x,lst)
SCM x,lst;
{
	for(;NIMP(lst);lst = CDR(lst)) {
		ASSERT(CONSP(lst),lst,ARG2,s_memq);
		if (CAR(lst)==x) return lst;
	}
	ASSERT(NULLP(lst),lst,ARG2,s_memq);
	return BOOL_F;
}
SCM member(x,lst)
SCM x,lst;
{
	for(;NIMP(lst);lst = CDR(lst)) {
		ASSERT(CONSP(lst),lst,ARG2,s_member);
		if NFALSEP(equal(CAR(lst),x)) return lst;
	}
	ASSERT(NULLP(lst),lst,ARG2,s_member);
	return BOOL_F;
}
SCM assq(x,alist)
SCM x,alist;
{
	SCM tmp;
	for(;NIMP(alist);alist = CDR(alist)) {
		ASSERT(CONSP(alist),alist,ARG2,s_assq);
		tmp = CAR(alist);
		ASSERT(NIMP(tmp) && CONSP(tmp),alist,ARG2,s_assq);
		if (CAR(tmp)==x) return tmp;
	}
	ASSERT(NULLP(alist),alist,ARG2,s_assq);
	return BOOL_F;
}
SCM assoc(x,alist)
SCM x,alist;
{
	SCM tmp;
	for(;NIMP(alist);alist = CDR(alist)) {
		ASSERT(CONSP(alist),alist,ARG2,s_assoc);
		tmp = CAR(alist);
		ASSERT(NIMP(tmp) && CONSP(tmp),alist,ARG2,s_assoc);
		if NFALSEP(equal(CAR(tmp),x)) return tmp;
	}
	ASSERT(NULLP(alist),alist,ARG2,s_assoc);
	return BOOL_F;
}

SCM symbolp(x)
SCM x;
{
	if IMP(x) return BOOL_F;
	return SYMBOLP(x) ? BOOL_T : BOOL_F;
}
SCM symbol2string(s)
SCM s;
{
	ASSERT(NIMP(s) && SYMBOLP(s),s,ARG1,s_symbol2string);
	return makfromstr(CHARS(s), (sizet)LENGTH(s));
}
SCM string2symbol(s)
SCM s;
{
	ASSERT(NIMP(s) && STRINGP(s),s,ARG1,s_str2symbol);
	s = intern(CHARS(s),(sizet)LENGTH(s));
	return CAR(s);
}

SCM exactp(x)
SCM x;
{
	if INUMP(x) return BOOL_T;
#ifdef BIGDIG
	if (NIMP(x) && BIGP(x)) return BOOL_T;
#endif
	return BOOL_F;
}
SCM oddp(n)
SCM n;
{
#ifdef BIGDIG
	if NINUMP(n) {
	  ASSERT(NIMP(n) && BIGP(n),n,ARG1,s_oddp);
	  return (1 & BDIGITS(n)[0]) ? BOOL_T : BOOL_F;
	}
#else
	ASSERT(INUMP(n),n,ARG1,s_oddp);
#endif
	return (4 & (int)n) ? BOOL_T : BOOL_F;
}
SCM evenp(n)
SCM n;
{
#ifdef BIGDIG
	if NINUMP(n) {
	  ASSERT(NIMP(n) && BIGP(n),n,ARG1,s_evenp);
	  return (1 & BDIGITS(n)[0]) ? BOOL_F : BOOL_T;
	}
#else
	ASSERT(INUMP(n),n,ARG1,s_evenp);
#endif
	return (4 & (int)n) ? BOOL_F : BOOL_T;
}
SCM absval(x)
SCM x;
{
#ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_abs);
    if (TYP16(x)==tc16_bigpos) return x;
    return copybig(x, 0);
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_abs);
#endif
  if (INUM(x) >= 0) return x;
  x = -INUM(x);
  if (!POSFIXABLE(x))
#ifdef BIGDIG
    return long2big(x);
#else
    wta(MAKINUM(-x), (char *)OVFLOW, s_abs);
#endif
  return MAKINUM(x);
}
SCM lquotient(x,y)
SCM x,y;
{
  register long z;
#ifdef BIGDIG
  if NINUMP(x) {
    long w;
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_quotient);
    if NINUMP(y) {
      ASRTGO(NIMP(y) && BIGP(y),bady);
      return divbigbig(BDIGITS(x), NUMDIGS(x), BDIGITS(y), NUMDIGS(y),
		       BIGSIGN(x) ^ BIGSIGN(y), 2);
    }
    z = INUM(y);
    ASRTGO(z,ov);
    if (1==z) return x;
    if (z < 0) z = -z;
    if (z < BIGRAD) {
      w = copybig(x, BIGSIGN(x) ? (y>0) : (y<0));
      divbigdig(BDIGITS(w), NUMDIGS(w), (BIGDIG)z);
      return normbig(w);
    }
#ifndef DIGSTOOBIG
    w = pseudolong(z);
    return divbigbig(BDIGITS(x), NUMDIGS(x), &w, DIGSPERLONG,
		     BIGSIGN(x) ? (y>0) : (y<0), 2);
#else
    { BIGDIG zdigs[DIGSPERLONG];
      return divbigbig(BDIGITS(x), NUMDIGS(x), zdigs, DIGSPERLONG,
		       BIGSIGN(x) ? (y>0) : (y<0), 2);
    }
#endif
  }
  if NINUMP(y) {
# ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_quotient);
# endif
    return INUM0;
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_quotient);
  ASSERT(INUMP(y),y,ARG2,s_quotient);
#endif
  if ((z = INUM(y))==0)
  ov: wta(y, (char *)OVFLOW, s_quotient);
  z = INUM(x)/z;
#ifdef BADIVSGNS
  {
#if (__TURBOC__==1)
    long t = ((y<0) ? -INUM(x) : INUM(x))%INUM(y);
#else
    long t = INUM(x)%INUM(y);
#endif
    if (t==0) ;
    else if (t < 0)
      if (x < 0) ;
      else z--;
    else if (x < 0) z++;
  }
#endif
  if (!FIXABLE(z))
#ifdef BIGDIG
    return long2big(z);
#else
  wta(x,(char *)OVFLOW,s_quotient);
#endif
  return MAKINUM(z);
}
SCM lremainder(x,y)
SCM x,y;
{
  register long z;
#ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_remainder);
    if NINUMP(y) {
      ASRTGO(NIMP(y) && BIGP(y),bady);
      return divbigbig(BDIGITS(x), NUMDIGS(x), BDIGITS(y), NUMDIGS(y),
		       BIGSIGN(x), 0);
    }
    if (!(z = INUM(y))) goto ov;
    return divbigint(x, z, BIGSIGN(x), 0);
  }
  if NINUMP(y) {
# ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_remainder);
# endif
    return x;
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_remainder);
  ASSERT(INUMP(y),y,ARG2,s_remainder);
#endif
  if (!(z = INUM(y)))
  ov: wta(y,(char *)OVFLOW,s_remainder);
#if (__TURBOC__==1)
  if (z < 0) z = -z;
#endif
  z = INUM(x)%z;
#ifdef BADIVSGNS
  if (!z) ;
  else if (z < 0)
	  if (x < 0) ;
	  else z += INUM(y);
  else if (x < 0) z -= INUM(y);
#endif
  return MAKINUM(z);
}
SCM modulo(x,y)
SCM x,y;
{
  register long yy, z;
#ifdef BIGDIG
  if NINUMP(x) {
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_modulo);
    if NINUMP(y) {
      ASRTGO(NIMP(y) && BIGP(y),bady);
      return divbigbig(BDIGITS(x), NUMDIGS(x), BDIGITS(y), NUMDIGS(y),
		       BIGSIGN(y), (BIGSIGN(x) ^ BIGSIGN(y)) ? 1 : 0);
    }
    if (!(z = INUM(y))) goto ov;
    return divbigint(x, z, y < 0, (BIGSIGN(x) ? (y > 0) : (y < 0)) ? 1 : 0);
  }
  if NINUMP(y) {
# ifndef RECKLESS
    if (!(NIMP(y) && BIGP(y)))
    bady: wta(y,(char *)ARG2,s_modulo);
# endif
    return (BIGSIGN(y) ? (x>0) : (x<0)) ? sum(x,y) : x;
  }
#else
  ASSERT(INUMP(x),x,ARG1,s_modulo);
  ASSERT(INUMP(y),y,ARG2,s_modulo);
#endif
  if (!(yy = INUM(y)))
  ov: wta(y,(char *)OVFLOW,s_modulo);
#if (__TURBOC__==1)
  z = INUM(x);
  z = ((yy<0) ? -z : z)%yy;
#else
  z = INUM(x)%yy;
#endif
  return MAKINUM(((yy<0) ? (z>0) : (z<0)) ? z+yy : z);
}

SCM lgcd(x,y)
SCM x,y;
{
  register long u,v,k,t;
 tailrec:
  if UNBNDP(y) return UNBNDP(x) ? INUM0 : x;
#ifdef BIGDIG
  if NINUMP(x) {
    big_gcd:
    ASSERT(NIMP(x) && BIGP(x),x,ARG1,s_gcd);
    if BIGSIGN(x) x = copybig(x,0);
  newy:
    if NINUMP(y) {
      ASSERT(NIMP(y) && BIGP(y),y,ARG2,s_gcd);
      if BIGSIGN(y) y = copybig(y,0);
      switch (bigcomp(x,y)) {
      case -1:
      swaprec: t = lremainder(x,y); x = y; y = t; goto tailrec;
      case  0: return x;
      case  1: y = lremainder(y,x); goto newy;
      }
      /* instead of the switch, we could just return lgcd(y,modulo(x,y)); */
    }
    if (INUM0==y) return x; goto swaprec;
  }
  if NINUMP(y) { t=x; x=y; y=t; goto big_gcd;}
#else
  ASSERT(INUMP(x),x,ARG1,s_gcd);
  ASSERT(INUMP(y),y,ARG2,s_gcd);
#endif
  u = INUM(x);
  if (u<0) u = -u;
  v = INUM(y);
  if (v<0) v = -v;
  else if (0==v) goto getout;
  if (0==u) {u = v; goto getout;}
  for (k = 1;!(1 & ((int)u|(int)v));k <<= 1,u >>= 1,v >>= 1);
  if (1 & (int)u) t = -v;
  else {
    t = u;
b3:
    t = SRS(t,1);
  }
  if (!(1 & (int)t)) goto b3;
  if (t>0) u = t;
  else v = -t;
  if ((t = u-v)) goto b3;
  u = u*k;
getout:
  if (!POSFIXABLE(u))
#ifdef BIGDIG
    return long2big(u);
#else
    wta(x, (char *)OVFLOW, s_gcd);
#endif
  return MAKINUM(u);
}
SCM llcm(n1,n2)
SCM n1,n2;
{
  SCM d;
  if UNBNDP(n2) {
    n2 = MAKINUM(1L);
    if UNBNDP(n1) return n2;
  }
  d = lgcd(n1,n2);
  if (INUM0==d) return d;
  return absval(product(n1,lquotient(n2,d)));
}

SCM logand(n1,n2)
SCM n1,n2;
{
  ASSERT(INUMP(n1),n1,ARG1,s_logand);
  ASSERT(INUMP(n2),n2,ARG1,s_logand);
  return MAKINUM(INUM(n1) & INUM(n2));
}

SCM logior(n1,n2)
SCM n1,n2;
{
  ASSERT(INUMP(n1),n1,ARG1,s_logior);
  ASSERT(INUMP(n2),n2,ARG1,s_logior);
  return MAKINUM(INUM(n1) | INUM(n2));
}

SCM logxor(n1,n2)
SCM n1,n2;
{
  ASSERT(INUMP(n1),n1,ARG1,s_logxor);
  ASSERT(INUMP(n2),n2,ARG1,s_logxor);
  return MAKINUM(INUM(n1) ^ INUM(n2));
}

SCM lognot(n)
SCM n;
{
  ASSERT(INUMP(n),n,ARG1,s_lognot);
  return difference(MAKINUM(-1L),n);
}

SCM intexpt(z1,z2)
     SCM z1,z2;
{
  SCM acc = MAKINUM(1L);
#ifdef BIGDIG
  if (INUM0==z1 || acc==z1) return z1;
  else if (MAKINUM(-1L)==z1) return BOOL_F==evenp(z2)?z1:acc;
#endif
  ASSERT(INUMP(z2),z2,ARG2,s_intexpt);
  z2 = INUM(z2);
  if (z2 < 0) {
    z2 = -z2;
    z1 = divide(z1, UNDEFINED);
  }
  while(1) {
    if (0==z2) return acc;
    if (1==z2) return product(acc, z1);
    if (z2 & 1) acc = product(acc, z1);
    z1 = product(z1, z1);
    z2 >>= 1;
  }
}
SCM ash(n,cnt)
SCM n,cnt;
{
  SCM res = INUM(n);
  ASSERT(INUMP(cnt),cnt,ARG2,s_ash);
#ifdef BIGDIG
  if(cnt < 0) {
    res = intexpt(MAKINUM(2),MAKINUM(-INUM(cnt)));
    if NFALSEP(negativep(n))
      return sum(MAKINUM(-1L),lquotient(sum(MAKINUM(1L),n),res));
    else return lquotient(n,res);
  }
  else return product(n,intexpt(MAKINUM(2),cnt));
#else
  ASSERT(INUMP(n),n,ARG1,s_ash);
  cnt = INUM(cnt);
  if (cnt < 0) return MAKINUM(SRS(res,-cnt));
  res = MAKINUM(res<<cnt);
  if (INUM(res)>>cnt != INUM(n)) wta(n, (char *)OVFLOW, s_ash);
  return res;
#endif
}

SCM bitextract(n,start,end)
SCM n,start,end;
{
  ASSERT(INUMP(start),start,ARG2,s_bitextract);
  ASSERT(INUMP(end),end,ARG3,s_bitextract);
  start = INUM(start); end = INUM(end);
  ASSERT(end >= start,MAKINUM(end),OUTOFRANGE,s_bitextract);
#ifdef BIGDIG
  if NINUMP(n)
    return
      logand(difference(intexpt(MAKINUM(2),MAKINUM(INUM(end)-INUM(start))),
			MAKINUM(1L)),
	     ash(n,MAKINUM(-start)));
#else
  ASSERT(INUMP(n),n,ARG1,s_bitextract);
#endif
  return MAKINUM((INUM(n)>>start) & ((1L<<(end-start))-1));
}

char logtab[] = {0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4};
SCM logcount(n)
SCM n;
{
  register unsigned long c = 0;
  register long nn;
#ifdef BIGDIG
  if NINUMP(n) {
    sizet i; BIGDIG *ds, d;
    ASSERT(NIMP(n) && BIGP(n),n,ARG1,s_logcount);
    if BIGSIGN(n) return logcount(difference(MAKINUM(-1L),n));
    ds = BDIGITS(n);
    for(i = NUMDIGS(n); i--; )
      for(d = ds[i]; d; d >>= 4) c += logtab[15 & d];
    return MAKINUM(c);
  }
#else
  ASSERT(INUMP(n),n,ARG1,s_logcount);
#endif
  if ((nn = INUM(n)) < 0) nn = -1 - nn;
  for(; nn; nn >>= 4) c += logtab[15 & nn];
  return MAKINUM(c);
}

char ilentab[] = {0, 1, 2, 2, 3, 3, 3, 3, 4, 4, 4, 4, 4, 4, 4, 4};
SCM intlength(n)
SCM n;
{
  register unsigned long c = 0;
  register long nn;
  unsigned int l = 4;
#ifdef BIGDIG
  if NINUMP(n) {
    BIGDIG *ds, d;
    ASSERT(NIMP(n) && BIGP(n),n,ARG1,s_intlength);
    if BIGSIGN(n) return intlength(difference(MAKINUM(-1L),n));
    ds = BDIGITS(n);
    d = ds[c = NUMDIGS(n)-1];
    for(c *= BITSPERDIG; d; d >>= 4) {c += 4; l = ilentab[15 & d];}
    return MAKINUM(c - 4 + l);
  }
#else
  ASSERT(INUMP(n),n,ARG1,s_intlength);
#endif
  if ((nn = INUM(n)) < 0) nn = -1 - nn;
  for(;nn; nn >>= 4) {c += 4; l = ilentab[15 & nn];}
  return MAKINUM(c - 4 + l);
}

SCM charp(x)
SCM x;
{
	return ICHRP(x) ? BOOL_T : BOOL_F;
}
SCM char_lessp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ch_lessp);
	ASSERT(ICHRP(y),y,ARG2,s_ch_lessp);
	return (ICHR(x) < ICHR(y)) ? BOOL_T : BOOL_F;
}
SCM char_leqp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ch_leqp);
	ASSERT(ICHRP(y),y,ARG2,s_ch_leqp);
	return (ICHR(x) <= ICHR(y)) ? BOOL_T : BOOL_F;
}
SCM char_grp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ch_grp);
	ASSERT(ICHRP(y),y,ARG2,s_ch_grp);
	return (ICHR(x) > ICHR(y)) ? BOOL_T : BOOL_F;
}
SCM char_geqp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ch_geqp);
	ASSERT(ICHRP(y),y,ARG2,s_ch_geqp);
	return (ICHR(x) >= ICHR(y)) ? BOOL_T : BOOL_F;
}
SCM chci_eq(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ci_eq);
	ASSERT(ICHRP(y),y,ARG2,s_ci_eq);
	return (upcase[ICHR(x)]==upcase[ICHR(y)]) ? BOOL_T : BOOL_F;
}
SCM chci_lessp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ci_lessp);
	ASSERT(ICHRP(y),y,ARG2,s_ci_lessp);
	return (upcase[ICHR(x)] < upcase[ICHR(y)]) ? BOOL_T : BOOL_F;
}
SCM chci_leqp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ci_leqp);
	ASSERT(ICHRP(y),y,ARG2,s_ci_leqp);
	return (upcase[ICHR(x)] <= upcase[ICHR(y)]) ? BOOL_T : BOOL_F;
}
SCM chci_grp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ci_grp);
	ASSERT(ICHRP(y),y,ARG2,s_ci_grp);
	return (upcase[ICHR(x)] > upcase[ICHR(y)]) ? BOOL_T : BOOL_F;
}
SCM chci_geqp(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ci_geqp);
	ASSERT(ICHRP(y),y,ARG2,s_ci_geqp);
	return (upcase[ICHR(x)] >= upcase[ICHR(y)]) ? BOOL_T : BOOL_F;
}
SCM char_alphap(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_ch_alphap);
	return (isascii(ICHR(chr)) && isalpha(ICHR(chr))) ? BOOL_T : BOOL_F;
}
SCM char_nump(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_ch_nump);
	return (isascii(ICHR(chr)) && isdigit(ICHR(chr))) ? BOOL_T : BOOL_F;
}
SCM char_whitep(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_ch_whitep);
	return (isascii(ICHR(chr)) && isspace(ICHR(chr))) ? BOOL_T : BOOL_F;
}
SCM char_upperp(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_ch_upperp);
	return (isascii(ICHR(chr)) && isupper(ICHR(chr))) ? BOOL_T : BOOL_F;
}
SCM char_lowerp(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_ch_lowerp);
	return (isascii(ICHR(chr)) && islower(ICHR(chr))) ? BOOL_T : BOOL_F;
}
SCM char2int(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_char2int);
	return MAKINUM(ICHR(chr));
}
SCM int2char(n)
SCM n;
{
  ASSERT(INUMP(n),n,ARG1,s_int2char);
  ASSERT((n >= INUM0) && (n < MAKINUM(CHAR_CODE_LIMIT)),
	 n,OUTOFRANGE,s_int2char);
  return MAKICHR(INUM(n));
}
SCM char_upcase(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_ch_upcase);
	return MAKICHR(upcase[ICHR(chr)]);
}
SCM char_downcase(chr)
SCM chr;
{
	ASSERT(ICHRP(chr),chr,ARG1,s_ch_downcase);
	return MAKICHR(downcase[ICHR(chr)]);
}

SCM stringp(x)
SCM x;
{
	if IMP(x) return BOOL_F;
	return STRINGP(x) ? BOOL_T : BOOL_F;
}
SCM string(chrs)
SCM chrs;
{
	SCM res;
	register char *data;
	long i = ilength(chrs);
	ASSERT(i >= 0,chrs,ARG1,s_string);
	res = makstr(i);
	data = CHARS(res);
	for(;NNULLP(chrs);chrs = CDR(chrs)) {
		ASSERT(ICHRP(CAR(chrs)),chrs,ARG1,s_string);
		*data++ = ICHR(CAR(chrs));
	}
	return res;
}
SCM make_string(k,chr)
SCM k,chr;
{
	SCM res;
	register char *dst;
	register long i;
	ASSERT(INUMP(k) && (k >= 0),k,ARG1,s_make_string);
	i = INUM(k);
	res = makstr(i);
	dst = CHARS(res);
	if ICHRP(chr) for(i--;i >= 0;i--) dst[i] = ICHR(chr);
	return res;
}
SCM st_length(str)
SCM str;
{
	ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_st_length);
	return MAKINUM(LENGTH(str));
}
SCM st_ref(str,k)
SCM str,k;
{
	ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_st_ref);
	ASSERT(INUMP(k),k,ARG2,s_st_ref);
	ASSERT(INUM(k) < LENGTH(str) && INUM(k) >= 0,k,OUTOFRANGE,s_st_ref);
	return MAKICHR(CHARS(str)[INUM(k)]);
}
SCM st_set(str,k,chr)
SCM str,k,chr;
{
	ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_st_set);
	ASSERT(INUMP(k),k,ARG2,s_st_set);
	ASSERT(ICHRP(chr),chr,ARG3,s_st_set);
	ASSERT(INUM(k) < LENGTH(str) && INUM(k) >= 0,k,OUTOFRANGE,s_st_set);
	CHARS(str)[INUM(k)] = ICHR(chr);
	return UNSPECIFIED;
}
SCM st_equal(s1, s2)
SCM s1, s2;
{
	register sizet i;
	register char *c1, *c2;
	ASSERT(NIMP(s1) && STRINGP(s1),s1,ARG1,s_st_equal);
	ASSERT(NIMP(s2) && STRINGP(s2),s2,ARG2,s_st_equal);
	i = LENGTH(s2);
	if (LENGTH(s1) != i) return BOOL_F;
	c1 = CHARS(s1);
	c2 = CHARS(s2);
	while(0 != i--) if(*c1++ != *c2++) return BOOL_F;
	return BOOL_T;
}
SCM stci_equal(s1, s2)
SCM s1, s2;
{
	register sizet i;
	register unsigned char *c1, *c2;
	ASSERT(NIMP(s1) && STRINGP(s1),s1,ARG1,s_stci_equal);
	ASSERT(NIMP(s2) && STRINGP(s2),s2,ARG2,s_stci_equal);
	i = LENGTH(s2);
	if (LENGTH(s1) != i) return BOOL_F;
	c1 = UCHARS(s1);
	c2 = UCHARS(s2);
	while(0 != i--) if(upcase[*c1++] != upcase[*c2++]) return BOOL_F;
	return BOOL_T;
}
SCM st_lessp(s1, s2)
SCM s1, s2;
{
	register sizet i,len;
	register unsigned char *c1, *c2;
	register int c;
	ASSERT(NIMP(s1) && STRINGP(s1),s1,ARG1,s_st_lessp);
	ASSERT(NIMP(s2) && STRINGP(s2),s2,ARG2,s_st_lessp);
	len = LENGTH(s1);
	i = LENGTH(s2);
	if (len>i) i = len;
	c1 = UCHARS(s1);
	c2 = UCHARS(s2);
	for(i = 0;i<len;i++) {
		c = (*c1++ - *c2++);
		if (c>0) return BOOL_F;
		if (c<0) return BOOL_T;
	}
	return (LENGTH(s2) != len) ? BOOL_T : BOOL_F;
}
SCM st_leqp(s1, s2)
SCM s1, s2;
{
  return BOOL_NOT(st_lessp(s2, s1));
}
SCM st_grp(s1, s2)
SCM s1, s2;
{
  return st_lessp(s2, s1);
}
SCM st_geqp(s1, s2)
SCM s1, s2;
{
  return BOOL_NOT(st_lessp(s1, s2));
}
SCM stci_lessp(s1, s2)
SCM s1, s2;
{
	register sizet i,len;
	register unsigned char *c1, *c2;
	register int c;
	ASSERT(NIMP(s1) && STRINGP(s1),s1,ARG1,s_stci_lessp);
	ASSERT(NIMP(s2) && STRINGP(s2),s2,ARG2,s_stci_lessp);
	len = LENGTH(s1);
	i = LENGTH(s2);
	if (len>i) i=len;
	c1 = UCHARS(s1);
	c2 = UCHARS(s2);
	for(i = 0;i<len;i++) {
		c = (upcase[*c1++] - upcase[*c2++]);
		if (c>0) return BOOL_F;
		if (c<0) return BOOL_T;
	}
	return (LENGTH(s2) != len) ? BOOL_T : BOOL_F;
}
SCM stci_leqp(s1, s2)
SCM s1, s2;
{
  return BOOL_NOT(stci_lessp(s2, s1));
}
SCM stci_grp(s1, s2)
SCM s1, s2;
{
  return stci_lessp(s2, s1);
}
SCM stci_geqp(s1, s2)
SCM s1, s2;
{
  return BOOL_NOT(stci_lessp(s1, s2));
}
SCM substring(str,start,end)
SCM str,start,end;
{
	long l;
	ASSERT(NIMP(str) && STRINGP(str),str,ARG1,s_substring);
	ASSERT(INUMP(start),start,ARG2,s_substring);
	ASSERT(INUMP(end),end,ARG3,s_substring);
	ASSERT(INUM(start) <= LENGTH(str),start,OUTOFRANGE,s_substring);
	ASSERT(INUM(end) <= LENGTH(str),end,OUTOFRANGE,s_substring);
	l = INUM(end)-INUM(start);
	ASSERT(l >= 0,MAKINUM(l),OUTOFRANGE,s_substring);
	return makfromstr(&CHARS(str)[INUM(start)],(sizet)l);
}
SCM st_append(args)
SCM args;
{
	SCM res;
	register long i = 0;
	register SCM l,s;
	register char *data;
	for(l = args;NIMP(l);) {
		ASSERT(CONSP(l),l,ARG1,s_st_append);
		s = CAR(l);
		ASSERT(NIMP(s) && STRINGP(s),s,ARG1,s_st_append);
		i += LENGTH(s);
		l = CDR(l);
	}
	ASSERT(NULLP(l),args,ARG1,s_st_append);
	res = makstr(i);
	data = CHARS(res);
	for(l = args;NIMP(l);l = CDR(l)) {
		s = CAR(l);
		for(i = 0;i<LENGTH(s);i++) *data++ = CHARS(s)[i];
	}
	return res;
}

SCM vectorp(x)
SCM x;
{
	if IMP(x) return BOOL_F;
	return VECTORP(x) ? BOOL_T : BOOL_F;
}
SCM vector_length(v)
SCM v;
{
	ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_ve_length);
	return MAKINUM(LENGTH(v));
}
SCM vector(l)
SCM l;
{
	SCM res;
	register SCM *data;
	long i = ilength(l);
	ASSERT(i >= 0,l,ARG1,s_vector);
	res = make_vector(MAKINUM(i),UNSPECIFIED);
	data = VELTS(res);
	for(;NIMP(l);l = CDR(l)) *data++ = CAR(l);
	return res;
}
SCM vector_ref(v, k)
SCM v,k;
{
  ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_ve_ref);
  ASSERT(INUMP(k),k,ARG2,s_ve_ref);
  ASSERT((INUM(k) < LENGTH(v)) && (INUM(k) >= 0), k,OUTOFRANGE,s_ve_ref);
  return VELTS(v)[((long) INUM(k))];
}
SCM vector_set(v,k,obj)
SCM v,k,obj;
{
  ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_ve_set);
  ASSERT(INUMP(k),k,ARG2,s_ve_set);
  ASSERT((INUM(k) < LENGTH(v)) && (INUM(k) >= 0),k,OUTOFRANGE,s_ve_set);
  VELTS(v)[((long) INUM(k))] = obj;
  return UNSPECIFIED;
}
char	s_make_vector[] = "make-vector";
SCM make_vector(k,fill)
SCM k,fill;
{
	SCM v;
	register long i;
	register SCM *velts;
	ASSERT(INUMP(k),k,ARG1,s_make_vector);
	if UNBNDP(fill) fill = UNSPECIFIED;
	i = INUM(k);
	NEWCELL(v);
	DEFER_INTS;
	SETCHARS(v,must_malloc(i?(long)(i*sizeof(SCM)):1L,s_vector));
	SETLENGTH(v,i,tc7_vector);
	velts = VELTS(v);
	while(--i >= 0) (velts)[i] = fill;
	ALLOW_INTS;
	return v;
}
#ifdef BIGDIG
char s_bignum[] = "bignum";
SCM mkbig(nlen, sign)
sizet nlen;
int sign;
{
	SCM v = nlen;
	if (((v << 16) >> 16) != nlen)
	  wta(MAKINUM(nlen),(char *)NALLOC,s_bignum);
	NEWCELL(v);
	DEFER_INTS;
	SETCHARS(v,must_malloc((long)(nlen*sizeof(BIGDIG)),s_bignum));
	SETNUMDIGS(v,nlen,sign?tc16_bigneg:tc16_bigpos);
	ALLOW_INTS;
	return v;
}
SCM big2long(b,l)
     SCM b;
     sizet l;
{
  unsigned long num = 0;
  BIGDIG *tmp = BDIGITS(b);
  while (l--) num = BIGUP(num) + tmp[l];
  if (TYP16(b)==tc16_bigpos) {
    if POSFIXABLE(num) return MAKINUM(num);
  }
  else if UNEGFIXABLE(num) return MAKINUM(-num);
  return b;
}
char s_adjbig[] = "adjbig";
SCM adjbig(b,nlen)
     SCM b;
     sizet nlen;
{
  long nsiz = nlen;
  if (((nsiz << 16) >> 16) != nlen) wta(MAKINUM(nsiz),(char *)NALLOC,s_adjbig);
  DEFER_INTS;
  SETCHARS(b,(BIGDIG *)must_realloc((char *)CHARS(b),
				    (long)(NUMDIGS(b)*sizeof(BIGDIG)),
				    (long)(nsiz*sizeof(BIGDIG)), s_adjbig));
  SETNUMDIGS(b,nsiz,TYP16(b));
  ALLOW_INTS;
  return b;
}
SCM normbig(b)
     SCM b;
{
#ifndef _UNICOS  
  sizet nlen = NUMDIGS(b);
#else
  int nlen = NUMDIGS(b);   /* unsigned nlen breaks on Cray when nlen => 0 */
#endif
  BIGDIG *zds = BDIGITS(b);
  while (nlen-- && !zds[nlen]); nlen++;
  if (nlen * BITSPERDIG/CHAR_BIT <= sizeof(SCM))
    if INUMP(b = big2long(b,(sizet)nlen)) return b;
  if (NUMDIGS(b)==nlen) return b;
  return adjbig(b,(sizet)nlen);
}
SCM copybig(b, sign)
     SCM b;
     int sign;
{
  sizet i = NUMDIGS(b);
  SCM ans = mkbig(i, sign);
  BIGDIG *src = BDIGITS(b), *dst = BDIGITS(ans);
  while (i--) dst[i] = src[i];
  return ans;
}
SCM long2big(n)
     long n;
{
  sizet i = 0;
  BIGDIG *digits;
  SCM ans = mkbig(DIGSPERLONG, n<0);
  digits = BDIGITS(ans);
  if (n < 0) n = -n;
  while (i < DIGSPERLONG) {
    digits[i++] = BIGLO(n);
    n = BIGDN(n);
  }
  return ans;
}

int bigcomp(x,y)
     SCM x,y;
{
  int xsign = BIGSIGN(x);
  int ysign = BIGSIGN(y);
  sizet xlen, ylen;
  if (ysign < xsign) return 1;
  if (ysign > xsign) return -1;
  if ((ylen = NUMDIGS(y)) > (xlen = NUMDIGS(x))) return (xsign) ? -1 : 1;
  if (ylen < xlen) return (xsign) ? 1 : -1;
  while(xlen-- && (BDIGITS(y)[xlen]==BDIGITS(x)[xlen]));
  if (-1==xlen) return 0;
  return (BDIGITS(y)[xlen] > BDIGITS(x)[xlen]) ?
    (xsign ? -1 : 1) : (xsign ? 1 : -1);
}

#ifndef DIGSTOOBIG
long pseudolong(x)
    long x;
{
  union {
    long l;
    BIGDIG bd[DIGSPERLONG];
  } p;
  sizet i = 0;
  if (x < 0) x = -x;
  while (i < DIGSPERLONG) {p.bd[i++] = BIGLO(x); x = BIGDN(x);}
/*  p.bd[0] = BIGLO(x); p.bd[1] = BIGDN(x); */
  return p.l;
}
#else
BIGDIG *longdigs(x, digs)
     long x;
     BIGDIG digs[DIGSPERLONG];
{
  sizet i = 0;
  if (x < 0) x = -x;
  while (i < DIGSPERLONG) {digs[i++] = BIGLO(x); x = BIGDN(x);}
  return &digs[0];
}
#endif

SCM addbig(x,nx,xsgn,bigy,sgny)
     BIGDIG *x;
     SCM bigy;
     sizet nx;		/* Assumes nx <= NUMDIGS(bigy) */
     int xsgn, sgny;	/* Assumes xsgn and sgny equal either 0 or 0x0100 */
{
  long num = 0;
  sizet i = 0, ny = NUMDIGS(bigy);
  SCM z = copybig(bigy, BIGSIGN(bigy) ^ sgny);
  BIGDIG *zds = BDIGITS(z);
  if (xsgn ^ BIGSIGN(z)) {
    do {
      num += (long) zds[i] - x[i];
      if (num < 0) {zds[i] = num + BIGRAD; num = -1;}
      else {zds[i] = BIGLO(num); num = 0;}
    } while (++i < nx);
    if (num && nx==ny) {
      num = 1; i = 0;
      CAR(z) ^= 0x0100;
      do {
	num += (BIGRAD-1) - zds[i];
	zds[i++] = BIGLO(num);
	num = BIGDN(num);
      } while (i < ny);
    }
    else while (i < ny) {
      num += zds[i];
      if (num < 0) {zds[i++] = num + BIGRAD; num = -1;}
      else {zds[i++] = BIGLO(num); num = 0;}
    }
  } else {
    do {
      num += (long) zds[i] + x[i];
      zds[i++] = BIGLO(num);
      num = BIGDN(num);
    } while (i < nx);
    if (!num) return z;
    while (i < ny) {
      num += zds[i];
      zds[i++] = BIGLO(num);
      num = BIGDN(num);
      if (!num) return z;
    }
    if (num) {z = adjbig(z,ny+1); BDIGITS(z)[ny] = num; return z;}
  }
  return normbig(z);
}

SCM mulbig(x,nx,y,ny,sgn)
     BIGDIG *x, *y;
     sizet nx, ny;
     int sgn;
{
  sizet i = 0, j = nx + ny;
  unsigned long n = 0;
  SCM z = mkbig(j, sgn);
  BIGDIG *zds = BDIGITS(z);
  while (j--) zds[j] = 0;
  do {
    j = 0;
    if (x[i]) {
      do {
	n += zds[i + j] + ((unsigned long) x[i] * y[j]);
	zds[i + j++] = BIGLO(n);
	n = BIGDN(n);
      } while (j < ny);
      if (n) {zds[i + j] = n; n = 0;}
    }
  } while (++i < nx);
  return normbig(z);
}
unsigned int divbigdig(ds,h,div)
     BIGDIG *ds;
     sizet h;
     BIGDIG div;
{
  register unsigned long t2 = 0;
  while(h--) {
    t2 = BIGUP(t2) + ds[h];
    ds[h] = t2 / div;
    t2 %= div;
  }
  return t2;
}
SCM divbigint(x,z,sgn,mode)
     SCM x;
     long z;
     int sgn,mode;
{
  if (z < 0) z = -z;
  if (z < BIGRAD) {
    register unsigned long t2 = 0;
    register BIGDIG *ds = BDIGITS(x);
    sizet nd = NUMDIGS(x);
    while(nd--) t2 = (BIGUP(t2) + ds[nd]) % z;
    if (mode) t2 = z - t2;
    return MAKINUM(sgn ? -t2 : t2);
  }
  {
#ifndef DIGSTOOBIG
    unsigned long t2 = pseudolong(z);
    return divbigbig(BDIGITS(x), NUMDIGS(x), &t2, DIGSPERLONG, sgn, mode);
#else
    BIGDIG t2[DIGSPERLONG];
    return divbigbig(BDIGITS(x), NUMDIGS(x), t2, DIGSPERLONG, sgn, mode);
#endif
  }
}
SCM divbigbig(x,nx,y,ny,sgn,modes)
     BIGDIG *x, *y;
     sizet nx, ny;
     int sgn, modes;
     /* modes description
	0	remainder
	1	modulo
	2	quotient
	3	quotient but returns 0 if division is not exact. */
{
  sizet i = 0, j = 0;
  long num = 0;
  unsigned long t2 = 0;
  SCM z, newy;
  BIGDIG  d = 0, qhat, *zds, *yds;
  /* algorithm requires nx >= ny */
  if (nx < ny)
    switch (modes) {
    case 0:			/* remainder -- just return x */
      z = mkbig(nx, sgn); zds = BDIGITS(z);
      do {zds[i] = x[i];} while (++i < nx);
      return z;
    case 1:			/* modulo -- return y-x */
      z = mkbig(ny, sgn); zds = BDIGITS(z);
      do {
	num += (long) y[i] - x[i];
	if (num < 0) {zds[i] = num + BIGRAD; num = -1;}
	else {zds[i] = num; num = 0;}
      } while (++i < nx);
      while (i < ny) {
	num += y[i];
	if (num < 0) {zds[i++] = num + BIGRAD; num = -1;}
	else {zds[i++] = num; num = 0;}
      }
      goto doadj;
    case 2: return INUM0;	/* quotient is zero */
    case 3: return 0;		/* the division is not exact */
    }

  z = mkbig(nx==ny ? nx+2 : nx+1, sgn); zds = BDIGITS(z);
  if (nx==ny) zds[nx+1] = 0;
  while(!y[ny-1]) ny--;		/* in case y came in as a psuedolong */
  if (y[ny-1] < (BIGRAD>>1)) {  /* normalize operands */
    d = BIGRAD/(y[ny-1]+1);
    newy = mkbig(ny,0); yds = BDIGITS(newy);
    while(j < ny)
      {t2 += (unsigned long) y[j]*d; yds[j++] = BIGLO(t2); t2 = BIGDN(t2);}
    y = yds; j = 0; t2 = 0;
    while(j < nx)
      {t2 += (unsigned long) x[j]*d; zds[j++] = BIGLO(t2); t2 = BIGDN(t2);}
    zds[j] = t2;
  }
  else {zds[j = nx] = 0; while (j--) zds[j] = x[j];}
  j = nx==ny ? nx+1 : nx;	/* dividend needs more digits than divisor */
  do {				/* loop over digits of quotient */
    if (zds[j]==y[ny-1]) qhat = BIGRAD-1;
    else qhat = (BIGUP(zds[j]) + zds[j-1])/y[ny-1];
    if (!qhat) continue;
    i = 0; num = 0; t2 = 0;
    do {			/* multiply and subtract */
      t2 += (unsigned long) y[i] * qhat;
      num += zds[j - ny + i] - BIGLO(t2);
      if (num < 0) {zds[j - ny + i] = num + BIGRAD; num = -1;}
      else {zds[j - ny + i] = num; num = 0;}
      t2 = BIGDN(t2);
    } while (++i < ny);
    num += zds[j - ny + i] - t2; /* borrow from high digit; don't update */
    while (num) {		/* "add back" required */
      i = 0; num = 0; qhat--;
      do {
	num += (long) zds[j - ny + i] + y[i];
	zds[j - ny + i] = BIGLO(num);
	num = BIGDN(num);
      } while (++i < ny);
      num--;
    }
    if (modes & 2) zds[j] = qhat;
  } while (--j >= ny);
  switch (modes) {
  case 3:			/* check that remainder==0 */
    for(j = ny;j && !zds[j-1];--j) ; if (j) return 0;
  case 2:			/* move quotient down in z */
    j = (nx==ny ? nx+2 : nx+1) - ny;
    for (i = 0;i < j;i++) zds[i] = zds[i+ny];
    ny = i;
    break;
  case 1:			/* subtract for modulo */
    i = 0; num = 0;
    do {num += y[i] - zds[i];
	if (num < 0) {zds[i] = num + BIGRAD; num = -1;}
	else {zds[i] = num; num = 0;}
      } while (++i < ny);
  case 0:			/* just normalize remainder */
    if (d) divbigdig(zds,ny,d);
  }
 doadj:
  for(j = ny;j && !zds[j-1];--j) ;
  if (j * BITSPERDIG <= sizeof(SCM)*CHAR_BIT)
    if INUMP(z = big2long(z,j)) return z;
  return adjbig(z,j);
}
#endif

static iproc cxrs[] = {
	{"car",0}, {"cdr",0},
	{"caar",0}, {"cadr",0}, {"cdar",0}, {"cddr",0},
	{"caaar",0}, {"caadr",0}, {"cadar",0}, {"caddr",0},
	{"cdaar",0}, {"cdadr",0}, {"cddar",0}, {"cdddr",0},
	{"caaaar",0}, {"caaadr",0}, {"caadar",0}, {"caaddr",0},
	{"cadaar",0}, {"cadadr",0}, {"caddar",0}, {"cadddr",0},
	{"cdaaar",0}, {"cdaadr",0}, {"cdadar",0}, {"cdaddr",0},
	{"cddaar",0}, {"cddadr",0}, {"cdddar",0}, {"cddddr",0},
	{0,0}};

static iproc subr1s[] = {
	{"not",lnot},
	{"boolean?",booleanp},
	{"pair?",consp},
	{"null?",nullp},
	{"list?",listp},
	{s_length,length},
	{s_reverse,reverse},
	{"symbol?",symbolp},
	{s_symbol2string,symbol2string},
	{s_str2symbol,string2symbol},
	{s_exactp,exactp},
	{s_oddp,oddp},
	{s_evenp,evenp},
	{s_abs,absval},
	{s_lognot,lognot},
	{s_logcount,logcount},
	{s_intlength,intlength},
	{"char?",charp},
	{s_ch_alphap,char_alphap},
	{s_ch_nump,char_nump},
	{s_ch_whitep,char_whitep},
	{s_ch_upperp,char_upperp},
	{s_ch_lowerp,char_lowerp},
	{s_char2int,char2int},
	{s_int2char,int2char},
	{s_ch_upcase,char_upcase},
	{s_ch_downcase,char_downcase},
	{"string?",stringp},
	{s_st_length,st_length},
	{"vector?",vectorp},
	{s_ve_length,vector_length},
	{"procedure?",procedurep},
	{0,0}};

static char s_acons[] = "acons";
static iproc subr2s[] = {
	{&s_acons[1],cons},
	{s_setcar,setcar},
	{s_setcdr,setcdr},
	{s_list_ref,list_ref},
	{s_memq,memq},
	{s_member,member},
	{s_assq,assq},
	{s_assoc,assoc},
	{s_quotient,lquotient},
	{s_remainder,lremainder},
	{s_modulo,modulo},
	{s_ash,ash},
	{s_intexpt,intexpt},
	{s_st_ref,st_ref},
	{"string<=?",st_leqp},
	{"string-ci<=?",stci_leqp},
	{s_ve_ref,vector_ref},
	{0,0}};

static iproc lsubrs[] = {
	{s_list,list},
	{s_append,append},
	{s_string,string},
	{s_st_append,st_append},
	{s_vector,vector},
	{0,0}};

static iproc subr2os[] = {
	{s_make_string,make_string},
	{s_make_vector,make_vector},
	{0,0}};

static iproc asubrs[] = {
	{s_gcd,lgcd},
	{"lcm",llcm},
	{s_logand,logand},
	{s_logior,logior},
	{s_logxor,logxor},
	{0,0}};

static iproc rpsubrs[] = {
	{"eq?",eq},
	{"equal?",equal},
	{"char=?",eq},
	{s_ch_lessp,char_lessp},
	{s_ci_eq,chci_eq},
	{s_ci_lessp,chci_lessp},
	{s_ch_leqp,char_leqp},
	{s_ci_leqp,chci_leqp},
	{s_ch_grp,char_grp},
	{s_ci_grp,chci_grp},
	{s_ch_geqp,char_geqp},
	{s_ci_geqp,chci_geqp},

	{s_st_equal,st_equal},
	{s_stci_equal,stci_equal},
	{s_st_lessp,st_lessp},
	{s_stci_lessp,stci_lessp},
	{"string>?",st_grp},
	{"string-ci>?",stci_grp},
	{"string>=?",st_geqp},
	{"string-ci>=?",stci_geqp},
	{0,0}};

static iproc subr3s[] = {
	{s_bitextract,bitextract},
	{s_substring,substring},
	{s_acons,acons},
	{s_st_set,st_set},
	{s_ve_set,vector_set},
	{0,0}};

void init_iprocs(subra, type)
     iproc *subra;
     int type;
{
  for(;subra->string; subra++)
    make_subr(subra->string,
	      type,
	      subra->cproc);
}

void init_subrs()
{
  init_iprocs(cxrs, tc7_cxr);
  init_iprocs(subr1s, tc7_subr_1);
  init_iprocs(subr2s, tc7_subr_2);
  init_iprocs(subr2os, tc7_subr_2o);
  init_iprocs(rpsubrs, tc7_rpsubr);
  init_iprocs(lsubrs, tc7_lsubr);
  init_iprocs(asubrs, tc7_asubr);
  init_iprocs(subr3s, tc7_subr_3);
}
