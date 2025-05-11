/* Convert tree expression to rtl instructions, for GNU compiler.
   Copyright (C) 1988 Free Software Foundation, Inc.

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
#include "tree.h"
#include "flags.h"
#include "insn-flags.h"
#include "insn-codes.h"
#include "expr.h"
#include "insn-config.h"
#include "recog.h"
#include "varargs.h"

/* Decide whether a function's arguments should be processed
   from first to last or from last to first.  */

#ifdef STACK_GROWS_DOWNWARD
#ifdef PUSH_ROUNDING
#define PUSH_ARGS_REVERSED	/* If it's last to first */
#endif
#endif

/* Like STACK_BOUNDARY but in units of bytes, not bits.  */
#define STACK_BYTES (STACK_BOUNDARY / BITS_PER_UNIT)

/* If this is nonzero, we do not bother generating VOLATILE
   around volatile memory references, and we are willing to
   output indirect addresses.  If cse is to follow, we reject
   indirect addresses so a useful potential cse is generated;
   if it is used only once, instruction combination will produce
   the same indirect address eventually.  */
int cse_not_expected;

/* Nonzero to generate code for all the subroutines within an
   expression before generating the upper levels of the expression.
   Nowadays this is never zero.  */
int do_preexpand_calls = 1;

/* Number of units that we should eventually pop off the stack.
   These are the arguments to function calls that have already returned.  */
int pending_stack_adjust;

/* Total size of arguments already pushed for function calls that
   have not happened yet.  Also counts 1 for each level of conditional
   expression that we are inside.  When this is nonzero,
   args passed to function calls must be popped right away
   to ensure contiguity of argument lists for future calls.  */
static int current_args_size;

/* Nonzero means current function may call alloca.  */
int may_call_alloca;

rtx store_expr ();
static void store_constructor ();
static rtx store_field ();
static rtx expand_call ();
static void emit_call_1 ();
static rtx prepare_call_address ();
static rtx expand_builtin ();
static rtx compare ();
static rtx compare_constants ();
static rtx compare1 ();
static rtx do_store_flag ();
static void preexpand_calls ();
static rtx expand_increment ();
static void move_by_pieces_1 ();
static int move_by_pieces_ninsns ();
static void init_queue ();

void do_pending_stack_adjust ();

/* MOVE_RATIO is the number of move instructions that is better than
   a block move.  */

#if defined (HAVE_movstrhi) || defined (HAVE_movstrsi)
#define MOVE_RATIO 2
#else
#define MOVE_RATIO 6
#endif

/* Table indexed by tree code giving 1 if the code is for a
   comparison operation, or anything that is most easily
   computed with a conditional branch.

   We include tree.def to give it the proper length.
   The contents thus created are irrelevant.
   The real contents are initialized in init_comparisons.  */

#define DEFTREECODE(SYM, NAME, TYPE, LENGTH) 0,

static char comparison_code[] = {
#include "tree.def"
};
#undef DEFTREECODE

/* This is run once per compilation.  */

void
init_comparisons ()
{
  comparison_code[(int) EQ_EXPR] = 1;
  comparison_code[(int) NE_EXPR] = 1;
  comparison_code[(int) LT_EXPR] = 1;
  comparison_code[(int) GT_EXPR] = 1;
  comparison_code[(int) LE_EXPR] = 1;
  comparison_code[(int) GE_EXPR] = 1;
}

/* This is run at the start of compiling a function.  */

void
init_expr ()
{
  init_queue ();
  may_call_alloca = 0;
}

/* Manage the queue of increment instructions to be output
   for POSTINCREMENT_EXPR expressions, etc.  */

static rtx pending_chain;

/* Queue up to increment (or change) VAR later.  BODY says how:
   BODY should be the same thing you would pass to emit_insn
   to increment right away.  It will go to emit_insn later on.

   The value is a QUEUED expression to be used in place of VAR
   where you want to guarantee the pre-incrementation value of VAR.  */

static rtx
enqueue_insn (var, body)
     rtx var, body;
{
  pending_chain = gen_rtx (QUEUED, GET_MODE (var),
			   var, 0, 0, body, pending_chain);
  return pending_chain;
}

/* Use protect_from_queue to convert a QUEUED expression
   into something that you can put immediately into an instruction.
   If the queued incrementation has not happened yet,
   protect_from_queue returns the variable itself.
   If the incrementation has happened, protect_from_queue returns a temp
   that contains a copy of the old value of the variable.

   Any time an rtx which might possibly be a QUEUED is to be put
   into an instruction, it must be passed through protect_from_queue first.
   QUEUED expressions are not meaningful in instructions.

   Do not pass a value through protect_from_queue and then hold
   on to it for a while before putting it in an instruction!
   If the queue is flushed in between, incorrect code will result.  */

rtx
protect_from_queue (x, modify)
     register rtx x;
     int modify;
{
  register RTX_CODE code = GET_CODE (x);
  if (code != QUEUED)
    {
      /* A special hack for read access to (MEM (QUEUED ...))
	 to facilitate use of autoincrement.
	 Make a copy of the contents of the memory location
	 rather than a copy of the address.  */
      if (code == MEM && GET_CODE (XEXP (x, 0)) == QUEUED && !modify)
	{
	  register rtx y = XEXP (x, 0);
	  XEXP (x, 0) = QUEUED_VAR (y);
	  if (QUEUED_INSN (y))
	    {
	      register rtx temp = gen_reg_rtx (GET_MODE (x));
	      emit_insn_before (gen_move_insn (temp, x),
				QUEUED_INSN (y));
	      return temp;
	    }
	  return x;
	}
      /* Otherwise, recursively protect the subexpressions of all
	 the kinds of rtx's that can contain a QUEUED.  */
      if (code == MEM)
	XEXP (x, 0) = protect_from_queue (XEXP (x, 0), 0);
      else if (code == PLUS || code == MULT)
	{
	  XEXP (x, 0) = protect_from_queue (XEXP (x, 0), 0);
	  XEXP (x, 1) = protect_from_queue (XEXP (x, 1), 0);
	}
      return x;
    }
  /* If the increment has not happened, use the variable itself.  */
  if (QUEUED_INSN (x) == 0)
    return QUEUED_VAR (x);
  /* If the increment has happened and a pre-increment copy exists,
     use that copy.  */
  if (QUEUED_COPY (x) != 0)
    return QUEUED_COPY (x);
  /* The increment has happened but we haven't set up a pre-increment copy.
     Set one up now, and use it.  */
  QUEUED_COPY (x) = gen_reg_rtx (GET_MODE (QUEUED_VAR (x)));
  emit_insn_before (gen_move_insn (QUEUED_COPY (x), QUEUED_VAR (x)),
		    QUEUED_INSN (x));
  return QUEUED_COPY (x);
}

/* Return nonzero if X contains a QUEUED expression:
   if it contains anything that will be altered by a queued increment.  */

static int
queued_subexp_p (x)
     rtx x;
{
  register enum rtx_code code = GET_CODE (x);
  switch (code)
    {
    case QUEUED:
      return 1;
    case MEM:
      return queued_subexp_p (XEXP (x, 0));
    case MULT:
    case PLUS:
    case MINUS:
      return queued_subexp_p (XEXP (x, 0))
	|| queued_subexp_p (XEXP (x, 1));
    }
  return 0;
}

/* Perform all the pending incrementations.  */

void
emit_queue ()
{
  register rtx p;
  while (p = pending_chain)
    {
      QUEUED_INSN (p) = emit_insn (QUEUED_BODY (p));
      pending_chain = QUEUED_NEXT (p);
    }
}

static void
init_queue ()
{
  if (pending_chain)
    abort ();
}

/* Copy data from FROM to TO, where the machine modes are not the same.
   Both modes may be integer, or both may be floating.
   UNSIGNEDP should be nonzero if FROM is an unsigned type.
   This causes zero-extension instead of sign-extension.  */

void
convert_move (to, from, unsignedp)
     register rtx to, from;
     int unsignedp;
{
  enum machine_mode to_mode = GET_MODE (to);
  enum machine_mode from_mode = GET_MODE (from);
  int to_real = to_mode == SFmode || to_mode == DFmode;
  int from_real = from_mode == SFmode || from_mode == DFmode;
  int extending = (int) to_mode > (int) from_mode;

  to = protect_from_queue (to, 1);
  from = protect_from_queue (from, 0);

  if (to_real != from_real)
    abort ();

  if (to_mode == from_mode
      || (from_mode == VOIDmode && CONSTANT_P (from)))
    {
      emit_move_insn (to, from);
      return;
    }

  if (to_real)
    {
#ifdef HAVE_extendsfdf2
      if (HAVE_extendsfdf2 && extending)
	{
	  emit_unop_insn (CODE_FOR_extendsfdf2, to, from, UNKNOWN);
	  return;
	}
#endif
#ifdef HAVE_truncdfsf2
      if (HAVE_truncdfsf2 && ! extending)
	{
	  emit_unop_insn (CODE_FOR_truncdfsf2, to, from, UNKNOWN);
	  return;
	}
#endif
      emit_library_call (gen_rtx (SYMBOL_REF, Pmode, (extending
						      ? "_extendsfdf2"
						      : "_truncdfsf2")),
			 GET_MODE (to), 1,
			 from,  (extending ? SFmode : DFmode));
      emit_move_insn (to, hard_libcall_value (GET_MODE (to)));
      return;
    }

  /* Now both modes are integers.  */

  if (to_mode == DImode)
    {
      emit_insn (gen_rtx (CLOBBER, VOIDmode, to));

      if (unsignedp)
	{
	  convert_move (gen_lowpart (SImode, to), from, unsignedp);
	  emit_clr_insn (gen_highpart (SImode, to));
	}
#ifdef HAVE_slt
      else if (HAVE_slt && insn_operand_mode[(int) CODE_FOR_slt][0] == SImode)
	{
	  convert_move (gen_lowpart (SImode, to), from, unsignedp);
	  emit_insn (gen_slt (gen_highpart (SImode, to)));
	}
#endif
      else
	{
	  register rtx label = gen_label_rtx ();

	  emit_clr_insn (gen_highpart (SImode, to));
	  convert_move (gen_lowpart (SImode, to), from, unsignedp);
	  emit_cmp_insn (gen_lowpart (SImode, to),
			 gen_rtx (CONST_INT, VOIDmode, 0),
			 0, 0);
	  emit_jump_insn (gen_bge (label));
	  expand_unop (SImode, one_cmpl_optab,
		       gen_highpart (SImode, to), gen_highpart (SImode, to),
		       1);
	  emit_label (label);
	}
      return;
    }

  if (from_mode == DImode)
    {
      convert_move (to, gen_lowpart (SImode, from), 0);
      return;
    }

  /* Now follow all the conversions between integers
     no more than a word long.  */

  /* For truncation, usually we can just refer to FROM in a narrower mode.  */
  if (GET_MODE_BITSIZE (to_mode) < GET_MODE_BITSIZE (from_mode)
      && TRULY_NOOP_TRUNCATION (GET_MODE_BITSIZE (to_mode),
				GET_MODE_BITSIZE (from_mode))
      && ((GET_CODE (from) == MEM
	   && ! mode_dependent_address_p (XEXP (from, 0)))
	  || GET_CODE (from) == REG))
    {
      emit_move_insn (to, gen_lowpart (to_mode, from));
      return;
    }

  if (to_mode == SImode && from_mode == HImode)
    {
      if (unsignedp)
	{
#ifdef HAVE_zero_extendhisi2
	  if (HAVE_zero_extendhisi2)
	    emit_unop_insn (CODE_FOR_zero_extendhisi2, to, from, ZERO_EXTEND);
	  else
#endif
	    abort ();
	}
      else
	{
#ifdef HAVE_extendhisi2
	  if (HAVE_extendhisi2)
	    emit_unop_insn (CODE_FOR_extendhisi2, to, from, SIGN_EXTEND);
	  else
#endif
	    abort ();
	}
      return;
    }

  if (to_mode == SImode && from_mode == QImode)
    {
      if (unsignedp)
	{
#ifdef HAVE_zero_extendqisi2
	  if (HAVE_zero_extendqisi2)
	    {
	      emit_unop_insn (CODE_FOR_zero_extendqisi2, to, from, ZERO_EXTEND);
	      return;
	    }
#endif
#if defined (HAVE_zero_extendqihi2) && defined (HAVE_extendhisi2)
	  if (HAVE_zero_extendqihi2 && HAVE_extendhisi2)
	    {
	      register rtx temp = gen_reg_rtx (HImode);
	      emit_unop_insn (CODE_FOR_zero_extendqihi2, temp, from, ZERO_EXTEND);
	      emit_unop_insn (CODE_FOR_extendhisi2, to, temp, SIGN_EXTEND);
	      return;
	    }
#endif
	}
      else
	{
#ifdef HAVE_extendqisi2
	  if (HAVE_extendqisi2)
	    {
	      emit_unop_insn (CODE_FOR_extendqisi2, to, from, SIGN_EXTEND);
	      return;
	    }
#endif
#if defined (HAVE_extendqihi2) && defined (HAVE_extendhisi2)
	  if (HAVE_extendqihi2 && HAVE_extendhisi2)
	    {
	      register rtx temp = gen_reg_rtx (HImode);
	      emit_unop_insn (CODE_FOR_extendqihi2, temp, from, SIGN_EXTEND);
	      emit_unop_insn (CODE_FOR_extendhisi2, to, temp, SIGN_EXTEND);
	      return;
	    }
#endif
	}
      abort ();
    }

  if (to_mode == HImode && from_mode == QImode)
    {
      if (unsignedp)
	{
#ifdef HAVE_zero_extendqihi2
	  if (HAVE_zero_extendqihi2)
	    {
	      emit_unop_insn (CODE_FOR_zero_extendqihi2, to, from, ZERO_EXTEND);
	      return;
	    }
#endif
	}
      else
	{
#ifdef HAVE_extendqihi2
	  if (HAVE_extendqihi2)
	    {
	      emit_unop_insn (CODE_FOR_extendqihi2, to, from, SIGN_EXTEND);
	      return;
	    }
#endif
	}
      abort ();
    }

  /* Now we are truncating an integer to a smaller one.
     If the result is a temporary, we might as well just copy it,
     since only the low-order part of the result needs to be valid
     and it is valid with no change.  */

  if (GET_CODE (to) == REG)
    {
      if (GET_CODE (from) == REG)
	{
	  emit_move_insn (to, gen_lowpart (GET_MODE (to), from));
	  return;
	}
      else if (GET_CODE (from) == SUBREG)
	{
	  from = copy_rtx (from);
	  /* This is safe since FROM is not more than one word.  */
	  PUT_MODE (from, GET_MODE (to));
	  emit_move_insn (to, from);
	  return;
	}
#ifndef BYTES_BIG_ENDIAN
      else if (GET_CODE (from) == MEM)
	{
	  register rtx addr = XEXP (from, 0);
	  if (memory_address_p (GET_MODE (to), addr))
	    {
	      emit_move_insn (to, gen_rtx (MEM, GET_MODE (to), addr));
	      return;
	    }
	}
#endif /* not BYTES_BIG_ENDIAN */
    }

  if (from_mode == SImode && to_mode == HImode)
    {
#ifdef HAVE_truncsihi2
      if (HAVE_truncsihi2)
	{
	  emit_unop_insn (CODE_FOR_truncsihi2, to, from, UNKNOWN);
	  return;
	}
#endif
      abort ();
    }

  if (from_mode == SImode && to_mode == QImode)
    {
#ifdef HAVE_truncsiqi2
      if (HAVE_truncsiqi2)
	{
	  emit_unop_insn (CODE_FOR_truncsiqi2, to, from, UNKNOWN);
	  return;
	}
#endif
      abort ();
    }

  if (from_mode == HImode && to_mode == QImode)
    {
#ifdef HAVE_trunchiqi2
      if (HAVE_trunchiqi2)
	{
	  emit_unop_insn (CODE_FOR_trunchiqi2, to, from, UNKNOWN);
	  return;
	}
#endif
      abort ();
    }

  /* Mode combination is not recognized.  */
  abort ();
}

/* Return an rtx for a value that would result
   from converting X to mode MODE.
   Both X and MODE may be floating, or both integer.
   UNSIGNEDP is nonzero if X is an unsigned value.
   This can be done by referring to a part of X in place
   or by copying to a new temporary with conversion.  */

rtx
convert_to_mode (mode, x, unsignedp)
     enum machine_mode mode;
     rtx x;
     int unsignedp;
{
  register rtx temp;
  if (mode == GET_MODE (x))
    return x;
  if (integer_mode_p (mode)
      && GET_MODE_SIZE (mode) <= GET_MODE_SIZE (GET_MODE (x)))
    return gen_lowpart (mode, x);
  temp = gen_reg_rtx (mode);
  convert_move (temp, x, unsignedp);
  return temp;
}

int
integer_mode_p (mode)
     enum machine_mode mode;
{
  return (int) mode > (int) VOIDmode && (int) mode <= (int) TImode;
}

/* Generate several move instructions to copy LEN bytes
   from block FROM to block TO.  (These are MEM rtx's with BLKmode).
   The caller must pass FROM and TO
    through protect_from_queue before calling.
   ALIGN (in bytes) is maximum alignment we can assume.  */

struct move_by_pieces
{
  rtx to;
  rtx to_addr;
  int autinc_to;
  int explicit_inc_to;
  rtx from;
  rtx from_addr;
  int autinc_from;
  int explicit_inc_from;
  int len;
  int offset;
  int reverse;
};

static void
move_by_pieces (to, from, len, align)
     rtx to, from;
     int len, align;
{
  struct move_by_pieces data;
  rtx to_addr = XEXP (to, 0), from_addr = XEXP (from, 0);

  data.offset = 0;
  data.to_addr = to_addr;
  data.from_addr = from_addr;
  data.to = to;
  data.from = from;
  data.autinc_to
    = (GET_CODE (to_addr) == PRE_INC || GET_CODE (to_addr) == PRE_DEC
       || GET_CODE (to_addr) == POST_INC || GET_CODE (to_addr) == POST_DEC);
  data.autinc_from
    = (GET_CODE (from_addr) == PRE_INC || GET_CODE (from_addr) == PRE_DEC
       || GET_CODE (from_addr) == POST_INC
       || GET_CODE (from_addr) == POST_DEC);

  data.explicit_inc_from = 0;
  data.explicit_inc_to = 0;
  data.reverse
    = (GET_CODE (to_addr) == PRE_DEC || GET_CODE (to_addr) == POST_DEC);
  if (data.reverse) data.offset = len;
  data.len = len;

  /* If copying requires more than two move insns,
     copy addresses to registers (to make displacements shorter)
     and use post-increment if available.  */
  if (!(data.autinc_from && data.autinc_to)
      && move_by_pieces_ninsns (len, align) > 2)
    {
#ifdef HAVE_PRE_DECREMENT
      if (data.reverse && ! data.autinc_from)
	{
	  data.from_addr = copy_addr_to_reg (plus_constant (from_addr, len));
	  data.autinc_from = 1;
	  data.explicit_inc_from = -1;
	}
#endif
#ifdef HAVE_POST_INCREMENT
      if (! data.autinc_from)
	{
	  data.from_addr = copy_addr_to_reg (from_addr);
	  data.autinc_from = 1;
	  data.explicit_inc_from = 1;
	}
#endif
      if (!data.autinc_from && CONSTANT_P (from_addr))
	data.from_addr = copy_addr_to_reg (from_addr);
#ifdef HAVE_PRE_DECREMENT
      if (data.reverse && ! data.autinc_to)
	{
	  data.to_addr = copy_addr_to_reg (plus_constant (to_addr, len));
	  data.autinc_to = 1;
	  data.explicit_inc_to = -1;
	}
#endif
#ifdef HAVE_POST_INCREMENT
      if (! data.reverse && ! data.autinc_to)
	{
	  data.to_addr = copy_addr_to_reg (to_addr);
	  data.autinc_to = 1;
	  data.explicit_inc_to = 1;
	}
#endif
      if (!data.autinc_to && CONSTANT_P (to_addr))
	data.to_addr = copy_addr_to_reg (to_addr);
    }

#ifdef STRICT_ALIGNMENT
  if (align > MOVE_MAX || align >= BIGGEST_ALIGNMENT / BITS_PER_UNIT)
    align = MOVE_MAX;
#else
  align = MOVE_MAX;
#endif

#ifdef HAVE_movti
  if (HAVE_movti && align >= GET_MODE_SIZE (TImode))
    move_by_pieces_1 (gen_movti, TImode, &data);
#endif
#ifdef HAVE_movdi
  if (HAVE_movdi && align >= GET_MODE_SIZE (DImode))
    move_by_pieces_1 (gen_movdi, DImode, &data);
#endif
#ifdef HAVE_movsi
  if (align >= GET_MODE_SIZE (SImode))
    move_by_pieces_1 (gen_movsi, SImode, &data);
#endif
#ifdef HAVE_movhi
  if (HAVE_movhi && align >= GET_MODE_SIZE (HImode))
    move_by_pieces_1 (gen_movhi, HImode, &data);
#endif
#ifdef HAVE_movqi
  move_by_pieces_1 (gen_movqi, QImode, &data);
#else
  movqi instruction required in machine description
#endif
}

/* Return number of insns required to move L bytes by pieces.
   ALIGN (in bytes) is maximum alignment we can assume.  */

static int
move_by_pieces_ninsns (l, align)
     unsigned int l;
     int align;
{
  register int n_insns = 0;

#ifdef STRICT_ALIGNMENT
  if (align > MOVE_MAX || align >= BIGGEST_ALIGNMENT / BITS_PER_UNIT)
    align = MOVE_MAX;
#else
  align = MOVE_MAX;
#endif

#ifdef HAVE_movti
  if (HAVE_movti && align >= GET_MODE_SIZE (TImode))
    n_insns += l / GET_MODE_SIZE (TImode), l %= GET_MODE_SIZE (TImode);
#endif
#ifdef HAVE_movdi
  if (HAVE_movdi && align >= GET_MODE_SIZE (DImode))
    n_insns += l / GET_MODE_SIZE (DImode), l %= GET_MODE_SIZE (DImode);
#endif
#ifdef HAVE_movsi
  if (HAVE_movsi && align >= GET_MODE_SIZE (SImode))
    n_insns += l / GET_MODE_SIZE (SImode), l %= GET_MODE_SIZE (SImode);
#endif
#ifdef HAVE_movhi
  if (HAVE_movhi && align >= GET_MODE_SIZE (HImode))
    n_insns += l / GET_MODE_SIZE (HImode), l %= GET_MODE_SIZE (HImode);
#endif
  n_insns += l;

  return n_insns;
}

/* Subroutine of move_by_pieces.  Move as many bytes as appropriate
   with move instructions for mode MODE.  GENFUN is the gen_... function
   to make a move insn for that mode.  DATA has all the other info.  */

static void
move_by_pieces_1 (genfun, mode, data)
     rtx (*genfun) ();
     enum machine_mode mode;
     struct move_by_pieces *data;
{
  register int size = GET_MODE_SIZE (mode);
  register rtx to1, from1;

#define add_offset(FLAG,X)  \
   (FLAG ? (X) : plus_constant ((X), data->offset))

  while (data->len >= size)
    {
      if (data->reverse) data->offset -= size;

      to1 = change_address (data->to, mode,
			    add_offset (data->autinc_to, data->to_addr));
      from1 = change_address (data->from, mode,
			      add_offset (data->autinc_from, data->from_addr));

#ifdef HAVE_PRE_DECREMENT
      if (data->explicit_inc_to < 0)
	emit_insn (gen_sub2_insn (data->to_addr,
				  gen_rtx (CONST_INT, VOIDmode, size)));
      if (data->explicit_inc_from < 0)
	emit_insn (gen_sub2_insn (data->from_addr,
				  gen_rtx (CONST_INT, VOIDmode, size)));
#endif

      emit_insn (genfun (to1, from1));
#ifdef HAVE_POST_INCREMENT
      if (data->explicit_inc_to > 0)
	emit_insn (gen_add2_insn (data->to_addr,
				  gen_rtx (CONST_INT, VOIDmode, size)));
      if (data->explicit_inc_from > 0)
	emit_insn (gen_add2_insn (data->from_addr,
				  gen_rtx (CONST_INT, VOIDmode, size)));
#endif

      if (! data->reverse) data->offset += size;

      data->len -= size;
    }
}

/* Emit code to move a block Y to a block X.
   This may be done with string-move instructions,
   with multiple scalar move instructions, or with a library call.

   Both X and Y must be MEM rtx's (perhaps inside VOLATILE)
   with mode BLKmode.
   SIZE is an rtx that says how long they are.
   ALIGN is the maximum alignment we can assume they have,
   measured in bytes.  */

static void
emit_block_move (x, y, size, align)
     rtx x, y;
     rtx size;
     int align;
{
  if (GET_MODE (x) != BLKmode)
    abort ();

  if (GET_MODE (y) != BLKmode)
    abort ();

  x = protect_from_queue (x, 1);
  y = protect_from_queue (y, 0);

  if (GET_CODE (x) != MEM)
    abort ();
  if (GET_CODE (y) != MEM)
    abort ();
  if (size == 0)
    abort ();

  if (GET_CODE (size) == CONST_INT
      && (move_by_pieces_ninsns ((unsigned) INTVAL (size), align)
	  < MOVE_RATIO))
    move_by_pieces (x, y, INTVAL (size), align);
  else
    {
#ifdef HAVE_movstrsi
      if (HAVE_movstrsi)
	{
	  emit_insn (gen_movstrsi (x, y, size));
	  return;
	}
#endif
#ifdef HAVE_movstrhi
      if (HAVE_movstrhi
	  && GET_CODE (size) == CONST_INT
	  && ((unsigned) INTVAL (size)
	      < (1 << (GET_MODE_SIZE (HImode) * BITS_PER_UNIT - 1))))
	{
	  emit_insn (gen_movstrhi (x, y, size));
	  return;
	}
#endif

#ifdef TARGET_MEM_FUNCTIONS
      emit_library_call (gen_rtx (SYMBOL_REF, Pmode, "memcpy"),
			 VOIDmode, 3, XEXP (x, 0), Pmode,
			 XEXP (y, 0), Pmode,
			 size, Pmode);
#else
      emit_library_call (gen_rtx (SYMBOL_REF, Pmode, "bcopy"),
			 VOIDmode, 3, XEXP (y, 0), Pmode,
			 XEXP (x, 0), Pmode,
			 size, Pmode);
#endif
    }
}

/* Copy all or part of a BLKmode value X into registers starting at REGNO.
   The number of registers to be filled is NREGS.  */

static void
move_block_to_reg (regno, x, nregs)
     int regno;
     rtx x;
     int nregs;
{
  int i;
  if (GET_CODE (x) == CONST_DOUBLE && x != dconst0_rtx)
    x = force_const_double_mem (x);
  for (i = 0; i < nregs; i++)
    {
      if (GET_CODE (x) == REG)
	emit_move_insn (gen_rtx (REG, SImode, regno + i),
			gen_rtx (SUBREG, SImode, x, i));
      else if (x == dconst0_rtx)
	emit_move_insn (gen_rtx (REG, SImode, regno + i),
			const0_rtx);
      else
	emit_move_insn (gen_rtx (REG, SImode, regno + i),
			gen_rtx (MEM, SImode,
				 plus_constant (XEXP (x, 0),
						i * GET_MODE_SIZE (SImode))));
    }
}

/* Copy all or part of a BLKmode value X out of registers starting at REGNO.
   The number of registers to be filled is NREGS.  */

void
move_block_from_reg (regno, x, nregs)
     int regno;
     rtx x;
     int nregs;
{
  int i;
  for (i = 0; i < nregs; i++)
    {
      if (GET_CODE (x) == REG)
	emit_move_insn (gen_rtx (SUBREG, SImode, x, i),
			gen_rtx (REG, SImode, regno + i));
      else
	emit_move_insn (gen_rtx (MEM, SImode,
				 plus_constant (XEXP (x, 0),
						i * GET_MODE_SIZE (SImode))),
			gen_rtx (REG, SImode, regno + i));
    }
}

/* Mark NREGS consecutive regs, starting at REGNO, as being live now.  */

static void
use_regs (regno, nregs)
     int regno;
     int nregs;
{
  int i;
  for (i = 0; i < nregs; i++)
    emit_insn (gen_rtx (USE, VOIDmode, gen_rtx (REG, SImode, regno + i)));
}

/* Write zeros through the storage of OBJECT.
   If OBJECT has BLKmode, SIZE is its length in bytes.  */

void
clear_storage (object, size)
     rtx object;
     int size;
{
  if (GET_MODE (object) == BLKmode)
    {
#ifdef TARGET_MEM_FUNCTIONS
      emit_library_call (gen_rtx (SYMBOL_REF, Pmode, "memset"),
			 VOIDmode, 3,
			 XEXP (object, 0), Pmode, const0_rtx, Pmode,
			 gen_rtx (CONST_INT, VOIDmode, size), Pmode);
#else
      emit_library_call (gen_rtx (SYMBOL_REF, Pmode, "bzero"),
			 VOIDmode, 2,
			 XEXP (object, 0), Pmode,
			 gen_rtx (CONST_INT, VOIDmode, size), Pmode);
#endif
    }
  else
    emit_move_insn (object, const0_rtx, 0);
}

/* Generate code to copy Y into X.
   Both Y and X must have the same mode, except that
   Y can be a constant with VOIDmode.
   This mode cannot be BLKmode; use emit_block_move for that.

   Return the last instruction emitted.  */

rtx
emit_move_insn (x, y)
     rtx x, y;
{
  enum machine_mode mode = GET_MODE (x);
  x = protect_from_queue (x, 1);
  y = protect_from_queue (y, 0);

  if ((CONSTANT_P (y) || GET_CODE (y) == CONST_DOUBLE)
      && ! LEGITIMATE_CONSTANT_P (y))
    y = force_const_mem (mode, y);

  if (mode == BLKmode)
    abort ();
  if (mov_optab->handlers[(int) mode].insn_code != CODE_FOR_nothing)
    return 
      emit_insn (GEN_FCN (mov_optab->handlers[(int) mode].insn_code) (x, y));
#if 0
  /* It turns out you get much better optimization (in cse and flow)
     if you define movdi and movdf instruction patterns
     even if they must turn into multiple assembler instructions.  */
  else if (GET_MODE_SIZE (mode) >= GET_MODE_SIZE (SImode))
    {
      register int count = GET_MODE_SIZE (mode) / GET_MODE_SIZE (SImode);
      register int i;
      if (GET_CODE (y) == CONST_DOUBLE && y != dconst0_rtx)
	y = force_const_double_mem (y);
      for (i = 0; i < count; i++)
	{
	  rtx x1, y1;
	  if (GET_CODE (x) == REG)
	    x1 = gen_rtx (SUBREG, SImode, x, i);
	  else
	    x1 = gen_rtx (MEM, SImode,
			  memory_address (SImode,
					  plus_constant (XEXP (x, 0),
							 i * GET_MODE_SIZE (SImode))));
	  if (GET_CODE (y) == REG)
	    y1 = gen_rtx (SUBREG, SImode, y, i);
	  else if (y == dconst0_rtx)
	    y1 = const0_rtx;
	  else
	    y1 = gen_rtx (MEM, SImode,
			  memory_address (SImode,
					  plus_constant (XEXP (y, 0),
							 i * GET_MODE_SIZE (SImode))));
	  emit_insn (gen_movsi (protect_from_queue (x1, 1), protect_from_queue (y1, 0)));
	}
    }
#endif
  else
    abort ();
}

/* Pushing data onto the stack.  */

/* Push a block of length SIZE (perhaps variable)
   and return an rtx to address the beginning of the block.
   Note that it is not possible for the value returned to be a QUEUED.
   The value may be stack_pointer_rtx.

   The value we return does not take account of STACK_POINTER_OFFSET,
   so the caller must do so when using the value.  */

static rtx
push_block (size)
     rtx size;
{
  register rtx temp;
  if (CONSTANT_P (size) || GET_CODE (size) == REG)
    anti_adjust_stack (size);
  else
    anti_adjust_stack (copy_to_mode_reg (Pmode, size));
	
#ifdef STACK_GROWS_DOWNWARD
  temp = stack_pointer_rtx;
#else
  temp = gen_rtx (PLUS, Pmode,
		  stack_pointer_rtx,
		  size);
  if (GET_CODE (size) != CONST_INT)
    temp = force_operand (temp, 0);
#endif
  return memory_address (QImode, temp);
}

static rtx
gen_push_operand ()
{
  return gen_rtx (
#ifdef STACK_GROWS_DOWNWARD
		  PRE_DEC,
#else
		  PRE_INC,
#endif
		  Pmode,
		  stack_pointer_rtx);
}

/* Generate code to push X onto the stack, assuming it has mode MODE.
   MODE is redundant except when X is a CONST_INT (since they don't
   carry mode info).
   SIZE is an rtx for the size of data to be copied (in bytes),
   needed only if X is BLKmode.
   ALIGN (in bytes) is maximum alignment we can assume.

   If PARTIAL is nonzero, then copy that many of the first words
   of X into registers starting with REG, and push the rest of X.
   The amount of space pushed is decreased by PARTIAL words,
   rounded *down* to a multiple of PARM_BOUNDARY.
   REG must be a hard register in this case.

   EXTRA is the amount in bytes of extra space to leave next to this arg.

   On a machine that lacks real push insns, ARGS_ADDR is the address of
   the bottom of the argument block for this call.  We use indexing off there
   to store the arg.  On machines with push insns, ARGS_ADDR is 0.

   ARGS_SO_FAR is the size of args previously pushed for this call.  */

static void
emit_push_insn (x, mode, size, align, partial, reg, extra, args_addr, args_so_far)
     register rtx x;
     enum machine_mode mode;
     rtx size;
     int align;
     int partial;
     rtx reg;
     int extra;
     rtx args_addr;
     rtx args_so_far;
{
  rtx xinner;

  xinner = x = protect_from_queue (x, 0);

  /* If part should go in registers, copy that part
     into the appropriate registers.  */
  if (partial > 0)
    move_block_to_reg (REGNO (reg), x, partial);

#ifdef STACK_GROWS_DOWNWARD
  if (extra && args_addr == 0)
    anti_adjust_stack (gen_rtx (CONST_INT, VOIDmode, extra));
#endif

  if (mode == BLKmode)
    {
      register rtx temp;
      int used = partial * UNITS_PER_WORD;
      int offset = used % (PARM_BOUNDARY / BITS_PER_UNIT);

      used -= used % (PARM_BOUNDARY / BITS_PER_UNIT);

      if (size == 0)
	abort ();

      if (partial != 0)
	xinner = change_address (xinner, BLKmode,
				 plus_constant (XEXP (xinner, 0), used));

#ifdef PUSH_ROUNDING
      /* Do it with several push insns if that doesn't take lots of insns
	 and if there is no difficulty with push insns that skip bytes
	 on the stack for alignment purposes.  */
      if (args_addr == 0
	  && GET_CODE (size) == CONST_INT
	  && args_addr == 0
	  && (move_by_pieces_ninsns ((unsigned) INTVAL (size) - used, align)
	      < MOVE_RATIO)
	  && PUSH_ROUNDING (INTVAL (size)) == INTVAL (size))
	move_by_pieces (gen_rtx (MEM, BLKmode, gen_push_operand ()), xinner,
			INTVAL (size) - used, align);
      else
#endif /* PUSH_ROUNDING */
	{
	  /* Otherwise make space on the stack and copy the data
	     to the address of that space.  */

	  /* First deduct part put into registers from the size we need.  */
	  if (partial != 0)
	    {
	      if (GET_CODE (size) == CONST_INT)
		size = gen_rtx (CONST_INT, VOIDmode, INTVAL (size) - used);
	      else
		size = expand_binop (GET_MODE (size), sub_optab, size,
				     gen_rtx (CONST_INT, VOIDmode, used),
				     0, 0, OPTAB_LIB_WIDEN);
	    }

	  /* Get the address of the stack space.  */
	  if (! args_addr)
	    temp = push_block (size);
	  else if (GET_CODE (args_so_far) == CONST_INT)
	    temp = memory_address (BLKmode,
				   plus_constant (args_addr,
						  offset + INTVAL (args_so_far)));
	  else
	    temp = memory_address (BLKmode,
				   plus_constant (gen_rtx (PLUS, Pmode,
							   args_addr, args_so_far),
						  offset));


	  /* TEMP is the address of the block.  Copy the data there.  */
	  if (GET_CODE (size) == CONST_INT
	      && (move_by_pieces_ninsns ((unsigned) INTVAL (size), align)
		  < MOVE_RATIO))
	    {
	      move_by_pieces (gen_rtx (MEM, BLKmode, temp), xinner,
			      INTVAL (size), align);
	      return;
	    }
#ifdef HAVE_movstrsi
	  if (HAVE_movstrsi)
	    {
	      emit_insn (gen_movstrsi (gen_rtx (MEM, BLKmode, temp), x, size));
	      return;
	    }
#endif
#ifdef HAVE_movstrhi
	  if (HAVE_movstrhi
	      && GET_CODE (size) == CONST_INT
	      && ((unsigned) INTVAL (size)
		  < (1 << (GET_MODE_SIZE (HImode) * BITS_PER_UNIT - 1))))
	    {
	      emit_insn (gen_movstrhi (gen_rtx (MEM, BLKmode, temp),
				       x, size));
	      return;
	    }
#endif

	  if (reg_mentioned_p (stack_pointer_rtx, temp))
	    {
	      /* Correct TEMP so it holds what will be a description of
		 the address to copy to, valid after one arg is pushed.  */
	      int xsize = ((PUSH_ROUNDING (GET_MODE_SIZE (Pmode))
			    + PARM_BOUNDARY / BITS_PER_UNIT - 1)
			   / (PARM_BOUNDARY / BITS_PER_UNIT)
			   * (PARM_BOUNDARY / BITS_PER_UNIT));
#ifdef STACK_GROWS_DOWNWARD
	      temp = plus_constant (temp, xsize);
#else
	      temp = plus_constant (temp, xsize);
#endif
	    }

	  /* Make current_args_size nonzero around the library call
	     to force it to pop the bcopy-arguments right away.  */
	  current_args_size += 1;
#ifdef TARGET_MEM_FUNCTIONS
	  emit_library_call (gen_rtx (SYMBOL_REF, Pmode, "memcpy"),
			     VOIDmode, 3, temp, Pmode, XEXP (xinner, 0), Pmode,
			     size, Pmode);
#else
	  emit_library_call (gen_rtx (SYMBOL_REF, Pmode, "bcopy"),
			     VOIDmode, 3, XEXP (xinner, 0), Pmode, temp, Pmode,
			     size, Pmode);
#endif
	  current_args_size -= 1;
	}
    }
  else if (partial > 0)
    {
      int size = GET_MODE_SIZE (mode) / UNITS_PER_WORD;
      int i;
      int used = partial * UNITS_PER_WORD;
      /* # words of start of argument 
	 that we must make space for but need not store.  */
      int skip = partial % (PARM_BOUNDARY / BITS_PER_WORD);
      int args_offset = INTVAL (args_so_far);

      /* If we make space by pushing it, we might as well push
	 the real data.  Otherwise, we can leave SKIP nonzero
	 and leave the space uninitialized.  */
      if (args_addr == 0)
	skip = 0;

      /* Deduct all the rest of PARTIAL words from SIZE in any case.
	 This is space that we don't even allocate in the stack.  */
      used -= used % (PARM_BOUNDARY / BITS_PER_UNIT);
      size -= used / UNITS_PER_WORD;

      if (GET_CODE (x) == CONST_DOUBLE && x != dconst0_rtx)
	x = force_const_double_mem (x);

#ifndef PUSH_ARGS_REVERSED
      for (i = skip; i < size; i++)
#else
      for (i = size - 1; i >= skip; i--)
#endif
	if (GET_CODE (x) == MEM)
	  emit_push_insn (gen_rtx (MEM, SImode,
				   plus_constant (XEXP (x, 0),
						  i * UNITS_PER_WORD)),
			  SImode, 0, align, 0, 0, 0, args_addr,
			  gen_rtx (CONST_INT, VOIDmode,
				   args_offset + i * UNITS_PER_WORD));
	else if (GET_CODE (x) == REG)
	  emit_push_insn (gen_rtx (SUBREG, SImode, x, i),
			  SImode, 0, align, 0, 0, 0, args_addr,
			  gen_rtx (CONST_INT, VOIDmode,
				   args_offset + i * UNITS_PER_WORD));
	else if (x == dconst0_rtx)
	  emit_push_insn (const0_rtx,
			  SImode, 0, align, 0, 0, 0, args_addr,
			  gen_rtx (CONST_INT, VOIDmode,
				   args_offset + i * UNITS_PER_WORD));
	else
	  abort ();
    }
  else
    {
      rtx addr;
#ifdef PUSH_ROUNDING
      if (args_addr == 0)
	addr = gen_push_operand ();
      else
#endif
	if (GET_CODE (args_so_far) == CONST_INT)
	  addr
	    = memory_address (mode,
			      plus_constant (args_addr, INTVAL (args_so_far)));
      else
	addr = memory_address (mode, gen_rtx (PLUS, Pmode, args_addr,
					      args_so_far));

      emit_move_insn (gen_rtx (MEM, mode, addr), x);
    }

#ifndef STACK_GROWS_DOWNWARD
  if (extra && args_addr == 0)
    anti_adjust_stack (gen_rtx (CONST_INT, VOIDmode, extra));
#endif
}

/* Output a library call to function FUN (a SYMBOL_REF rtx)
   for a value of mode OUTMODE
   with NARGS different arguments, passed as alternating rtx values
   and machine_modes to convert them to.
   The rtx values should have been passed through protect_from_queue already.  */

void
emit_library_call (va_alist)
     va_dcl
{
  register va_list p;
  register int args_size = 0;
  register int argnum;
  enum machine_mode outmode;
  int nargs;
  rtx fun;
  rtx orgfun;
  int inc;
  int count;
  rtx *regvec;
  rtx argblock = 0;
  CUMULATIVE_ARGS args_so_far;
  struct arg { rtx value; enum machine_mode mode; };
  struct arg *argvec;
  int old_args_size = current_args_size;

  va_start (p);
  orgfun = fun = va_arg (p, rtx);
  outmode = va_arg (p, enum machine_mode);
  nargs = va_arg (p, int);

  regvec = (rtx *) alloca (nargs * sizeof (rtx));

  /* Copy all the libcall-arguments out of the varargs data
     and into a vector ARGVEC.  */
  argvec = (struct arg *) alloca (nargs * sizeof (struct arg));
  for (count = 0; count < nargs; count++)
    {
      argvec[count].value = va_arg (p, rtx);
      argvec[count].mode = va_arg (p, enum machine_mode);
    }
  va_end (p);

  /* If we have no actual push instructions, make space for all the args
     right now.  */
#ifndef PUSH_ROUNDING
  INIT_CUMULATIVE_ARGS (args_so_far, (tree)0);
  for (count = 0; count < nargs; count++)
    {
      register enum machine_mode mode = argvec[count].mode;
      register rtx reg;
      register int partial;

      reg = FUNCTION_ARG (args_so_far, mode, 0, 1);
#ifdef FUNCTION_ARG_PARTIAL_NREGS
      partial = FUNCTION_ARG_PARTIAL_NREGS (args_so_far, mode, 0, 1);
#else
      partial = 0;
#endif
      if (reg == 0 || partial != 0)
	args_size += GET_MODE_SIZE (mode);
      if (partial != 0)
	args_size -= partial * GET_MODE_SIZE (SImode);
      FUNCTION_ARG_ADVANCE (args_so_far, mode, 0, 1);
    }

  if (args_size != 0)
    argblock
      = push_block (round_push (gen_rtx (CONST_INT, VOIDmode, args_size)));
#endif

  INIT_CUMULATIVE_ARGS (args_so_far, (tree)0);

#ifdef PUSH_ARGS_REVERSED
  inc = -1;
  argnum = nargs - 1;
#else
  inc = 1;
  argnum = 0;
#endif
  args_size = 0;

  for (count = 0; count < nargs; count++, argnum += inc)
    {
      register enum machine_mode mode = argvec[argnum].mode;
      register rtx val = argvec[argnum].value;
      rtx reg;
      int partial;
      int arg_size;

      /* Convert the arg value to the mode the library wants.  */
      /* ??? It is wrong to do it here; must do it earlier
	 where we know the signedness of the arg.  */
      if (GET_MODE (val) != mode && GET_MODE (val) != VOIDmode)
	{
	  val = gen_reg_rtx (mode);
	  convert_move (val, argvec[argnum].value, 0);
	}
      reg = FUNCTION_ARG (args_so_far, mode, 0, 1);
      regvec[argnum] = reg;
#ifdef FUNCTION_ARG_PARTIAL_NREGS
      partial = FUNCTION_ARG_PARTIAL_NREGS (args_so_far, mode, 0, 1);
#else
      partial = 0;
#endif

      if (reg != 0 && partial == 0)
	emit_move_insn (reg, val);
      else
	emit_push_insn (val, mode, 0, 0, partial, reg, 0, argblock,
			gen_rtx (CONST_INT, VOIDmode, args_size));

      /* Compute size of stack space used by this argument.  */
      if (reg == 0 || partial != 0)
	arg_size = GET_MODE_SIZE (mode);
      else
	arg_size = 0;
      if (partial != 0)
	arg_size
	  -= ((partial * UNITS_PER_WORD)
	      / (PARM_BOUNDARY / BITS_PER_UNIT)
	      * (PARM_BOUNDARY / BITS_PER_UNIT));

      args_size += arg_size;
      current_args_size += arg_size;
      FUNCTION_ARG_ADVANCE (args_so_far, mode, 0, 1);
    }

  emit_queue ();

  fun = prepare_call_address (fun, 0);

  /* Any regs containing parms remain in use through the call.
     ??? This is not quite correct, since it doesn't indicate
     that they are in use immediately before the call insn.
     Currently that doesn't matter since explicitly-used regs
     won't be used for reloading.  But if the reloader becomes smarter,
     this will have to change somehow.  */
  for (count = 0; count < nargs; count++)
    if (regvec[count] != 0)
      emit_insn (gen_rtx (USE, VOIDmode, regvec[count]));

#ifdef STACK_BOUNDARY
  args_size = (args_size + STACK_BYTES - 1) / STACK_BYTES * STACK_BYTES;
#endif

  /* Don't allow popping to be deferred, since then
     cse'ing of library calls could delete a call and leave the pop.  */
  current_args_size += 1;
  emit_call_1 (fun, get_identifier (XSTR (orgfun, 0)), args_size,
	       FUNCTION_ARG (args_so_far, VOIDmode, void_type_node, 1),
	       outmode != VOIDmode ? hard_libcall_value (outmode) : 0,
	       old_args_size + 1);
  current_args_size -= 1;
}

/* Expand an assignment that stores the value of FROM into TO.
   If WANT_VALUE is nonzero, return an rtx for the value of TO.
   (This may contain a QUEUED rtx.)
   Otherwise, the returned value is not meaningful.

   SUGGEST_REG is no longer actually used.
   It used to mean, copy the value through a register
   and return that register, if that is possible.
   But now we do this if WANT_VALUE.

   If the value stored is a constant, we return the constant.  */

rtx
expand_assignment (to, from, want_value, suggest_reg)
     tree to, from;
     int want_value;
     int suggest_reg;
{
  register rtx to_rtx = 0;

  /* Don't crash if the lhs of the assignment was erroneous.  */

  if (TREE_CODE (to) == ERROR_MARK)
    return expand_expr (from, 0, VOIDmode, 0);

  /* Assignment of a structure component needs special treatment
     if the structure component's rtx is not simply a MEM.
     Assignment of an array element at a constant index
     has the same problem.  */

  if (TREE_CODE (to) == COMPONENT_REF
      || (TREE_CODE (to) == ARRAY_REF
	  && TREE_CODE (TREE_OPERAND (to, 1)) == INTEGER_CST
	  && TREE_CODE (TYPE_SIZE (TREE_TYPE (to))) == INTEGER_CST))
    {
      register enum machine_mode mode1;
      int bitsize;
      int volstruct = 0;
      tree tem = to;
      int bitpos = 0;
      int unsignedp;

      if (TREE_CODE (to) == COMPONENT_REF)
	{
	  tree field = TREE_OPERAND (to, 1);
	  bitsize = TREE_INT_CST_LOW (DECL_SIZE (field)) * DECL_SIZE_UNIT (field);
	  mode1 = DECL_MODE (TREE_OPERAND (to, 1));
	  unsignedp = TREE_UNSIGNED (field);
	}
      else
	{
	  mode1 = TYPE_MODE (TREE_TYPE (to));
	  bitsize = GET_MODE_BITSIZE (mode1);
	  unsignedp = TREE_UNSIGNED (TREE_TYPE (to));
	}

      /* Compute cumulative bit-offset for nested component-refs
	 and array-refs, and find the ultimate containing object.  */

      while (1)
	{
	  if (TREE_CODE (tem) == COMPONENT_REF)
	    {
	      bitpos += DECL_OFFSET (TREE_OPERAND (tem, 1));
	      if (TREE_THIS_VOLATILE (tem))
		volstruct = 1;
	    }
	  else if (TREE_CODE (tem) == ARRAY_REF
		   && TREE_CODE (TREE_OPERAND (tem, 1)) == INTEGER_CST
		   && TREE_CODE (TYPE_SIZE (TREE_TYPE (tem))) == INTEGER_CST)
	    {
	      bitpos += (TREE_INT_CST_LOW (TREE_OPERAND (tem, 1))
			 * TREE_INT_CST_LOW (TYPE_SIZE (TREE_TYPE (tem)))
			 * TYPE_SIZE_UNIT (TREE_TYPE (tem)));
	    }
	  else
	    break;
	  tem = TREE_OPERAND (tem, 0);
	}

      /* If we are going to use store_bit_field and extract_bit_field,
	 make sure to_rtx will be safe for multiple use.  */
      if (mode1 == BImode && want_value)
	tem = stabilize_reference (tem);

      to_rtx = expand_expr (tem, 0, VOIDmode, 0);

      return store_field (to_rtx, bitsize, bitpos, mode1, from,
			  want_value ? TYPE_MODE (TREE_TYPE (to)) : VOIDmode,
			  unsignedp);
    }

  /* Ordinary treatment.  Expand TO to get a REG or MEM rtx.
     Don't re-expand if it was expanded already (in COMPONENT_REF case).  */

  if (to_rtx == 0)
    to_rtx = expand_expr (to, 0, VOIDmode, 0);

  /* Compute FROM and store the value in the rtx we got.  */

  return store_expr (from, to_rtx, want_value);
}

/* Generate code for computing expression EXP,
   and storing the value into TARGET.
   Returns TARGET or an equivalent value.
   TARGET may contain a QUEUED rtx.

   If SUGGEST_REG is nonzero, copy the value through a register
   and return that register, if that is possible.

   If the value stored is a constant, we return the constant.  */

rtx
store_expr (exp, target, suggest_reg)
     register tree exp;
     register rtx target;
     int suggest_reg;
{
  register rtx temp;
  int dont_return_target = 0;

  /* Copying a non-constant CONSTRUCTOR needs special treatment.  */

  if (TREE_CODE (exp) == CONSTRUCTOR && ! TREE_LITERAL (exp))
    {
      store_constructor (exp, target);
      return target;
    }

  if (suggest_reg && GET_CODE (target) == MEM && GET_MODE (target) != BLKmode)
    /* If target is in memory and caller wants value in a register instead,
       arrange that.  Pass TARGET as target for expand_expr so that,
       if EXP is another assignment, SUGGEST_REG will be nonzero for it.
       We know expand_expr will not use the target in that case.  */
    {
      temp = expand_expr (exp, cse_not_expected ? 0 : target,
			  GET_MODE (target), 0);
      if (GET_MODE (temp) != BLKmode && GET_MODE (temp) != VOIDmode)
	temp = copy_to_reg (temp);
      dont_return_target = 1;
    }
  else if (queued_subexp_p (target))
    /* If target contains a postincrement, it is not safe
       to use as the returned value.  It would access the wrong
       place by the time the queued increment gets output.
       So copy the value through a temporary and use that temp
       as the result.  */
    {
      temp = expand_expr (exp, 0, GET_MODE (target), 0);
      if (GET_MODE (temp) != BLKmode && GET_MODE (temp) != VOIDmode)
	temp = copy_to_reg (temp);
      dont_return_target = 1;
    }
  else
    {
      temp = expand_expr (exp, target, GET_MODE (target), 0);
      /* DO return TARGET if it's a specified hardware register.
	 expand_return relies on this.  */
      if (!(target && GET_CODE (target) == REG
	    && REGNO (target) < FIRST_PSEUDO_REGISTER)
	  && (CONSTANT_P (temp) || GET_CODE (temp) == CONST_DOUBLE))
	dont_return_target = 1;
    }

  /* If value was not generated in the target, store it there.  */

  if (temp != target && TREE_CODE (exp) != ERROR_MARK)
    {
      target = protect_from_queue (target, 1);
      if (GET_MODE (temp) != GET_MODE (target)
	  && GET_MODE (temp) != VOIDmode)
	{
	  int unsignedp = TREE_UNSIGNED (TREE_TYPE (exp));
	  if (dont_return_target)
	    temp = convert_to_mode (GET_MODE (target), temp, unsignedp);
	  else
	    convert_move (target, temp, unsignedp);
	}

      else if (GET_MODE (temp) == BLKmode)
	emit_block_move (target, temp, expr_size (exp),
			 TYPE_ALIGN (TREE_TYPE (exp)) / BITS_PER_UNIT);
      else
	emit_move_insn (target, temp);
    }
  if (dont_return_target)
    return temp;
  return target;
}

/* Store the value of constructor EXP into the rtx TARGET.
   TARGET is either a REG or a MEM.  */

static void
store_constructor (exp, target)
     tree exp;
     rtx target;
{
  if (TREE_CODE (TREE_TYPE (exp)) == RECORD_TYPE)
    {
      register tree elt;

      /* If the constructor has fewer fields than the structure,
	 clear the whole structure first.  */

      if (list_length (CONSTRUCTOR_ELTS (exp))
	  != list_length (TYPE_FIELDS (TREE_TYPE (exp))))
	clear_storage (target, int_size_in_bytes (TREE_TYPE (exp)));
      else
	/* Inform later passes that the old value is dead.  */
	emit_insn (gen_rtx (CLOBBER, VOIDmode, target));

      /* Store each element of the constructor into
	 the corresponding field of TARGET.  */

      for (elt = CONSTRUCTOR_ELTS (exp); elt; elt = TREE_CHAIN (elt))
	{
	  register tree field = TREE_PURPOSE (elt);
	  register enum machine_mode mode;
	  int bitsize;
	  int bitpos;
	  int unsignedp;

	  bitsize = TREE_INT_CST_LOW (DECL_SIZE (field)) * DECL_SIZE_UNIT (field);
	  mode = DECL_MODE (field);
	  unsignedp = TREE_UNSIGNED (field);

	  bitpos = DECL_OFFSET (field);

	  store_field (target, bitsize, bitpos, mode, TREE_VALUE (elt),
		       VOIDmode, 0);
	}
    }
  else if (TREE_CODE (TREE_TYPE (exp)) == ARRAY_TYPE)
    {
      register tree elt;
      register int i;
      tree domain = TYPE_DOMAIN (TREE_TYPE (exp));
      int minelt = TREE_INT_CST_LOW (TYPE_MIN_VALUE (domain));
      int maxelt = TREE_INT_CST_LOW (TYPE_MAX_VALUE (domain));
      tree elttype = TREE_TYPE (TREE_TYPE (exp));

      /* If the constructor has fewer fields than the structure,
	 clear the whole structure first.  */

      if (list_length (CONSTRUCTOR_ELTS (exp)) < maxelt - minelt + 1)
	clear_storage (target, maxelt - minelt + 1);
      else
	/* Inform later passes that the old value is dead.  */
	emit_insn (gen_rtx (CLOBBER, VOIDmode, target));

      /* Store each element of the constructor into
	 the corresponding element of TARGET, determined
	 by counting the elements.  */
      for (elt = CONSTRUCTOR_ELTS (exp), i = 0;
	   elt;
	   elt = TREE_CHAIN (elt), i++)
	{
	  register enum machine_mode mode;
	  int bitsize;
	  int bitpos;
	  int unsignedp;

	  mode = TYPE_MODE (elttype);
	  bitsize = GET_MODE_BITSIZE (mode);
	  unsignedp = TREE_UNSIGNED (elttype);

	  bitpos = (i * TREE_INT_CST_LOW (TYPE_SIZE (elttype))
		    * TYPE_SIZE_UNIT (elttype));

	  store_field (target, bitsize, bitpos, mode, TREE_VALUE (elt),
		       VOIDmode, 0);
	}
    }
}

/* Store the value of EXP (an expression tree)
   into a subfield of TARGET which has mode MODE and occupies
   BITSIZE bits, starting BITPOS bits from the start of TARGET.

   If VALUE_MODE is VOIDmode, return nothing in particular.
   UNSIGNEDP is not used in this case.

   Otherwise, return an rtx for the value stored.  This rtx
   has mode VALUE_MODE if that is convenient to do.
   In this case, UNSIGNEDP must be nonzero if the value is an unsigned type.  */

static rtx
store_field (target, bitsize, bitpos, mode, exp, value_mode, unsignedp)
     rtx target;
     int bitsize, bitpos;
     enum machine_mode mode;
     tree exp;
     enum machine_mode value_mode;
     int unsignedp;
{
  /* If the structure is in a register or if the component
     is a bit field, we cannot use addressing to access it.
     Use bit-field techniques or SUBREG to store in it.  */

  if (mode == BImode || GET_CODE (target) == REG
      || GET_CODE (target) == SUBREG)
    {
      store_bit_field (target, bitsize, bitpos,
		       mode,
		       expand_expr (exp, 0, VOIDmode, 0));
      if (value_mode != VOIDmode)
	return extract_bit_field (target, bitsize, bitpos, unsignedp,
				  0, value_mode, 0);
      return const0_rtx;
    }
  else
    {
      rtx addr = XEXP (target, 0);
      rtx to_rtx;

      /* If a value is wanted, it must be the lhs;
	 so make the address stable for multiple use.  */

      if (value_mode != VOIDmode && GET_CODE (addr) != REG
	  && ! CONSTANT_ADDRESS_P (addr))
	addr = copy_to_reg (addr);

      /* Now build a reference to just the desired component.  */

      to_rtx = change_address (target, mode,
			       plus_constant (addr,
					      (bitpos / BITS_PER_UNIT)));
      to_rtx->in_struct = 1;

      return store_expr (exp, to_rtx, value_mode != VOIDmode);
    }
}

/* Given an rtx VALUE that may contain additions and multiplications,
   return an equivalent value that just refers to a register or memory.
   This is done by generating instructions to perform the arithmetic
   and returning a pseudo-register containing the value.  */

rtx
force_operand (value, target)
     rtx value, target;
{
  register optab binoptab = 0;
  register rtx op2;
  /* Use subtarget as the target for operand 0 of a binary operation.  */
  register rtx subtarget = (target != 0 && GET_CODE (target) == REG ? target : 0);

  if (GET_CODE (value) == PLUS)
    binoptab = add_optab;
  else if (GET_CODE (value) == MINUS)
    binoptab = sub_optab;
  else if (GET_CODE (value) == MULT)
    {
      op2 = XEXP (value, 1);
      if (!CONSTANT_P (op2)
	  && !(GET_CODE (op2) == REG && op2 != subtarget))
	subtarget = 0;
      return expand_mult (GET_MODE (value),
			  force_operand (XEXP (value, 0), subtarget),
			  force_operand (op2, 0),
			  target, 0);
    }

  if (binoptab)
    {
      op2 = XEXP (value, 1);
      if (!CONSTANT_P (op2)
	  && !(GET_CODE (op2) == REG && op2 != subtarget))
	subtarget = 0;
      if (binoptab == sub_optab
	  && GET_CODE (op2) == CONST_INT && INTVAL (op2) < 0)
	{
	  binoptab = add_optab;
	  op2 = gen_rtx (CONST_INT, VOIDmode, - INTVAL (op2));
	}
      return expand_binop (GET_MODE (value), binoptab,
			   force_operand (XEXP (value, 0), subtarget),
			   force_operand (op2, 0),
			   target, 0, OPTAB_LIB_WIDEN);
      /* We give UNSIGNEP = 0 to expand_binop
	 because the only operations we are expanding here are signed ones.  */
    }
  return value;
}

/* expand_expr: generate code for computing expression EXP.
   An rtx for the computed value is returned.

   The value may be stored in TARGET if TARGET is nonzero.
   TARGET is just a suggestion; callers must assume that
   the rtx returned may not be the same as TARGET.

   If TARGET is CONST0_RTX, it means that the value will be ignored.

   If TMODE is not VOIDmode, it suggests generating the
   result in mode TMODE.  But this is done only when convenient.
   Otherwise, TMODE is ignored and the value generated in its natural mode.
   TMODE is just a suggestion; callers must assume that
   the rtx returned may not have mode TMODE.

   If MODIFIER is EXPAND_SUM then when EXP is an addition
   we can return an rtx of the form (MULT (REG ...) (CONST_INT ...))
   or a nest of (PLUS ...) and (MINUS ...) where the terms are
   products as above, or REG or MEM, or constant.
   Ordinarily in such cases we would output mul or add instructions
   and then return a pseudo reg containing the sum.

   If MODIFIER is EXPAND_CONST_ADDRESS then it is ok to return
   a MEM rtx whose address is a constant that isn't a legitimate address.  */

/* Subroutine of expand_expr:
   return the target to use when recursively expanding
   the first operand of an arithmetic operation.  */

static rtx
validate_subtarget (subtarget, otherop)
     rtx subtarget;
     tree otherop;
{
  if (TREE_LITERAL (otherop))
    return subtarget;
  if (TREE_CODE (otherop) == VAR_DECL
      && DECL_RTL (otherop) != subtarget)
    return subtarget;
  return 0;
}

rtx
expand_expr (exp, target, tmode, modifier)
     register tree exp;
     rtx target;
     enum machine_mode tmode;
     enum expand_modifier modifier;
{
  register rtx op0, op1, temp;
  tree type = TREE_TYPE (exp);
  register enum machine_mode mode = TYPE_MODE (type);
  register enum tree_code code = TREE_CODE (exp);
  optab this_optab;
  int negate_1;
  /* Use subtarget as the target for operand 0 of a binary operation.  */
  rtx subtarget = (target != 0 && GET_CODE (target) == REG ? target : 0);
  rtx original_target = target;
  int ignore = target == const0_rtx;

  if (ignore) target = 0, original_target = 0;

  /* If will do cse, generate all results into registers
     since 1) that allows cse to find more things
     and 2) otherwise cse could produce an insn the machine
     cannot support.  */

  if (! cse_not_expected && mode != BLKmode)
    target = subtarget;

  /* No sense saving up arithmetic to be done
     if it's all in the wrong mode to form part of an address.
     And force_operand won't know whether to sign-extend or zero-extend.  */

  if (mode != Pmode && modifier == EXPAND_SUM)
    modifier = (enum expand_modifier) 0;

  switch (code)
    {
    case PARM_DECL:
      if (DECL_RTL (exp) == 0)
	{
	  error_with_decl (exp, "prior parameter's size depends on `%s'");
	  return const0_rtx;
	}

    case FUNCTION_DECL:
    case VAR_DECL:
    case RESULT_DECL:
      if (DECL_RTL (exp) == 0)
	abort ();
      if (GET_CODE (DECL_RTL (exp)) == SYMBOL_REF)
	abort ();
      if (GET_CODE (DECL_RTL (exp)) == MEM
	  && modifier != EXPAND_CONST_ADDRESS)
	{
	  /* DECL_RTL probably contains a constant address.
	     On RISC machines where a constant address isn't valid,
	     make some insns to get that address into a register.  */
	  if (!memory_address_p (DECL_MODE (exp), XEXP (DECL_RTL (exp), 0)))
	    return change_address (DECL_RTL (exp), VOIDmode,
				   copy_rtx (XEXP (DECL_RTL (exp), 0)));
	}
      return DECL_RTL (exp);

    case INTEGER_CST:
      return gen_rtx (CONST_INT, VOIDmode, TREE_INT_CST_LOW (exp));

    case CONST_DECL:
      return expand_expr (DECL_INITIAL (exp), target, VOIDmode, 0);

    case REAL_CST:
      if (TREE_CST_RTL (exp))
	return TREE_CST_RTL (exp);
      /* If optimized, generate immediate float
	 which will be turned into memory float if necessary.  */
      if (!cse_not_expected)
	return immed_real_const (exp);
      output_constant_def (exp);
      return TREE_CST_RTL (exp);

    case COMPLEX_CST:
    case STRING_CST:
      if (TREE_CST_RTL (exp))
	return TREE_CST_RTL (exp);
      output_constant_def (exp);
      return TREE_CST_RTL (exp);

    case SAVE_EXPR:
      if (SAVE_EXPR_RTL (exp) == 0)
	{
	  SAVE_EXPR_RTL (exp) = gen_reg_rtx (mode);
	  store_expr (TREE_OPERAND (exp, 0), SAVE_EXPR_RTL (exp), 0);
	}
      /* Don't let the same rtl node appear in two places.  */
      return SAVE_EXPR_RTL (exp);

    case RTL_EXPR:
      emit_insn (RTL_EXPR_SEQUENCE (exp));
      return RTL_EXPR_RTL (exp);

    case CONSTRUCTOR:
      /* All elts simple constants => refer to a constant in memory.  */
      if (TREE_STATIC (exp))
	/* For aggregate types with non-BLKmode modes,
	   this should ideally construct a CONST_INT.  */
	return output_constant_def (exp);

      if (ignore)
	{
	  tree elt;
	  for (elt = CONSTRUCTOR_ELTS (exp); elt; elt = TREE_CHAIN (elt))
	    expand_expr (TREE_VALUE (elt), const0_rtx, VOIDmode, 0);
	  return const0_rtx;
	}
      else
	{
	  if (target == 0)
	    target = gen_rtx (MEM, TYPE_MODE (TREE_TYPE (exp)),
			      get_structure_value_addr (expr_size (exp)));
	  store_expr (exp, target, 0);
	  return target;
	}

    case INDIRECT_REF:
      {
	tree exp1 = TREE_OPERAND (exp, 0);
	tree exp2;

	/* A SAVE_EXPR as the address in an INDIRECT_EXPR is generated
	   for  *PTR += ANYTHING  where PTR is put inside the SAVE_EXPR.
	   This code has the same general effect as simply doing
	   expand_expr on the save expr, except that the expression PTR
	   is computed for use as a memory address.  This means different
	   code, suitable for indexing, may be generated.  */
	if (TREE_CODE (exp1) == SAVE_EXPR
	    && SAVE_EXPR_RTL (exp1) == 0
	    && TREE_CODE (exp2 = TREE_OPERAND (exp1, 0)) != ERROR_MARK
	    && TYPE_MODE (TREE_TYPE (exp1)) == Pmode
	    && TYPE_MODE (TREE_TYPE (exp2)) == Pmode)
	  {
	    temp = expand_expr (TREE_OPERAND (exp1, 0), 0, VOIDmode, EXPAND_SUM);
	    op0 = memory_address (mode, temp);
	    op0 = copy_all_regs (op0);
	    SAVE_EXPR_RTL (exp1) = op0;
	  }
	else
	  {
	    op0 = expand_expr (TREE_OPERAND (exp, 0), 0, VOIDmode, EXPAND_SUM);
	    op0 = memory_address (mode, op0);
	  }
      }
      temp = gen_rtx (MEM, mode, op0);
      /* If address was computed by addition,
	 mark this as an element of an aggregate.  */
      if (TREE_CODE (TREE_OPERAND (exp, 0)) == PLUS_EXPR
	  || (TREE_CODE (TREE_OPERAND (exp, 0)) == SAVE_EXPR
	      && TREE_CODE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)) == PLUS_EXPR))
	temp->in_struct = 1;
      temp->volatil = TREE_THIS_VOLATILE (exp) | flag_volatile;
      temp->unchanging = TREE_READONLY (exp);
      return temp;

    case ARRAY_REF:
      if (TREE_CODE (TREE_OPERAND (exp, 1)) != INTEGER_CST
	  || TREE_CODE (TYPE_SIZE (TREE_TYPE (exp))) != INTEGER_CST)
	{
	  /* Nonconstant array index or nonconstant element size.
	     Generate the tree for *(&array+index) and expand that,
	     except do it in a language-independent way
	     and don't complain about non-lvalue arrays.
	     `mark_addressable' should already have been called
	     for any array for which this case will be reached.  */

	  tree array_adr = build (ADDR_EXPR, TYPE_POINTER_TO (type),
				  TREE_OPERAND (exp, 0));
	  tree index = TREE_OPERAND (exp, 1);
	  tree elt;

	  /* Convert the integer argument to a type the same size as a pointer
	     so the multiply won't overflow spuriously.  */
	  if (TYPE_PRECISION (TREE_TYPE (index)) != POINTER_SIZE)
	    index = convert (type_for_size (POINTER_SIZE, 0), index);

	  /* The array address isn't volatile even if the array is.  */
	  TREE_VOLATILE (array_adr) = 0;

	  elt = build (INDIRECT_REF, type,
		       fold (build (PLUS_EXPR, TYPE_POINTER_TO (type),
				    array_adr,
				    fold (build (MULT_EXPR,
						 TYPE_POINTER_TO (type),
						 index, size_in_bytes (type))))));

	  return expand_expr (elt, target, tmode, modifier);
	}
      /* Treat array-ref with constant index as a component-ref.  */

    case COMPONENT_REF:
      {
	register enum machine_mode mode1;
	int volstruct = 0;
	tree dbg1 = TREE_OPERAND (exp, 0);  /* For debugging */
	int bitsize;
	tree tem = exp;
	int bitpos = 0;
	int unsignedp;

	if (TREE_CODE (exp) == COMPONENT_REF)
	  {
	    tree field = TREE_OPERAND (exp, 1);
	    bitsize = TREE_INT_CST_LOW (DECL_SIZE (field)) * DECL_SIZE_UNIT (field);
	    mode1 = DECL_MODE (TREE_OPERAND (exp, 1));
	    unsignedp = TREE_UNSIGNED (field);
	  }
	else
	  {
	    mode1 = TYPE_MODE (TREE_TYPE (exp));
	    bitsize = GET_MODE_BITSIZE (mode1);
	    unsignedp = TREE_UNSIGNED (TREE_TYPE (exp));
	  }

	/* Compute cumulative bit-offset for nested component-refs
	   and array-refs, and find the ultimate containing object.  */

	while (1)
	  {
	    if (TREE_CODE (tem) == COMPONENT_REF)
	      {
		bitpos += DECL_OFFSET (TREE_OPERAND (tem, 1));
		if (TREE_THIS_VOLATILE (tem))
		  volstruct = 1;
	      }
	    else if (TREE_CODE (tem) == ARRAY_REF
		     && TREE_CODE (TREE_OPERAND (tem, 1)) == INTEGER_CST
		     && TREE_CODE (TYPE_SIZE (TREE_TYPE (tem))) == INTEGER_CST)
	      {
		bitpos += (TREE_INT_CST_LOW (TREE_OPERAND (tem, 1))
			   * TREE_INT_CST_LOW (TYPE_SIZE (TREE_TYPE (tem)))
			   * TYPE_SIZE_UNIT (TREE_TYPE (tem)));
	      }
	    else
	      break;
	    tem = TREE_OPERAND (tem, 0);
	  }

	op0 = expand_expr (tem, 0, VOIDmode,
			   (modifier == EXPAND_CONST_ADDRESS
			    ? modifier : EXPAND_NORMAL));

	if (mode1 == BImode || GET_CODE (op0) == REG
	    || GET_CODE (op0) == SUBREG)
	  {
	    return extract_bit_field (op0, bitsize, bitpos, unsignedp,
				      target, mode, tmode);
	  }
	/* Get a reference to just this component.  */
	if (modifier == EXPAND_CONST_ADDRESS)
	  op0 = gen_rtx (MEM, mode1, plus_constant (XEXP (op0, 0),
						    (bitpos / BITS_PER_UNIT)));
	else
	  op0 = change_address (op0, mode1,
				plus_constant (XEXP (op0, 0),
					       (bitpos / BITS_PER_UNIT)));
	op0->in_struct = 1;
	op0->volatil = volstruct;
	/* If OP0 is in the shared structure-value stack slot,
	   and it is not BLKmode, copy it into a register.
	   The shared slot may be clobbered at any time by another call.
	   BLKmode is safe because our caller will either copy the value away
	   or take another component and come back here.  */
	if (mode != BLKmode
	    && TREE_CODE (TREE_OPERAND (exp, 0)) == CALL_EXPR
	    && TYPE_MODE (TREE_TYPE (TREE_OPERAND (exp, 0))) == BLKmode)
	  op0 = copy_to_reg (op0);
	if (mode == mode1 || mode1 == BLKmode || mode1 == tmode)
	  return op0;
	if (target == 0)
	  target = gen_reg_rtx (tmode != VOIDmode ? tmode : mode);
	convert_move (target, op0, unsignedp);
	return target;
      }

      /* Intended for a reference to a buffer of a file-object in Pascal.
	 But it's not certain that a special tree code will really be
	 necessary for these.  INDIRECT_REF might work for them.  */
    case BUFFER_REF:
      abort ();

    case CALL_EXPR:
      /* Check for a built-in function.  */
      if (TREE_CODE (TREE_OPERAND (exp, 0)) == ADDR_EXPR
	  && TREE_CODE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)) == FUNCTION_DECL
	  && DECL_FUNCTION_CODE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)))
	return expand_builtin (exp, target, subtarget, tmode);
      /* If this call was expanded already by preexpand_calls,
	 just return the result we got.  */
      if (CALL_EXPR_RTL (exp) != 0)
	return CALL_EXPR_RTL (exp);
      return expand_call (exp, target, ignore);

    case NOP_EXPR:
    case CONVERT_EXPR:
      if (TREE_CODE (type) == VOID_TYPE || ignore)
	{
	  expand_expr (TREE_OPERAND (exp, 0), const0_rtx, VOIDmode, modifier);
	  return const0_rtx;
	}
      if (mode == TYPE_MODE (TREE_TYPE (TREE_OPERAND (exp, 0))))
	return expand_expr (TREE_OPERAND (exp, 0), target, VOIDmode, modifier);
      op0 = expand_expr (TREE_OPERAND (exp, 0), 0, mode, 0);
      if (GET_MODE (op0) == mode || GET_MODE (op0) == VOIDmode)
	return op0;
      if (flag_force_mem && GET_CODE (op0) == MEM)
	op0 = copy_to_reg (op0);
      if (target == 0)
	target = gen_reg_rtx (mode);
      convert_move (target, op0, TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (exp, 0))));
      return target;

    case PLUS_EXPR:
      preexpand_calls (exp);
      if (TREE_CODE (TREE_OPERAND (exp, 0)) == INTEGER_CST
	  && modifier == EXPAND_SUM)
	{
	  op1 = expand_expr (TREE_OPERAND (exp, 1), subtarget, VOIDmode, EXPAND_SUM);
	  op1 = plus_constant (op1, TREE_INT_CST_LOW (TREE_OPERAND (exp, 0)));
	  return op1;
	}
      negate_1 = 1;
    plus_minus:
      if (TREE_CODE (TREE_OPERAND (exp, 1)) == INTEGER_CST
	  && modifier == EXPAND_SUM)
	{
	  op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, EXPAND_SUM);
	  op0 = plus_constant (op0,
			       negate_1 * TREE_INT_CST_LOW (TREE_OPERAND (exp, 1)));
	  return op0;
	}
      this_optab = add_optab;
      if (modifier != EXPAND_SUM) goto binop;
      subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, EXPAND_SUM);
      op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, EXPAND_SUM);
      /* Put a sum last, to simplify what follows.  */
#ifdef OLD_INDEXING
      if (GET_CODE (op1) == MULT)
	{
	  temp = op0;
	  op0 = op1;
	  op1 = temp;
	}
#endif
#ifndef OLD_INDEXING
      /* Make sure any term that's a sum with a constant comes last.  */
      if (GET_CODE (op0) == PLUS
	  && CONSTANT_P (XEXP (op0, 1)))
	{
	  temp = op0;
	  op0 = op1;
	  op1 = temp;
	}
      /* If adding to a sum including a constant,
	 associate it to put the constant outside.  */
      if (GET_CODE (op1) == PLUS
	  && CONSTANT_P (XEXP (op1, 1)))
	{
	  op0 = gen_rtx (PLUS, mode, XEXP (op1, 0), op0);
	  if (GET_CODE (XEXP (op1, 1)) == CONST_INT)
	    return plus_constant (op0, INTVAL (XEXP (op1, 1)));
	  else
	    return gen_rtx (PLUS, mode, op0, XEXP (op1, 1));
	}
#endif
      return gen_rtx (PLUS, mode, op0, op1);

    case MINUS_EXPR:
      preexpand_calls (exp);
      if (TREE_CODE (TREE_OPERAND (exp, 1)) == INTEGER_CST)
	{
	  if (modifier == EXPAND_SUM)
	    {
	      negate_1 = -1;
	      goto plus_minus;
	    }
	  subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
	  op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
	  op1 = gen_rtx (CONST_INT, VOIDmode,
			 - TREE_INT_CST_LOW (TREE_OPERAND (exp, 1)));
	  this_optab = add_optab;
	  goto binop2;
	}
      this_optab = sub_optab;
      goto binop;

    case MULT_EXPR:
      preexpand_calls (exp);
      /* If first operand is constant, swap them.
	 Thus the following special case checks need only
	 check the second operand.  */
      if (TREE_CODE (TREE_OPERAND (exp, 0)) == INTEGER_CST)
	{
	  register tree t1 = TREE_OPERAND (exp, 0);
	  TREE_OPERAND (exp, 0) = TREE_OPERAND (exp, 1);
	  TREE_OPERAND (exp, 1) = t1;
	}

      /* Attempt to return something suitable for generating an
	 indexed address, for machines that support that.  */

      if (modifier == EXPAND_SUM
	  && TREE_CODE (TREE_OPERAND (exp, 1)) == INTEGER_CST) 
	{
	  op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, EXPAND_SUM);

	  /* Apply distributive law if OP0 is x+c.  */
	  if (GET_CODE (op0) == PLUS
	      && GET_CODE (XEXP (op0, 1)) == CONST_INT)
	    return gen_rtx (PLUS, mode,
			    gen_rtx (MULT, mode, XEXP (op0, 0),
				     gen_rtx (CONST_INT, VOIDmode,
					      TREE_INT_CST_LOW (TREE_OPERAND (exp, 1)))),
			    gen_rtx (CONST_INT, VOIDmode,
				     (TREE_INT_CST_LOW (TREE_OPERAND (exp, 1))
				      * INTVAL (XEXP (op0, 1)))));

	  if (GET_CODE (op0) != REG)
	    op0 = force_operand (op0, 0);
	  if (GET_CODE (op0) != REG)
	    op0 = copy_to_mode_reg (mode, op0);

	  return gen_rtx (MULT, mode, op0, 
			  gen_rtx (CONST_INT, VOIDmode,
				   TREE_INT_CST_LOW (TREE_OPERAND (exp, 1))));
	}
      subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
      /* Check for multiplying things that have been extended
	 from a narrower type.  If this machine supports multiplying
	 in that narrower type with a result in the desired type,
	 do it that way, and avoid the explicit type-conversion.  */
      if (TREE_CODE (TREE_OPERAND (exp, 0)) == NOP_EXPR
	  && TREE_CODE (TREE_TYPE (exp)) == INTEGER_TYPE
	  && (TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)))
	      < TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (exp, 0))))
	  && ((TREE_CODE (TREE_OPERAND (exp, 1)) == INTEGER_CST
	       && int_fits_type_p (TREE_OPERAND (exp, 1),
				   TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)))
	       /* Don't use a widening multiply if a shift will do.  */
	       && exact_log2 (TREE_INT_CST_LOW (TREE_OPERAND (exp, 1))) < 0)
	      ||
	      (TREE_CODE (TREE_OPERAND (exp, 1)) == NOP_EXPR
	       && (TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 1), 0)))
		   ==
		   TYPE_PRECISION (TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0))))
	       /* If both operands are extended, they must either both
		  be zero-extended or both be sign-extended.  */
	       && (TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 1), 0)))
		   ==
		   TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)))))))
	{
	  enum machine_mode innermode
	    = TYPE_MODE (TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)));
	  this_optab = (TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)))
			? umul_widen_optab : smul_widen_optab);
	  if ((int) innermode + 1 == (int) mode
	      && this_optab->handlers[(int) mode].insn_code != CODE_FOR_nothing)
	    {
	      op0 = expand_expr (TREE_OPERAND (TREE_OPERAND (exp, 0), 0),
				 0, VOIDmode, 0);
	      if (TREE_CODE (TREE_OPERAND (exp, 1)) == INTEGER_CST)
		op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
	      else
		op1 = expand_expr (TREE_OPERAND (TREE_OPERAND (exp, 1), 0),
				   0, VOIDmode, 0);
	      goto binop2;
	    }
	}
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
      return expand_mult (mode, op0, op1, target, TREE_UNSIGNED (type));

    case TRUNC_DIV_EXPR:
    case FLOOR_DIV_EXPR:
    case CEIL_DIV_EXPR:
    case ROUND_DIV_EXPR:
      preexpand_calls (exp);
      subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
      /* Possible optimization: compute the dividend with EXPAND_SUM
	 then if the divisor is constant can optimize the case
	 where some terms of the dividend have coeffs divisible by it.  */
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
      return expand_divmod (0, code, mode, op0, op1, target,
			    TREE_UNSIGNED (type));

    case RDIV_EXPR:
      preexpand_calls (exp);
      this_optab = flodiv_optab;
      goto binop;

    case TRUNC_MOD_EXPR:
    case FLOOR_MOD_EXPR:
    case CEIL_MOD_EXPR:
    case ROUND_MOD_EXPR:
      preexpand_calls (exp);
      subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
      return expand_divmod (1, code, mode, op0, op1, target,
			    TREE_UNSIGNED (type));
#if 0
#ifdef HAVE_divmoddisi4
      if (GET_MODE (op0) != DImode)
	{
	  temp = gen_reg_rtx (DImode);
	  convert_move (temp, op0, 0);
	  op0 = temp;
	  if (GET_MODE (op1) != SImode && GET_CODE (op1) != CONST_INT)
	    {
	      temp = gen_reg_rtx (SImode);
	      convert_move (temp, op1, 0);
	      op1 = temp;
	    }
	  temp = gen_reg_rtx (SImode);
	  if (target == 0)
	    target = gen_reg_rtx (SImode);
	  emit_insn (gen_divmoddisi4 (temp, protect_from_queue (op0, 0),
				      protect_from_queue (op1, 0),
				      protect_from_queue (target, 1)));
	  return target;
	}
#endif
#endif

    case FIX_ROUND_EXPR:
    case FIX_FLOOR_EXPR:
    case FIX_CEIL_EXPR:
      abort ();			/* Not used for C.  */

    case FIX_TRUNC_EXPR:
      op0 = expand_expr (TREE_OPERAND (exp, 0), 0, VOIDmode, 0);
      if (target == 0)
	target = gen_reg_rtx (mode);
      {
	int unsignedp = TREE_UNSIGNED (TREE_TYPE (exp));
	if (mode == HImode || mode == QImode)
	  {
	    register rtx temp = gen_reg_rtx (SImode);
	    expand_fix (temp, op0, 1);
	    convert_move (target, temp, 1);
	  }
	else
	  expand_fix (target, op0, unsignedp);
      }
      return target;

    case FLOAT_EXPR:
      op0 = expand_expr (TREE_OPERAND (exp, 0), 0, VOIDmode, 0);
      if (target == 0)
	target = gen_reg_rtx (mode);
      {
	int unsignedp = TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (exp, 0)));
	if (GET_MODE (op0) == HImode
	    || GET_MODE (op0) == QImode)
	  {
	    register rtx temp = gen_reg_rtx (SImode);
	    convert_move (temp, op0, unsignedp);
	    expand_float (target, temp, 0);
	  }
	else
	  expand_float (target, op0, unsignedp);
      }
      return target;

    case NEGATE_EXPR:
      op0 = expand_expr (TREE_OPERAND (exp, 0), target, VOIDmode, 0);
      temp = expand_unop (mode, neg_optab, op0, target, 0);
      if (temp == 0)
	abort ();
      return temp;

    case ABS_EXPR:
      /* First try to do it with a special abs instruction.
	 If that does not win, use conditional jump and negate.  */
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      temp = expand_unop (mode, abs_optab, op0, target, 0);
      if (temp != 0)
	return temp;
      temp = gen_label_rtx ();
      if (target == 0 || GET_CODE (target) != REG)
	target = gen_reg_rtx (mode);
      emit_move_insn (target, op0);
      emit_cmp_insn (target,
		     expand_expr (convert (TREE_TYPE (exp), integer_zero_node),
				  0, VOIDmode, 0),
		     0, 0);
      emit_jump_insn (gen_bge (temp));
      op0 = expand_unop (mode, neg_optab, target, target, 0);
      if (op0 != target)
	emit_move_insn (target, op0);
      emit_label (temp);
      return target;

    case MAX_EXPR:
    case MIN_EXPR:
      mode = TYPE_MODE (TREE_OPERAND (exp, 1));
      op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
      if (target == 0 || GET_CODE (target) != REG || target == op1)
	target = gen_reg_rtx (mode);
      op0 = expand_expr (TREE_OPERAND (exp, 0), target, VOIDmode, 0);
      if (target != op0)
	emit_move_insn (target, op0);
      op0 = gen_label_rtx ();
      if (code == MAX_EXPR)
	temp = (TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (exp, 1)))
		? compare1 (target, op1, GEU, LEU, 1, mode)
		: compare1 (target, op1, GE, LE, 0, mode));
      else
	temp = (TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (exp, 1)))
		? compare1 (target, op1, LEU, GEU, 1, mode)
		: compare1 (target, op1, LE, GE, 0, mode));
      if (temp == const0_rtx)
	emit_move_insn (target, op1);
      else if (temp != const1_rtx)
	{
	  emit_jump_insn (gen_rtx (SET, VOIDmode, pc_rtx,
				   gen_rtx (IF_THEN_ELSE, VOIDmode,
					    temp,
					    gen_rtx (LABEL_REF, VOIDmode, op0),
					    pc_rtx)));
	  emit_move_insn (target, op1);
	}
      emit_label (op0);
      return target;

/* ??? Can optimize when the operand of this is a bitwise operation,
   by using a different bitwise operation.  */
    case BIT_NOT_EXPR:
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      temp = expand_unop (mode, one_cmpl_optab, op0, target, 1);
      if (temp == 0)
	abort ();
      return temp;

    case FFS_EXPR:
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      temp = expand_unop (mode, ffs_optab, op0, target, 1);
      if (temp == 0)
	abort ();
      return temp;

/* ??? Can optimize bitwise operations with one arg constant.
   Pastel optimizes (a bitwise1 n) bitwise2 (a bitwise3 b)
   and (a bitwise1 b) bitwise2 b (etc)
   but that is probably not worth while.  */

/* BIT_AND_EXPR is for bitwise anding.
   TRUTH_AND_EXPR is for anding two boolean values
   when we want in all cases to compute both of them.
   In general it is fastest to do TRUTH_AND_EXPR by
   computing both operands as actual zero-or-1 values
   and then bitwise anding.  In cases where there cannot
   be any side effects, better code would be made by
   treating TRUTH_AND_EXPR like TRUTH_ANDIF_EXPR;
   but the question is how to recognize those cases.  */

    case TRUTH_AND_EXPR:
    case BIT_AND_EXPR:
      preexpand_calls (exp);
      subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
      return expand_bit_and (mode, op0, op1, target);

/* See comment above about TRUTH_AND_EXPR; it applies here too.  */
    case TRUTH_OR_EXPR:
    case BIT_IOR_EXPR:
      preexpand_calls (exp);
      this_optab = ior_optab;
      goto binop;

    case BIT_XOR_EXPR:
      preexpand_calls (exp);
      this_optab = xor_optab;
      goto binop;

    case LSHIFT_EXPR:
    case RSHIFT_EXPR:
    case LROTATE_EXPR:
    case RROTATE_EXPR:
      preexpand_calls (exp);
      subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
      op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
      return expand_shift (code, mode, op0, TREE_OPERAND (exp, 1), target,
			   TREE_UNSIGNED (type));

/* ??? cv's were used to effect here to combine additive constants
   and to determine the answer when only additive constants differ.
   Also, the addition of one can be handled by changing the condition.  */
    case LT_EXPR:
    case LE_EXPR:
    case GT_EXPR:
    case GE_EXPR:
    case EQ_EXPR:
    case NE_EXPR:
      preexpand_calls (exp);
      temp = do_store_flag (exp, target, mode);
      if (temp != 0)
	return temp;
      /* For foo != 0, load foo, and if it is nonzero load 1 instead. */
      if (code == NE_EXPR && integer_zerop (TREE_OPERAND (exp, 1))
	  && subtarget
	  && (GET_MODE (subtarget)
	      == TYPE_MODE (TREE_TYPE (TREE_OPERAND (exp, 0)))))
	{
	  temp = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
	  if (temp != subtarget)
	    temp = copy_to_reg (temp);
	  op1 = gen_label_rtx ();
	  emit_cmp_insn (temp, const0_rtx, 0, TREE_UNSIGNED (type));
	  emit_jump_insn (gen_beq (op1));
	  emit_move_insn (temp, const1_rtx);
	  emit_label (op1);
	  return temp;
	}
      /* If no set-flag instruction, must generate a conditional
	 store into a temporary variable.  Drop through
	 and handle this like && and ||.  */

    case TRUTH_ANDIF_EXPR:
    case TRUTH_ORIF_EXPR:
      temp = gen_reg_rtx (mode);
      emit_clr_insn (temp);
      op1 = gen_label_rtx ();
      jumpifnot (exp, op1);
      emit_0_to_1_insn (temp);
      emit_label (op1);
      return temp;

    case TRUTH_NOT_EXPR:
      op0 = expand_expr (TREE_OPERAND (exp, 0), target, VOIDmode, 0);
      /* The parser is careful to generate TRUTH_NOT_EXPR
	 only with operands that are always zero or one.  */
      temp = expand_binop (mode, xor_optab, op0,
			   gen_rtx (CONST_INT, mode, 1),
			   target, 1, OPTAB_LIB_WIDEN);
      if (temp == 0)
	abort ();
      return temp;

    case COMPOUND_EXPR:
      expand_expr (TREE_OPERAND (exp, 0), const0_rtx, VOIDmode, 0);
      emit_queue ();
      return expand_expr (TREE_OPERAND (exp, 1), target, VOIDmode, 0);

    case COND_EXPR:
      /* Note that COND_EXPRs whose type is a structure or union
	 are required to be constructed to contain assignments of
	 a temporary variable, so that we can evaluate them here
	 for side effect only.  If type is void, we must do likewise.  */
      op0 = gen_label_rtx ();
      op1 = gen_label_rtx ();

      if (mode == VOIDmode || ignore)
	temp = 0;
      else if (target)
	temp = target;
      else if (mode == BLKmode)
	{
	  if (TYPE_SIZE (type) == 0 || ! TREE_LITERAL (TYPE_SIZE (type)))
	    abort ();
	  temp = assign_stack_local (BLKmode,
				     (TREE_INT_CST_LOW (TYPE_SIZE (type))
				      * TYPE_SIZE_UNIT (type)
				      + BITS_PER_UNIT - 1)
				     / BITS_PER_UNIT);
	}
      else
	temp = gen_reg_rtx (mode);

      jumpifnot (TREE_OPERAND (exp, 0), op0);
      current_args_size += 1;
      if (temp != 0)
	store_expr (TREE_OPERAND (exp, 1), temp, 0);
      else
	expand_expr (TREE_OPERAND (exp, 1), ignore ? const0_rtx : 0,
		     VOIDmode, 0);
      emit_queue ();
      emit_jump_insn (gen_jump (op1));
      emit_barrier ();
      emit_label (op0);
      if (temp != 0)
	store_expr (TREE_OPERAND (exp, 2), temp, 0);
      else
	expand_expr (TREE_OPERAND (exp, 2), ignore ? const0_rtx : 0,
		     VOIDmode, 0);
      emit_queue ();
      emit_label (op1);
      current_args_size -= 1;
      return temp;

    case MODIFY_EXPR:
      /* If lhs is complex, expand calls in rhs before computing it.
	 That's so we don't compute a pointer and save it over a call.
	 If lhs is simple, compute it first so we can give it as a
	 target if the rhs is just a call.  This avoids an extra temp and copy
	 and that prevents a partial-subsumption which makes bad code.
	 Actually we could treat component_ref's of vars like vars.  */
      if (TREE_CODE (TREE_OPERAND (exp, 0)) != VAR_DECL
	  && TREE_CODE (TREE_OPERAND (exp, 0)) != RESULT_DECL
	  && TREE_CODE (TREE_OPERAND (exp, 0)) != PARM_DECL)
	preexpand_calls (exp);
      temp = expand_assignment (TREE_OPERAND (exp, 0),
				TREE_OPERAND (exp, 1),
				! ignore,
				original_target != 0);
      return temp;

    case PREINCREMENT_EXPR:
    case PREDECREMENT_EXPR:
      return expand_increment (exp, 0);

    case POSTINCREMENT_EXPR:
    case POSTDECREMENT_EXPR:
      return expand_increment (exp, 1);

    case ADDR_EXPR:
      op0 = expand_expr (TREE_OPERAND (exp, 0), 0, VOIDmode,
			 EXPAND_CONST_ADDRESS);
      if (GET_CODE (op0) != MEM)
	abort ();
      if (modifier == EXPAND_SUM)
	return XEXP (op0, 0);
      op0 = force_operand (XEXP (op0, 0), target);
      if (flag_force_addr && GET_CODE (op0) != REG)
	return force_reg (Pmode, op0);
      return op0;

    case ENTRY_VALUE_EXPR:
      abort ();

    case ERROR_MARK:
      return const0_rtx;

    default:
      abort ();
    }

  /* Here to do an ordinary binary operator, generating an instruction
     from the optab already placed in `this_optab'.  */
 binop:
  /* Detect things like x = y | (a == b)
     and do them as (x = y), (a == b ? x |= 1 : 0), x.  */
  /* First, get the comparison or conditional into the second arg.  */
  if (comparison_code[(int) TREE_CODE (TREE_OPERAND (exp, 0))]
      || (TREE_CODE (TREE_OPERAND (exp, 0)) == COND_EXPR
	  && (integer_zerop (TREE_OPERAND (TREE_OPERAND (exp, 0), 1))
	      || integer_zerop (TREE_OPERAND (TREE_OPERAND (exp, 0), 2)))))
    {
      if (this_optab == ior_optab || this_optab == add_optab
	  || this_optab == xor_optab)
	{
	  tree exch = TREE_OPERAND (exp, 1);
	  TREE_OPERAND (exp, 1) = TREE_OPERAND (exp, 0);
	  TREE_OPERAND (exp, 0) = exch;
	}
    }
  /* Optimize X + (Y ? Z : 0) by computing X and maybe adding Z.  */
  if (comparison_code[(int) TREE_CODE (TREE_OPERAND (exp, 1))]
      || (TREE_CODE (TREE_OPERAND (exp, 1)) == COND_EXPR
	  && (integer_zerop (TREE_OPERAND (TREE_OPERAND (exp, 1), 1))
	      || integer_zerop (TREE_OPERAND (TREE_OPERAND (exp, 1), 2)))))
    {
      if (this_optab == ior_optab || this_optab == add_optab
	  || this_optab == xor_optab || this_optab == sub_optab
	  || this_optab == lshl_optab || this_optab == ashl_optab
	  || this_optab == lshr_optab || this_optab == ashr_optab
	  || this_optab == rotl_optab || this_optab == rotr_optab)
	{
	  tree thenexp;
	  rtx thenv = 0;

	  /* Don't store intermediate results in a fixed register.  */
	  if (target != 0 && GET_CODE (target) == REG
	      && REGNO (target) < FIRST_PSEUDO_REGISTER)
	    target = 0;
	  if (target == 0) target = gen_reg_rtx (mode);

	  /* Compute X into the target.  */
	  store_expr (TREE_OPERAND (exp, 0), target, 0);
	  op0 = gen_label_rtx ();

	  /* If other operand is a comparison COMP, treat it as COMP ? 1 : 0 */
	  if (TREE_CODE (TREE_OPERAND (exp, 1)) != COND_EXPR)
	    {
	      do_jump (TREE_OPERAND (exp, 1), op0, 0);
	      thenv = const1_rtx;
	    }
	  else if (integer_zerop (TREE_OPERAND (TREE_OPERAND (exp, 1), 2)))
	    {
	      do_jump (TREE_OPERAND (TREE_OPERAND (exp, 1), 0), op0, 0);
	      thenexp = TREE_OPERAND (TREE_OPERAND (exp, 1), 1);
	    }
	  else
	    {
	      do_jump (TREE_OPERAND (TREE_OPERAND (exp, 1), 0), 0, op0);
	      thenexp = TREE_OPERAND (TREE_OPERAND (exp, 1), 2);
	    }

	  if (thenv == 0)
	    thenv = expand_expr (thenexp, 0, VOIDmode, 0);

	  /* THENV is now Z, the value to operate on, as an rtx.
	     We have already tested that Y isn't zero, so do the operation.  */

	  if (this_optab == rotl_optab || this_optab == rotr_optab)
	    temp = expand_binop (mode, this_optab, target, thenv, target,
				 -1, OPTAB_LIB);
	  else if (this_optab == lshl_optab || this_optab == lshr_optab)
	    temp = expand_binop (mode, this_optab, target, thenv, target,
				 1, OPTAB_LIB_WIDEN);
	  else
	    temp = expand_binop (mode, this_optab, target, thenv, target,
				 0, OPTAB_LIB_WIDEN);
	  if (target != temp)
	    emit_move_insn (target, temp);

	  emit_label (op0);
	  return target;
	}
    }
  subtarget = validate_subtarget (subtarget, TREE_OPERAND (exp, 1));
  op0 = expand_expr (TREE_OPERAND (exp, 0), subtarget, VOIDmode, 0);
  op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
 binop2:
  temp = expand_binop (mode, this_optab, op0, op1, target,
		       TREE_UNSIGNED (TREE_TYPE (exp)), OPTAB_LIB_WIDEN);
 binop1:
  if (temp == 0)
    abort ();
  return temp;
}

/* Expand an expression EXP that calls a built-in function,
   with result going to TARGET if that's convenient
   (and in mode MODE if that's convenient).
   SUBTARGET may be used as the target for computing one of EXP's operands.  */

static rtx
expand_builtin (exp, target, subtarget, mode)
     tree exp;
     rtx target;
     rtx subtarget;
     enum machine_mode mode;
{
  tree fndecl = TREE_OPERAND (TREE_OPERAND (exp, 0), 0);
  tree arglist = TREE_OPERAND (exp, 1);
  rtx op0;
  rtx temp;

  switch (DECL_FUNCTION_CODE (fndecl))
    {
    case BUILT_IN_ABS:
    case BUILT_IN_LABS:
    case BUILT_IN_FABS:
      /* build_function_call changes these into ABS_EXPR.  */
      abort ();

    case BUILT_IN_ALLOCA:
      if (arglist == 0)
	return const0_rtx;
      frame_pointer_needed = 1;
      /* Compute the argument.  */
      op0 = expand_expr (TREE_VALUE (arglist), 0, VOIDmode, 0);
      if (! CONSTANT_P (op0))
	{
	  op0 = force_reg (GET_MODE (op0), op0);
	  if (GET_MODE (op0) != Pmode)
	    op0 = convert_to_mode (Pmode, op0);
	}
      /* Push that much space (rounding it up).  */
      do_pending_stack_adjust ();
#ifdef STACK_GROWS_DOWNWARD
      anti_adjust_stack (round_push (op0));
#endif
      /* Return a copy of current stack ptr, in TARGET if possible.  */
      if (target)
	emit_move_insn (target, stack_pointer_rtx);
      else
	target = copy_to_reg (stack_pointer_rtx);
#ifdef STACK_POINTER_OFFSET
      /* If the contents of the stack pointer reg are offset from the
	 actual top-of-stack address, add the offset here.  */
      emit_insn (gen_add2_insn (target, gen_rtx (CONST_INT, VOIDmode,
						 STACK_POINTER_OFFSET)));
#endif
#ifndef STACK_GROWS_DOWNWARD
      anti_adjust_stack (round_push (op0));
#endif
      return target;

    case BUILT_IN_FFS:
      if (arglist == 0)
	return const0_rtx;

      /* Compute the argument.  */
      op0 = expand_expr (TREE_VALUE (arglist), subtarget, VOIDmode, 0);
      /* Compute ffs, into TARGET if possible.
	 Set TARGET to wherever the result comes back.  */
      target = expand_unop (mode, ffs_optab, op0, target, 1);
      if (target == 0)
	abort ();
      return target;

    default:
      abort ();
    }
}

/* Expand code for a post- or pre- increment or decrement
   and return the RTX for the result.
   POST is 1 for postinc/decrements and 0 for preinc/decrements.  */

static rtx
expand_increment (exp, post)
     register tree exp;
     int post;
{
  register rtx op0, op1;
  register rtx temp;
  register tree incremented = TREE_OPERAND (exp, 0);
  optab this_optab = add_optab;
  int icode;
  enum machine_mode mode = TYPE_MODE (TREE_TYPE (exp));
  int op0_is_copy = 0;

  /* Stabilize any component ref that might need to be
     evaluated more than once below.  */
  if (TREE_CODE (incremented) == COMPONENT_REF
      && (TREE_CODE (TREE_OPERAND (incremented, 0)) != INDIRECT_REF
	  || DECL_MODE (TREE_OPERAND (exp, 1)) == BImode))
    incremented = stabilize_reference (incremented);

  /* Compute the operands as RTX.
     Note whether OP0 is the actual lvalue or a copy of it:
     I believe it is a copy iff it is a register and insns were
     generated in computing it.  */
  temp = get_last_insn ();
  op0 = expand_expr (incremented, 0, VOIDmode, 0);
  if (temp != get_last_insn ())
    op0_is_copy = (GET_CODE (op0) == REG || GET_CODE (op0) == SUBREG);
  op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);

  /* Decide whether incrementing or decrementing.  */
  if (TREE_CODE (exp) == POSTDECREMENT_EXPR
      || TREE_CODE (exp) == PREDECREMENT_EXPR)
    this_optab = sub_optab;

  /* If OP0 is not the actual lvalue, but rather a copy in a register,
     then we cannot just increment OP0.  We must
     therefore contrive to increment the original value.
     Then we can return OP0 since it is a copy of the old value.  */
  if (op0_is_copy)
    {
      /* This is the easiest way to increment the value wherever it is.
	 Problems with multiple evaluation of INCREMENTED
	 are prevented because either (1) it is a component_ref,
	 in which case it was stabilized above, or (2) it is an array_ref
	 with constant index in an array in a register, which is
	 safe to reevaluate.  */
      tree newexp = build ((this_optab == add_optab
			    ? PLUS_EXPR : MINUS_EXPR),
			   TREE_TYPE (exp),
			   incremented,
			   TREE_OPERAND (exp, 1));
      temp = expand_assignment (incremented, newexp, ! post, 0);
      return post ? op0 : temp;
    }

  /* Convert decrement by a constant into a negative increment.  */
  if (this_optab == sub_optab
      && GET_CODE (op1) == CONST_INT)
    {
      op1 = gen_rtx (CONST_INT, VOIDmode, - INTVAL (op1));
      this_optab = add_optab;
    }

  if (post)
    {
      /* We have a true reference to the value in OP0.
	 If there is an insn to add or subtract in this mode, queue it.  */

      /* I'm not sure this is still necessary.  */
      op0 = stabilize (op0);

      icode = (int) this_optab->handlers[(int) mode].insn_code;
      if (icode != (int) CODE_FOR_nothing
	  /* Make sure that OP0 is valid for operands 0 and 1
	     of the insn we want to queue.  */
	  && (*insn_operand_predicate[icode][0]) (op0, mode)
	  && (*insn_operand_predicate[icode][1]) (op0, mode))
	{
	  if (! (*insn_operand_predicate[icode][2]) (op1, mode))
	    op1 = force_reg (mode, op1);

	  return enqueue_insn (op0, GEN_FCN (icode) (op0, op0, op1));
	}
    }

  /* Preincrement, or we can't increment with one simple insn.  */
  if (post)
    /* Save a copy of the value before inc or dec, to return it later.  */
    temp = copy_to_reg (op0);
  else
    /* Arrange to return the incremented value.  */
    temp = op0;

  /* Increment however we can.  */
  op1 = expand_binop (mode, this_optab, op0, op1, op0,
		      0, OPTAB_LIB_WIDEN);
  /* Make sure the value is stored into OP0.  */
  if (op1 != op0)
    emit_move_insn (op0, op1);

  return temp;
}

/* Expand all function calls contained within EXP, innermost ones first.
   But don't look within expressions that have sequence points.
   For each CALL_EXPR, record the rtx for its value
   in the CALL_EXPR_RTL field.

   Calls that return large structures for which a structure return
   stack slot is needed are not preexpanded.  Preexpanding them loses
   because if more than one were preexpanded they would try to use the
   same stack slot.  */

static void
preexpand_calls (exp)
     tree exp;
{
  register int nops, i;

  if (! do_preexpand_calls)
    return;

  /* Only expressions and references can contain calls.  */

  if (tree_code_type[(int) TREE_CODE (exp)][0] != 'e'
      && tree_code_type[(int) TREE_CODE (exp)][0] != 'r')
    return;

  switch (TREE_CODE (exp))
    {
    case CALL_EXPR:
      /* Do nothing to built-in functions.  */
      if (TREE_CODE (TREE_OPERAND (exp, 0)) == ADDR_EXPR
	  && TREE_CODE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)) == FUNCTION_DECL
	  && DECL_FUNCTION_CODE (TREE_OPERAND (TREE_OPERAND (exp, 0), 0)))
	return;
      if (CALL_EXPR_RTL (exp) == 0
	  && TYPE_MODE (TREE_TYPE (exp)) != BLKmode)
	CALL_EXPR_RTL (exp) = expand_call (exp, 0, 0);
      return;

    case COMPOUND_EXPR:
    case COND_EXPR:
    case TRUTH_ANDIF_EXPR:
    case TRUTH_ORIF_EXPR:
      /* If we find one of these, then we can be sure
	 the adjust will be done for it (since it makes jumps).
	 Do it now, so that if this is inside an argument
	 of a function, we don't get the stack adjustment
	 after some other args have already been pushed.  */
      do_pending_stack_adjust ();
      return;

    case RTL_EXPR:
      return;

    case SAVE_EXPR:
      if (SAVE_EXPR_RTL (exp) != 0)
	return;
    }

  nops = tree_code_length[(int) TREE_CODE (exp)];
  for (i = 0; i < nops; i++)
    if (TREE_OPERAND (exp, i) != 0)
      {
	register int type = *tree_code_type[(int) TREE_CODE (TREE_OPERAND (exp, i))];
	if (type == 'e' || type == 'r')
	  preexpand_calls (TREE_OPERAND (exp, i));
      }
}

/* Force FUNEXP into a form suitable for the address of a CALL,
   and return that as an rtx.  Also load the static chain register
   from either FUNEXP or CONTEXT.  */

static rtx
prepare_call_address (funexp, context)
     rtx funexp;
     rtx context;
{
  funexp = protect_from_queue (funexp, 0);
  if (context != 0)
    context = protect_from_queue (context, 0);

  /* Function variable in language with nested functions.  */
  if (GET_MODE (funexp) == EPmode)
    {
      emit_move_insn (static_chain_rtx, gen_highpart (Pmode, funexp));
      funexp = memory_address (FUNCTION_MODE, gen_lowpart (Pmode, funexp));
      emit_insn (gen_rtx (USE, VOIDmode, static_chain_rtx));
    }
  else
    {
      if (context != 0)
	/* Unless function variable in C, or top level function constant */
	emit_move_insn (static_chain_rtx, lookup_static_chain (context));

      /* Make a valid memory address and copy constants thru pseudo-regs,
	 but not for a constant address if -fno-function-cse.  */
      if (GET_CODE (funexp) != SYMBOL_REF)
	funexp = memory_address (FUNCTION_MODE, funexp);
      else
	{
#ifndef NO_FUNCTION_CSE
	  if (! flag_no_function_cse)
	    funexp = copy_to_mode_reg (Pmode, funexp);
#endif
	}

      if (context != 0)
	emit_insn (gen_rtx (USE, VOIDmode, static_chain_rtx));
    }
  return funexp;
}

/* Generate instructions to call function FUNEXP,
   and optionally pop the results.
   The CALL_INSN is the first insn generated.

   FUNTYPE is the data type of the function, or, for a library call,
   the identifier for the name of the call.  This is given to the
   macro RETURN_POPS_ARGS to determine whether this function pops its own args.

   STACK_SIZE is the number of bytes of arguments on the stack, 
   rounded up to STACK_BOUNDARY; zero if the size is variable.
   This is both to put into the call insn and
   to generate explicit popping code if necessary.

   NEXT_ARG_REG is the rtx that results from executing
     FUNCTION_ARG (args_so_far, VOIDmode, void_type_node, 1)
   just after all the args have had their registers assigned.
   This could be whatever you like, but normally it is the first
   arg-register beyond those used for args in this call,
   or 0 if all the arg-registers are used in this call.
   It is passed on to `gen_call' so you can put this info in the call insn.

   VALREG is a hard register in which a value is returned,
   or 0 if the call does not return a value.

   OLD_ARGS_SIZE is the value that `current_args_size' had before
   the args to this call were processed.
   We restore `current_args_size' to that value.  */

static void
emit_call_1 (funexp, funtype, stack_size, next_arg_reg, valreg, old_args_size)
     rtx funexp;
     tree funtype;
     int stack_size;
     rtx next_arg_reg;
     rtx valreg;
     int old_args_size;
{
  rtx stack_size_rtx = gen_rtx (CONST_INT, VOIDmode, stack_size);

  if (valreg)
    emit_call_insn (gen_call_value (valreg,
				    gen_rtx (MEM, FUNCTION_MODE, funexp),
				    stack_size_rtx, next_arg_reg));
  else
    emit_call_insn (gen_call (gen_rtx (MEM, FUNCTION_MODE, funexp),
			      stack_size_rtx, next_arg_reg));

  current_args_size = old_args_size;

  /* If returning from the subroutine does not automatically pop the args,
     we need an instruction to pop them sooner or later.
     Perhaps do it now; perhaps just record how much space to pop later.  */

  if (! RETURN_POPS_ARGS (TREE_TYPE (funtype))
      && stack_size != 0)
    {
      if (flag_defer_pop && current_args_size == 0)
	pending_stack_adjust += stack_size;
      else
	adjust_stack (stack_size_rtx);
    }
}

/* At the start of a function, record that we have no previously-pushed
   arguments waiting to be popped.  */

void
init_pending_stack_adjust ()
{
  pending_stack_adjust = 0;
}

/* When exiting from function, if safe, clear out any pending stack adjust
   so the adjustment won't get done.  */

void
clear_pending_stack_adjust ()
{
#ifdef EXIT_IGNORE_STACK
  if (!flag_omit_frame_pointer && EXIT_IGNORE_STACK
      && ! TREE_INLINE (current_function_decl))
    pending_stack_adjust = 0;
#endif
}

/* At start of function, initialize.  */
void
clear_current_args_size ()
{
  current_args_size = 0;
}

/* Pop any previously-pushed arguments that have not been popped yet.  */

void
do_pending_stack_adjust ()
{
  if (current_args_size == 0)
    {
      if (pending_stack_adjust != 0)
	adjust_stack (gen_rtx (CONST_INT, VOIDmode, pending_stack_adjust));
      pending_stack_adjust = 0;
    }
}

/* Generate all the code for a function call
   and return an rtx for its value.
   Store the value in TARGET (specified as an rtx) if convenient.
   If the value is stored in TARGET then TARGET is returned.
   If IGNORE is nonzero, then we ignore the value of the function call.  */

static rtx
expand_call (exp, target, ignore)
     tree exp;
     rtx target;
     int ignore;
{
  tree actparms = TREE_OPERAND (exp, 1);
  tree funtype;
  rtx funexp;
  register tree p = TREE_OPERAND (exp, 0);
  struct args_size args_size;
  register int i;
  register tree *argvec;
  rtx *regvec;
  rtx *valvec;
  int *partial;
  struct args_size *arg_offset;
  struct args_size *arg_size;
  int num_actuals;
  rtx structure_value_addr = 0;
  tree fndecl = 0;
  int may_be_alloca;
  int inc;
  int is_setjmp;
  int is_integrable = 0;
  rtx argblock = 0;
  CUMULATIVE_ARGS args_so_far;
  int reg_parm_seen = 0;
  rtx valreg;
  rtx old_stack_level;
  int old_pending_adj;
  int old_current_args_size = current_args_size;

  /* Number of named args.  Args after this are anonymous ones
     and they must all go on the stack.  */
  int n_named_args;

  args_size.constant = 0;
  args_size.var = 0;

  /* See if we can find a DECL-node for the actual function.
     As a result, decide whether this is a call to an integrable function.  */

  if (TREE_CODE (p) == ADDR_EXPR)
    {
      fndecl = TREE_OPERAND (p, 0);
      if (TREE_CODE (fndecl) != FUNCTION_DECL)
	fndecl = 0;
      else
	{
	  extern tree current_function_decl;

	  if (fndecl != current_function_decl
	      && DECL_SAVED_INSNS (fndecl))
	    is_integrable = 1;
	  else
	    {
	      /* In case this function later becomes inlineable,
		 record that there was already a non-inline call to it.  */
	      TREE_ADDRESSABLE (fndecl) = 1;
	      TREE_ADDRESSABLE (DECL_NAME (fndecl)) = 1;
	    }
	}
    }

  /* Set up a place to return a structure.  */

  if (TYPE_MODE (TREE_TYPE (exp)) == BLKmode)
    {
      /* This call returns a big structure.  */
      if (target)
	structure_value_addr = XEXP (target, 0);
      else
	/* Make room on the stack to hold the value.  */
	structure_value_addr = get_structure_value_addr (expr_size (exp));
    }

  if (is_integrable)
    {
      extern int integration_time;
      extern rtx expand_inline_function ();
      rtx temp;

      temp = expand_inline_function (fndecl, actparms, target,
				     ignore, TREE_TYPE (exp),
				     structure_value_addr);

      if (temp != (rtx)-1)
	return temp;
    }

#if 0
  /* Unless it's a call to a specific function that isn't alloca,
     if it has one argument, we must assume it might be alloca.  */

  may_be_alloca =
    (!(fndecl != 0
       && strcmp (IDENTIFIER_POINTER (DECL_NAME (fndecl)),
		  "alloca"))
     && actparms != 0
     && TREE_CHAIN (actparms) == 0);
#else
  /* We assume that alloca will always be called by name.  It
     makes no sense to pass it as a pointer-to-function to
     anything that does not understand its behavior.  */
  may_be_alloca =
    (fndecl && ! strcmp (IDENTIFIER_POINTER (DECL_NAME (fndecl)), "alloca"));
#endif

  /* See if this is a call to a function that can return more than once.  */

  is_setjmp
    = (fndecl != 0
       && (!strcmp (IDENTIFIER_POINTER (DECL_NAME (fndecl)), "setjmp")
	   || !strcmp (IDENTIFIER_POINTER (DECL_NAME (fndecl)), "_setjmp")));

  if (may_be_alloca)
    {
      frame_pointer_needed = 1;
      may_call_alloca = 1;
    }

  /* Don't let pending stack adjusts add up to too much.
     Also, do all pending adjustments now
     if there is any chance this might be a call to alloca.  */

  if (pending_stack_adjust >= 32
      || (pending_stack_adjust > 0 && may_be_alloca))
    do_pending_stack_adjust ();

  /* Operand 0 is a pointer-to-function; get the type of the function.  */
  funtype = TREE_TYPE (TREE_OPERAND (exp, 0));
  if (TREE_CODE (funtype) != POINTER_TYPE)
    abort ();
  funtype = TREE_TYPE (funtype);

  /* Count the arguments and set NUM_ACTUALS.  */
  for (p = actparms, i = 0; p; p = TREE_CHAIN (p)) i++;
  num_actuals = i;

  /* Compute number of named args.
     This may actually be 1 too large, but that happens
     only in the case when all args are named, so no trouble results.  */
  if (TYPE_ARG_TYPES (funtype) != 0)
    n_named_args = list_length (TYPE_ARG_TYPES (funtype));
  else
    /* If we know nothing, treat all args as named.  */
    n_named_args = num_actuals;

  /* Make a vector of the args, in the order we want to compute them,
     and a parallel vector of where we want to put them.
     regvec[I] is 0 to if should push argvec[I] or else a reg to put it in.
     valvec[i] is the arg value as an rtx.  */
  argvec = (tree *) alloca (i * sizeof (tree));
  regvec = (rtx *) alloca (i * sizeof (rtx));
  valvec = (rtx *) alloca (i * sizeof (rtx));
  partial = (int *) alloca (i * sizeof (int));
  arg_size = (struct args_size *) alloca (i * sizeof (struct args_size));
  arg_offset = (struct args_size *) alloca (i * sizeof (struct args_size));

  /* In this loop, we consider args in the order they are written.
     We fill up argvec from the front of from the back
     so that the first arg to be pushed ends up at the front.  */

#ifdef PUSH_ARGS_REVERSED
  i = num_actuals - 1, inc = -1;
  /* In this case, must reverse order of args
     so that we compute and push the last arg first.  */
#else
  i = 0, inc = 1;
#endif

  INIT_CUMULATIVE_ARGS (args_so_far, funtype);

  for (p = actparms; p; p = TREE_CHAIN (p), i += inc)
    {
      tree type = TREE_TYPE (TREE_VALUE (p));
      argvec[i] = p;
      regvec[i] = 0;
      valvec[i] = 0;
      partial[i] = 0;
      arg_size[i].constant = 0;
      arg_size[i].var = 0;
      arg_offset[i] = args_size;

#ifdef STACK_POINTER_OFFSET
      /* ARG_OFFSET is used to index ARGS_ADDR, which is the stack ptr reg,
	 so if there is a gap between that reg and the actual t.o.s. addr,
	 we must include it in this offset.  */
      arg_offset.constant += STACK_POINTER_OFFSET;
#endif

      if (type == error_mark_node)
	continue;

      /* Decide where to pass this arg.  */
      /* regvec[i] is nonzero if all or part is passed in registers.
	 partial[i] is nonzero if part but not all is passed in registers,
	  and the exact value says how many words are passed in registers.  */

      if (TREE_CODE (TYPE_SIZE (type)) == INTEGER_CST
	  || args_size.var != 0)
	{
	  regvec[i] = FUNCTION_ARG (args_so_far, TYPE_MODE (type), type,
				    i < n_named_args);
#ifdef FUNCTION_ARG_PARTIAL_NREGS
	  partial[i] = FUNCTION_ARG_PARTIAL_NREGS (args_so_far,
						   TYPE_MODE (type), type,
						   i < n_named_args);
#endif
	}

      /* Once we see at least one parm that is being passed in a register,
	 precompute that parm and all remaining parms (if they do arithmetic)
	 before loading any of them into their specified registers.
	 That way we don't lose if one of them involves
	 a function call OR a library routine that needs the same regs.  */
      if (regvec[i] != 0)
	reg_parm_seen = 1;

      if (reg_parm_seen)
	{
	  valvec[i] = expand_expr (TREE_VALUE (p), 0, VOIDmode, 0);
	  if (GET_CODE (valvec[i]) != MEM
	      && ! CONSTANT_P (valvec[i])
	      && GET_CODE (valvec[i]) != CONST_DOUBLE)
	    valvec[i] = force_reg (TYPE_MODE (type), valvec[i]);
	  /* ANSI doesn't require a sequence point here,
	     but PCC has one, so this will avoid some problems.  */
	  emit_queue ();
	}

      /* Increment ARGS_SO_FAR, which has info about which arg-registers
	 have been used, etc.  */

      FUNCTION_ARG_ADVANCE (args_so_far, TYPE_MODE (type), type,
			    i < n_named_args);

      /* Increment ARGS_SIZE, which is the size of all args so far.  */

      if (regvec[i] != 0 && partial[i] == 0)
	/* A register-arg doesn't count.  */
	;
      else if (TYPE_MODE (type) != BLKmode)
	{
	  register int size;

	  size = GET_MODE_SIZE (TYPE_MODE (type));
	  /* Compute how much space the push instruction will push.
	     On many machines, pushing a byte will advance the stack
	     pointer by a halfword.  */
#ifdef PUSH_ROUNDING
	  size = PUSH_ROUNDING (size);
#endif
	  /* Compute how much space the argument should get:
	     round up to a multiple of the alignment for arguments.  */
	  arg_size[i].constant
	    = (((size + PARM_BOUNDARY / BITS_PER_UNIT - 1)
		/ (PARM_BOUNDARY / BITS_PER_UNIT))
	       * (PARM_BOUNDARY / BITS_PER_UNIT));
	}
      else
	{
	  register tree size = size_in_bytes (type);

	  /* A nonscalar.  Round its size up to a multiple
	     of the allocation unit for arguments.  */

	  /* Now round up to multiple of PARM_BOUNDARY bits,
	     then express as number of bytes.  */
	  ADD_PARM_SIZE (arg_size[i],
			 convert_units (convert_units (size, BITS_PER_UNIT, PARM_BOUNDARY),
					PARM_BOUNDARY, BITS_PER_UNIT));

	}
      /* If a part of the arg was put into registers,
	 don't include that part in the amount pushed.  */
      arg_size[i].constant
	-= ((partial[i] * UNITS_PER_WORD)
	    / (PARM_BOUNDARY / BITS_PER_UNIT)
	    * (PARM_BOUNDARY / BITS_PER_UNIT));

      args_size.constant += arg_size[i].constant;

      if (arg_size[i].var)
	{
	  ADD_PARM_SIZE (args_size, arg_size[i].var);
	}
    }

  /* If we have no actual push instructions, or we need a variable
     amount of space, make space for all the args right now.
     In any case, round the needed size up to multiple of STACK_BOUNDARY.  */

  if (args_size.var != 0)
    {
      old_stack_level = copy_to_mode_reg (Pmode, stack_pointer_rtx);
      old_pending_adj = pending_stack_adjust;
      argblock = push_block (round_push (ARGS_SIZE_RTX (args_size)));
    }
  else if (args_size.constant != 0)
    {
      int needed = args_size.constant;

#ifdef STACK_BOUNDARY
      needed = (needed + STACK_BYTES - 1) / STACK_BYTES * STACK_BYTES;
      args_size.constant = needed;
#endif

#ifndef PUSH_ROUNDING
      /* Try to reuse some or all of the pending_stack_adjust
	 to get this space.  Maybe we can avoid any pushing.  */
      if (needed > pending_stack_adjust)
	{
	  needed -= pending_stack_adjust;
	  pending_stack_adjust = 0;
	}
      else
	{
	  pending_stack_adjust -= needed;
	  needed = 0;
	}
      argblock = push_block (gen_rtx (CONST_INT, VOIDmode, needed));
#endif /* no PUSH_ROUNDING */
    }

  /* Get the function to call, in the form of RTL.  */
  if (fndecl)
    /* Get a SYMBOL_REF rtx for the function address.  */
    funexp = XEXP (DECL_RTL (fndecl), 0);
  else
    /* Generate an rtx (probably a pseudo-register) for the address.  */
    {
      funexp = expand_expr (TREE_OPERAND (exp, 0), 0, VOIDmode, 0);
      emit_queue ();
    }

  /* Now actually compute the args, and push those that need pushing.  */

  for (i = 0; i < num_actuals; i++)
    {
      register tree p = argvec[i];
      register tree pval = TREE_VALUE (p);
      int used = 0;

      /* Push the next argument.  Note that it has already been converted
	 if necessary to the type that the called function expects.  */

      if (TREE_CODE (pval) == ERROR_MARK)
	;
      else if (regvec[i] != 0 && partial[i] == 0)
	{
	  /* Being passed entirely in a register.  */
	  if (valvec[i] != 0)
	    {
	      if (GET_MODE (valvec[i]) == BLKmode)
		move_block_to_reg (REGNO (regvec[i]), valvec[i],
				   (int_size_in_bytes (TREE_TYPE (pval))
				    / UNITS_PER_WORD));
	      else
		emit_move_insn (regvec[i], valvec[i]);
	    }
	  else
	    store_expr (pval, regvec[i], 0);

	  /* Don't allow anything left on stack from computation
	     of argument to alloca.  */
	  if (may_be_alloca)
	    do_pending_stack_adjust ();
	}
      else if (TYPE_MODE (TREE_TYPE (pval)) != BLKmode)
	{
	  register int size;
	  rtx tem;

	  /* Argument is a scalar, not entirely passed in registers.
	     (If part is passed in registers, partial[I] says how much
	     and emit_push_insn will take care of putting it there.)

	     Push it, and if its size is less than the
	     amount of space allocated to it,
	     also bump stack pointer by the additional space.
	     Note that in C the default argument promotions
	     will prevent such mismatches.  */

	  used = size = GET_MODE_SIZE (TYPE_MODE (TREE_TYPE (pval)));
	  /* Compute how much space the push instruction will push.
	     On many machines, pushing a byte will advance the stack
	     pointer by a halfword.  */
#ifdef PUSH_ROUNDING
	  size = PUSH_ROUNDING (size);
#endif
	  /* Compute how much space the argument should get:
	     round up to a multiple of the alignment for arguments.  */
	  used = (((size + PARM_BOUNDARY / BITS_PER_UNIT - 1)
		   / (PARM_BOUNDARY / BITS_PER_UNIT))
		  * (PARM_BOUNDARY / BITS_PER_UNIT));

	  tem = valvec[i];
	  if (tem == 0)
	    {
	      tem = expand_expr (pval, 0, VOIDmode, 0);
	      /* ANSI doesn't require a sequence point here,
		 but PCC has one, so this will avoid some problems.  */
	      emit_queue ();
	    }

	  /* Don't allow anything left on stack from computation
	     of argument to alloca.  */
	  if (may_be_alloca)
	    do_pending_stack_adjust ();

	  emit_push_insn (tem, TYPE_MODE (TREE_TYPE (pval)), 0, 0,
			  partial[i], regvec[i], used - size,
			  argblock, ARGS_SIZE_RTX (arg_offset[i]));
	}
      else
	{
	  register rtx tem
	    = valvec[i] ? valvec[i] : expand_expr (pval, 0, VOIDmode, 0);
	  register int excess;
	  rtx size_rtx;

	  /* Pushing a nonscalar.
	     If part is passed in registers, partial[I] says how much
	     and emit_push_insn will take care of putting it there.  */

	  /* Round its size up to a multiple
	     of the allocation unit for arguments.  */

	  if (arg_size[i].var != 0)
	    {
	      excess = 0;
	      size_rtx = ARGS_SIZE_RTX (arg_size[i]);
	    }
	  else
	    {
	      register tree size = size_in_bytes (TREE_TYPE (pval));
	      /* PUSH_ROUNDING has no effect on us, because
		 emit_push_insn for BLKmode is careful to avoid it.  */
	      excess = arg_size[i].constant - TREE_INT_CST_LOW (size);
	      size_rtx = expand_expr (size, 0, VOIDmode, 0);
	    }

	  emit_push_insn (tem, TYPE_MODE (TREE_TYPE (pval)), size_rtx,
			  TYPE_ALIGN (TREE_TYPE (pval)) / BITS_PER_UNIT,
			  partial[i], regvec[i], excess, argblock,
			  ARGS_SIZE_RTX (arg_offset[i]));
	}

      /* Account for the stack space thus used.  */


      current_args_size += arg_size[i].constant;
      if (arg_size[i].var)
	current_args_size += 1;
    }

  /* Perform postincrements before actually calling the function.  */
  emit_queue ();

  /* Pass the function the address in which to return a structure value.  */
  if (structure_value_addr)
    emit_move_insn (struct_value_rtx, structure_value_addr);

  /* All arguments and registers used for the call must be set up by now!  */

  /* ??? Other languages need a nontrivial second argument (static chain).  */
  funexp = prepare_call_address (funexp, 0);

  /* Mark all register-parms as living through the call.
     ??? This is not quite correct, since it doesn't indicate
     that they are in use immediately before the call insn.
     Currently that doesn't matter since explicitly-used regs
     won't be used for reloading.  But if the reloader becomes smarter,
     this will have to change somehow.  */
  for (i = 0; i < num_actuals; i++)
    if (regvec[i] != 0)
      {
	if (partial[i] > 0)
	  use_regs (REGNO (regvec[i]), partial[i]);
	else if (GET_MODE (regvec[i]) == BLKmode)
	  use_regs (REGNO (regvec[i]),
		    (int_size_in_bytes (TREE_TYPE (TREE_VALUE (argvec[i])))
		     / UNITS_PER_WORD));
	else
	  emit_insn (gen_rtx (USE, VOIDmode, regvec[i]));
      }

  if (structure_value_addr)
    emit_insn (gen_rtx (USE, VOIDmode, struct_value_rtx));

  /* Figure out the register where the value, if any, will come back.  */
  valreg = 0;
  if (TYPE_MODE (TREE_TYPE (exp)) != VOIDmode
      && TYPE_MODE (TREE_TYPE (exp)) != BLKmode)
    valreg = hard_function_value (TREE_TYPE (exp), fndecl);

  /* Generate the actual call instruction.  */
  emit_call_1 (funexp, funtype, args_size.constant,
	       FUNCTION_ARG (args_so_far, VOIDmode, void_type_node, 1),
	       valreg, old_current_args_size);

/* ???  Nothing has been done here to record control flow
   when contained functions can do nonlocal gotos.  */

  /* For calls to `setjmp', etc., inform flow.c it should complain
     if nonvolatile values are live.  */

  if (is_setjmp)
    emit_note (IDENTIFIER_POINTER (DECL_NAME (fndecl)), NOTE_INSN_SETJMP);

  /* If size of args is variable, restore saved stack-pointer value.  */

  if (args_size.var != 0)
    {
      emit_move_insn (stack_pointer_rtx, old_stack_level);
      pending_stack_adjust = old_pending_adj;
    }

  /* If value type not void, return an rtx for the value.  */

  if (TYPE_MODE (TREE_TYPE (exp)) == VOIDmode
      || ignore)
    return 0;

  if (structure_value_addr)
    {
      if (target)
	return target;
      return gen_rtx (MEM, BLKmode,
		      memory_address (BLKmode, structure_value_addr));
    }

 if (target && GET_MODE (target) == TYPE_MODE (TREE_TYPE (exp)))
    {
      if (!rtx_equal_p (target, valreg))
	emit_move_insn (target, valreg);
      else
	/* This tells expand_inline_function to copy valreg to its target.  */
	emit_insn (gen_rtx (USE, VOIDmode, valreg));
      return target;
    }
  return copy_to_reg (valreg);
}

/* Expand conditional expressions.  */

/* Generate code to evaluate EXP and jump to LABEL if the value is zero.
   LABEL is an rtx of code CODE_LABEL, in this function and all the
   functions here.  */

void
jumpifnot (exp, label)
     tree exp;
     rtx label;
{
  do_jump (exp, label, 0);
}

/* Generate code to evaluate EXP and jump to LABEL if the value is nonzero.  */

void
jumpif (exp, label)
     tree exp;
     rtx label;
{
  do_jump (exp, 0, label);
}

/* Generate code to evaluate EXP and jump to IF_FALSE_LABEL if
   the result is zero, or IF_TRUE_LABEL if the result is one.
   Either of IF_FALSE_LABEL and IF_TRUE_LABEL may be zero,
   meaning fall through in that case.

   This function is responsible for optimizing cases such as
   &&, || and comparison operators in EXP.  */

void
do_jump (exp, if_false_label, if_true_label)
     tree exp;
     rtx if_false_label, if_true_label;
{
  register enum tree_code code = TREE_CODE (exp);
  /* Some cases need to create a label to jump to
     in order to properly fall through.
     These cases set DROP_THROUGH_LABEL nonzero.  */
  rtx drop_through_label = 0;
  rtx temp;
  rtx comparison = 0;

  emit_queue ();

  switch (code)
    {
    case ERROR_MARK:
      break;

    case INTEGER_CST:
      temp = integer_zerop (exp) ? if_false_label : if_true_label;
      if (temp)
	emit_jump (temp);
      break;

    case ADDR_EXPR:
      /* The address of something can never be zero.  */
      if (if_true_label)
	emit_jump (if_true_label);
      break;
      
    case NOP_EXPR:
      do_jump (TREE_OPERAND (exp, 0), if_false_label, if_true_label);
      break;

    case TRUTH_NOT_EXPR:
      do_jump (TREE_OPERAND (exp, 0), if_true_label, if_false_label);
      break;

    case TRUTH_ANDIF_EXPR:
      if (if_false_label == 0)
	if_false_label = drop_through_label = gen_label_rtx ();
      do_jump (TREE_OPERAND (exp, 0), if_false_label, 0);
      do_jump (TREE_OPERAND (exp, 1), if_false_label, if_true_label);
      break;

    case TRUTH_ORIF_EXPR:
      if (if_true_label == 0)
	if_true_label = drop_through_label = gen_label_rtx ();
      do_jump (TREE_OPERAND (exp, 0), 0, if_true_label);
      do_jump (TREE_OPERAND (exp, 1), if_false_label, if_true_label);
      break;

    case COMPOUND_EXPR:
      expand_expr (TREE_OPERAND (exp, 0), const0_rtx, VOIDmode, 0);
      emit_queue ();
      do_jump (TREE_OPERAND (exp, 1), if_false_label, if_true_label);
      break;

    case COND_EXPR:
      {
	register rtx label1 = gen_label_rtx ();
	drop_through_label = gen_label_rtx ();
	do_jump (TREE_OPERAND (exp, 0), label1, 0);
	/* Now the THEN-expression.  */
	do_jump (TREE_OPERAND (exp, 1),
		 if_false_label ? if_false_label : drop_through_label,
		 if_true_label ? if_true_label : drop_through_label);
	emit_label (label1);
	/* Now the ELSE-expression.  */
	do_jump (TREE_OPERAND (exp, 2),
		 if_false_label ? if_false_label : drop_through_label,
		 if_true_label ? if_true_label : drop_through_label);
      }
      break;

    case EQ_EXPR:
      comparison = compare (exp, EQ, EQ, EQ, EQ);
      break;

    case NE_EXPR:
      comparison = compare (exp, NE, NE, NE, NE);
      break;

    case LT_EXPR:
      comparison = compare (exp, LT, LTU, GT, GTU);
      break;

    case LE_EXPR:
      comparison = compare (exp, LE, LEU, GE, GEU);
      break;

    case GT_EXPR:
      comparison = compare (exp, GT, GTU, LT, LTU);
      break;

    case GE_EXPR:
      comparison = compare (exp, GE, GEU, LE, LEU);
      break;

    default:
      temp = expand_expr (exp, 0, VOIDmode, 0);
      /* Copy to register to avoid generating bad insns by cse
	 from (set (mem ...) (arithop))  (set (cc0) (mem ...)).  */
      if (!cse_not_expected && GET_CODE (temp) == MEM)
	temp = copy_to_reg (temp);
      do_pending_stack_adjust ();
      {
	rtx zero;
	if (GET_MODE (temp) == SFmode)
	  zero = fconst0_rtx;
	else if (GET_MODE (temp) == DFmode)
	  zero = dconst0_rtx;
	else
	  zero = const0_rtx;

	if (GET_CODE (temp) == CONST_INT)
	  comparison = compare_constants (NE, 0,
					  INTVAL (temp), 0, BITS_PER_WORD);
	else if (GET_MODE (temp) != VOIDmode)
	  comparison = compare1 (temp, zero, NE, NE, 0, GET_MODE (temp));
	else
	  abort ();
      }
    }

  /* Do any postincrements in the expression that was tested.  */
  emit_queue ();

  /* If COMPARISON is nonzero here, it is an rtx that can be substituted
     straight into a conditional jump instruction as the jump condition.
     Otherwise, all the work has been done already.  */

  if (comparison == const1_rtx)
    {
      if (if_true_label)
	emit_jump (if_true_label);
    }
  else if (comparison == const0_rtx)
    {
      if (if_false_label)
	emit_jump (if_false_label);
    }
  else if (comparison)
    {
      if (if_true_label)
	{
	  emit_jump_insn (gen_rtx (SET, VOIDmode, pc_rtx,
				   gen_rtx (IF_THEN_ELSE, VOIDmode, comparison,
					    gen_rtx (LABEL_REF, VOIDmode,
						     if_true_label),
					    pc_rtx)));
	  if (if_false_label)
	    emit_jump (if_false_label);
	}
      else if (if_false_label)
	{
	  emit_jump_insn (gen_rtx (SET, VOIDmode, pc_rtx,
				   gen_rtx (IF_THEN_ELSE, VOIDmode, comparison,
					    pc_rtx,
					    gen_rtx (LABEL_REF, VOIDmode,
						     if_false_label))));
	}
    }

  if (drop_through_label)
    emit_label (drop_through_label);
}

/* Compare two integer constant rtx's, OP0 and OP1.
   The comparison operation is OPERATION.
   Return an rtx representing the value 1 or 0.
   WIDTH is the width in bits that is significant.  */

static rtx
compare_constants (operation, unsignedp, op0, op1, width)
     enum rtx_code operation;
     int unsignedp;
     int op0, op1;
     int width;
{
  int val;

  /* Sign-extend or zero-extend the operands to a full word
     from an initial width of WIDTH bits.  */
  if (width < HOST_BITS_PER_INT)
    {
      op0 &= (1 << width) - 1;
      op1 &= (1 << width) - 1;

      if (! unsignedp)
	{
	  if (op0 & (1 << (width - 1)))
	    op0 |= ((-1) << width);
	  if (op1 & (1 << (width - 1)))
	    op1 |= ((-1) << width);
	}
    }

  switch (operation)
    {
    case EQ:
      val = op0 == op1;
      break;

    case NE:
      val = op0 != op1;
      break;

    case GT:
    case GTU:
      val = op0 > op1;
      break;

    case LT:
    case LTU:
      val = op0 < op1;
      break;

    case GE:
    case GEU:
      val = op0 >= op1;
      break;

    case LE:
    case LEU:
      val = op0 <= op1;
    }

  return val ? const1_rtx : const0_rtx;
}

/* Generate code for a comparison expression EXP
   (including code to compute the values to be compared)
   and set (CC0) according to the result.
   SIGNED_FORWARD should be the rtx operation for this comparison for
   signed data; UNSIGNED_FORWARD, likewise for use if data is unsigned.
   SIGNED_REVERSE and UNSIGNED_REVERSE are used if it is desirable
   to interchange the operands for the compare instruction.

   We force a stack adjustment unless there are currently
   things pushed on the stack that aren't yet used.  */

static rtx
compare (exp, signed_forward, unsigned_forward,
	 signed_reverse, unsigned_reverse)
     register tree exp;
     enum rtx_code signed_forward, unsigned_forward;
     enum rtx_code signed_reverse, unsigned_reverse;
{

  register rtx op0 = expand_expr (TREE_OPERAND (exp, 0), 0, VOIDmode, 0);
  register rtx op1 = expand_expr (TREE_OPERAND (exp, 1), 0, VOIDmode, 0);
  register enum machine_mode mode = GET_MODE (op0);
  int unsignedp;

  /* If one operand is 0, make it the second one.  */

  if (op0 == const0_rtx || op0 == fconst0_rtx || op0 == dconst0_rtx)
    {
      rtx tem = op0;
      op0 = op1;
      op1 = tem;
      signed_forward = signed_reverse;
      unsigned_forward = unsigned_reverse;
    }

  if (flag_force_mem)
    {
      op0 = force_not_mem (op0);
      op1 = force_not_mem (op1);
    }

  do_pending_stack_adjust ();

  unsignedp = (TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (exp, 0)))
	       || TREE_UNSIGNED (TREE_TYPE (TREE_OPERAND (exp, 1))));

  if (GET_CODE (op0) == CONST_INT && GET_CODE (op1) == CONST_INT)
    return compare_constants (signed_forward, unsignedp,
			      INTVAL (op0), INTVAL (op1),
			      GET_MODE_BITSIZE (TYPE_MODE (TREE_TYPE (TREE_OPERAND (exp, 0)))));

  emit_cmp_insn (op0, op1,
		 (mode == BLKmode) ? expr_size (TREE_OPERAND (exp, 0)) : 0,
		 unsignedp);

  return gen_rtx ((unsignedp ? unsigned_forward : signed_forward),
		  VOIDmode, cc0_rtx, const0_rtx);
}

/* Like compare but expects the values to compare as two rtx's.
   The decision as to signed or unsigned comparison must be made by the caller.
   BLKmode is not allowed.  */

static rtx
compare1 (op0, op1, forward_op, reverse_op, unsignedp, mode)
     register rtx op0, op1;
     enum rtx_code forward_op, reverse_op;
     int unsignedp;
     enum machine_mode mode;
{
  /* If one operand is 0, make it the second one.  */

  if (op0 == const0_rtx || op0 == fconst0_rtx || op0 == dconst0_rtx)
    {
      rtx tem = op0;
      op0 = op1;
      op1 = tem;
      forward_op = reverse_op;
    }

  if (flag_force_mem)
    {
      op0 = force_not_mem (op0);
      op1 = force_not_mem (op1);
    }

  do_pending_stack_adjust ();

  if (GET_CODE (op0) == CONST_INT && GET_CODE (op1) == CONST_INT)
    return compare_constants (forward_op, unsignedp,
			      INTVAL (op0), INTVAL (op1),
			      GET_MODE_BITSIZE (mode));

  emit_cmp_insn (op0, op1, 0, unsignedp);

  return gen_rtx (forward_op, VOIDmode, cc0_rtx, const0_rtx);
}

/* Generate code to calculate EXP using a store-flag instruction
   and return an rtx for the result.
   If TARGET is nonzero, store the result there if convenient.

   Return zero if there is no suitable set-flag instruction
   available on this machine.  */

static rtx
do_store_flag (exp, target, mode)
     tree exp;
     rtx target;
     enum machine_mode mode;
{
  register enum tree_code code = TREE_CODE (exp);
  register rtx comparison = 0;
  enum machine_mode compare_mode;

  switch (code)
    {
#ifdef HAVE_seq
    case EQ_EXPR:
      if (HAVE_seq)
	{
	  comparison = compare (exp, EQ, EQ, EQ, EQ);
	  compare_mode = insn_operand_mode[(int) CODE_FOR_seq][0];
	}
      break;
#endif

#ifdef HAVE_sne
    case NE_EXPR:
      if (HAVE_sne)
	{
	  comparison = compare (exp, NE, NE, NE, NE);
	  compare_mode = insn_operand_mode[(int) CODE_FOR_sne][0];
	}
      break;
#endif

#if defined (HAVE_slt) && defined (HAVE_sltu) && defined (HAVE_sgt) && defined (HAVE_sgtu)
    case LT_EXPR:
      if (HAVE_slt && HAVE_sltu && HAVE_sgt && HAVE_sgtu)
	{
	  comparison = compare (exp, LT, LTU, GT, GTU);
	  compare_mode = insn_operand_mode[(int) CODE_FOR_slt][0];
	}
      break;

    case GT_EXPR:
      if (HAVE_slt && HAVE_sltu && HAVE_sgt && HAVE_sgtu)
	{
	  comparison = compare (exp, GT, GTU, LT, LTU);
	  compare_mode = insn_operand_mode[(int) CODE_FOR_slt][0];
	}
      break;
#endif

#if defined (HAVE_sle) && defined (HAVE_sleu) && defined (HAVE_sge) && defined (HAVE_sgeu)
    case LE_EXPR:
      if (HAVE_sle && HAVE_sleu && HAVE_sge && HAVE_sgeu)
	{
	  comparison = compare (exp, LE, LEU, GE, GEU);
	  compare_mode = insn_operand_mode[(int) CODE_FOR_sle][0];
	}
      break;

    case GE_EXPR:
      if (HAVE_sle && HAVE_sleu && HAVE_sge && HAVE_sgeu)
	{
	  comparison = compare (exp, GE, GEU, LE, LEU);
	  compare_mode = insn_operand_mode[(int) CODE_FOR_sle][0];
	}
      break;
#endif
    }
  if (comparison == 0)
    return 0;

  if (target == 0 || GET_MODE (target) != mode
      || (mode != compare_mode && GET_CODE (target) != REG))
    target = gen_reg_rtx (mode);

  /* Store the comparison in its proper mode.  */
  if (GET_MODE (target) != compare_mode)
    emit_insn (gen_rtx (SET, VOIDmode,
			gen_rtx (SUBREG, compare_mode, target, 0),
			comparison));
  else
    emit_insn (gen_rtx (SET, VOIDmode, target, comparison));

#if STORE_FLAG_VALUE != 1
  expand_bit_and (mode, target, const1_rtx, target);
#endif
  return target;
}

/* Generate a tablejump instruction (used for switch statements).  */

#ifdef HAVE_tablejump

/* INDEX is the value being switched on, with the lowest value
   in the table already subtracted.
   RANGE is the length of the jump table.
   TABLE_LABEL is a CODE_LABEL rtx for the table itself.

   DEFAULT_LABEL is a CODE_LABEL rtx to jump to if the
   index value is out of range.  */

void
do_tablejump (index, range, table_label, default_label)
     rtx index, range, table_label, default_label;
{
  register rtx temp;

  emit_cmp_insn (range, index, 0);
  emit_jump_insn (gen_bltu (default_label));
  /* If flag_force_addr were to affect this address
     it could interfere with the tricky assumptions made
     about addresses that contain label-refs,
     which may be valid only very near the tablejump itself.  */
  index = memory_address_noforce
    (CASE_VECTOR_MODE,
     gen_rtx (PLUS, Pmode,
	      gen_rtx (MULT, Pmode, index,
		       gen_rtx (CONST_INT, VOIDmode,
				GET_MODE_SIZE (CASE_VECTOR_MODE))),
	      gen_rtx (LABEL_REF, VOIDmode, table_label)));
  temp = gen_reg_rtx (CASE_VECTOR_MODE);
  convert_move (temp, gen_rtx (MEM, CASE_VECTOR_MODE, index), 0);

  emit_jump_insn (gen_tablejump (temp, table_label));
}

#endif /* HAVE_tablejump */
