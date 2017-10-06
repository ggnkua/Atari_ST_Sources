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
/* Conversions amongst Internal Types                                      */

#include "j.h"

#define KF1(f)          B f(w,y)A w,*y;

#define CVCASE(a,b)     ((a)+128*(b))
#define BxI             CVCASE(BOOL,INT )
#define BxD             CVCASE(BOOL,FL  )
#define BxZ             CVCASE(BOOL,CMPX)
#define IxB             CVCASE(INT ,BOOL)
#define IxD             CVCASE(INT ,FL  )
#define IxZ             CVCASE(INT ,CMPX)
#define DxB             CVCASE(FL  ,BOOL)
#define DxI             CVCASE(FL  ,INT )
#define DxZ             CVCASE(FL  ,CMPX)
#define ZxB             CVCASE(CMPX,BOOL)
#define ZxI             CVCASE(CMPX,INT )
#define ZxD             CVCASE(CMPX,FL  )
#define KxA             CVCASE(BOXK,BOX )


static KF1(BfromI){B*x;I n,p,*v;
 RZ(w);
 n=AN(w); v=AV(w);
 GA(*y,BOOL,n,AR(w),AS(w)); x=(B*)AV(*y);
 DO(n, p=*v++; if(0==p||1==p)*x++=p; else R 0;);
 R 1;
}

static KF1(BfromD){B*x;D p,*u,*v;I n;
 RZ(w);
 n=AN(w); u=(D*)AV(w);
 GA(*y,BOOL,n,AR(w),AS(w)); x=(B*)AV(*y);
 v=u; DO(n, p=*v++; if(p<-2||2<p)R 0;);  /* 2==p to catch NaN */
 v=u; DO(n, p=*v++; if(!p)*x++=0; else if(feq(1.0,p))*x++=1; else R 0;);
 R 1;
}

static KF1(IfromD){D p,q,r,*v;I n,*x;
 RZ(w);
 n=AN(w); v=(D*)AV(w);
 GA(*y,INT,n,AR(w),AS(w)); x=AV(*y);
 q=LONG_MIN*(1+qfuzz); r=LONG_MAX*(1+qfuzz);
 DO(n, p=v[i]; if(p<q||r<p)R 0;);
 DO(n, p=v[i]; q=floor(p); if(feq(p,q))*x++=q; else if(feq(p,1+q))*x++=1+q; else R 0;);
 R 1;
}

static KF1(DfromZ){D*x;I n;Z*v;
 RZ(w);
 n=AN(w); v=(Z*)AV(w);
 GA(*y,FL,n,AR(w),AS(w)); x=(D*)AV(*y);
 DO(n, if(freal(*v)){*x++=v->re; v++;} else R 0;);
 R 1;
}

static KF1(BfromZ){R DfromZ(w,y)?BfromD(*y,y):0;}

static KF1(IfromZ){R DfromZ(w,y)?IfromD(*y,y):0;}


static B ccvt(t,w,y)I t;A w,*y;{I n,wt,*wv,*yv;
 RZ(w);
 n=AN(w); wt=AT(w); wv=AV(w);
 if(t>=wt||!n){
  if(t==wt)RZ(*y=ca(w))
  else{GA(*y,t,n,AR(w),AS(w)); yv=AV(*y); if(t&CMPX+BOXK)fillv(t,n,yv);}
  if(t==wt||!n)R 1;
 }
 switch(CVCASE(t,wt)){
  case BxI: R BfromI(w,y);
  case BxD: R BfromD(w,y);
  case IxD: R IfromD(w,y);
  case BxZ: R BfromZ(w,y);
  case IxZ: R IfromZ(w,y);
  case DxZ: R DfromZ(w,y);
  case IxB: {I*x=    yv;B*v=(B*)wv; DO(n,*x++=*v++;);} R 1;
  case DxB: {D*x=(D*)yv;B*v=(B*)wv; DO(n,*x++=*v++;);} R 1;
  case DxI: {D*x=(D*)yv;I*v=    wv; DO(n,*x++=*v++;);} R 1;
  case ZxB: {Z*x=(Z*)yv;B*v=(B*)wv; DO(n,x++->re=*v++;);} R 1;
  case ZxI: {Z*x=(Z*)yv;I*v=    wv; DO(n,x++->re=*v++;);} R 1;
  case ZxD: {Z*x=(Z*)yv;D*v=(D*)wv; DO(n,x++->re=*v++;);} R 1;
  case KxA: {K*x=(K*)yv;A*v=(A*)wv; DO(n,x++->v=ca(*v++););} R 1;
  default:  ASSERT(0,EVDOMAIN);
}}

A cvt(t,w)I t;A w;{A y; ASSERT(ccvt(t,w,&y),EVDOMAIN); R y;}


F1(icvt){A z;D*v,x;I*u;
 RZ(w);
 GA(z,INT,AN(w),AR(w),AS(w)); u=AV(z); v=(D*)AV(w);
 DO(AN(w), x=*v++; if(x<LONG_MIN||LONG_MAX<x)R w; *u++=x;);
 R z;
}

A pcvt(t,w)I t;A w;{A y; R ccvt(t,w,&y)?y:w;}

static F1(xcvta){A y; R ccvt(BOOL,w,&y)?y:ccvt(INT,w,&y)?y:ccvt(FL,w,&y)?y:w;}

F1(xcvt){A z;D ofuzz=qfuzz; qfuzz=0; z=xcvta(w); qfuzz=ofuzz; R z;}
