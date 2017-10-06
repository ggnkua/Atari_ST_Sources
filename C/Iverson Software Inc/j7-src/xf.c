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
/* Xenos: File stuff                                                       */

#include "js.h"

#if (SYS & SYS_PCWIN)
#include <windows.h>
#endif

#include "j.h"
#include "x.h"


#if (SYS & SYS_ARCHIMEDES)
#define Wimp_StartTask 0x400DE
static int unlink(s)C*s;{R remove(s);}
extern int os_swi1(I,I);
#endif

#if (SYS & SYS_MACINTOSH)
void setftype(A w,OSType type,OSType crea){C p[256];FInfo f;
 __c2p((C*)AV(w),p);
 GetFInfo(p,0,&f);
 f.fdType=type; f.fdCreator=crea;
 SetFInfo(p,0,&f);
}
#endif

#if (SYS & SYS_MACINTOSH)

F1(host  ){ASSERT(0,EVDOMAIN);}
F1(hostne){ASSERT(0,EVDOMAIN);}

#else

F1(host){A t,z;B b;C*fname,*s;FILE*f;I n;
 F1RANK(1,host,0);
 ASSERT(CHAR&AT(w),EVDOMAIN);
 n=AN(w);
 GA(t,CHAR,n+5+L_tmpnam,1,0); s=(C*)AV(t);
 fname=5+n+s; MC(s,AV(w),n);
#if (SYS & SYS_ARCHIMEDES)
 MC(n+s," { > ",5L); strcpy(fname,"<J$Dir>.Temp"); strcat(s," }");
 unlink(fname);
 b=sesm?!os_swi1(Wimp_StartTask,(I)s):!system(s);
#endif
#if (SYS & SYS_ATARIST)
 MC(n+s,"   > ",5L); MC(fname,"jxxhost",8L); b=!system(s);
#endif
#if (SYS & SYS_PCWIN)
 ASSERT(0,EVDOMAIN);
#endif
#if !(SYS & SYS_ARCHIMEDES+SYS_ATARIST+SYS_PCWIN)
 MC(n+s,"   > ",5L); tmpnam(fname);          b=!system(s);
#endif
 if(b){f=fopen(fname,FREAD); z=rd(f,-1L,fsize(f)); fclose(f);}
 unlink(fname);
 ASSERT(b&&f,EVFACE);
 R z;
}

F1(hostne){C*s;
 F1RANK(1,hostne,0);
 ASSERT(CHAR&AT(w),EVDOMAIN);
 s=(C*)AV(w);
#if (SYS & SYS_ARCHIMEDES)
 ASSERT(sesm?!os_swi1(Wimp_StartTask,(I)s):!system(s),EVFACE);
#endif
#if (SYS & SYS_PCWIN)
 ASSERT(32<=WinExec(s,0L),EVFACE);
#endif
#if !(SYS & SYS_ARCHIMEDES+SYS_PCWIN)
 ASSERT(!system(s),EVFACE);
#endif
 R mtv;
}

#endif


I fsize(f)FILE*f;{I z; RZ(f); fseek(f,0L,SEEK_END); z=ftell(f); rewind(f); R z;}

F2(jfappend){A t;FILE*f;
 F2RANK(RMAXL,0,jfappend,0);
 if(NUMERIC&AT(w)){ASSERT(2==i0(w),EVDOMAIN); R jpr(a);}
 RZ(t=vs(a));
 RZ(f=jfopen(w,FAPPEND));
#if (SYS & SYS_MACINTOSH)
 setftype(*(A*)AV(w),'TEXT','    ');
#endif
 wa(f,-1L,t);
 fclose(f);
 R mtv;
}

F1(jfdir){ASSERT(0,EVNONCE);}

F1(jferase){A t;FILE*f;
 F1RANK(0,jferase,0);
 RZ(f=jfopen(w,FREAD)); fclose(f);
 t=*(A*)AV(w);
 R unlink((C*)AV(t))?zero:one;
}

FILE*jfopen(w,mode)A w;C*mode;{A t;FILE*f;
 RZ(w);
 ASSERT(BOX&AT(w),EVDOMAIN);
 RZ(t=vs(*(A*)AV(w)));
 ASSERT(AN(t),EVLENGTH);
#if (SYS & SYS_MACINTOSH)
 ASSERT(AN(t)<256,EVLIMIT);
#endif
 f=fopen((C*)AV(t),mode); ASSERT(f,EVFACE);
 R f;
}

F1(jfread){A z;FILE*f;
 F1RANK(0,jfread,0);
 if(BOX&AT(w)){RZ(f=jfopen(w,FREAD)); z=rd(f,-1L,fsize(f)); fclose(f); R z;}
 else{ASSERT(1==i0(w),EVDOMAIN); R jgets("");}
}

F1(jfsize){FILE*f;I m;
 F1RANK(0,jfsize,0);
 RZ(f=jfopen(w,FREAD)); m=fsize(f); fclose(f);
 R sc(m);
}

F2(jfwrite){A t;FILE*f;B xt;
 F2RANK(RMAXL,0,jfwrite,0);
 if(NUMERIC&AT(w)){ASSERT(2==i0(w),EVDOMAIN); xt=tostdout; tostdout=1; t=jpr(a); tostdout=xt; R t;}
 RZ(t=vs(a));
 RZ(f=jfopen(w,FWRITE));
#if (SYS & SYS_MACINTOSH)
 setftype(*(A*)AV(w),'TEXT','    ');
#endif
 wa(f,-1L,t);
 fclose(f);
 R mtv;
}

static C vfin(w,f,i,n,rd)A w;FILE**f;I*i,*n;B rd;{A in;I j,k,m,s,*u;
 *f=0;
 ASSERT(BOX&AT(w),EVDOMAIN);
 ASSERT(2==AN(w),EVLENGTH);
 in=vi(*(1+(A*)AV(w))); k=AN(in);
 ASSERT(1>=AR(in),EVRANK);
 ASSERT(1==k||2==k,EVLENGTH);
 u=AV(in); j=u[0]; m=1==k?-1:u[1];
 ASSERT(1==k||0<=m,EVLENGTH);
 RZ(*f=jfopen(w,rd?FREAD:FUPDATE));
 s=fsize(*f);
 ASSERT(-s<=j&&j<s,EVINDEX);
 *i=j=0>j?s+j:j;
 if(!rd)ASSERT(j+*n<=s,EVINDEX);
 *n=m=0>m?s-j:m;
 ASSERT(j+m<=s,EVINDEX);
 R 1;
}

F1(jiread){A z;FILE*f;I i,n;
 F1RANK(1,jiread,0);
 if(vfin(w,&f,&i,&n,1))z=rd(f,i,n);
 if(f)fclose(f);
 R z;
}

F2(jiwrite){FILE*f;I i,n;
 F2RANK(RMAXL,1,jiwrite,0);
 RZ(a=vs(a)); n=AN(a);
 if(vfin(w,&f,&i,&n,0)){
#if (SYS & SYS_MACINTOSH)
  setftype(*(A*)AV(w),'TEXT','    ');
#endif
  wa(f,i,a);
 }
 if(f)fclose(f);
 R mtv;
}

A rd(f,j,n)FILE*f;I j,n;{A z;C*x;I p=0;size_t q=1;
 RZ(f);
 GA(z,CHAR,n,1,0); x=(C*)AV(z);
 if(0<=j)fseek(f,j,SEEK_SET);
 while(q&&n>p)p+=q=fread(p+x,sizeof(C),(size_t)(n-p),f);
 ASSERT(!ferror(f),EVFACE);
 R z;
}

A wa(f,j,w)FILE*f;I j;A w;{C*x;I n,p=0;size_t q=1;
 RZ(w&&f);
 n=AN(w); x=(C*)AV(w);
 if(0<=j)fseek(f,j,SEEK_SET);
 while(q&&n>p)p+=q=fwrite(p+x,sizeof(C),(size_t)(n-p),f);
 ASSERT(!ferror(f),EVFACE);
 R mtv;
} /* Write or append string w to file f */
