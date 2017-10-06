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
/* Verbs:  Complex-Valued Scalar Functions                                 */

#include "j.h"
#include "v.h"

#define ZF1DECL         D a=v.re,b=v.im,              zi=0,zr=0;Z z
#define ZF2DECL         D a=u.re,b=u.im,c=v.re,d=v.im,zi=0,zr=0;Z z
#define ZEPILOG         z.re=zr; z.im=zi; R z
#define ZF1(f)          Z f(v)Z v;
#define ZF2(f)          Z f(u,v)Z u,v;
#define ZS1(f,stmts)    ZF1(f){ZF1DECL; stmts; ZEPILOG;}
#define ZS2(f,stmts)    ZF2(f){ZF2DECL; stmts; ZEPILOG;}
#define ZASSERT(b,e)    {if(!(b)){jsignal(e); R zeroZ;}}

#define ZNZ(v)          (v.re||v.im)
#define ZEZ(v)          (!(v.re||v.im))
#define ZEQ(u,v)        (u.re==v.re && u.im==v.im)
#define ZOV(v)          (ABS(v.re)> OVERFLOW||ABS(v.im)> OVERFLOW)
#define ZUN(v)          (ABS(v.re)<UNDERFLOW||ABS(v.im)<UNDERFLOW)

#define MMM(a,b)        {p=ABS(a); q=ABS(b); if(p<q){D t=p; p=q; q=t;}}


static Z zj ={0, 1};
static Z zmj={0,-1};
static Z z1 ={1, 0};

static D hypoth(u,v)D u,v;{D p,q,t; MMM(u,v); R p?(t=q/p,p*sqrt(1+t*t)):0;}


ZS1(zconjug, zr=a; zi=-b;)

ZS2(zplus,  zr=a+c; zi=b+d;)

ZS2(zminus, zr=a-c; zi=b-d;)

ZS1(ztrend, if(ZNZ(v)){D t; if(ZOV(v)){a/=2; b/=2;} t=hypoth(a,b); zr=a/t; zi=b/t;})

ZS2(ztymes, if(ZNZ(u)&&ZNZ(v)){zr=a*c-b*d; zi=a*d+b*c;})

ZF2(zdiv){ZF2DECL;D t;
 if(ZNZ(v)){
  if(ABS(c)<ABS(d)){t=a; a=-b; b=t;  t=c; c=-d; d=t;}
  a/=c; b/=c; d/=c; t=1+d*d; zr=(a+b*d)/t; zi=(b-a*d)/t;
 } else if(ZNZ(u))switch(2*(0>a)+(0>b)){
   case 0: if(a> b)zr= inf; else zi= inf; break;
   case 1: if(a>-b)zr= inf; else zi=-inf; break;
   case 2: if(a<-b)zr=-inf; else zi= inf; break;
   case 3: if(a< b)zr=-inf; else zi=-inf;
 }
 ZEPILOG;
}

static ZF1(znegate){R zminus(zeroZ,v);}

D zmag(v)Z v;{R hypoth(v.re,v.im);}

B zeq(u,v)Z u,v;{D a=u.re,b=u.im,c=v.re,d=v.im;
 if(ZEQ(u,v)) R 1;
 else if(ZEZ(u)||ZEZ(v)||!qct||(0>a!=0>c&&0>b!=0>d)) R 0;
 else {D p,q;Z t;
  if(ZOV(u)||ZOV(v)){a/=2; b/=2; c/=2; d/=2;}
  if(ZUN(u)||ZUN(v)){a*=2; b*=2; c*=2; d*=2;}
  p=hypoth(a,b); q=hypoth(c,d); t=zminus(u,v);
  R hypoth(t.re,t.im)<=qct*MAX(p,q);
}}

ZF1(zfloor){D p,q;
 ZF1DECL;
 zr=floor(a); p=a-zr;
 zi=floor(b); q=b-zi;
 if(1<=p+q+qct)if(p>=q)++zr; else ++zi;
 ZEPILOG;
}

ZF1(zceil){R znegate(zfloor(znegate(v)));}

ZF2(zrem){Z q,s,t;
 if(!u.re&&!u.im)R v;
 q=zdiv(v,u); s=zceil(q); t=zfloor(q);
 if(zeq(s,t))R zeroZ; else R zminus(v,ztymes(u,t));
}

ZF2(zgcd){D a,b;Z t,z;
 while(ZNZ(u)){t=zrem(u,v); v.re=u.re; v.im=u.im; u.re=t.re; u.im=t.im;}
 z.re=a=v.re; z.im=b=v.im;
 switch(2*(0>a)+(0>b)){
  case 1: z.re=-b; z.im= a; break;
  case 2: z.re= b; z.im=-a; break;
  case 3: z.re=-a; z.im=-b;
 }
 R z;
}

ZF2(zlcm){if(ZEZ(u)||ZEZ(v))R zeroZ; else R ztymes(u,zdiv(v,zgcd(u,v)));}

ZF1(zexp){ZF1DECL;D t=xexp(a); zr=t*xcos(b); zi=t*xsin(b); ZEPILOG;}


#if (SYS & SYS_ATARIST)

static D jtan2(y,x)D x,y;{R !y ? (0<=x?0.0:PI) : !x ? (0<=y?PI/2:-PI/2) : atan2(x,y);}

ZS1(zlog, zr=b?log(hypoth(a,b)):a==inf||a==-inf?inf:a?log(hypoth(a,b)):-inf;
    zi=a||b?jtan2(b,a):0;)

#else
ZS1(zlog, zr=b?log(hypoth(a,b)):a==inf||a==-inf?inf:a?log(hypoth(a,b)):-inf;
    zi=a||b?atan2(b,a):0;)
#endif


ZF2(zpow){ZF2DECL;D m=floor(c);
 if(!b&&!d){
  z.im=0;
  if(!a){z.re=0>c?inf:!c; R z;}
  if(c==m&&LONG_MIN<m&&m<=LONG_MAX){D r=1,t=a;I n=m;
   if(0>n){t=1/t; n=-n;}
   while(n){if(n%2)r*=t; t*=t; n/=2;}
   z.re=r; R z;
 }}
 z=zexp(ztymes(v,zlog(u)));
 if(!b&&!d&&0>a&&c>m&&c==0.5+m)z.re=0;
 R z;
}

ZF1(zsqrt){D p,q,t;
 ZF1DECL;
 MMM(a,b);
 if(p){
  t=0.5*q/p; zr=sqrt(ABS(a/2)+p*sqrt(0.25+t*t)); zi=b/(zr+zr);
  if(0>a){t=ABS(zi); zi=0>b?-zr:zr; zr=t;}
 }
 ZEPILOG;
}


/* See Abramowitz & Stegun, Handbook of Mathematical Functions,            */
/*   National Bureau of Standards, 1964 6.                                 */

static ZF1(zsin){ZF1DECL; zr=xsin(a)*xcosh(b); zi= xcos(a)*xsinh(b); ZEPILOG;}
 /* 4.3.55 */

static ZF1(zcos){ZF1DECL; zr=xcos(a)*xcosh(b); zi=-xsin(a)*xsinh(b); ZEPILOG;}
 /* 4.3.56 */

static ZF1(ztan){R zdiv(zsin(v),zcos(v));}

static ZF1(zp4){R zsqrt(ztymes(zplus(v,zj),zminus(v,zj)));}

static ZF1(zm4){R ztymes(zplus(v,z1),zsqrt(zdiv(zminus(v,z1),zplus(v,z1))));}

static ZF1(zsinh){R ztymes(zmj,zsin(ztymes(zj,v)));}  /* 4.5.7 */

static ZF1(zcosh){R zcos(ztymes(zj,v));}              /* 4.5.8 */

static ZF1(ztanh){R zdiv(zsinh(v),zcosh(v));}

static ZF1(zp8){R zsqrt(ztymes(zplus(zj,v),zminus(zj,v)));}

static ZF1(zasinh){if(0>v.re)R znegate(zasinh(znegate(v))); R zlog(zplus(v,zp4(v)));}

static ZF1(zacosh){Z z;
 z=zlog(zplus(v,zm4(v)));
 if(0>=z.re){z.re=0; z.im=ABS(z.im);}
 R z;
}

static ZF1(zatanh){Z z05;
 z05.re=0.5; z05.im=0;
 R ztymes(z05,zlog(zdiv(zplus(z1,v),zminus(z1,v))));
}

static ZF1(zasin){R ztymes(zmj,zasinh(ztymes(zj,v)));}   /* 4.4.20 */

static ZF1(zacos){Z zpi2; zpi2.re=PI/2; zpi2.im=0; R zminus(zpi2,zasin(v));}

static ZF1(zatan){R ztymes(zmj,zatanh(ztymes(zj,v)));}   /* 4.4.22 */

static ZF1(zarc){if(v.re||v.im)R ztymes(zmj,zlog(ztrend(v))); R zeroZ;}

ZF2(zcir){D x=u.re;Z z;
 z=zeroZ; /* Sun386i does not allow init of aggregate object */
 ZASSERT(!u.im&&-12<=x&&x<=12&&x==floor(x),EVDOMAIN);
 switch((int)x){
  case  0: R zsqrt(ztymes(zplus(z1,v),zminus(z1,v)));
  case  1: R zsin(v);           case  -1: R zasin(v);
  case  2: R zcos(v);           case  -2: R zacos(v);
  case  3: R ztan(v);           case  -3: R zatan(v);
  case  4: R zp4(v);            case  -4: R zm4(v);
  case  5: R zsinh(v);          case  -5: R zasinh(v);
  case  6: R zcosh(v);          case  -6: R zacosh(v);
  case  7: R ztanh(v);          case  -7: R zatanh(v);
  case  8: R zp8(v);            case  -8: R znegate(zp8(v));
  case  9: z.re=v.re;     R z;  case  -9: R v;
  case 10: z.re=zmag(v);  R z;  case -10: R zconjug(v);
  case 11: z.re=v.im;     R z;  case -11: R ztymes(zj,v);
  case 12: R zarc(v);           case -12: R zexp(ztymes(zj,v));
  default: ZASSERT(0,EVDOMAIN);
}}

ZF1(znonce1){ZASSERT(0,EVNONCE);}

ZF2(znonce2){ZASSERT(0,EVNONCE);}
