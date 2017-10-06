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
/* Conjunction: Trains -- Fork, Hook, A-Trains, C-Trains                   */

#include "j.h"
#include "a.h"

#define TC(ft,gt,ht)    (ft&ADV?0:8)+(gt&NOUN?0:gt&VERB?2:gt&ADV?4:6)+(ht&ADV?0:1)
#define TDECL           V*sv=VAV(self);A fs=sv->f,gs=sv->g,hs=sv->h;


static DF1(fork1){DECLFG;A hs=sv->h;AF h1=VAV(hs)->f1;
 PREF1(fork1);
 R CLBKCO==ID(fs) ? g1(h1(w,hs),gs) : g2(f1(w,fs),h1(w,hs),gs);
}

static DF2(fork2){DECLFG;A hs=sv->h;AF h2=VAV(hs)->f2;
 PREF2(fork2);
 R CLBKCO==ID(fs) ? g1(h2(a,w,hs),gs) : g2(f2(a,w,fs),h2(a,w,hs),gs);
}

A folk(f,g,h)A f,g,h;{I l,m,r;
 RZ(f&&g&&h);
 ASSERT(VERB&AT(f)&AT(g)&AT(h),EVDOMAIN);
 m=MAX(mr(f),mr(h));
 l=MAX(lr(f),lr(h));
 r=MAX(rr(f),rr(h));
 R fdef(CFORK,VERB, fork1,fork2, f,g,h, 0L, m,l,r);
}


static CS1(hook1, f2(w,g1(w,gs),fs))

static CS2(hook2, f2(a,g1(w,gs),fs))

F2(hook){
 RZ(a&&w);
 ASSERT(VERB&AT(a)&AT(w),EVDOMAIN);
 R CDERIV(CHOOK,hook1,hook2,RMAXL,RMAXL,RMAXL);
}


static DF1(taaa){TDECL; R df1(df1(df1(w,fs),gs),hs);}

static DF2(taca){TDECL; R df2(df1(a,fs),df1(w,hs),  gs);}

static DF2(tacc){TDECL; R df2(df1(a,fs),df2(a,w,hs),gs);}

static DF2(tcaa){TDECL; R df1(df1(df2(a,w,fs),gs),hs);}

static DF2(tcca){TDECL; R df2(df2(a,w,fs),df1(w,hs),  gs);}

static DF2(tccc){TDECL; R df2(df2(a,w,fs),df2(a,w,hs),gs);}

static DF2(tcvc){TDECL; R folk(df2(a,w,fs),gs,df2(a,w,hs));}

A forko(f,g,h)A f,g,h;{AF f1=0,f2=0;I t=CONJ;
 RZ(f&&g&&h);
 switch(TC(AT(f),AT(g),AT(h))){
  case TC(ADV, ADV, ADV ): f1=taaa; t=ADV; break;
  case TC(ADV, CONJ,ADV ): f2=taca; break;
  case TC(ADV, CONJ,CONJ): f2=tacc; break;
  case TC(CONJ,ADV, ADV ): f2=tcaa; break;
  case TC(CONJ,CONJ,ADV ): f2=tcca; break;
  case TC(CONJ,CONJ,CONJ): f2=tccc; break;
  case TC(CONJ,VERB,CONJ): f2=tcvc; break;
  default:                 ASSERT(0,EVDOMAIN);
 }
 R fdef(CFORKO,t, f1,f2, f,g,h, 0L, 0L,0L,0L);
}

static DF1(taa){TDECL; R df1(df1(w,fs),gs);}

static DF1(tac){TDECL; R df2(df1(w,fs),w,gs);}

static DF2(tca){TDECL; R df1(df2(a,w,fs),gs);}

F2(hooko){AF f1=0,f2=0;I t=ADV;
 RZ(a&&w);
 switch(TC(AT(a),AT(w),0L)){
  case TC(ADV, ADV, 0L): f1=taa;         break;
  case TC(ADV, CONJ,0L): f1=tac;         break;
  case TC(CONJ,ADV, 0L): f2=tca; t=CONJ; break;
  default:               ASSERT(0,EVDOMAIN);
 }
 R fdef(CHOOKO,t, f1,f2, a,w,0L, 0L, 0L,0L,0L);
}


static DF1(aform){V*sv=VAV(self);A fs=sv->f,gs=sv->g;
 R CONJ&AT(fs) ? df2(w,gs,fs) : df2(fs,w,gs);
}

F2(advform){A x;B b,g;C id;I flag;
 RZ(a&&w);
 b=AT(a)&NOUN+VERB&&AT(w)&CONJ;
 ASSERT(b||AT(a)&CONJ&&AT(w)&NOUN+VERB,EVDOMAIN);
 x=b?a:w; g=BOX&AT(x);
 x=b?w:a; id=VAV(x)->id;
 flag= g&&b&&(id==CATDOT||id==CGRAVE||id==CGRCO) ? VGERL :
     g&&!b&&(id==CGRAVE||id==CPOWOP) ? VGERR : 0;
 R fdef(CADVF,ADV, aform,0L, a,w,0L, flag, 0L,0L,0L);
}


F1(gtrain){A hs,*hv,u;I j,n,t;
 RZ(w);
 n=AN(w);
 ASSERT(1>=AR(w),EVRANK);
 ASSERT(n,EVLENGTH);
 ASSERT(BOX&AT(w),EVDOMAIN);
 RZ(hs=every(w,fx)); hv=(A*)AV(hs);
 t=AT(hv[0]);
 ASSERT(t&VERB+ADV+CONJ,EVDOMAIN);
 t=t&VERB?t:ADV+CONJ;
 DO(n, ASSERT(t&AT(hv[i]),EVDOMAIN););
 if(t&VERB){
  u=hv[n-1]; j=n-3; DO((n-1)/2, RZ(u=folk(hv[j],hv[1+j],u));  j-=2;);
  R n%2 ? u : hook(*hv,u);
 }else{
  u=hv[0];   j=1;   DO((n-1)/2, RZ(u=forko(u,hv[j],hv[1+j])); j+=2;);
  R n%2 ? u : hooko(u,hv[n-1]);
}}
