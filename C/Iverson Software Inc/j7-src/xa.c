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
/* Xenos: Miscellaneous                                                    */

#include "j.h"
#include "x.h"

#if (SYS_GETTOD)
#include <sys/time.h>
#else
#include <time.h>
#endif

#if (SYS & SYS_MACINTOSH)
#include "mac.h"
#include "PrintTraps.h"
#endif

#if (SYS & SYS_MACINTOSH)
#include "PrintTraps.h"
#endif

#ifndef CLOCKS_PER_SEC
#if (SYS & SYS_UNIX)
#define CLOCKS_PER_SEC  1000000
#endif
#ifdef  CLK_TCK
#define CLOCKS_PER_SEC  CLK_TCK
#endif
#endif


F1(stype){R sc(AT(w));}

F1(ir){A z;I m;
 RZ(w);
 m=4*WP(AT(w),AN(w),AR(w)); GA(z,CHAR,m,1,0); MC(AV(z),w,m);
 R z;
}

F1(ri){A y,z;I n,r,*s,t;
 F1RANK(1,ri,0);
 ASSERT(CHAR&AT(w),EVDOMAIN);
 y=(A)AV(w); n=AN(y); r=AR(y); s=AS(y); t=AT(y);
 ASSERT(t==BOOL||t==CHAR||t==INT||t==FL||t==CMPX,EVDOMAIN);
 ASSERT(0<=r,EVRANK);
 DO(r,ASSERT(0<=s[i],EVLENGTH);); ASSERT(n==prod(r,s),EVLENGTH);
 ASSERT((3+AN(w))/4==WP(t,n,r),EVLENGTH);
 GA(z,t,n,r,0); MC(AS(z),s,AN(w)-AH*SZI);
 R z;
}

F1(fxx){
 RZ(w);
 ASSERT(AT(w)&CHAR+BOX,EVDOMAIN);
 ASSERT(1>=AR(w),EVRANK);
 R AT(w)&CHAR ? unsr(ca(w)) : fx(ope(w));
}

F1(arx){F1RANK(0,arx,0); ASSERT(BOX&AT(w),EVDOMAIN); R arep(symbrd(onm(w)));}

F1(drx){F1RANK(0,drx,0); ASSERT(BOX&AT(w),EVDOMAIN); R drep(symbrd(onm(w)));}

F1(srx){F1RANK(0,srx,0); ASSERT(BOX&AT(w),EVDOMAIN); R srep(ope(w),symbrd(onm(w)));}

F1(trx){F1RANK(0,trx,0); ASSERT(BOX&AT(w),EVDOMAIN); R trep(symbrd(onm(w)));}

F1(lrx){F1RANK(0,lrx,0); ASSERT(BOX&AT(w),EVDOMAIN); R lrep(symbrd(onm(w)));}

F1(ts){A z;I*x;struct tm*t;time_t now;
 RZ(w);
 time(&now); t=localtime(&now);
 GA(z,INT,6,1,0); x=AV(z);
 x[0]=t->tm_year+1900;
 x[1]=t->tm_mon+1;
 x[2]=t->tm_mday;
 x[3]=t->tm_hour;
 x[4]=t->tm_min;
 x[5]=t->tm_sec;
 R z;
}

#if (SYS_GETTOD)
D tod(){struct timeval t; gettimeofday(&t,NULL); R t.tv_sec+(D)t.tv_usec/1e6;}
#else
D tod(){R(D)clock()/CLOCKS_PER_SEC;}
#endif

F1(tss){R scf(tod()-tssbase);}

F2(tsit2){D t;I n,old;
 F2RANK(0,1,tsit2,0);
 RE(n=i0(a));
 t=tod(); old=tbase+ttop; DO(n, RZ(exec1(w)); gc(0L,old);); t=tod()-t;
 R scf(n?t/n:0);
}

F1(tsit1){R tsit2(one,w);}

F1(dl){
 F1RANK(0,dl,0);
#if (SYS & SYS_MACINTOSH)
 {I m=TickCount()+60*i0(w); while(m>TickCount()&&breaker());}
#else
 DO(i0(w), sleep(1); RZ(breaker()););
#endif
 R w;
}

F1(sp){R sc(bytes);}

F1(sps){R sc(totbytes);}

F1(spit){I k; F1RANK(1,spit,0); maxbytes=k=bytes; RZ(exec1(w)); R sc(maxbytes-k);}


#if (SYS&SYS_SESM && SYS&SYS_PC+SYS_PC386)

static int      cgav;
extern I        jstratts();
extern void     jstref();
extern void     jstsatts();
extern void     jstslow();

F1(cgaq){ASSERT(sesm,EVDOMAIN); R sc((I)cgav);}

F1(cgas){
 ASSERT(sesm,EVDOMAIN);
 ASSERT(!AR(w),EVRANK);
 RZ(w=cvt(BOOL,w));
 jstslow(cgav=*(B*)AV(w));
 R mtv;
}

F1(colorq){A z;I k,*s,*x;UC t[4];
 RZ(w);
 ASSERT(sesm,EVDOMAIN);
 GA(z,INT,8,2,0); s=AS(z); *s=4; *++s=2;
 x=AV(z);
 k=jstratts(); MC(t,&k,4L); DO(4, *x++=t[i]/16; *x++=t[i]%16;);
 R z;
}

F1(colors){I*x;UC c,t[4],*tv;
 ASSERT(sesm,EVDOMAIN);
 RZ(w=vi(w));
 ASSERT(2==AR(w),EVRANK);
 ASSERT(8==AN(w)&&4==*AS(w),EVLENGTH);
 x=AV(w);
 DO(8, ASSERT(0<=x[i]&&x[i]<16,EVDOMAIN););
 tv=t; DO(4, c=16**x++; c+=*x++; *tv++=c;); jstsatts(*(unsigned long*)t);
 R mtv;
}

F1(refresh){ASSERT(sesm,EVDOMAIN); jstref(); R mtv;}


#if (SYS & SYS_PC386)

extern SI       jstedit(SI);

F1(edit){PROLOG;A z;I k,n;
 RZ(w);
 ASSERT(sesm,EVDOMAIN);
 ASSERT(1>=AR(w),EVRANK);
 n=AN(w);
 ASSERT(!n||CHAR&AT(w),EVDOMAIN);
 ASSERT(n<=NEDB,EVLIMIT);
 MC(edbuf,AV(w),n);
 k=jstedit((SI)n);
 z=0>k?ca(w):str(k,edbuf);
 EPILOG(z);
}

#else

extern SI       jstedit(SI,SI,C*);

F1(edit){PROLOG;A t,z;C*s;I k,m,n;
 RZ(w);
 ASSERT(sesm,EVDOMAIN);
 ASSERT(1>=AR(w),EVRANK);
 n=AN(w);
 ASSERT(!n||CHAR&AT(w),EVDOMAIN);
 m=MIN(32767,4000+n);
 GA(t,CHAR,m,1,0);
 k=(I)(15+(C*)AV(t)); k&=0xfffffff0L; s=(C*)k; /* ensure segment aligned */
 MC(s,AV(w),n);
 k=jstedit((S)n,(S)m-15,s);
 z=0>k?ca(w):str(k,s);
 EPILOG(z);
}

#endif
#endif


#if (SYS & SYS_MACINTOSH)

F1(fontq){A z;I*x;
 GA(z,INT,3,1,0); x=AV(z);
 x[0]=texi.tsFont;
 x[1]=texi.tsFace;
 x[2]=texi.tsSize;
 R z;
}

F1(fonts){I*v;TextStyle old=texi;
 RZ(w=vi(w));
 ASSERT(1==AR(w),EVRANK);
 ASSERT(3==AN(w),EVLENGTH);
 v=AV(w);
 texi.tsFont=v[0];
 texi.tsFace=v[1];
 texi.tsSize=v[2];
 reFont(&old,&texi);
 R mtv;
}

F1(prtscr){
 PrClose(); PrDrvrClose();
 PrDrvrOpen();
 PrCtlCall(iPrDevCtl,lPrReset,0L,0L);
 PrCtlCall(iPrBitsCtl,(I)&screenBits,(I)&screenBits.bounds,lPaintBits);
 PrDrvrClose();
 PrOpen();
 R mtv;
}
#endif


F1(rlq){R sc(qrl);}

F1(rls){I k; RE(k=i0(w)); ASSERT(0<k&&k<2147483646L,EVDOMAIN); qrl=k; R mtv;}

F1(dispq){A z; GA(z,INT,*qdisp,1,0); ICPY(AV(z),1+qdisp,*qdisp); R z;}

F1(disps){I n;
 RZ(w=vi(w));
 n=AN(w);
 ASSERT(1>=AR(w),EVRANK);
 ASSERT(all1(nubsieve(w)),EVDOMAIN);
 ASSERT(all1(eps(w,apv(5L,1L,1L))),EVINDEX);
 *qdisp=n; ICPY(1+qdisp,AV(w),n);
 R mtv;
}

F1(promptq){R cstr(qprompt);}

F1(prompts){C*v;I n;
 RZ(vs(w));
 n=AN(w); v=(C*)AV(w);
 ASSERT(!memchr(v,'\0',n),EVDOMAIN);
 ASSERT(NPROMPT>=n,EVLIMIT);
 MC(qprompt,v,1+n);
 R mtv;
}

F1(boxq){R str(11L,qbx);}

F1(boxs){RZ(vs(w)); ASSERT(11==AN(w),EVLENGTH); MC(qbx,AV(w),11L); R mtv;}

F1(evmq){R behead(qevm);}

F1(evms){A t,*y;
 RZ(w);
 ASSERT(1==AR(w),EVRANK);
 ASSERT(NEVM==AN(w),EVLENGTH);
 ASSERT(BOX&AT(w),EVDOMAIN);
 y=(A*)AV(w); DO(NEVM, RZ(vs(*y++)););
 RZ(t=link(mtv,w)); ra(t); fa(qevm); qevm=t;
 R mtv;
}

C jc(k,f1,f2)I k;AF*f1,*f2;{
 switch(k){
/*  case k:
/*   *f1=  ;     monad of 10!:k  (0 if none)   */
/*   *f2=  ;     dyad  of 10!:k  (0 if none)   */
/*   R 1;        indicate no error             */
  default:
   ASSERT(0,EVNONCE);
}}
