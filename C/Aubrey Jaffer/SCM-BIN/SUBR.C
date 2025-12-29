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

#include <ctype.h>
#include "scm.h"

/* Yasuaki Honda */
/* Think C lacks isascii macro */
#ifdef THINK_C
#define isascii(c)	((unsigned)(c) <= 0x7f)
#endif

char	s_list[]="list", s_vector[]="vector", s_string[]="string";

static char	s_setcar[]="set-car!", s_setcdr[]="set-cdr!";
static char	s_length[]="length", s_append[]="append",
	s_reverse[]="reverse", s_list_ref[]="list-ref";
static char	s_memq[]="memq",s_member[]="member",
	s_assq[]="assq",s_assoc[]="assoc";
static char	s_symbol2string[]="symbol->string",
	s_str2symbol[]="string->symbol";
extern char s_inexactp[];
#define s_exactp (s_inexactp+2)
static char	s_oddp[]="odd?",s_evenp[]="even?";
static char	s_abs[]="abs",
	s_quotient[]="quotient",s_remainder[]="remainder",s_modulo[]="modulo";
static char	s_gcd[]="gcd",s_lcm[]="lcm";

static char	s_ch_lessp[]="char<?",
	s_ch_leqp[]="char<=?",
	s_ci_eq[]="char-ci=?",
	s_ci_lessp[]="char-ci<?",
	s_ci_leqp[]="char-ci<=?";
static char	s_ch_alphap[]="char-alphabetic?",
	s_ch_nump[]="char-numeric?",
	s_ch_whitep[]="char-whitespace?",
	s_ch_upperp[]="char-upper-case?",
	s_ch_lowerp[]="char-lower-case?";
static char	s_char2int[]="char->integer",s_int2char[]="integer->char",
	s_ch_upcase[]="char-upcase",s_ch_downcase[]="char-downcase";

static char	s_st_length[]="string-length", s_make_string[]="make-string",
	s_st_ref[]="string-ref",s_st_set[]="string-set!";
static char	s_st_equal[]="string=?",s_stci_equal[]="string-ci=?",
	s_st_lessp[]="string<?",s_stci_lessp[]="string-ci<?";
static char	s_substring[]="substring",s_st_append[]="string-append";

static char	s_ve_length[]="vector-length",
	s_ve_ref[]="vector-ref",s_ve_set[]="vector-set!";

SCM lnot(x)
SCM x;
{
	return FALSEP(x) ? BOOL_T : BOOL_F;
}
SCM booleanp(obj)
SCM obj;
{
	if (obj == BOOL_F) return BOOL_T;
	if (obj == BOOL_T) return BOOL_T;
	return BOOL_F;
}
SCM eq(x,y)
SCM x,y;
{
	if (x == y) return BOOL_T;
	else return BOOL_F;
}

SCM equal(), st_equal();

SCM vector_equal(x,y)
SCM x,y;
{
	long i;
	for(i=LENGTH(x)-1;i>=0;i--)
		if FALSEP(equal(VELTS(x)[i],VELTS(y)[i])) return BOOL_F;
	return BOOL_T;
}

SCM equal(x,y)
SCM x,y;
{
tailrecurse:
	if (x == y) return BOOL_T;
	if IMP(x) return BOOL_F;
	if IMP(y) return BOOL_F;
	if (CONSP(x) && CONSP(y)) {
		if (BOOL_F == equal(CAR(x),CAR(y))) return BOOL_F;
		x = CDR(x);
		y = CDR(y);
		goto tailrecurse;
	}
	/* this ensures that types and length are the same. */
	if (CAR(x) != CAR(y)) return BOOL_F;
	if STRINGP(x) return st_equal(x,y);
	if VECTORP(x) return vector_equal(x,y);
	if (numberp(x) == BOOL_T) return eqp(x,y,EOL);
	/* Numberp could be bummed by moving this to scl.c */
	return BOOL_F;
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
	register long i=0;
	register SCM x=sx;
	do {
		if IMP(x) return NULLP(x) ? i : -1;
		if NCONSP(x) return -1;
		x = CDR(x);
		i++;
		if IMP(x) return NULLP(x) ? i : -1;
		if NCONSP(x) return -1;
		x = CDR(x);
		i++;
		sx=CDR(sx);
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
	SCM i=MAKINUM(ilength(x));
	ASSERT(i>=INUM0,x,ARG1,s_length);
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
		ASSERT(NIMP(lst) && CONSP(lst),lst,ARG1,s_list_ref);
		lst=CDR(lst);
	}
	ASSERT(NIMP(lst) && CONSP(lst),lst,ARG1,s_list_ref);
	return CAR(lst);
}
SCM memq(x,lst)
SCM x,lst;
{
	for(;NIMP(lst);lst = CDR(lst)) {
		ASSERT(CONSP(lst),lst,ARG2,s_memq);
		if (CAR(lst) == x) return lst;
	}
	ASSERT(NULLP(lst),lst,ARG2,s_memq);
	return BOOL_F;
}
SCM member(x,lst)
SCM x,lst;
{
	for(;NIMP(lst);lst = CDR(lst)) {
		ASSERT(CONSP(lst),lst,ARG2,s_member);
		if (equal(CAR(lst),x) == BOOL_T) return lst;
	}
	ASSERT(NULLP(lst),lst,ARG2,s_member);
	return BOOL_F;
}
SCM assq(x,alist)
SCM x,alist;
{
	SCM tmp;
	for(;NIMP(alist);alist=CDR(alist)) {
		ASSERT(CONSP(alist),alist,ARG2,s_assq);
		tmp = CAR(alist);
		ASSERT(CONSP(tmp),alist,ARG2,s_assq);
		if (CAR(tmp) == x) return tmp;
	}
	ASSERT(NULLP(alist),alist,ARG2,s_assq);
	return BOOL_F;
}
SCM assoc(x,alist)
SCM x,alist;
{
	SCM tmp;
	for(;NIMP(alist);alist=CDR(alist)) {
		ASSERT(CONSP(alist),alist,ARG2,s_assoc);
		tmp = CAR(alist);
		ASSERT(CONSP(tmp),alist,ARG2,s_assoc);
		if (equal(CAR(tmp),x) == BOOL_T) return tmp;
	}
	ASSERT(NULLP(alist),alist,ARG2,s_assoc);
	return BOOL_F;
}

SCM symbolp(x)
SCM x;
{
	if ISYMP(x) return BOOL_T;
	if IMP(x) return BOOL_F;
	return SYMBOLP(x) ? BOOL_T : BOOL_F;
}
SCM symbol2string(s)
SCM s;
{
	if ISYMP(s) return makfromstr(ISYMCHARS(s), strlen(ISYMCHARS(s)));
	ASSERT(NIMP(s) && SYMBOLP(s),s,ARG1,s_symbol2string);
	return NAMESTR(s);
}
SCM string2symbol(s)
SCM s;
{
	ASSERT(NIMP(s) && STRINGP(s),s,ARG1,s_str2symbol);
	return intern(CHARS(s),(sizet)LENGTH(s));
}

SCM exactp(x)
SCM x;
{
	if INUMP(x) return BOOL_T;
	return BOOL_F;
}
SCM oddp(n)
SCM n;
{
	ASSERT(INUMP(n),n,ARG1,s_oddp);
	return (4 & (int)n) ? BOOL_T : BOOL_F;
}
SCM evenp(n)
SCM n;
{
	ASSERT(INUMP(n),n,ARG1,s_evenp);
	return (4 & (int)n) ? BOOL_F : BOOL_T;
}
SCM absval(x)
SCM x;
{
	SCM res;
	register long z = INUM(x);
	ASSERT(INUMP(x),x,ARG1,s_abs);
	if (z<0) z = -z;
	res = MAKINUM(z);
	ASSERT(res>>2 == z,res,OVFLOW,s_abs);
	return res;
}

SCM quotient(x,y)
SCM x,y;
{
	SCM res;
	register long z;
	ASSERT(INUMP(x),x,ARG1,s_quotient);
	ASSERT(INUMP(y),y,ARG2,s_quotient);
	z = INUM(y);
	ASSERT(z,y,OVFLOW,s_quotient);
	z = INUM(x)/z;
#ifdef BADIVSGNS
	{
#if (__TURBOC__ == 1)
		long t = (y<0 ? -INUM(x) : INUM(x))%INUM(y);
#else
		long t = INUM(x)%INUM(y);
#endif
		if (t == 0) ;
		else if (t < 0)
			if (x < 0) ;
			else z--;
		else if (x < 0) z++;
	}
#endif
	res = MAKINUM(z);
	ASSERT(INUM(res) == z,res,OVFLOW,s_quotient);
	return res;
}
SCM lremainder(x,y)
SCM x,y;
{
	register long z;
	ASSERT(INUMP(x),x,ARG1,s_remainder);
	ASSERT(INUMP(y),y,ARG2,s_remainder);
	z = INUM(y);
	ASSERT(z,y,OVFLOW,s_remainder);
#if (__TURBOC__ == 1)
	z = (y<0 ? -INUM(x) : INUM(x))%z;
#else
	z = INUM(x)%z;
#endif
#ifdef BADIVSGNS
	if (z == 0) ;
	else if (z < 0)
		if (x < 0) ;
		else z += INUM(y);
	else if (x < 0) z -= INUM(y);
#endif
	return MAKINUM(z);
}
SCM modulo(n1,n2)
SCM n1,n2;
{
	register long y = INUM(n2),z;
	ASSERT(INUMP(n1),n1,ARG1,s_modulo);
	ASSERT(INUMP(n2),n2,ARG2,s_modulo);
	ASSERT(y,n2,OVFLOW,s_modulo);
#if (__TURBOC__ == 1)
	z = INUM(n1);
	z = (y<0 ? -z : z)%y;
#else
	z = INUM(n1)%y;
#endif
	return MAKINUM(y<0 ? (z>0) ? z+y : z
			   : (z<0) ? z+y : z);
}
SCM lgcd(n1,n2)
SCM n1,n2;
{
	register long u,v,k,t;
	if UNBNDP(n2) return UNBNDP(n1) ? INUM0 : n1;
	ASSERT(INUMP(n1),n1,ARG1,s_gcd);
	ASSERT(INUMP(n2),n2,ARG2,s_gcd);
	u = INUM(n1);
	if (u<0) u = -u;
	v = INUM(n2);
	if (v<0) v = -v;
	else if (0 == v) return MAKINUM(u);
	if (0 == u) return MAKINUM(v);
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
	if (t = u-v) goto b3;
	u = u*k;
	v = MAKINUM(u);
	ASSERT((v>>2) == u,v,OVFLOW,s_gcd);
	return v;
}
SCM llcm(n1,n2)
SCM n1,n2;
{
	SCM res;
	register long q,z;
	long x = INUM(n1);
	if UNBNDP(n2) {
		n2 = MAKINUM(1L);
		if UNBNDP(n1) return n2;
	}
	q = INUM(lgcd(n1,n2));
	if ((x == 0) || (n2 == INUM0)) return INUM0;
	q = INUM(n2)/q;
	z = x*q;
	ASSERT(z/q == x,n1,OVFLOW,s_lcm);
	if (z < 0) z = -z;
	res = MAKINUM(z);
	ASSERT((res>>2) == z,res,OVFLOW,s_lcm);
	return res;
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
SCM chci_eq(x,y)
SCM x,y;
{
	ASSERT(ICHRP(x),x,ARG1,s_ci_eq);
	ASSERT(ICHRP(y),y,ARG2,s_ci_eq);
	return (upcase[ICHR(x)] == upcase[ICHR(y)]) ? BOOL_T : BOOL_F;
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
extern SCM sym_char_code_limit;
SCM int2char(n)
SCM n;
{
  ASSERT(INUMP(n),n,ARG1,s_int2char);
  ASSERT((n>=INUM0) && (n<VCELL(sym_char_code_limit)),
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
	ASSERT(i>=0,chrs,ARG1,s_string);
	if (i == 0) return nullstr;
	res = makstr(i);
	data = CHARS(res);
	for(;NNULLP(chrs);chrs=CDR(chrs)) {
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
	if (i == 0) return nullstr;
	res = makstr(i);
	dst = CHARS(res);
	if ICHRP(chr) for(i--;i>=0;i--) dst[i] = ICHR(chr);
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
	ASSERT(INUM(k) < LENGTH(str),k,OUTOFRANGE,s_st_set);
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
	while(i-- != 0) if(*c1++ != *c2++) return BOOL_F;
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
	c1 = (unsigned char *) CHARS(s1);
	c2 = (unsigned char *) CHARS(s2);
	while(i-- != 0) if(upcase[*c1++] != upcase[*c2++]) return BOOL_F;
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
	if (len>i) i=len;
	c1 = (unsigned char *) CHARS(s1);
	c2 = (unsigned char *) CHARS(s2);
	for(i=0;i<len;i++) {
		c = (*c1++ - *c2++);
		if (c>0) return BOOL_F;
		if (c<0) return BOOL_T;
	}
	return (len != LENGTH(s2)) ? BOOL_T : BOOL_F;
}
SCM st_leqp(s1, s2)
SCM s1, s2;
{
  return st_lessp(s2, s1) ^ (BOOL_F ^ BOOL_T);
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
	c1 = (unsigned char *) CHARS(s1);
	c2 = (unsigned char *) CHARS(s2);
	for(i=0;i<len;i++) {
		c = (upcase[*c1++] - upcase[*c2++]);
		if (c>0) return BOOL_F;
		if (c<0) return BOOL_T;
	}
	return (len != LENGTH(s2)) ? BOOL_T : BOOL_F;
}
SCM stci_leqp(s1, s2)
SCM s1, s2;
{
  return stci_lessp(s2, s1) ^ (BOOL_F ^ BOOL_T);
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
	l=INUM(end)-INUM(start);
	ASSERT(l>=0,MAKINUM(l),OUTOFRANGE,s_substring);
	if (l == 0) return nullstr;
	return makfromstr(&CHARS(str)[INUM(start)],(sizet)l);
}
SCM st_append(args)
SCM args;
{
	SCM res;
	register long i=0;
	register SCM l,s;
	register char *data;
	for(l=args;NIMP(l);) {
		ASSERT(CONSP(l),l,ARG1,s_st_append);
		s = CAR(l);
		ASSERT(NIMP(s) && STRINGP(s),s,ARG1,s_st_append);
		i += LENGTH(s);
		l=CDR(l);
	}
	ASSERT(NULLP(l),args,ARG1,s_st_append);
	if (i == 0) return nullstr;
	res = makstr(i);
	data = CHARS(res);
	for(l=args;NIMP(l);l=CDR(l)) {
		s = CAR(l);
		for(i=0;i<LENGTH(s);i++) *data++ = CHARS(s)[i];
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
	ASSERT(i>=0,l,ARG1,s_vector);
	res = make_vector(MAKINUM(i),UNSPECIFIED);
	data = VELTS(res);
	for(;NIMP(l);l=CDR(l)) *data++ = CAR(l);
	return res;
}
SCM vector_ref(v, k)
SCM v,k;
{
	ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_ve_ref);
	ASSERT(INUMP(k),k,ARG2,s_ve_ref);
	ASSERT((INUM(k) < LENGTH(v)) && (INUM(k) >= 0),
	       k,OUTOFRANGE,s_ve_ref);
	return VELTS(v)[((long) INUM(k))];
}
SCM vector_set(v,k,obj)
SCM v,k,obj;
{
	ASSERT(NIMP(v) && VECTORP(v),v,ARG1,s_ve_set);
	ASSERT(INUMP(k),k,ARG2,s_ve_set);
	ASSERT((INUM(k) < LENGTH(v)),k,OUTOFRANGE,s_ve_set);
	VELTS(v)[((long) INUM(k))] = obj;
	return UNSPECIFIED;
}

extern char s_apply[], s_map[], s_for_each[];
extern char s_make_vector[],s_force[],s_resizstr[],s_resizvect[];

static iproc cxrs[] = {
	{"car",0},
	{"cdr",0},
	{"caar",0},
	{"cadr",0},
	{"cdar",0},
	{"cddr",0},
	{"caaar",0},
	{"caadr",0},
	{"cadar",0},
	{"caddr",0},
	{"cdaar",0},
	{"cdadr",0},
	{"cddar",0},
	{"cdddr",0},
	{"caaaar",0},
	{"caaadr",0},
	{"caadar",0},
	{"caaddr",0},
	{"cadaar",0},
	{"cadadr",0},
	{"caddar",0},
	{"cadddr",0},
	{"cdaaar",0},
	{"cdaadr",0},
	{"cdadar",0},
	{"cdaddr",0},
	{"cddaar",0},
	{"cddadr",0},
	{"cdddar",0},
	{"cddddr",0},
	{0,0}};

static iproc subr1s[]={
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
	{s_force,force},
	{0,0}};

static iproc subr2s[]={
	{"eq?",eq},
	{"equal?",equal},
	{"cons",cons},
#ifndef PURE_FUNCTIONAL
	{s_setcar,setcar},
	{s_setcdr,setcdr},
#endif
	{s_list_ref,list_ref},
	{s_memq,memq},
	{s_member,member},
	{s_assq,assq},
	{s_assoc,assoc},
	{s_quotient,quotient},
	{s_remainder,lremainder},
	{s_modulo,modulo},
	{"char=?",eq},
	{s_ch_lessp,char_lessp},
	{s_ci_eq,chci_eq},
	{s_ci_lessp,chci_lessp},
	{s_ch_leqp,char_leqp},
	{s_ci_leqp,chci_leqp},
	{s_st_ref,st_ref},
	{s_st_equal,st_equal},
	{s_stci_equal,stci_equal},
	{s_st_lessp,st_lessp},
	{s_stci_lessp,stci_lessp},
	{"string<=?",st_leqp},
	{"string-ci<=?",stci_leqp},
	{s_ve_ref,vector_ref},
	{0,0}};

static iproc lsubrs[]={
	{s_list,list},
	{s_append,append},
	{s_string,string},
	{s_st_append,st_append},
	{s_vector,vector},
	{0,0}};

static iproc lsubr2s[]={
	{s_apply,apply},
	{s_map,map},
	{s_for_each,for_each},
	{s_resizstr,resizstr},
	{s_resizvect,resizvect},
	{0,0}};

static iproc subr2os[]={
	{s_make_string,make_string},
	{s_make_vector,make_vector},
	{0,0}};

static iproc asubrs[]={
	{s_gcd,lgcd},
	{s_lcm,llcm},
	{0,0}};

static iproc subr2xs[]={
	{"char>?",char_lessp},
	{"char-ci>?",chci_lessp},
	{"char>=?",char_leqp},
	{"char-ci>=?",chci_leqp},
	{"string>?",st_lessp},
	{"string-ci>?",stci_lessp},
	{"string>=?",st_leqp},
	{"string-ci>=?",stci_leqp},
	{0,0}};

static iproc subr3s[]={
	{s_substring,substring},
#ifndef PURE_FUNCTIONAL
	{s_st_set,st_set},
	{s_ve_set,vector_set},
#endif
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
  init_iprocs(subr2xs, tc7_subr_2x);
  init_iprocs(lsubrs, tc7_lsubr);
  init_iprocs(lsubr2s, tc7_lsubr_2);
  init_iprocs(asubrs, tc7_asubr);
  init_iprocs(subr3s, tc7_subr_3);
}
