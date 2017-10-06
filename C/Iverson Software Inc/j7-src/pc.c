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
/* Parsing: Tacit Adverb/Conjunction Translator (s :21 and s :22)          */

#include "j.h"
#include "p.h"


static A tbs;
static A tdex;
static B tcj;
static A tia;
static A tlev;
static A ttie;

static B veq(a,w)A a,w;{RZ(a&&w); R!memcmp(VAV(a),VAV(w),sizeof(V));}

static F1(ltie){R advform(ttie,w);}

static F1(rtie){R advform(w,ttie);}

static A consa(w)AA w;{R w.t?w.t:advform(tdex,w.a);}

static A consc(w)AA w;{R w.t?w.t:hooko(tdex,advform(tdex,w.a));}

static F2(thook){A af,ag,ah,wf,wg;B b,p,q;C c,d;V*u,*v;
 RZ(a&&w);
 u=VAV(a); c=u->id; p=c==CHOOKO; af=u->f; ag=u->g; ah=u->h;
 v=VAV(w); d=v->id; q=d==CHOOKO; wf=v->f; wg=v->g;
 if(p&&(veq(af,tlev)||veq(af,tdex)))R hooko(af,thook(ag,w));
 if(veq(a,tia)&&ADV&AT(w))R w;
 if(veq(w,tia))R a;
 if((p||c==CFORKO)&&veq(tbs,p?ag:ah)&&q&&veq(tbs,wg)){
  u=VAV(p?af:ag); b=veq(ttie,u->f); v=VAV(wf);
  if(CADVF==u->id&&(b||veq(ttie,u->g))&&CADVF==v->id&&veq(ttie,v->g))
   if(b)R p?forko(af,wf,tbs):forko(hooko(af,ag),wf,tbs);
   else R p?hooko(rtie(tie(v->f,u->f)),tbs):forko(af,rtie(tie(v->f,u->f)),tbs);
 }
 if(q&&ADV&AT(wf)&AT(wg))R forko(a,wf,wg);
 R hooko(a,w);
}

static A tfork(a,fs,w)A a,fs,w;{A p,q;C c;V*u,*v;
 RZ(a&&fs&&w);
 if(tcj){
  u=VAV(a); v=VAV(w);
  if(veq(a,tlev)&&veq(w,tdex))R fs;
  p=CHOOKO==u->id&&veq(u->f,tlev)?u->g:a;
  q=CHOOKO==v->id&&veq(v->f,tdex)?v->g:w;
  R forko(p,fs,q);
 }else{
  if(CONJ&AT(fs))R ADV&AT(a)&&veq(w,tia)?thook(a,fs):hooko(tia,forko(a,fs,w));
  if(veq(a,tia))R thook(fs,w);
  u=VAV(a); c=u->id;
  if((c==CHOOKO||c==CFORKO)&&ADV&AT(u->g))
   R thook(u->f,tfork(c==CHOOKO?u->g:thook(u->g,u->h),fs,w));
  R forko(a,fs,w);
}}

static F1(gt1){R thook(w,tbs);}

static F2(gt2){R thook(a,thook(w,tbs));}


TACT(cmonad){AA z; z.a=df1(stack[e].a,stack[b].a); z.t=0; R z;}

TACT(cdyad){AA z; z.a=df2(stack[b].a,stack[e].a,stack[e-1].a); z.t=0; R z;}

TACT(cadv){A fs;AA x,z;
 x=stack[b]; fs=stack[e].a;
 z.a=df1(x.a,fs);
 z.t=x.t?thook(x.t,fs):0;
 R z;
}

TACT(cconj){A fs;AA x,y,z;
 x=stack[b]; y=stack[e]; fs=stack[e-1].a;
 z.a=df2(x.a,y.a,fs);
 switch((x.t?2:0)+(y.t?1:0)){
  case 0: z.t=0; break;
  case 1: z.t=thook(y.t,advform(x.a,fs)); break;
  case 2: z.t=thook(x.t,advform(fs,y.a)); break;
  case 3: z.t=tfork(x.t,fs,y.t);
 }
 R z;
}

TACT(cforkv){AA p,q,r,z;
 p=stack[b]; q=stack[1+b]; r=stack[e];
 z.a=folk(p.a,q.a,r.a);
 if(tcj)switch((p.t?4:0)+(q.t?2:0)+(r.t?1:0)){
  case 0: z.t=0; break;
  case 1: z.t=gt2(r.t,rtie(tie(p.a,q.a)));                  break;
  case 2:
  case 6: z.t=gt2(tfork(consa(p),ttie,consa(q)),ltie(r.a)); break;
  case 3: z.t=gt2(tfork(consa(q),ttie,consa(r)),rtie(p.a)); break;
  case 4: z.t=gt2(p.t,ltie(tie(q.a,r.a)));                  break;
  case 5: z.t=forko(consc(p),q.a,consc(r));                 break;
  case 7: z.t=gt1(tfork(tfork(consa(p),ttie,consa(q)),ttie,consa(r)));
 }else switch((p.t?4:0)+(q.t?2:0)+(r.t?1:0)){
  case 0: z.t=0; break;
  case 1: z.t=gt2(r.t,rtie(tie(p.a,q.a)));                  break;
  case 2: z.t=gt2(thook(q.t,rtie(p.a)),ltie(r.a));          break;
  case 3: z.t=gt2(tfork(q.t,ttie,r.t),rtie(p.a));           break;
  case 4: z.t=gt2(p.t,ltie(tie(q.a,r.a)));                  break;
  case 5: z.t=thook(tia,forko(thook(tlev,p.t),q.a,thook(tlev,r.t))); break;
  case 6: z.t=gt2(tfork(consa(p),ttie,consa(q)),ltie(r.a)); break;
  case 7: z.t=gt1(tfork(tfork(consa(p),ttie,consa(q)),ttie,consa(r)));
 }
 R z;
}

TACT(chookv){AA x,y,z;
 x=stack[b]; y=stack[e];
 z.a=hook(x.a,y.a);
 if(tcj)switch((x.t?2:0)+(y.t?1:0)){
  case 0:  z.t=0; break;
  case 2:  z.t=gt2(x.t,advform(ttie,y.a)); break;
  default: z.t=gt1(tfork(consa(x),ttie,consa(y)));
 }else switch((x.t?2:0)+(y.t?1:0)){
  case 0:  z.t=0; break;
  case 1:  z.t=gt2(y.t,rtie(x.a)); break;
  case 2:  z.t=gt2(x.t,ltie(y.a)); break;
  case 3:  z.t=gt1(tfork(consa(x),ttie,consa(y)));
 }
 R z;
}

TACT(cformo){AA p,q,r,z;
 p=stack[b]; q=stack[1+b]; r=stack[e];
 tfail=p.t||q.t||r.t;
 z.a=b==e-1?hooko(p,q):forko(p,q,r);
 z.t=0;
 R z;
}

TACT(ccurry){AA x,y,z;
 x=stack[b]; y=stack[e];
 tfail=x.t||y.t;
 z.a=advform(x.a,y.a);
 z.t=0;
 R z;
}

A xtrans(b,w)B b;A w;{PROLOG;A loc=local,z;
 RZ(w);
 tcj=b;
 ASSERT(CHAR&AT(w),EVDOMAIN);
 ASSERT(1>=AR(w),EVRANK);
 RZ(tia=advform(ds(CLEV),ds(CPLUS)));
 RZ(tdex=ds(CDEX));
 RZ(tlev=ds(CLEV));
 RZ(ttie=ds(CGRAVE));
 RZ(tbs =ds(CBSLASH));
 GA(local,SYMB,twprimes[0],1,0);
 RZ(tname=link(ds(CALPHA),   tcj?ds(COMEGA):mtv));
 RZ(tval =link(tcj?tlev:tia,tcj?tdex      :mtv));
 symbis(scnm(CALPHA),ds(CLEFT),local);
 if(tcj)symbis(scnm(COMEGA),ds(CLEFT),local);
 z=tparse(0,ttokens(w));
 if(z&&MARK&AT(z))z=colon(w,tcj?two:one);
 local=loc;
 EPILOG(z);
}
