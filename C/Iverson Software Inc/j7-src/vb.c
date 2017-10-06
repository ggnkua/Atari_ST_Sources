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
/* Verbs:  Boolean-valued                                                  */

#include "j.h"
#include "v.h"


SF2(blt,B,B, !*u&&*v)

SF2(ilt,I,B, *u<*v)

SF2(dlt,D,B, tlt(*u,*v))

F2(lt){R va2(a,w,CLT);}


SF2(ble,B,B, !*u||*v)

SF2(ile,I,B, *u<=*v)

SF2(dle,D,B, tle(*u,*v))

F2(le){R va2(a,w,CLE);}


SF2(bgt,B,B, *u&&!*v)

SF2(igt,I,B, *u>*v)

SF2(dgt,D,B, !tle(*u,*v))

F2(gt){R va2(a,w,CGT);}


SF2(bge,B,B, *u||!*v)

SF2(ige,I,B, *u>=*v)

SF2(dge,D,B, !tlt(*u,*v))

F2(ge){R va2(a,w,CGE);}


SF2(bnand,B,B, !(*u&&*v))

F2(nand){R va2(a,w,CNAND);}


SF2(bnor,B,B, !(*u||*v))

F2(nor){R va2(a,w,CNOR);}


SF2(beq,B,B, *u==*v)

SF2(ieq,I,B, *u==*v)

SF2(deq,D,B, teq(*u,*v))

SF2(jeq,Z,B, zeq(*u,*v))

static SF2(ceq,C,B, *u==*v)

static SF2(aeq,A,B, one==match(*u,*v))

static SF2(keq,K,B, one==match(u->k,v->k)&&one==match(u->v,v->v))

static SF2(neq,C,B, 0)


SF2(bne,B,B, *u!=*v)

SF2(ine,I,B, *u!=*v)

SF2(dne,D,B, !teq(*u,*v))

SF2(jne,Z,B, !zeq(*u,*v))

static SF2(cne,C,B, *u!=*v)

static SF2(ane,A,B, one!=match(*u,*v))

static SF2(kne,K,B, one!=match(u->k,v->k)||one!=match(u->v,v->v))

static SF2(nne,C,B, 1)


A neeq(a,w,l,r,id)A a,w;C id;I l,r;{B b;I an,at,t,wn,wt;SF f2;
 RZ(a&&w);
 an=AN(a); at=an?AT(a):BOOL;
 wn=AN(w); wt=wn?AT(w):BOOL;
 t=MAX(at,wt); b=id==CEQ;
 if(!(an&&wn&&homo(at,wt)))R r2a(a,w,BOOL,l,r,b?neq:nne);
 if(t!=at)RZ(a=cvt(t,a));
 if(t!=wt)RZ(w=cvt(t,w));
 if(b)f2=t&BOOL?beq:t&INT?ieq:t&FL?deq:t&CMPX?jeq:t&CHAR+NAME?ceq:t&BOX?aeq:keq;
 else f2=t&BOOL?bne:t&INT?ine:t&FL?dne:t&CMPX?jne:t&CHAR+NAME?cne:t&BOX?ane:kne;
 R r2a(a,w,BOOL,l,r,f2);
}

F2(eq){R neeq(a,w,0L,0L,CEQ);}

F2(ne){R neeq(a,w,0L,0L,CNE);}


F1(sclass){A x;
 RZ(w);
 x=indexof(w,AR(w)?w:ravel(w));
 R df2(repeat(eq(ii(w),x),x),x,slash(ds(CEQ)));
}

F1(nubsieve){R eq(ii(w),indexof(w,w));}

F2(match){PROLOG;A z;I at,*av,n,r,t,wt,*wv;
 RZ(a&&w);
 at=AT(a); av=AV(a); wt=AT(w); wv=AV(w);
 n=AN(a); r=AR(a); t=MAX(at,wt);
 if(n!=AN(w)||r!=AR(w)||ICMP(AS(a),AS(w),r))R zero;
 if(!n)R one;
 if(!homo(at,wt))R zero;
 if(t&BOX){A*u=(A*)av,*v=(A*)wv; DO(n, if(z=match(*u++,*v++),!z||z==zero)break;);}
 else if(t&BOXK){A y;
  RZ(y=reshape(shape(a),box(zero)));
  RZ(z=       match(at&BOX?y:kast(0,a),wt&BOX?y:kast(0,w)));
  z=z==zero?z:match(at&BOX?a:kast(1,a),wt&BOX?w:kast(1,w));
 }else{B b;
  if(t!=at){RZ(a=cvt(t,a)); av=AV(a);}
  if(t!=wt){RZ(w=cvt(t,w)); wv=AV(w);}
  if(!(0!=qct&&t&FL+CMPX))z=memcmp(av,wv,n*bp(t))?zero:one;
  else if(t&FL){D*u=(D*)av,*v=(D*)wv; DO(n,if(b=!teq(*u++,*v++))break;); z=b?zero:one;}
  else         {Z*u=(Z*)av,*v=(Z*)wv; DO(n,if(b=!zeq(*u++,*v++))break;); z=b?zero:one;}
 }
 EPILOG(z);
}

F2(eps){R lt(indexof(w,a),tally(w));}

F1(razein){R df2(w,box(raze(w)),amp(swap(ds(CEPS)),ds(COPE)));}

F2(ebar){A z;B*x;I i,k=0,m,n,p,td1[NALP];UC*u,*v;
 ASSERT((!AN(a)||CHAR&AT(a))&&(!AN(w)||CHAR&AT(w))&&1>=AR(a)&&1>=AR(w),EVNONCE);
 m=AN(a); u=(UC*)AV(a);
 n=AN(w); v=(UC*)AV(w);
 DO(NALP, td1[i]=1+m;); DO(m, td1[u[i]]=m-i;);
 GA(z,BOOL,n,AR(w),0); x=(B*)AV(z); memset(x,C0,n);
 p=1+n-m;
 while(k<p){for(i=0;i<m&&u[i]==v[k+i];++i); x[k]=i==m; k+=td1[v[k+m]];}
 R z;
}  /* Daniel M. Sunday, CACM 1990 8, 132-142 */
