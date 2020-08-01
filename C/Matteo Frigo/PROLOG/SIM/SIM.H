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
/* sim.h */

#include <stdio.h>
#include <math.h>

#define  STR_LIM 256  /* limit on the length of the name of a constant */
#define	 SIMPATH_LEN 1024  /* limit on length of SIMPATH */

#define MAXREGS       257  /* registers 1-256 correspond to args 1-256 */
#define MAXTRAPS      2
#define WRITEFLAG     1
#define READFLAG      0
#define MAX_LEN       1280
#define BUCKET_CHAIN  53
#define null          0
#define TRUE          1
#define FALSE         0
#define PERM          1
#define TEMP          0
#define CAR           1
#define CDR           0

#define T_ORDI        0    /* constant-type: no ep definition */
#define T_DYNA        1    /* constant-type: dynamic, code in buffer */
#define T_PRED        2    /* constant-type: ep points to compiled code */
#define T_BUFF        3    /* constant-type: no ep field at all */
#define T_TEMP_PRED  15    /* psc entry for predicate containing offset
                              entry point */

/* ---------- Type Specifiers ----------------------------------------------- */

typedef char                CHAR;     /*  8 bits */
typedef unsigned char       BYTE;     /*  8 bits */
typedef unsigned short int  WORD;     /* 16 bits */
typedef long int            LONG;     /* 32 bits */

typedef CHAR  *CHAR_PTR;              /* pointers to memory types */
typedef BYTE  *BYTE_PTR;
typedef WORD  *WORD_PTR;
typedef LONG  *LONG_PTR;

typedef struct psc_rec {
   BYTE      entry_type;
   BYTE      arity;
   WORD      length;
   CHAR_PTR  nameptr;
   LONG_PTR  ep;         /* entry point, various meanings */
   } *PSC_REC_PTR;

/* ---------- External variable declarations -------------------------------- */

extern LONG      maxmem, maxpspace, maxtrail;  /* declared in init.c */

extern LONG_PTR  memory;          /* heap, local stack   */
extern LONG_PTR  pspace;          /* psc records, instructions, p-names */
extern LONG_PTR  tstack;          /* trail stack */
extern LONG      reg[MAXREGS];    /* general purpose registers */

extern LONG_PTR  local_bottom;
extern LONG_PTR  heap_bottom;
extern LONG_PTR  trail_bottom;

extern CHAR_PTR  curr_fence;      /* ptr to next free byte in perm space */
extern CHAR_PTR  max_fence;       /* ptr to last+1 free byte in perm space */
extern WORD_PTR  inst_begin;      /* ptr to the beginning of inst. array */

extern LONG_PTR  ereg;            /* last activation record       */
extern LONG_PTR  breg;            /* last choice point            */
extern LONG_PTR  hreg;            /* top of heap                  */
extern LONG_PTR  trreg;           /* top of trail stack           */
extern LONG_PTR  hbreg;           /* heap backtrack point         */
extern LONG_PTR  sreg;            /* current build or unify field */
extern LONG_PTR  cpreg;           /* return point register        */
extern WORD_PTR  pcreg;           /* program counter              */

extern LONG_PTR  mheaptop, mlocaltop, mtrailtop;
extern int       pspace_used;     /* heap_used, stack_used, trail_used */

extern LONG_PTR  trap_vector[MAXTRAPS];
extern LONG_PTR  hash_table[BUCKET_CHAIN][2];

extern LONG      oprnd1, oprnd2, oprnd3;

extern WORD      flags[10];       /* user flags from command line: -u[0-9] */
extern BYTE      trace;           /* (0) 1 = trace on, 0 = trace off     */
extern BYTE      hitrace;         /* (1) 1 = hitrace on, 0 = hitrace off */
extern BYTE      overflow_f;      /* (2) 1 = ignore stack overflow       */
extern BYTE      disassem;
extern BYTE      trace_sta;       /* 1 = keep max stack size stats */
extern BYTE      call_intercept;  /* hitrace or trace_sta for efficiency */
extern int       num_line;        /* print instruction addresses on trace
				     and disassem */

extern LONG      nil_sym, list_str;

extern int       interrupt_code;

extern PSC_REC_PTR  list_psc;
extern PSC_REC_PTR  interrupt_psc;
extern PSC_REC_PTR  comma_psc;
