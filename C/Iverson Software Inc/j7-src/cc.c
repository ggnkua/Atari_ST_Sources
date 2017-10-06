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
/* Conjunctions:  Cuts                                                     */

#include "j.h"
#include "a.h"


static DF2(cut02){DECLF;A p,y;I*av0,*av1,k,*pv,*ws,*yv;
 PREF2(cut02);
 /* Approximately,  f(i.1{a){,(1{a){.(0{a)}.w */
 RZ(a=vi(a));
 ASSERT(2==AR(a),EVRANK);
 k=*(1+AS(a)); av0=AV(a); av1=k+av0; ws=AS(w);
 ASSERT(2==IC(a)&&k<=AR(w),EVLENGTH);
 RZ(p=rank2ex(shape(w),take(rank(w),head(a)),0L,0L,0L,pind)); pv=AV(p);
 RZ(y=shape(w)); yv=AV(y); DO(k,yv[i]=av1[i];);
 DO(k, if(0>av0[i])pv[i]+=1-ABS(yv[i]); ASSERT(0<=pv[i]&&pv[i]<ws[i],EVLENGTH););
 R f1(from(iota(y),ravel(take(mag(y),drop(p,w)))),fs);
}

static DF1(cut01){R cut02(lamin2(zero,negate(shape(w))),w,self);}


static DF2(cut2){PROLOG;DECLFG;A y,z,*zv;B b,neg,pfx,*v;C*u,*wv;
    I c,d,i,k,m,n,p,q,r,*s,t;
 PREF2(cut2);
 n=p=IC(w);
 if(!AR(a))RZ(a=reshape(sc(n),a));
 ASSERT(n==IC(a),EVLENGTH);
 if(BOOL!=AT(a))RZ(a=cvt(BOOL,a)); v=(B*)AV(a);
 r=MAX(1,AR(w)); s=AS(w); t=AT(w); wv=(C*)AV(w); c=aii(w); k=c*bp(t);
 m=0; DO(AN(a), m+=v[i];); if(!m)R mtv;
 GA(z,BOX,m,1,0); zv=(A*)AV(z);
 q=*AV(gs); neg=0>q; pfx=q==1||q==-1; b=neg&&pfx;
 if(pfx){u=memchr(v,C1,n); p-=u-v; v=u;}
 for(i=1;i<=m;++i){
  if(i<m||!pfx){u=memchr(v+pfx,C1,p-pfx); u+=!pfx; q=u-v;} else q=p;
  d=q-neg; GA(y,t,c*d,r,s); *AS(y)=d; MC(AV(y),wv+k*(b+n-p),k*d);
  RZ(*zv++=f1(y,fs));
  p-=q; v=u;
 }
 z=ope(z); EPILOG(z);
}

static DF1(cut1){DECLFG;I q=*AV(gs);
 RZ(w);
 R!IC(w)?mtv:cut2(eps(w,take(q==1||q==-1?one:neg1,w)),w,self);
}

static DF1(cut1x){DECLFG;A z,*za;B b,neg,pfx;C id,sep,*u,*v,*zc;I c,d,i,m,n,p,q,t,*zi;
 RZ(w);
 t=AT(w); n=p=IC(w); if(!n)R mtv;
 if(!(1==AR(w)&&t&IS1BYTE))R cut1(w,self);
 q=*AV(gs); neg=0>q; pfx=q==1||q==-1; b=neg&&pfx;
 u=v=(C*)AV(w); sep=v[pfx?0:n-1];
 m=c=0; q=-1; DO(n, if(sep==v[i]){++m; d=i-q; c=MAX(c,d); q=i;}); c=MAX(c,n-q)-neg;
 id=ID(fs);
 switch(id){
  case CDOLLAR: GA(z,INT,m,  2,0); zi=    AV(z); break;
  case CPOUND:  GA(z,INT,m,  1,0); zi=    AV(z); break;
  case CBOX:    GA(z,BOX,m,  1,0); za=(A*)AV(z); break;
  case CHEAD:
  case CTAIL:   GA(z,t,  m,  1,0); zc=(C*)AV(z); break;
  default:      GA(z,t,  m*c,2,0); zc=(C*)AV(z); fillv(t,AN(z),zc);
 }
 if(2==AR(z)){*AS(z)=m; *(1+AS(z))=AN(z)/m;}
 for(i=1;i<=m;++i){
  v=u;
  if(i<m||!pfx){u=memchr(v+pfx,sep,p-pfx); u+=!pfx; p-=q=u-v;} else q=p;
  d=q-neg;
  switch(id){
   case CDOLLAR:
   case CPOUND: *zi++=d;              break;
   case CBOX:   RZ(*za++=str(d,v+b)); break;
   case CHEAD:  *zc++=*(v+b);         break;
   case CTAIL:  *zc++=*(v+b+d-1);     break;
   default:     MC(zc,v+b,d); zc+=c;
 }}
 R z;
}

static C cx[]={CBOX,CCOMMA,CDOLLAR,CHEAD,CLEFT,CPOUND,CRIGHT,CTAIL,0};

F2(cut){I k;
 RZ(a&&w);
 ASSERT(VERB&AT(a)&&NOUN&AT(w),EVDOMAIN);
 RZ(w=vi(w));
 RE(k=i0(w));
 ASSERT(-3<=k&&k<=3,EVDOMAIN);
 if(!k)R CDERIV(CCUT,cut01,cut02,RMAXL,2L,RMAXL);
 R CDERIV(CCUT, strchr(cx,ID(a))?cut1x:cut1, cut2 ,RMAXL,1L,RMAXL);
}
