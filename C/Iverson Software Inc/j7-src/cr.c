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
/* Conjunctions:  Rank Associates                                          */

#include "j.h"
#include "a.h"

#define DR(r)           (0>r?RMAXL:r)


static I efr(ar,r)I ar,r;{R 0>r?MAX(0,r+ar):MIN(r,ar);}


A sex1(w,zt,f1)A w;I zt;SF f1;{A z;C*v,*x;I k,n,zk;
 RZ(w);
 n=AN(w);
 GA(z,zt,n,AR(w),AS(w));
 k =bp(AT(w)); v=(C*)AV(w)-k;
 zk=bp(zt);    x=(C*)AV(z)-zk;
 DO(n, f1(v+=k,x+=zk););
 R jerr?0:z;
}

static void ado(b,m,n,k,zk,u,v,x,f2)B b;C*u,*v,*x;I m,n,k,zk;SF f2;{
 u-=k; v-=k; x-=zk;
 if(1==n)  DO(m,             f2(u+=k,v+=k,x+=zk); )
 else if(b)DO(m, u+=k; DO(n, f2(u,   v+=k,x+=zk);))
 else      DO(m, v+=k; DO(n, f2(u+=k,v,   x+=zk);))
}

A sex2(a,w,zt,f2)A a,w;I zt;SF f2;{A z;B b;I an,ar,*as,m,n,wn,wr,*ws;
 RZ(a&&w);
 an=AN(a); ar=AR(a); as=AS(a);
 wn=AN(w); wr=AR(w); ws=AS(w);
 b=ar<=wr; m=b?an:wn; n=m?(b?wn:an)/m:0;
 ASSERT(!ICMP(as,ws,b?ar:wr),EVLENGTH);
 GA(z,zt,m*n,b?wr:ar,b?ws:as);
 ado(b,m,n,bp(AT(a)),bp(zt),AV(a),AV(w),AV(z),f2);
 R jerr?0:z;
}

A r2a(a,w,zt,lr,rr,f2)A a,w;I lr,rr,zt;SF f2;{PROLOG;A z;B b,c;
    I acn,acr,af,ar,*as,cn,cr,m,mc,n,nc,p,q,*s,wcn,wcr,wf,wr,*ws;
 RZ(a&&w);
 ar=AR(a); as=AS(a); acr=efr(ar,lr); af=ar-acr; acn=prod(acr,as+af);
 wr=AR(w); ws=AS(w); wcr=efr(wr,rr); wf=wr-wcr; wcn=prod(wcr,ws+wf);
 b=af<=wf; p=b?wf:af; q=b?af:wf; s=b?ws:as; m=prod(q,s); n=prod(p-q,s+q);
 c=acr<=wcr; mc=c?acn:wcn; nc=mc?(c?wcn:acn)/mc:0; cn=c?wcn:acn; cr=c?wcr:acr;
 ASSERT(!ICMP(as,ws,q),EVLENGTH);
 ASSERT(!ICMP(as+af,ws+wf,c?acr:wcr),EVLENGTH);
 GA(z,zt,m*n*cn,p+cr,s); ICPY(p+AS(z),c?ws+wf:as+af,cr);
 if(AN(z)){C*u,*v,*x,*y;I k,k1;
  k=bp(AT(a)); k1=bp(zt);
  u=(C*)AV(a)-k; v=(C*)AV(w)-k; x=(C*)AV(z)-k1;
  if(1==n&&1==nc)DO(AN(z), f2(u+=k,v+=k,x+=k1);)
  else if(1==mc&&1==nc)ado(b,m,n,k,k1,u+k,v+k,x+k1,f2);
  else if(1==m&&1==nc){
   if(b)  {y=u; DO(n,  u=y;       DO(mc, f2(u+=k,v+=k,x+=k1);));}
   else   {y=v; DO(n,  v=y;       DO(mc, f2(u+=k,v+=k,x+=k1);));}
  }else if(1==m&&1==mc){I an=AN(a),wn=AN(w);
   if(wcr){y=v; DO(an, v=y; u+=k; DO(wn, f2(u,   v+=k,x+=k1);));}
   else   {y=u; DO(wn, u=y; v+=k; DO(an, f2(u+=k,v,   x+=k1);));}
  }else{I ak,wk,zk;
   ak=acn*k;  u+=k -ak;
   wk=wcn*k;  v+=k -wk;
   zk= cn*k1; x+=k1-zk;
   if(1==n)  DO(m,              ado(c,mc,nc,k,k1,u+=ak,v+=wk,x+=zk,f2); )
   else if(b)DO(m, u+=ak; DO(n, ado(c,mc,nc,k,k1,u,    v+=wk,x+=zk,f2);))
   else      DO(m, v+=wk; DO(n, ado(c,mc,nc,k,k1,u+=ak,v,    x+=zk,f2);))
 }}
 R jerr?0:z;
}

A rank1ex(w,fs,mr,f1)A w,fs;I mr;AF f1;{PROLOG;A*x,y,yw,yz,z;C*v,*vv;
   I n,wcn,wcr,wf,wk,wr,*ws,wt;
 RZ(w);
 wr=AR(w); ws=AS(w); wt=AT(w); wcr=efr(wr,mr); wf=wr-wcr; n=prod(wf,ws);
 wcn=n?AN(w)/n:prod(wcr,wf+ws); wk=wcn*bp(wt); v=(C*)AV(w)-wk;
 GA(yw,wt,wcn,wcr,ws+wf); vv=(C*)AV(yw);
 GA(yz,BOX,n,wf,ws); x=(A*)AV(yz);
 if(n){DO(n, MC(vv,v+=wk,wk); RZ(*x++=f1(yw,fs));); z=ope(yz);}
 else{
  RZ(y=f1(reshape(shape(yw),zero),fs));
  GA(z,AT(y),0,wf+AR(y),ws); ICPY(wf+AS(z),AS(y),AR(y));
 }
 EPILOG(z);
}

A rank2ex(a,w,fs,lr,rr,f2)A a,w,fs;I lr,rr;AF f2;{PROLOG;A*x,y,ya,yw,yz,z;B b;
   C*u,*uu,*v,*vv;I acn,acr,af,ak,ar,*as,at,m,n,p,q,*s,wcn,wcr,wf,wk,wr,*ws,wt;
 RZ(a&&w);
 ar=AR(a); as=AS(a); at=AT(a); acr=efr(ar,lr); af=ar-acr;
 wr=AR(w); ws=AS(w); wt=AT(w); wcr=efr(wr,rr); wf=wr-wcr;
 acn=prod(acr,as+af); ak=acn*bp(at); u=(C*)AV(a)-ak;
 wcn=prod(wcr,ws+wf); wk=wcn*bp(wt); v=(C*)AV(w)-wk;
 b=af<=wf; p=b?wf:af; q=b?af:wf; s=b?ws:as; m=prod(q,s); n=prod(p-q,s+q);
 ASSERT(!ICMP(as,ws,q),EVLENGTH);
 GA(ya,at,acn,acr,as+af); uu=(C*)AV(ya);
 GA(yw,wt,wcn,wcr,ws+wf); vv=(C*)AV(yw);
 if(m&&n){
  GA(yz,BOX,m*n,p,s); x=(A*)AV(yz);
  if(1==n)  DO(m, MC(uu,u+=ak,ak);       MC(vv,v+=wk,wk); RZ(*x++=f2(ya,yw,fs)); )
  else if(b)DO(m, MC(uu,u+=ak,ak); DO(n, MC(vv,v+=wk,wk); RZ(*x++=f2(ya,yw,fs));))
  else      DO(m, MC(vv,v+=wk,wk); DO(n, MC(uu,u+=ak,ak); RZ(*x++=f2(ya,yw,fs));))
  z=ope(yz);
 }else{
  if(AN(a))MC(uu,u+=ak,ak); else RZ(ya=reshape(shape(ya),zero));
  if(AN(w))MC(vv,v+=wk,wk); else RZ(yw=reshape(shape(yw),zero));
  RZ(y=f2(ya,yw,fs));
  GA(z,AT(y),0,p+AR(y),s); ICPY(p+AS(z),AS(y),AR(y));
 }
 EPILOG(z);
}

static DF1(cons1a){R VAV(self)->f;}

static DF2(cons2a){R VAV(self)->f;}

static DF1(cons1){V*sv=VAV(self);
 RZ(w);
 R rank1ex(w,self,efr(AR(w),*AV(sv->h)),cons1a);
}

static DF2(cons2){V*sv=VAV(self);I*v=AV(sv->h);
 RZ(a&&w);
 R rank2ex(a,w,self,efr(AR(a),v[1]),efr(AR(w),v[2]),cons2a);
}

static DF1(rank1){DECLF;I m,wr;
 RZ(w);
 wr=AR(w); m=efr(wr,*AV(sv->h));
 R m<wr?rank1ex(w,fs,m,f1):f1(w,fs);
}

static DF2(rank2){DECLF;I ar,wr,l,r,*v=AV(sv->h);
 RZ(a&&w);
 ar=AR(a); l=efr(ar,v[1]);
 wr=AR(w); r=efr(wr,v[2]);
 R l<ar||r<wr?rank2ex(a,w,fs,l,r,f2):f2(a,w,fs);
}

static DF2(rank2a){C id;I at,cv,t,*v,wt;SF f2;V*sv;
 RZ(a&&w);
 sv=VAV(self); id=ID(sv->f); v=AV(sv->h);
 if(id==CEQ||id==CNE)R neeq(a,w,v[1],v[2],id);
 at=AN(a)?AT(a):BOOL; wt=AN(w)?AT(w):BOOL; t=MAX(at,wt);
 var(id,t,&f2,&cv);
 t=atype(cv);
 R cvz(cv,r2a(t==at?a:cvt(t,a),t==wt?w:cvt(t,w),rtype(cv),v[1],v[2],f2));
}

F2(qq){A hs,t;D*d;I n,*hv,r[3],*v;
 RZ(a&&w);
 RZ(hs=apv(3L,0L,0L)); hv=AV(hs);
 if(VERB&AT(w)){
  GA(t,FL,3,1,0); d=(D*)AV(t);
  n=r[0]=hv[0]=mr(w); d[0]=n<=-RMAX?-inf:RMAX<=n?inf:n;
  n=r[1]=hv[1]=lr(w); d[1]=n<=-RMAX?-inf:RMAX<=n?inf:n;
  n=r[2]=hv[2]=rr(w); d[2]=n<=-RMAX?-inf:RMAX<=n?inf:n;
  w=t;
 }else{
  n=AN(w);
  ASSERT(1>=AR(w),EVRANK);
  ASSERT(0<n&&n<4,EVLENGTH);
  RZ(t=vib(sc(RMAXL),w)); v=AV(t);
  hv[0]=v[2==n]; r[0]=DR(hv[0]);
  hv[1]=v[3==n]; r[1]=DR(hv[1]);
  hv[2]=v[n-1];  r[2]=DR(hv[2]);
 }
 n=NOUN&AT(a);
 R fdef(CQQ,VERB, n?cons1:rank1, n?cons2:vaptr[(UC)ID(a)]?rank2a:rank2,
     a,w,hs, 0L, r[0],r[1],r[2]);
}
