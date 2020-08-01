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
/* builtin.h */

#define  CALL              10
#define  LOAD              11
#define	 GET_SIMPATH	   12
#define  STLOOKUP	   14
#define  WRITEPTR	   15
#define  RESET             16
#define  REWRITE           17
#define  GET0              18
#define  GET               19
#define  SKIP              20
#define  READ              21
#define  READNAME          22
#define  CLOSE             23
#define  PUT               24
#define  TAB               25
#define  NL                26
#define  ACCESS            27
#define  FILEERRORS        28
#define  NOFILEERRORS      29
#define  SEE               30
#define  SEEING            31
#define  SEEN              32
#define  TELL              33
#define  TELLING           34
#define  TOLD              35

#define  STATISTICS0       40
#define  STATISTICS        41
#define  SYMTYPE           42
#define  HASHVAL           43

#define  SUBSTRING         51
#define  SUBNUMBER         52
#define  SUBDELIM          53
#define  CONLENGTH         54

#define  WRITE4            59
#define  ARITH             60
#define  FLOATC            61

#define  REAL              62
#define  FLOOR0            63
#define  VAR               64
#define  NONVAR            65
#define  ATOM              66
#define  INTEGER           67
#define  ATOMIC            68
#define  ARITY             69
#define  CPUTIME           70
#define  STATS             71
#define  DBREF		   72
#define  COMPARE           73
#define  SAVE              74
#define  RESTORE           75
#define  ALLOC_BUFF        76
#define  BUFF_CODE         77
#define  TRIMBUFF          79

#define  ARG0              80
#define  FUNCTOR0          81
#define  SYSTEM0           82
#define  SYSCALL           83
#define  BLDSTR            84
#define  MKSTR             85
#define  BLDATOM           98
#define  NAME0             99
#define  ERRNO            101

#define  TRACE            110
#define  PILTRACE         111
#define  UNTRACE          112
#define  FLAGS            113

#define  TERMREP          127
#define  NUMBER           128
#define  STRUCTURE        129
#define  WRITEQNAME       130
#define  WRITENAME        133

#define  CURSES           134               /* for curses interface */

#define  NEXT_TOKEN       135

#include   "../sim.h"
#include   "../aux.h"

extern int (*branch_table[])();
