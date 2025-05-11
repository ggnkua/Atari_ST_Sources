/* Subroutines used by or related to instruction recognition.
   Copyright (C) 1987, 1988 Free Software Foundation, Inc.

This file is part of GNU CC.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU CC General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
GNU CC, but only under the conditions described in the
GNU CC General Public License.   A copy of this license is
supposed to have been given to you along with GNU CC so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies.  */


#include "config.h"
#include "rtl.h"
#include <stdio.h>
#include "insn-config.h"
#include "recog.h"
#include "regs.h"
#include "hard-reg-set.h"

static int inequality_comparisons_p ();

/* Nonzero means allow operands to be volatile.
   This is 1 if you use recog_memoized, 0 if you don't.
   init_recog and recog_memoized are responsible for setting it.
   This way of handling it is not really clean and will be change later.  */

int volatile_ok;

rtx recog_addr_dummy;

/* On return from `constrain_operands', indicate which alternative
   was satisfied.  */

int which_alternative;

/* Initialize data used by the function `recog'.
   This must be called once in the compilation of a function
   before any insn recognition may be done in the function.  */

void
init_recog ()
{
  volatile_ok = 0;
  recog_addr_dummy = gen_rtx (MEM, VOIDmode, 0);
}

/* Try recognizing the instruction INSN,
   and return the code number that results.
   Remeber the code so that repeated calls do not
   need to spend the time for actual rerecognition.

   This function is the normal interface to instruction recognition.
   The automatically-generated function `recog' is normally called
   through this one.  (The only exception is in combine.c.)  */

int
recog_memoized (insn)
     rtx insn;
{
  volatile_ok = 1;
  if (INSN_CODE (insn) < 0)
    INSN_CODE (insn) = recog (PATTERN (insn), insn);
  return INSN_CODE (insn);
}

/* Return 1 if the insn following INSN does not contain
   any ordered tests applied to the condition codes.
   EQ and NE tests do not count.  */

int
next_insn_tests_no_inequality (insn)
     rtx insn;
{
  register rtx next = NEXT_INSN (insn);

  return ((GET_CODE (next) == JUMP_INSN
	   || GET_CODE (next) == INSN
	   || GET_CODE (next) == CALL_INSN)
	  && ! inequality_comparisons_p (PATTERN (next)));
}

static int
inequality_comparisons_p (x)
     rtx x;
{
  register char *fmt;
  register int len, i;
  register enum rtx_code code = GET_CODE (x);

  switch (code)
    {
    case REG:
    case PC:
    case CC0:
    case CONST_INT:
    case CONST_DOUBLE:
    case CONST:
    case LABEL_REF:
    case SYMBOL_REF:
      return 0;

    case LT:
    case LTU:
    case GT:
    case GTU:
    case LE:
    case LEU:
    case GE:
    case GEU:
      return (XEXP (x, 0) == cc0_rtx || XEXP (x, 1) == cc0_rtx);
    }

  len = GET_RTX_LENGTH (code);
  fmt = GET_RTX_FORMAT (code);

  for (i = 0; i < len; i++)
    {
      if (fmt[i] == 'e')
	{
	  if (inequality_comparisons_p (XEXP (x, i)))
	    return 1;
	}
      else if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = XVECLEN (x, i) - 1; j >= 0; j--)
	    if (inequality_comparisons_p (XVECEXP (x, i, j)))
	      return 1;
	}
    }
	    
  return 0;
}

/* Return 1 if OP is a valid general operand for machine mode MODE.
   This is either a register reference, a memory reference,
   or a constant.  In the case of a memory reference, the address
   is checked for general validity for the target machine.

   Register and memory references must have mode MODE in order to be valid,
   but some constants have no machine mode and are valid for any mode.

   If MODE is VOIDmode, OP is checked for validity for whatever mode
   it has.

   The main use of this function is as a predicate in match_operand
   expressions in the machine description.  */

int
general_operand (op, mode)
     register rtx op;
     enum machine_mode mode;
{
  register enum rtx_code code = GET_CODE (op);
  int mode_altering_drug = 0;

  if (mode == VOIDmode)
    mode = GET_MODE (op);

  if (CONSTANT_P (op))
    return ((GET_MODE (op) == VOIDmode || GET_MODE (op) == mode)
	    && LEGITIMATE_CONSTANT_P (op));

  /* Except for certain constants with VOIDmode, already checked for,
     OP's mode must match MODE if MODE specifies a mode.  */

  if (GET_MODE (op) != mode)
    return 0;

  while (code == SUBREG)
    {
      op = SUBREG_REG (op);
      code = GET_CODE (op);
      mode_altering_drug = 1;
    }
  if (code == REG)
    return 1;
  if (code == CONST_DOUBLE)
    return LEGITIMATE_CONSTANT_P (op);
  if (code == MEM)
    {
      register rtx y = XEXP (op, 0);
      if (! volatile_ok && op->volatil)
	return 0;
      GO_IF_LEGITIMATE_ADDRESS (mode, y, win);
    }
  return 0;

 win:
  if (mode_altering_drug)
    return ! mode_dependent_address_p (XEXP (op, 0));
  return 1;
}

/* Return 1 if OP is a valid memory address for a memory reference
   of mode MODE.

   The main use of this function is as a predicate in match_operand
   expressions in the machine description.  */

int
address_operand (op, mode)
     register rtx op;
     enum machine_mode mode;
{
  return memory_address_p (mode, op);
}

/* Return 1 if OP is a register reference of mode MODE.
   If MODE is VOIDmode, accept a register in any mode.

   The main use of this function is as a predicate in match_operand
   expressions in the machine description.  */

int
register_operand (op, mode)
     register rtx op;
     enum machine_mode mode;
{
  if (GET_MODE (op) != mode && mode != VOIDmode)
    return 0;

  while (GET_CODE (op) == SUBREG)
    op = SUBREG_REG (op);

  return GET_CODE (op) == REG;
}

/* Return 1 if OP is a valid immediate operand for mode MODE.

   The main use of this function is as a predicate in match_operand
   expressions in the machine description.  */

int
immediate_operand (op, mode)
     register rtx op;
     enum machine_mode mode;
{
  return ((CONSTANT_P (op)
	   || (GET_CODE (op) == CONST_DOUBLE
	       && (GET_MODE (op) == mode || mode == VOIDmode)))
	  && LEGITIMATE_CONSTANT_P (op));
}

/* Return 1 if OP is a general operand that is not an immediate operand.  */

int
nonimmediate_operand (op, mode)
     register rtx op;
     enum machine_mode mode;
{
  return (general_operand (op, mode)
	  && ! CONSTANT_P (op) && GET_CODE (op) != CONST_DOUBLE);
}

/* Return 1 if OP is a register reference or immediate value of mode MODE.  */

int
nonmemory_operand (op, mode)
     register rtx op;
     enum machine_mode mode;
{
  if (CONSTANT_P (op)
      || (GET_CODE (op) == CONST_DOUBLE
	  && (GET_MODE (op) == mode || mode == VOIDmode)))
    return LEGITIMATE_CONSTANT_P (op);

  if (GET_MODE (op) != mode && mode != VOIDmode)
    return 0;

  while (GET_CODE (op) == SUBREG)
    op = SUBREG_REG (op);

  return GET_CODE (op) == REG;
}

/* Return 1 if OP is a valid operand that stands for pushing a
   value of mode MODE onto the stack.

   The main use of this function is as a predicate in match_operand
   expressions in the machine description.  */

int
push_operand (op, mode)
     rtx op;
     enum machine_mode mode;
{
  if (GET_CODE (op) != MEM)
    return 0;

  if (GET_MODE (op) != mode)
    return 0;

  op = XEXP (op, 0);

#ifdef STACK_GROWS_DOWNWARD
  if (GET_CODE (op) != PRE_DEC)
    return 0;
#else
  if (GET_CODE (op) != PRE_INC)
    return 0;
#endif
  return REGNO (XEXP (op, 0)) == STACK_POINTER_REGNUM;
}

/* Return 1 if ADDR is a valid memory address for mode MODE.  */

int
memory_address_p (mode, addr)
     enum machine_mode mode;
     register rtx addr;
{
  GO_IF_LEGITIMATE_ADDRESS (mode, addr, win);
  return 0;

 win:
  return 1;
}

/* Return 1 if OP is a valid memory reference with mode MODE,
   including a valid address.

   The main use of this function is as a predicate in match_operand
   expressions in the machine description.  */

int
memory_operand (op, mode)
     register rtx op;
     enum machine_mode mode;
{
  enum rtx_code code = GET_CODE (op);
  int mode_altering_drug = 0;

  while (code == SUBREG)
    {
      op = SUBREG_REG (op);
      code = GET_CODE (op);
      mode_altering_drug = 1;
    }

  return (GET_CODE (op) == MEM && general_operand (op, mode)
	  && ! (mode_altering_drug
		&& mode_dependent_address_p (XEXP (op, 0))));
}

/* If BODY is an insn body that uses ASM_OPERANDS,
   return the number of operands (both input and output) in the insn.
   Otherwise return 0.  */

int
asm_noperands (body)
     rtx body;
{
  int noperands;

  if (GET_CODE (body) == SET && GET_CODE (SET_SRC (body)) == ASM_OPERANDS)
    /* Single output operand: BODY is (set OUTPUT (asm_operands ...)).  */
    return XVECLEN (SET_SRC (body), 3) + 1;
  else if (GET_CODE (body) == PARALLEL
	   && GET_CODE (XVECEXP (body, 0, 0)) == SET
	   && GET_CODE (SET_SRC (XVECEXP (body, 0, 0))) == ASM_OPERANDS)
    /* Multiple outputs: BODY is
       (parallel [(set OUTPUT0 (asm_operands ...)) ...]).  */
    return XVECLEN (SET_SRC (XVECEXP (body, 0, 0)), 3) + XVECLEN (body, 0);
  else
    return 0;
}

/* Assuming BODY is an insn body that uses ASM_OPERANDS,
   copy its operands (both input and output) into the vector OPERANDS,
   the locations of the operands within the insn into the vector OPERAND_LOCS,
   and the constraints for the operands into CONSTRAINTS.
   Write the modes of the operands into MODES.
   Return the assembler-template.

   If MODES, OPERAND_LOCS, CONSTRAINTS or OPERANDS is 0,
   we don't store that info.  */

char *
decode_asm_operands (body, operands, operand_locs, constraints, modes)
     rtx body;
     rtx *operands;
     rtx **operand_locs;
     char **constraints;
     enum machine_mode *modes;
{
  register int i;
  int noperands;
  char *template;

  if (GET_CODE (body) == SET && GET_CODE (SET_SRC (body)) == ASM_OPERANDS)
    {
      rtx asmop = SET_SRC (body);
      /* Single output operand: BODY is (set OUTPUT (asm_operands ....)).  */

      noperands = XVECLEN (asmop, 3) + 1;

      /* The input operands are found in the 1st element vector.  */
      /* Constraints for inputs are in the 2nd element vector.  */
      for (i = 1; i < noperands; i++)
	{
	  if (operand_locs)
	    operand_locs[i] = &XVECEXP (asmop, 3, i - 1);
	  if (operands)
	    operands[i] = XVECEXP (asmop, 3, i - 1);
	  if (constraints)
	    constraints[i] = XSTR (XVECEXP (asmop, 4, i - 1), 0);
	  if (modes)
	    modes[i] = GET_MODE (XVECEXP (asmop, 4, i - 1));
	}

      /* The output is in the SET.
	 Its constraint is in the ASM_OPERANDS itself.  */
      if (operands)
	operands[0] = SET_DEST (body);
      if (operand_locs)
	operand_locs[0] = &SET_DEST (body);
      if (constraints)
	constraints[0] = XSTR (asmop, 1);
      if (modes)
	modes[0] = GET_MODE (SET_DEST (body));
      template = XSTR (asmop, 0);
    }
  else
    {
      rtx asmop = SET_SRC (XVECEXP (body, 0, 0));
      int nout = XVECLEN (body, 0);
      int nin = XVECLEN (asmop, 3);

      noperands = XVECLEN (asmop, 3) + XVECLEN (body, 0);

      /* The input operands are found in the 1st element vector.  */
      /* Constraints for inputs are in the 2nd element vector.  */
      for (i = 0; i < nin; i++)
	{
	  if (operand_locs)
	    operand_locs[i + nout] = &XVECEXP (asmop, 3, i);
	  if (operands)
	    operands[i + nout] = XVECEXP (asmop, 3, i);
	  if (constraints)
	    constraints[i + nout] = XSTR (XVECEXP (asmop, 4, i), 0);
	  if (modes)
	    modes[i + nout] = GET_MODE (XVECEXP (asmop, 4, i));
	}
      /* The outputs are in the SETs.
	 Their constraints are in the ASM_OPERANDS itself.  */
      for (i = 0; i < nout; i++)
	{
	  if (operands)
	    operands[i] = SET_DEST (XVECEXP (body, 0, i));
	  if (operand_locs)
	    operand_locs[i] = &SET_DEST (XVECEXP (body, 0, i));
	  if (constraints)
	    constraints[i] = XSTR (SET_SRC (XVECEXP (body, 0, i)), 1);
	  if (modes)
	    modes[i] = GET_MODE (SET_DEST (XVECEXP (body, 0, i)));
	}
      template = XSTR (asmop, 0);
    }

  return template;
}

extern rtx plus_constant ();
extern rtx copy_rtx ();

/* Given an rtx *P, if it is a sum containing an integer constant term,
   return the location (type rtx *) of the pointer to that constant term.
   Otherwise, return a null pointer.  */

static rtx *
find_constant_term_loc (p)
     rtx *p;
{
  register rtx *tem;
  register enum rtx_code code = GET_CODE (*p);

  /* If *P IS such a constant term, P is its location.  */

  if (code == CONST_INT || code == SYMBOL_REF || code == LABEL_REF
      || code == CONST)
    return p;

  /* Otherwise, if not a sum, it has no constant term.  */

  if (GET_CODE (*p) != PLUS)
    return 0;

  /* If one of the summands is constant, return its location.  */

  if (XEXP (*p, 0) && CONSTANT_P (XEXP (*p, 0))
      && XEXP (*p, 1) && CONSTANT_P (XEXP (*p, 1)))
    return p;

  /* Otherwise, check each summand for containing a constant term.  */

  if (XEXP (*p, 0) != 0)
    {
      tem = find_constant_term_loc (&XEXP (*p, 0));
      if (tem != 0)
	return tem;
    }

  if (XEXP (*p, 1) != 0)
    {
      tem = find_constant_term_loc (&XEXP (*p, 1));
      if (tem != 0)
	return tem;
    }

  return 0;
}

/* Return 1 if OP is a memory reference
   whose address contains no side effects
   and remains valid after the addition
   of a positive integer less than the
   size of the object being referenced.

   We assume that the original address is valid and do not check it.  */

int
offsetable_memref_p (op)
     rtx op;
{
  return ((GET_CODE (op) == MEM)
	  && offsetable_address_p (GET_MODE (op), XEXP (op, 0)));
}

/* Return 1 if Y is a memory address which contains no side effects
   and would remain valid for mode MODE
   after the addition of a positive integer less than the
   size of that mode.

   We assume that the original address is valid and do not check it.  */

int
offsetable_address_p (mode, y)
     enum machine_mode mode;
     register rtx y;
{
  register enum rtx_code ycode = GET_CODE (y);
  register rtx z;
  rtx y1 = y;
  rtx *y2;

  if (CONSTANT_ADDRESS_P (y))
    return 1;
      
  /* If the expression contains a constant term,
     see if it remains valid when max possible offset is added.  */

  if ((ycode == PLUS) && (y2 = find_constant_term_loc (&y1)))
    {
      int old = INTVAL (y1 = *y2);
      int good;
      INTVAL (y1) += GET_MODE_SIZE (mode) - 1;
      good = memory_address_p (mode, y);
      /* In any case, restore old contents of memory.  */
      INTVAL (y1) = old;
      return good;
    }

  if (ycode == PRE_DEC || ycode == PRE_INC
      || ycode == POST_DEC || ycode == POST_INC)
    return 0;

  /* The offset added here is chosen as the maximum offset that
     any instruction could need to add when operating on something
     of the specified mode.  We assume that if Y and Y+c are
     valid addresses then so is Y+d for all 0<d<c.  */

  z = plus_constant (y, GET_MODE_SIZE (mode) - 1);

  return memory_address_p (mode, z);
}

/* Return 1 if ADDR is an address-expression whose effect depends
   on the mode of the memory reference it is used in.

   Autoincrement addressing is a typical example of mode-dependence
   because the amount of the increment depends on the mode.  */

int
mode_dependent_address_p (addr)
     rtx addr;
{
  GO_IF_MODE_DEPENDENT_ADDRESS (addr, win);
  return 0;
 win:
  return 1;
}

/* Return 1 if OP is a general operand
   other than a memory ref with a mode dependent address.  */

int
mode_independent_operand (mode, op)
     rtx op;
{
  rtx addr;

  if (! general_operand (mode, op))
    return 0;

  if (GET_CODE (op) != MEM)
    return 1;

  addr = XEXP (op, 0);
  GO_IF_MODE_DEPENDENT_ADDRESS (addr, lose);
  return 1;
 lose:
  return 0;
}

/* Given an operand OP that is a valid memory reference
   which satisfies offsetable_memref_p,
   return a new memory reference whose address has been adjusted by OFFSET.
   OFFSET should be positive and less than the size of the object referenced.
*/

rtx
adj_offsetable_operand (op, offset)
     rtx op;
     int offset;
{
  register enum rtx_code code = GET_CODE (op);

  if (code == MEM) 
    {
      register rtx y = XEXP (op, 0);

      if (CONSTANT_ADDRESS_P (y))
	return gen_rtx (MEM, GET_MODE (op), plus_constant (y, offset));

      if (GET_CODE (y) == PLUS)
	{
	  rtx z = y;
	  register rtx *const_loc;

	  op = copy_rtx (op);
	  z = XEXP (op, 0);
	  const_loc = find_constant_term_loc (&z);
	  if (const_loc)
	    {
	      *const_loc = plus_constant (*const_loc, offset);
	      return op;
	    }
	}

      return gen_rtx (MEM, GET_MODE (op), plus_constant (y, offset));
    }
  abort ();
}

#ifdef REGISTER_CONSTRAINTS

/* Check the operands of an insn (found in recog_operands)
   against the insn's operand constraints (found via INSN_CODE_NUM)
   and return 1 if they are valid.

   WHICH_ALTERNATIVE is set to a number which indicates which
   alternative of constraints was matched: 0 for the first alternative,
   1 for the next, etc.

   In addition, when two operands are match
   and it happens that the output operand is (reg) while the
   input operand is --(reg) or ++(reg) (a pre-inc or pre-dec),
   make the output operand look like the input.
   This is because the output operand is the one the template will print.

   This is used in final, just before printing the assembler code.  */

struct funny_match
{
  int this, other;
};

int
constrain_operands (insn_code_num)
     int insn_code_num;
{
  char *constraints[MAX_RECOG_OPERANDS];
  register int c;
  int noperands = insn_n_operands[insn_code_num];

  struct funny_match funny_match[MAX_RECOG_OPERANDS];
  int funny_match_index;

  if (noperands == 0)
    return 1;

  for (c = 0; c < noperands; c++)
    constraints[c] = insn_operand_constraint[insn_code_num][c];

  which_alternative = 0;

  while (*constraints[0])
    {
      register int opno;
      int lose = 0;
      funny_match_index = 0;

      for (opno = 0; opno < noperands; opno++)
	{
	  register rtx op = recog_operand[opno];
	  register char *p = constraints[opno];
	  int win = 0;
	  int val;

	  /* `alter_subreg' should already have converted any SUBREG
	     that appears at the level of an operand.  */
	  while (GET_CODE (op) == SUBREG)
	    abort ();

	  while (*p && (c = *p++) != ',')
	    switch (c)
	      {
	      case '=':
	      case '+':
	      case '?':
	      case '#':
	      case '!':
	      case '*':
	      case '%':
		break;

	      case '0':
	      case '1':
	      case '2':
	      case '3':
	      case '4':
		/* This operand must be the same as a previous one.  */
		/* This kind of constraint is used for instructions such
		   as add when they take only two operands.  */
		/* Note that the lower-numbered operand is passed first.  */
		val = operands_match_p (recog_operand[c - '0'],
					recog_operand[opno]);
		if (val != 0)
		  win = 1;
		/* If output is *x and input is *--x,
		   arrange later to change the output to *--x as well,
		   since the output op is the one that will be printed.  */
		if (val == 2)
		  {
		    funny_match[funny_match_index].this = opno;
		    funny_match[funny_match_index++].other = c - '0';
		  }
		break;

	      case 'p':
		/* p is used for address_operands, and everything
		   that must be checked was checked already.  */
		win = 1;
		break;

		/* No need to check general_operand again;
		   it was done in insn-recog.c.  */
	      case 'g':
		/* Anything goes unless it is a REG and really has a hard reg
		   but the hard reg is not in the class GENERAL_REGS.  */
		if (GENERAL_REGS == ALL_REGS
		    || GET_CODE (op) != REG
		    || (REGNO (op) >= FIRST_PSEUDO_REGISTER
			&& reg_renumber[REGNO (op)] < 0)
		    || reg_renumbered_fits_class_p (op, GENERAL_REGS, 0,
						    GET_MODE (op)))
		  win = 1;
		break;

	      case 'r':
		if (GET_CODE (op) == REG
		    && (GENERAL_REGS == ALL_REGS
			|| reg_renumbered_fits_class_p (op, GENERAL_REGS,
							0, GET_MODE (op))))
		  win = 1;
		break;

	      case 'm':
		if (GET_CODE (op) == MEM)
		  win = 1;
		break;

	      case '<':
		if (GET_CODE (op) == MEM
		    && (GET_CODE (XEXP (op, 0)) == PRE_DEC
			|| GET_CODE (XEXP (op, 0)) == POST_DEC))
		  win = 1;
		break;

	      case '>':
		if (GET_CODE (op) == MEM
		    && (GET_CODE (XEXP (op, 0)) == PRE_INC
			|| GET_CODE (XEXP (op, 0)) == POST_INC))
		  win = 1;
		break;

	      case 'F':
		if (GET_CODE (op) == CONST_DOUBLE)
		  win = 1;
		break;

	      case 'G':
	      case 'H':
		if (GET_CODE (op) == CONST_DOUBLE
		    && CONST_DOUBLE_OK_FOR_LETTER_P (op, c))
		  win = 1;
		break;

	      case 's':
		if (GET_CODE (op) == CONST_INT)
		  break;
	      case 'i':
		if (CONSTANT_P (op))
		  win = 1;
		break;

	      case 'n':
		if (GET_CODE (op) == CONST_INT)
		  win = 1;
		break;

	      case 'I':
	      case 'J':
	      case 'K':
	      case 'L':
	      case 'M':
		if (GET_CODE (op) == CONST_INT
		    && CONST_OK_FOR_LETTER_P (INTVAL (op), c))
		  win = 1;
		break;

	      case 'o':
		if (offsetable_memref_p (op))
		  win = 1;
		break;

	      default:
		if (GET_CODE (op) == REG
		    && reg_renumbered_fits_class_p (op,
						    REG_CLASS_FROM_LETTER (c),
						    0, GET_MODE (op)))
		  win = 1;
	      }

	  constraints[opno] = p;
	  /* If this operand did not win somehow,
	     this alternative loses.  */
	  if (! win)
	    lose = 1;
	}
      /* This alternative won; the operands are ok.
	 Change whichever operands this alternative says to change.  */
      if (! lose)
	{
	  while (--funny_match_index >= 0)
	    {
	      recog_operand[funny_match[funny_match_index].other]
		= recog_operand[funny_match[funny_match_index].this];
	    }
	  return 1;
	}

      which_alternative++;
    }
  return 0;
}

/* Return 1 iff OPERAND (assumed to be a REG rtx)
   is a hard reg in class CLASS when its regno is offsetted by OFFSET
   and changed to mode MODE,
   or is a pseudo reg allocated into such a hard reg.
   If REG occupies multiple hard regs, all of them must by in CLASS.  */

int
reg_renumbered_fits_class_p (operand, class, offset, mode)
     rtx operand;
     register enum reg_class class;
     int offset;
     enum machine_mode mode;
{
  if (GET_CODE (operand) == REG)
    {
      register int regno = REGNO (operand);
      if (reg_renumber[regno] >= 0)
	regno = reg_renumber[regno];
      if (regno < FIRST_PSEUDO_REGISTER
	  && TEST_HARD_REG_BIT (reg_class_contents[(int) class],
				regno + offset))
	{
	  register int sr;
	  regno += offset;
	  for (sr = HARD_REGNO_NREGS (regno, mode) - 1;
	       sr > 0; sr--)
	    if (! TEST_HARD_REG_BIT (reg_class_contents[(int) class],
				     regno + sr))
	      break;
	  return sr == 0;
	}
    }
  return 0;
}

#endif /* REGISTER_CONSTRAINTS */
