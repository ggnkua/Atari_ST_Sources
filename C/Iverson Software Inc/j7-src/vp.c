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
/* Verbs:  Permutations                                                    */

#include "j.h"
#include "v.h"


static F1(ord){RZ(w); R AN(w)?cvt(INT,increm(df1(w,slash(ds(CMAX))))):sc(0L);}

F2(pind){A z;I j,m,n,*v;
 n=i0(a); m=-n;
 RZ(z=ca(vi(w))); v=AV(z);
 DO(AN(z), j=*v; ASSERT(m<=j&&j<n,EVINDEX); *v++=0>j?j+n:j;);
 R z;
}  /* positive indices */

F1(pinv){I m=0,n,*v;
 F1RANK(1,pinv,0);
 RZ(w=vi(w));
 n=AN(w); v=AV(w);
 DO(n, m=0>v[i]?MAX(m,-1-v[i]):MAX(m,v[i]);); m+=0<n;
 R indexof(pfill(sc(m),w),apv(m,0L,1L));
}  /* permutation inverse */

F2(pfill){PROLOG;A z;
 RZ(a&&w);
 RZ(a=vi(a));
 RZ(w=pind(a,w));
 RZ(z=over(less(iota(a),w),w));
 ASSERT(AN(z)==*AV(a),EVINDEX);
 EPILOG(z);
}

static F2(cfd){PROLOG;A b,p,q,y,*x,z;B*bv;I c,d,i,j,k,n,*pv,*qv,r,*v;
 RZ(w);
 RZ(w=pfill(a,w)); v=AV(w);
 n=AN(w); i=j=0;
 RZ(b=reshape(tally(w),zero)); bv=(B*)AV(b);
 GA(p,INT,n,1,0); pv=AV(p);
 GA(q,INT,n,1,0); qv=AV(q);
 GA(z,BOX,n,1,0); x=(A*)AV(z);
 for(;;){
  while(j<n&&bv[j])j++; if(j>=n)break;
  k=d=r=0; c=j;
  do{bv[c]=1; d=MAX(d,c); r=c==d?k:r; qv[k++]=c; c=v[c];}while(c!=j);
  pv[i]=d; RZ(x[i++]=rotate(sc(r),take(sc(k),q)));
 }
 RZ(y=sc(i)); z=grade2(take(y,z),take(y,p)); EPILOG(z);
}  /* cycle from direct*/

static F2(dfc){PROLOG;A b,q,*v,z;B*bv;I c,j,qn,*qv,*x;
 RZ(a&&w);
 ASSERT(!AR(a)&&INT&AT(a)&&0<=*AV(a),EVINDEX);
 RZ(b=reshape(a,one)); bv=(B*)AV(b);
 RZ(z=iota(a)); x=AV(z);
 v=(A*)AV(w);
 for(j=AN(w)-1;0<=j;j--){
  RZ(q=pind(a,v[j])); qv=AV(q); qn=AN(q);
  if(!qn)continue;
  DO(qn, ASSERT(bv[qv[i]],EVINDEX); bv[qv[i]]=0;); DO(qn,bv[qv[i]]=1;);
  c=x[qv[0]]; DO(qn-1,x[qv[i]]=x[qv[i+1]];); x[qv[qn-1]]=c;
 }
 EPILOG(z);
}  /* direct from cycle */

F1(cdot1){F1RANK(1,cdot1,0); R BOX&AT(w)?dfc(ord(raze(w)),w):cfd(ord(w),w);}

F2(cdot2){RZ(a&&w); R from((BOX&AT(a)?dfc:pfill)(tally(w),a),w);}

static F1(dfr){A z;I c,d,j,n,*v,*x;
 F1RANK(1,dfr,0);
 n=AN(w); v=AV(w);
 RZ(z=ii(w)); x=AV(z);
 DO(n-1, j=i; c=x[j+v[j]]; DO(1+v[j], d=x[j+i]; x[j+i]=c; c=d;););
 R z;
}  /* direct from reduced */

static F1(rfd){A z;I j=0,k,n,*v,*x;
 F1RANK(1,rfd,0);
 n=AN(w); v=AV(w);
 RZ(z=ca(w)); x=AV(z);
 DO(n-1, ++j; k=0; DO(n-j, k+=v[j]>v[j+i];); x[j]=k;);
 R z;
}  /* reduced from direct */

F1(adot1){A y;I n;
 F1RANK(1,adot1,0);
 RZ(y=BOX&AT(w)?cdot1(w):pfill(ord(w),w));
 n=IC(y);
 R base2(apv(n,n,-1L),rfd(y));
}

F2(adot2){A m;I n;
 RZ(a&&w);
 n=IC(w);
 RZ(m=fact(sc(n)));
 ASSERT(all1(le(negate(m),a))&&all1(lt(a,m)),EVINDEX);
 R from(dfr(vi(abase2(apv(n,n,-1L),a))),w);
}
