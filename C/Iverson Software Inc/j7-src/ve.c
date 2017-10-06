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
/* Verbs:  Elementary Functions (Arithmetic, etc.)                         */

#include "j.h"
#include "v.h"


static SF1(jconjug,Z,Z, zconjug(*v))

F1(conjug){
 switch(coerce1(&w,BOOL)){
  case BOOL:
  case INT:
  case FL:   R ca(w);
  case CMPX: R sex1(w,CMPX,jconjug);
  default:   R 0;
}}


SF2(bplus, I,I, *u+*v)

SF2(bplus2,B,I, *u+*v)

SF2(iplus, I,D, *u+(D)*v)

SF2(dplus, D,D, *u+*v)

SF2(jplus, Z,Z, zplus(*u,*v))

F2(plus){R va2(a,w,CPLUS);}


F1(negate){R minus(zero,w);}


SF2(bminus, I,I, *u-*v)

SF2(bminus2,B,I, *u-*v)

SF2(iminus, I,D, *u-(D)*v)

SF2(dminus, D,D, *u-*v)

SF2(jminus, Z,Z, zminus(*u,*v))

F2(minus){R va2(a,w,CMINUS);}


static SF1(isignum,I,I, SGN(*v))

static SF1(dsignum,D,I, qct>ABS(*v)?0:SGN(*v))

#if (SYS & SYS_PC+SYS_MACINTOSH)
static void jsignum(v,x)Z*v,*x;{if(qct<zmag(*v))*x=ztrend(*v); else *x=zeroZ;}
#else
static SF1(jsignum,Z,Z, qct>zmag(*v)?zeroZ:ztrend(*v))
#endif

F1(signum){
 switch(coerce1(&w,BOOL)){
  case BOOL: R ca(w);
  case INT:  R sex1(w,INT ,isignum);
  case FL:   R sex1(w,INT ,dsignum);
  case CMPX: R sex1(w,CMPX,jsignum);
  default:   R 0;
}}


SF2(band,B,B, *u&&*v)

SF2(itymes,I,D, *u*(D)*v)

SF2(dtymes, D,D, *u&&*v?*u**v:0)

SF2(jtymes, Z,Z, ztymes(*u,*v))

F2(tymes){R va2(a,w,CSTAR);}


F1(recip){R divide(one,w);}


SF2(bdiv,B,D, *v?*u:*u?inf:0)

SF2(idiv,I,D, *v?*u/(D)*v:*u?*u*inf:0)

void ddiv(u,v,x)D*u,*v,*x;{D t=*v?*u/ *v:*u?*u*inf:0; *x=0==t?0:t;} /* beware -0 */

SF2(jdiv,Z,Z, zdiv(*u,*v))

F2(divide){R va2(a,w,CDIV);}


F1(decrem){R minus(w,one);}

F1(increm){R plus(one,w);}

F1(not){R w&&BOOL&AT(w)?eq(zero,w):minus(one,w);}

F1(duble){R plus(w,w);}

F1(halve){R divide(w,two);}

F1(square){R tymes(w,w);}


static SF1(imag,I,I, ABS(*v))

static SF1(dmag,D,D, ABS(*v))

static SF1(jmag,Z,D, zmag(*v))

F1(mag){
 switch(coerce1(&w,BOOL)){
  case BOOL: R ca(w);
  case INT:  R all1(eps(sc(LONG_MIN),w))?sex1(cvt(FL,w),FL,dmag):sex1(w,INT,imag);
  case FL:   R sex1(w,FL,dmag);
  case CMPX: R sex1(w,FL,jmag);
  default:   R 0;
}}


static I xirem(a,b)I a,b;{I r; R!a?b:(r=b%a,0<a?r+a*(0>r):r+a*(0<r));}

static D xdrem(a,b)D a,b;{D q,t,z;
 if(!a)R b;
 q=b/a; t=tfloor(q); R teq(t,tceil(q))?0:(z=b-a*t, 0<a&&0<z||0>a&&0>z?z:0);
}

SF2(irem,I,I, xirem(*u,*v))

SF2(dren,D,D, xdrem(*u,*v))

SF2(jrem,Z,Z, zrem(*u,*v))

F2(residue){R va2(a,w,CSTILE);}


static I xigcd(a,b)I a,b;{R a?xigcd(xirem(a,b),a):b;}

static D xdgcd(a,b)D a,b;{D a1,b1,t;
 if(!a)R b;
 if(a>b)R xdgcd(b,a);
 a1=a; b1=b;
 while(xdrem(a1/floor(0.5+a1/a),b1)){t=a; a=xdrem(a,b); b=t;}
 R a;
} /* D.L. Forkes 1984; E.E. McDonnell 1992 */

SF2(bor,B,B, *u||*v)

SF2(igcd,I,I, xigcd(ABS(*u),ABS(*v)))

SF2(dgcd,D,D, xdgcd(ABS(*u),ABS(*v)))

SF2(jgcd,Z,Z, zgcd(*u,*v))

F2(gcd){R va2(a,w,COR);}


void ilcm(u,v,x)I*u,*v;D*x;{I a=ABS(*u),b=ABS(*v); *x=a&&b?*u*(D)(*v/xigcd(a,b)):0;}

void dlcm(u,v,x)D*u,*v, *x;{D a=ABS(*u),b=ABS(*v); *x=a&&b?*u*    *v/xdgcd(a,b) :0;}

SF2(jlcm,Z,Z, zlcm(*u,*v))

F2(lcm){R va2(a,w,CAND);}


static SF1(dfloor,D,D, tfloor(*v))

static SF1(jfloor,Z,Z, zfloor(*v))

F1(floor1){
 switch(coerce1(&w,BOOL)){
  case BOOL:
  case INT:  R ca(w);
  case FL:   R icvt(sex1(w,FL,dfloor));
  case CMPX: R sex1(w,CMPX,jfloor);
  default:   R 0;
}}


SF2(imin,I,I, MIN(*u,*v))

SF2(dmin,D,D, MIN(*u,*v))

F2(minimum){R va2(a,w,CMIN);}


static SF1(dceil,D,D, tceil(*v))

static SF1(jceil,Z,Z, zceil(*v))

F1(ceil1){
 switch(coerce1(&w,BOOL)){
  case BOOL:
  case INT:  R ca(w);
  case FL:   R icvt(sex1(w,FL,dceil));
  case CMPX: R sex1(w,CMPX,jceil);
  default:   R 0;
}}


SF2(imax,I,I, MAX(*u,*v))

SF2(dmax,D,D, MAX(*u,*v))

F2(maximum){R va2(a,w,CMAX);}


static F2(wt){A z;B b;D*v,x=1,y,*zv;I n,t,*u;
 RZ(a&&w);
 b=0<AR(w); n=b?AN(w):*AV(a); t=AT(w);
 ASSERT(t&NUMERIC,EVDOMAIN);
 if(!(t&INT+FL))R behead(df1(over(b?w:reshape(a,w),one),bsdot(slash(ds(CSTAR)))));
 GA(z,FL,n,1,0); zv=n+(D*)AV(z); u=AV(w); v=(D*)AV(w);
 switch(b+2*(t==FL)){
  case 0: y=*u; DO(n, *--zv=x; x*=y;   ); R icvt(z);
  case 1: u+=n; DO(n, *--zv=x; x*=*--u;); R icvt(z);
  case 2: y=*v; DO(n, *--zv=x; x*=y;   ); R z;
  case 3: v+=n; DO(n, *--zv=x; x*=*--v;); R z;
}}

F1(base1){A z;B*v;I c,d,m,n,p,r,*s,*x;
 RZ(w);
 n=AN(w); r=AR(w); s=AS(w); c=r?*(s+r-1):1;
 if(31<c||BOOL!=AT(w))R pdt(w,wt(sc(c),two));
 m=c?n/c:prod(r-1,s);
 GA(z,INT,m,r?r-1:0,s); x=m+AV(z); v=n+(B*)AV(w);
 if(c)DO(m, p=0; d=1; DO(c, if(*--v)p+=d; d+=d;); *--x=p;)
 else memset(x-m,C0,m*SZI);
 R z;
}

F2(base2){I ar,*as,c,wr,*ws;
 RZ(a&&w);
 ar=AR(a); as=AS(a);
 wr=AR(w); ws=AS(w); c=wr?*(ws+wr-1):1;
 R 1>=ar?pdt(w,wt(sc(c),a)):rank2ex(w,rank2ex(sc(c),a,0L,0L,1L,wt),0L,1L,1L,pdt);
}

F1(abase1){A z;B*zv;I c,n,p,r,t,*v,x;
 RZ(w);
 n=AN(w); r=AR(w); t=AT(w);
 if(!n||t&BOOL)R reshape(over(shape(w),n?one:zero),w);
 if(!(t&INT))R abase2(reshape(increm(floor1(logar2(two,maximum(one,
                 df1(mag(ravel(w)),slash(ds(CMAX))) )))),two),w);
 c=x=0; v=AV(w);
 DO(n, p=*v++; if(p==LONG_MIN){c=32; break;} x=x<p?p:x<-p?-p:x;);
 if(!c)while(x){x/=2; ++c;}
 c=MAX(1,c);
 GA(z,BOOL,n*c,1+r,AS(w)); *(r+AS(z))=c;
 v=n+AV(w); zv=AN(z)+(B*)AV(z);
 DO(n, x=*--v; DO(c, r=x%2; *--zv=r=0>r?1:r; x=(x-r)/2;););
 R z;
}

F2(abase2){A z;I an,ar,at,wn,wr,wt;
 RZ(a&&w);
 an=AN(a); ar=AR(a); at=AT(a);
 wn=AN(w); wr=AR(w); wt=AT(w);
 if(!ar)R residue(a,w);
 if(1==ar&&at&BOOL+INT&&wt&BOOL+INT){I*av,d,r,*u,*wv,x,*zv;
  RZ(coerce2(&a,&w,INT));
  GA(z,INT,an*wn,1+wr,AS(w)); *(wr+AS(z))=an;
  av=an+AV(a); wv=wn+AV(w); zv=AN(z)+AV(z);
  DO(wn, x=*--wv; u=av; DO(an, d=*--u; *--zv=r=xirem(d,x); x=d?(x-r)/d:0;););
  R z;
 }else{PROLOG;A y,*zv;C*u,*yv;I k;
  F2RANK(1,0,abase2,0);
  k=bp(at); u=an*k+(C*)AV(a);
  GA(y,at, 1, 0,0); yv=(C*)AV(y);
  GA(z,BOX,an,1,0); zv=an+(A*)AV(z);
  DO(an, MC(yv,u-=k,k); RZ(w=divide(minus(w,*--zv=residue(y,w)),y)););
  RZ(z=ope(z));
  EPILOG(z);
}}
