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
/* Verbs: Box & Open                                                       */

#include "j.h"
#include "v.h"


void fillv(t,n,v)I t,n;C*v;{I k=bp(t);K kv;
 if(t&NUMERIC)  memset(v,C0, k*n);
 else if(t&CHAR)memset(v,' ',n);
 else mvc(n*k,v,k,t&BOX?(C*)&mtv:(kv.k=zero,kv.v=mtv,(C*)&kv));
}

F1(filler){A z;I t; RZ(w); t=AT(w); GA(z,t,1,0,0); fillv(t,1L,AV(z)); R z;}

B homo(s,t)I s,t;{R s==t||s&NUMERIC&&t&NUMERIC||s&BOX+BOXK&&t&BOX+BOXK;}

A kast(b,w)B b;A w;{A z,*zv;K*wv;
 RZ(w);
 GA(z,BOX,AN(w),AR(w),AS(w));
 wv=(K*)AV(w); zv=(A*)AV(z); DO(AN(w), *zv++=b?wv->v:wv->k; ++wv;);
 R z;
}

F1(kbox){A z;I r,*s;
 RZ(w);
 r=AR(w);
 if(r){GA(z,BOX,2*AN(w),1+r,AS(w)); *(r+AS(z))=2;}
 else {GA(z,BOX,2,2,0); s=AS(z); s[0]=1; s[1]=2;}
 ICPY(AV(z),AV(w),AN(z));
 R z;
}


F1(box){RZ(w); R scalar4(BOX,ca(w));}

static void povtake(a,w,x)A a,w;C*x;{B b;C*v;I d,i,j,k,m,n,p,q,r,*s,*ss,*u,*uu,y;
 r=AR(w); n=AN(w); k=bp(AT(w)); v=(C*)AV(w);
 if(1>=r){MC(x,v,k*n); R;}
 m=AN(a); u=AV(a); s=AS(w);
 p=0; d=1; DO(r, if(u[m-1-i]==s[r-1-i]){d*=s[r-1-i]; ++p;}else break;);
 b=0; DO(r-p, if(b=1<s[i])break;);
 if(!b){MC(x,v,k*n); R;}
 k*=d; n/=d; ss=s+r-p; uu=u+m-p;
 for(i=0;i<n;++i){
  y=0; d=1; q=i; /* y=.a#.((-$a){.(($a)$1),$w)#:i */
  s=ss; u=uu; DO(r-p, j=*--s; y+=q%j*d; d*=*--u; q/=j;);
  MC(x+y*k,v,k); v+=k;
}}

F1(ope){PROLOG;A a,*v,y,z;C*x;I k,m,n,q=RMAX,r=0,*s,t=0,*u,*uu;
 RZ(w);
 n=AN(w); v=(A*)AV(w);
 if(!n)         R cvt(BOOL,w);
 if(AT(w)==BOXK)R ope(kast(1,w));
 if(AT(w)!=BOX) R ca(w);
 if(!AR(w))     R*v;
 DO(n, y=v[i]; q=MIN(q,AR(y)); r=MAX(r,AR(y));
     if(AN(y)){k=AT(y); t=t?t:k; ASSERT(homo(t,k),EVDOMAIN); t=MAX(t,k);});
 t=MAX(BOOL,t);
 RZ(a=apv(r,1L,0L)); u=AV(a); uu=u+r-q; DO(q,uu[i]=0;);
 DO(n, y=v[i]; s=AS(y); uu=u+r-AR(y); DO(AR(y),uu[i]=MAX(uu[i],s[i]);););
 m=prod(r,u);
 GA(z,t,n*m,r+AR(w),AS(w)); ICPY(AS(z)+AR(w),u,r);
 if(m){
  x=(C*)AV(z); fillv(t,AN(z),x); k=m*bp(t);
  DO(n, y=v[i]; if(m==AN(y)&&t==AT(y))MC(x,AV(y),k); else if(AN(y))
      povtake(a,t==AT(y)?y:cvt(t,y),x); x+=k;);
 }
 EPILOG(z);
}
