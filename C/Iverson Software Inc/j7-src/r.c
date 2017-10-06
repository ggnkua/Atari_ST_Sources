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
/* Representations                                                         */

#include "j.h"


static F1(drr){PROLOG;A df,dg,fs,gs,*x,z;B b;C c,id;I fl,m;V*v;
 RZ(w);
 if(AT(w)&NOUN+NAME)R w;
 v=VAV(w); id=v->id; fl=v->fl; fs=v->f; gs=v->g; m=!!fs+!!gs;
 if(!m)R spellout(id);
 if(evoke(w))R CA==ctype[c=cf(fs)]?fs:spellout(c);
 b=id==CHOOK||id==CHOOKO||id==CADVF; c=id==CFORK||id==CFORKO;
 if(fs)df=fl&VGERL?every(every(fs,fx),drr):drr(fs);
 if(gs)dg=fl&VGERR?every(every(gs,fx),drr):drr(gs);
 GA(z,BOX,m+!b,1,0); x=(A*)AV(z);
 RZ(x[0]=df);
 RZ(x[1]=b||c?dg:spellout(id));
 if(!b&&1<m)RZ(x[2]=c?drr(v->h):dg);
 EPILOG(z);
}

F1(drep){A z; R(z=drr(w),z&&AT(z)&BOX+BOXK)?z:ravel(box(z));}



F1(aro){A fs,gs,*u,*x,y,z;C c,id;I m;V*v;
 RZ(w);
 if(FUNC&AT(w)){
  v=VAV(w); id=v->id; fs=v->f; gs=v->g;
  m=id==CFORK||id==CFORKO?3:!!fs+!!gs;
  if(!m)R spellout(id);
 }
 GA(z,BOX,2,1,0); x=(A*)AV(z);
 if(NOUN&AT(w)){*x++=str(1L,"0"); *x=w; R z;}
 GA(y,BOX,m,1,0); u=(A*)AV(y);
 if(0<m)RZ(u[0]=aro(evoke(w)&&CA!=ctype[c=cf(fs)]?spellout(c):fs));
 if(1<m)RZ(u[1]=aro(gs));
 if(2<m)RZ(u[2]=aro(v->h));
 RZ(*x++=spellout(id));
 *x=y;
 R z;
}

F1(arep){R box(aro(w));}


static F1(fxr){PROLOG;A z; RZ(z=fx(w)); ASSERT(AT(z)&NOUN+VERB,EVDOMAIN); EPILOG(z);}

F1(fx){A arg,fs,*u,*x,y;C b,id;I n;
 RZ(w);
 b=BOX&AT(w); u=(A*)AV(w); y=b?u[0]:w; arg=u[1];
 ASSERT(1>=AR(w),EVRANK);
 ASSERT(b||CHAR&AT(w),EVDOMAIN);
 ASSERT(!b||2==AN(w),EVLENGTH);
 RZ(vs(y));
 ASSERT(id=spellin(AN(y),AV(y)),EVSPELL);
 if(C9==ctype[id]){
  ASSERT(b,EVDOMAIN);
  if('0'==id)R arg;
  ASSERT(1>=AR(arg),EVRANK);
  ASSERT(BOX&AT(arg),EVDOMAIN);
  n=AN(arg); x=(A*)AV(arg);
  switch(id){
   case '2': ASSERT(2==n,EVLENGTH); R hook(fx(x[0]),fx(x[1]));
   case '3': ASSERT(3==n,EVLENGTH); R folk(fx(x[0]),fx(x[1]),fx(x[2]));
   case '4': ASSERT(2==n,EVLENGTH); R advform(fx(x[0]),fx(x[1]));
   case '5': ASSERT(2==n,EVLENGTH); R hooko(fx(x[0]),fx(x[1]));
   case '6': ASSERT(3==n,EVLENGTH); R forko(fx(x[0]),fx(x[1]),fx(x[2]));
   default:  ASSERT(0,EVDOMAIN);
 }}else{
  RZ(fs=ds(id));
  ASSERT(RHS&AT(fs),EVDOMAIN);
  if(!b)R fs;
  ASSERT(1>=AR(arg),EVRANK);
  n=AN(arg); x=(A*)AV(arg);
  if(!n)R fs;
  ASSERT(BOX&AT(arg),EVDOMAIN);
  ASSERT(nc(fs)==3+n,EVLENGTH);
  R 1==n ? df1(fxr(x[0]),fs) : df2(fxr(x[0]),fxr(x[1]),fs);
}}


static F1(sr1){R srep(dash,w);}

F2(srep){PROLOG;A*v,y,z;C s[13];I m,t;
 RZ(a&&w);
 GA(y,BOX,7,1,0); v=(A*)AV(y);
 t=AT(w); if(t&FUNC)RZ(w=aro(w));
 RZ(v[1]=cstr(t&CHAR+NAME?"c":t&NUMERIC?"n":t&BOX?"xb":t&BOXK?"xk":
     t&VERB?"xv":t&ADV?"xa":t&CONJ?"xc":"?"));
 t=AT(w);
 RZ(v[2]=NAME&AT(a)?str(AN(a),AV(a)):a);
 sprintf(s," %ld ",AR(w)); RZ(v[3]=cstr(s));
 if(AR(w)){RZ(v[4]=thorn1(shape(w))); RZ(v[5]=scc(' '));} else v[4]=v[5]=mtv;
 RZ(v[6]=t&BOX+BOXK?raze(every(t&BOX?w:kbox(w),sr1)):thorn1(ravel(w)));
 m=0; DO(AN(y)-1,m+=AN(v[1+i]);); sprintf(s,"%ld",m); RZ(v[0]=cstr(s));
 z=raze(y);
 EPILOG(z);
}

static A unw(n,s,s1,b)B b;I n;C*s,**s1;{A nm=0,*x,sh,z;C c,*s0=s,*t;
    I d,k,m,n0=n,p,q,r,*v;
 RZ(s=fi(s,&m)); *s1=m+s; q=s-s0;
 ASSERT(6<=m&&m<=n-q,EVLENGTH);
 c=*s++; d='c'==c||'p'==c?CHAR:'n'==c?INT:0;
 if('x'==c){c=*s++; d='a'==c?ADV:'b'==c?BOX:'k'==c?BOXK:'c'==c?CONJ:'v'==c?VERB:0;}
 ASSERT(d&&(b||d&NOUN),EVDOMAIN);
 t=strchr(s,' '); k=t-s; ASSERT(t&&k,EVILNAME);
 if(1<k||'-'!=*s)RZ(nm=onm(str(k,s)));
 RZ(s=fi(t,&r)); ASSERT(r<=RMAX,EVLIMIT);
 ASSERT(' '==*s++,EVDOMAIN);
 GA(sh,INT,r,1,0); v=AV(sh);
 if(r){DO(r, RZ(s=fi(s,i+v));); ASSERT(' '==*s++,EVDOMAIN);}
 p=prod(r,v); k=(s-s0)-q; n-=k;
 if(d&CHAR||d&FUNC&&2>=m-k)RZ(z=str(m-k,s))
 else if(d&INT)RZ(z=connum(m-k,s))
 else{I pp=d&BOXK?p+p:p;
  GA(z,d&BOXK?d:BOX,p,r,v); x=(A*)AV(z);
  DO(pp, RZ(*x++=unw(n,t=s,&s,0)); n-=s-t; ASSERT(n||i==pp-1,EVLENGTH););
  ASSERT(m==n0-n,EVLENGTH);
 }
 ASSERT(p==AN(z),EVLENGTH);
 if(d&FUNC){RZ(z=fx(z)); ASSERT(d&AT(z),EVDOMAIN);}
 else if(d&CHAR+INT)RZ(z=reshape(sh,z));
 symbis(nm,z,global);
 R z;
}

F1(unsr){A z=mtv;C*s,*t;I n;
 RZ(vs(w));
 s=t=(C*)AV(w); while(' '==*s)++s;
 if(n=AN(w)-(s-t))do{RZ(z=unw(n,t=s,&s,1)); while(' '==*s)++s;}while(n-=s-t);
 R z;
}
