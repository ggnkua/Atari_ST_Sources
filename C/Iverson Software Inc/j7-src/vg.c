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
/* Verbs: Grades                                                           */

#include "j.h"
#include "v.h"


#define ASCEND          1
#define DESCEND         0

#define COMP(f,T,Tp)    int f(a,b)I*a,*b;{I q;T*x=(T*)*a,*y=(T*)*b;Tp p;  \
                         DO(compn,if(p=*x++-*y++)break;);                 \
                         R p?SGN(p):(q=*++a-*++b,SGN(q));                 \
                        }

static I compn;

static COMP(compUC,UC,int)

static COMP(compI, I, I  )

static COMP(compD, D, D  )

static A gr(ascend,w)B ascend;A w;{PROLOG;A c,z;B b;I*cv,j,k,m,n,s=0,*v,*zv;UC*u;
 n=AN(w); v=AV(w); u=(UC*)v;
 b=INT&AT(w)?1:0; m=b?n:BOOL&AT(w)?2:256;
 GA(c,INT,m,1,0); cv=AV(c); memset(cv,C0,m*SZI);
 if(b){m=0; DO(n, k=v[i]; if(0>k)R mtv; if(k>m){m=k; if(m>=n)R mtv;} ++cv[k];); ++m;}
 else DO(n, ++cv[u[i]];);
 if(ascend)DO(m, k=cv[i]; cv[i]=s; s+=k;) else{j=m-1; DO(m, k=cv[j]; cv[j--]=s; s+=k;);}
 GA(z,INT,n,1,0); zv=AV(z);
 if(b)DO(n, zv[cv[v[i]]++]=i;) else DO(n, zv[cv[u[i]]++]=i;);
 EPILOG(z);
}

static A grade(ascend,w)B ascend;A w;{PROLOG;A y,z;C*wv;I j,k,m,wk,wt,*x,*yv;
 RZ(w);
 if(CMPX&AT(w))RZ(w=cvt(FL,w));
 wt=AT(w); wv=(C*)AV(w); m=IC(w); compn=aii(w); wk=compn*bp(wt);
 ASSERT(wt&BOOL+CHAR+INT+FL,EVDOMAIN);
 if(1>=m||!compn)R ii(w);
 if(1==compn&&wt&BOOL+CHAR+INT){RZ(z=gr(ascend,w)); if(AN(z))R z;}
 GA(y,INT,2*m,1,0); yv=AV(y);
 j=(I)wv-wk; DO(m, *yv++=j+=wk; *yv++=ascend?i:-i;);
 qsort(AV(y),m,2*SZI,wt&BOOL+CHAR?compUC:wt&INT?compI:compD);
 GA(z,INT,m,1,0); x=AV(z);
 yv=AV(y); j=ascend?1:2*m-1; k=ascend?2:-2; DO(m, x[i]=ascend?yv[j]:-yv[j]; j+=k;);
 EPILOG(z);
}

F1(grade1){R grade(ASCEND,w);}

F2(grade2){R from(grade1(w),a);}

F1(dgrade1){R grade(DESCEND,w);}

F2(dgrade2){R from(dgrade1(w),a);}
