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
/* Convert numeric input into numbers                                      */

#include "j.h"
#include "v.h"


static B numd(n,s,v)I n;C*s;D*v;{C c,*t;D x,y;
 ASSERT(n,EVILNUM);
 if('-'==*s&&3>n){x=1==n?inf:(c=*(1+s),c=='-')?-inf:c=='.'?nan:0; if(x){*v=x; R 1;}}
 x=strtod(s,&t);
 if(t<s+n-1&&'r'==*t){y=strtod(1+t,&t); x=y?x/y:0<x?inf:0>x?-inf:0;}
 ASSERT(t>=s+n,EVILNUM);
 *v=x; R 1;
}

static B numj(n,s,v)I n;C*s;Z*v;{C*t,*ta;D x,y;
 if(t=memchr(s,'j',n))ta=0; else t=ta=memchr(s,'a',n);
 RZ(numd(t?t-s:n,s,&x));
 if(t){t+=ta?2:1; RZ(numd(n+s-t,t,&y));} else y=0;
 if(ta){C c;
  c=*(1+ta);
  ASSERT(0<=x&&(c=='d'||c=='r'),EVILNUM);
  if(c=='d')y*=PI/180; if(y<=-P2||P2<=y)y-=P2*floor(y/P2); if(0>y)y+=P2;
  v->re=y==0.5*PI||y==1.5*PI?0:x*cos(y); v->im=y==PI?0:x*sin(y);
 }else{v->re=x; v->im=y;}
 R 1;
}

static B numb(n,s,v,b)I n;C*s;Z*v,b;{A c,d,y;I k;
  static C dig[]="0123456789abcdefghijklmnopqrstuvwxyz";I m=strlen(dig);
 if(!n){*v=zeroZ; R 1;}
 RZ(d=indexof(str(m,dig),str(n,s)));
 ASSERT(all0(eps(sc(m),d)),EVILNUM);
 k=bp(CMPX);
 GA(c,CMPX,1,0,0); MC(AV(c),&b,k); RZ(y=base2(c,d)); MC(v,AV(y),k);
 R 1;
}

static Z zpi={PI,0};

static B numbpx(n,s,v)I n;C*s;Z*v;{B ne,ze;C*t,*u;I k,m;Z b,p,q,x,y;
 if(t=memchr(s,'b',n)){
  RZ(numbpx(t-s,s,&b));
  ++t; if(ne='-'==*t)++t;
  m=k=n+s-t; if(u=memchr(t,'.',m))k=u-t;
  ASSERT(ne||m>(u?1:0),EVILNUM);
  RZ(numb(k,t,&p,b));
  if(u){
   k=m-(1+k);
   if(ze=!(b.re||b.im))b.re=1;
   RZ(numb(k,1+u,&q,b));
   if(ze){if(q.re)p.re=inf;} else{DO(k,q=zdiv(q,b);); p=zplus(p,q);}
  }
  *v=p; if(ne){v->re=-v->re; v->im=-v->im;}
  R 1;
 }
 if(t=memchr(s,'p',n))u=0; else t=u=memchr(s,'x',n);
 if(!t)R numj(n,s,v);
 RZ(numj(t-s,s,&x)); ++t; RZ(numj(n+s-t,t,&y));
 if(u)*v=ztymes(x,zexp(y)); else *v=ztymes(x,zpow(zpi,y));
 R 1;
}

A connum(n,s)I n;C*s;{PROLOG;A y,z;B b,(*f)(),j,p=1;C c,*v;I d=0,k,m=0,q,t,*x;
 RZ(y=str(n,s)); s=v=(C*)AV(y);
 GA(y,INT,1+n,1,0); x=AV(y);
 DO(n, c=*v; *v++=c=c==CSIGN?'-':c==CTAB?' ':c; b=' '==c; if(p!=b)x[d++]=i; p=b;);
 if(d%2)x[d++]=n; m=d/2;
 b=memchr(s,'b',n)||memchr(s,'p',n)||memchr(s,'x',n);
 j=memchr(s,'j',n)||memchr(s,'a',n);
 f=b?numbpx:j?numj:numd; t=j||b?CMPX:FL; k=bp(t);
 GA(z,t,m,1!=m,0); v=(C*)AV(z);
 DO(m, d=i+i; q=x[d]; RZ(f(x[1+d]-q,q+s,v)); v+=k;);
 z=xcvt(z); EPILOG(z);
}
