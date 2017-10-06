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
/* Xenos: Workspace stuff                                                  */
/*                                                                         */
/*                                                                         */
/* Internal Organization of Workspaces:                                    */
/*                                                                         */
/* Objects are represented in WSIS format.                                 */
/* The first NWPFX bytes are two fixed variables, "wpfx":                  */
/*   wsis    scalar 0 (required by WSIS)                                   */
/*   -       scalar 1 (indicates version 1)                                */
/* The next NWPTR bytes are an anonymous 4-element integer vector, "wptr": */
/*   0 index  of name list "wp"                                            */
/*   1 length of name list                                                 */
/*   2 index  of pointers "wq"                                             */
/*   3 length of pointers                                                  */
/* wp is a string of the names in the ws, separated by spaces.             */
/* wq is a corresponding 3-column integer matrix:                          */
/*   0 index                                                               */
/*   1 length                                                              */
/*   2 internal type                                                       */
/* wp and wq typically come at the end of the WS.                          */

#include "j.h"
#include "x.h"

#if (SYS & SYS_PC)
#define NXIL            8000
#else
#define NXIL            32000
#endif

#define NW              (NWPFX+NWPTR)
#define NWPFX           20L
#define NWPTR           50L

#define WF1(g)          A g(f)FILE*f;
#define WF2(g)          A g(f,w)FILE*f;A w;


static A wp;
static A wq;
static I wptr[4];
static C wpfx[1+NWPFX] = "9pwsis 0 09n- 0 1   ";

static F1(gnl){A loc=local,z; local=0; z=nl1(apv(4L,2L,1L)); local=loc; R z;}

static F1(xil){I c,i,j=0,k,m,n,*v;
 RZ(w=grade2(w,w));
 n=*AS(w); k=c=*(1+AS(w));
 if(1>=n)R w;
 v=AV(w); m=v[1+j];
 for(i=1;i<n;++i){
  if(v[k]!=m+v[j]||NXIL<m+v[1+k]){v[1+j]=m; v[j+=c]=v[k]; m=v[1+k];}
  else m+=v[1+k];
  k+=c;
 }
 v[1+j]=m;
 R take(sc(1+j/c),w);
}

static WF2(wcp){I j,old=tbase+ttop,*qv;
 RZ(w=xil(w));
 qv=AV(w);
 DO(*AS(w), j=*qv++; RZ(unsr(rd(f,j,*qv++))); qv++; tpop(old););
 R one;
}

static F1(ung){A b,p,s,*u,*v;I m=0;
 RZ(s=str(0L,"")); RZ(p=ca(wp)); u=(A*)AV(p); v=(A*)AV(wp);
 DO(AN(wp), if(CESC2==cl(*v++))++m; else *u++=s;);
 if(m){
  RZ(b=not(eps(wp,repeat(eps(p,gnl(mtv)),p))));
  RZ(wp=repeat(b,wp));
  RZ(wq=repeat(b,wq));
 }
 R mark;
}

static WF1(copy1f){RZ(ung(mark)); R wcp(f,wq);}

static WF2(copy2f){A y;
 RZ(ung(mark));
 RZ(wcp(f,repeat(eps(ii(wq),y=indexof(wp,w)),wq)));
 R lt(y,tally(wp));
}

static WF1(pcopy1f){R wcp(f,repeat(not(eps(wp,gnl(mtv))),wq));}

static WF2(pcopy2f){A b;
 RZ(b=not(eps(wp,gnl(mtv))));
 RZ(wp=repeat(b,wp));
 RZ(wq=repeat(b,wq));
 R copy2f(f,w);
}


static F1(catsp){R over(w,scc(' '));}

static I wend(w)A w;{RZ(w); if(AN(w)){I*v=AV(w)+AN(w)-3; R*v+*(1+v);}else R NW;}

static WF1(wrdir){A t,y;
 RZ(y=AN(wp)?raze(every(wp,catsp)):mtv);
 wptr[0]=ftell(f); RZ(wa(f,-1L,t=srep(dash,y ))); wptr[1]=AN(t);
 wptr[2]=ftell(f); RZ(wa(f,-1L,t=srep(dash,wq))); wptr[3]=AN(t);
 RZ(wa(f,-1L,str(9L,"8pend 0 0")));
 GA(t,INT,4,1,0); MC(AV(t),wptr,16L);
 RZ(wa(f,NWPFX,take(sc(NWPTR),srep(dash,t))));
 R mtv;
}

static WF1(psave1f){ASSERT(0,EVNONCE);}

static WF2(psave2f){ASSERT(0,EVNONCE);}

static WF1(save1f){A p,t,y;C*pv;I d,i,k,m=AN(global),n,old,*qv;SY*e,*ee=(SY*)AV(global);
 RZ(wa(f,-1L,str(NW,wpfx)));
 e=ee; d=n=0; DO(m, if(e->val){++n; d+=AN(e->name);} ++e;);
 GA(p,CHAR,d+n,1,0); pv=(C*)AV(p);
 GA(wq,INT,3*n,2,0); *AS(wq)=n; *(1+AS(wq))=3; qv=AV(wq);
 e=ee; k=NW; old=tbase+ttop;
 for(i=0;i<m;++i,++e)
  if(e->val){
   y=e->name; d=AN(y); MC(pv,AV(y),d); pv+=d; *pv++=' ';
   RZ(wa(f,-1L,t=srep(y,e->val)));
   *qv++=k; *qv++=AN(t); *qv++=AT(e->val); k+=AN(t);
   tpop(old);
  }
 RZ(wp=words(p)); RZ(wrdir(f));
 R one;
}

static WF2(save2f){A b,t,*v,y,z;I i,k,n,old,*qv;
 RZ(z=eps(w,gnl(mtv)));
 RZ(w=nub(repeat(z,w)));
 RZ(b=not(eps(wp,w)));
 RZ(wq=repeat(b,wq)); fseek(f,k=wend(wq),SEEK_SET);
 RZ(wp=over(repeat(b,wp),w));
 n=AN(wq); RZ(wq=take(tally(wp),n?wq:over(wq,two))); qv=n+AV(wq);
 n=AN(w); v=(A*)AV(w); old=tbase+ttop;
 for(i=0;i<n;++i){
  RZ(wa(f,-1L,t=srep(v[i],y=srd(v[i],global))));
  *qv++=k; *qv++=AN(t); *qv++=AT(y); k+=AN(t);
  tpop(old);
 }
 RZ(wrdir(f));
 R z;
}

static WF2(wexf){A b,t,*u,z;I*bv,m,n,*x;
 RZ(z=indexof(wp,w));
 m=AN(w); n=AN(wp); u=(A*)AV(w); x=AV(z);
 RZ(b=apv(n,1L,0L)); bv=AV(b);
 DO(m, if(n==x[i]){t=u[i]; RZ(vs(t)); x[i]=vnm(AN(t),AV(t));}else{bv[x[i]]=0; x[i]=1;});
 RZ(wp=repeat(b,wp));
 RZ(wq=repeat(b,wq));
 fseek(f,wend(wq),SEEK_SET);
 RZ(wrdir(f));
 R z;
}

static WF2(wncf){A t,*u,z;B b;I i,j,m,n,*v,*x;
 RZ(z=indexof(wp,w));
 m=AN(w); n=AN(wp); u=(A*)AV(w); v=AV(wq); x=AV(z);
 for(i=0;i<m;++i)
  if(n==*x){t=u[i]; b=AN(t)&&AT(t)&CHAR+NAME&&1>=AR(t)&&vnm(AN(t),AV(t)); *x++=-!b;}
  else{j=v[2+3**x]; *x++=j&NOUN?2:j&VERB?3:j&ADV?4:5;}
 R z;
}

static WF1(wnlf){R grade2(wp,ope(wp));}


static FILE*wopen(w,md)A w;S md;{A t;FILE*f;
 RZ(f=jfopen(w,md==WREAD?FREAD:md==WUPDATE?FUPDATE:FWRITE));
#if (!LINKJ && SYS & SYS_MACINTOSH)
 if(md!=WREAD)setftype(*(A*)AV(w),'WKSP','ISIj');
#endif
 wp=wq=0;
 if(md!=WWRITE){
  RZ(t=rd(f,-1L,NWPFX));
  ASSERT(!memcmp(AV(t),wpfx,NWPFX),EVDOMAIN);
  RZ(t=unsr(rd(f,-1L,NWPTR))); MC(wptr,AV(t),16L);
  RZ(wp=words(unsr(rd(f,wptr[0],wptr[1]))));
  RZ(wq=unsr(rd(f,-1L,wptr[3])));
  ASSERT(2==AR(wq),EVRANK);
  ASSERT(AN(wp)==*AS(wq)&&3==*(1+AS(wq)),EVLENGTH);
  if(!AN(wq))GA(wq,INT,0,2,AS(wq));
  ASSERT(INT&AT(wq),EVDOMAIN);
 }
 R f;
}

static A wopr1(w,ff,fa,md)A w;AF ff,fa;int md;{PROLOG;A z;FILE*f;
 RZ(w);
 if(1<AN(w))R rank1ex(w,0L,0L,fa);
 RZ(f=wopen(w,md)); sprintf(3+qpps,"%ldg",NPP);
 z=ff(f);
 fclose(f); MC(3+qpps,"6g",3L);
 EPILOG(z);
}

static A wopr2(a,w,ff,fa,md)A a,w;AF ff,fa;int md;{PROLOG;A z;FILE*f;
 RZ(a&&w);
 if(1<AN(w))R rank2ex(a,w,0L,0L,0L,fa);
 ASSERT(BOX&AT(a),EVDOMAIN);
 RZ(f=wopen(w,md)); sprintf(3+qpps,"%ldg",NPP);
 z=ff(f,every(a,rankle));
 fclose(f);  MC(3+qpps,"6g",3L);
 EPILOG(z);
}

F1(copy1 ){R wopr1(  w,copy1f, copy1, WREAD  );}

F2(copy2 ){R wopr2(a,w,copy2f, copy2, WREAD  );}

F1(pcopy1){R wopr1(  w,pcopy1f,pcopy1,WREAD  );}

F2(pcopy2){R wopr2(a,w,pcopy2f,pcopy2,WREAD  );}

F2(wex   ){R wopr2(a,w,wexf,   wex,   WUPDATE);}

F2(wnc   ){R wopr2(a,w,wncf,   wnc,   WREAD  );}

F1(wnl   ){R wopr1(  w,wnlf,   wnl,   WREAD  );}

F1(save1 ){R wopr1(  w,save1f, save1, WWRITE );}

F2(save2 ){R wopr2(a,w,save2f, save2, WUPDATE);}

F1(psave1){R wopr1(  w,psave1f,psave1,WWRITE );}

F2(psave2){R wopr2(a,w,psave2f,psave2,WUPDATE);}
