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
/* Initializations                                                         */

#include "j.h"
#include "x.h"

#define GG4(v,t,exp)    {GGA(v,t,1,0); *AV(v)=(I)(exp);}
#define GG8(v,t,exp)    {GGA(v,t,1,0); *(D*)AV(v)=(exp);}


#if (SYS & SYS_MACINTOSH)
#include "mac.h"
static A initevm(v,i,s)A*v;S i;C*s;{C x[256];
 GetIndString(x,IdErrMsgs,i);
 R v[i]=str((I)*x,1+x);
}
#else
static A initevm(v,i,s)A*v;S i;C*s;{R v[i]=cstr(s);}
#endif

static void sigflpe(k)int k;{jsignal(EVDOMAIN); signal(SIGFPE,sigflpe);}

C jinit2(argc,argv)int argc;C**argv;{A*v;B b=1,n=0;C p[256]="profile.js",*s;D*d;
 FILE*f;I i;S t;
 tssbase=tod();
 outfile=0;
#if !(SYS & SYS_ARCHIMEDES)
 b=isatty(fileno(stdin));
#endif
#if (SYS & SYS_SESM)
 sesm=b;
#endif
#if (SYS & SYS_PCWIN)
 s=*argv;
 while(*s){
  if(' '==*s){++s; continue;}
  if('/'==*s){
   if('n'==*++s) n=1;
   while(*s && ' '!=*s && '/'!=*s) ++s; 
   continue;
  }
  i=0; while(*s && ' '!=*s) p[i++]=*s++; p[i]=0;
 }
#else
 for(i=1;i<argc;i++){s=argv[i]; if('/'==*s && 's'==*++s) sesm=0;}
 for(i=1;i<argc;i++){s=argv[i]; if('/'==*s && 'n'==*++s) n=1;}
 for(i=1;i<argc;i++){s=argv[i]; if('/'!=*s) strcpy(p,s);}
#endif
 sesminit();
 symbinit();
 GGA(alp,CHAR,NALP,1); s=(C*)AV(alp); DO(NALP,*s++=i;); ps[psptr[(UC)CALP]].f1=(AF)alp;
 GGA(mtv, BOOL,0,1);
 GGA(mtc, CHAR,0,1);
 GGA(zero,BOOL,1,0); *(B*)AV(zero)=0;
 GGA(one, BOOL,1,0); *(B*)AV(one )=1;
 GGA(dash,CHAR,1,0); *(C*)AV(dash)='-';
 GGA(cnl,CHAR,1,0); *(C*)AV(cnl)=CNL;
 GGA(a0j1,CMPX,1,0); d=(D*)AV(a0j1); *d=0; *(1+d)=1;
 GG4(jot, BOX ,mtv);
 GG4(neg1,INT ,-1 );
 GG4(two, INT ,2  );
 GG4(mark,MARK,0  );
 GG8(pie ,FL  ,PI );
 GA(mtm,BOOL,0,2,&zeroZ);
 qct=1.0; DO(44, qct *=0.5;); qfuzz=qct;
 MC(&inf,XINF,(size_t)sizeof(D)); GGA(ainf,FL,1,0); *(D*)AV(ainf)=inf;
 MC(&nan,XNAN,(size_t)sizeof(D));
 GA(qevm,BOX,1+NEVM,1,0); v=(A*)AV(qevm);
 RZ(initevm(v,EVBREAK  ,"break"            ));
 RZ(initevm(v,EVDEFN   ,"defn error"       ));
 RZ(initevm(v,EVDOMAIN ,"domain error"     ));
 RZ(initevm(v,EVILNAME ,"ill-formed name"  ));
 RZ(initevm(v,EVILNUM  ,"ill-formed number"));
 RZ(initevm(v,EVINDEX  ,"index error"      ));
 RZ(initevm(v,EVINPRUPT,"input interrupt"  ));
 RZ(initevm(v,EVFACE   ,"interface error"  ));
 RZ(initevm(v,EVLENGTH ,"length error"     ));
 RZ(initevm(v,EVLIMIT  ,"limit error"      ));
 RZ(initevm(v,EVNONCE  ,"nonce error"      ));
 RZ(initevm(v,EVNOTASGN,"not reassignable" ));
 RZ(initevm(v,EVOPENQ  ,"open quote"       ));
 RZ(initevm(v,EVRANK   ,"rank error"       ));
 RZ(initevm(v,EVSPELL  ,"spelling error"   ));
 RZ(initevm(v,EVSYNTAX ,"syntax error"     ));
 RZ(initevm(v,EVSYSTEM ,"system error"     ));
 RZ(initevm(v,EVVALUE  ,"value error"      ));
 RZ(initevm(v,EVWSFULL ,"ws full"          ));
 RZ(initevm(v,EVSTOP   ,"stop"             ));
 RZ(initevm(v,EVRESULT ,"result error"     ));
 ra(qevm);
#if (SYS & SYS_PC)
 t=EM_ZERODIVIDE+EM_INVALID; _control87(t,t);
#endif
 if(b){
  jouts("J7 Copyright (c) 1990-1993, Iverson Software Inc.  All Rights Reserved.");
  jputc(CNL); jputc(CNL);
 }else qprompt[0]=0;
#if (SYS&SYS_MACINTOSH)
 jstf->act=JFPROFILE;
#endif
 f=fopen(p,"rb");
 if(f){fclose(f); if(n) sscript1(box(cstr(p)));else script1(box(cstr(p)));}
 R 1;
}
