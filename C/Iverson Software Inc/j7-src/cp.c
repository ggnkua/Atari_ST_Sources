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
/* Conjunctions:  Power Operator ^: and Associates                         */

#include "j.h"
#include "a.h"


static DF1(ply1){PROLOG;DECLFG;A hs,j,x,*xv,y,z;I i,*jv,k,m,n,*nv,old,p=0;
 hs=sv->h; m=AN(hs); nv=AV(hs);
 RZ(j=grade1(ravel(hs))); jv=AV(j);
 GA(x,BOX,m,AR(hs),AS(hs)); xv=(A*)AV(x);
 while(p<m&&0>nv[jv[p]])p++;
 if(p<m){
  RZ(z=ca(w));
  n=nv[jv[m-1]]; k=p;
  while(k<m&&!nv[jv[k]]){xv[jv[k]]=z; ++k;}
  old=tbase+ttop;
  for(i=1;i<=n;++i){
   RZ(z=f1(y=z,fs));
   if(all1(match(y,z))){DO(m-k, xv[jv[k+i]]=z;); break;}
   while(k<m&&i==nv[jv[k]]){xv[jv[k]]=z; ++k;}
   gc3(x,z,0L,old);
 }}
 if(0<p){
  RZ(fs=inv(fs)); f1=VAV(fs)->f1;
  RZ(z=ca(w));
  n=nv[jv[0]]; k=p-1;
  old=tbase+ttop;
  for(i=-1;i>=n;--i){
   RZ(z=f1(y=z,fs));
   if(all1(match(y,z))){DO(1+k, xv[jv[i]]=z;); break;}
   while(0<=k&&i==nv[jv[k]]){xv[jv[k]]=z; --k;}
   gc3(x,z,0L,old);
 }}
 z=ope(x); EPILOG(z);
}

static CS2(ply2,  df1(w,powop(amp(a,fs),gs)))

static CS1(powv1, df1(w,powop(fs,g1(w,gs))))

static CS2(powv2, df1(w,powop(amp(a,fs),g2(a,w,gs))))

static CS1(inv1,  df1(w,inv(fs)))

F2(powop){A hs;
 RZ(a&&w);
 switch(CONJCASE(a,w)){
  case VN:
   if(BOX&AT(w))R gconj(a,w,CPOWOP);
   RZ(hs=vib(sc(LONG_MAX),w));
   if(AR(hs)||-1!=*AV(hs))R fdef(CPOWOP,VERB, ply1,ply2, a,w,hs, 0L, RMAXL,RMAXL,RMAXL);
   R nameless(a) ? inv(a) : CDERIV(CPOWOP,inv1,0L,RMAXL,RMAXL,RMAXL);
  case VV:
   R CDERIV(CPOWOP,powv1,powv2,RMAXL,RMAXL,RMAXL);
  default: ASSERT(0,EVDOMAIN);
}}
