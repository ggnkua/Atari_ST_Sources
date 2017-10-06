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
/* Conjunction:  Differentiation, Integration, Taylor's Series             */

#include "j.h"
#include "a.h"


static F1(cfn){R qq(w,zero);}

static A eval(s)C*s;{R parse(tokens(cstr(s)));}

static F2(fg){R folk(a,ds(CSTAR),w);}

static F1(icube){R atco(eval("* =/~@(i.@$)"),w);}

static F1(diffamp0){A f,g,h,x,y;B nf,ng;V*v;
 RZ(w);
 v=VAV(w);
 f=v->f; nf=NOUN&AT(f)?1:0;
 g=v->g; ng=NOUN&AT(g)?1:0;
 h=nf?g:f; x=nf?f:g;
 RZ(!AR(x));
 switch(ID(h)){
  case CPLUS:    R cfn(one);
  case CSTAR:    R cfn(x);
  case CMINUS:   R cfn(nf?neg1:one);
  case CDIV:     R nf?atop(amp(negate(x),ds(CDIV)),ds(CSQUARE)):cfn(recip(x));
  case CEXP:
   if(nf)R atop(amp(logar1(x),ds(CSTAR)),w);
   RZ(y=pcvt(INT,x));
   if(INT&AT(y))switch(*AV(y)){
    case 0:      R cfn(zero);
    case 1:      R cfn(one);
    case 2:      R ds(CDOUBLE);
   }
   R atop(amp(x,ds(CSTAR)),amp(ds(CEXP),decrem(x)));
  case CLOG:
   R nf?atop(ds(CDIV),amp(df1(x,h),ds(CSTAR))):
       atop(amp(negate(df1(x,h)),ds(CDIV)),eval("* *:@^."));
  case CCIRCLE:
   if(nf){
    RZ(x=vi(x));
    switch(*AV(x)){
     case 1:     R amp(two,h);
     case 2:     R atop(ds(CMINUS),amp(one,h));
     case 3:     R atop(atop(ds(CDIV),ds(CSQUARE)),amp(two,   h));
     case 5:     R amp(sc(6L),h);
     case 6:     R amp(sc(5L),h);
     case 7:     R atop(atop(ds(CDIV),ds(CSQUARE)),amp(sc(6L),h));
 }}}
 R 0;
}

static F1(diff0){A df=0,dg=0,dh=0,f,g,h;B nf,ng,vf,vg;C id;V*v;
 RZ(w);
 id=ID(w); v=VAV(w);
 f=v->f; nf=f&&NOUN&AT(f); vf=f&&!nf; if(vf)df=diff0(f);
 g=v->g; ng=g&&NOUN&AT(g); vg=g&&!ng; if(vg)dg=diff0(g);
 if(id==CAMP&&nf!=ng)R diffamp0(w);
 switch(id){
  case CLE:
  case CGE:
  case CLEFT:
  case CRIGHT:   R cfn(one);
  case CDOUBLE:  R cfn(two);
  case CSQUARE:  R ds(CDOUBLE);
  case CNOT:
  case CMINUS:   R cfn(neg1);
  case CHALVE:   R cfn(scf(0.5));
  case CDIV:     R eval("- @%@*:");
  case CSQRT:    R eval("-:@%@%:");
  case CEXP:     R w;
  case CLOG:     R ds(CDIV);
  case CJDOT:    R cfn(a0j1);
  case CCIRCLE:  R cfn(pie);
  case CRDOT:    R atop(ds(CJDOT),w);
  case CZERO: case CONE: case CTWO:   case CTHREE: case CFOUR:
  case CFIVE: case CSIX: case CSEVEN: case CEIGHT: case CNINE:
   R ds(CZERO);
  case CQQ:
   if(!AR(f)&&NUMERIC&AT(f)&&ng&&all1(eq(g,zero)))R cfn(zero);
   if(vf&&ng)R qq(df,g);
   break;
  case CAT:
   if(vf&&ng)R(h=df1(g,f))&&!AR(h)?cfn(h):0;
  case CATCO:
  case CAMP:
  case CAMPCO:
   if(vf&&vg)R folk(dg,ds(CSTAR),atop(df,g));
   break;
  case CFORK:
   h=v->h; dh=diff0(h);
   switch(ID(g)){
    case CPLUS:
    case CMINUS: R folk(df,g,dh);
    case CSTAR:  R folk(     fg(df,h),ds(CPLUS), fg(f,dh));
    case CDIV:   R folk(folk(fg(df,h),ds(CMINUS),fg(f,dh)),ds(CDIV),atop(ds(CSQUARE),h));
 }}
 R 0;
}

static F1(diffamp){A f,g,h,x;B nf,ng;I n;V*v;
 RZ(w);
 v=VAV(w);
 f=v->f; nf=NOUN&AT(f)?1:0;
 g=v->g; ng=NOUN&AT(g)?1:0;
 h=nf?g:f; x=nf?f:g;
 switch(ID(h)){
  case CROT:
  case CCANT:
  case CLBRACE:
  case CATOMIC:
  case CCYCLE:  
   if(nf)R atop(hook(eval("=/"),w),eval("i.@$"));
  case CPOLY:
   n=AN(f);
   if(nf&&1>=AR(f)&&(!n||NUMERIC&AT(f)))R 1<n?amp(behead(tymes(f,ii(f))),g):cfn(zero);
  default:      
   R 0;
}}

static F1(diff){A f,ff,g,h,z;B b,nf,ng,vf,vg;C id;I r;V*v;
 RZ(w=fix(w)); ASSERT(VERB&AT(w),EVDOMAIN);
 id=ID(w); v=VAV(w); r=mr(w);
 f=v->f; nf=f&&NOUN&AT(f); vf=f&&!nf;
 g=v->g; ng=g&&NOUN&AT(g); vg=g&&!ng;
 if(z=diff0(w))R id==CQQ&&ng&&all1(eq(g,zero))?z:icube(z);
 if(id==CAMP&&nf!=ng)R diffamp(w);
 switch(id){
  case CREV:     R eval("(|.=/])@(i.@$)");
  case CCANT:    R eval("(|:=/])@(i.@$)");
  case CSLASH:
   switch(vf?ID(f):0){
    case CPLUS:  R eval("({. =/ */@}.@$ | ])@(i.@$)");
   }
   break;
  case CBSLASH:
  case CBSDOT:
   if(CSLASH==ID(f)&&(ff=VAV(f)->f,ff&&VERB&AT(ff))){
    b=id==CBSDOT;
    switch(ID(ff)){
     case CPLUS: R eval(b ? "<:/~@(i.@$)" : ">:/~@(i.@$)");
   }}
   break;
  case CZERO: case CONE: case CTWO:   case CTHREE: case CFOUR:
  case CFIVE: case CSIX: case CSEVEN: case CEIGHT: case CNINE:
   R atop(amp(ds(CDOLLAR),zero),ds(CDOLLAR));
  case CQQ:
   if(NUMERIC&AT(f)&&ng){
    z=atop(amp(ds(CDOLLAR),zero),ds(CDOLLAR));
    R RMAX<mr(w)?z:qq(z,g);
   }
   if(vf&&ng)R qq(diff(f),g);
   break;
  case CAT:
  case CAMP:
   if(vf&&ng)R qq(df1(g,f),ainf);
   if(vf&&vg)R folk(diff(g),eval("+/ .*"),atop(diff(f),g));
   break;
  case CFORK:
   h=v->h;
   switch(ID(g)){
    case CPLUS:
    case CMINUS: R folk(diff(f),g,diff(h));
    case CSTAR:  R folk(     fg(diff(f),h),ds(CPLUS), fg(f,diff(h)));
    case CDIV:   R folk(folk(fg(diff(f),h),ds(CMINUS),fg(f,diff(h))),
                      ds(CDIV), atop(ds(CSQUARE),h));
 }}
 R 0;
}


static F1(intg){ASSERT(0,EVNONCE);}


static A dtab(a,d)A a;I d;{
 RZ(a);
 switch(SGN(d)){
  case -1: R dtab(intg(a),d+1);
  case  0: R a;
  case  1: R dtab(diff(a),d-1);
}}


#define DELTA  0.000001

static DF1(dapprox){A fs,f0,y,z,*zv;I d,i,n;V*sv=VAV(self);
 RZ(w);
 fs=sv->f; d=*AV(sv->g);
 if(1<d)RZ(fs=ddot(fs,sc(d-1)));
 RZ(f0=df1(w,fs));
 n=AN(w); RZ(y=ca(w));
 GA(z,BOX,n,AR(w),AS(w)); zv=(A*)AV(z);
 if(FL&AT(w)){D*wv,yy,*yv;
  wv=(D*)AV(w);
  yv=(D*)AV(y);
  for(i=0;i<n;++i){
   yv[i]+=yy=wv[i]?DELTA*wv[i]:DELTA;
   RZ(zv[i]=divide(minus(df1(y,fs),f0),scf(yy)));
   yv[i]-=yy;
 }}else{Z*wv,*yv;
  wv=(Z*)AV(w);
  yv=(Z*)AV(y);
  ASSERT(0,EVNONCE);
 }
 R ope(z);
}

static DF1(deriv1){DECLFG;A ff;I d;
 PREF1(deriv1);
 if(!(AT(w)&FL+CMPX))RZ(w=cvt(FL,w));
 RZ(gs=vi(gs)); d=*AV(gs);
 R (ff=dtab(fs,d)) ? df1(w,ff) : dapprox(w,self);
}

static DF2(deriv2){ASSERT(0,EVDOMAIN);}

F2(ddot){A z;I d,r;
 RZ(a&&w);
 ASSERT(VERB&AT(a)&&NOUN&AT(w),EVDOMAIN);
 RZ(w=vi(w)); d=*AV(w);
 ASSERT(!AR(w)&&0<=d,EVNONCE);
 R !AR(w)&&nameless(a)&&(z=dtab(a,d))?z:(r=mr(a),CDERIV(CDDOT,deriv1,deriv2,r,0L,r));
}


static F1(taypoly){R atop(amp(ds(CLBRACE),over(w,zero)),amp(tally(w),ds(CMIN)));}

static F1(tayamp){A f,g,h,x;B nf,ng;C c;V*v;
 RZ(w);
 v=VAV(w);
 f=v->f; nf=!!(NOUN&AT(f));
 g=v->g; ng=!!(NOUN&AT(g));
 h=nf?g:f; x=nf?f:g; c=ID(h);
 switch(c){
  case CPOLY: {ASSERT(nf,EVDOMAIN); R taypoly(x);}
  case CBANG: {ASSERT(nf&&all1(eq(x,two)),EVDOMAIN); R taypoly(eval("0 _0.5 0.5"));}
  default:    ASSERT(0,EVDOMAIN);
}}

AS1(taylor1, df1(w,taylor(fix(fs))))

F1(taylor){A f,g;B nf,ng,vf,vg;C id;V*v;
 RZ(w);
 ASSERT(VERB&AT(w),EVDOMAIN);
 if(!nameless(w))R ADERIV(CTAYLOR,taylor1,0L,RMAXL,RMAXL,RMAXL);
 id=ID(w); v=VAV(w);
 f=v->f; nf=f&&NOUN&AT(f); vf=f&&!nf;
 g=v->g; ng=g&&NOUN&AT(g); vg=g&&!ng;
 if(id==CAMP&&nf!=ng)R tayamp(w);
 switch(id){
  case CEXP:  R atop(ds(CDIV),ds(CBANG));
  case CFORK: R folk(taylor(f),g,taylor(v->h));
  default:    ASSERT(0,EVDOMAIN);
}}

CS1(tayn1, df1(w,tayn(fix(fs),gs)))

F2(tayn){A t;I n;
 RZ(a&&w);
 ASSERT(VERB&AT(a)&&NOUN&AT(w),EVDOMAIN);
 ASSERT(!AR(w),EVRANK);
 RZ(t=vib(sc(LONG_MAX),w));
 n=*AV(t);
 ASSERT(0<=n,EVDOMAIN);
 if(!nameless(a))R CDERIV(CTAYN,tayn1,0L,RMAXL,RMAXL,RMAXL);
 if(n<LONG_MAX)R amp(df1(iota(t),taylor(a)),ds(CPOLY));
 ASSERT(CEXP==ID(a),EVDOMAIN);
 R eval("'g (] * g >:@~: g@+:)^:_ ] 1 [. g=.p.&y.@(^ t.)@i.' : '' \" 0");
}

