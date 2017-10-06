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
/* Verbs:  Indexof with Hashing                                            */

#include "j.h"
#include "v.h"

/* Floating point byte order:                 */
/* Archimedes       3 2 1 0 7 6 5 4           */
/* VAX              1 0 3 2 5 4 7 6           */
/* little endian    7 6 5 4 3 2 1 0           */
/* MAC universal    0 1 0 1 4 5 6 7 8 9 a b   */
/* MAC 6888x        0 1 _ _ 4 5 6 7 8 9 a b   */
/* normal           0 1 2 3 4 5 6 7 ...       */

static I hid(k,v)I k;C*v;{
#if (SYS&SYS_MACINTOSH && SYS_MAC6888X)
 C*xv;I x; xv=(C*)&x; x[0]=v[0]; x[1]=v[1]; x[2]=v[4]; x[3]=v[5]; R x;
#else
#if (SYS&SYS_MACINTOSH && SYS_MACUNIV)
 R*(I*)(v+2);
#else
#if (SYS&SYS_LILENDIAN)
 R*(I*)(v+4);
#else
 R*(I*)v;
#endif
#endif
#endif
}

static I hix(k,v)I k;C*v;{C*xv;I x;
 xv=(C*)&x; xv[0]=v[k-1]; xv[1]=v[k-2]; xv[2]=v[1]; xv[3]=v[0];
 R x;
}

static I hiat(hct,k,v)D hct;I k;A*v;{A y;C*yv;D d;I n,t;
 y=*v; n=AN(y); t=AT(y); yv=(C*)AV(y);
 if(n&&t&CHAR+NAME)R 1<n?hix(n,yv):*yv;
 if(!n||t&BOX+BOXK)R AR(y)?hix(AR(y)*SZI,AS(y)):BOX;
 if(t&BOOL)d=*(B*)yv; else if(t&INT)d=*(I*)yv; else d=*(D*)yv;
 d*=hct;
 R hid(k,&d);
}

static I hia(k,v)I k;A*v;{R hiat(1.0,k,v);}

static B eqa(n,u,v)I n;A*u,*v;{DO(n, if(one!=match(*u++,*v++))R 0;); R 1;}

static B eqd(n,u,v)I n;D*u,*v;{DO(n, if(!teq(*u++,*v++))R 0;); R 1;}

static B eqj(n,u,v)I n;Z*u,*v;{DO(n, if(!zeq(*u++,*v++))R 0;); R 1;}

static B eqx(k,u,v)I k;C*u,*v;{R memcmp(u,v,k)?0:1;}

static F2(ciof){A z;I an,k,t[256],wn,*x;UC*u,*v;
 RZ(a&&w);
 an=AN(a); u=(UC*)AV(a)+an; k=an;
 wn=AN(w); v=(UC*)AV(w);
 GA(z,INT,wn,AR(w)-MAX(0,AR(a)-1),AS(w)); x=AV(z);
 DO(256,t[i]=an;); DO(an,t[*--u]=--k;); DO(wn,*x++=t[*v++];);
 R z;
}  /* a i.w, byte-size items */


static I p2[]={131L, 257L, 521L, 1031L, 2053L, 4099L, 8209L, 16411L, 32771L,
    65537L, 131101L, 262147L, 524309L, 1048583L, 2097169L, 4194319L,
    8388617L, 16777259L, 33554467L, 67108879L, 134217757L, 268435459L,
    536870923L, 1073741827L};

#define FIND(lhs)                      \
 while(0<=(jj=hv[j])){if(eqq(q,av+k*jj,v)){lhs=jj; break;} ++j; if(j==p)j=0;}

#define HASHJ(lhs)     j=hiq(k,v)%p; j=ABS(j); FIND(lhs);

F2(indexof){PROLOG;A h,z;B(*eqq)(),ex;C*av,*v,*wv;
  I at,(*hiq)(),*hv,j,jj,k,m,n,p,q,t,wt,zn,zr,*zv;
 RZ(a&&w);
 at=AT(a); m=IC(a); n=aii(a); wt=AT(w);
 {B b;I*as,r,*ws;
  as=AS(a); ws=AS(w);
  r=MAX(0,AR(a)-1); zr=MAX(0,AR(w)-r); zn=n?AN(w)/n:0;
  b=r<=AR(w)&&!ICMP(as+1,ws+zr,r);
  if(!(b&&m&&n&&zn&&homo(at,wt)))R reshape(take(sc(zr),shape(w)),sc(b&&!n?0L:m));
 }
 t=MAX(at,wt); k=n*bp(t);
 if(1==k)R ciof(a,w);
 if(t!=at)RZ(a=cvt(t,a)); av=(C*)AV(a);
 if(t!=wt)RZ(w=cvt(t,w)); wv=(C*)AV(w);
 if(t&BOXK)R indexof(kbox(a),kbox(w));
 p=m+m; if(p<p2[sizeof(p2)/SZI-1])DO(32, if(p<=p2[i]){p=p2[i]; break;});
 RZ(h=apv(p,-1L,0L)); hv=AV(h);
 GA(z,INT,zn,zr,AS(w)); zv=AV(z);
 ex=0==qct||!(t&FL+CMPX+BOX);
 eqq=t&BOX?eqa:t&FL?eqd:t&CMPX?eqj  :eqx;
 hiq=t&BOX?hia:0!=qct&&t&FL+CMPX?hid:hix;
 if(t&INT&&1==n){B b=1;I*u=m+(I*)av;
  q=m; DO(m, j=*--u; if(j<0||p<=j){b=0; break;}else hv[j]=--q;);
  if(b){
   u=(I*)wv;
   if(a==w)DO(zn, zv[i]=hv[*u++];)
   else    DO(zn, j=*u++; zv[i]=0<=j&&j<p&&0<=(jj=hv[j])?jj:m;);
   EPILOG(z);
  }else{q=-1; mvc(p*SZI,hv,SZI,&q);}
 }
 v=av; q=t&FL+CMPX+BOX?n:k;
 if(ex&&a==w)DO(m, HASHJ(zv[i]); if(0>jj)hv[j]=zv[i]=i; v+=k;)
 else{C*yv;D qctl=1-qct,qctr=1/qctl,y,yy;I i,ja,jr;
  yv=(C*)&y;
  DO(m, HASHJ(jj); if(0>jj)hv[j]=i; v+=k;);
  v=wv;
  if(ex)DO(zn, zv[i]=m; HASHJ(zv[i]); v+=k;)
  else if(t&BOX) for(i=0;i<zn;++i){
   zv[i]=m;
   j=jr=hiat(qctr,k,v)%p; j=ABS(j); FIND(zv[i]);
   j=   hiat(qctl,k,v)%p;
   if(j!=jr){ja=m; j=ABS(j); FIND(ja); zv[i]=MIN(zv[i],ja);}
   v+=k;
  }else for(i=0;i<zn;++i){
   zv[i]=m; yy=*(D*)v;
   y=qctr*yy; j=jr=hid(k,yv)%p; j=ABS(j); FIND(zv[i]);
   y=qctl*yy; j=   hid(k,yv)%p;
   if(j!=jr){ja=m; j=ABS(j); FIND(ja); zv[i]=MIN(zv[i],ja);}
   v+=k;
 }}
 EPILOG(z);
}
