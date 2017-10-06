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
/* Verbs:  Selection & Structural                                          */

#include "j.h"
#include "v.h"


F1(reverse){RZ(w); R AR(w)?from(apv(IC(w),-1L,-1L),w):ca(w);}

F2(rotate){I n,p;
 F2RANK(0,RMAX,rotate,0);
 p=i0(a); n=IC(w);
 R n&&AR(w)?from(apv(n,p%n-n*(0<p),1L),w):ca(w);
}

F1(cant1){RZ(w); R cant2(apv(AR(w),AR(w)-1,-1L),w);}

static F2(canta){PROLOG;A e,p,*pv,q,*qv,t,z;C b;I an,*av,d,*ev,i,j,k,*tv,*v,wr,*ws,zr;
 RZ(a&&w);
 an=AN(a); av=AV(a); wr=AR(w); ws=AS(w);
 ASSERT(an==wr,EVLENGTH);
 if(!wr)R ca(w);
 zr=0; DO(an, zr=MAX(zr,av[i]);); zr++;
 DO(zr, k=i; DO(an,if(b=k==av[i])break;); ASSERT(b,EVINDEX););
 GA(t,INT,wr,1,0); tv=AV(t);
 GA(p,BOX,zr,1,0); pv=(A*)AV(p);
 k=1; DO(wr, j=wr-1-i; tv[j]=k; k*=ws[j];);
 for(i=0;i<zr;i++){
  j=i; d=0; k=LONG_MAX;
  DO(an, if(j==av[i]){d+=tv[i]; k=MIN(k,ws[i]);});
  RZ(*pv++=apv(k,0L,d));
 }
 RZ(q=catalog(p)); qv=(A*)AV(q);
 GA(e,INT,AN(q),zr,AS(q)); ev=AV(e);
 DO(AN(q), k=0; v=AV(*qv); DO(zr,k+=*v++;); qv++; *ev++=k;);
 z=from(e,ravel(w)); EPILOG(z);
}

static F1(cantm){A z;C*v,*vv,*x;I j,k,m,n,*s,t;
 RZ(w);
 s=AS(w); m=*s; n=*++s;
 t=AT(w); k=bp(t); j=k*n;
 GA(z,t,AN(w),AR(w),0); s=AS(z); *s=n; *++s=m;
 x=(C*)AV(z)-k; v=vv=(C*)AV(w)-j;
 DO(n, DO(m, MC(x+=k,v+=j,k);); v=vv+=k;);
 R z;
}

F2(cant2){A p,r,t,*v,y;I j=0,k,*pv,*yv;
 F2RANK(1,RMAX,cant2,0);
 RZ(r=rank(w));
 if(BOX&AT(a)){
  RZ(t=raze(a));
  RZ(p=pfill(r,t)); pv=AV(p);
  RZ(y=ca(p)); yv=AV(y);
  v=(A*)AV(a);
  DO(AR(w)-IC(t),yv[*pv++]=j++;);
  DO(AN(a), k=AN(v[i]); DO(k,yv[*pv++]=j;); j+=!!k;);
  R canta(y,w);
 } else {RZ(p=pinv(pfill(r,a))); R all1(match(p,v2(1L,0L)))?cantm(w):canta(p,w);}
}

F2(take){PROLOG;A x=qfill,z;B b;C*xv,*zv;I k,m,n,r,*s,t,*u,xn;
 F2RANK(1,RMAX,take,0);
 RZ(a=vi(a));
 n=AN(a); xn=x?AN(x):0;
 if(!AR(w))RZ(w=reshape(apv(n,1L,0L),w));
 r=AR(w); s=AS(w); t=AN(w)?AT(w):BOOL; u=AV(a);
 ASSERT(n<=r,EVLENGTH);
 ASSERT(!x||!AR(x),EVRANK);
 b=0; DO(n, if(!u[i]){b=1; break;}); if(!b)DO(r-n, if(!s[n+i]){b=1; break;});
 if(!b&&xn)DO(n, if(s[i]<ABS(u[i])){t=MAX(t,AT(x));
     if(t!=AT(w))RZ(w=cvt(t,w)); if(t!=AT(x))RZ(x=cvt(t,x)); break;});
 if(x)xv=(C*)AV(x); k=bp(t);
 if(b||!AN(w)){I*v;
  if(b)m=0; else{m=prod(n,u)*prod(r-n,n+s); m=ABS(m);}
  GA(z,t,m,r,0); v=AS(z); zv=(C*)AV(z);
  DO(n, *v++=ABS(u[i]);); ICPY(v,n+s,r-n);
  if(m)if(xn)mvc(k*m,zv,k*xn,xv); else fillv(t,m,zv);
 }else{A y;C*yv;I c=1,d,dy,dz,e,i,p,q=1;
  z=w;
  for(i=0;i<n;++i){
   c*=q; p=u[i]; q=ABS(p); m=s[i];
   if(q!=m){
    b=1; d=AN(z)/(m*c)*k;
    GA(y,t,AN(z)/m*q,r,AS(z)); *(i+AS(y))=q; yv=(C*)AV(y);
    if(q>m)if(xn)mvc(k*AN(y),yv,k*xn,xv); else fillv(t,AN(y),yv);
    dy=d*q; yv+=         (0>p&&q>m?d*(q-m):0)-dy;
    dz=d*m; zv=(C*)AV(z)+(0>p&&m>q?d*(m-q):0)-dz; e=d*MIN(m,q);
    DO(c, MC(yv+=dy,zv+=dz,e););
    z=y;
  }}
  if(!b)z=ca(w);
 }
 EPILOG(z);
}

F2(drop){A s;I n,*u,*v;
 F2RANK(1,RMAX,drop,0);
 RZ(a=vi(a));
 n=AN(a); u=AV(a);
 if(!AR(w))RZ(w=reshape(apv(n,1L,0L),w));
 ASSERT(n<=AR(w),EVLENGTH);
 RZ(s=shape(w)); v=AV(s);
 DO(n, v[i]=0<u[i]?MIN(0,u[i]-v[i]):MAX(0,u[i]+v[i]););
 R take(s,w);
}

F1(head   ){R from(zero,w);}

F1(tail   ){R from(neg1,w);}

F1(behead ){R drop(one ,w);}

F1(curtail){R drop(neg1,w);}

F1(rank){RZ(w); R sc(AR(w));}

F1(shape){A z; RZ(w); GA(z,INT,AR(w),1,0); ICPY(AV(z),AS(w),AR(w)); R z;}

F2(reshape){A q=qfill,z;I k,m,n,p,r,t,*u;
 RZ(a&&w);
 RZ(a=vi(a));
 r=AN(a); u=AV(a); n=AN(w); t=AT(w); k=bp(t);
 DO(r,ASSERT(0<=u[i],EVDOMAIN););
 m=prod(r,u); ASSERT(n||!m,EVLENGTH);
 if(q&&n&&m>n){
  t=MAX(t,AT(q)); k=bp(t);
  if(t!=AT(w))RZ(w=cvt(t,w));
  if(t!=AT(q))RZ(q=cvt(t,q));
  GA(z,t,m,r,u);
  p=k*n; mvc(p,AV(z),p,AV(w)); mvc(k*m-p,p+(C*)AV(z),k,AV(q));
 }else{GA(z,t,m,r,u); mvc(k*m,AV(z),k*n,AV(w));}
 R z;
}

F2(reitem){
 F2RANK(1,RMAX,reitem,0);
 R 1>=AR(w)?reshape(a,w):reshape(over(a,behead(shape(w))),w);
}

F1(tally){RZ(w); R sc(IC(w));}

static F2(repeatf){I ar,wr;
 RZ(a&&w);
 ar=AR(a); wr=AR(w);
 R !ar&&wr||ar&&!wr ? repeatf(ar?a:reshape(tally(w),a),wr?w:reshape(tally(a),w)) :
     repeat(vi(ravel(rect(a))),df2(w,qfill?qfill:filler(w),
     atop(slash(ds(CCOMMA)),qq(ds(1<wr?CLAMIN:CCOMMA),v2(-1L,RMAXL))) ));
}

F2(repeat){A z;C*v,*x;I c,d,k,m,n,p=0,r,t,*u;
 F2RANK(1,RMAX,repeat,0);
 if(CMPX&AT(a))R repeatf(a,w);
 RZ(a=vi(a));
 n=AN(a); u=AV(a); m=IC(w); r=AR(w);
 ASSERT(!AR(a)||!r||n==m,EVLENGTH);
 DO(n, ASSERT(0<=u[i],EVDOMAIN); p+=u[i]; ASSERT(0<=p,EVLIMIT);); p=1==n?m*p:p;
 if(!r)R reshape(sc(p),w);
 t=AT(w); c=aii(w); k=c*bp(t);
 GA(z,t,p*c,r,AS(w)); *AS(z)=p; x=(C*)AV(z); v=(C*)AV(w);
 if(1<n)DO(n, if(d=k**u++){mvc(d,x,k,v+i*k); x+=d;})
 else if(d=k**u)DO(m, mvc(d,x,k,v+i*k); x+=d;);
 R z;
}

F1(ravel){A z; RZ(w); GA(z,AT(w),AN(w),1,0); MC(AV(z),AV(w),AN(w)*bp(AT(w))); R z;}

F2(over){A s,y,z;C*av,*x,*wv;I ak,ar,*as,c,k,m,n,q,r,*sv,t,wk,wr,*ws;
 RZ(t=coerce2(&a,&w,0L));
 k=bp(t); ar=AR(a); wr=AR(w); r=ar+wr?MAX(ar,wr):1;
 m=r==ar?IC(a):1; av=(C*)AV(a);
 n=r==wr?IC(w):1; wv=(C*)AV(w);
 if(1>=r){GA(z,t,m+n,1,0); x=(C*)AV(z); MC(x,av,k*m); MC(x+k*m,wv,k*n); R z;}
 RZ(s=shape(r==ar?a:w)); sv=AV(s);
 as=AS(a); ws=AS(w); q=MIN(ar,wr);
 DO(q, sv[r-1-i]=MAX(as[ar-1-i],ws[wr-1-i]);); if(q)DO(r-q, sv[i]=MAX(1,sv[i]););
 c=prod(r-1,1+sv); ak=k*c*m; wk=k*c*n;
 *sv=m+n; GA(z,t,c*(m+n),r,sv); x=(C*)AV(z);
 switch(!AN(a)?0:!ar?1:AN(a)<c*m?2:3){
  case 0: fillv(t,c*m,x); break;
  case 1: mvc(ak,x,k,av); break;
  case 2: if(ar<r){RZ(y=apv(r,1L,0L)); ICPY(AV(y)+r-ar,as,ar); RZ(a=reshape(y,a));}
          *sv=m; RZ(a=take(s,a));
  case 3: MC(x,AV(a),ak);
 }
 x+=ak;
 switch(!AN(w)?0:!wr?1:AN(w)<c*n?2:3){
  case 0: fillv(t,c*n,x); R z;
  case 1: mvc(wk,x,k,wv); R z;
  case 2: if(wr<r){RZ(y=apv(r,1L,0L)); ICPY(AV(y)+r-wr,ws,wr); RZ(w=reshape(y,w));}
          *sv=n; RZ(w=take(s,w));
  case 3: MC(x,AV(w),wk); R z;
}}

F1(table){A z;
 RZ(w);
 GA(z,AT(w),AN(w),2,0); *AS(z)=IC(w); *(1+AS(z))=aii(w);
 MC(AV(z),AV(w),AN(w)*bp(AT(w)));
 R z;
}

F2(overr){A z;C*av,*u,*v,*wv,*x;I ac,am,ar,*as,c,ck,d,k,n,*s,t,wc,wm,wr,*ws;
 RZ(t=coerce2(&a,&w,0L));
 ar=AR(a); wr=AR(w);
 if(2<ar||2<wr)R rank2ex(a,w,0L,-1L,-1L,over);
 if(!ar&&!wr)R over(a,w);
 as=AS(a); av=(C*)AV(a); am=ar?*as:1; ac=1<ar?as[1]:1;
 ws=AS(w); wv=(C*)AV(w); wm=wr?*ws:1; wc=1<wr?ws[1]:1;
 ASSERT(!ar||!wr||am==wm,EVLENGTH);
 n=ar?am:wm; c=ac+wc; k=bp(t); ck=c*k;
 GA(z,t,n*c,2,0); s=AS(z); *s=n; *(1+s)=c; x=(C*)AV(z);
 if(!ar)mvc(k*AN(z),x,k,av);
 if(!wr)mvc(k*AN(z),x,k,wv);
 if(1==ar){        u=x       -ck; v=av-k; DO(n, MC(u+=ck,v+=k,k););}
 if(1==wr){        u=x+(ac*k)-ck; v=wv-k; DO(n, MC(u+=ck,v+=k,k););}
 if(2==ar){d=k*ac; u=x       -ck; v=av-d; DO(n, MC(u+=ck,v+=d,d););}
 if(2==wr){d=k*wc; u=x+(ac*k)-ck; v=wv-d; DO(n, MC(u+=ck,v+=d,d););}
 R z;
}

F1(lamin1){R reshape(over(one,shape(w)),w);}

F2(lamin2){RZ(a&&w); R over(AR(a)?lamin1(a):a, AR(w)?lamin1(w):AR(a)?w:table(w));}

F1(catalog){PROLOG;A b,c,p,q,*v,*x,z;C*bu,*bv,**pv;I*cv,i,j,k,m,n,*qv,r=0,*s,t=0,*u;
 F1RANK(1,catalog,0);
 if(!(AN(w)&&BOX&AT(w)))R box(w);
 n=AN(w); v=(A*)AV(w);
 DO(n, if(AN(v[i])){k=AT(v[i]); t=t?t:k; ASSERT(homo(t,k),EVDOMAIN); t=MAX(t,k);});
 t=MAX(BOOL,t);
 GA(b,t,n,1,0);      bv=(C*)AV(b);
 GA(q,INT,n,1,0);    qv=AV(q);
 GA(p,BOX,n,1,0);    pv=(C**)AV(p);
 RZ(c=apv(n,0L,0L)); cv=AV(c);
 DO(n, RZ(c=cvt(t,v[i])); r+=AR(c); qv[i]=AN(c); pv[i]=(C*)AV(c););
 m=prod(n,qv);
 GA(z,BOX,m,r,0);    x=(A*)AV(z);
 s=AS(z); DO(n, u=AS(v[i]); k=AR(v[i]); DO(k,*s++=*u++;););
 k=bp(t);
 for(i=0;i<m;i++){
  bu=bv-k;
  DO(n, MC(bu+=k,pv[i]+k*cv[i],k););
  DO(n, j=n-1-i; if(qv[j]>++cv[j])break; cv[j]=0;);
  *x++=ca(b);
 }
 EPILOG(z);
}

static A ifrom(a,w,r)A a,w;I r;{A z;C*v,*x;I an,ar,*as,c,d,k,wr,*ws,wt,*u;
 RZ(a&&w);
 ar=AR(a); u=    AV(a); as=AS(a); an=AN(a);
 wr=AR(w); v=(C*)AV(w); ws=AS(w); wt=AT(w);
 d=MAX(0,wr-r); c=prod(d,r+ws); k=c*bp(wt);
 GA(z,wt,an*c,ar+d,as); ICPY(ar+AS(z),ws+r,d); x=(C*)AV(z)-k;
 DO(an, MC(x+=k,v+k**u++,k););
 R z;
}

static F2(afi){RZ(a&&w); R(BOX&AT(w))?less(iota(a),pind(a,ope(w))):pind(a,w);}

static F2(afrom){PROLOG;A j,s,z;
 F2RANK(0,RMAX,afrom,0);
 RZ(a=ope(a));
 ASSERT(IC(a)<=AR(w),EVLENGTH);
 ASSERT(1>=AR(a),EVRANK);
 if(!AR(w))R w;
 RZ(s=take(tally(a),shape(w)));
 RZ(j=catalog(df2(s,a,under(ac2(afi),ds(COPE)))));
 z=ifrom(AN(j)?base2(s,ope(j)):j,w,IC(a));
 EPILOG(z);
}

F2(from){RZ(a&&w); R BOX&AT(a)?afrom(a,w):ifrom(pind(tally(w),a),w,1L);}
