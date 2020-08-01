/************************************************************************
*									*
* The SB-Prolog System							*
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987	*
*									*
************************************************************************/

/*-----------------------------------------------------------------
SB-Prolog is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the SB-Prolog General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
SB-Prolog, but only under the conditions described in the
SB-Prolog General Public License.   A copy of this license is
supposed to have been given to you along with SB-Prolog so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies. 
------------------------------------------------------------------ */
/* init_branch.c */

#include "builtin.h"

extern int b_0();
extern int b_1();

extern int b_WRITEPTR();    /* temp! */

extern int b_NEXT_TOKEN();
extern int b_NAME0();
extern int b_BLDATOM();
extern int b_RESET();
extern int b_REWRITE();
extern int b_GET0();
extern int b_GET();
extern int b_SKIP();
extern int b_READ();
extern int b_READNAME();
extern int b_CLOSE();
extern int b_PUT();
extern int b_TAB();
extern int b_NL();
extern int b_ACCESS();
extern int b_FILEERRORS();
extern int b_NOFILEERRORS();
extern int b_ALLOC_BUFF();
extern int b_BUFF_CODE();
extern int b_TRIMBUFF();
extern int b_WRITE4();
extern int b_ARITH();
extern int b_FLOATC();
extern int b_REAL();
extern int b_FLOOR0();
extern int b_VAR();
extern int b_NONVAR();
extern int b_ATOM();
extern int b_INTEGER();
extern int b_ATOMIC();
extern int b_ARITY();
extern int b_STATS();
extern int b_DBREF();
extern int b_CPUTIME();
extern int b_COMPARE();
extern int b_SAVE();
extern int b_RESTORE();
extern int b_ARG0();
extern int b_FUNCTOR0();
extern int b_SYSTEM0();
extern int b_SYSCALL();
extern int b_ERRNO();
extern int b_BLDSTR();
extern int b_MKSTR();
extern int b_TERMREP();
extern int b_STRUCTURE();
extern int b_WRITEQNAME();
extern int b_WRITENAME();
extern int b_CALL();
extern int b_LOAD();
extern int b_GET_SIMPATH();
extern int b_SEE();
extern int b_SEEING();
extern int b_SEEN();
extern int b_TELL();
extern int b_TELLING();
extern int b_TOLD();
extern int b_STATISTICS0();
extern int b_STATISTICS();
extern int b_SYMTYPE();
extern int b_HASHVAL();
extern int b_TRACE();
extern int b_PILTRACE();
extern int b_UNTRACE();
extern int b_FLAGS();
extern int b_SUBSTRING();
extern int b_SUBNUMBER();
extern int b_SUBDELIM();
extern int b_CONLENGTH();
extern int b_STLOOKUP();

/* CURSES: add this instruction
extern int b_CURSES(); */

int (*branch_table[256])();

b_unused()
{
   printf("Builtin #%d is not implemented.\n", oprnd1);
   exit(111);
}

init_branch_table()
{
   WORD i;

   for (i = 0; i < 256; i++)
      branch_table[ i ] = b_unused;

   branch_table[ WRITEPTR     ] = b_WRITEPTR;    /* temp! */
   branch_table[ NEXT_TOKEN   ] = b_NEXT_TOKEN;
   branch_table[ VAR          ] = b_VAR;
   branch_table[ BUFF_CODE    ] = b_BUFF_CODE;
   branch_table[ TRIMBUFF     ] = b_TRIMBUFF;
   branch_table[ ALLOC_BUFF   ] = b_ALLOC_BUFF;
   branch_table[ SYSTEM0      ] = b_SYSTEM0;
   branch_table[ SYSCALL      ] = b_SYSCALL;
   branch_table[ ERRNO        ] = b_ERRNO;
   branch_table[ NONVAR       ] = b_NONVAR;
   branch_table[ TERMREP      ] = b_TERMREP;
   branch_table[ WRITE4       ] = b_WRITE4;
   branch_table[ ARITH        ] = b_ARITH;
   branch_table[ FLOATC       ] = b_FLOATC;
   branch_table[ REAL         ] = b_REAL;
   branch_table[ FLOOR0       ] = b_FLOOR0;
   branch_table[ INTEGER      ] = b_INTEGER;
   branch_table[ ATOM         ] = b_ATOM;
   branch_table[ ATOMIC       ] = b_ATOMIC;
   branch_table[ ARITY        ] = b_ARITY;
   branch_table[ STRUCTURE    ] = b_STRUCTURE;
   branch_table[ ARG0         ] = b_ARG0;
   branch_table[ FUNCTOR0     ] = b_FUNCTOR0;
   branch_table[ BLDSTR       ] = b_BLDSTR;
   branch_table[ MKSTR        ] = b_MKSTR;
   branch_table[ WRITEQNAME   ] = b_WRITEQNAME;
   branch_table[ FILEERRORS   ] = b_FILEERRORS;
   branch_table[ NOFILEERRORS ] = b_NOFILEERRORS;
   branch_table[ PUT          ] = b_PUT;
   branch_table[ GET0         ] = b_GET0;
   branch_table[ GET          ] = b_GET;
   branch_table[ SKIP         ] = b_SKIP;
   branch_table[ TAB          ] = b_TAB;
   branch_table[ NL           ] = b_NL;
   branch_table[ ACCESS       ] = b_ACCESS;
   branch_table[ READNAME     ] = b_READNAME;
   branch_table[ WRITENAME    ] = b_WRITENAME;
   branch_table[ RESET        ] = b_RESET;
   branch_table[ REWRITE      ] = b_REWRITE;
   branch_table[ CLOSE        ] = b_CLOSE;
   branch_table[ 0            ] = b_0;
   branch_table[ 1            ] = b_1;
   branch_table[ NAME0        ] = b_NAME0;
   branch_table[ BLDATOM      ] = b_BLDATOM;
   branch_table[ CALL         ] = b_CALL;
   branch_table[ LOAD         ] = b_LOAD;
   branch_table[ GET_SIMPATH  ] = b_GET_SIMPATH;
   branch_table[ SEE          ] = b_SEE;
   branch_table[ SEEING       ] = b_SEEING;
   branch_table[ SEEN         ] = b_SEEN;
   branch_table[ TELL         ] = b_TELL;
   branch_table[ TELLING      ] = b_TELLING;
   branch_table[ TOLD         ] = b_TOLD;
   branch_table[ CPUTIME      ] = b_CPUTIME;
   branch_table[ STATS        ] = b_STATS;
   branch_table[ DBREF        ] = b_DBREF;
   branch_table[ COMPARE      ] = b_COMPARE;
   branch_table[ SAVE         ] = b_SAVE;
   branch_table[ RESTORE      ] = b_RESTORE;
   branch_table[ STATISTICS0  ] = b_STATISTICS0;
   branch_table[ STATISTICS   ] = b_STATISTICS;
   branch_table[ SYMTYPE      ] = b_SYMTYPE;
   branch_table[ HASHVAL      ] = b_HASHVAL;
   branch_table[ TRACE        ] = b_TRACE;
   branch_table[ PILTRACE     ] = b_PILTRACE;
   branch_table[ UNTRACE      ] = b_UNTRACE;
   branch_table[ FLAGS        ] = b_FLAGS;
   branch_table[ SUBSTRING    ] = b_SUBSTRING;
   branch_table[ SUBNUMBER    ] = b_SUBNUMBER;
   branch_table[ SUBDELIM     ] = b_SUBDELIM;
   branch_table[ CONLENGTH    ] = b_CONLENGTH;
   branch_table[ STLOOKUP     ] = b_STLOOKUP;

/* CURSES: add this instruction
   branch_table[ CURSES       ] = b_CURSES;
*/

}
