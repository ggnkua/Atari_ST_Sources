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
/* arith.c */

/*  some builtins for arithmetic functions  */

#include "builtin.h"

extern double floatval();
extern LONG   makefloat();

b_FLOATC()    /* F, M, E, S */
{
   /* reg1 (F) is either a variable or a number (in WAM format);
    * reg2 (M) is either a number (in WAM format) or a variable;
    * reg3 (E) is either an integer or a variable.  The intended
    * interpretation is that M and E represent the mantissa and exponent,
    * respectively, of the floating point number F.  Either F, or 
    * both M and E, are assumed to be bound (the selector reg4 (S)
    * tells us which case it is).  No checking for this is done here.
    */

   register LONG     op1, op2, op3, op4;
   register LONG_PTR top;
   double            fval; 
   int               exp0;

   op1 = reg[1];  DEREF(op1);
   op2 = reg[2];  DEREF(op2);
   op3 = reg[3];  DEREF(op3);
   op4 = reg[4];  DEREF(op4);

   switch (INTVAL(op4)) {
      case 0: fval = frexp(NUMVAL(op1), &exp0);
              FOLLOW(op2) = makefloat(fval);
	      PUSHTRAIL(op2);
              FOLLOW(op3) = MAKEINT(exp0);
	      PUSHTRAIL(op3);
              break;
      case 1: fval = ldexp((double)NUMVAL(op2), (int)INTVAL(op3));
              FOLLOW(op1) = makefloat(fval);
	      PUSHTRAIL(op1);
              break;
      case 3: fval = ldexp((double)NUMVAL(op2), (int)INTVAL(op3));
              if (floatval(op1) != fval) {FAIL0;}
              break;
   }
}

b_ARITH()
{
   register LONG     op1, op2, op3;
   register LONG_PTR top;
   double            y;

   op1 = reg[1]; 
   op2 = reg[2];
   op3 = reg[3];  DEREF(op3);

   switch (INTVAL(op3)) {
      case 0: DEREF(op2);
              if (!unify(op1, makefloat(log((double)NUMVAL(op2)))))
                 {FAIL0;}
              break;
      case 1: DEREF(op1);
              if (!unify(makefloat(exp((double)NUMVAL(op1))), op2))
                 {FAIL0;}
              break;
      case 2: DEREF(op2);
              if (!unify(op1, makefloat(sqrt((double)NUMVAL(op2)))))
                 {FAIL0;}
              break;
      case 3: DEREF(op1);
              y = (double)NUMVAL(op1);
              if (!unify(makefloat(y * y), op2)) 
                 {FAIL0;}
              break;
      case 4: DEREF(op1);
              if (!unify(makefloat(sin((double)NUMVAL(op1))), op2))
                 {FAIL0;}
              break;
      case 5: DEREF(op2);
              if (!unify(op1, makefloat(asin((double)NUMVAL(op2)))))
                 {FAIL0;}
              break;
   }
}
