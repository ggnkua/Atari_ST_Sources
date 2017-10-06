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
/* Adverbs:  Inverse & Identity Functions                                  */

#include "j.h"
#include "a.h"


static B ip(w,c,d)A w;C c,d;{A f,g;V*v;
 v=VAV(w); f=v->f; g=v->g;
 R VERB&AT(f)&&CSLASH==ID(f)&&c==ID(VAV(f)->f)&&VERB&AT(g)&&d==ID(g);
}

static F1(invdef){A h;
 h=atop(atop(ds(CEQ),ds(CIOTA)),ds(CPOUND));
 R obverse(folk(atop(atco(ds(CDOMINO),w),h),dot(slash(ds(CPLUS)),ds(CSTAR)),
     ds(CRIGHT)), w);
}

static F1(invamp){A f,ff,g,h,x,y;B nf,ng;C c,*yv;V*v;
 RZ(w);
 v=VAV(w);
 f=v->f; nf=!!(NOUN&AT(f));
 g=v->g; ng=!!(NOUN&AT(g));
 h=nf?g:f; x=nf?f:g; c=ID(h);
 switch(c){
  case CPLUS:   R amp(ds(CMINUS),x);
  case CMINUS:  R amp(x,ds(nf?CMINUS:CPLUS));
  case CSTAR:   R amp(ds(CDIV),x);
  case CDIV:    R amp(x,ds(nf?CDIV:CSTAR));
  case CROOT:   R amp(ds(nf?CEXP:CLOG),x);
  case CEXP:    R amp(x,ds(nf?CLOG:CROOT));
  case CLOG:    R nf?amp(x,ds(CEXP)):amp(ds(CROOT),x);
  case CJDOT:   R nf?atop(inv(ds(CJDOT)),amp(ds(CMINUS),x)):amp(ds(CMINUS),jdot1(x));
  case CRDOT:   R nf?atop(inv(ds(CRDOT)),amp(ds(CDIV  ),x)):amp(ds(CDIV  ),rdot1(x));
  case CLBRACE: R nf?amp(pinv(x),h):amp(x,ds(CIOTA));
  case CCOMMA:  R obverse(amp(sc(nf?IC(x):-IC(x)),ds(CDROP)),w);
  case CBASE:   if(nf)R amp(x,ds(CABASE));   break;
  case CABASE:  if(nf)R amp(x,ds(CBASE));    break;
  case CCANT:   if(nf)R amp(pinv(x),h);      break;
  case CROT:
  case CCIRCLE: if(nf)R amp(negate(x),h);    break;
  case CIOTA:
   if(!nf)break;
   R obverse(atop(amp(ds(CLBRACE),x),amp(tally(x),ds(CSTILE))),w);
  case CATOMIC:
  case CCYCLE:
   if(!(nf&&AR(x)<=(c==CCYCLE)))break;
   R obverse( folk(atop(atop(ds(CGRADE),w),atop(ds(CIOTA),ds(CPOUND))),
       ds(CLBRACE),ds(CRIGHT)), w);
  case CDROP:
   if(!(nf&&1>=AR(x)))break;
   RZ(x=cvt(INT,x));
   RZ(y=eps(v2(-1L,1L),signum(x))); yv=(C*)AV(y);
   f=amp(mag(x),ds(CPLUS));
   g=1==AN(x)?ds(CPOUND):atop(amp(tally(x),ds(CTAKE)),ds(CDOLLAR));
   h=!yv[1]?f:atop(!yv[0]?ds(CMINUS):amp(negate(signum(x)),ds(CSTAR)),f);
   R obverse(hook(swap(ds(CTAKE)),atop(h,g)),w);
  case CDOMINO:
   if(!(2==AR(x)&&*AS(x)==*(1+AS(x))))break;
   RZ(ff=dot(slash(ds(CPLUS)),ds(CSTAR)));
   R nf?atop(h,amp(ff,minv(x))):amp(x,ff);
  case CDOT:
   if(ip(h,CPLUS,CSTAR)){
    ASSERT(2==AR(x),EVRANK);
    ASSERT(*AS(x)==*(1+AS(x)),EVLENGTH);
    R nf?amp(ds(CDOMINO),x):amp(h,minv(x));
 }}
 R invdef(w);
}

static F1(alt){R atop(amp(ds(CDOLLAR),v2(1L,-1L)),ds(CPOUND));}

static F1(shl){R amp(one,fit(ds(CROT),w));}

static F1(shr){R fit(ds(CROT),w);}

static F1(sl1_){R qq(qq(slash(w),one),ainf);}

F1(inv){A f,ff,g;AF shf;B b,nf,ng,vf,vg;C c,id;V*v;
 RZ(w=fix(w)); ASSERT(VERB&AT(w),EVDOMAIN);
 id=ID(w); v=VAV(w);
 if(c=ps[psptr[(UC)id]].inv)R ds(c);
 f=v->f; nf=f&&NOUN&AT(f); vf=f&&!nf;
 g=v->g; ng=g&&NOUN&AT(g); vg=g&&!ng;
 if(id==CAMP&&nf!=ng)R invamp(w);
 switch(id){
  case CCIRCLE:  R amp(ds(CDIV),pie);
  case CJDOT:    R amp(ds(CDIV),a0j1);
  case CRDOT:    R atop(amp(ds(CDIV),a0j1),ds(CLOG));
  case CRECT:    R obverse(sl1_(ds(CJDOT)),w);
  case CPOLAR:   R obverse(sl1_(ds(CRDOT)),w);
  case CDGRADE:  R atop(ds(CGRADE),ds(CREV));
  case CWORDS:   R obverse(atop(ds(CRAZE),
                     qq(under(amp(scc(' '),ds(CCOMMA)),ds(COPE)),one)  ),w);
  case CQQ:      if(vf)R qq(inv(f),g);              break;
  case COBVERSE: if(vf&&vg)R obverse(g,f);          break;
  case CPOWOP:   if(vf&&-1==i0(g))R f;              break;
  case CAT:
  case CAMP:     if(vf&&vg)R atop(inv(g),inv(f));   break;
  case CATCO:
  case CAMPCO:   if(vf&&vg)R atco(inv(g),inv(f));   break;
  case CTILDE:
   switch(ID(f)){
    case CPLUS:  R ds(CHALVE);
    case CSTAR:  R ds(CSQRT);
    case CJDOT:  R amp(ds(CDIV),increm(a0j1));
    case CLAMIN: R obverse(ds(CHEAD),w);
    case CSEMICO:R obverse(atop(ds(COPE),ds(CHEAD)),w);
    case CCOMMA: R obverse( hook(swap(ds(CTAKE)),
                     atop(atop(ds(CFLOOR),ds(CHALVE)),ds(CPOUND))), w);
    case CEXP:   R obverse(qq(colon(cstr("(- -&b@(*^.) % >:@^.)^:_ b=.^.y."),
                     mtv),zero),w);
    }
    break;
  case CBSLASH:
  case CBSDOT:
   if(CSLASH==ID(f)&&(ff=VAV(f)->f,ff&&VERB&AT(ff))){
    b=id==CBSDOT; shf=b?shl:shr;
    switch(ID(ff)){
     case CPLUS: R obverse(hook(ds(CMINUS),shf(zero)),w);
     case CSTAR: R obverse(hook(ds(CDIV  ),shf(one )),w);
     case CEQ:   R obverse(hook(ds(CEQ   ),shf(one )),w);
     case CNE:   R obverse(hook(ds(CNE   ),shf(zero)),w);
     case CMINUS:
      R b ? obverse(hook(ds(CPLUS),shf(zero)),w) :
          obverse(folk(hook(ds(CMINUS),shf(zero)),qq(ds(CSTAR),neg1),alt(mark)),w);
     case CDIV:
      R b ? obverse(hook(ds(CSTAR),shf(one )),w) :
          obverse(folk(hook(ds(CDIV  ),shf(one )),qq(ds(CEXP ),neg1),alt(mark)),w);
 }}}
 R invdef(w);
}

F1(iden){A f,g,r,s,t,x=0;V*v;
 RZ(w=fix(w)); ASSERT(VERB&AT(w),EVDOMAIN);
 v=VAV(w); f=v->f; g=v->g;
 RZ(s=ds(CDOLLAR));
 RZ(r=atop(ds(CBEHEAD),s));
 RZ(t=atop(ds(CIOTA),amp(one,ds(CTAKE))));
 switch(ID(w)){
  case CCOMMA:  R atop(atop(atop(ds(CIOTA),amp(zero,ds(CCOMMA))),amp(two,ds(CDROP))),s);
  case CDOT:    if(!(ip(w,CPLUS,CSTAR)||ip(w,COR,CAND)||ip(w,CNE,CAND)))break;
  case CDOMINO: R atop(ds(CEQ),atop(t,r));
  case CCYCLE:
  case CLBRACE: R atop(t,r);
  case CSLASH:  if(VERB&AT(f))R atop(iden(f),ds(CPOUND)); break;
  case CPLUS: case CMINUS: case CSTILE: case CNE:
  case CGT:   case CLT:    case COR:    case CJDOT:   case CRDOT:
                x=zero; break;
  case CSTAR: case CDIV:   case CEXP:   case CROOT:   case CBANG:
  case CEQ:   case CGE:    case CLE:    case CAND:
                x=one; break;
  case CMAX:    x=negate(ainf); break;
  case CMIN:    x=ainf; break;
  case CUNDER:  x=df1(df1(mtv,iden(f)),inv(g)); break;
  case CBOOL:
   switch(i0(f)){
    case 2: case 4: case 5:  case 6:  case 7:
                x=zero; break;
    case 1: case 9: case 11: case 13:
                x=one;
 }}
 if(x)R atop(amp(s,x),r);
 ASSERT(0,EVDOMAIN);
}
