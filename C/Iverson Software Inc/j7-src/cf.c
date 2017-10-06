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
/* Conjunction: Fit !.                                                     */

#include "j.h"
#include "a.h"

D qct;
A qfill=0;
C qpps[7]="%0.6g";

static B ctv(b,w)B b;A w;{D d;
 RZ(w);
 ASSERT(!AR(w),EVRANK);
 d=*(D*)AV(w); ASSERT(b&&d==inf||0<=d&&d<=5.820766091e-11,EVDOMAIN);
 R 1;
}

static DF1(fitct1){DECLFG;A z; qct=*(D*)AV(gs); z=f1(  w,fs); qct=qfuzz; R z;}

static DF2(fitct2){DECLFG;A z; qct=*(D*)AV(gs); z=f2(a,w,fs); qct=qfuzz; R z;}

static DF2(fitctv){DECLFG;A z;
 RZ(ctv(0,gs=cvt(FL,gs)));
 qct=*(D*)AV(gs); z=f2(a,w,fs); qct=qfuzz;
 R z;
}

static DF1(fitope){
 RZ(w);
 switch(AT(w)){
  case BOX:  R reshape(shape(w),zero);
  case BOXK: R ope(kast(0,w));
  default:   ASSERT(0,EVDOMAIN);
}}

static DF1(fitbox){DECLFG;A z;K*v;
 RZ(w);
 if(all1(match(gs,zero)))R box(w);
 GA(z,BOXK,1,0,0); v=(K*)AV(z); v->k=ca(gs); v->v=ca(w); R z;
}

static DF1(fitpp1){DECLFG;A z;
 sprintf(3+qpps,"%ldg",*AV(gs)); z=f1(w,fs); MC(3+qpps,"6g",3L);
 R z;
}

static DF2(fitfill){DECLFG;A z; qfill=gs; z=f2(a,w,fs); qfill=0; R z;}

static DF2(shift2){A gs,s,x,y;I c,m,n,p,t;
 F2RANK(0,RMAX,shift2,self);
 n=IC(w); t=AT(w); c=aii(w);
 p=i0(a); p=p<-n?-n:n<p?n:p; m=ABS(p);
 gs=VAV(self)->g;
 RZ(s=shape(w)); if(AR(w))*AV(s)=m;
 if(!AR(gs))RZ(x=reshape(s,gs))
 else if(AN(gs))RZ(x=rank2ex(behead(s),reitem(sc(m),gs),0L,1L,-1L,reshape))
 else RZ(x=reshape(s,filler(w)))
 if(AR(w)){y=drop(sc(p),w); R 0<p?over(y,x):over(x,y);} else R m?x:ca(w);
}

static DF1(shift1){R shift2(neg1,w,self);}

static DF1(fitexp1){R df1(w,amp(scf(exp(1.0)),self));}

static DF2(fitexp2){A gs,z;I n;V*sv;
 F2RANK(0,0,fitexp2,self);
 sv=VAV(self); gs=sv->g;
 RE(n=i0(w)); ASSERT(0<=n,EVDOMAIN);
 RZ(z=reshape(shape(gs),one));
 DO(n, RZ(z=tymes(z,a)); RZ(a=plus(a,gs)););
 R z;
}

F2(fit){I k,l,m,r;V*sv;
 RZ(a&&w);
 ASSERT(VERB&AT(a)&&NOUN&AT(w),EVDOMAIN);
 sv=VAV(a); m=sv->mr; l=sv->lr; r=sv->rr;
 switch(sv->id){
  case CLE:   case CGE:   case CNE:    case CEQ:    case CMATCH: case CEPS:
  case CIOTA: case CNUB:  case CSTAR:  case CFLOOR: case CCEIL:  case CSTILE:
  case COR:   case CAND:  case CABASE:
	       RZ(ctv(0,w=cvt(FL,w))); R CDERIV(CFIT,fitct1,fitct2,m,l,r);
  case CGT:    RZ(ctv(1,w=cvt(FL,w))); R CDERIV(CFIT,fitope,fitctv,m,l,r);
  case CLT:    R CDERIV(CFIT,fitbox, fitctv, m,l,r);
  case CROT:   R CDERIV(CFIT,shift1, shift2, m,l,r);
  case CEXP:   R CDERIV(CFIT,fitexp1,fitexp2,m,l,r);
  case CDOLLAR:
  case CPOUND:
  case CTAKE:
   ASSERT(!AR(w),EVRANK);
   R CDERIV(CFIT,sv->f1,fitfill,m,l,r);
  case CTHORN:
   ASSERT(!AR(w),EVRANK);
   RZ(w=vi(w)); k=*AV(w); ASSERT(0<k&&k<=NPP,EVDOMAIN);
   R CDERIV(CFIT,fitpp1,sv->f2,m,l,r);
  default:
   ASSERT(0,EVDOMAIN);
}}
