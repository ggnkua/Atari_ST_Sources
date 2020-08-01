/************************************************************************
*                                                                       *
* The SB-Prolog System                                                  *
* Copyright SUNY at Stony Brook, 1986; University of Arizona, 1987      *
*                                                                       *
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
/* main.c */

#include "simdef.h"
#include "aux.h"
#include "inst.h"

#define NEXT_INSTRUCTION     goto contcase

#define OPREGC        (rreg[*lpcreg++])
#define OPREG         ((LONG)(rreg + *lpcreg++))
#define VARC(varno)   FOLLOW(lereg - (LONG)(varno))
#define OPVARC        VARC(*lpcreg++)
#define OPVAR         ((LONG)(lereg - (LONG)*lpcreg++))

#define PAD           lpcreg++
#define OP2WORD       op2 = *(LONG_PTR)lpcreg;  lpcreg += 2
#define NPARSE_VWv    op1 = OPVARC;  OP2WORD
#define NPARSE_RWv    op1 = OPREGC;  OP2WORD
#define NPARSE_Rv     op1 = OPREGC
#define NPARSE_Vv     op1 = OPVARC
#define NPARSE_PW     lpcreg++;  OP2WORD    /* note op2! */
#define NPARSE_BW     op1 = *lpcreg++;  OP2WORD
#define NPARSE_B      op1 = *lpcreg++

extern LONG_PTR set_intercode();
extern double   floatval();
extern LONG     makefloat();
extern          eval();

LONG   temp_res;
double result;
WORD   floatp, current_opcode;
LONG simpath;

main(argc, argv)
int  argc;
char *argv[];
{
   register WORD_PTR lpcreg;        /* local pcreg */
   register LONG_PTR lereg;         /* local ereg */
   register LONG_PTR rreg;          /* for SUN */
   register LONG_PTR sreg;
   register LONG_PTR top;
   register LONG     op1;
   LONG              op2, op3;
   LONG              top1, top2;
   PSC_REC_PTR       psc_ptr;
   WORD              i, arity;      /* to unify subfields of op1 and op2 */
   LONG_PTR          tempbreg;      /* for subtryme, rerestore, trrestore */
   LONG_PTR          oldtr;
   BYTE              flag;          /* read/write mode flag */

   arm_intercept();                 /* set up interrupt routine */
   init_sim(argc, argv);            /* set up memory according to arguments */

   /* init_parse_routine(); */      /* set up array of pointers to functions */
   init_load_routine();             /* set up array of pointers to functions */
   init_builtin();                  /* set up array of pointers to functions */
   init_loading(argc, argv);        /* load input files (bc_files) */
   init_simpath(&simpath);	    /* set up SIMPATH */

   if (disassem) {                  /* disassembly is requested */
      dis();
      printf("The byte code file is dumped in the file dump.pil\n");
      exit(0);
   }

   lpcreg = inst_begin;
   lereg = ereg;
   rreg   = (LONG_PTR)&reg[0];      /* for SUN */

/******************************************************************************/
contcase:                           /* TOP OF EXECUTION LOOP */

   switch (*lpcreg++) {             /* switch on current opcode */

      case getpvar:                 /* PSS    Variable, Register */
         PAD;
         op1 = *lpcreg++;
         VARC(op1) = OPREGC;
         NEXT_INSTRUCTION;

      case getpval:                 /* PVR */
         PAD;
         op1 = OPVARC;
         op2 = OPREGC;
         goto nunify;

      case getstrv:                 /* VW */
         NPARSE_VWv;
         goto nunify_with_str;

      case gettval:                 /* PRR */
         PAD;
         op1 = OPREGC;
         op2 = OPREGC;
         goto nunify;

      case getcon:                  /* RW */
         NPARSE_RWv;
         goto nunify_with_con;

      case getnil:                  /* R */
         NPARSE_Rv;
         goto nunify_with_nil;

      case getstr:                  /* RW */
         NPARSE_RWv;
         goto nunify_with_str;

      case getlist:                 /* R */
         NPARSE_Rv;
         goto nunify_with_list_sym;

      case unipvar:                 /* V */
         if (flag == WRITEFLAG) {
            OPVARC = (LONG)hreg;
            NEW_HEAP_FREE;
         } else OPVARC = *sreg++;
         NEXT_INSTRUCTION;

      case unipval:                 /* V */
         NPARSE_Vv;
         if (flag == WRITEFLAG)
            goto nbldval;
         else {
            op2 = *sreg++;
            goto nunify;
         }

      case unitvar:                 /* R */
         if (flag == WRITEFLAG) {
            OPREGC = (LONG)hreg;
            NEW_HEAP_FREE;
         } else OPREGC = *sreg++;
         NEXT_INSTRUCTION;

      case unitval:                 /* R */
         NPARSE_Rv;
         if (flag == WRITEFLAG)
            goto nbldval;
         else {
            op2 = *sreg++;
            goto nunify;
         }

      case unicon:                  /* PW */
         NPARSE_PW;                 /* note goes to op2! */
         if (flag == WRITEFLAG) {
            NEW_HEAP_CON(op2);
            NEXT_INSTRUCTION;
         } else {                   /* op2 already set */
            op1 = *sreg++;
            goto nunify_with_con;
         }

      case uninil:                  /* P */
         PAD;
         if (flag == WRITEFLAG) {
            NEW_HEAP_NODE(nil_sym);
            NEXT_INSTRUCTION;
         } else {
            op1 = *sreg++;
            goto nunify_with_nil;
         }

      case getnumcon:               /* RW */
         NPARSE_RWv;
         goto nunify_with_int;

      case putnumcon:               /* RW */
         op1 = *lpcreg++;
         rreg[op1] = MAKEINT(*(LONG_PTR)lpcreg);
         lpcreg += 2;
         NEXT_INSTRUCTION;

      case putpvar:                 /* PVR */
         PAD;
         op1 = OPVAR;
         FOLLOW(op1) = op1;
         OPREGC = op1;
         NEXT_INSTRUCTION;

      case putpval:                 /* PVR */
         PAD;
         op1 = *lpcreg++;
         OPREGC = VARC(op1);
         NEXT_INSTRUCTION;

      case puttvar:                 /* PRR */
         PAD;
         OPREGC = (LONG)hreg;
         OPREGC = (LONG)hreg;
         NEW_HEAP_FREE;
         NEXT_INSTRUCTION;

      case putstrv:                 /* VW */
         OPVARC = (LONG)hreg | CS_TAG;
         NEW_HEAP_NODE(*(LONG_PTR)lpcreg);
         lpcreg += 2;
         NEXT_INSTRUCTION;

      case putcon:                  /* RW */
         op1 = *lpcreg++;
         rreg[op1] = *(LONG_PTR)lpcreg | CS_TAG;
         lpcreg += 2;
         NEXT_INSTRUCTION;

      case putnil:                  /* R */
         OPREGC = nil_sym;
         NEXT_INSTRUCTION;

      case putstr:                  /* RW */
         OPREGC = (LONG)hreg | CS_TAG;
         NEW_HEAP_NODE(*(LONG_PTR)lpcreg);
         lpcreg += 2;
         NEXT_INSTRUCTION;

      case putlist:                 /* R */
         OPREGC = (LONG)hreg | LIST_TAG;
         NEXT_INSTRUCTION;

      case bldpvar:                 /* V */
         OPVARC = (LONG)hreg;
         NEW_HEAP_FREE;
         NEXT_INSTRUCTION;

      case bldpval:                 /* V */
         NPARSE_Vv;
         goto nbldval;

      case bldtvar:                 /* R */
         OPREGC = (LONG)hreg;
         NEW_HEAP_FREE;
         NEXT_INSTRUCTION;

      case bldtval:                 /* R */
         NPARSE_Rv;
         goto nbldval;

      case bldcon:                  /* PW */
         PAD;
         NEW_HEAP_CON(*(LONG_PTR)lpcreg);
         lpcreg += 2;
         NEXT_INSTRUCTION;

      case bldnil:                  /* P */
         PAD;
         NEW_HEAP_NODE(nil_sym);
         NEXT_INSTRUCTION;

      case uninumcon:               /* PL */
         NPARSE_PW;                 /* num in op2 */
         if (flag == WRITEFLAG) {
            NEW_HEAP_INT(op2);
            NEXT_INSTRUCTION;
         } else {                   /* op2 set */
            op1 = *sreg++;
            goto nunify_with_int;
         }

      case bldnumcon:               /* PL */
         NPARSE_PW;                 /* num in op2 */
         NEW_HEAP_INT(op2);
         NEXT_INSTRUCTION;

      case getfloatcon:             /* RW */
         NPARSE_RWv;
         goto nunify_with_float;

      case putfloatcon:             /* RW */
         op1 = *lpcreg++;
         rreg[op1] = *(LONG_PTR)lpcreg;
         lpcreg += 2;               /* float already tagged */
         NEXT_INSTRUCTION;

      case unifloatcon:             /* PL */
         NPARSE_PW;                 /* float in op2 */
         if (flag == WRITEFLAG) {
            NEW_HEAP_FLOAT(op2);
            NEXT_INSTRUCTION;
         } else {                   /* op2 set */
            op1 = *sreg++;
            goto nunify_with_float;
         }

      case bldfloatcon:             /* PL */
         NPARSE_PW;                 /* float in op2 */
         NEW_HEAP_FLOAT(op2);
         NEXT_INSTRUCTION;

      case test_unifiable:          /* RRR */
         /* if reg1 and reg2 are unifiable, then reg3 is set to 1,
          * else reg3 is set to 0.  Logically equivalent to
          * not(not(reg1 = reg2)).
          */
         op1 = OPREGC;
         op2 = OPREGC;
         op3 = OPREG;
         top1 = (LONG)trreg;
         FOLLOW(op3) = MAKEINT(unify(op1, op2));
         while ((LONG)trreg != top1) {    /* undo bindings, if any */
            top = (LONG_PTR)*(++trreg);
            *(LONG_PTR *)top = top;
         }
         NEXT_INSTRUCTION;

      case getlist_k:               /* R */
         PAD;
         flag = READFLAG;
         NEXT_INSTRUCTION;

      case getlist_k_tvar_tvar:     /* BBB */
         PAD;
         OPREGC = *sreg++;
         OPREGC = *sreg;
         NEXT_INSTRUCTION;

      case getlist_tvar_tvar:       /* BBB */
         op1 = OPREGC;
glrr:    switch (TAG(op1)) {
            case FREE: NDEREF(op1, glrr);
                       FOLLOW(op1) = (LONG)hreg | LIST_TAG;
                       PUSHTRAIL(op1);
                       OPREGC = (LONG)hreg;
                       NEW_HEAP_FREE;
                       OPREGC = (LONG)hreg;
                       NEW_HEAP_FREE;
                       NEXT_INSTRUCTION;
            case CS  :
            case NUM : FAIL1;
                       NEXT_INSTRUCTION;
            case LIST: sreg = (LONG_PTR)(UNTAGGED(op1));
                       OPREGC = *sreg++;
                       OPREGC = *sreg;
                       NEXT_INSTRUCTION;
         }  /* end getlist_tvar_tvar */

      case getcomma:                /* R */
         NPARSE_Rv;
         op2 = (LONG)comma_psc;
         goto nunify_with_str;

      case getcomma_tvar_tvar:      /* BBB */
         op1 = OPREGC;
gcrr:    switch (TAG(op1)) {
            case FREE: NDEREF(op1, gcrr);
                       FOLLOW(op1) = (LONG)hreg | CS_TAG;
                       PUSHTRAIL(op1);
                       NEW_HEAP_NODE((LONG)comma_psc);
                       PUSHTRAIL(op1);
                       OPREGC = (LONG)hreg;
                       NEW_HEAP_FREE;
                       OPREGC = (LONG)hreg;
                       NEW_HEAP_FREE;
                       NEXT_INSTRUCTION;
            case CS  : UNTAG(op1);
                       if (FOLLOW(op1) == (LONG)comma_psc) {
                          sreg = (LONG_PTR)(op1+4);
                          OPREGC = *sreg++;
                          OPREGC = *sreg;
                          NEXT_INSTRUCTION;
                       }
            case NUM :
            case LIST: FAIL1;
                       NEXT_INSTRUCTION;
         }  /* end getcomma_tvar_tvar */

      case trymeelse:               /* BA */
         NPARSE_BW;
         goto subtryme;

      case retrymeelse:             /* BA */
         op1 = *lpcreg++;
         *(breg + 1) = *(LONG_PTR)lpcreg;
         lpcreg += 2;
         goto rerestore;

      case trustmeelsefail:         /* B */
         NPARSE_B;
         goto trrestore;

      case try:                     /* BA */
         op1 = *lpcreg++;
         op2 = (LONG)(lpcreg + 2);
         lpcreg = (WORD_PTR)*(LONG_PTR)lpcreg;
         goto subtryme;

      case retry:                   /* BA */
         op1 = *lpcreg++;
         *(breg + 1) = (LONG)(lpcreg + 2);
         lpcreg = (WORD_PTR)*(LONG_PTR)lpcreg;
         goto rerestore;

      case trust:                   /* BA */
         op1 = *lpcreg++;
         lpcreg = (WORD_PTR)*(LONG_PTR)lpcreg;
         goto trrestore;

      case getpbreg:                /* V */
         OPVARC = (LONG)breg | NUM_TAG;
         NEXT_INSTRUCTION;

      case gettbreg:                /* R */
         OPREGC = (LONG)breg | NUM_TAG;
         NEXT_INSTRUCTION;

      case putpbreg:                /* V */
         NPARSE_Vv;
         DEREF(op1);
         breg  = (LONG_PTR)UNTAGGED(op1);
         hbreg = (LONG_PTR)*(breg + 3);
         NEXT_INSTRUCTION;

      case puttbreg:                /* R */
         NPARSE_Rv;
         DEREF(op1);
         breg = (LONG_PTR)UNTAGGED(op1);
         hbreg = (LONG_PTR)*(breg + 3);
         NEXT_INSTRUCTION;

      case switchonterm:            /* RWW */
         op1 = OPREGC;
sotd:    switch (TAG(op1)) {
            case FREE: NDEREF(op1, sotd);
                       lpcreg += 4;
                       NEXT_INSTRUCTION;
            case NUM : lpcreg = *(WORD_PTR *)lpcreg;
                       NEXT_INSTRUCTION;
            case CS  : if (GET_STR_ARITY(op1) == 0) {
                          lpcreg = *(WORD_PTR *)lpcreg;
                          NEXT_INSTRUCTION;
                       }
            case LIST: /* include structure case here */
                       lpcreg += 2;
                       lpcreg = *(WORD_PTR *)lpcreg;
                       NEXT_INSTRUCTION;
         }  /* end switchonterm */

      case arg:                     /* RRR */
         op1 = OPREGC;              /* index, i */
         op2 = OPREGC;              /* term being indexed into, T */
         op3 = OPREGC;              /* i_th. argument of T */
         DEREF(op1);
         if (!ISINTEGER(op1)) {
            printf("arg: Index must be an integer.\n");
            FAIL1;
            NEXT_INSTRUCTION;
         }
         op1 = INTVAL(op1);
         if (op1 <= 0) {
            printf("arg: index must be > 0\n");
            FAIL1;
            NEXT_INSTRUCTION;
         }
         DEREF(op2);
         if (ISCONSTR(op2) && op1 <= GET_STR_ARITY(op2))
            if (unify(*((LONG_PTR)UNTAG(op2) + op1), op3))
               NEXT_INSTRUCTION;
         if (ISLIST(op2) && op1 <= 2)
            if (unify(*((LONG_PTR)UNTAG(op2) + op1 - 1), op3))
               NEXT_INSTRUCTION;
         FAIL1;
         NEXT_INSTRUCTION;

      case arg0:                    /* RRR */
         op1 = OPREGC;              /* index, i */
         op2 = OPREGC;              /* term being indexed into, T */
         op3 = OPREGC;              /* i_th. argument of T */
         DEREF(op1);
         if (!ISINTEGER(op1)) {
            printf("arg: Index must be an integer.\n");
            FAIL1;
            NEXT_INSTRUCTION;
         }
         op1 = INTVAL(op1);
         if (op1 <= 0) {
            printf("arg: index must be > 0\n");
            FAIL1;
            NEXT_INSTRUCTION;
         }
         DEREF(op2);
         if (ISCONSTR(op2) && op1 <= GET_STR_ARITY(op2))
            op2 = *((LONG_PTR)UNTAG(op2) + op1);
         else if (ISLIST(op2) && op1 <= 2)
            op2 = *((LONG_PTR)UNTAG(op2) + op1 - 1);
         else {
            FAIL1;
            NEXT_INSTRUCTION;
         }
         DEREF(op3);
         if (ISNONVAR(op2)) {
            FOLLOW(op3) = op2;
            PUSHTRAIL(op3);
         } else {                          /* op2 is a variable */
            if (op2 != op3) {
               if (op2 < op3) {
                  if (op2 < (LONG)hreg) {  /* op2 not in loc stack */
                     FOLLOW(op3) = op2;
                     PUSHTRAIL(op3);
                  } else {                 /* op2 points to op3 */
                     FOLLOW(op2) = op3;
                     PUSHTRAIL(op2);
                  }
               } else {                    /* op2 > op3 */
                  if (op3 < (LONG)hreg) {
                     FOLLOW(op2) = op3;
                     PUSHTRAIL(op2);
                  } else {
                     FOLLOW(op3) = op2;
                     PUSHTRAIL(op3);
                  }
               }
            }
         }
         NEXT_INSTRUCTION;

      case switchonbound:           /* RWW */
         op1 = OPREGC;
sotd1:   switch (TAG(op1)) {
            case FREE: NDEREF(op1, sotd1);
                       lpcreg += 4;
                       NEXT_INSTRUCTION;
            case NUM : op1 = NUMVAL(op1);
                       break;
            case LIST: op1 = *(LONG_PTR)UNTAGGED(list_str);
                       break;
            case CS  : op1 = (LONG)GET_STR_PSC(op1);
                       break;
         }
         op2 = *(LONG_PTR)lpcreg;
         lpcreg += 2;
         op3 = *(LONG_PTR)lpcreg;
         lpcreg = *(WORD_PTR *)(IHASH(op1, op3) * 4 + op2);
         NEXT_INSTRUCTION;

      case switchonlist:            /* RWW */
         /* this is a specialization of the switchonterm instruction:
          * switchonlist R, L1, L2 means: if reg R DEREFs to '[]', goto
          * L1; if it DEREFs to [_|_], goto L2; if it DEREFs to a variable,
          * fall through; else fail.
          */
         op1 = OPREGC;
sold:    switch (TAG(op1)) {
            case FREE: NDEREF(op1, sold);
                       lpcreg += 4;
                       NEXT_INSTRUCTION;
            case NUM : FAIL1;
                       NEXT_INSTRUCTION;
            case CS  : if (op1 == nil_sym)
                          lpcreg = *(WORD_PTR *)lpcreg;
                       else
                          FAIL1;
                       NEXT_INSTRUCTION;
            case LIST: sreg = (LONG_PTR)(UNTAGGED(op1));
                       lpcreg += 2;
                       lpcreg = *(WORD_PTR *)lpcreg;
                       NEXT_INSTRUCTION;
         }  /* end switchonlist */

      case get_tag:                 /* PRR */
         /* DEREFs 1st operand reg, copies low 3 bits into 2nd operand reg */
         PAD;
         op1 = OPREGC;  DEREF(op1);
         OPREGC = MAKEINT(op1 & 0x7);
         NEXT_INSTRUCTION;

      case movreg:                  /* PRR */
         PAD;
         op1 = *lpcreg++;
         OPREGC = rreg[op1];
         NEXT_INSTRUCTION;

      case negate:
         op1 = *lpcreg++;
         op2 = rreg[op1];  DEREF(op2);
         if (!ISINTEGER(op2)) {
            printf("negate: integer required\n");
            FAIL1;
         } else rreg[op1] = MAKEINT(~INTVAL(op2));
         NEXT_INSTRUCTION;

      case and:
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         DEREF(op2);
         if (!ISINTEGER(op1) || !ISINTEGER(op2)) {
            printf("and: integer required\n");
            FAIL1;
         } else FOLLOW(op3) = MAKEINT(INTVAL(op2) & INTVAL(op1));
         NEXT_INSTRUCTION;

      case or:
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         DEREF(op2);
         if (!ISINTEGER(op1) || !ISINTEGER(op2)) {
            printf("or: integer required\n");
            FAIL1;
         } else FOLLOW(op3) = MAKEINT(INTVAL(op2) | INTVAL(op1));
         NEXT_INSTRUCTION;

      case lshiftl:
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         DEREF(op2);
         if (!ISINTEGER(op1) || !ISINTEGER(op2)) {
            printf("lshiftl: integer required\n");
            FAIL1;
         } else FOLLOW(op3) = MAKEINT(INTVAL(op2) << INTVAL(op1));
         NEXT_INSTRUCTION;

      case lshiftr:
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         DEREF(op2);
         if (!ISINTEGER(op1) ||!ISINTEGER(op2)) {
            printf("lshiftr: integer required\n");
            FAIL1;
         } else FOLLOW(op3) = MAKEINT(INTVAL(op2) >> INTVAL(op1));
         NEXT_INSTRUCTION;

      case addreg:                /* PRR */
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         if (ISINTEGER(op1))
            floatp = 0;
         else if (ISFLOAT(op1))
            floatp = 1;
         else {
            floatp = eval(op1, &top1);
            op1 = top1;
         }
         DEREF(op2);
         if (ISINTEGER(op2))
            ;
         else if (ISFLOAT(op2))
            floatp = floatp | 1;
         else {
            floatp = floatp | eval(op2, &top2);
            op2 = top2;
         }
         switch (floatp) {
            case -1: printf("add: number required\n");
                     FAIL1;
                     NEXT_INSTRUCTION;
            case  0: FOLLOW(op3) = MAKEINT(INTVAL(op2) + INTVAL(op1));
                     NEXT_INSTRUCTION;
            case  1: FOLLOW(op3) = makefloat(NUMVAL(op2) + NUMVAL(op1));
                     NEXT_INSTRUCTION;
         }
         NEXT_INSTRUCTION;

      case subreg:                /* PRR */
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         if (ISINTEGER(op1))
            floatp = 0;
         else if (ISFLOAT(op1))
            floatp = 1;
         else {
            floatp = eval(op1, &top1);
            op1 = top1;
         }
         DEREF(op2);
         if (ISINTEGER(op2))
            ;
         else if (ISFLOAT(op2))
            floatp = floatp | 1;
         else {
            floatp = floatp | eval(op2, &top2);
            op2 = top2;
         }
         switch (floatp) {
            case -1: printf("sub: number required\n");
                     FAIL1;
                     NEXT_INSTRUCTION;
            case  0: FOLLOW(op3) = MAKEINT(INTVAL(op2) - INTVAL(op1));
                     NEXT_INSTRUCTION;
            case  1: FOLLOW(op3) = makefloat(NUMVAL(op2) - NUMVAL(op1));
                     NEXT_INSTRUCTION;
         }
         NEXT_INSTRUCTION;

      case mulreg:                /* PRR */
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         if (ISINTEGER(op1))
            floatp = 0;
         else if (ISFLOAT(op1))
            floatp = 1;
         else {
            floatp = eval(op1, &top1);
            op1 = top1;
         }
         DEREF(op2);
         if (ISINTEGER(op2))
            ;
         else if (ISFLOAT(op2))
            floatp = floatp | 1;
         else {
            floatp = floatp | eval(op2, &top2);
            op2 = top2;
         }
         switch (floatp) {
            case -1: printf("mul: number required\n");
                     FAIL1;
                     NEXT_INSTRUCTION;
            case  0:  FOLLOW(op3) = MAKEINT(INTVAL(op2) * INTVAL(op1));
                     NEXT_INSTRUCTION;
            case  1: FOLLOW(op3) = makefloat(NUMVAL(op2) * NUMVAL(op1));
                     NEXT_INSTRUCTION;
         }
         NEXT_INSTRUCTION;

      case divreg:                /* PRR */
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         if (!ISNUM(op1)) {
            eval(op1, &top1);
            op1 = top1;
         }
         DEREF(op2);
         if (!ISNUM(op2)) {
            eval(op2, &top2);
            op2 = top2;
         }
         result = NUMVAL(op2) / NUMVAL(op1);
         FOLLOW(op3) = makefloat(result);
         NEXT_INSTRUCTION;

      case idivreg:               /* PRR */
         PAD;
         op1 = OPREGC;
         op3 = OPREG;
         op2 = FOLLOW(op3);
         DEREF(op1);
         if (ISINTEGER(op1))
            floatp = 0;
         else {
            floatp = eval(op1, &top1);
            op1 = top1;
         }
         DEREF(op2);
         if (ISINTEGER(op2))
            ;
         else {
            floatp = floatp | eval(op2, &top2);
            op2 = top2;
         }
         if (floatp != 0) {
            printf("integer division: operands must be integers\n");
            FAIL1;
         } else FOLLOW(op3) = MAKEINT(INTVAL(op2) / INTVAL(op1));
         NEXT_INSTRUCTION;

      case putdval:               /* PVR */
         PAD;
         op1 = OPVARC;  DEREF(op1);
         OPREGC = op1;
         NEXT_INSTRUCTION;

      case putuval:               /* PVR */
         PAD;
         op1 = OPVARC;  DEREF(op1);
         if (ISNONVAR(op1) || op1 < (LONG)hreg || op1 >= (LONG)lereg)
            OPREGC = op1;
         else {
            FOLLOW(op1) = OPREGC = (LONG)hreg;
            PUSHTRAIL(op1);
            NEW_HEAP_FREE;
         }
         NEXT_INSTRUCTION;

      case call:                  /* PW */
         NPARSE_PW;
         cpreg = (LONG_PTR)lpcreg;
         psc_ptr = (PSC_REC_PTR)op2;
         goto call_sub;

      case allocate:
         op1 = *lpcreg++;
         op2 = (breg < lereg) ? (LONG)breg : (LONG)(lereg - ENV_SIZE(cpreg));

	 /* check for heap overflow */
         if ((LONG_PTR)op2 - op1 < hreg) {
            ereg = lereg;
            /* garbage_collection("allocate"); */ /* GC buggy! */
	    if ((LONG_PTR)op2 - op1 < hreg) {    /* still too full */
	       quit("Heap overflow\n");
/*
	       if (!overflow_f) {
                  overflow_f = 1;
                  lpcreg = (WORD_PTR)set_intercode(2);
               }
*/
	    }
	 }

         FOLLOW(op2) = (LONG)lereg;
         FOLLOW(op2 - 4) = (LONG)cpreg;
	 lereg = (LONG_PTR)op2;
         for (op2 -= 8, op1 -= 2; op1 > 0; op2 -= 4, op1 -= 1)
            FOLLOW(op2) = op2;        /* init permanent vars */
         NEXT_INSTRUCTION;

      case deallocate:
         PAD;
         cpreg  = (LONG_PTR)*(lereg - 1);
         lereg = (LONG_PTR)*lereg;
         NEXT_INSTRUCTION;

      case proceed:
         PAD;
         lpcreg = (WORD_PTR)cpreg;
         NEXT_INSTRUCTION;

      case execute:
         NPARSE_PW;
         psc_ptr = (PSC_REC_PTR)op2;
         goto call_sub;

      case calld:
         PAD;
         cpreg  = (LONG_PTR)(lpcreg + 2);
         lpcreg = (WORD_PTR)*(LONG_PTR)lpcreg;

	 /* check for potential heap overflow */
         if (lereg < hreg + 100) {
            ereg = lereg;
            /* garbage_collection("calld"); */ /* GC buggy! */
	    if (lereg < hreg + 100)     /* still too full */
	       quit("Heap overflow\n");
         }

         NEXT_INSTRUCTION;

      case jump:
         PAD;
         lpcreg = (WORD_PTR)*(LONG_PTR)lpcreg;
         NEXT_INSTRUCTION;

      case jumpz:
         op3 = OPREGC;
         if (NUMVAL(op3) == 0)
            lpcreg = *(WORD_PTR *)lpcreg;
         else
            lpcreg += 2;
         NEXT_INSTRUCTION;

      case jumpnz:
         op3 = OPREGC;
         if (NUMVAL(op3) != 0)
            lpcreg = *(WORD_PTR *)lpcreg;
         else
            lpcreg += 2;
         NEXT_INSTRUCTION;

      case jumplt:
         op3 = OPREGC;
         if (NUMVAL(op3) < 0)
            lpcreg = *(WORD_PTR *)lpcreg;
         else
            lpcreg += 2;
         NEXT_INSTRUCTION;

      case jumple:
         op3 = OPREGC;
         if (NUMVAL(op3) <= 0)
            lpcreg = *(WORD_PTR *)lpcreg;
         else
            lpcreg += 2;
         NEXT_INSTRUCTION;

      case jumpgt:
         op3 = OPREGC;
         if (NUMVAL(op3) > 0)
            lpcreg = *(WORD_PTR *)lpcreg;
         else
            lpcreg += 2;
         NEXT_INSTRUCTION;

      case jumpge:
         op3 = OPREGC;
         if (NUMVAL(op3) >= 0)
            lpcreg = *(WORD_PTR *)lpcreg;
         else
            lpcreg += 2;
         NEXT_INSTRUCTION;

      case fail:
         PAD;
         FAIL1;
         NEXT_INSTRUCTION;

      case noop:
         NPARSE_B;
         lpcreg += op1;
         NEXT_INSTRUCTION;

      case halt:
         PAD;
         printf("\nHalt. Program terminated normally\n");
         exit(0);
         NEXT_INSTRUCTION;

      case builtin:
         NPARSE_B;
         pcreg = lpcreg;
         ereg  = lereg;
         Builtin(op1);
         lpcreg = pcreg;
         NEXT_INSTRUCTION;

      case endfile:
         NPARSE_PW;
         NEXT_INSTRUCTION;

      case getival:               /* RW */
         NPARSE_RWv;
         goto nunify;

      case jumptbreg:             /* RW */
         OPREGC = (LONG)breg | NUM_TAG;
         lpcreg = *(WORD_PTR *)lpcreg;
         NEXT_INSTRUCTION;

      case unexec:
         /* PWW, builds str on heap, and executes 2nd arg
          * simulates exec(op2(op1(A1,A2,..,An)) for intercepting calls
          */
         NPARSE_PW;
         op3 = (LONG)hreg;        /* save addr of new structure rec */
         NEW_HEAP_NODE(op2);      /* set str psc ptr */
         for (i = 1; i <= GET_ARITY((PSC_REC_PTR)op2); i++) {
            op1 = rreg[i];
unebld:     if (ISVAR(op1)) {
               NDEREF(op1, unebld);
               FOLLOW(op1) = (LONG)hreg;
               PUSHTRAIL(op1);
               NEW_HEAP_FREE;
            } else NEW_HEAP_NODE(op1);
         }
         rreg[1] = op3 | CS_TAG;  /* ptr to new structure on heap */
         OP2WORD;
         psc_ptr = (PSC_REC_PTR)op2;
         goto call_sub;

      case unexeci:
         /* PWW, builds str on heap with last arg a var,
          * and executes 2nd arg; for interpreting;
          * simulates exec(op2(op1(A1,A2,..,An-1,B),B)
          */
         NPARSE_PW;
         op3 = (LONG)hreg;        /* save addr of new structure rec */
         NEW_HEAP_NODE(op2);      /* set str psc ptr */
         for (i = 1; i < GET_ARITY((PSC_REC_PTR)op2); i++) {
            op1 = rreg[i];
unibld:     if (ISVAR(op1)) {
               NDEREF(op1, unibld);
               FOLLOW(op1) = (LONG)hreg;
               PUSHTRAIL(op1);
               NEW_HEAP_FREE;
            } else NEW_HEAP_NODE(op1);
         }
         rreg[1] = op3 | CS_TAG;  /* ptr to new structure on heap */
         rreg[2] = (LONG)hreg;
         NEW_HEAP_FREE;           /* add last field to rec */
         OP2WORD;
         psc_ptr = (PSC_REC_PTR)op2;
         goto call_sub;

      case executev:
         NPARSE_PW;
exun:    switch (TAG(op2)) {
            case FREE: NDEREF(op2,exun);
            case NUM : printf("Error: Illegal call\n");
                       FAIL1;
                       NEXT_INSTRUCTION;
            case CS  : psc_ptr = GET_STR_PSC(op2);
                       goto call_sub;
            case LIST: psc_ptr = list_psc;
                       goto call_sub;
         }

      default:
         printf("\nIllegal opcode hex %x at %x\n", *--lpcreg, lpcreg);
         exit(1);

   }  /* end switch */

/******************************************************************************/

/*------------------------------------------------------------------*/
nunify:                                     /* op1 and op2 are unknown type */

   switch (TAG(op1)) {
      case FREE:                            /* op1 is derefed free node */
         NDEREF(op1, nunify);
nunify1: switch (TAG(op2)) {
            case FREE:                      /* op1 is free, op2 is free */
               NDEREF(op2, nunify1);
               if (op1 != op2) {
                  if (op1 < op2) {
                     if (op1 < (LONG)hreg) {  /* op1 not in loc stack */
                        FOLLOW(op2) = op1;
                        PUSHTRAIL(op2);
                     } else {                 /* op1 points to op2 */
                        FOLLOW(op1) = op2;
                        PUSHTRAIL(op1);
                     }
                  } else {                    /* op1 > op2 */
                     if (op2 < (LONG)hreg) {
                        FOLLOW(op1) = op2;
                        PUSHTRAIL(op1);
                     } else {
                        FOLLOW(op2) = op1;
                        PUSHTRAIL(op2);
                     }
                  }
               }
               NEXT_INSTRUCTION;
            case CS  :                      /* op1 is free, op2 is con/str */
            case LIST:                      /* op1 is free, op2 is list    */
            case NUM :                      /* op1 is free, op2 is num     */
	       FOLLOW(op1) = op2;
               PUSHTRAIL(op1);
               NEXT_INSTRUCTION;
         }  /* op1 = FREE - switch on op2 */

      case CS:                              /* op1 is con/str */
nunify2: switch (TAG(op2)) {
            case FREE:                      /* op1 is con/str, op2 is free */
	       NDEREF(op2, nunify2);
               FOLLOW(op2) = op1;
               PUSHTRAIL(op2);
               NEXT_INSTRUCTION;
            case CS:                        /* op1 is con/str, op2 is con/str */
	       if (op1 != op2) {
                  UNTAG(op1);
                  UNTAG(op2);
                  if (FOLLOW(op1) != FOLLOW(op2))
                     FAIL1;
                  else {
                     arity = GET_STR_ARITY(op1);
                     for (i = 1; i <= arity; i++)
                        if (!unify(*((LONG_PTR)op1+i), *((LONG_PTR)op2+i))) {
                           FAIL1;
                           NEXT_INSTRUCTION;
                        }
                  }
               }
               NEXT_INSTRUCTION;            /* OK by default */
            case LIST:                      /* op1 is con/str, op2 is list */
            case NUM :                      /* op1 is con/str, op2 is num  */
	       FAIL1;
               NEXT_INSTRUCTION;
         }  /* op1 = CS - switch on op2 */

      case LIST:                            /* op1 is list */
nunify3: switch (TAG(op2)) {
            case FREE:                      /* op1 is list, op2 is free */
	       NDEREF(op2, nunify3);
               FOLLOW(op2) = op1;
               PUSHTRAIL(op2);
               NEXT_INSTRUCTION;
            case CS :                       /* op1 is list, op2 is con/str */
            case NUM:                       /* op1 is list, op2 is num     */
	       FAIL1;
               NEXT_INSTRUCTION;
            case LIST:                      /* op1 is list, op2 is list */
	       if (op1 != op2) {
                  UNTAG(op1);
                  UNTAG(op2);
                  if (!unify(*(LONG_PTR)op1, *(LONG_PTR)op2) ||
                      !unify(*((LONG_PTR)op1 + 1), *((LONG_PTR)op2 + 1)))
                     FAIL1;
               }
               NEXT_INSTRUCTION;            /* OK by default */
         }  /* op1 = LIST - switch on op2 */

      case NUM:                             /* op1 is num */
nunify4: switch (TAG(op2)) {
            case FREE:                      /* op1 is num, op2 is free */
               NDEREF(op2, nunify4);
               FOLLOW(op2) = op1;
               PUSHTRAIL(op2);
               NEXT_INSTRUCTION;
            case NUM:                       /* op1 is num, op2 is num */
	       if (op1 == op2)
                  NEXT_INSTRUCTION;
               else if ((ISFLOAT(op1) || ISFLOAT(op2)) &&
	                 NUMVAL(op2) == NUMVAL(op1))
                  NEXT_INSTRUCTION;	/* fails by default */
            case CS  :                      /* op1 is num, op2 is con/str */
            case LIST:                      /* op1 is num, op2 is list    */
	       FAIL1;
               NEXT_INSTRUCTION;
         }  /* op1 = NUM - switch on op2 */

   }  /* end of nunify */

/*------------------------------------------------------------------*/
nunify_with_con:                            /* op1 is unknown,           */
					    /* op2 is con/str (UNTAGGED) */
   switch (TAG(op1)) {
      case FREE:                            /* op1 is free, op2 is con/str */
	 NDEREF(op1, nunify_with_con);
         FOLLOW(op1) = op2 | CS_TAG;
         PUSHTRAIL(op1);
         NEXT_INSTRUCTION;
      case CS:                              /* op1 is con/str, op2 is con/str */
         UNTAG(op1);
         if (op1 != op2)
            if (FOLLOW(op2) != FOLLOW(op1))
               FAIL1;
         NEXT_INSTRUCTION;                  /* OK by default */
      case LIST:                            /* op1 is list, op2 is con/str */
      case NUM :                            /* op1 is num, op2 is con/str  */
         FAIL1;
         NEXT_INSTRUCTION;
   }  /* end nunify_with_con */

/*------------------------------------------------------------------*/
nunify_with_int:                            /* op1 is unknown,           */
					    /* op2 is integer (UNTAGGED) */
   switch (TAG(op1)) {
      case FREE:
	 NDEREF(op1, nunify_with_int);
         FOLLOW(op1) = MAKEINT(op2);
         PUSHTRAIL(op1);
         NEXT_INSTRUCTION;
      case NUM:
	 if (ISINTEGER(op1) && INTVAL(op1) == op2)
            NEXT_INSTRUCTION;
         else if (ISFLOAT(op1) && floatval(op1) == op2)
            NEXT_INSTRUCTION;
         /* fails by default */
      case CS  :
      case LIST:
         FAIL1;
         NEXT_INSTRUCTION;
   }  /* end nunify_with_int */

/*------------------------------------------------------------------*/
nunify_with_float:                      /* op1 is unknown,                   */
                                        /* op2 is tagged float in WAM format */
   switch (TAG(op1)) {
      case FREE:
         NDEREF(op1, nunify_with_float);
         FOLLOW(op1) = op2;
         PUSHTRAIL(op1);
         NEXT_INSTRUCTION;
      case NUM:
         if (NUMVAL(op1) == floatval(op2))
            NEXT_INSTRUCTION;
         /* fails by default */
      case CS  :
      case LIST:
         FAIL1;
         NEXT_INSTRUCTION;
   }  /* end nunify_with_float */

/*------------------------------------------------------------------*/
nunify_with_nil:                         /* op1 is unknown,         */
                                         /* op2 is nil_sym (TAGGED) */
   switch (TAG(op1)) {
      case FREE:
	 NDEREF(op1, nunify_with_nil);
         FOLLOW(op1) = nil_sym;
         PUSHTRAIL(op1);
         NEXT_INSTRUCTION;
      case CS:
	 if (op1 == nil_sym)
            NEXT_INSTRUCTION;
         /* fails by default */
      case LIST:
      case NUM :
	 FAIL1;
         NEXT_INSTRUCTION;
   }  /* end nunify_with_nil */

/*------------------------------------------------------------------*/
nunify_with_str:                         /* op1 is unknown, */
                                         /* op2 is psc_ptr  */
   switch (TAG(op1)) {
      case FREE:
	 NDEREF(op1, nunify_with_str);
         FOLLOW(op1) = (LONG)hreg | CS_TAG;
         PUSHTRAIL(op1);
         NEW_HEAP_NODE(op2);
         flag = WRITEFLAG;
         NEXT_INSTRUCTION;
      case CS:
	 UNTAG(op1);
         if (FOLLOW(op1) == op2) {
            flag = READFLAG;
            sreg = (LONG_PTR)op1 + 1;
            NEXT_INSTRUCTION;
         }
         /* fails by default */
      case LIST:
      case NUM :
	 FAIL1;
         NEXT_INSTRUCTION;
   }  /* end nunify_with_str */

/*------------------------------------------------------------------*/
nunify_with_list_sym:                    /* op1 is unknown, */
                                         /* op2 is list     */
   switch (TAG(op1)) {
      case FREE:
	 NDEREF(op1, nunify_with_list_sym);
         FOLLOW(op1) = (LONG)hreg | LIST_TAG;
         PUSHTRAIL(op1);
         flag = WRITEFLAG;
         NEXT_INSTRUCTION;
      case CS :
      case NUM:
	 FAIL1;
         NEXT_INSTRUCTION;
      case LIST:
	 sreg = (LONG_PTR)UNTAGGED(op1);
         flag = READFLAG;
         NEXT_INSTRUCTION;
   }  /* end nunify_with_list_sym */

/*------------------------------------------------------------------*/
nbldval:

   if (ISVAR(op1)) {
      NDEREF(op1, nbldval);
      FOLLOW(op1) = (LONG)hreg;
      PUSHTRAIL(op1);
      NEW_HEAP_FREE;
   } else NEW_HEAP_NODE(op1);
   NEXT_INSTRUCTION;    /* end of nbldval */

/*------------------------------------------------------------------*/
subtryme:

   tempbreg = (breg < lereg) ? breg : lereg - ENV_SIZE(cpreg);

   /* check for heap overflow */
   if (tempbreg - op1 - 6 < hreg) {
      ereg = lereg;
      /* garbage_collection("subtryme"); */ /* GC buggy! */
      if (tempbreg - op1 - 6 < hreg) {   /* still too full */
	 quit("Heap overflow\n");
/*
	 if (!overflow_f) {
            overflow_f = 1;
            lpcreg = (WORD_PTR)set_intercode(2);
            NEXT_INSTRUCTION;
         }
*/
      }
   }

   for (i = 1; i <= op1; i++)
      *tempbreg-- = rreg[i];

   *tempbreg-- = (LONG)lereg;
   *tempbreg-- = (LONG)cpreg;
   *tempbreg-- = (LONG)trreg;
   *tempbreg-- = (LONG)hreg;
   *tempbreg-- = (LONG)breg;
   *tempbreg-- = op2;               /* next process' entry pt. */
   breg  = tempbreg;                /* next free space was b+6 */
   hbreg = hreg;

   NEXT_INSTRUCTION;    /* end of subtryme */

/*------------------------------------------------------------------*/
rerestore:

   tempbreg = breg + 3;
   hreg  = (LONG_PTR)*tempbreg;
   oldtr = (LONG_PTR)*(++tempbreg);
   while (trreg != oldtr) {
      top = (LONG_PTR)*(++trreg);
      *(LONG_PTR *)top = top;
   }
   cpreg  = (LONG_PTR)*(++tempbreg);
   lereg = (LONG_PTR)*(++tempbreg);
   for (i = op1; i >= 1; i--)
      rreg[i] = *(++tempbreg);
   NEXT_INSTRUCTION;    /* end of rerestore */

/*------------------------------------------------------------------*/
trrestore:

   tempbreg = breg + 3;
   hreg  = (LONG_PTR)*(tempbreg);
   oldtr = (LONG_PTR)*(++tempbreg);
   while (trreg != oldtr) {
      top = (LONG_PTR)*(++trreg);
      *(LONG_PTR *)top = top;
   }
   cpreg  = (LONG_PTR)*(++tempbreg);
   lereg = (LONG_PTR)*(++tempbreg);
   for (i = op1; i >= 1; i--)
      rreg[i] = *(++tempbreg);

   breg  = (LONG_PTR)*(breg + 2);
   hbreg = (LONG_PTR)*(breg + 3);
   NEXT_INSTRUCTION;    /* end of trrestore */

/*------------------------------------------------------------------*/
call_sub:                         /* (psc) */

   /* check for potential heap overflow */
   if (lereg < hreg + 100) {
      ereg = lereg;
      /* garbage_collection("call_sub"); */ /* GC buggy! */
      if (lereg < hreg + 100)     /* still too full */
	 quit("Heap overflow\n");
   }

   if (interrupt_code > 0) {      /* combine with call_intercept check! */
      build_call(psc_ptr);
      lpcreg = (WORD_PTR)set_intercode(1);
      interrupt_code = 0;
      arm_intercept();
      psc_ptr = interrupt_psc;
   } else if (IS_PRED(psc_ptr) || IS_DYNA(psc_ptr)) {
      lpcreg = (WORD_PTR)GET_EP(psc_ptr);
   } else if (IS_BUFF(psc_ptr)) {
      lpcreg = (WORD_PTR)GET_NAME(psc_ptr) + 1;
   } else {
      build_call(psc_ptr);
      lpcreg = (WORD_PTR)set_intercode(0);
      psc_ptr = interrupt_psc;
   }

   if (call_intercept) {
      if (hitrace) {
         printf("call/exec: ");
         writepname(stdout, GET_NAME(psc_ptr), GET_LENGTH(psc_ptr));
         printf("/%d(", GET_ARITY(psc_ptr));
         for (i = 1; i <= GET_ARITY(psc_ptr); i++) {
            printterm(rreg[i], CAR);
            if (i < GET_ARITY(psc_ptr))
               printf(" ");
         }
         printf(")\n");
      }
      if (trace_sta) {
         if (hreg  > mheaptop ) mheaptop  = hreg;
         if (ereg  < mlocaltop) mlocaltop = ereg;
         if (breg  < mlocaltop) mlocaltop = breg;
         if (trreg < mtrailtop) mtrailtop = trreg;
      }
   }

   NEXT_INSTRUCTION;    /* end of call_sub */

}  /* end of main */
