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
/* sub_inst.c */

#include <signal.h>
#include "sim.h"
#include "aux.h"

/* #define DEBUG */


/******************************************************************************/

/* set interrupt code in reg 2 and return ep of interrupt handler */

LONG_PTR set_intercode(intcode)
WORD intcode;
{

#ifdef DEBUG
   printf("set_intercode: intcode = %d  interrupt_psc = %08x\n", 
          intcode, interrupt_psc);
#endif

   if (!IS_PRED(interrupt_psc))
      quit("Interrupt handler not defined\n");

   reg[2] = MAKEINT(intcode);
   return (LONG_PTR)GET_EP(interrupt_psc);
}

/******************************************************************************/

intercept_proc()
{
        signal(SIGINT,intercept_proc);
   if (interrupt_code == 0) {
      interrupt_code = 1;
   }
   else exit(2);
}

/******************************************************************************/

arm_intercept()
{
        signal(SIGINT,intercept_proc);
}

/******************************************************************************/

callv_sub()   /* arg from register 1 */
{
   LONG              term;
   register LONG_PTR top;
   WORD              i;
   PSC_REC_PTR       psc_ptr;
   CHAR              s1[256];

   term = reg[1];
cvlab: 
   switch (TAG(term)) {
      case FREE: NDEREF(term, cvlab);
      case NUM : printf("illegal call\n");
                 FAIL0;
                 return;
      case LIST: psc_ptr = list_psc;
                 term -= 4;
                 break;
      case CS  : psc_ptr = GET_STR_PSC(term);
                 break;
   }

   if (interrupt_code > 0) {
      interrupt_code = 0;
      pcreg = (WORD_PTR)set_intercode(1);
      return;
   }

   /* call code */

   if (IS_PRED(psc_ptr) || IS_DYNA(psc_ptr))
      pcreg = (WORD_PTR)GET_EP(psc_ptr);
   else {
      pcreg = (WORD_PTR)set_intercode(0);
      return;
   }
   UNTAG(term);
   for (i = 1; i <= GET_ARITY(psc_ptr); ++i)
      reg[i] = FOLLOW((LONG_PTR)term + i);
   if (hitrace == 1) {
      printf("callv: ");
      writepname(stdout, GET_NAME(psc_ptr), GET_LENGTH(psc_ptr));
      printf("        (");
      for (i = 1; i <= GET_ARITY(psc_ptr); i++) {
         printf(" ");
         printterm(reg[i], CAR);
      }
      printf(")\n");
   }

}  /* callv_sub */

/******************************************************************************/

/* builds the current call onto the heap and points reg 1 to it, 
   and puts the interrupt number in reg 2 
*/

build_call(psc_ptr)
PSC_REC_PTR psc_ptr;
{
   register LONG     callstr, arg;
   register WORD     i;
   register LONG_PTR top;

#ifdef DEBUG
   printf("build call : psc = %08x\n", psc_ptr);
#endif

   callstr = (LONG)hreg;               /* save addr of new structure rec */
   NEW_HEAP_NODE((LONG)psc_ptr);       /* set str psc ptr */
   for (i = 1; i <= GET_ARITY(psc_ptr); i++) {
      arg = reg[i];

#ifdef DEBUG
      printf("build call : arg = %08x  %08x\n", arg , *(LONG_PTR)arg);
#endif

bldc: 
      if (ISVAR(arg)) {
         NDEREF(arg, bldc);
         FOLLOW(arg) = (LONG)hreg;
         PUSHTRAIL(arg);
         NEW_HEAP_FREE;
      } else NEW_HEAP_NODE(arg);
   }
   reg[1] = callstr | CS_TAG;    /* ptr to new structure on heap */

}  /* build_call */
