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
/* meta.c */

#include "builtin.h"

extern double floatval();
extern LONG   makefloat();

b_VAR()
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (ISNONVAR(op))
      {FAIL0;}
}

b_NONVAR()
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (ISVAR(op))
      {FAIL0;}
}

b_ATOM()
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!ISATOM(op))
      {FAIL0;}
}

b_ATOMIC()
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!(ISNUM(op) || ISATOM(op)))
      {FAIL0;}
}

b_INTEGER()
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!ISINTEGER(op))
      {FAIL0;}
}

b_REAL()
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!ISFLOAT(op))
      {FAIL0;}
}

b_STRUCTURE()
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!(ISLIST(op) || (ISCONSTR(op) && GET_STR_ARITY(op) != 0)))
      {FAIL0;}
}

b_TERMREP()    /* reg1 is term (var);  reg2 is integer that is its rep */
{
   register LONG     op;
   register LONG_PTR top;

   op = reg[1];  DEREF(op);
   if (!unify(MAKEINT(op), reg[2]))
      {FAIL0;}
}

b_DBREF()
{
    register LONG op;
    register LONG_PTR top;
    PSC_REC_PTR psc_ptr;

    op = reg[1]; DEREF(op);
    if (TAG(op) == CS_TAG) {
	psc_ptr = GET_STR_PSC(op);
	if (GET_ETYPE(psc_ptr) != T_BUFF) {FAIL0;}
    }
    else {FAIL0;}
}    

b_FLOOR0()    /* F, I, N */
{
/* reg3 is bound to a number which gives the direction of conversion:
 * if reg3 = 0 then reg1 is bound to a number and reg2 is a variable;
 * while if reg3 = 1 then reg1 is a variable and reg2 is bound to a number.
 * No checking for the above is done.
 */
    register LONG     op1, op2, op3;
    register LONG_PTR top;

    op1 = reg[1];  DEREF(op1);
    op2 = reg[2];  DEREF(op2);
    op3 = reg[3];  DEREF(op3);
    if (INTVAL(op3) == 0) {    /* reg1 = number, reg2 = free */
       FOLLOW(op2) = MAKEINT((LONG)(NUMVAL(op1)));
       PUSHTRAIL(op2);
    } else {                   /* reg1 = free, reg2 = number */
       FOLLOW(op1) = makefloat((double)(NUMVAL(op2)));
       PUSHTRAIL(op1);
    }
}
