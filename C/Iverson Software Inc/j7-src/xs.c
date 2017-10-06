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
/* Scripts                                                                 */

#include "j.h"
#include "x.h"
#include "d.h"

C*         scad=0;     /* script ptr to start of next line */
C*         scpad=0;    /* script ptr to start of previous line */
C*         sczad=0;    /* script ptr to end of script */
static A   lastout;    /* previous outfile value           */
FILE*      outfile;    /* output file handle               */
B          tostdout=1; /* 1 if output to stdout            */

static FILE*sopen(w)A w;{A x;FILE*z;
 if(outfile)fclose(outfile);
 outfile=0; lastout=w;
 RZ(w);
 ASSERT(BOX&AT(w),EVDOMAIN);
 ASSERT(!AR(w),EVRANK);
 x=*(A*)AV(w);
 ASSERT(CHAR&AT(x),EVDOMAIN);
 z=outfile=fopen((C*)AV(x),SAPPEND);
 ASSERT(z,EVFACE);
#if (SYS & SYS_MACINTOSH)
 setftype(x,'TEXT','ISIj');
#endif
 R z;
}

static A line(a,w,tso)A a,w;B tso;{A x,xl;B xt=tostdout;C *p,*sp,*spp,*spz;
  DC ds;I ln,old;
 RZ(w);
 ASSERT(CHAR&AT(w),EVDOMAIN);
 sp=scad; spz=sczad; spp=scpad;
 scad=(C*)AV(w); sczad=scad+AN(w); scpad=scad;
 ln=0;
 xl=lastout; sopen(a);
 RZ(ds=debadd(DCSCRP));
 tostdout=tso;
 old=tbase+ttop;
 while(1)
 {
   ds->ln=ln++; 	
   jerr=0; x=jgets("   ");
   if(!jerr&&!x)break;
   if(jerr)x=mtv; else immex(x);
   tpop(old);
 }
 scad=sp; scpad=spp; sczad=spz; tostdout=xt; sopen(xl);
 debz();
 R mtv;
}

static A linf(a,w,tso)A a,w;B tso;{A x;
 RZ(w);
 if(!(BOX&AT(w)&&AN(w)&&(x=*(A*)AV(w),!AN(x)&&1==AR(x))))R line(a,jfread(w),tso);
 tostdout=tso; sopen(a); lastout=0;
 R mtv;
}

F1(script1 ){F1RANK(  0,script1, 0); R linf(0L,w,1);}

F2(script2 ){F2RANK(0,0,script2, 0); R linf(a ,w,1);}

F1(sscript1){F1RANK(  0,sscript1,0); R linf(0L,w,0);}

F2(sscript2){F2RANK(0,0,sscript2,0); R linf(a ,w,0);}

F1(line1   ){F1RANK(  1,line1,   0); R line(0L,w,1);}

F2(line2   ){F2RANK(0,1,line2,   0); R line(a ,w,1);}

F1(sline1  ){F1RANK(  1,sline1,  0); R line(0L,w,0);}

F2(sline2  ){F2RANK(0,1,sline2,  0); R line(a ,w,0);}

#if (SYS & SYS_ARCHIMEDES+SYS_MACINTOSH)

static JF               jstfrec={0,0L,0,0};
JF                     *jstf=&jstfrec;

#if (SYS & SYS_MACINTOSH)
static C appf1(act,w)C act;A w;{A t;C*s;fileParam f;
 RZ(w);
 t=*(A*)AV(w); s=(C*)AV(t);
 if(act==JFSAVE){/* save script here */}
 else if(act==JFOPEN){
  f.ioNamePtr=(StringPtr)s;
  f.ioVRefNum=jstf->vol;
  f.ioFDirIndex=0;
  JSPR("\rscript %s saved 1991-xx-xx xx:xx:xx\r",s);
  script1(w,0L);
}}

B appf(){C a;
 if(a=jstf->act){ioParam pb,pb0;
  jstf->act=0; pb.ioNamePtr=NULL; pb0.ioNamePtr=NULL;
  PBGetVol(&pb0,false);
  if(a==JFPROFILE){AppFile f;C*t;S i,msg,n;
   CountAppFiles(&msg,&n);
   n=msg==appOpen?n:0;
   for(i=1;i<=n;++i){
    GetAppFiles(i,&f); jstf->type=f.fType; t=(C*)&f.fName;
    pb.ioNamePtr=NULL; pb.ioVRefNum=f.vRefNum; PBSetVol(&pb,false);
    appf1(JFOPEN,box(str((I)*t,1+t)));
  }}else{
   pb.ioNamePtr=NULL;  pb.ioVRefNum=jstf->vol; PBSetVol(&pb,false);
   appf1(a,box(cstr(jstf->name)));
  }
  PBSetVol(&pb0,false);
 }
 R a;
}
#endif

#if (SYS & SYS_ARCHIMEDES)
static C appf1(act,w)C act;A w;{
 RZ(w);
 if(act==JFSAVE){/* save script here */}
 else if(act==JFOPEN) script1(w,0L);
}

B appf(){C a; if(a=jstf->act){jstf->act=0; appf1(a,box(cstr(jstf->name)));} R a;}
#endif

#endif
