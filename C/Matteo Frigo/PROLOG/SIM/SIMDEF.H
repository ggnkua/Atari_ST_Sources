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
/* simdef.h */

#include "sim.h"
#include <stdio.h>

LONG_PTR  memory;          /* heap, local stack */
LONG_PTR  pspace;          /* psc records, instructions, p-names */
LONG_PTR  tstack;          /* trail stack */
LONG      reg[MAXREGS];    /* general purpose registers */

LONG_PTR  local_bottom;
LONG_PTR  heap_bottom;
LONG_PTR  trail_bottom;

CHAR_PTR  curr_fence;      /* ptr to next free byte in perm space */
CHAR_PTR  max_fence;       /* ptr to last+1 free byte in perm space */
WORD_PTR  inst_begin;      /* ptr to the beginning of inst. array */

LONG_PTR  ereg;            /* last activation record       */
LONG_PTR  breg;            /* last choice point            */
LONG_PTR  hreg;            /* top of heap                  */
LONG_PTR  trreg;           /* top of trail stack           */
LONG_PTR  hbreg;           /* heap back track point        */
LONG_PTR  sreg;            /* current build or unify field */
LONG_PTR  cpreg;           /* return point register        */
WORD_PTR  pcreg;           /* program counter              */

LONG_PTR  mheaptop, mlocaltop, mtrailtop;
int       pspace_used;     /* heap_used, stack_used, trail_used */

LONG_PTR  trap_vector[MAXTRAPS];
LONG_PTR  hash_table[BUCKET_CHAIN][2];

LONG      oprnd1, oprnd2, oprnd3;

WORD      flags[10];       /* user flags from command line: -u[0-9] */
BYTE      trace;           /* (0) 1 = trace on, 0 = trace off     */
BYTE      hitrace;         /* (1) 1 = hitrace on, 0 = hitrace off */
BYTE      overflow_f;      /* (2) 1 = ignore stack overflow       */
BYTE      disassem;
BYTE      trace_sta;       /* 1 = keep max stack size stats */
BYTE      call_intercept;  /* hitrace or trace_sta for efficiency */
int       num_line;        /* print instruction addresses on trace
                              and disassem */

LONG      nil_sym, list_str;

int       interrupt_code;

PSC_REC_PTR  list_psc;
PSC_REC_PTR  interrupt_psc;
PSC_REC_PTR  comma_psc;
