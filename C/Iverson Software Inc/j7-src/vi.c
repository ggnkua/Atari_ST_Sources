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
/* Verbs:  Matrix Inverse and Associates                                   */

#include "j.h"


static F1(norm){R sqroot(pdt(w,conjug(w)));}

F1(rinv){PROLOG;A ai,b,bx,di,z;I m,n,r,*s;
 RZ(w);
 r=AR(w); s=AS(w); n=2>r?1:s[1]; m=(1+n)/2;
 ASSERT(2>=r,EVRANK);
 ASSERT(!r||n==s[0],EVLENGTH);
 if(1>=n)R recip(w);
 RZ(ai=rinv(take(v2(m,m),w)));
 RZ(di=rinv(drop(v2(m,m),w)));
 RZ(b=take(v2(m,m-n),w));
 RZ(bx=negate(pdt(ai,pdt(b,di))));
 z=over(overr(ai,bx),take(v2(n-m,-n),di));
 EPILOG(z);
}  /* R.K.W. Hui, Uses of { and }, APL87, p. 56 */

F1(qr){PROLOG;A a1,q,q0,q1,r,r0,r1,t,*tv,t0,t1,y,z;I m,n,p,*s,wr;
 RZ(w);
 wr=AR(w); s=AS(w); n=2>wr?1:s[1]; m=(1+n)/2; p=IC(w);
 ASSERT(2>=wr,EVRANK);
 ASSERT(2>wr||p>=n,EVLENGTH);
 if(1>=n){t=norm(ravel(w)); R link(table(divide(w,t)),reshape(v2(n,n),t));}
 RZ(t0=qr(take(v2(p,m),w)));
 tv=(A*)AV(t0); q0=*tv++; r0=*tv;
 RZ(a1=drop(v2(0L,m),w));
 RZ(y=pdt(conjug(cant1(q0)),a1));
 RZ(t1=qr(minus(a1,pdt(q0,y))));
 tv=(A*)AV(t1); q1=*tv++; r1=*tv;
 RZ(q=overr(q0,q1));
 RZ(r=over(overr(r0,y),take(v2(n-m,-n),r1)));
 z=link(q,r); EPILOG(z);
}       /* R.K.W. Hui, M.Sc. Thesis, 1981 */

static F2(icor){D d,*v;I n;
 RZ(a&&w);
 d=1; n=1+*AS(a);
 v=(D*)AV(a); DO(n-1, d*=*v; v+=n;); d=floor(0.5+ABS(d));
 if(!d||d>1e20)R w;
 v=(D*)AV(w); DO(AN(w), v[i]=floor(0.5+d*v[i])/d;);
 R w;
}

F1(minv){PROLOG;A q,r,*v,y,z;I t;
 F1RANK(2,minv,0);
 t=AT(w);
 RZ(y=qr(w)); v=(A*)AV(y); q=*v++; r=*v;
 z=pdt(rinv(r),t&CMPX?conjug(cant1(q)):cant1(q));
 if(t&BOOL+INT&&2==AR(w)&&*AS(w)==*(1+AS(w)))z=icor(r,z);
 z=2==AR(w)?z:reshape(shape(w),z);
 EPILOG(z);
}

F2(mdiv){PROLOG;A q,r,*v,y,z;B b;I t;
 F2RANK(RMAX,2,mdiv,0);
 t=AT(w);
 RZ(y=qr(w)); v=(A*)AV(y); q=*v++; r=*v;
 z=pdt(rinv(r),t&CMPX?conjug(cant1(q)):cant1(q));
 b=t&BOOL+INT&&2==AR(w)&&*AS(w)==*(1+AS(w));
 if(b)z=icor(r,z);
 z=pdt(2>AR(w)?reshape(shape(w),z):z,a);
 if(b&&AT(a)&BOOL+INT)z=icor(r,z);
 EPILOG(z);
}
