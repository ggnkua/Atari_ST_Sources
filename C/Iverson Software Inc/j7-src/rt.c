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
/* Tree Representation                                                     */

#include "j.h"

static A trr();
static C xdash;


static F1(rc){A bot,p,*v,x,y;B b;C*bv,c,ul,ll,*pv;I j,k,m,n,*s,xn,*xv,yn,*yv;
 RZ(w);
 n=AN(w); s=AS(w); v=(A*)AV(w);
 xn=s[0]; RZ(x=apv(xn,0L,0L)); xv=AV(x);
 yn=s[1]; RZ(y=apv(yn,0L,0L)); yv=AV(y);
 j=0; DO(xn, xv[i]=IC(v[j]); j+=yn;);
 GA(bot,CHAR,yn,1,0); bv=(C*)AV(bot);
 ul=qbx[0]; ll=qbx[6];
 for(b=j=0;j<xn;++j,b=0<j)
  for(k=0;k<yn;++k){
   p=*v++;
   if(AN(p)){
    m=*(1+AS(p)); yv[k]=MAX(yv[k],m);
    pv=(C*)AV(p); c=*pv;
    if(b&&(c==ul&&' '!=bv[k]||c!=' '&&ll==bv[k])){xv[j-1]+=1; b=0;}
    bv[k]=*(pv+AN(p)-m);
   }else bv[k]=' ';
  }
 R link(x,y);
}

static I pad(a,w,zv)A a,w;C*zv;{C*u,*v,*wv;I c,d,r,*s;
 RZ(a&&w);
 s=AV(a); r=s[0]; d=s[1];
 if(AN(w)){
  c=*(1+AS(w)); wv=(C*)AV(w);
  if(c==d)MC(zv,wv,AN(w));
  else{
   zv-=d; v=zv+c-1; u=wv-c;
   DO(IC(w), MC(zv+=d,u+=c,c); v+=d; if(xdash==*v)memset(1+v,xdash,d-c););
 }}
 R r*d;
}

static F1(graft){A p,q,t,*u,x,y,z,*zv;C*v;I d,j,k,m,n,*pv,*s,xn,*xv,yn,*yv;
 RZ(t=rc(w)); u=(A*)AV(t);
 x=u[0]; xn=AN(x); xv=AV(x); m=0; DO(xn,m+=xv[i];);
 y=u[1]; yn=AN(y); yv=AV(y);
 RZ(p=v2(0L,0L));  pv=AV(p);
 GA(z,BOX,yn,1,0); zv=(A*)AV(z);
 u=(A*)AV(w);
 for(j=0;j<yn;++j){
  GA(q,CHAR,m*yv[j],2,0); s=AS(q); *s=m; *++s=yv[j];
  v=(C*)AV(q); memset(v,' ',AN(q));
  pv[1]=yv[j]; k=j-yn; DO(xn, *pv=xv[i]; RE(v+=pad(p,u[k+=yn],v)););
  zv[j]=q;
 }
 t=zv[0]; n=yv[0];
 if(1==m)RZ(p=scc(xdash))
 else{
  v=(C*)AV(t);         DO(m, if(' '!=*v){j=i;   break;} v+=n;);
  v=(C*)AV(t)+AN(t)-n; DO(m, if(' '!=*v){k=m-i; break;} v-=n;);
  d=k-j;
  GA(p,CHAR,m,1,0); v=(C*)AV(p); memset(v,' ',m);
  if(1==d)*(v+j)=xdash; else{memset(v+j,qbx[9],d); *(v+j)=*qbx; *(v+k-1)=qbx[6];}
 }
 RZ(zv[0]=overr(p,t));
 R z;
}

static A center(a,j,k,m)A a;I j,k,m;{A z;C*x;I n,*s;
 RZ(a);
 n=AN(a);
 GA(z,CHAR,m*n,2,0); s=AS(z); *s=m; *++s=n;
 x=(C*)AV(z); memset(x,' ',AN(z)); MC(x+n*(j+(m-(j+k))/2),AV(a),n);
 R z;
}

static F2(troot){A t,x;B b;C*u,*v;I j,k,m,n,*s;
 RZ(a&&w);
 m=AN(a); u=(C*)AV(a); b=!m||'0'<=*u&&*u<='9';
 GA(x,CHAR,b?1:4+m,1,0); v=(C*)AV(x);
 *v=xdash; if(!b){v[3+m]=xdash; v[1]=v[2+m]=' '; MC(2+v,u,m);}
 t=*(A*)AV(w); s=AS(t); m=*s; n=*(1+s);
 u=(C*)AV(t);         DO(m, if(' '!=*u){j=i; break;} u+=n;);
 u=(C*)AV(t)+(m-1)*n; DO(m, if(' '!=*u){k=i; break;} u-=n;);
 R link(center(x,j,k,m),w);
}

static F1(tleaf){A t,*x,z;C d[2],*v;I n,*s;
 RZ(w);
 GA(z,BOX,1,1,0); x=(A*)AV(z);
 if(CHAR&AT(w)&&1>=AR(w)){
  n=AN(w);
  GA(t,CHAR,2+n,2,0); s=AS(t); *s=1; *++s=2+n;
  v=(C*)AV(t); *v=xdash; *(v+1)=' '; MC(2+v,AV(w),n);
  *x=t;
 }else{
  RZ(t=matth1(w)); d[0]=xdash; d[1]=' ';
  RZ(*x=overr(center(str(2L,d),0L,0L,IC(t)),t));
 }
 R z;
}

static F1(connect){A*wv,x,y,z;B b,d;C c,*u,*xv,*yv,*zv;I e,i,j,m,n,p,q;
 RZ(w);
 n=AN(w); wv=(A*)AV(w); y=*wv; m=*AS(y);
 e=0; DO(n,e+=*(1+AS(wv[i])););
 GA(z,CHAR,m*e,2,AS(y)); *(1+AS(z))=e; zv=(C*)AV(z);
 for(i=0;i<n;++i){
  y=wv[i]; q=*(1+AS(y)); yv=(C*)AV(y);
  if(i){
   xv=(C*)AV(x)+p-1;
   for(j=0;j<m;++j){
    b=xdash==*xv; c=*yv; d=xdash==*(1+yv);
    if(b&&c==qbx[9])c=qbx[5];
    if(d&&c==qbx[5])c=qbx[4];
    if(d&&c==qbx[9])c=qbx[3];
    if(b&&c==qbx[6])c=qbx[7];
    *yv=c; yv+=q; xv+=p;
  }}
  u=zv-e; yv=(C*)AV(y)-q; DO(m, MC(u+=e,yv+=q,q);); zv+=q;
  x=y; p=q;
 }
 R z;
}

static F1(treach){R troot(scc('0'),graft(ope(every(w,trr))));}

static F1(trr){PROLOG;A fs,gs,hs,t,*x,z;C c,id;I fl,m;V*v;
 RZ(w);
 if(AT(w)&NOUN+NAME)R tleaf(w);
 v=VAV(w); id=v->id; fl=v->fl; fs=v->f; gs=v->g; hs=v->h;
 m=!!fs+!!gs+(id==CFORK||id==CFORKO);
 if(!m)R tleaf(spellout(id));
 if(evoke(w))R tleaf(CA==ctype[c=cf(fs)]?fs:spellout(c));
 GA(t,BOX,m,1,0); x=(A*)AV(t);
 if(0<m)RZ(x[0]=fl&VGERL?treach(every(fs,fx)):trr(fs));
 if(1<m)RZ(x[1]=fl&VGERR?treach(every(gs,fx)):trr(gs));
 if(2<m)RZ(x[2]=trr(hs));
 z=troot(spellout(id),graft(ope(t)));
 EPILOG(z);
}

F1(trep){PROLOG;A z; xdash=qbx[10]; z=connect(troot(mtv,trr(w))); EPILOG(z);}
