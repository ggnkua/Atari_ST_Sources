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
/* Interpreter Utilities                                                   */

#include "j.h"


I aii(w)A w;{I m=IC(w); R m?AN(w)/m:prod(AR(w)-1,1+AS(w));}

B all0(w)A w;{RZ(w); R memchr(AV(w),C1,AN(w))?0:1;}

B all1(w)A w;{RZ(w); R memchr(AV(w),C0,AN(w))?0:1;}

A apv(n,b,m)I n,b,m;{A z;I j=b-m,p=b+m*(n-1),*x;
 GA(z,INT,n,1,0); x=AV(z);
 if(n)switch(m){
  case  0: mvc(n*SZI,x,SZI,&b); break;
  case -1: while(j!=p)*x++=--j; break;
  case  1: while(j!=p)*x++=++j; break;
  default: while(j!=p)*x++=j+=m;
 }
 R z;
}

I bp(t)I t;{
 switch(t){
  case BOOL:  R sizeof(B);
  case NAME:
  case CHAR:  R sizeof(C);
  case LPAR:
  case RPAR:
  case ASGN:
  case MARK:
  case INT:   R sizeof(I);
  case FL:    R sizeof(D);
  case CMPX:  R sizeof(Z);
  case BOX:   R sizeof(A);
  case BOXK:  R sizeof(K);
  case VERB:
  case ADV:
  case CONJ:  R sizeof(V);
  case SYMB:  R sizeof(SY);
  default:    jsignal(EVSYSTEM); JSPR("bp: 0x%lx", t); jputc(CNL); R 0;
}}

C cf(w)A w;{RZ(w); R*(C*)AV(w);}

C cl(w)A w;{RZ(w); R*((C*)AV(w)+AN(w)-1);}

I coerce1(w,mt)A*w;I mt;{I t,wt;
 RZ(*w);
 if(!AN(*w))R mt;
 wt=AT(*w); t=MAX(wt,mt);
 ASSERT(wt&NUMERIC,EVDOMAIN);
 if(t!=wt)RZ(*w=cvt(t,*w));
 R t;
}

I coerce2(a,w,mt)A*a,*w;I mt;{I at,t,wt;
 RZ(*a&&*w);
 at=AN(*a)?AT(*a):0;
 wt=AN(*w)?AT(*w):0;
 t=MAX(at,wt); t=MAX(t,mt);
 if(!t)R MAX(AT(*a),AT(*w));
 if(t!=at)RZ(*a=cvt(t,*a));
 if(t!=wt)RZ(*w=cvt(t,*w));
 R t;
}

A cstr(s)C*s;{R str((I)strlen(s),s);}

B evoke(w)A w;{V*v=VAV(w); R CTILDE==v->id&&CHAR&AT(v->f);}

C*fi(s,v)C*s;I*v;{C*t; *v=strtol(s,&t,10); ASSERT(0<=*v&&s!=t,EVDOMAIN); R t;}

F1(ii){RZ(w); R apv(IC(w),0L,1L);}

I i0(w)A w;{RZ(w=vi(w)); ASSERT(!AR(w),EVRANK); R*AV(w);}

void mvc(m,z,n,w)I m,n;UC*z,*w;{I p=n,r;
 if(1==n)memset(z,*w,m);
 else{MC(z,w,MIN(p,m)); while(m>p){r=m-p; MC(z+p,z,MIN(p,r)); p+=p;}}
}

I prod(n,v)I n,*v;{I z=1; DO(n,if(!v[i])R 0;); DO(n,z*=v[i];); R z;}

F1(rankle){R!w||AR(w)?w:ravel(w);}

A sc(k)I k;{A z; GA(z,INT,1,0,0); *AV(z)=k; R z;}

A scalar4(t,v)I t,v;{A z; GA(z,t,1,0,0); *AV(z)=v; R z;}

A scc(c) C c;{A z; GA(z,CHAR,1,0,0); *(C*)AV(z)=c; R z;}

A scf(x) D x;{A z; GA(z,FL  ,1,0,0); *(D*)AV(z)=x; R z;}

A scnm(c)C c;{A z; GA(z,NAME,1,0,0); *(C*)AV(z)=c; R z;}

A str(n,s)I n;C*s;{A z; GA(z,CHAR,n,1,0); MC(AV(z),s,n); R z;}

F1(vi){RZ(w); ASSERT(!AN(w)||AT(w)&NUMERIC,EVDOMAIN); R INT&AT(w)?w:cvt(INT,w);}

F2(vib){A z;B b;
 RZ(w);
 b=AT(w)&BOOL+INT;
 ASSERT(b||all1(eq(w,floor1(w))),EVDOMAIN);
 z=maximum(negate(a),minimum(a,w));
 R b?z:icvt(z);
}

F1(vn){RZ(w); ASSERT(NOUN&AT(w),EVSYNTAX); R w;}

F1(vs){RZ(w); ASSERT(!AN(w)||AT(w)&CHAR+NAME,EVDOMAIN); ASSERT(1>=AR(w),EVRANK); R w;}

A v2(a,b)I a,b;{A z;I*x; GA(z,INT,2,1,0); x=AV(z); *x++=a; *x=b; R z;}


I mr(w)A w;{R VAV(w)->mr;}

I lr(w)A w;{R VAV(w)->lr;}

I rr(w)A w;{R VAV(w)->rr;}
