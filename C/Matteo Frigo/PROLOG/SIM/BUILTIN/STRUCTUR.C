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
/* structure.c */

#include "builtin.h"

extern LONG_PTR insert();
static BYTE perm = PERM;

b_ARG0()  /* (I, T, X) */
{
   /* reg1 is bound to a number; reg2 is bound to a structure;
    * reg3 may be free or bound; no checking for above is done;
    * reg1 out of range will cause failure
    */

   register LONG     op1, op2;
   register LONG_PTR top;

   op1 = reg[1];  DEREF(op1);
   if (!ISINTEGER(op1)) {
      printf("arg0: Index must be an integer.\n");
      FAIL0;
      return;
   }
   op1 = INTVAL(op1);

   op2 = reg[2];  DEREF(op2);
   if (ISCONSTR(op2) && op1 <= GET_STR_ARITY(op2) && op1 > 0)
      if (unify(*(((LONG_PTR)(UNTAG(op2))) + op1), reg[3]))
         return;
   if (ISLIST(op2) && op1 <= 2)
      if (unify(*(((LONG_PTR)(UNTAG(op2))) + op1 - 1), reg[3]))
         return;
   FAIL0;
}

b_ARITY()  /* (T, N) */
{
   /* reg1 is bound to a structure or constant; reg2 will be unified with
    * the arity of reg1
    */

   register LONG     op1, op2;
   register LONG_PTR top;

   op1 = reg[1];  DEREF(op1);
   if (ISCONSTR(op1))
      op2 = MAKEINT(GET_ARITY(GET_STR_PSC(op1)));
   else if (ISLIST(op1))
      op2 = MAKEINT(2);
   else if (ISNUM(op1))
      op2 = MAKEINT(0);
   else {
      printf("arity: Term must be bound.\n");
      FAIL0;
      return;
   }
   if (!unify(reg[2], op2))
      {FAIL0;}
}

b_FUNCTOR0()  /* (T, F) */
{
   /* reg1 is bound to a structure (no checking), reg2 will be unified
    * with the functor of reg1
    */

   register LONG     op1, op2;
   register LONG_PTR top;
   PSC_REC_PTR       psc_ptr;

   op1 = reg[1];  DEREF(op1);
   if (ISLIST(op1))
      op2 = (LONG)insert(".", 1, 0, &perm);
   else {
      psc_ptr = GET_STR_PSC(op1);
      if (GET_ARITY(psc_ptr) != 0)
         op2 = (LONG)insert(GET_NAME(psc_ptr), GET_LENGTH(psc_ptr), 0, &perm);
      else op2 = op1;
   }
   op2 |= CS_TAG;
   if (!unify(op2, reg[2]))
      {FAIL0;}
}

b_BLDSTR()  /* (F, N, T) */
{
   /* reg1 is bound to an atom, reg2 is bound to an integer (> 0)
    * reg3 is free, and will be set to the most general structure
    * with functor reg1; incomplete error checking
    */

   register LONG     op1, op2;
   register LONG_PTR top;
   PSC_REC_PTR       psc_ptr;
   LONG              i, a;
   LONG_PTR          stack_top;

   op1 = reg[1];  DEREF(op1);
   if (!ISCONSTR(op1)) {
      printf("bldstr: first arg must be constant\n");
      FAIL0;
      return;
   }
   op2 = reg[2];  DEREF(op2);
   if (!ISINTEGER(op2)) {
      printf("bldstr: second arg must be integer\n");
      FAIL0;
      return;
   }
   a = INTVAL(op2);
   if (a < 0 || a > 127) {
      printf("bldstr: arity must be between 0 and 127\n");
      FAIL0;
      return;
   }
   op2 = reg[3];  DEREF(op2);
   psc_ptr = GET_STR_PSC(op1);
   if (GET_ARITY(psc_ptr) > 0) {
      printf("bldstr: first arg must be constant\n");
      FAIL0;
      return;
   }
   /* check for heap overflow */
   stack_top = (breg < ereg) ? breg : ereg - ENV_SIZE(cpreg);
   if (stack_top < hreg + a + 1) {
      /* garbage_collection("b_BLDSTR"); */
      if (stack_top < hreg + a + 1)    /* still too full */
	 quit("Heap overflow\n");
   }
   if (a == 2 && GET_NAME(psc_ptr)[0] == '.' && GET_LENGTH(psc_ptr) == 1)
      FOLLOW(op2) = (LONG)hreg | LIST_TAG;
   else if (a == 0)
      FOLLOW(op2) = op1;
   else {
      op1 = (LONG)insert(GET_NAME(psc_ptr), GET_LENGTH(psc_ptr), a, &perm);
      op1 = FOLLOW(op1);        /* returns addr of addr of psc */
      FOLLOW(op2) = (LONG)hreg | CS_TAG;
      *hreg++ = op1;
   }
   PUSHTRAIL(op2);
   for (i = 0; i < a; hreg++, i++)
      MAKE_FREE(LONG, *hreg);
}

b_MKSTR()
{	    /*  (F, T, A) : F is a pointer to the PSC table entry of a function
		symbol f/n.  b_MKSTR creates T, a most general instance of
		a term with principal functor f/n on the heap, and sets the
		variable register 2 points to,  to it; the variable that
		register 3 points to is set to the arity n.

	        At this point, this is used only for decompilation.   */

    int i, arity;
    PSC_REC_PTR psc_p;
    register LONG op;
    register LONG_PTR top;

    op = reg[1]; DEREF(op);
    if (!ISCONSTR(op)) {
	printf("mkstr: first arg must be a function symbol!\n");
	FAIL0; return; }
    psc_p = (PSC_REC_PTR)(UNTAGGED(op));
    arity = GET_ARITY(psc_p);
    op = reg[2]; DEREF(op);
    if (!ISFREE(op)) {
	printf("mkstr: second argument must be a variable!\n");
	FAIL0; return; }
    if ((arity==2) && (GET_NAME(psc_p)[0]=='.') && (GET_LENGTH(psc_p)==1)) 
	FOLLOW(op) = (LONG)hreg | LIST_TAG;
    else {
	FOLLOW(op) = (LONG)hreg | CS_TAG;
	*hreg++ = (LONG)psc_p;
	if (arity > 0)
	    for (i = 0; i < arity; hreg++, i++) MAKE_FREE(LONG, *hreg);
	};
    PUSHTRAIL(op);
    op = reg[3]; DEREF(op);
    FOLLOW(op) = MAKEINT(arity);
    PUSHTRAIL(op);
}
