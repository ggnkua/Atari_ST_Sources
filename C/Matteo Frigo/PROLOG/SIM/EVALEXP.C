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
#include "sim.h"
#include "aux.h"

extern double floatval();
extern LONG   makefloat();

/***********************************************************************/
static eval_error(functor, arity)
CHAR_PTR functor;
WORD     arity;
{
   printf("Error: unknown functor %s/%d in arithmetic expression\n",
          functor, arity);
}

/***********************************************************************/
eval(op, val)
LONG     op;
LONG_PTR val;
{
   register LONG_PTR top;
   PSC_REC_PTR       psc_ptr;
   CHAR_PTR          functor;
   WORD              arity, floatp;
   LONG              length, op1, op2;
   double            result;

   switch (TAG(op)) {
      case FREE:
         printf("Error: unbound variable in arithmetic expression\n");
         FAIL0;
         return -1;

      case CS:
         floatp = 0;
         psc_ptr = GET_STR_PSC(op);
         functor = GET_NAME(psc_ptr);
         arity   = GET_ARITY(psc_ptr);
         length  = GET_LENGTH(psc_ptr);
         if (length == 1) {
            switch (*functor) {
               case '+':
                  if (arity == 1) {
		     op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
                     return eval(op1, val);
                  } else if (arity == 2) {
		     op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
                     floatp = eval(op1, &op1);
                     op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
                     floatp = floatp | eval(op2, &op2);
                     if (floatp >= 0)
                        *val = MAKENUM(NUMVAL(op1) + NUMVAL(op2));
                     return floatp;
                  } else {
		     eval_error(functor, arity);
                     FAIL0;
                     return -1;
                  }
               case '-':
		  if (arity == 1) {
                     op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
                     floatp = eval(op1, &op1);
                     if (floatp >= 0) {
                        *val = MAKENUM(-(NUMVAL(op1)));
                        return floatp;
                     }
                  } else if (arity == 2) {
		     op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
                     floatp = eval(op1, &op1);
                     op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
                     floatp = floatp | eval(op2, &op2);
                     if (floatp >= 0)
                        *val = MAKENUM(NUMVAL(op1) - NUMVAL(op2));
                     return floatp;
                  } else {
		     eval_error(functor, arity);
                     FAIL0;
                     return -1;
                  }
               case '*':
                  if (arity == 2) {
                     op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
                     floatp = eval(op1, &op1);
                     op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
                     floatp = floatp | eval(op2, &op2);
                     if (floatp >= 0)
                        *val = MAKENUM(NUMVAL(op1) * NUMVAL(op2));
                     return floatp;
                  } else {
                     eval_error(functor, arity);
                     FAIL0;
                     return -1;
                  }
               case '/':
                  if (arity == 2) {
                     op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
                     floatp = eval(op1, &op1);
                     op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
                     floatp = floatp | eval(op2, &op2);
                     if (NUMVAL(op2) == 0) {
                        printf(
			  "div: division by zero! ... failing execution ...\n");
                        return -1;
                     }
                     if (floatp >= 0) {
                        result = NUMVAL(op1) / NUMVAL(op2);
                        *val = makefloat((double)result);
                        return 1;
                     }
                  } else {
                     eval_error(functor, arity);
                     FAIL0;
                     return -1;
                  }
              case '\\':
                  if (arity == 1) {
                     op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
                     floatp = eval(op1, &op1);
                     if (floatp == 0) {
                        *val = MAKEINT(~(INTVAL(op1)));
                        return floatp;
                     } else {
                        printf("neg: integer required\n");
                        return -1;
                     }
                  } else {
                     eval_error(functor, arity);
                     FAIL0;
                     return -1;
                  }
            }  /* end of switch on (*functor) */
	 }  /* end of if (length == 1) */

         else if (arity == 2) {
            if (!strcmp(functor, "//")) {
               op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
               floatp = eval(op1, &op1);
               op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
               floatp = floatp | eval(op2, &op2);
               if (floatp >= 0)
                  *val = MAKEINT(((NUMVAL(op1) / NUMVAL(op2))));
               return 0;
            }
            else if (!strcmp(functor, "mod")) {
               op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
               floatp = eval(op1, &op1);
               op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
               floatp = floatp | eval(op2, &op2);
               if (floatp == 0) {
                  *val = MAKEINT(INTVAL(op1) % INTVAL(op2));
                  return 0;
               } else {
                  printf("mod: integer required\n");
                  return -1;
               }
            }
            else if (!strcmp(functor, "/\\")) {
               op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
               floatp = eval(op1, &op1);
               op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
               floatp = floatp | eval(op2, &op2);
               if (floatp == 0) {
                  *val = MAKEINT(INTVAL(op1) & INTVAL(op2));
                  return 0;
               } else {
                  printf("and: integer required\n");
                  FAIL0;
                  return -1;
               }
            }
            else if (!strcmp(functor, "\\/")) {
               op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
               floatp = eval(op1, &op1);
               op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
               floatp = floatp | eval(op2, &op2);
               if (floatp == 0) {
                  *val = MAKEINT(INTVAL(op1) | INTVAL(op2));
                  return 0;
               } else {
                  printf("or: integer required\n");
                  FAIL0;
                  return -1;
               }
            }
            else if (!strcmp(functor, ">>")) {
               op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
               floatp = eval(op1, &op1);
               op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
               floatp = floatp | eval(op2, &op2);
               if (floatp == 0) {
                   *val = MAKEINT(INTVAL(op1) >> INTVAL(op2));
                   return 0;
               } else {
                  printf("rshift: integer required\n");
                  FAIL0;
                  return -1;
               }
            }
            else if (!strcmp(functor, "<<")) {
               op1 = *(((LONG_PTR)(UNTAG(op))) + 1);  DEREF(op1);
               floatp = eval(op1, &op1);
               op2 = *(((LONG_PTR)(UNTAG(op))) + 2);  DEREF(op2);
               floatp = floatp | eval(op2, &op2);
               if (floatp == 0) {
                  *val = MAKEINT(INTVAL(op1) << INTVAL(op2));
                  return 0;
               } else {
                  printf("lshift: integer required\n");
                  FAIL0;
                  return -1;
               }
            }
            else {
               eval_error(functor, arity);
               FAIL0;
               return -1;
            }
         }
         else {
            eval_error(functor, arity);
            FAIL0;
            return -1;
         }  /* end of if (arity == 2) */
      /* end of CS case */

      case NUM:
         *val = op;
         return ISFLOAT(op);

      case LIST:
         UNTAG(op);
	 if (ISNUM(*(LONG_PTR)op) && *(LONG_PTR)(op+4) == nil_sym) {
	   *val = op;     /* convert [N] to N, N is a number */
	   return ISFLOAT(*(LONG_PTR)op);
	 }
	 else {
	   FAIL0;
           return -1;
	}
   }
}
