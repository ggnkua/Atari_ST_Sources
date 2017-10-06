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
/* Symbol Table & Associates                                               */

#include "j.h"
#include "x.h"
#include "d.h"

I twprimes[]={61,139,271,523,1021,2029,4093,8221,16363,0}; /* p-2 also prime */

A local;          /* local symbol table           */
A global;         /* current global symbol table  */

static A gst;     /* "home" global symbol table   */
static A mgst;    /* locales symbol table         */

B symbinit(){
 GGA(global,SYMB,twprimes[3],1); gst=global;
 GGA(mgst,  SYMB,twprimes[1],1);
 R 1;
}

static F1(stdnm){C c,*s;I j,n,p,q;
 RZ(vs(w));
 n=AN(w); s=(C*)AV(w);
 j=0;   DO(n, if(' '!=s[j++])break;); p=n?j-1:0;
 j=n-1; DO(n, if(' '!=s[j--])break;); q=n?(n-2)-j:0;
 if(p||q)RZ(w=drop(sc(p),drop(sc(-q),w)));
 c=spellin(n,AV(w));
 R c&&1!=c? scc(c) : w;
}

static I probe(a,symb,is)A a,symb;C is;{A t;C*av;I c,i,k,m;SY*tab;
 av=(C*)AV(a); tab=(SY*)AV(symb); m=AN(symb);
 k=256L*(UC)*av+*(av+AN(a)-1);
 i=k%m;
 c=1+k%(m-2);
 if(is&&symb==global)while(tab[i].val)i-=i<c?c-m:c;
 else while((t=tab[i].name)&&strcmp(av,(C*)AV(t)))i-=i<c?c-m:c;
 R i;
} /* D.E. Knuth, Algorithm D, "Searching & Sorting", p. 521. */

F2(srd){R(probe(a,w,0)+(SY*)AV(w))->val;}

F1(srdlg){A g,z;
 RZ(w);
 if(stname(w,&w,&g)){RZ(z=stfind(g)); R srd(w,z);}
 R local&&(z=srd(w,local))?(z==mark?0:z):srd(w,global);
}

static B sex(a,w,b,is)A a,w;B b,is;{B z;SY*e;
 e=probe(a,w,0)+(SY*)AV(w);
 z=e->val&&e->val!=mark;
 if(z&&!b){B g=w==global;
  if(g||is){fa(e->name); e->name=0;}
  fa(e->val); e->val=g?0:mark;
 }
 R z;
}

static F1(stcreate){A g; RZ(w); GGA(g,SYMB,twprimes[3],1); symbis(w,g,mgst); R g;}
     /* create locale name */

A symbis(a,w,symb)A a,w,symb;{B b;SY*e;A g;
 RZ(a&&w);
 if(stname(a,&a,&g)){
  RZ(a);
  symb=stfind(g);
  if(!symb){symb=stcreate(g); RZ(symb);}
 }
 a=ra(a); w=ra(w);
 b=CESC2==cl(a);
 ASSERT(!(sex(a,symb,b,1)&&b),EVNOTASGN);
 e=probe(a,symb,1)+(SY*)AV(symb);
 e->name=a; e->val=w;
 if(VERB==AT(w)) (VAV(w))->s=ra(a);
 R mark;
}

static B x6;

static B ex1(w)A w;{A y;B b;
 RZ(y=stdnm(w));
 R!vnm(AN(y),AV(y))?0:(b=x6!=(CESC2==cl(y)),
    !((local&&sex(y,local,b,0)||sex(y,global,b,0))&&b));
}

static F1(ex){A*wv,z;B*zv;
 RZ(w);
 ASSERT(BOX&AT(w),EVDOMAIN);
 GA(z,BOOL,AN(w),AR(w),AS(w));
 wv=(A*)AV(w); zv=(B*)AV(z); DO(AN(w),RE(*zv++=ex1(*wv++)););
 R z;
}

F1(ex55){x6=0; R ex(w);}

F1(ex56){x6=1; R ex(w);}


I nc(w)A w;{R !w ? 0 : NOUN&AT(w) ? 2 : VERB&AT(w) ? 3 : ADV&AT(w) ? 4 : 5;}

F1(ncx){A t,y;
 F1RANK(0,ncx,0);
 R sc(BOX&AT(w) && (t=*(A*)AV(w)) && AN(t) && 1>=AR(t) && AT(t)&CHAR+NAME &&
  (y=stdnm(t)) && vnm(AN(y),AV(y)) ? nc(srdlg(y)) : -1L);
}

static C nla[256];
static I nlmask[] = {0, 0, NOUN, VERB, ADV, CONJ};

static A nls(tm,w)I tm;A w;{A x,y,*yv;C b,c;I i,k=0,n;SY*e;
 RZ(w);
 n=AN(w); e=(SY*)AV(w);
 GA(y,BOX,n,1,0); yv=(A*)AV(y);
 for(i=0;i<n;i++){
  x=e->name;
  b=x&&e->val&&tm&AT(e->val)&&nla[c=cf(x),(UC)c];
  if(b){*yv++=0<=c&&c<=127?str(AN(x),AV(x)):spellout(c); ++k;}
  ++e;
 }
 R take(sc(k),y);
}

static B nlmc(w)A w;{SY*e=(SY*)AV(w); DO(AN(w), if(e->name&&e->val)R 1; ++e;); R 0;}
     /* 1 if symbol table w is non-empty */

static F1(nlm){A x,y,*yv;I k=0;SY*e=(SY*)AV(w);
 GA(y,BOX,AN(w),1,0); yv=(A*)AV(y);
 DO(AN(w), x=e->name; if(x&&nlmc(e->val))yv[k++]=str(AN(x),AV(x)); ++e;);
 R take(sc(k),y);
}

static F1(nlx){A z;B f=0;I tm=0,*v,x;
 RZ(w=vi(w));
 v=AV(w);
 DO(AN(w), x=*v; ASSERT(0<x&&x<7,EVDOMAIN); if(x==6)f=1; else tm+=nlmask[x]; ++v;);
 RZ(z=nls(tm,global));
 if(local)RZ(z=over(nls(tm,local),z));
 if(f)RZ(z=over(nlm(mgst),z));
 RZ(z=grade2(z,ope(z)));
 if(local||f)z=repeat(ne(z,behead(over(z,jot))),z);
 R z;
}

F1(nl1){DO(256,nla[i]=1;); R nlx(w);}

F2(nl2){UC*u;
 RZ(a&&w);
 ASSERT(CHAR&AT(a),EVDOMAIN);
 u=(UC*)AV(a); DO(256,nla[i]=0;); DO(AN(a),nla[*u++]=1;);
 R nlx(w);
}

F1(onm){RZ(w=stdnm(ope(w))); ASSERT(vnm(AN(w),AV(w)),EVILNAME); R w;}

F1(symbrd){A z; RZ(w); ASSERT(z=srdlg(w),EVVALUE); R z;}

B vnm(n,s)I n;C*s;{C c=*s;
 RZ(n);
 if(1==n&&(c==CALPHA||c==COMEGA||c==CGOTO))R 1;
 if(CA!=ctype[s[0]]) R 0;
 DO(n-1, c=ctype[s[i]]; RZ(c==CA||c==C9););
 c=s[n-1];
 if('_'==c){DO(n-1, if('_'==s[i]) R 1;); R 0;}
 c=ctype[c];
 R (c==CA||c==C9||c==CC);
}


/* stname - return 0 if not abc_def_ name, or 1 and abc and def */
B stname(A w, A *pn, A *pg)
{
 A z; C *p,*q,*r;I n;
 p=(C*)AV(w);
 q=-1+AN(w)+p;
 if('_'!=*q) R 0;
 r=q; q=q-1;
 *pn=0; *pg=0;
 while((p<q) && '_'!=*q)--q;
 if(p==q) R 0;
 n=-1+r-q;
 if(n){z=str(n,q+1); if(!z){*pn=0; R 1;}; *pg=z;}
 GA(z, NAME, q-p, 1, 0);
 *pn=z;
 if(z) memcpy(AV(z), AV(w), q-p);
 R 1;
}

/* stfind - find st from mgst name */
F1(stfind){ R w? srd(w, mgst) : gst;}
