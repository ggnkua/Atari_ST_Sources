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
/* Verbs:  "Mathematical" Functions (Non-Rational, Transcendental, etc.)   */

#include "j.h"
#include "v.h"


D xsin(x)D x;{D y=x==inf||x==-inf?0:x-P2*floor(x/P2); R sin(y);}

D xcos(x)D x;{D y=x==inf||x==-inf?0:x-P2*floor(x/P2); R cos(y);}

D xsinh(x)D x;{R x<-709?-inf:709<x?inf:sinh(x);}

D xcosh(x)D x;{R x<-709||709<x?inf:cosh(x);}

D xexp(x)D x;{R 709<x?inf:exp(x);}


static A math1(w,df,jf)A w;SF df,jf;{
 switch(coerce1(&w,FL)){
  case FL:   R sex1(w,FL  ,df);
  case CMPX: R sex1(w,CMPX,jf);
  default:   R 0;
}}


static SF1(dexp,D,D, xexp(*v))

static SF1(jexp,Z,Z, zexp(*v))

F1(expn1){R math1(w,dexp,jexp);}

SF2(jpow,Z,Z, zpow(*u,*v))

F2(expn2){R va2(a,w,CEXP);}


static SF1(jlog,Z,Z, zlog(*v))

F1(logar1){RZ(w); R pcvt(FL,sex1(CMPX==AT(w)?w:cvt(CMPX,w),CMPX,jlog));}

F2(logar2){R divide(logar1(w),logar1(a));}


static SF1(jsqrt,Z,Z, zsqrt(*v))

F1(sqroot){RZ(w); R pcvt(FL,sex1(CMPX==AT(w)?w:cvt(CMPX,w),CMPX,jsqrt));}

F2(root){R expn2(w,recip(a));}


F1(jdot1){R tymes(a0j1,w);}

F2(jdot2){R plus(a,tymes(a0j1,w));}


F1(rdot1){R expn1(jdot1(w));}

F2(rdot2){R tymes(a,rdot1(w));}


F1(pix){R tymes(pie,w);}

SF2(jcir,Z,Z, zcir(*u,*v))

F2(circle){R va2(a,w,CCIRCLE);}


static D gam5243(v)D v;{D a,b,x;
 static D p[]={-42353.689509744089,-20886.861789269888,-8762.710297852149,
  -2008.52740130727915,-439.3304440600257,-50.108693752970954,-6.744950724592529};
 static D q[]={-42353.689509744089,-2980.385330925665,9940.307415082771,
  -1528.607273779522,-499.028526621439,189.498234157028016,-23.081551524580124,1.0};
 static I m=sizeof(p)/sizeof(D),n=sizeof(q)/sizeof(D);
 a=0; x=1; DO(m, a+=x*p[i]; x*=v;);
 b=0; x=1; DO(n, b+=x*q[i]; x*=v;);
 R a/b;
} /* Hart et al, "Computer Approximations" */

static D fac(v)D v;{B b,e;D t=1,x;
 x=floor(v); b=v==x; e=x==2*floor(x/2);
 if(170<ABS(v)||b&&0>v)R e&&0>v?-inf:inf;
 if(0<=v) while(1<v)t*=v--; else while(0>v)t/=++v;
 R b?t:t*gam5243(v-1);
}

static SF1(dfact,D,D, fac(*v))

F1(fact){R math1(w,dfact,znonce1);}


static D binD(u,v)D u,v;{D z=1; DO(v-170,z*=v--/u--;); R fac(v)/fac(u)/fac(v-u)*z;}

static D binI(u,v)D u,v;{D c=MIN(u,v-u),z=1; DO(c,z*=v--/c--;); R floor(0.5+z);}

#define MOD2(x) ((x)-2*floor(0.5*(x)))

static D bin(u,v)D u,v;{D t=v-u;
 switch(2*(u==floor(u))+(v==floor(v))){
  case 0: R 0>t&&t==floor(t)?0:binD(u,v);
  case 1: ASSERT(0<=v,EVDOMAIN); R binD(u,v);
  case 2: R u?binD(u,v):1;
  case 3: switch(4*(0>u)+2*(0>v)+(0>t)){
           case 0:  R binI(u,v);
           case 1:  R 0;
           case 2:  ASSERT(0,EVDOMAIN);
           case 3:  R (MOD2(u)?-1:1)*binI(u,u-v-1);
           case 4:  R 0;
           case 5:  /* Impossible */
           case 6:  R (MOD2(t)?-1:1)*binI(-1-v,-1-u);
           case 7:  R 0;
}}} /* P.C. Berry, Sharp APL Reference Manual, 1979, p. 132 */

SF2(dbin,D,D, bin(*u,*v))

SF2(jbin,Z,Z, znonce2(*u,*v))

F2(outof){R va2(a,w,CBANG);}


F1(rect ){R rank2ex(v2( 9L,11L),w,0L,1L,0L,circle);}

F1(polar){R rank2ex(v2(10L,12L),w,0L,1L,0L,circle);}

F1(eig1){ASSERT(0,EVNONCE);}

F2(eig2){ASSERT(0,EVNONCE);}


F1(poly1){ASSERT(0,EVNONCE);}


static D hornerD(x,n,v)D*v,x;I n;{D z=0;I j=n; DO(n,z=v[--j]+x*z;); R z;}

static Z hornerZ(x,n,v)Z*v,x;I n;{I j=n;Z z; 
 z.re=z.im=0;
 DO(n, z=zplus(v[--j],ztymes(x,z)););
 R z;
}

F2(poly2){A c,z;B b;I an,at,t,wn,wt;
 RZ(a&&w);
 if(1<AR(a))F2RANK(1,0,poly2,0);
 an=AN(a); at=AT(a); 
 wn=AN(w); wt=AT(w);
 ASSERT(wt&NUMERIC,EVDOMAIN);
 if(!AN(a))R reshape(shape(w),zero);
 b=!!(BOX&at);
 ASSERT(b||at&NUMERIC,EVDOMAIN);
 if(b){A*v=(A*)AV(a);
  ASSERT(2==an,EVLENGTH);
  c=v[0]; a=v[1]; an=AN(a); at=AT(a);
  ASSERT(NUMERIC&at+AT(c),EVDOMAIN);
  ASSERT(!AR(c),EVRANK);
  ASSERT(1>=AR(a),EVRANK);
 }
 t=MAX(at,wt); t=MAX(t,FL); if(b)t=MAX(t,AT(c));
 if(t!=at)RZ(a=cvt(t,a));
 if(t!=wt)RZ(w=cvt(t,w));
 GA(z,t,AN(w),AR(w),AS(w));
 if(b){ 
  RZ(c=cvt(t,c));
  if(t&FL){D*av,d,*wv,p,x,*zv; 
   av=(D*)AV(a); wv=(D*)AV(w); zv=(D*)AV(z); d=*(D*)AV(c);
   DO(wn, p=d; x=*wv++; DO(an, p*=x-av[i];); *zv++=p;);
  }else   {Z*av,d,*wv,p,x,*zv;
   av=(Z*)AV(a); wv=(Z*)AV(w); zv=(Z*)AV(z); d=*(Z*)AV(c);
   DO(wn, p=d; x=*wv++; DO(an, p=ztymes(p,zminus(x,av[i]));); *zv++=p;);
 }}else{
  if(t&FL){D*av,*wv,*zv; 
   av=(D*)AV(a); wv=(D*)AV(w); zv=(D*)AV(z); DO(wn, *zv++=hornerD(*wv++,an,av););
  }else   {Z*av,*wv,*zv;
   av=(Z*)AV(a); wv=(Z*)AV(w); zv=(Z*)AV(z); DO(wn, *zv++=hornerZ(*wv++,an,av););
 }}
 R z;
}
