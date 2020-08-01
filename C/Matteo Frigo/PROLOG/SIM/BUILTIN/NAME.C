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
/* name.c */

#include "builtin.h"

LONG ptr;
static BYTE perm = PERM;

extern LONG_PTR insert();

b_NAME0()  /* X, L: reg2 (L) is made to be the string of the name of reg1 (X) */
{
   PSC_REC_PTR       psc_ptr;
   CHAR_PTR name;
   LONG     i, len, nlist;
   register LONG     op1;
   register LONG_PTR top;
   LONG_PTR stack_top;

   op1 = reg[1];  DEREF(op1);
   if (!(ISCONSTR(op1) && GET_STR_ARITY(op1) == 0)) {
      printf("Error: name0, illegal argument\n");
      FAIL0;
      return;
   }
   psc_ptr = GET_STR_PSC(op1);
   name    = GET_NAME(psc_ptr);
   len     = GET_LENGTH(psc_ptr);
   /* check for potential heap overflow */
   /*  (this will guarantee space for lists of up to 50 elements */
   stack_top = (breg < ereg) ? breg : ereg - ENV_SIZE(cpreg);
   if (stack_top < hreg + 100) {
      /* garbage_collection("b_NAME0"); */
      if (stack_top < hreg + 100)    /* still too full */
	 quit("Heap overflow\n");
   }
   if (len == 0) {
     if (!unify(reg[2], nil_sym))
       {FAIL0;}
   }
   else {
       nlist = (LONG)hreg | LIST_TAG;
       for (i = 0; i < len; i++) {
	    FOLLOW(hreg++) = MAKEINT(*name++);
	    top = hreg++;
	    FOLLOW(top) = (LONG)hreg | LIST_TAG;
       }
       FOLLOW(top) = nil_sym;
       if (!unify(reg[2], nlist))
           {FAIL0;}
   }
}  /* b_NAME0 */


b_BLDATOM()  /* X, L: reg2 (L) is known not free, reg1 (X) is known free. */
{            /* make X to be an atom with name string L       */

   WORD     a, n;
   CHAR     name[256];
   CHAR_PTR s;
   register LONG     op2, op3;
   register LONG_PTR top;

   s = name;
   n = 0;
   op2 = reg[2];

   do {
      DEREF(op2);
      if (op2 == nil_sym)
	 break;
      if (ISLIST(op2)) {
         UNTAG(op2);
         op3 = FOLLOW(op2);  DEREF(op3);
         if (!ISINTEGER(op3)) {
            printf("Error: bldatom, non integer\n");
            FAIL0;
            return;
         }
         a = INTVAL(op3);
         if (a < 0 || a > 255) {
            printf("Error: bldatom, bad integer\n");
            FAIL0;
            return;
         }
         *s++ = a;
         n++;
         op2 = FOLLOW((op2+4));
      } else {
         printf("Error: bldstr, non list\n");
         FAIL0;
         return;
      }
   } while (1);
   ptr = (LONG)insert(name, n, 0, &perm) | CS_TAG;

   if (!unify(reg[1], ptr))
      {FAIL0;}

}  /* b_BLDATOM */
