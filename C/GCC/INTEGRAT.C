/* Procedure integration for GNU CC.
   Copyright (C) 1988 Free Software Foundation, Inc.
   Contributed by Michael Tiemann (tiemann@mcc.com)

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


#include <ctype.h>
#include <stdio.h>

#include "config.h"
#include "rtl.h"
#include "tree.h"
#include "flags.h"
#include "insn-flags.h"
#include "expr.h"

#include "obstack.h"
#define	obstack_chunk_alloc	xmalloc
#define	obstack_chunk_free	free
extern int xmalloc ();
extern void free ();

extern struct obstack permanent_obstack, maybepermanent_obstack;
extern struct obstack *rtl_obstack, *saveable_obstack, *current_obstack;

#define MIN(x,y) ((x < y) ? x : y)

extern tree pushdecl ();

/* This is the target of the inline function being expanded,
   or NULL if there is none.  */
static rtx inline_target;

/* We must take special care not to disrupt life too severely
   when performing procedure integration.  One thing that that
   involves is not creating illegitimate address which reload
   cannot fix.  Since we don't know what the frame pointer is
   not capable of (in a machine independent way), we create
   a pseudo-frame pointer which will have to do for now.  */
static rtx inline_fp_rtx;

/* Convert old frame-pointer offsets to new.  Parameters which only
   produce values (no addresses, and are never assigned), map directly
   to the pseudo-reg of the incoming value.  Parameters that are
   assigned to but do not have their address taken are given a fresh
   pseudo-register.  Parameters that have their address take are
   given a fresh stack-slot.  */
static rtx *parm_map;

/* ?? Should this be done here??  It is not right now.
   Keep track of whether a given pseudo-register is the sum
   of the frame pointer and a const_int (or zero).  */
static char *fp_addr_p;

/* For the local variables of the procdure being integrated that live
   on the frame, FRAME_POINTER_DELTA says how much to change their
   offsets by, so that they now live in the correct place on the
   frame of the function being compiled.  */
static int fp_delta;

/* Return a copy of an rtx (as needed), substituting pseudo-register,
   labels, and frame-pointer offsets as necessary.  */
static rtx copy_rtx_and_substitute ();

static void copy_parm_decls ();
static void copy_decl_tree ();

static rtx try_fold_cc0 ();

/* We do some simple constant folding optimization.  This optimization
   really exists primarily to save time inlining a function.  It
   also help users who ask for inline functions without -O.  */
static rtx fold_out_const_cc0 ();

/* Zero if the current function (whose FUNCTION_DECL is FNDECL)
   is safe and reasonable to integrate into other functions.
   Nonzero means value is a warning message with a single %s
   for the function's name.  */

char *
function_cannot_inline_p (fndecl)
     register tree fndecl;
{
  register rtx insn;
  tree last = tree_last (TYPE_ARG_TYPES (TREE_TYPE (fndecl)));
  int nargs = list_length (DECL_ARGUMENTS (fndecl));
  int max_insns = 4 * (4 + nargs + 16*TREE_INLINE (fndecl));
  register int ninsns = 0;
  register tree parms;

  /* No inlines with varargs.  `grokdeclarator' gives a warning
     message about that if `inline' is specified.  This code
     it put in to catch the volunteers.  */
  if (last && TREE_VALUE (last) != void_type_node)
    return "varargs function `%s' cannot be inline";

  /* If its not even close, don't even look.  */
  if (get_max_uid () > 2 * max_insns)
    return "function `%s' too large to be inline";

  /* Don't inline functions which have BLKmode arguments.
     Don't inline functions that take the address of
       a parameter and do not specify a function prototype.  */
  for (parms = DECL_ARGUMENTS (fndecl); parms; parms = TREE_CHAIN (parms))
    {
      if (TYPE_MODE (TREE_TYPE (parms)) == BLKmode)
	return "function `%s' with large aggregate parameter cannot be inline";
      if (last == NULL_TREE && TREE_ADDRESSABLE (parms))
	return "function `%s' without prototype uses address of parameter;\n cannot be inline";
    }

  if (get_max_uid () > max_insns)
    {
      for (ninsns = 0, insn = get_first_nonparm_insn (); insn && ninsns < max_insns;
	   insn = NEXT_INSN (insn))
	{
	  if (GET_CODE (insn) == INSN
	      || GET_CODE (insn) == JUMP_INSN
	      || GET_CODE (insn) == CALL_INSN)
	    ninsns++;
	}

      if (ninsns >= max_insns)
	return "function `%s' too large to be inline";
    }

  return 0;
}

/* Variables used within save_for_inline.  */

/* Mapping from old pesudo-register to new pseudo-registers.
   The first element of this map is reg_map[FIRST_PSEUDO_REGISTER].
   It allocated in `save_current_insns' and `expand_function_inline',
   and deallocated on exit from each of those routines.  */
static rtx *reg_map;

/* Mapping from old code-labels to new code-labels.
   The first element of this map is label_map[min_labelno].
   It allocated in `save_current_insns' and `expand_function_inline',
   and deallocated on exit from each of those routines.  */
static rtx *label_map;

/* Map pseudo reg number into the PARM_DECL for the parm living in the reg.
   Zero for a reg that isn't a parm's home.
   Only reg numbers less than max_parm_reg are mapped here.  */
static tree *parmdecl_map;

/* Keep track of first pseudo-register beyond those that are parms.  */
static int max_parm_reg;

/* On machines that perform a function return with a single
   instruction, such as the VAX, these return insns must be
   mapped into branch statements.  */
extern rtx return_label;

/* Copy an rtx for save_for_inline.  */
static rtx copy_for_inline ();

/* Make the insns and PARM_DECLs of the current function permanent
   and record other information in DECL_SAVED_INSNS to allow inlining
   of this function in subsequent calls.  */

void
save_for_inline (fndecl)
     tree fndecl;
{
  extern rtx *regno_reg_rtx;	/* in emit-rtl.c.  */
  extern current_function_args_size;

  rtx first_insn, last_insn, insn;
  rtx head, copy;
  tree parms;
  int max_labelno, min_labelno, i, len;
  int max_reg;

  /* Make and emit a return-label if we have not already done so.  */

  if (return_label == 0)
    {
      return_label = gen_label_rtx ();
      emit_label (return_label);
    }

  /* Get some bounds on the labels and registers used.  */

  max_labelno = max_label_num ();
  min_labelno = get_first_label_num ();
  max_parm_reg = max_parm_reg_num ();
  max_reg = max_reg_num ();

  /* Set up PARMDECL_MAP which maps pseudo-reg number to its PARM_DECL.

     Set TREE_VOLATILE to 0 if the parm is in a register, otherwise 1.
     Later we set TREE_READONLY to 0 if the parm is modified inside the fn.  */

  parmdecl_map = (tree *) alloca (max_parm_reg * sizeof (tree));
  bzero (parmdecl_map, max_parm_reg * sizeof (tree));

  for (parms = DECL_ARGUMENTS (fndecl); parms; parms = TREE_CHAIN (parms))
    {
      rtx p = DECL_RTL (parms);

      if (GET_CODE (p) == REG)
	{
	  parmdecl_map[REGNO (p)] = parms;
	  TREE_VOLATILE (parms) = 0;
	}
      else
	TREE_VOLATILE (parms) = 1;
      TREE_READONLY (parms) = 1;
    }

  /* The list of DECL_SAVES_INSNS, starts off with a header which
     contains the following information:

     the first insn of the function (not including the insns that copy
     parameters into registers).
     the first label used by that function,
     the last label used by that function,
     and the total number of registers used.  */

  head = gen_inline_header_rtx (NULL, NULL, min_labelno, max_labelno,
				max_parm_reg, max_reg,
				current_function_args_size);

  /* We have now allocated all that needs to be allocated permanently
     on the rtx obstack.  Set our high-water mark, so that we
     can free the rest of this when the time comes.  */

  preserve_data ();

  /* Copy the chain insns of this function.
     Install the copied chain as the insns of this function,
     for continued compilation;
     the original chain is recorded as the DECL_SAVED_INSNS
     for inlining future calls.  */

  /* If there are insns that copy parms from the stack into pseudo registers,
     those insns are not copied.  `expand_inline_function' must
     emit the correct code to handle such things.  */

  insn = get_insns ();
  if (GET_CODE (insn) != NOTE)
    abort ();
  first_insn = rtx_alloc (NOTE);
  NOTE_SOURCE_FILE (first_insn) = NOTE_SOURCE_FILE (insn);
  NOTE_LINE_NUMBER (first_insn) = NOTE_LINE_NUMBER (insn);
  INSN_UID (first_insn) = INSN_UID (insn);
  PREV_INSN (first_insn) = NULL;
  NEXT_INSN (first_insn) = NULL;
  last_insn = first_insn;

  /* Each pseudo-reg in the old insn chain must have a unique rtx in the copy.
     Make these new rtx's now, and install them in regno_reg_rtx, so they
     will be the official pseudo-reg rtx's for the rest of compilation.  */

  reg_map = (rtx *) alloca ((max_reg + 1) * sizeof (rtx));

  len = sizeof (struct rtx_def) + (GET_RTX_LENGTH (REG) - 1) * sizeof (rtunion);
  for (i = max_reg - 1; i >= FIRST_PSEUDO_REGISTER; i--)
    reg_map[i] = (rtx)obstack_copy (&maybepermanent_obstack, regno_reg_rtx[i], len);
  bcopy (reg_map + FIRST_PSEUDO_REGISTER,
	 regno_reg_rtx + FIRST_PSEUDO_REGISTER,
	 (max_reg_num () - FIRST_PSEUDO_REGISTER) * sizeof (rtx));

  /* Likewise each label rtx must have a unique rtx as its copy.  */

  label_map = (rtx *)alloca ((max_labelno - min_labelno) * sizeof (rtx));
  label_map -= min_labelno;

  for (i = min_labelno; i < max_labelno; i++)
    label_map[i] = gen_label_rtx ();

  /* Now copy the chain of insns.  */

  for (insn = NEXT_INSN (insn); insn; insn = NEXT_INSN (insn))
    {
      switch (GET_CODE (insn))
	{
	case NOTE:
	  copy = rtx_alloc (NOTE);
	  NOTE_SOURCE_FILE (copy) = NOTE_SOURCE_FILE (insn);
	  NOTE_LINE_NUMBER (copy) = NOTE_LINE_NUMBER (insn);
	  break;

	case INSN:
	case CALL_INSN:
	case JUMP_INSN:
	  copy = rtx_alloc (GET_CODE (insn));
	  PATTERN (copy) = copy_for_inline (PATTERN (insn));
	  INSN_CODE (copy) = -1;
	  LOG_LINKS (copy) = NULL;
	  REG_NOTES (copy) = copy_for_inline (REG_NOTES (insn));
	  break;

	case CODE_LABEL:
	  copy = label_map[CODE_LABEL_NUMBER (insn)];
	  break;

	case BARRIER:
	  copy = rtx_alloc (BARRIER);
	  break;

	default:
	  abort ();
	}
      INSN_UID (copy) = INSN_UID (insn);
      NEXT_INSN (last_insn) = copy;
      PREV_INSN (copy) = last_insn;
      last_insn = copy;
    }

  NEXT_INSN (last_insn) = NULL;

  NEXT_INSN (head) = get_first_nonparm_insn ();
  FIRST_PARM_INSN (head) = get_insns ();
  DECL_SAVED_INSNS (fndecl) = head;
  DECL_FRAME_SIZE (fndecl) = get_frame_size ();
  TREE_INLINE (fndecl) = 1;

  parmdecl_map = 0;
  label_map = 0;
  reg_map = 0;
  return_label = 0;

  set_new_first_and_last_insn (first_insn, last_insn);
}

/* Copy the rtx ORIG recursively, replacing pseudo-regs and labels
   according to `reg_map' and `label_map'.
   All other kinds of rtx are copied except those that can never be
   changed during compilation.  */

static rtx
copy_for_inline (orig)
     rtx orig;
{
  register rtx x = orig;
  register int i;
  register enum rtx_code code;
  register char *format_ptr;

  if (x == 0)
    return x;

  code = GET_CODE (x);

  /* These types may be freely shared.  */

  switch (code)
    {
    case QUEUED:
    case CONST_INT:
    case CONST_DOUBLE:
    case SYMBOL_REF:
    case CODE_LABEL:
    case PC:
    case CC0:
      return x;

    case MEM:
      /* A MEM is allowed to be shared if its address is constant
	 or is a constant plus one of the special registers.  */
      if (CONSTANT_ADDRESS_P (XEXP (x, 0)))
	return x;
      if (GET_CODE (XEXP (x, 0)) == PLUS
	  && GET_CODE (XEXP (XEXP (x, 0), 0)) == REG
	  && (REGNO (XEXP (XEXP (x, 0), 0)) == FRAME_POINTER_REGNUM
	      || REGNO (XEXP (XEXP (x, 0), 0)) == ARG_POINTER_REGNUM)
	  && CONSTANT_ADDRESS_P (XEXP (XEXP (x, 0), 1)))
	if (GET_CODE (XEXP (x, 0)) == REG
	    && (REGNO (XEXP (x, 0)) == FRAME_POINTER_REGNUM
		|| REGNO (XEXP (x, 0)) == ARG_POINTER_REGNUM)
	    && CONSTANT_ADDRESS_P (XEXP (x, 1)))
	return x;
      break;

    case LABEL_REF:
      {
	/* Must point to the new insn.  */
	return gen_rtx (LABEL_REF, GET_MODE (orig),
			label_map[CODE_LABEL_NUMBER (XEXP (orig, 0))]);
      }

    case REG:
      if (REGNO (x) >= FIRST_PSEUDO_REGISTER)
	return reg_map [REGNO (x)];
      else
	return x;

      /* If a parm that gets modified lives in a pseudo-reg,
	 set its TREE_VOLATILE to prevent certain optimizations.  */
    case SET:
      {
	rtx dest = SET_DEST (x);

	if (GET_CODE (dest) == REG
	    && REGNO (dest) < max_parm_reg
	    && REGNO (dest) >= FIRST_PSEUDO_REGISTER
	    && parmdecl_map[REGNO (dest)] != 0)
	  TREE_READONLY (parmdecl_map[REGNO (dest)]) = 0;
      }
      break;
    }

  /* Replace this rtx with a copy of itself.  */

  x = rtx_alloc (code);
  bcopy (orig, x, sizeof (int) * (GET_RTX_LENGTH (code) + 1));

  /* Now scan the subexpressions recursively.
     We can store any replaced subexpressions directly into X
     since we know X is not shared!  Any vectors in X
     must be copied if X was copied.  */

  format_ptr = GET_RTX_FORMAT (code);

  for (i = 0; i < GET_RTX_LENGTH (code); i++)
    {
      switch (*format_ptr++)
	{
	case 'e':
	  XEXP (x, i) = copy_for_inline (XEXP (x, i));
	  break;

	case 'E':
	  if (XVEC (x, i) != NULL)
	    {
	      register int j;

	      XVEC (x, i) = gen_rtvec_v (XVECLEN (x, i), &XVECEXP (x, i, 0));
	      for (j = 0; j < XVECLEN (x, i); j++)
		XVECEXP (x, i, j)
		  = copy_for_inline (XVECEXP (x, i, j));
	    }
	  break;
	}
    }
  return x;
}

/* Integrate the procedure defined by FNDECL.  Note that this function
   may wind up calling itself.  Since the static variables are not
   reentrant, we do not assign them until after the possibility
   or recursion is eliminated.

   If IGNORE is nonzero, do not produce a value.
   Otherwise store the value in TARGET if it is nonzero and that is convenient.

   Value is:
   (rtx)-1 if we could not substitute the function
   0 if we substituted it and it does not produce a value
   else an rtx for where the value is stored.  */

rtx
expand_inline_function (fndecl, parms, target, ignore, type, structure_value_addr)
     tree fndecl, parms;
     rtx target;
     int ignore;
     tree type;
     rtx structure_value_addr;
{
  tree formal, actual;
  rtx header = DECL_SAVED_INSNS (fndecl);
  rtx insns = FIRST_FUNCTION_INSN (header);
  rtx insn, protect;
  rtx last_insn = get_last_insn ();
  int max_regno = MAX_REGNUM (header) + 1;
  register int i;
  int keep;
  int min_labelno = FIRST_LABELNO (header);
  int max_labelno = LAST_LABELNO (header);
  int nargs;
  rtx *arg_vec;
  rtx return_label = 0;
  rtx follows_call = 0;

  if (max_regno < FIRST_PSEUDO_REGISTER)
    abort ();

  nargs = list_length (DECL_ARGUMENTS (fndecl));

  /* We expect PARMS to have the right length; don't crash if not.  */
  if (list_length (parms) != nargs)
    return (rtx)-1;

  /* Make a fresh binding contour that we can easily remove.  */
  pushlevel (0);
  expand_start_bindings (0);

  /* Get all the actual args as RTL, and store them in ARG_VEC.  */

  arg_vec = (rtx *)alloca (nargs * sizeof (rtx));

  for (formal = DECL_ARGUMENTS (fndecl),
       actual = parms,
       i = 0;
       formal;
       formal = TREE_CHAIN (formal),
       actual = TREE_CHAIN (actual),
       i++)
    {
      tree arg = TREE_VALUE (actual); /* this has already been converted */
      enum machine_mode tmode = TYPE_MODE (TREE_TYPE (formal));
      tree decl = formal;
      rtx copy;

      emit_note (DECL_SOURCE_FILE (decl), DECL_SOURCE_LINE (decl));

      if (TREE_ADDRESSABLE (formal))
	{
	  int size = int_size_in_bytes (TREE_TYPE (formal));
	  copy = assign_stack_local (tmode, size);
	  store_expr (arg, copy, 0);
	}
      else if (! TREE_READONLY (formal)
	       || TREE_VOLATILE (formal))
	{
	  /* If parm is modified or if it hasn't a pseudo reg,
	     we may not simply substitute the actual value;
	     copy it through a register.  */
	  copy = gen_reg_rtx (tmode);
	  store_expr (arg, copy, 0);
	}
      else
	{
	  copy = expand_expr (arg, 0, tmode, 0);

	  /* We do not use CONSTANT_ADDRESS_P here because
	     the set of cases where that might make a difference
	     are a subset of the cases that arise even when
	     it is a CONSTANT_ADDRESS_P (i.e., fp_delta
	     gets into the act.  */
	  if (GET_CODE (copy) != REG && ! CONSTANT_P (copy))
	    copy = copy_to_reg (copy);
	}
      arg_vec[i] = copy;
    }

  copy_parm_decls (DECL_ARGUMENTS (fndecl), arg_vec);

  /* Perform postincrements before actually calling the function.  */
  emit_queue ();

  /* clean up stack so that variables might have smaller offsets.  */
  do_pending_stack_adjust ();

  /* Pass the function the address in which to return a structure value.  */
  if (structure_value_addr)
    emit_move_insn (struct_value_rtx, structure_value_addr);

  /* Now prepare for copying the insns.
     Set up reg_map, parm_map and label_map saying how to translate
     the pseudo-registers, stack-parm references and labels when copying.  */

  reg_map = (rtx *) alloca (max_regno * sizeof (rtx));
  bzero (reg_map, max_regno * sizeof (rtx));

  if (DECL_ARGUMENTS (fndecl))
    {
      tree decl = DECL_ARGUMENTS (fndecl);
      tree last = tree_last (decl);
      int offset = FUNCTION_ARGS_SIZE (header);
      parm_map =
	(rtx *)alloca ((offset / UNITS_PER_WORD) * sizeof (rtx));
      bzero (parm_map, (offset / UNITS_PER_WORD) * sizeof (rtx));
      parm_map -= FIRST_PARM_OFFSET / UNITS_PER_WORD;

      for (formal = decl, i = 0; formal; formal = TREE_CHAIN (formal), i++)
	{
	  /* Create an entry in PARM_MAP that says what pseudo register
	     is associated with an address we might compute.  */
	  parm_map[DECL_OFFSET (formal) / BITS_PER_WORD] = arg_vec[i];
	  /* Create an entry in REG_MAP that says what rtx is associated
	     with a pseudo register from the function being inlined.  */
	  if (GET_CODE (DECL_RTL (formal)) == REG)
	    reg_map[REGNO (DECL_RTL (formal))] = arg_vec[i];
	}
    }
  else
    {
      parm_map = NULL;
    }

  label_map = (rtx *)alloca ((max_labelno - min_labelno) * sizeof (rtx));
  label_map -= min_labelno;

  for (i = min_labelno; i < max_labelno; i++)
    label_map[i] = gen_label_rtx ();

  /* Set up a target to translate the inline function's value-register.  */

  if (structure_value_addr != 0 || TYPE_MODE (type) == VOIDmode)
    inline_target = 0;
  else
    {
      /* Machine mode function was declared to return.   */
      enum machine_mode departing_mode = TYPE_MODE (type);
      /* (Possibly wider) machine mode it actually computes
	 (for the sake of callers that fail to declare it right).  */
      enum machine_mode arriving_mode
	= TYPE_MODE (TREE_TYPE (DECL_RESULT (fndecl)));

      if (target && GET_MODE (target) == departing_mode)
	inline_target = target;
      else
	inline_target = target = gen_reg_rtx (departing_mode);

      /* If function's value was promoted before return,
	 avoid machine mode mismatch when we substitute INLINE_TARGET.
	 But TARGET is what we will return to the caller.  */
      if (arriving_mode != departing_mode)
	inline_target = gen_rtx (SUBREG, arriving_mode, target, 0);
    }

  /* We are about to make space in this function's stack frame
     for a copy of the stack frame of the inline function.
     First, create an RTX that points to that stack frame
     with the same offset usually used for the frame pointer.
     This will be substituted for all frame-pointer references.  */

  fp_delta = get_frame_size ();
#ifdef FRAME_GROWS_DOWNWARD
  fp_delta = - fp_delta;
#endif
  fp_delta -= STARTING_FRAME_OFFSET;

  inline_fp_rtx
    = copy_to_mode_reg (Pmode,
			plus_constant (frame_pointer_rtx, fp_delta));

  /* Now allocate the space for that to point at.  */

  assign_stack_local (VOIDmode, DECL_FRAME_SIZE (fndecl));

  /* Now copy the insns one by one.  */

  for (insn = insns; insn; insn = NEXT_INSN (insn))
    {
      rtx copy, pattern, next = 0;

      switch (GET_CODE (insn))
	{
	case INSN:
	  pattern = PATTERN (insn);

	  /* Special handling for the insn immediately after a CALL_INSN
	     that returned a value:
	     If it does copy the value, we must avoid the usual translation
	     of the return-register into INLINE_TARGET.
	     If it just USEs the value, the inline function expects it to
	     stay in the return-register and be returned,
	     so copy it into INLINE_TARGET.  */

	  if (follows_call
	      /* Allow a stack-adjust, handled normally, to come in between
		 the call and the value-copying insn.  */
	      && ! (GET_CODE (pattern) == SET
		    && SET_DEST (pattern) == stack_pointer_rtx))
	    {
	      if (GET_CODE (pattern) == SET
		  && rtx_equal_p (SET_SRC (pattern), follows_call))
		/* This insn copies the value: take special care to copy
		   that value to this insn's destination.  */
		{
		  copy = emit_insn (gen_rtx (SET, VOIDmode,
					     copy_rtx_and_substitute (SET_DEST (pattern)),
					     follows_call));
		  copy->integrated = 1;
		  follows_call = 0;
		  break;
		}
	      else if (GET_CODE (pattern) == USE
		       && rtx_equal_p (XEXP (pattern, 0), follows_call))
		/* This insn does nothing but says the value is expected
		   to flow through to the inline function's return-value.
		   Make that happen, then ignore this insn.  */
		{
		  copy = emit_insn (gen_rtx (SET, VOIDmode, inline_target,
					     follows_call));
		  copy->integrated = 1;
		  follows_call = 0;
		  break;
		}
	      /* If it does neither, this value must be ignored.  */
	      follows_call = 0;
	    }

	  /* The (USE (REG n)) at return from the function should be ignored
	     since we are changing (REG n) into inline_target.  */
	  if (GET_CODE (pattern) == USE
	      && GET_CODE (XEXP (pattern, 0)) == REG
	      && FUNCTION_VALUE_REGNO_P (REGNO (XEXP (pattern, 0))))
	    break;

	  /* Try to do some quick constant folding here.
	     This will save save execution time of the compiler,
	     as well time and space of the program if done here.  */
	  if (GET_CODE (pattern) == SET
	      && SET_DEST (pattern) == cc0_rtx)
	    next = try_fold_cc0 (insn);

	  if (next != 0)
	    {
	      insn = next;
	    }
	  else
	    {
	      copy = emit_insn (copy_rtx_and_substitute (pattern));
	      copy->integrated = 1;
	    }
	  break;

	case JUMP_INSN:
	  follows_call = 0;
	  if (GET_CODE (PATTERN (insn)) == RETURN)
	    {
	      if (return_label == 0)
		return_label = gen_label_rtx ();
	      emit_jump (return_label);
	      break;
	    }
	  copy = emit_jump_insn (copy_rtx_and_substitute (PATTERN (insn)));
	  copy->integrated = 1;
	  break;

	case CALL_INSN:
	  {
	    rtx newbod;
	    /* If the call's body is (set (reg...) (call...)),
	       the register is a function return register, but DON'T
	       translate it into INLINE_TARGET because it describes the
	       called function, not the caller's return value.  */
	    if (GET_CODE (PATTERN (insn)) == SET)
	      newbod = gen_rtx (SET, VOIDmode, SET_DEST (PATTERN (insn)),
				copy_rtx_and_substitute (SET_SRC (PATTERN (insn))));
	    else
	      newbod = copy_rtx_and_substitute (PATTERN (insn));
	    copy = emit_call_insn (newbod);
	  }
	  copy->integrated = 1;
	  /* Special handling needed for the following INSN depending on
	     whether it copies the value from the fcn return reg.  */
	  if (GET_CODE (PATTERN (insn)) == SET)
	    follows_call = SET_DEST (PATTERN (insn));
	  break;

	case CODE_LABEL:
	  emit_label (label_map[CODE_LABEL_NUMBER (insn)]);
	  follows_call = 0;
	  break;

	case BARRIER:
	  emit_barrier ();
	  break;

	case NOTE:
	  emit_note (NOTE_SOURCE_FILE (insn), NOTE_LINE_NUMBER (insn));
	  break;

	default:
	  abort ();
	  break;
	}
    }

  if (return_label)
    emit_label (return_label);

  /* Make copies of the decls of the symbols in the inline function, so that
     the copies of the variables get declared in the current function.  */
  copy_decl_tree (DECL_INITIAL (fndecl), 0);

  /* End the scope containing the copied formal parameter variables.  */

  expand_end_bindings (getdecls (), 1);
  poplevel (1, 1, 0);

  reg_map = NULL;
  label_map = NULL;

  if (ignore || TYPE_MODE (type) == VOIDmode)
    return 0;

  if (structure_value_addr)
    {
      if (target)
	return target;
      return gen_rtx (MEM, BLKmode,
		      memory_address (BLKmode, structure_value_addr));
    }

  return target;
}

/* Given a chain of PARM_DECLs, ARGS, and a vector of RTL homes VEC,
   copy each decl into a VAR_DECL, push all of those decls
   and give each one the corresponding home.  */

static void
copy_parm_decls (args, vec)
     tree args;
     rtx *vec;
{
  register tree tail;
  register int i;

  for (tail = args, i = 0; tail; tail = TREE_CHAIN (tail), i++)
    {
      register tree decl = pushdecl (build_decl (VAR_DECL, DECL_NAME (tail),
						 TREE_TYPE (tail)));
      DECL_RTL (decl) = vec[i];
    }
}

/* Given a LET_STMT node, push decls and levels
   so as to construct in the current function a tree of contexts
   isomorphic to the one that is given.  */

static void
copy_decl_tree (let, level)
     tree let;
     int level;
{
  tree t;

  pushlevel (0);
  
  for (t = STMT_VARS (let); t; t = TREE_CHAIN (t))
    {
      tree d = build_decl (TREE_CODE (t), DECL_NAME (t), TREE_TYPE (t));
      DECL_SOURCE_LINE (d) = DECL_SOURCE_LINE (t);
      DECL_SOURCE_FILE (d) = DECL_SOURCE_FILE (t);
      if (DECL_RTL (t) != 0)
	DECL_RTL (d) = copy_rtx_and_substitute (DECL_RTL (t));
      TREE_EXTERNAL (d) = TREE_EXTERNAL (t);
      TREE_STATIC (d) = TREE_STATIC (t);
      TREE_PUBLIC (d) = TREE_PUBLIC (t);
      TREE_LITERAL (d) = TREE_LITERAL (t);
      TREE_ADDRESSABLE (d) = TREE_ADDRESSABLE (t);
      TREE_READONLY (d) = TREE_READONLY (t);
      TREE_VOLATILE (d) = TREE_VOLATILE (t);
      pushdecl (d);
    }

  for (t = STMT_BODY (let); t; t = TREE_CHAIN (t))
    copy_decl_tree (t, level + 1);

  poplevel (level > 0, 0, 0);
}

/* Create a new copy of an rtx.
   Recursively copies the operands of the rtx,
   except for those few rtx codes that are sharable.  */

static rtx
copy_rtx_and_substitute (orig)
     register rtx orig;
{
  register rtx copy, temp;
  register int i, j;
  register RTX_CODE code;
  register enum machine_mode mode;
  register char *format_ptr;
  int regno;

  if (orig == 0)
    return 0;

  code = GET_CODE (orig);
  mode = GET_MODE (orig);

  switch (code)
    {
    case REG:
      /* If a frame-pointer register shows up, then we
	 must `fix' the reference.  If the stack pointer
	 register shows up, it must be part of stack-adjustments
	 (*not* because we eliminated the frame pointer!).
	 Small hard registers are returned as-is.  Pseudo-registers
	 go through their `reg_map'.  */
      regno = REGNO (orig);
      if (regno < FIRST_PSEUDO_REGISTER)
	{
	  if (FUNCTION_VALUE_REGNO_P (regno))
	    return inline_target;
	  if (regno == FRAME_POINTER_REGNUM)
	    return plus_constant (orig, fp_delta);
	  return orig;
	}
      if (reg_map[regno] == NULL)
	reg_map[regno] = gen_reg_rtx (mode);
      return reg_map[regno];

    case CODE_LABEL:
      return label_map[CODE_LABEL_NUMBER (orig)];

    case LABEL_REF:
      copy = rtx_alloc (LABEL_REF);
      PUT_MODE (copy, mode);
      XEXP (copy, 0) = label_map[CODE_LABEL_NUMBER (XEXP (orig, 0))];
      return copy;

    case PC:
    case CC0:
    case CONST_INT:
    case CONST_DOUBLE:
    case SYMBOL_REF:
      return orig;

    case PLUS:
      /* Note:  the PLUS case is not nearly as careful as the MEM
	 case in terms of preserving addresses.  The reason for this
	 is that it is expected that if a PLUS_EXPR turns out not
	 to be a legitimate address, reload can fix that up, without
	 doing major damage.  However, a MEM rtx must preside
	 over a legitimate address.  The MEM case has lots of hair
	 to deal with what happens when it sits on a PLUS...  */
      /* Take care of the easy case quickly.  */
      if (XEXP (orig, 0) == frame_pointer_rtx
	  || XEXP (orig, 1) == frame_pointer_rtx
	  || (ARG_POINTER_REGNUM != FRAME_POINTER_REGNUM
	      && (XEXP (orig, 0) == arg_pointer_rtx
		  || XEXP (orig, 1) == arg_pointer_rtx)))
	{
	  if (XEXP (orig, 0) == frame_pointer_rtx
	      || XEXP (orig, 0) == arg_pointer_rtx)
	    copy = XEXP (orig, 1);
	  else
	    copy = XEXP (orig, 0);

	  if (GET_CODE (copy) == CONST_INT)
	    {
	      int c = INTVAL (copy);

	      if (c > 0)
		{
		  copy = parm_map[c / UNITS_PER_WORD];
		  return XEXP (copy, 0);
		}
	      return gen_rtx (PLUS, mode,
			      frame_pointer_rtx,
			      gen_rtx (CONST_INT, SImode,
				       c + fp_delta));
	    }
	  copy = copy_rtx_and_substitute (copy);
	  temp = gen_rtx (PLUS, mode, frame_pointer_rtx, copy);
	  return plus_constant (temp, fp_delta);
	}
      else if (reg_mentioned_p (frame_pointer_rtx, orig)
	       || (ARG_POINTER_REGNUM != FRAME_POINTER_REGNUM
		   && reg_mentioned_p (arg_pointer_rtx, orig)))
	{
	  /* If we have a complex sum which has a frame pointer
	     in it, and it was a legitimate address, then
	     keep it that way.  */
	  if (memory_address_p (mode, orig))
	    {
	      if (GET_CODE (XEXP (orig, 0)) == CONST_INT)
		{
		  copy = copy_rtx_and_substitute (XEXP (orig, 1));
		  temp = plus_constant (copy, INTVAL (XEXP (orig, 0)));
		}
	      else if (GET_CODE (XEXP (orig, 1)) == CONST_INT)
		{
		  copy = copy_rtx_and_substitute (XEXP (orig, 0));
		  temp = plus_constant (copy, INTVAL (XEXP (orig, 1)));
		}
	      else
		{
		  temp = gen_rtx (PLUS, GET_MODE (orig),
				  copy_rtx_and_substitute (XEXP (orig, 0)),
				  copy_rtx_and_substitute (XEXP (orig, 1)));
		}
	      temp = memory_address (mode, temp);
	    }
	  else
	    temp = gen_rtx (PLUS, GET_MODE (orig),
			    copy_rtx_and_substitute (XEXP (orig, 0)),
			    copy_rtx_and_substitute (XEXP (orig, 1)));
	}
      else
	temp = gen_rtx (PLUS, GET_MODE (orig),
			copy_rtx_and_substitute (XEXP (orig, 0)),
			copy_rtx_and_substitute (XEXP (orig, 1)));

      return temp;
      
    case MEM:
      /* Take care of easiest case here.  */
      copy = XEXP (orig, 0);
      if (copy == frame_pointer_rtx || copy == arg_pointer_rtx)
	return gen_rtx (MEM, mode,
			plus_constant (frame_pointer_rtx, fp_delta));
      if (GET_CODE (copy) == PLUS)
	{
	  if (XEXP (copy, 0) == frame_pointer_rtx
	      || XEXP (copy, 1) == frame_pointer_rtx
	      || (ARG_POINTER_REGNUM != FRAME_POINTER_REGNUM
		  && (XEXP (copy, 0) == arg_pointer_rtx
		      || XEXP (copy, 1) == arg_pointer_rtx)))
	    {
	      rtx reg;
	      if (XEXP (copy, 0) == frame_pointer_rtx
		  || XEXP (copy, 0) == arg_pointer_rtx)
		reg = XEXP (copy, 0), copy = XEXP (copy, 1);
	      else
		reg = XEXP (copy, 1), copy = XEXP (copy, 0);

	      if (GET_CODE (copy) == CONST_INT)
		{
		  int c = INTVAL (copy);

		  if (reg == arg_pointer_rtx
		      && c >= FIRST_PARM_OFFSET)
		    {
		      copy = parm_map[c / UNITS_PER_WORD];

		      /* If the MEM is only some of the bytes in the parm,
			 truncate the parm value to the desired mode.  */
		      if (GET_MODE (copy) != mode
			  && GET_MODE (copy) != VOIDmode)
			return convert_to_mode (mode, copy, 0);
		      return copy;
		    }
		  temp = gen_rtx (PLUS, Pmode,
				  frame_pointer_rtx,
				  gen_rtx (CONST_INT, SImode,
					   c + fp_delta));
		  if (! memory_address_p (Pmode, temp))
		    return gen_rtx (MEM, mode, plus_constant (inline_fp_rtx, c));
		}
	      copy =  copy_rtx_and_substitute (copy);
	      temp = gen_rtx (PLUS, Pmode, frame_pointer_rtx, copy);
	      temp = plus_constant (temp, fp_delta);
	      temp = memory_address (Pmode, temp);
	    }
	  else if (reg_mentioned_p (frame_pointer_rtx, copy)
		   || (ARG_POINTER_REGNUM != FRAME_POINTER_REGNUM
		       && reg_mentioned_p (arg_pointer_rtx, copy)))
	    {
	      if (GET_CODE (XEXP (copy, 0)) == CONST_INT)
		{
		  temp = copy_rtx_and_substitute (XEXP (copy, 1));
		  temp = plus_constant (temp, INTVAL (XEXP (copy, 0)));
		}
	      else if (GET_CODE (XEXP (copy, 1)) == CONST_INT)
		{
		  temp = copy_rtx_and_substitute (XEXP (copy, 0));
		  temp = plus_constant (temp, INTVAL (XEXP (copy, 1)));
		}
	      else
		{
		  temp = gen_rtx (PLUS, GET_MODE (copy),
				  copy_rtx_and_substitute (XEXP (copy, 0)),
				  copy_rtx_and_substitute (XEXP (copy, 1)));
		}
	    }
	  else
	    {
	      if (GET_CODE (XEXP (copy, 1)) == CONST_INT)
		temp = plus_constant (copy_rtx_and_substitute (XEXP (copy, 0)),
				      INTVAL (XEXP (copy, 1)));
	      else if (GET_CODE (XEXP (copy, 0)) == CONST_INT)
		temp = plus_constant (copy_rtx_and_substitute (XEXP (copy, 1)),
				      INTVAL (XEXP (copy, 0)));
	      else
		{
		  rtx left = copy_rtx_and_substitute (XEXP (copy, 0));
		  rtx right = copy_rtx_and_substitute (XEXP (copy, 1));

		  temp = gen_rtx (PLUS, GET_MODE (copy), left, right);
		}
	    }
	}
      else
	temp = copy_rtx_and_substitute (copy);

      return change_address (orig, mode, temp);

    case RETURN:
      abort ();
    }

  copy = rtx_alloc (code);
  PUT_MODE (copy, mode);
  copy->in_struct = orig->in_struct;
  copy->volatil = orig->volatil;
  copy->unchanging = orig->unchanging;

  format_ptr = GET_RTX_FORMAT (GET_CODE (copy));

  for (i = 0; i < GET_RTX_LENGTH (GET_CODE (copy)); i++)
    {
      rtx new;

      switch (*format_ptr++)
	{
	case 'u':
	case '0':
	  break;

	case 'e':
	  XEXP (copy, i) = copy_rtx_and_substitute (XEXP (orig, i));
	  break;

	case 'E':
	  XVEC (copy, i) = XVEC (orig, i);
	  if (XVEC (orig, i) != NULL)
	    {
	      XVEC (copy, i) = rtvec_alloc (XVECLEN (orig, i));
	      for (j = 0; j < XVECLEN (copy, i); j++)
		XVECEXP (copy, i, j) = copy_rtx_and_substitute (XVECEXP (orig, i, j));
	    }
	  break;

	case 'i':
	  XINT (copy, i) = XINT (orig, i);
	  break;

	case 's':
	  XSTR (copy, i) = XSTR (orig, i);
	  break;

	default:
	  fprintf (stderr,
		   "switch format wrong in rtl2.copy_rtx_and_substitute(). format was: %c.\n",
		   format_ptr[-1]);
	  abort ();
	}
    }
  return copy;
}

/* Attempt to simplify INSN while copying it from an inline fn,
   assuming it is a SET that sets CC0.

   If we simplify it, we emit the appropriate insns and return
   the last insn that we have handled (since we may handle the insn
   that follows INSN as well as INSN itself).

   Otherwise we do nothing and return zero.  */

static rtx
try_fold_cc0 (insn)
     rtx insn;
{
  rtx cnst = copy_rtx_and_substitute (SET_SRC (PATTERN (insn)));
  rtx pat, copy;

  if (CONSTANT_P (cnst)
      /* @@ Cautious: Don't know how many of these tests we need.  */
      && NEXT_INSN (insn)
      && GET_CODE (pat = PATTERN (NEXT_INSN (insn))) == SET
      && SET_DEST (pat) == pc_rtx
      && GET_CODE (pat = SET_SRC (pat)) == IF_THEN_ELSE
      && GET_RTX_LENGTH (GET_CODE (XEXP (pat, 0))) == 2)
    {
      rtx cnst2;
      rtx cond = XEXP (pat, 0);

      if ((XEXP (cond, 0) == cc0_rtx
	   && CONSTANT_P (XEXP (cond, 1))
	   && (cnst2 = XEXP (cond, 1)))
	  || (XEXP (cond, 1) == cc0_rtx
	      && CONSTANT_P (XEXP (cond, 0))
	      && (cnst2 = XEXP (cond, 0))))
	{
	  copy = fold_out_const_cc0 (cond, XEXP (pat, 1), XEXP (pat, 2),
				     cnst, cnst2);
	  if (copy)
	    {
	      if (GET_CODE (copy) == LABEL_REF)
		{
		  /* We will branch unconditionally to
		     the label specified by COPY.
		     Eliminate dead code by running down the
		     list of insn until we see a CODE_LABEL.
		     If the CODE_LABEL is the one specified
		     by COPY, we win, and can delete all code
		     up to (but not necessarily including)
		     that label.  Otherwise only win a little:
		     emit the branch insn, and continue expanding.  */
		  rtx tmp = NEXT_INSN (insn);
		  while (tmp && GET_CODE (tmp) != CODE_LABEL)
		    tmp = NEXT_INSN (tmp);
		  if (! tmp)
		    abort ();
		  if (label_map[CODE_LABEL_NUMBER (tmp)] == XEXP (copy, 0))
		    {
		      /* Big win.  */
		      return PREV_INSN (tmp);
		    }
		  else
		    {
		      /* Small win.  Emit the unconditional branch,
			 followed by a BARRIER, so that jump optimization
			 will know what to do.  */
		      emit_jump (copy);
		      return NEXT_INSN (insn);
		    }
		}
	      else if (copy == pc_rtx)
		{
		  /* Do not take the branch, just fall through.
		     Jump optimize should handle the elimination of
		     dead code if appropriate.  */
		  return NEXT_INSN (insn);
		}
	      else
		abort ();
	    }
	}
    }
  return 0;
}

/* If (COND_RTX CNST1 CNST2) yield a result we can treat
   as being constant, return THEN_RTX if the result is always
   non-zero, and return ELSE_RTX otherwise.  */
static rtx
fold_out_const_cc0 (cond_rtx, then_rtx, else_rtx, cnst1, cnst2)
     rtx cond_rtx, then_rtx, else_rtx;
     rtx cnst1, cnst2;
{
  int value1, value2;
  int int1 = GET_CODE (cnst1) == CONST_INT;
  int int2 = GET_CODE (cnst2) == CONST_INT;
  if (int1)
    value1 = INTVAL (cnst1);
  else
    value1 = 1;
  if (int2)
    value2 = INTVAL (cnst2);
  else
    value2 = 1;

  switch (GET_CODE (cond_rtx))
    {
    case NE:
      if (int1 && int2)
	if (value1 != value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0 || value2 == 0)
	return copy_rtx_and_substitute (then_rtx);
      if (int1 == 0 && int2 == 0)
	if (rtx_equal_p (cnst1, cnst2))
	  return copy_rtx_and_substitute (else_rtx);
      break;
    case EQ:
      if (int1 && int2)
	if (value1 == value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0 || value2 == 0)
	return copy_rtx_and_substitute (else_rtx);
      if (int1 == 0 && int2 == 0)
	if (rtx_equal_p (cnst1, cnst2))
	  return copy_rtx_and_substitute (then_rtx);
      break;
    case GE:
      if (int1 && int2)
	if (value1 >= value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (else_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (then_rtx);
      break;
    case GT:
      if (int1 && int2)
	if (value1 > value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (else_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (then_rtx);
      break;
    case LE:
      if (int1 && int2)
	if (value1 <= value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (then_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (else_rtx);
      break;
    case LT:
      if (int1 && int2)
	if (value1 < value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (then_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (else_rtx);
      break;
    case GEU:
      if (int1 && int2)
	if ((unsigned)value1 >= (unsigned)value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (else_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (then_rtx);
      break;
    case GTU:
      if (int1 && int2)
	if ((unsigned)value1 > (unsigned)value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (else_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (then_rtx);
      break;
    case LEU:
      if (int1 && int2)
	if ((unsigned)value1 <= (unsigned)value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (then_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (else_rtx);
      break;
    case LTU:
      if (int1 && int2)
	if ((unsigned)value1 < (unsigned)value2)
	  return copy_rtx_and_substitute (then_rtx);
	else
	  return copy_rtx_and_substitute (else_rtx);
      if (value1 == 0)
	return copy_rtx_and_substitute (then_rtx);
      if (value2 == 0)
	return copy_rtx_and_substitute (else_rtx);
      break;
    }
  /* Could not hack it.  */
  return 0;
}

/* Output the assembly language code for the function FNDECL
   from its DECL_SAVED_INSNS.  Used for inline functions that are output
   at end of compilation instead of where they came in the source.  */

void
output_inline_function (fndecl)
     tree fndecl;
{
  rtx head = DECL_SAVED_INSNS (fndecl);
  rtx last;

  temporary_allocation ();

  /* This call is only used to initialize global variables.
     The rtl code it emits will be discarded below.  */
  expand_function_start (fndecl);

  /* Set stack frame size.  */
  assign_stack_local (BLKmode, DECL_FRAME_SIZE (fndecl));

  restore_reg_data (FIRST_PARM_INSN (head));

  expand_function_end (fndecl);

  for (last = head; NEXT_INSN (last); last = NEXT_INSN (last))
    ;

  set_new_first_and_last_insn (FIRST_PARM_INSN (head), last);

  /* Compile this function all the way down to assembly code.  */
  rest_of_compilation (fndecl);

  permanent_allocation ();
}
