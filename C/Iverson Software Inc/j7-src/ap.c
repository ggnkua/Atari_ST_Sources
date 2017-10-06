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
/* Adverbs:  Partitions                                                    */

#include "j.h"
#include "a.h"


static F1(oind){A*x,z;I d,m,m1,n,n1,p,q,r,*s;
 r=AR(w); s=AS(w);
 m=1<r?*s:1;       m1=m-!!m;
 n=r?*(s+(1<r)):1; n1=n-!!n;
 d=m&&n?m+n-1:0;
 GA(z,BOX,d,1,0); x=(A*)AV(z);
 DO(d, p=MIN(i,m1); q=MIN(i,n1); RZ(*x++=apv((1+p+q-i),q+n*(i-q),n1));)
 R z;
}

static F2(osub){R ope(IC(w)?from(ope(a),w):w);}

static AS1(oblique, df2(oind(w),ravel(rank1ex(w,0L,-2L,box)),
  atop(fs,qq(ac2(osub),v2(0L,1L))) ))

static DF2(key){PROLOG;DECLF;A i,p,x,z;B*u;I c,d=-1,n,*v;
 RZ(a&&w);
 ASSERT(IC(a)==IC(w),EVLENGTH);
 RZ(x=indexof(a,a));
 RZ(i=grade1(x));
 RZ(x=from(i,x));
 n=AN(x); GA(p,BOOL,n,1,0);
 u=(B*)AV(p); v=AV(x); DO(n, c=d; d=*v++; *u++=c!=d;);
 z=df2(p,from(i,w),cut(fs,one));
 EPILOG(z);
}

F1(sldot){
 RZ(w);
 R VERB&AT(w)?ADERIV(CSLDOT,oblique,key,RMAXL,RMAXL,RMAXL):evger(w,sc(GAPPEND));
}


static F2(seg){A z;I c,k,m=0,n=0,*u,wt;
 RZ(a&&w);
 if(INT&AT(a)){u=AV(a); m=*u; n=*(1+u);}
 wt=AT(w); c=aii(w); k=c*bp(wt);
 GA(z,wt,n*c,MAX(1,AR(w)),AS(w)); *AS(z)=n;
 MC(AV(z),m*k+(C*)AV(w),n*k);
 R z;
}

static F2(ifxi){A z;I d,j,k,m,n,p,*x;
 RZ(a&&w);
 m=i0(a); p=ABS(m); n=IC(w);
 d=0>m?(n+p-1)/p:MAX(0,1+n-m);
 GA(z,INT,2*d,2,0); *AS(z)=d; *(1+AS(z))=2;
 x=AV(z); k=0>m?p:1; j=-k; DO(d, *x++=j+=k; *x++=p;); if(d)*--x=MIN(p,n-j);
 R z;
}

static F2(omask){A c,r,x,y;I m,n,p;
 RZ(a&&w);
 m=i0(a); p=ABS(m); n=IC(w);
 RZ(r=sc(0>m?(n+p-1)/p:MAX(0,1+n-m)));
 RZ(c=tally(w));
 RZ(x=reshape(sc(p)  ,zero));
 RZ(y=reshape(0>m?c:r,one ));
 R reshape(over(r,c),over(x,y));
}

static F1(pfxi){RZ(w); R table(apv(IC(w),1L,1L));}


static AS2(infix , df2(ifxi(a,w),   w,atop(fs,qq(ac2(seg),v2(1L,RMAXL)))))

static AS2(outfix, df2(omask(a,w),  w,atop(fs,ds(CPOUND))))

static AS1(prefix, df2(pfxi(w),     w,atop(fs,ds(CTAKE))))

static AS1(suffix, df2(table(ii(w)),w,atop(fs,ds(CDROP))))


static void bpv(m,v,x,bf)I m;B*v,*x;C bf;{B b,*u;C*cc="\000\001\000";I d;
 switch(bf){
  case V0001: u=memchr(v,C0,m); d=u?u-v:m; memset(x,C1,d); memset(x+d,C0,m-d); break;
  case V0111: u=memchr(v,C1,m); d=u?u-v:m; memset(x,C0,d); memset(x+d,C1,m-d); break;
  case V1110: u=memchr(v,C0,m); d=u?u-v:m; mvc(d,x,2L,1+cc);
                  memset(x+d,d%2?C0:C1,m-d); if(u)*(x+d)=d%2?1:0; break;
  case V1000: u=memchr(v,C1,m); d=u?u-v:m; mvc(d,x,2L,cc);
                  memset(x+d,d%2?C1:C0,m-d); if(u)*(x+d)=d%2?0:1; break;
  case V0010: u=memchr(v,C0,m); d=u?u-v:m; mvc(d,x,2L,1+cc);
                  memset(x+d,d%2?C1:C0,m-d); break;
  case V1011: u=memchr(v,C1,m); d=u?u-v:m; mvc(d,x,2L,cc);
                  memset(x+d,d%2?C0:C1,m-d); break;
  case V0100: memset(x,C0,m); if(u=memchr(v,C1,m))*(x+(u-v))=1; break;
  case V1101: memset(x,C1,m); if(u=memchr(v,C0,m))*(x+(u-v))=0; break;
  case V0110: b=0; MC(x,v,m); DO(m, *x=b=b!=*x; ++x;); break;
  case V1001: b=1; MC(x,v,m); DO(m, *x=b=b==*x; ++x;); break;
}}

static A pscan();

static DF1(bpscan){A fs,z;C bf,id;I c,m;VA*p;
 RZ(w);  /* AN(w)&&1<IC(w) */
 m=IC(w); c=aii(w);
 fs=VAV(self)->f; p=vap(fs); id=p->id; bf=p->bf;
 if(bf&&1==c){GA(z,BOOL,m,AR(w),AS(w)); bpv(m,AV(w),AV(z),bf); R z;}
 if(id==CPLUS||id==CMINUS){B b;I d,*v,*x;
  RZ(z=cvt(INT,w)); x=AV(z); v=x+c; d=0; b=1;
  switch(2*(1==c)+(id==CPLUS)){
   case 0: DO(m-1, if(b)DO(c, *v=*x++-*v; ++v;)else DO(c, *v+++=*x++;); b=!b;) R z;
   case 1: DO(c*(m-1), *v+++=*x++;); R z;
   case 2: DO(m, *x=d+=b?*x:-*x; ++x; b=!b;); R z;
   case 3: DO(m, *x=d+=*x; ++x;); R z;
 }}else{A q,r;B*qv,*rv,*u,*v,*x;I cv;SF f2;
  vaa(fs,BOOL,&f2,&cv);
  if(!(cv&VB))R pscan(cvt(FL,w),self);
  RZ(z=ca(w)); x=(B*)AV(z);
  if(cv&VASS){v=x+c; DO(c*(m-1), f2(x,v,v); ++x; ++v;); R jerr?0:z;}
  GA(q,BOOL,m,1,0); qv=(B*)AV(q);
  GA(r,BOOL,m,1,0); rv=(B*)AV(r);
  DO(c, u=x; DO(m, qv[i]=*u; u+=c;); bpv(m,qv,rv,bf); u=x++; DO(m, *u=rv[i]; u+=c;););
  R jerr?0:z;
}}

static DF1(pscan){A fs,z;C id,*v,*x;I c,cv,k,m,t;SF f2;
 RZ(w);
 m=IC(w); t=AT(w);
 if(!(1<m&&AN(w)&&t&NUMERIC))R prefix(w,self);
 if(t&BOOL)R bpscan(w,self);
 fs=VAV(self)->f; id=vap(fs)->id;
 if(id==CMINUS||id==CDIV){A y;I yv[2];
  if(id==CDIV&&!all0(eps(w,zero)))R prefix(w,self);
  GA(y,INT,m,1,0); yv[0]=1; yv[1]=-1; mvc(m*SZI,AV(y),2L*SZI,yv);
  if(id==CMINUS){RZ(w=tymes(w,y)); RZ(fs=slash(ds(CPLUS)));}
  else          {RZ(w=expn2(w,y)); RZ(fs=slash(ds(CSTAR)));}
  t=AT(w);
 }
 vaa(fs,t,&f2,&cv);
 if(!(cv&VASS))R prefix(w,self);
 RZ(z=cva(cv,w));
 c=aii(z); k=bp(AT(z)); x=(C*)AV(z); v=x+c*k;
 DO(c*(m-1), f2(x,v,v); x+=k; v+=k;);
 R jerr?0:cvz(cv,z);
}

static DF1(sscan){A z;C*v,*x;I c,cv,k,m,t;SF f2;
 RZ(w);
 m=IC(w); t=AT(w); c=aii(w);
 if(!(1<m&&t&NUMERIC))R suffix(w,self);
 vaa(VAV(self)->f,t,&f2,&cv);
 if(t&BOOL||!(cv&VB)){
  RZ(z=cva(cv,w));
  k=bp(AT(z)); x=(C*)AV(z)+m*c*k; v=x-c*k;
  DO(c*(m-1), x-=k; v-=k; f2(v,x,v););
  R jerr?0:cvz(cv,z);
 }else{A fs,q,y,z,*zv;AF f2;C*wv,*yv;V*sv=VAV(self);
  fs=VAV(sv->f)->f; f2=VAV(fs)->f2; k=c*bp(t); wv=(C*)AV(w)+k*(m-1);
  RZ(q=tail(w));
  GA(y,t,c,AR(q),AS(q)); yv=(C*)AV(y);
  GA(z,BOX,m,1,0); zv=m+(A*)AV(z);
  *--zv=q; DO(m-1, MC(yv,wv-=k,k); RZ(*--zv=q=f2(y,q,fs)););
  R ope(z);
}}


static B issl(w)A w;{A fs; RZ(w); R CSLASH==ID(w)&&(fs=VAV(w)->f,vaptr[(UC)ID(fs)]);}

F1(bslash){
 RZ(w);
 if(NOUN&AT(w))R gtrain(w);
 R ADERIV(CBSLASH,issl(w)?pscan:prefix,infix,RMAXL,0L,RMAXL);
}

F1(bsdot){
 RZ(w);
 ASSERT(VERB&AT(w),EVDOMAIN);
 R ADERIV(CBSDOT,issl(w)?sscan:suffix,outfix,RMAXL,0L,RMAXL);
}
