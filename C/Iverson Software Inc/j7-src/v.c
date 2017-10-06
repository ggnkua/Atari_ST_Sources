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
/* Verbs                                                                   */

#include "j.h"
#include "v.h"


F1(left1){R ca(w);}

F2(left2){R ca(a);}

F1(right1){R ca(w);}

F2(right2){R ca(w);}

F2(less){I ar,t,wr;
 RZ(a&&w);
 t=AT(a); ar=AR(a); wr=AR(w);
 if(t==AT(w)&&1>=ar&&1==bp(t)){A z;B b[256];C c,*u,*v,*zv;I n=0;
  memset(b,C1,sizeof(b));
  u=(C*)AV(a); v=(C*)AV(w);
  DO(AN(w),b[*v++]=0;); DO(AN(a),if(b[*u++])++n;);
  GA(z,t,n,1,0); zv=n+(C*)AV(z); DO(AN(a), if(b[c=*--u])*--zv=c;);
  R z;
 }
 if(ar>1+wr)R ca(a);
 if(wr&&ar!=wr){A s;I k,m,*sv,*ws;
  m=MAX(1,ar);
  GA(s,INT,m,1,0); sv=AV(s); ws=AS(w);
  k=ar>wr?0:1+wr-m; *sv=prod(k,ws); ICPY(1+sv,k+ws,m-1);
  RZ(w=reshape(s,w));
 }
 R repeat(not(eps(a,w)),a);
}

F1(nub){R repeat(nubsieve(w),w);}

F1(iota){A z;I m,n,*v;
 F1RANK(1,iota,0);
 RZ(w=vi(w)); n=AN(w); v=AV(w);
 if(1==n){m=*v; R 0>m?apv(-m,-m-1,-1L):apv(m,0L,1L);}
 m=prod(n,v);
 RZ(z=reshape(mag(w),apv(ABS(m),0L,1L)));
 DO(m?n:0, if(0>v[i])RZ(z=rank1ex(z,0L,n-i,reverse)););
 R z;
}

F1(immex){A z; z=(z=parse(tokens(w)))&&!asgn ? jpr(z) : z; R z;}

F1(exec1){A z;
 F1RANK(1,exec1,0);
 z=parse(tokens(vs(w)),0); asgn=0;
 R !z?0:MARK&AT(z)?mtv:vn(z);
}

F2(exec2){A z;C es=errsee;
 F2RANK(1,1,exec2,0);
 errsee=0; z=exec1(w); errsee=es; jerr=0;
 R z?z:exec1(a);
}

F1(raze){A*v,y,z;B b=0;C*x;I c=0,k,m=0,n,p,r=1,*s,t;
 RZ(w);
 n=AN(w); v=(A*)AV(w);
 if(!(n&&BOX&AT(w)))R ravel(w);
 s=1+AS(*v); t=AT(*v); k=bp(t);
 DO(n, y=v[i]; c+=IC(y); m+=AN(y); r=MAX(r,AR(y)); if(b=t!=AT(y))break;);
 p=(r-1)*SZI;
 if(!b&&1<r)DO(n, y=v[i]; if(b=r>AR(y)||memcmp(s,1+AS(y),p))break;);
 if(b){v+=n; z=*--v; DO(n-1,RZ(z=over(*--v,z));); R rankle(z);}
 GA(z,t,m,r,s-1); *AS(z)=c; x=(C*)AV(z);
 DO(n, y=*v++; p=k*AN(y); MC(x,AV(y),p); x+=p;);
 R z;
}

F2(link){RZ(a&&w); R over(box(a),AN(w)&&AT(w)&BOX+BOXK?w:box(w));}


static A numx(id)C id;{
 switch(id){
  case CZERO: R zero;
  case CONE:  R one;
  case CUSCO: R ainf;
  default:    R sc((I)(id-CZERO));
}}

DF1(num1){RZ(   w&&self); R numx(ID(self));}

DF2(num2){RZ(a&&w&&self); R numx(ID(self));}


#if (SYS & SYS_ATARIST+SYS_VAX)
static D fmod(x,y)D x,y;{R y?x-y*floor(x/y):x;}
#endif

F1(roll){A z;D rl=qrl;static D m=16807,p=2147483647L;I c,n,*v,*x;
 RZ(w=vi(w));
 n=AN(w); v=AV(w);
 RZ(z=reshape(shape(w),two)); x=AV(z);
 if(ICMP(v,x,n))
  DO(n, c=*v++; ASSERT(0<c,EVDOMAIN); rl=fmod(rl*m,p); *x++=(I)floor(rl*c/p);)
 else{B*x;D q=p/2;
  GA(z,BOOL,n,AR(w),AS(w)); x=(B*)AV(z);
  DO(n, rl=fmod(rl*m,p); *x++=rl>q;);
 }
 qrl=rl;
 R z;
}  /* P.C. Berry, Sharp APL Reference Manual, 1979, p. 126. */

F2(deal){A y;D rl=qrl;static D m=16807,p=2147483647L;I am,j,k,wm,*yv;
 F2RANK(0,0,deal,0);
 am=i0(a);
 wm=i0(w);
 ASSERT(0<=am&&am<=wm,EVDOMAIN);
 RZ(y=apv(wm,wm-1,-1L)); yv=AV(y);
 DO(am, rl=fmod(rl*m,p); j=i+(I)floor(rl*(wm-i)/(1+p)); k=yv[i]; yv[i]=yv[j]; yv[j]=k;);
 qrl=rl;
 R take(a,y);
}  /* P.C. Berry, Sharp APL Reference Manual, 1979, p. 178. */
