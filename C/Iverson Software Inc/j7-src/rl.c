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
/* Linear Representation                                                   */

#include "j.h"


static F1(lparen){A z;C*v;I n;
 RZ(w);
 n=AN(w);
 GA(z,CHAR,2+n,1,0); v=(C*)AV(z); *v='('; *(v+n+1)=')'; MC(1+v,AV(w),n);
 R z;
}

static A lcp(b,w)B b;A w;{R b?lparen(w):w;}

static B lp(w)A w;{B b=1,p=0;C c,d,*v;I j=0,n;
 RZ(w);
 n=AN(w); v=(C*)AV(w); c=*v; d=*(v+n-1);
 if(1==n||(2==n||3>=n&&' '==c)&&(d==CESC1||d==CESC2)||vnm(n,v))R 0;
 if(C9==ctype[c])  DO(n, c=ctype[*v++]; if(b=!(c==C9||c==CD||c==CA||c==CS))break;)
 else if(c==CQUOTE)DO(n-1, c=*v++; if(c==CQUOTE)p=!p; if(b=p?0:c!=CQUOTE)break;)
 else if(c=='(')   DO(n-1, c=*v++; c=='('?++j:c==')'?--j:0; if(b=!j)break;)
 R b;
}


static F1(lsh){R over(thorn1(shape(w)),spellout(CDOLLAR));}

static F1(lshape){I r,*s;
 RZ(w);
 r=AR(w); s=AS(w);
 R 2==r&&(1==s[0]||1==s[1]) ? spellout(1==s[1]?CCOMDOT:CLAMIN) : !r ? mtv :
     1<r ? lsh(w) : 1<AN(w) ? mtv : spellout(CCOMMA);
}

static F1(lchar){A y;B b;C c,d,*u,*v;I j,n;
 RZ(w);
 n=AN(w); u=v=(C*)AV(w); d=*v;
 j=2; b=7<n||1<n&&1<AR(w);
 DO(n, c=*v++; c==CQUOTE?j++:0; b=b&&c==d;); if(b){n=1; j=MIN(3,j);}
 GA(y,CHAR,n+j,1,0); v=(C*)AV(y);
 *v=*(v+n+j-1)=CQUOTE; ++v;
 if(2==j)MC(v,u,n); else DO(n, *v++=c=*u++; if(c==CQUOTE)*v++=c;);
 R over(b?lsh(w):lshape(w),y);
}

static A lnoun();

static F1(lbox){A s,*u,*v,*vv,x,y;B b;I n;
 RZ(w);
 n=AN(w); u=(A*)AV(w);
 DO(n, if(b=AT(u[i])&BOX+BOXK)break;); b=b||1==n;
  GA(y,BOX,n+n-!b,1,0); v=vv=(A*)AV(y);
 if(b){
  RZ(s=cstr("),(<"));
  DO(n, *v++=s; RZ(*v++=lnoun(u[i])););
  if(1==n)RZ(*vv=cstr("<"))else{RZ(*vv=cstr("(<")); RZ(vv[n+n-2]=cstr("),<"));}
  R over(lshape(w),raze(y));
 }
 DO(n, x=u[i]; if(b=!(1==AR(x)&&CHAR&AT(x)&&!memchr(AV(x),' ',AN(x))))break;);
 if(b){
  RZ(s=spellout(CSEMICO));
  DO(n-1, RZ(x=lnoun(u[i])); RZ(*v++=lcp(lp(x),x)); *v++=s;);
  RZ(*v=lnoun(u[n-1]));
  R over(lshape(w),raze(y));
 }
 R over(lshape(w),over(cstr("<;._1 "),
     lchar(raze( df2(scc(' '),w,under(ds(CCOMMA),ds(COPE))) ))));
}

static F1(lboxk){A s,t,*u,*v,*vv,y;I m,n;
 RZ(w);
 n=AN(w); m=4*n; u=(A*)AV(w);
 GA(y,BOX,m,1,0); v=vv=(A*)AV(y);
 RZ(s=cstr("),(<!.(")); RZ(t=cstr(")"));
 DO(n, *v++=s; RZ(*v++=lnoun(*u++)); *v++=t; RZ(*v++=lnoun(*u++)););
 if(1==n)RZ(*vv=cstr("<!.("))else{RZ(*vv=cstr("(<!.(")); RZ(vv[m-4]=cstr("),<!.("));}
 R over(lshape(w),raze(y));
}

static F1(lnum){A b,d,fs,t,*v,y;I n;
 RZ(t=ravel(w));
 n=AN(w); RZ(fs=fit(ds(CTHORN),sc(18L)));
 if(7<n||1<n&&1<AR(w)){
  RZ(d=minus(from(one,t),b=from(zero,t)));
  if(all1(match(t,plus(b,tymes(d,apv(n,0L,1L)))))){
   if(all1(eq(d,zero)))R over(lsh(w),df1(b,fs));
   GA(y,BOX,6,1,0); v=(A*)AV(y); v[0]=v[1]=v[2]=v[3]=mtv;
   if(     all0(eq(b,zero))){RZ(v[0]=df1(b,fs)); RZ(v[1]=spellout(CPLUS));}
   if(     all1(eq(d,neg1))) RZ(v[1]=spellout(CMINUS))
   else if(all0(eq(d,one ))){RZ(v[2]=df1(d,fs)); RZ(v[3]=spellout(CSTAR));}
   RZ(v[4]=spellout(CIOTA)); RZ(v[5]=thorn1(shape(w)));
   R raze(y);
 }}
 R over(lshape(w),df1(t,fs));
}

static F1(lnoun){
 RZ(w);
 if(!AN(w))R 1==AR(w)?cstr("''"):over(spellout(CIOTA),thorn1(shape(w)));
 switch(AT(w)){
  case CHAR: R lchar(w);
  case BOX:  R lbox(w);
  case BOXK: R lboxk(w);
  default:   R lnum(w);
}}


static A lsymb(c)C c;{A t;C d;
 d=cf(t=spellout(c));
 R d==CESC1||d==CESC2?over(scc(' '),t):t;
}

static B laa(a,w)A a,w;{C c,d;
 RZ(a&&w);
 c=ctype[cl(a)]; d=ctype[cf(w)];
 R (c==C9||c==CA)&&(d==C9||d==CA);
}

static B lnn(a,w)A a,w;{RZ(a&&w); R C9==ctype[cl(a)]&&C9==ctype[cf(w)];}

static F2(linsert){A f,g,h,t0,t1,*u,y;B ft,gt,ht,vb;C id,p,q,r;I n;V*v;
 RZ(a&&w);
 n=AN(a); u=(A*)AV(a); vb=VERB==AT(w); v=VAV(w); id=v->id;
 if(1<=n){f=u[0]; p=ID(v->f); ft=vb?p==CHOOK||p==CFORK:p==CADVF||p==CHOOKO;}
 if(2<=n){g=u[1]; q=ID(v->g); gt=vb?q==CHOOK||q==CFORK:lp(g);}
 if(3<=n){h=u[2]; r=ID(v->h); ht=vb?r==CHOOK          :lp(h);}
 switch(id){
  case CADVF:
  case CHOOKO:
  case CHOOK:
   GA(y,BOX,3,1,0); u=(A*)AV(y);
   RZ(u[0]=f=lcp(ft||lnn(f,g),f));
   RZ(u[2]=g=lcp(gt,g));
   RZ(u[1]=str(' '==cf(g)||id==CADVF&&!laa(f,g)&&!(lp(f)&&lp(g))?0L:1L," "));
   R raze(y);
  case CFORKO:
  case CFORK:
   GA(y,BOX,5,1,0); u=(A*)AV(y);
   RZ(u[0]=f=lcp(ft||lnn(f,g),f));
   RZ(u[2]=g=lcp(gt||lnn(g,h),g));  RZ(u[1]=str(' '==cf(g)?0L:1L," "));
   RZ(u[4]=h=lcp(ht||ft&&lp(h),h)); RZ(u[3]=str(' '==cf(h)?0L:1L," "));
   R raze(y);
  default:
   t0=lcp(ft||NOUN&AT(v->f)&&!(VGERL&v->fl)&&lp(f),f);
   t1=lsymb(id);
   y=over(t0,laa(t0,t1)?over(scc(' '),t1):t1);
   R 1==n?y:over(y,lcp(lp(g),g));
}}

static F1(ltie){A t,*u,*v,x,y;B b;C c;I n;
 RZ(w);
 n=AN(w); RZ(t=spellout(CGRAVE));
 GA(y,BOX,n+n,1,0); v=(A*)AV(y); u=(A*)AV(w);
 DO(n, *v++=i?t:mtv; x=*u++; c=ID(x); RZ(x=lrep(x)); b=c==CHOOK||c==CFORK||i&&lp(x);
     RZ(*v++=lcp(b,x)););
 R raze(y);
}

F1(lrep){PROLOG;A fs,gs,hs,t,*tv,z;C c,id;I fl,m;V*v;
 RZ(w);
 if(AT(w)&NOUN+NAME)R lnoun(w);
 v=VAV(w); id=v->id; fs=v->f; gs=v->g; hs=v->h; fl=v->fl;
 m=!!fs+!!gs+(id==CFORK||id==CFORKO);
 if(!m)R lsymb(id);
 if(evoke(w))R CA==ctype[c=cf(fs)]?ca(fs):spellout(c);
 GA(t,BOX,m,1,0); tv=(A*)AV(t);
 if(0<m)RZ(tv[0]=fl&VGERL?ltie(every(fs,fx)):lrep(fs));
 if(1<m)RZ(tv[1]=fl&VGERR?ltie(every(gs,fx)):lrep(gs));
 if(2<m)RZ(tv[2]=lrep(hs));
 z=linsert(t,w);
 EPILOG(z);
}
