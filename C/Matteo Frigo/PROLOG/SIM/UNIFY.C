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
/* unify.c */

#include "sim.h"
#include "aux.h"

extern double floatval();

unify(op1, op2)
LONG op1, op2;
{
   register LONG_PTR top;
   WORD     arity, i;

nun: 
   switch (TAG(op1)) {
      case FREE:                              /* op1 = free var */
         NDEREF(op1, nun);
nun1:    switch (TAG(op2)) {
            case FREE:                        /* op1 = free, op2 = free */
               NDEREF(op2, nun1);
               if (op1 != op2) {
                  if (op1 < op2) {            /* op1 < op2 */
                     if (op1 < (LONG)hreg) {  /* op1 not in loc stack */
                        FOLLOW(op2) = op1;
                        PUSHTRAIL(op2);
		     } else {                 /* op1 points to op2 */
                        FOLLOW(op1) = op2;
                        PUSHTRAIL(op1);
		     }
                  } else {                    /* op1 > op2 */
                     if (op2 < (LONG)hreg) {  /* op2 not in loc stack */
                        FOLLOW(op1) = op2;
                        PUSHTRAIL(op1);
		     } else {                 /* op2 points to op1 */
                        FOLLOW(op2) = op1;
                        PUSHTRAIL(op2);
		     }
                  }
               }
               return 1;
            case CS  :                        /* op1 = free, op2 = con/str */
            case LIST:                        /* op1 = free, op2 = list    */
            case NUM :                        /* op1 = free, op2 = num     */
               FOLLOW(op1) = op2;
               PUSHTRAIL(op1);
               return 1;
         }

      case CS:                                /* op1 = con/str */
nun2:    switch (TAG(op2)) {
            case FREE:                        /* op1 = con/str, op2 = free */
               NDEREF(op2, nun2);
               FOLLOW(op2) = op1;
               PUSHTRAIL(op2);
               return 1;
            case CS:                          /* op1 = con/str, op2 = con/str */
               if (op1 != op2) {              /* a != b */
                  UNTAG(op1);
                  UNTAG(op2);
                  if (FOLLOW(op1) != FOLLOW(op2)) /* 0(a) != 0(b) */
                     return 0;
                  else {
		     arity = GET_STR_ARITY(op1);
                     for (i = 1; i <= arity; i++) 
                        if (!unify(*((LONG_PTR)op1 + i), *((LONG_PTR)op2 + i)))
                           return 0;
                  }
               }
               return 1;
            case LIST:                        /* op1 = con/str, op2 = list */
            case NUM :                        /* op1 = con/str, op2 = num  */
               return 0;
         }

      case LIST:                              /* op1 = list */
nun3:    switch (TAG(op2)) {
            case FREE:                        /* op1 = list, op2 = free */
               NDEREF(op2, nun3);
               FOLLOW(op2) = op1;
               PUSHTRAIL(op2);
               return 1;
            case CS :                         /* op1 = list, op2 = con/str */
            case NUM:                         /* op1 = list, op2 = num     */
               return 0;
            case LIST:                        /* op1 = list, op2 = list */
               if (op1 != op2) {
                  UNTAG(op1);
                  UNTAG(op2);
                  if (!unify(*(LONG_PTR)op1, *(LONG_PTR)op2) ||
                      !unify(*(((LONG_PTR)op1)+1), *(((LONG_PTR)op2)+1)))
                     return 0;
               }
               return 1;
         }

      case NUM:                               /* op1 = num */
nun4:    switch (TAG(op2)) {
            case FREE:                        /* op1 = num, op2 = free */
               NDEREF(op2, nun4);
               FOLLOW(op2) = op1;
               PUSHTRAIL(op2);
               return 1;
            case NUM:                         /* op1 = num, op2 = num */
               if (op1 == op2)                /* op1 = op2 */
		  return 1;
               else if ((ISFLOAT(op1) || ISFLOAT(op2)) &&
		        NUMVAL(op2) == NUMVAL(op1))
                  return 1;
            case CS  :                        /* op1 = num, op2 = con/str */
            case LIST:                        /* op1 = num, op2 = list    */
               return 0;
         }
   }  /* end of switch on op1 */
}  /* end of unify */
