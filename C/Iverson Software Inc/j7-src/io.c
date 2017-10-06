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
/* Input/Output                                                            */

#include "j.h"

static void     sesmexit();
C               ibuf[2+NIBUF];
I               jbrk=0;
C               obuf[NOBUF];

A inpl(e,n,s)B e;I n;C*s;{A z;C c;
 jbrk=0;
 if(n&&(c=*(s+n-1),CLF==c||CCR==c))--n;
 if(n&&COFF==*(s+n-1))joff(zero);
 ASSERT(5!=n||memcmp(s,"o\010u\010t",n),EVINPRUPT);
 RZ(z=str(n,s)); s=(C*)AV(z);
 if(e){jputs(qprompt); jputs(s); jputc(CNL);}
 else if(outfile){fputs(s,outfile); fputc(CNL,outfile);}
 R z;
}

F1(joff){if(outfile&&outfile!=stdout)fclose(outfile); sesmexit(); exit(0);R 0;}

void jouts(s)C*s;{if(outfile)fputc(COUT,outfile); jputs(s);}

static void sigint(k)int k;{++jbrk; signal(SIGINT,sigint);}

static void scadup(){
  while(scad<sczad&&CNL!=*scad&&CEOF!=*scad)++scad; ++scad;
}

static B scget(s)C*s;{C*p;I n;
 while(scad<sczad&&COUT==*scad)scadup();
 if(scad>=sczad||CEOF==*scad)R 0;
 jputs(s);
 scpad=scad;
 scadup();
 n=scad-scpad-1;
 strncpy(ibuf,scpad,(n<NIBUF)?n : NIBUF);
 ibuf[n]=0;
 if(n>0&&ibuf[n-1]<32)ibuf[n-1]=0;
 jputs(ibuf);
 jputc(CNL);
 R 1;
}

/* --------------------- Special Session Manager ------------------------- */

#if (SYS & SYS_SESM)


#if (SYS & SYS_PC386)
C*edbuf;
#endif

C breaker(){if(sesm)jstpoll(); if(jbrk){jbrk=0; jsignal(EVBREAK);} R!jerr;}

A jgets(s)C*s;{
 if(scad){RZ(scget(s));}
   else{prompt(s); if(sesm)jsti((SI)NIBUF,ibuf); else RZ(fgets(ibuf,NIBUF,stdin));}
 R inpl(0,(I)strlen(ibuf),ibuf);
}

void jputc(c)C c;{
 if(tostdout){if(sesm)jsto(MTYOUT,(SI)1,&c); else fputc(c,stdout);}
 if(outfile)fputc(c,outfile);
}

void jputs(s)C*s;{
 if(tostdout){if(sesm)jsto(MTYOUT,(SI)strlen(s),s); else fputs(s,stdout);}
 if(outfile)fputs(s,outfile);
}

void prompt(s)C*s;{
 if(tostdout){if(sesm)jsto(MTYOIN,(SI)strlen(s),s); else fputs(s,stdout);}
 if(outfile&&!sesm)fputs(s,outfile);
}

static void sesmexit(){if(sesm)jststop();}

C sesminit(){
 if(sesm){A t;I j,mask=0xfffffff0L;
  struct{Ptr vlog;SI nlog;Ptr vinb;SI ninb;Ptr vfkd;SI nfkd;Ptr vedb;SI nedb;}in;
#if (SYS & SYS_PC+SYS_PC386)
  /* The 15+ and &0xfffffff0 are because addresses must be segment aligned */
  GA(t,CHAR,15+NLOG,1,0); j=(I)(15+(C*)AV(t)); j&=mask; in.vlog=(Ptr)j; in.nlog=NLOG;
  GA(t,CHAR,15+NTA ,1,0); j=(I)(15+(C*)AV(t)); j&=mask; in.vinb=(Ptr)j; in.ninb=NTA ;
  GA(t,CHAR,15+NFKD,1,0); j=(I)(15+(C*)AV(t)); j&=mask; in.vfkd=(Ptr)j; in.nfkd=NFKD;
  GA(t,CHAR,15+NEDB,1,0); j=(I)(15+(C*)AV(t)); j&=mask; in.vedb=(Ptr)j; in.nedb=NEDB;
#endif
#if (SYS & SYS_PC386)
  edbuf=in.vedb;
#endif
  jstinit((Ptr)&in);
 }
#if (SYS & SYS_PC386)
 else jstsbrk();
#else
 signal(SIGINT,sigint);
#endif
 R 1;
}

C*wr(n,v)I n;C*v;{I k=0,m;
 if(tostdout){
  if(sesm)while(n>k&&!jerr){m=MIN(3000,n-k); jsto(MTYOUT,(SI)m,v+k); k+=m;}
  else    while(n>k&&!jerr)k+=fwrite(v+k,sizeof(C),(size_t)(n-k),stdout);
 }
 if(outfile){
  fputc(COUT,outfile);
  k=0;    while(n>k&&!jerr)k+=fwrite(v+k,sizeof(C),(size_t)(n-k),outfile);
 }
 jputc(CNL); R v+n;
}


/* --------------------- Others (No Session Manager) --------------------- */

#else

C breaker(){R!jerr;}

A jgets(s)C*s;{
 if(scad){RZ(scget(s));}
   else{prompt(s); RZ(fgets(ibuf,NIBUF,stdin));}
 R inpl(0,(I)strlen(ibuf),ibuf);
}

void jputc(c)C c;{if(tostdout)fputc(c,stdout); if(outfile)fputc(c,outfile);}

void jputs(s)C*s;{if(tostdout)fputs(s,stdout); if(outfile)fputs(s,outfile);}

void prompt(s)C*s;{jputs(s);}

static void sesmexit(){}

C sesminit(){signal(SIGINT,sigint); R 1;}

C*wr(n,v)I n;C*v;{I k=0;
 if(tostdout)while(n>k&&!jerr)k+=fwrite(v+k,sizeof(C),(size_t)(n-k),stdout);
 if(outfile){
  fputc(COUT,outfile);
  k=0;       while(n>k&&!jerr)k+=fwrite(v+k,sizeof(C),(size_t)(n-k),outfile);
 }
 jputc(CNL); R v+n;
}

#endif
