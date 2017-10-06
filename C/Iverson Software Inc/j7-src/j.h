/* ----------------------------------------------------------------------- */
/* J-Source Version 7 - COPYRIGHT 1993 Iverson Software Inc.               */
/* 33 Major Street, Toronto, Ontario, Canada, M5S 2K9, (416) 925 6096      */
/*                                                                         */
/* J-Source is provided "as is" without warranty of any kind.              */
/*                                                                         */
/* J-Source Version 7 license agreement:  You may use, copy, and           */
/* modify the source.  You have a non-exclusive, royalty-free right        */
/* to redistribute source and executable files.                            */
/* ----------------------------------------------------------------------- */
/*                                                                         */
/* Global Definitions                                                      */


#include "js.h"

#if (SYS & SYS_ATARIST)
#define __NO_INLINE__           1
#endif

#if (SYS & SYS_UNIX)
#include <memory.h>
#include <sys/types.h>
#endif

#if (SYS & SYS_ANSILIB)
#include <float.h>
#include <limits.h>
#include <stdlib.h>
#endif

#include <errno.h>
#include <math.h>
#include <signal.h>
#include <stdio.h>
#include <string.h>
#include "jc.h"
#include "jt.h"
#include "je.h"
#include "io.h"


#if (SYS & SYS_LILENDIAN)
#define XINF            "\000\000\000\000\000\000\360\177"
#define XNAN            "\000\000\000\000\000\000\370\377"
#endif

#if (SYS & SYS_AMIGA)
#define XINF            "\177\377\000\000\000\000\000\000"
#define XNAN            "\177\361\000\000\000\000\000\000"
#endif

#if (SYS & SYS_ARCHIMEDES)
#define XINF            "\000\000\360\177\000\000\000\000"
#define XNAN            "\000\000\370\377\000\000\000\000"
#endif

#if (SYS & SYS_MACINTOSH)
#define XINF            "\177\377\000\000\000\000\000\000\000\000\000\000"
#define XNAN            "\377\377\100\000\000\000\000\000\000\000\000\000"
#endif

#if (SYS & SYS_VAX)
#define XINF            "\377\177\377\377\377\377\377\377"
#define XNAN            "\377\177\377\377\377\377\377\376" /* not right */
#endif

#ifndef XINF
#define XINF            "\177\360\000\000\000\000\000\000"
#define XNAN            "\377\370\000\000\000\000\000\000"
#endif


#ifndef PI
#define PI              3.14159265358979323846
#endif
#define P2              6.28318530717958647693
#ifndef LONG_MAX
#define LONG_MAX        2147483647L
#endif
#ifndef LONG_MIN
#define LONG_MIN        (~2147483647L)
#endif
#ifndef OVERFLOW
#define OVERFLOW        8.988465674311578e307
#endif
#ifndef UNDERFLOW
#define UNDERFLOW       4.450147717014403e-308
#endif


#define NALP            256             /* size of alphabet                */
#define NPP             20              /* max value for quad pp           */
#define NPROMPT         20              /* max length of immex prompt      */
#define NTSTACK         2000L           /* size of stack for temps         */
#define RMAX            127             /* max rank                        */
#define RMAXL           127L            /* max rank, long                  */


#define ABS(a)          (0<=(a)?(a):-(a))
#define DF1(f)          A f(  w,self)A   w,self;
#define DF2(f)          A f(a,w,self)A a,w,self;
#define DO(n,stm)       {I i=0;I _n=(n); for(;i<_n;i++){stm}}
#define EPILOG(z)       R gc(z,_ttop)
#define F1(f)           A f(  w)A   w;
#define F2(f)           A f(a,w)A a,w;
#define F1RANK(m,f,self)    {RZ(   w); if(m<AR(w))            \
                                 R rank1ex(  w,(A)self,(I)m,     f);}
#define F2RANK(l,r,f,self)  {RZ(a&&w); if(l<AR(a)||r<AR(w))   \
                                 R rank2ex(a,w,(A)self,(I)l,(I)r,f);}
#define GA(v,t,n,r,s)   RZ(v=ga((I)(t),(I)(n),(I)(r),(I*)(s)))
#define GGA(v,t,n,r)    {GA(v,t,n,r,0); AC(v)=LONG_MAX/2;}
#define IC(w)           (AR(w) ? *AS(w) : 1L)
#define ICMP(z,w,n)     memcmp((z),(w),(n)*SZI)
#define ICPY(z,w,n)     memcpy((z),(w),(n)*SZI)
#define JSPR(fmt,x)     {sprintf(obuf,fmt,x); jouts(obuf);}
#define JSPRX(fmt,x)    {sprintf(obuf,fmt,x); jputs(obuf);}
#define MAX(a,b)        ((a)>(b)?(a):(b))
#define MC              memcpy
#define MIN(a,b)        ((a)<(b)?(a):(b))
#define PROLOG          I _ttop=tbase+ttop
#define R               return
#define RE(exp)         {if((exp),jerr)R 0;}
#define RZ(exp)         {if(!(exp))R 0;}
#define SGN(a)          ((0<(a))-(0>(a)))
#define SZI             ((I)sizeof(I))


#define ASSERT(b,e)     {if(!(b)){jsignal(e); R 0;}}

#define EVBREAK         1
#define EVDEFN          2
#define EVDOMAIN        3
#define EVILNAME        4
#define EVILNUM         5
#define EVINDEX         6
#define EVFACE          7
#define EVINPRUPT       8
#define EVLENGTH        9
#define EVLIMIT         10
#define EVNONCE         11
#define EVNOTASGN       12
#define EVOPENQ         13
#define EVRANK          14
#define EVRESULT        15
#define EVSPELL         16
#define EVSTOP          17
#define EVSYNTAX        18
#define EVSYSTEM        19
#define EVVALUE         20
#define EVWSFULL        21

#define NEVM            21      /* number of event codes                   */
