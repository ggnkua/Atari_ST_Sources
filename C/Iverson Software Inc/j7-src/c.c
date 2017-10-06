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
/* Conjunctions                                                            */

#include "j.h"
#include "a.h"

#define ASSERTVV(a,w)  RZ(a&&w); ASSERT(VERB&AT(a)&AT(w),EVDOMAIN)


static DF1(withl){DECLFG; R g2(fs,w,gs);}

static DF1(withr){DECLFG; R f2(w,gs,fs);}

static CS1(on1, f1(g1(w,gs),fs))

static CS2(on2, f2(g1(a,gs),g1(w,gs),fs))

F2(amp){
 RZ(a&&w);
 switch(CONJCASE(a,w)){
  case NN: ASSERT(0,EVDOMAIN);
  case NV: R CDERIV(CAMP,withl,0L,RMAXL,RMAXL,RMAXL);
  case VN: R CDERIV(CAMP,withr,0L,RMAXL,RMAXL,RMAXL);
  case VV: R CDERIV(CAMP,on1,on2,mr(w),mr(w),mr(w));
}}


static DF1(under1){DECLFG; R df1(  w,atop(inv(gs),amp(fs,gs)));}

static DF2(under2){DECLFG; R df2(a,w,atop(inv(gs),amp(fs,gs)));}

F2(under){ASSERTVV(a,w); R CDERIV(CUNDER,under1,under2,mr(w),mr(w),mr(w));}


F2(ampco){ASSERTVV(a,w); R CDERIV(CAMPCO,on1,on2,RMAXL,RMAXL,RMAXL);}


static CS2(upon2, f1(g2(a,w,gs),fs))

F2(atop){ASSERTVV(a,w); R CDERIV(CAT,on1,   upon2, mr(w),lr(w),rr(w));}


F2(atco){ASSERTVV(a,w); R CDERIV(CATCO,on1,upon2,RMAXL,RMAXL,RMAXL);}

F2(lev){R a;}

F2(dex){R w;}


static CS1(obv1, f1(w,fs))

static CS2(obv2, f2(a,w,fs))

F2(obverse){ASSERTVV(a,w); R CDERIV(COBVERSE,obv1,obv2,mr(a),lr(a),rr(a));}


static DF1(ad1){DECLFG;A z;C es=errsee;
 PREF1(ad1);
 errsee=0; z=f1(w,fs); errsee=es; jerr=0;
 R z?z:g1(w,gs);
}

static DF2(ad2){DECLFG;A z;C es=errsee;
 PREF2(ad2);
 errsee=0; z=f2(a,w,fs); errsee=es; jerr=0;
 R z?z:g2(a,w,gs);
}

F2(adverse){ASSERTVV(a,w); R CDERIV(CADVERSE,ad1,ad2,mr(a),lr(a),rr(a));}


F2(pdt){PROLOG;A z;I an,ar,ar1,*as,m,mn,n,p,t,wn,wr,wr1,*ws;
 t=coerce2(&a,&w,BOOL);
 ASSERT(t&NUMERIC,EVDOMAIN);
 an=AN(a); ar=AR(a); as=AS(a); ar1=ar?ar-1:0; m=prod(ar1,  as);
 wn=AN(w); wr=AR(w); ws=AS(w); wr1=wr?wr-1:0; n=prod(wr1,1+ws);
 p=ar?*(as+ar1):wr?*ws:1;
 if(!ar!=!wr)R ar?pdt(a,reshape(sc(p),w)):pdt(reshape(sc(p),a),w);
 ASSERT(!(ar&&wr)||p==*ws,EVLENGTH); mn=m*n;
 GA(z,t&BOOL?INT:t&INT?FL:t,mn,ar1+wr1,0);
 ICPY(AS(z),      as,ar1);
 ICPY(AS(z)+ar1,1+ws,wr1);
 switch(t){
  case BOOL:
   {B*u,*v,*wv;I*x,*zv;
    u=an+(B*)AV(a); wv=wn+(B*)AV(w); zv=mn+AV(z); memset(AV(z),C0,mn*SZI);
    DO(m, v=wv; DO(p, if(*--u){x=zv; DO(n, *--x+=*--v;);} else v-=n;); zv-=n;);
    break;
   }
  case INT:
   {D x,*zv;I*u,*uu,*v,*wv;
    uu=AV(a); wv=AV(w); zv=(D*)AV(z);
    DO(m, DO(n, x=0; u=uu; v=i+wv; DO(p, x+=*u++*(D)*v; v+=n;); *zv++=x;); uu+=p;);
    RZ(z=icvt(z));
    break;
   }
  case FL:
   {D*u,*uu,*v,*wv,x,*zv;
    uu=(D*)AV(a); wv=(D*)AV(w); zv=(D*)AV(z);
    DO(m, DO(n, x=0; u=uu; v=i+wv; DO(p, x+=*u++**v;    v+=n;); *zv++=x;); uu+=p;);
    break;
   }
  case CMPX:
   {D x,y;Z*u,*uu,*v,*wv,*zv;
    uu=(Z*)AV(a); wv=(Z*)AV(w); zv=(Z*)AV(z);
    DO(m, DO(n, x=y=0; u=uu; v=i+wv;
        DO(p, x+=u->re*v->re-u->im*v->im; y+=u->re*v->im+u->im*v->re; ++u; v+=n;);
        zv->re=x; zv->im=y; ++zv;); uu+=p;);
 }}
 EPILOG(z);
}

static CS2(dotprod, df2(a,w,atop(fs,qq(gs,v2(1+lr(gs),RMAXL)))))

static F1(minors){A d;
 RZ(d=apv(3L,-1L,1L)); *AV(d)=0;
 R drop(d,df2(one,w,bsdot(ds(CLEFT))));
}

static DF1(det){DECLFG;I c;
 PREF1(det);
 c=2>AR(w)?1:*(1+AS(w));
 R !c ? df1(mtv,slash(gs)) : 1==c ? f1(ravel(w),fs) :
    dotprod(rank1ex(w,0L,1L,head),det(minors(w),self),self);
}

F2(dot){A f;C b;
 ASSERTVV(a,w);
 b=SCALARFN(CSTAR,w)&&CSLASH==ID(a)&&(f=VAV(a)->f,SCALARFN(CPLUS,f));
 R CDERIV(CDOT,det,b?pdt:dotprod,2L,RMAXL,RMAXL);
}


static A eo(a,w,f)A a,w,f;{A z;V*u,*v;
 RZ(a&&w);
 ASSERT(VERB&AT(a)&AT(w),EVDOMAIN);
 RZ(z=folk(a,atco(ds(CHALVE),f),amp(a,w)));
 u=VAV(z); v=VAV(a); v->mr=u->mr; v->lr=u->lr; v->rr=u->rr;
 R z;
}

F2(even){R eo(a,w,ds(CPLUS ));}

F2(odd ){R eo(a,w,ds(CMINUS));}
