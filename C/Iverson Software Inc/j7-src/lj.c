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
/* LinkJ                                                                   */

#include "lj.h"


#if LINKJ

#define MARK    8192L
#define RPAR    2048L

extern I        bytes;
extern A        cstr();
extern A        fa();
extern A        ga();
extern A        global;
extern C        jinit2();
extern A        mark;
extern I        maxbytes;
extern A        onm();
extern A        parse();
extern A        symbis();
extern I        tbase;
extern A        tokens();
extern I        tpop();
extern I        ttop;

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

#endif
