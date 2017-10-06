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
/* Adverbs:  Utilities                                                     */

#include "j.h"
#include "a.h"


A ac1(f)AF f;{R fdef(0,VERB, f,0L, 0L,0L,0L, 0L, RMAXL,0L,0L   );}

A ac2(f)AF f;{R fdef(0,VERB, 0L,f, 0L,0L,0L, 0L, 0L,RMAXL,RMAXL);}

DF1(df1){RZ(   w&&self); R(VAV(self)->f1)(  w,self);}

DF2(df2){RZ(a&&w&&self); R(VAV(self)->f2)(a,w,self);}

A ds(c)C c;{I t;P*p;
 p=ps+psptr[(UC)c]; t=p->type;
 switch(t){
  case NOUN: R(A)p->f1;
  case ASGN: R scalar4(t,(I)(c==CASGN));
  case NAME: R scnm(c);
  case VERB:
  case ADV:
  case CONJ: R fdef(c,t, p->f1,p->f2, 0L,0L,0L, 0L, (I)p->mr,(I)p->lr,(I)p->rr);
  case LPAR:
  case RPAR: R scalar4(t,0L);
  default:   R mark;
}}

static F2(domerr){ASSERT(0,EVDOMAIN);}

A every(w,f)A w;AF f;{A*v,*x,z;
 RZ(w);
 GA(z,BOX,AN(w),AR(w),AS(w));
 x=(A*)AV(z); v=(A*)AV(w); DO(AN(w),RZ(*x++=f(*v++)););
 R z;
}

A fdef(id,t,f1,f2,fs,gs,hs,flag,m,l,r)C id;I t,flag,m,l,r;AF f1,f2;A fs,gs,hs;{A z;V*v;
 GA(z,t,1,0,0); v=VAV(z);
 v->f1=f1?f1:domerr;
 v->f2=f2?f2:domerr;
 v->f =fs;
 v->g =gs;
 v->h =hs;
 v->s =0;
 v->fl=flag;
 v->mr=m;
 v->lr=l;
 v->rr=r;
 v->id=id;
 R z;
}

B nameless(w)A w;{A f,g,h;C id;V*v;
 if(!w||NOUN&AT(w))R 1;
 v=VAV(w);
 id=v->id; f=v->f; g=v->g; h=v->h;
 R !(id==CTILDE&&CHAR&AT(f)) && nameless(f) && nameless(g) && (id==CFORK?nameless(h):1);
}
