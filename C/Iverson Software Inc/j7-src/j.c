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
/* main(), Main Loop, & Global Variables                                   */

#include "j.h"


A a0j1;
A ainf;
A alp;
B asgn;
A dash;
A cnl;
B errsee=1;
D inf;
C jerr;
A jot;
A mark;
A mtm;
A mtv;
A mtc;
D nan;
A neg1;
A one;
A pie;
I qdisp[6]={1,2};
A qevm;
D qfuzz;
C qprompt[1+NPROMPT]="   ";
I qrl=16807;
B sesm;
D tssbase;
A two;
A zero;
Z zeroZ={0,0};

#if (SYS & SYS_PC)
U _stklen = 65535u;
#endif

#if (SYS & SYS_PC+SYS_PCWIN+SYS_PC386)
C qbx[11]={218,194,191, 195,197,180, 192,193,217, 179,196};
#else
C qbx[11]={43,43,43,    43,43,43,    43,43,43,    124,45 };
#endif


C immloop(){A x=mtv;I old=tbase+ttop;
#if (SYS & SYS_ARCHIMEDES+SYS_MACINTOSH)
 while(x)if(!appf()){
#else
 while(x){
#endif
  jerr=0; x=jgets(qprompt);
  if(jerr)x=mtv; else immex(x);
  tpop(old);
}}

#if !(SYS & SYS_PCWIN)
int main(argc,argv)int argc;C**argv;{if(jinit2(argc,argv))immloop();}
#endif


/* functions and variables of the LinkJ interface */

static I old;

C jinit(){C c=jinit2(0,0L); old=tbase+ttop; R c;}

A jx(s)C*s;{A t,*x;
 jerr=0; maxbytes=bytes;
 tpop(old);
 RZ(t=tokens(cstr(s)));
 x=(A*)AV(t);
 R MARK&AT(x[1])?mark:parse(t);
}

A jma(t,n,r)I t,n,r;{R ga(t,n,r,0L);}

C jfr(x)A x;{R fa(x)?1:0;}

A jset(name,x)C*name;A x;{R symbis(onm(cstr(name)),x,global);}
