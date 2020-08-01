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
/* compare.c */

#include "builtin.h"

extern float floatval();

b_COMPARE()
{
   /* reg1, reg2: two terms to be compared; reg3: free var to set the
    * result of the comparison: reg1 < reg2: int<0,  reg1 = reg2: 0, >0 o/w.
    * reg3 must be free and a LOCAL new variable
    * LIST is the largest term of the all four kinds
    */

   if (!unify(reg[3], MAKEINT(compare(reg[1], reg[2]))))
      {FAIL0;}
}

compare(val1, val2)
LONG val1, val2;
{
   register LONG_PTR top;
   WORD              a, b;
   LONG              c;
   PSC_REC_PTR       psc_ptr1, psc_ptr2;
   float             fpt_val;

   DEREF(val2);
cd:
   switch (TAG(val1)) {
      case FREE: NDEREF(val1, cd);
                 if (ISVAR(val2))
 		    return (val1 - val2);
                 else return -1;
      case NUM : if (ISVAR(val2))
 		    return 1;
                 else if (ISINTEGER(val1) && ISINTEGER(val2))
                    return (INTVAL(val1) - INTVAL(val2));
                 else if (ISFLOAT(val1) && ISFLOAT(val2)) {
                    fpt_val = floatval(val1) - floatval(val2);
                    if (fpt_val > 0)
 		       return 1;
                    else if (fpt_val == 0)
 		       return 0;
                    else return -1;
                 } else return -1;
      case CS  : if (ISVAR(val2) || ISINTEGER(val2))
 		    return 1;
                 else if (ISLIST(val2))
 		    return -1;
                 else {
                    psc_ptr1 = GET_STR_PSC(val1);
                    psc_ptr2 = GET_STR_PSC(val2);
                    a = GET_ARITY(psc_ptr1);
                    b = GET_ARITY(psc_ptr2);
                    if (a != b)
 		       return (a - b);
                    c = comalpha(psc_ptr1, psc_ptr2);
                    if (c || a == 0)
 		       return c;
                    UNTAG(val1);
                    UNTAG(val2);
                    for (b = 1; b <= a; b++) {
                       c = compare(FOLLOW(((LONG_PTR)val1)+b),
                                   FOLLOW(((LONG_PTR)val2)+b));
                       if (c)
 		          break;
                    }
                    return c;
                 }
                 /* break; */
      case LIST: if (!ISLIST(val2))
 		    return 1;
                 else {
                    UNTAG(val1);
                    UNTAG(val2);
                    c = compare(FOLLOW(val1), FOLLOW(val2));
                    if (c)
                       return c;
                    else
                       return compare(FOLLOW(((LONG_PTR)val1)+1),
                                      FOLLOW(((LONG_PTR)val2)+1));
                }
                /* break; */
   }  /* switch */
}  /* compare */

comalpha(psc_ptr1, psc_ptr2)
PSC_REC_PTR psc_ptr1, psc_ptr2;
{
   CHAR name1[256], name2[256];

   if (psc_ptr1 == psc_ptr2)
      return 0;
   namestring(psc_ptr1, name1);
   namestring(psc_ptr2, name2);
   return strcmp(name1, name2);
}
