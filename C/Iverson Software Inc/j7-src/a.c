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
/* Adverbs                                                                 */

#include "j.h"
#include "a.h"


static B booltab[64]={
 0,0,0,0, 0,0,0,1, 0,0,1,0, 0,0,1,1,  0,1,0,0, 0,1,0,1, 0,1,1,0, 0,1,1,1,
 1,0,0,0, 1,0,0,1, 1,0,1,0, 1,0,1,1,  1,1,0,0, 1,1,0,1, 1,1,1,0, 1,1,1,1,
};

static DF2(bool2){R from(plus(duble(cvt(BOOL,a)),cvt(BOOL,w)),VAV(self)->h);}

static DF1(bool1){R bool2(zero,w,self);}

static DF1(basis1){DECLF;A z;D*x;I j;V*v;
 PREF1(basis1);
 RZ(w=vi(w));
 switch(*AV(w)){
  case 0:
   GA(z,FL,3,1,0); x=(D*)AV(z); v=VAV(fs);
   j=v->mr; x[0]=j<=-RMAX?-inf:j>=RMAX?inf:j;
   j=v->lr; x[1]=j<=-RMAX?-inf:j>=RMAX?inf:j;
   j=v->rr; x[2]=j<=-RMAX?-inf:j>=RMAX?inf:j;
   R pcvt(INT,z);
  case -1: R lrep(inv (fs));
  case  1: R lrep(iden(fs));
 }
 ASSERT(0,EVDOMAIN);
}

F1(bool){A b,h;I j,*v;
 RZ(w);
 if(VERB&AT(w))R ADERIV(CBOOL, basis1,0L, 0L,0L,0L);
 RZ(w=vi(w));
 v=AV(w);
 DO(AN(w), j=*v++; ASSERT(-16<=j&&j<16,EVINDEX););
 GA(b,BOOL,64,2,0); *AS(b)=16; *(1+AS(b))=4; MC(AV(b),booltab,64L);
 RZ(h=cant2(apv(AR(w),0L,1L),from(w,b)));
 R fdef(CBOOL,VERB, bool1,bool2, w,0L,h, 0L, RMAXL,0L,0L);
}


static AS2(oprod, df2(a,w,qq(fs,v2(lr(fs),RMAXL))))

static DF1(reduce){PROLOG;DECLF;A y,z;C*u,*v;I c,k,m,old,t;
 RZ(w);
 m=IC(w);
 if(!m)R df1(w,iden(fs));
 RZ(z=tail(w));
 if(1==m)R z;
 t=AT(w); c=AN(z);
 GA(y,t,c,AR(z),AS(z)); u=(C*)AV(y); k=c*bp(t); v=(C*)AV(w)+k*(m-1);
 old=tbase+ttop;
 DO(m-1, MC(u,v-=k,k); RZ(z=f2(y,z,fs)); gc(z,old););
 EPILOG(z);
}

static A areduce();

static DF1(breduce){A z;B b,*u,*v,*x,*xx;I c,cv,d,m;SF f2;VA*p;
 RZ(w); /* AN(w)&&1<IC(w) */
 m=IC(w); RZ(z=tail(w)); c=AN(z); x=(B*)AV(z); v=(B*)AV(w);
 p=vap(self);
 switch(1<c?0:p->bf){
  case V0001: *x=memchr(v,C0,m)?0:1; R z;
  case V0111: *x=memchr(v,C1,m)?1:0; R z;
  case V1110: u=memchr(v,C0,m); d=u?u-v:m; *x=d%2!=d<m-1; R z;
  case V1000: u=memchr(v,C1,m); d=u?u-v:m; *x=d%2==d<m-1; R z;
  case V0010: u=memchr(v,C0,m); *x=(u?u-v:m)%2?1:0; R z;
  case V1011: u=memchr(v,C1,m); *x=(u?u-v:m)%2?0:1; R z;
  case V0100: *x= *(v+m-1)&&!memchr(v,C1,m-1)?1:0; R z;
  case V1101: *x=!*(v+m-1)&&!memchr(v,C0,m-1)?0:1; R z;
  case V0110: b=0; DO(m, b=b!=*v++;); *x=b; R z;
  case V1001: b=1; DO(m, b=b==*v++;); *x=b; R z;
 }
 switch(p->id){I*x,*xx;
  case CPLUS:
   RZ(z=cvt(INT,z)); x=AV(z);
   if(1==c){d=0; DO(m, *v++?d++:0;); *x=d;}
   else{xx=x+=c; v+=c*(m-1); DO(m-1, DO(c, --x; *x=*--v+*x;); x=xx;);}
   R z;
  case CMINUS:
   RZ(z=cvt(INT,z)); x=AV(z);
   if(1==c){v+=m; d=0; DO(m, d=*--v?1-d:-d;); *x=d;}
   else{xx=x+=c; v+=c*(m-1); DO(m-1, DO(c, --x; *x=*--v-*x;); x=xx;);}
   R z;
 }
 vaa(self,BOOL,&f2,&cv);
 if(!(cv&VB))R areduce(cvt(FL,w),self);
 xx=x+=c; v+=c*(m-1); DO(m-1, DO(c, --v; --x; f2(v,x,x);); x=xx;);
 R jerr?0:z;
}

static DF1(areduce){A z;C*v,*x,*xx;I c,cv,k,m,t;SF f2;
 RZ(w);
 m=IC(w); t=AT(w);
 if(!(1<m&&AN(w)&&t&NUMERIC))R reduce(w,self);
 if(t&BOOL)R breduce(w,self);
 vaa(self,t,&f2,&cv);
 if(cv&VB)R reduce(w,self);
 RZ(w=cva(cv,w));
 RZ(z=tail(w));
 c=AN(z); k=bp(AT(w)); v=(C*)AV(w)+c*k*(m-1); x=xx=(C*)AV(z)+c*k;
 if(1==c){x-=k; DO(m-1, v-=k; f2(v,x,x););}
 else DO(m-1, DO(c, v-=k; x-=k; f2(v,x,x);); x=xx;);
 R jerr?0:cvz(cv,z);
}

static DF1(catred){A z;I n,r,*s,t;
 RZ(w);
 n=AN(w); r=AR(w); s=AS(w); t=AT(w);
 if(2>r)R ca(w);
 if(!*s)R reduce(w,self);
 GA(z,t,n,r-1,1+s); *AS(z)=*s**(1+s); MC(AV(z),AV(w),n*bp(t));
 R z;
}

F1(slash){UC id;
 RZ(w);
 if(NOUN&AT(w))R evger(w,sc(GINSERT));
 id=ID(w);
 R ADERIV(CSLASH,id==CCOMMA?catred:vaptr[id]?areduce:reduce,oprod,RMAXL,RMAXL,RMAXL);
}


static DF1(merge1){PROLOG;DECLF;A ind,z;C*v,*x;I c,k,r,*s,t,*u;
 RZ(w);
 r=MAX(0,AR(w)-1); s=1+AS(w); t=AT(w); c=aii(w);
 RZ(ind=pind(tally(w),f1(w,fs)));
 ASSERT(r==AR(ind),EVRANK);
 ASSERT(!ICMP(s,AS(ind),r),EVLENGTH);
 GA(z,t,c,r,s); x=(C*)AV(z); v=(C*)AV(w); u=AV(ind); k=bp(t);
 DO(c, MC(x+k*i,v+k*(i+c*u[i]),k););
 EPILOG(z);
}

static DF2(merge2){PROLOG;DECLF;A ind,z;C*u,*x;I ak,an,ar,*as,in,ir,*iv,t,zk;
 RZ(a&&w);
 an=AN(a); ar=AR(a); as=AS(a);
 ASSERT(!an||homo(AT(a),AT(w)),EVDOMAIN);
 RZ(ind=pind(sc(AN(w)),f2(a,w,fs)));
 in=AN(ind); ir=AR(ind); iv=AV(ind);
 ASSERT(ar<=ir,EVRANK);
 ASSERT(!ICMP(as,AS(ind)+ir-ar,ar),EVLENGTH);
 t=MAX(AT(a),AT(w)); RZ(a=cvt(t,a)); RZ(z=cvt(t,w));
 x=(C*)AV(z); zk=bp(t);
 u=(C*)AV(a); ak=ar?zk:0;
 DO(in, MC(x+zk**iv++,u+ak*(i%an),zk););
 EPILOG(z);
}

F1(rbrace){
 RZ(w);
 R VERB&AT(w) ? ADERIV(CRBRACE,merge1,merge2,RMAXL,RMAXL,RMAXL) :
    BOX&AT(w) ? gadv(w,CRBRACE) : rbrace(qq(w,ainf)) ;
}


static AS1(swap1, f2(w,w,fs))

static AS2(swap2, f2(w,a,fs))

static DF1(unquo1){RZ(   w); R unquote(0L,w,self);}

static DF2(unquo2){RZ(a&&w); R unquote(a ,w,self);}

F1(swap){
 RZ(w);
 if(VERB&AT(w))R ADERIV(CTILDE,swap1,swap2,RMAXL,rr(w),lr(w));
 else{A t;
  RZ(w=onm(AR(w)?w:ravel(w))); AT(w)=CHAR;
  t=srdlg(w);
  if(!t)RZ(t=ds(CZERO));
  R NOUN&AT(t) ? t : fdef(CTILDE,AT(t), unquo1,unquo2, w,0L,0L, 0L, mr(t),lr(t),rr(t));
}}


static I fixi;
static A fixpath;
static A*fixpv;

static F1(fixa){A fs,y,z;V*v;
 RZ(z=ca(w));
 if(NOUN&AT(z))R z;
 v=VAV(z);
 switch(v->id){
  case CATDOT:
  case CGRCO:
   RZ(v->h=y=every(v->h,fixa)); RZ(v->f=every(y,aro)); RZ(v->g=fixa(v->g));
   R z;
  case CTILDE:
   fs=v->f;
   if(CHAR&AT(fs)&&!all1(eps(box(fs),fixpath))){
    ASSERT(fixi,EVLIMIT);
    fixpv[--fixi]=fs; z=fixa(symbrd(fs)); fixpv[fixi++]=mtv;
    R z;
   }
  default:
   if(v->f)RZ(v->f=fixa(v->f));
   if(v->g)RZ(v->g=fixa(v->g));
   if(v->h)RZ(v->h=fixa(v->h));
   R z;
}}

F1(fix){PROLOG;A z;
 RZ(fixpath=reshape(sc(fixi=255L),jot)); fixpv=(A*)AV(fixpath);
 ASSERT(AT(w)&CHAR+NAME+VERB,EVDOMAIN);
 z=fixa(AT(w)&VERB?w:symbrd(w));
 EPILOG(z);
}
