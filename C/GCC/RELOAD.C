/* Search an insn for pseudo regs that must be in hard regs and are not.
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


/* This file contains subroutines used only from the file reload1.c.
   It knows how to scan one insn for operands and values
   that need to be copied into registers to make valid code.
   It also finds other operands and values which are valid
   but for which equivalent values in registers exist and
   ought to be used instead.

   Before processing the first insn of the function, call `init_reload'.

   To scan an insn, call `find_reloads'.  This does two things:
   1. sets up tables describing which values must be reloaded
   for this insn, and what kind of hard regs they must be reloaded into;
   2. optionally record the locations where those values appear in
   the data, so they can be replaced properly later.
   This is done only if the second arg to `find_reloads' is nonzero.

   The third arg to `find_reloads' specifies the value of `indirect_ok'.

   Then you must choose the hard regs to reload those pseudo regs into,
   and generate appropriate load insns before this insn and perhaps
   also store insns after this insn.  Set up the array `reload_reg_rtx'
   to contain the REG rtx's for the registers you used.  In some
   cases `find_reloads' will return a nonzero value in `reload_reg_rtx'
   for certain reloads.  Then that tells you which register to use,
   so you do not need to allocate one.  But you still do need to add extra
   instructions to copy the value into and out of that register.

   Finally you must call `subst_reloads' to substitute the reload reg rtx's
   into the locations already recorded.

NOTE SIDE EFFECTS:

   find_reloads can alter the operands of the instruction it is called on.

   1. Two operands of any sort may be interchanged, if they are in a
   commutative instruction.
   This happens only if find_reloads thinks the instruction will compile
   better that way.

   2. Pseudo-registers that are equivalent to constants are replaced
   with those constants if they are not in hard registers.

1 happens every time find_reloads is called.
2 happens only when REPLACE is 1, which is only when
actually doing the reloads, not when just counting them.
*/

#define REG_OK_STRICT

#include "config.h"
#include "rtl.h"
#include "insn-config.h"
#include "recog.h"
#include "reload.h"
#include "regs.h"
#include "hard-reg-set.h"

/* The variables set up by `find_reloads' are:

   n_reloads		  number of distinct reloads needed; max reload # + 1
       tables indexed by reload number
   reload_in		  rtx for value to reload from
   reload_out		  rtx for where to store reload-reg afterward if nec
			   (often the same as reload_in)
   reload_reg_class	  enum reg_class, saying what regs to reload into
   reload_inmode	  enum machine_mode; mode this operand should have
			   when reloaded, on input.
   reload_outmode	  enum machine_mode; mode this operand should have
			   when reloaded, on output.
   reload_strict_low	  char; 1 if this reload is inside a STRICT_LOW_PART.
   reload_optional	  char, nonzero for an optional reload.
			   Optional reloads are ignored unless the
			   value is already sitting in a register.
   reload_inc		  int, amount to increment reload_in by
			   before this insn.
   reload_reg_rtx	  rtx.  This is the register to reload into.
			   If it is zero when `find_reloads' returns,
			   you must find a suitable register in the class
			   specified by reload_reg_class, and store here
			   an rtx for that register with mode from
			   reload_inmode or reload_outmode.
   reload_nocombine	  char, nonzero if this reload shouldn't be
			   combined with another reload.  */

int n_reloads;

rtx reload_in[FIRST_PSEUDO_REGISTER];
rtx reload_out[FIRST_PSEUDO_REGISTER];
enum reg_class reload_reg_class[FIRST_PSEUDO_REGISTER];
enum machine_mode reload_inmode[FIRST_PSEUDO_REGISTER];
enum machine_mode reload_outmode[FIRST_PSEUDO_REGISTER];
char reload_strict_low[FIRST_PSEUDO_REGISTER];
rtx reload_reg_rtx[FIRST_PSEUDO_REGISTER];
char reload_optional[FIRST_PSEUDO_REGISTER];
int reload_inc[FIRST_PSEUDO_REGISTER];
char reload_nocombine[FIRST_PSEUDO_REGISTER];

/* Replacing reloads.

   If `replace_reloads' is nonzero, then as each reload is recorded
   an entry is made for it in the table `replacements'.
   Then later `subst_reloads' can look through that table and
   perform all the replacements needed.  */

/* Nonzero means record the places to replace.  */
static int replace_reloads;

/* Each replacement is recorded with a structure like this.  */
struct replacement
{
  rtx *where;			/* Location to store in */
  int what;			/* which reload this is for */
  enum machine_mode mode;	/* mode it must have */
};

static struct replacement replacements[MAX_RECOG_OPERANDS * ((MAX_REGS_PER_ADDRESS * 2) + 1)];

/* Number of replacements currently recorded.  */
static int n_replacements;

/* MEM-rtx's created for pseudo-regs in stack slots not directly addressable;
   (see reg_equiv_address).  */
static rtx memlocs[MAX_RECOG_OPERANDS * ((MAX_REGS_PER_ADDRESS * 2) + 1)];
static int n_memlocs;

/* The instruction we are doing reloads for;
   so we can test whether a register dies in it.  */
static rtx this_insn;

/* Nonzero means (MEM (REG n)) is valid even if (REG n) is spilled.  */
static int indirect_ok;

/* If hard_regs_live_known is nonzero,
   we can tell which hard regs are currently live,
   at least enough to succeed in choosing dummy reloads.  */
static int hard_regs_live_known;

/* Indexed by hard reg number,
   element is nonegative if hard reg has been spilled.
   This vector is passed to `find_reloads' as an argument
   and is not changed here.  */
static short *static_reload_reg_p;

/* Set to 1 in subst_reg_equivs if it changes anything.  */
static int subst_reg_equivs_changed;

static int alternative_allows_memconst ();
static rtx find_dummy_reload ();
static rtx find_reloads_toplev ();
static void find_reloads_address ();
static void find_reloads_address_1 ();
static int hard_reg_set_here_p ();
static int refers_to_regno_p ();
static rtx forget_volatility ();
static rtx subst_reg_equivs ();
static rtx subst_indexed_address ();
rtx find_equiv_reg ();
static int find_inc_amount ();

/* Record one reload that needs to be performed.
   IN is an rtx saying where the data are to be found before this instruction.
   OUT says where they must be stored after the instruction.
   (IN is zero for data not read, and OUT is zero for data not written.)
   INLOC and OUTLOC point to the places in the instructions where
   IN and OUT were found.
   CLASS is a register class required for the reloaded data.
   INMODE is the machine mode that the instruction requires
   for the reg that replaces IN and OUTMODE is likewise for OUT.

   If IN is zero, then OUT's location and mode should be passed as
   INLOC and INMODE.

   STRICT_LOW is the 1 if there is a containing STRICT_LOW_PART rtx.

   OPTIONAL nonzero means this reload does not need to be performed:
   it can be discarded if that is more convenient.  */
   
static int
push_reload (in, out, inloc, outloc, class,
	     inmode, outmode, strict_low, optional)
     register rtx in, out;
     rtx *inloc, *outloc;
     enum reg_class class;
     enum machine_mode inmode, outmode;
     int strict_low;
     int optional;
{
  register int i;
  int noshare = 0;

  /* Compare two RTX's.  */
#define MATCHES(x, y) (x == y || (x != 0 && GET_CODE (x) != REG && rtx_equal_p (x, y)))

  /* If IN is a pseudo register everywhere-equivalent to a constant, and 
     it is not in a hard register, reload straight from the constant,
     since we want to get rid of such pseudo registers.  */
  if (in != 0 && GET_CODE (in) == REG)
    {
      register int regno = REGNO (in);

      if (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	in = reg_equiv_constant[regno];
    }

  /* Likewise for OUT.  Of course, OUT will never be equivalent to
     an actual constant, but it might be equivalent to a memory location
     (in the case of a parameter).  */
  if (out != 0 && GET_CODE (out) == REG)
    {
      register int regno = REGNO (out);

      if (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	out = reg_equiv_constant[regno];
    }

  /* If we have a read-write operand with an address side-effect,
     change either IN or OUT so the side-effect happens only once.  */
  if (in != 0 && out != 0 && GET_CODE (in) == MEM && rtx_equal_p (in, out))
    {
      if (GET_CODE (XEXP (in, 0)) == POST_INC
	  || GET_CODE (XEXP (in, 0)) == POST_DEC)
	in = gen_rtx (MEM, GET_MODE (in), XEXP (XEXP (in, 0), 0));
      if (GET_CODE (XEXP (in, 0)) == PRE_INC
	  || GET_CODE (XEXP (in, 0)) == PRE_DEC)
	out = gen_rtx (MEM, GET_MODE (out), XEXP (XEXP (out, 0), 0));
    }

  /* If IN appears in OUT, we can't share any input-only reload for IN.  */
  if (in != 0 && out != 0 && reg_mentioned_p (in, out))
    noshare = 1;

  if (class == NO_REGS)
    abort ();

  /* Narrow down the class of register wanted if that is
     desirable on this machine for efficiency.  */
  if (in != 0)
    class = PREFERRED_RELOAD_CLASS(in, class);

  /* We can use an existing reload if the class is right
     and at least one of IN and OUT is a match
     and the other is at worst neutral.
     (A zero compared against anything is neutral.)  */
  for (i = 0; i < n_reloads; i++)
    if (reload_reg_class[i] == class
	&& reload_strict_low[i] == strict_low
	&& ((in != 0 && MATCHES (reload_in[i], in) && ! noshare
	     && (out == 0 || reload_out[i] == 0 || MATCHES (reload_out[i], out)))
	    ||
	    (out != 0 && MATCHES (reload_out[i], out)
	     && (in == 0 || reload_in[i] == 0 || MATCHES (reload_in[i], in)))))
      break;

  if (i == n_reloads)
    {
      /* We found no existing reload suitable for re-use.
	 So add an additional reload.  */

      reload_in[i] = in;
      reload_out[i] = out;
      reload_reg_class[i] = class;
      reload_inmode[i] = inmode;
      reload_outmode[i] = outmode;
      reload_reg_rtx[i] = 0;
      reload_optional[i] = optional;
      reload_inc[i] = 0;
      reload_strict_low[i] = strict_low;
      reload_nocombine[i] = 0;

      n_reloads++;
    }
  else
    {
      /* We are reusing an existing reload,
	 but we may have additional information for it.
	 For example, we may now have both IN and OUT
	 while the old one may have just one of them.  */

      if (inmode != VOIDmode)
	reload_inmode[i] = inmode;
      if (outmode != VOIDmode)
	reload_outmode[i] = outmode;
      if (in != 0)
	reload_in[i] = in;
      if (out != 0)
	reload_out[i] = out;
      reload_optional[i] &= optional;
    }

  /* If the ostensible rtx being reload differs from the rtx found
     in the location to substitute, this reload is not safe to combine
     because we cannot reliably tell whether it appears in the insn.  */

  if (in != 0 && in != *inloc)
    reload_nocombine[i] = 1;

  /* If this is an IN/OUT reload in an insn that sets the CC,
     it must be for an autoincrement.  It doesn't work to store
     the incremented value after the insn because that would clobber the CC.
     So we must do the increment of the value reloaded from,
     increment it, store it back, then decrement again.  */
  if (out != 0 && GET_CODE (PATTERN (this_insn)) == SET
      && SET_DEST (PATTERN (this_insn)) == cc0_rtx)
    {
      out = 0;
      reload_out[i] = 0;
      reload_inc[i] = find_inc_amount (PATTERN (this_insn), in);
      /* If we did not find a nonzero amount-to-increment-by,
	 that contradicts the belief that IN is being incremented
	 in an address in this insn.  */
      if (reload_inc[i] == 0)
	abort ();
    }

  /* If we will replace IN and OUT with the reload-reg,
     record where they are located so that substitution need
     not do a tree walk.  */

  if (replace_reloads)
    {
      if (inloc != 0)
	{
	  register struct replacement *r = &replacements[n_replacements++];
	  r->what = i;
	  r->where = inloc;
	  r->mode = inmode;
	}
      if (outloc != 0 && outloc != inloc)
	{
	  register struct replacement *r = &replacements[n_replacements++];
	  r->what = i;
	  r->where = outloc;
	  r->mode = outmode;
	}
    }

  /* If this reload is just being introduced and it has both
     an incoming quantity and an outgoing quantity that are
     supposed to be made to match, see if either one of the two
     can serve as the place to reload into.

     If one of them is acceptable, set reload_reg_rtx[i]
     to that one.  */

  if (in != 0 && out != 0 && in != out && reload_reg_rtx[i] == 0)
    {
      reload_reg_rtx[i] = find_dummy_reload (in, out, inloc, outloc,
					     reload_reg_class[i], i);

      /* If the outgoing register already contains the same value
	 as the incoming one, we can dispense with loading it.
	 The easiest way to tell the caller that is to give a phony
	 value for the incoming operand (same as outgoing one).  */
      if (reload_reg_rtx[i] == out
	  && (GET_CODE (in) == REG || CONSTANT_P (in))
	  && 0 != find_equiv_reg (in, this_insn, 0, REGNO (out),
				  static_reload_reg_p, i, inmode))
	reload_in[i] = out;
    }

  return i;
}

/* Record an additional place we must replace a value
   for which we have already recorded a reload.
   RELOADNUM is the value returned by push_reload
   when the reload was recorded.
   This is used in insn patterns that use match_dup.  */

static void
push_replacement (loc, reloadnum, mode)
     rtx *loc;
     int reloadnum;
     enum machine_mode mode;
{
  if (replace_reloads)
    {
      register struct replacement *r = &replacements[n_replacements++];
      r->what = reloadnum;
      r->where = loc;
      r->mode = mode;
    }
}

/* If there is only one output reload, try to combine it
   with a (logically unrelated) input reload
   to reduce the number of reload registers needed.

   This is safe if the input reload does not appear in
   the value being output-reloaded, because this implies
   it is not needed any more once the original insn completes.  */

static void
combine_reloads ()
{
  int i;
  int output_reload = -1;

  /* Find the output reload; return unless there is exactly one
     and that one is mandatory.  */

  for (i = 0; i < n_reloads; i++)
    if (reload_out[i] != 0)
      {
	if (output_reload >= 0)
	  return;
	output_reload = i;
      }

  if (output_reload < 0 || reload_optional[output_reload])
    return;

  /* An input-output reload isn't combinable.  */

  if (reload_in[output_reload] != 0)
    return;

  /* Check each input reload; can we combine it?  */

  for (i = 0; i < n_reloads; i++)
    if (reload_in[i] && ! reload_optional[i] && ! reload_nocombine[i]
	&& reload_inmode[i] == reload_outmode[output_reload]
	&& reload_inc[i] == 0
	&& reload_reg_rtx[i] == 0
	&& reload_strict_low[i] == 0
	&& reload_reg_class[i] == reload_reg_class[output_reload]
	&& ! reg_mentioned_p (reload_in[i], reload_out[output_reload]))
      {
	int j;

	/* We have found a reload to combine with!  */
	reload_out[i] = reload_out[output_reload];
	reload_outmode[i] = reload_outmode[output_reload];
	/* Mark the old output reload as inoperative.  */
	reload_out[output_reload] = 0;

	/* Transfer all replacements from the old reload to the combined.  */
	for (j = 0; j < n_replacements; j++)
	  if (replacements[j].what == output_reload)
	    replacements[j].what = i;

	return;
      }
}

/* Try to find a reload register for an in-out reload (expressions IN and OUT).
   See if one of IN and OUT is a register that may be used;
   this is desirable since a spill-register won't be needed.
   If so, return the register rtx that proves acceptable.

   INLOC and OUTLOC are locations where IN and OUT appear in the insn.
   CLASS is the register class required for the reload.

   If FOR_REAL is >= 0, it is the number of the reload,
   and in some cases when it can be discovered that OUT doesn't need
   to be computed, clear out reload_out[FOR_REAL].

   If FOR_REAL is -1, this should not be done, because this call
   is just to see if a register can be found, not to find and install it.  */

static rtx
find_dummy_reload (in, out, inloc, outloc, class, for_real)
     rtx in, out;
     rtx *inloc, *outloc;
     enum reg_class class;
     int for_real;
{
  rtx value = 0;
  rtx orig_in = in;

  while (GET_CODE (out) == SUBREG)
    out = SUBREG_REG (out);
  while (GET_CODE (in) == SUBREG)
    in = SUBREG_REG (in);

  /* If operands exceed a word, we can't use either of them
     unless they have the same size.  */
  if (GET_MODE_SIZE (GET_MODE (out)) != GET_MODE_SIZE (GET_MODE (in))
      && (GET_MODE_SIZE (GET_MODE (out)) > UNITS_PER_WORD
	  || GET_MODE_SIZE (GET_MODE (in)) > UNITS_PER_WORD))
    return 0;

  /* See if OUT will do.  */
  if (GET_CODE (out) == REG)
    {
      register int regno = REGNO (out);

      /* When we consider whether the insn uses OUT,
	 ignore references within IN.  They don't prevent us
	 from copying IN into OUT, because those refs would
	 move into the insn that reloads IN.

	 However, we only ignore IN in its role as this operand.
	 If the insn uses IN elsewhere and it contains OUT,
	 that counts.  We can't be sure it's the "same" operand
	 so it might not go through this reload.  */
      *inloc = const0_rtx;

      if (reg_renumber[regno] >= 0)
	regno = reg_renumber[regno];
      if (regno < FIRST_PSEUDO_REGISTER
	  && ! refers_to_regno_p (regno, PATTERN (this_insn), outloc)
	  && TEST_HARD_REG_BIT (reg_class_contents[(int) class], regno))
	value = out;

      *inloc = orig_in;
    }

  /* Consider using IN if OUT was not acceptable
     or if OUT dies in this insn (like the quotient in a divmod insn).
     We can't use IN unless it is free after this insn,
     which means we must know accurately which hard regs are live.
     Also, the result can't go in IN if IN is used within OUT.  */
  if (hard_regs_live_known
      && GET_CODE (in) == REG
      && (value == 0
	  || find_regno_note (this_insn, REG_DEAD, REGNO (value))))
    {
      register int regno = REGNO (in);
      if (find_regno_note (this_insn, REG_DEAD, regno))
	{
	  if (reg_renumber[regno] >= 0)
	    regno = reg_renumber[regno];
	  if (regno < FIRST_PSEUDO_REGISTER
	      && ! refers_to_regno_p (regno, out, 0)
	      && ! hard_reg_set_here_p (regno, PATTERN (this_insn))
	      && TEST_HARD_REG_BIT (reg_class_contents[(int) class], regno))
	    {
	      /* If we were going to use OUT as the reload reg
		 and changed our mind, it means OUT is a dummy that
		 dies here.  So don't bother copying value to it.  */
	      if (for_real >= 0 && value == out)
		reload_out[for_real] = 0;
	      value = in;
	    }
	}
    }

  return value;
}

/* This page contains subroutines used mainly for determining
   whether the IN or an OUT of a reload can serve as the
   reload register.  */

/* Return 1 if hard reg number REGNO is stored in by expression X,
   either explicitly or in the guise of a pseudo-reg allocated to REGNO.
   X should be the body of an instruction.  */

static int
hard_reg_set_here_p (regno, x)
     register int regno;
     rtx x;
{
  if (GET_CODE (x) == SET)
    {
      register rtx op0 = SET_DEST (x);
      if (GET_CODE (op0) == REG)
	{
	  register int r = REGNO (op0);
	  if (reg_renumber[r] >= 0)
	    r = reg_renumber[r];
	  if (r == regno)
	    return 1;
	}
    }
  else if (GET_CODE (x) == PARALLEL)
    {
      register int i = XVECLEN (x, 0) - 1;
      for (; i >= 0; i--)
	if (hard_reg_set_here_p (regno, XVECEXP (x, 0, i)))
	  return 1;
    }

  return 0;
}

/* Return nonzero if hard register REGNO appears 
   either explicitly or implicitly in X
   other than being stored into.

   References contained within the substructure at LOC do not count.
   LOC may be zero, meaning don't ignore anything.  */

static int
refers_to_regno_p (regno, x, loc)
     int regno;
     rtx x;
     rtx *loc;
{
  register int i;
  register RTX_CODE code;
  register char *fmt;

 repeat:
  code = GET_CODE (x);
  if (code == REG)
    {
      i = REGNO (x);
      if (reg_renumber[i] >= 0)
	i = reg_renumber[i];
      return i == regno;
    }

  if (code == SET)
    {
      if (GET_CODE (SET_DEST (x)) != REG
	  && refers_to_regno_p (regno, SET_DEST (x), loc))
	return 1;
      if (loc == &SET_SRC (x))
	return 0;
      x = SET_SRC (x);
      goto repeat;
    }

  /* X does not match, so try its subexpressions.  */

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e' && loc != &XEXP (x, i))
	{
	  if (i == 0)
	    {
	      x = XEXP (x, 0);
	      goto repeat;
	    }
	  else
	    if (refers_to_regno_p (regno, XEXP (x, i), loc))
	      return 1;
	}
      else if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = XVECLEN (x, i) - 1; j >=0; j--)
	    if (loc != &XVECEXP (x, i, j)
		&& refers_to_regno_p (regno, XVECEXP (x, i, j), loc))
	      return 1;
	}
    }
  return 0;
}

/* Return 1 if ADDR is a valid memory address for mode MODE,
   and check that each pseudo reg has the proper kind of
   hard reg.  */

int
strict_memory_address_p (mode, addr)
     enum machine_mode mode;
     register rtx addr;
{
  GO_IF_LEGITIMATE_ADDRESS (mode, addr, win);
  return 0;

 win:
  return 1;
}


/* Like rtx_equal_p except that it allows a REG and a SUBREG to match
   if they are the same hard reg, and has special hacks for
   autoincrement and autodecrement.
   This is specifically intended for find_reloads to use
   in determining whether two operands match.
   X is the operand whose number is the lower of the two.

   The value is 2 if Y contains a pre-increment that matches
   a non-incrementing address in X.  */

/* ??? To be completely correct, we should arrange to pass
   for X the output operand and for Y the input operand.
   For now, we assume that the output operand has the lower number
   because that is natural in (SET output (... input ...)).  */

int
operands_match_p (x, y)
     register rtx x, y;
{
  register int i;
  register RTX_CODE code = GET_CODE (x);
  register char *fmt;
  int success_2;
      
  if (x == y)
    return 1;
  if ((code == REG || (code == SUBREG && GET_CODE (SUBREG_REG (x)) == REG))
      && (GET_CODE (y) == REG || (GET_CODE (y) == SUBREG
				  && GET_CODE (SUBREG_REG (y)) == REG)))
    {
      register int j;

      if (code == SUBREG)
	{
	  i = REGNO (SUBREG_REG (x));
	  if (i >= FIRST_PSEUDO_REGISTER)
	    goto slow;
	  i += SUBREG_WORD (x);
	}
      else
	i = REGNO (x);

      if (GET_CODE (y) == SUBREG)
	{
	  j = REGNO (SUBREG_REG (y));
	  if (j >= FIRST_PSEUDO_REGISTER)
	    goto slow;
	  j += SUBREG_WORD (y);
	}
      else
	j = REGNO (y);

      return i == j;
    }
  /* If two operands must match, because they are really a single
     operand of an assembler insn, then two postincrements are invalid
     because the assembler insn would increment only once.
     On the other hand, an postincrement matches ordinary indexing
     if the postincrement is the output operand.  */
  if (code == POST_DEC || code == POST_INC)
    return operands_match_p (XEXP (x, 0), y);
  /* Two preincrements are invalid
     because the assembler insn would increment only once.
     On the other hand, an preincrement matches ordinary indexing
     if the preincrement is the input operand.
     In this case, return 2, since some callers need to do special
     things when this happens.  */
  if (GET_CODE (y) == PRE_DEC || GET_CODE (y) == PRE_INC)
    return operands_match_p (x, XEXP (y, 0)) ? 2 : 0;
  /* Now we have disposed of all the cases 
     in which different rtx codes can match.  */
  if (code != GET_CODE (y))
    return 0;
  if (code == LABEL_REF)
    return XEXP (x, 0) == XEXP (y, 0);
  if (code == SYMBOL_REF)
    return XSTR (x, 0) == XSTR (y, 0);

 slow:
  /* (MULT:SI x y) and (MULT:HI x y) are NOT equivalent.  */

  if (GET_MODE (x) != GET_MODE (y))
    return 0;

  /* Compare the elements.  If any pair of corresponding elements
     fail to match, return 0 for the whole things.  */

  success_2 = 0;
  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      int val;
      switch (fmt[i])
	{
	case 'i':
	  if (XINT (x, i) != XINT (y, i))
	    return 0;
	  break;

	case 'e':
	  val = operands_match_p (XEXP (x, i), XEXP (y, i));
	  if (val == 0)
	    return 0;
	  /* If any subexpression returns 2,
	     we should return 2 if we are successful.  */
	  if (val == 2)
	    success_2 = 1;
	  break;

	case '0':
	  break;

	  /* It is believed that rtx's at this level will never
	     contain anything but integers and other rtx's,
	     except for within LABEL_REFs and SYMBOL_REFs.  */
	default:
	  abort ();
	}
    }
  return 1 + success_2;
}

/* Main entry point of this file: search the body of INSN
   for values that need reloading and record them with push_reload.
   REPLACE nonzero means record also where the values occur
   so that subst_reloads can be used.
   IND_OK says that a memory reference is a valid memory address.

   LIVE_KNOWN says we have valid information about which hard
   regs are live at each point in the program; this is true when
   we are called from global_alloc but false when stupid register
   allocation has been done.

   RELOAD_REG_P if nonzero is a vector indexed by hard reg number
   which is nonnegative if the reg has been commandeered for reloading into.
   It is copied into STATIC_RELOAD_REG_P and referenced from there
   by various subroutines.  */

void
find_reloads (insn, replace, ind_ok, live_known, reload_reg_p)
     rtx insn;
     int replace, ind_ok;
     int live_known;
     short *reload_reg_p;
{
#ifdef REGISTER_CONSTRAINTS

  enum reload_modified { RELOAD_NOTHING, RELOAD_READ, RELOAD_READ_WRITE, RELOAD_WRITE };

  register int insn_code_number;
  register int i;
  int noperands;
  /* These are the constraints for the insn.  We don't change them.  */
  char *constraints1[MAX_RECOG_OPERANDS];
  /* These start out as the constraints for the insn
     and they are chewed up as we consider alternatives.  */
  char *constraints[MAX_RECOG_OPERANDS];
  int this_alternative[MAX_RECOG_OPERANDS];
  char this_alternative_win[MAX_RECOG_OPERANDS];
  char this_alternative_offmemok[MAX_RECOG_OPERANDS];
  char this_alternative_earlyclobber[MAX_RECOG_OPERANDS];
  int this_alternative_matches[MAX_RECOG_OPERANDS];
  int swapped;
  int goal_alternative[MAX_RECOG_OPERANDS];
  int this_alternative_number;
  int goal_alternative_number;
  int operand_reloadnum[MAX_RECOG_OPERANDS];
  int goal_alternative_matches[MAX_RECOG_OPERANDS];
  int goal_alternative_matched[MAX_RECOG_OPERANDS];
  char goal_alternative_win[MAX_RECOG_OPERANDS];
  char goal_alternative_offmemok[MAX_RECOG_OPERANDS];
  int goal_alternative_swapped;
  enum reload_modified modified[MAX_RECOG_OPERANDS];
  int best;
  int commutative;
  char operands_match[MAX_RECOG_OPERANDS][MAX_RECOG_OPERANDS];
  rtx substed_operand[MAX_RECOG_OPERANDS];
  rtx body = PATTERN (insn);
  int goal_earlyclobber, this_earlyclobber;
  enum machine_mode operand_mode[MAX_RECOG_OPERANDS];

  this_insn = insn;
  n_reloads = 0;
  n_replacements = 0;
  n_memlocs = 0;
  replace_reloads = replace;
  indirect_ok = ind_ok;
  hard_regs_live_known = live_known;
  static_reload_reg_p = reload_reg_p;

  /* Find what kind of insn this is.  NOPERANDS gets number of operands.
     Make OPERANDS point to a vector of operand values.
     Make OPERAND_LOCS point to a vector of pointers to
     where the operands were found.
     Fill CONSTRAINTS and CONSTRAINTS1 with pointers to the
     constraint-strings for this insn.
     Return if the insn needs no reload processing.  */

  switch (GET_CODE (body))
    {
    case USE:
    case CLOBBER:
    case ASM_INPUT:
    case ADDR_VEC:
    case ADDR_DIFF_VEC:
      return;

    case SET:
      /* Dispose quickly of (set (reg..) (reg..)) if both have hard regs.  */
      if (GET_CODE (SET_DEST (body)) == REG
	  && REGNO (SET_DEST (body)) < FIRST_PSEUDO_REGISTER
	  && GET_CODE (SET_SRC (body)) == REG
	  && REGNO (SET_SRC (body)) < FIRST_PSEUDO_REGISTER)
	return;
    case PARALLEL:
      noperands = asm_noperands (body);
      if (noperands > 0)
	{
	  /* This insn is an `asm' with operands.  */

	  insn_code_number = -1;

	  /* expand_asm_operands makes sure there aren't too many operands.  */
	  if (noperands > MAX_RECOG_OPERANDS)
	    abort ();

	  /* Now get the operand values and constraints out of the insn.  */

	  decode_asm_operands (body, recog_operand, recog_operand_loc,
			       constraints, operand_mode);
	  bcopy (constraints, constraints1, noperands * sizeof (char *));
	  break;
	}

    default:
      /* Ordinary insn: recognize it, allocate space for operands and
	 constraints, and get them out via insn_extract.  */

      insn_code_number = recog_memoized (insn);
      noperands = insn_n_operands[insn_code_number];
      insn_extract (insn);
      {
	/* Nonzero if some operand has a nonnull constraint.
	   If none has, we have no work to do.
	   Even a general_operand should have `g' in its constraint.  */
	int have_constraints = 0;

	for (i = 0; i < noperands; i++)
	  {
	    constraints[i] = constraints1[i]
	      = insn_operand_constraint[insn_code_number][i];
	    operand_mode[i] = insn_operand_mode[insn_code_number][i];
	    if (constraints[i] != 0)
	      have_constraints = 1;
	  }
	if (!have_constraints)
	  return;
      }
    }

  if (noperands == 0)
    return;

  commutative = -1;

  /* If we will need to know, later, whether some pair of operands
     are the same, we must compare them now and save the result.
     Reloading the base and index registers will clobber them
     and afterward they will fail to match.  */

  for (i = 0; i < noperands; i++)
    {
      register char *p;
      register int c;

      substed_operand[i] = recog_operand[i];
      p = constraints[i];

      /* Scan this operand's constraint to see if it should match another.  */

      while (c = *p++)
	if (c == '%')
	  commutative = i;
	else if (c >= '0' && c <= '9')
	  {
	    c -= '0';
	    operands_match[c][i]
	      = operands_match_p (recog_operand[c], recog_operand[i]);
	    /* If C can be commuted with C+1, and C might need to match I,
	       then C+1 might also need to match I.  */
	    if (commutative >= 0)
	      {
		if (c == commutative || c == commutative + 1)
		  {
		    int other = c + (c == commutative ? 1 : -1);
		    operands_match[other][i]
		      = operands_match_p (recog_operand[other], recog_operand[i]);
		  }
		if (i == commutative || i == commutative + 1)
		  {
		    int other = i + (i == commutative ? 1 : -1);
		    operands_match[c][other]
		    = operands_match_p (recog_operand[c], recog_operand[other]);
		  }
		/* Note that C is supposed to be less than I.
		   No need to consider altering both C and I
		   because in that case we would alter one into the other.  */
	      }
	  }
    }

  /* Examine each operand that is a memory reference or memory address
     and reload parts of the addresses into index registers.
     While we are at it, initialize the array `modified'.
     Also here any references to pseudo regs that didn't get hard regs
     but are equivalent to constants get replaced in the insn itself
     with those constants.  Nobody will ever see them again.  */

  for (i = 0; i < noperands; i++)
    {
      register RTX_CODE code = GET_CODE (recog_operand[i]);
      modified[i] = RELOAD_READ;
      if (constraints[i][0] == 'p')
	{
	  find_reloads_address (VOIDmode, 0,
				recog_operand[i], recog_operand_loc[i]);
	  substed_operand[i] = recog_operand[i] = *recog_operand_loc[i];
	}
      else if (code == MEM)
	{
	  find_reloads_address (GET_MODE (recog_operand[i]),
				recog_operand_loc[i],
				XEXP (recog_operand[i], 0),
				&XEXP (recog_operand[i], 0));
	  substed_operand[i] = recog_operand[i] = *recog_operand_loc[i];
	}
      else if (code == SUBREG)
	find_reloads_toplev (recog_operand[i]);
      else if (code == REG)
	{
	  /* This is equivalent to calling find_reloads_toplev.
	     The code is duplicated for speed.  */
	  register int regno = REGNO (recog_operand[i]);
	  if (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	      && reg_equiv_constant[regno] != 0)
	    substed_operand[i] = recog_operand[i]
	      = reg_equiv_constant[regno];
	  if (reg_equiv_address[regno] != 0)
	    {
	      *recog_operand_loc[i] = recog_operand[i]
		= gen_rtx (MEM, GET_MODE (recog_operand[i]),
			   reg_equiv_address[regno]);
	      find_reloads_address (GET_MODE (recog_operand[i]),
				    recog_operand_loc[i],
				    XEXP (recog_operand[i], 0),
				    &XEXP (recog_operand[i], 0));
	      substed_operand[i] = recog_operand[i] = *recog_operand_loc[i];
	    }
	}
    }

  /* Now see what we need for pseudo-regs that didn't get hard regs
     or got the wrong kind of hard reg.  For this, we must consider
     all the operands together against the register constraints.  */

  best = MAX_RECOG_OPERANDS + 100;

  swapped = 0;
 try_swapped:
  this_alternative_number = 0;
  /* The constraints are made of several alternatives.
     Each operand's constraint looks like foo,bar,... with commas
     separating the alternatives.  The first alternatives for all
     operands go together, the second alternatives go together, etc.

     First loop over alternatives.  */

  while (*constraints[0])
    {
      /* Loop over operands for one constraint alternative.  */
      /* LOSERS counts those that don't fit this alternative
	 and would require loading.  */
      int losers = 0;
      /* BAD is set to 1 if it some operand can't fit this alternative
	 even after reloading.  */
      int bad = 0;
      /* REJECT is a count of how undesirable this alternative says it is
	 if any reloading is required.  If the alternative matches exactly
	 then REJECT is ignored, but otherwise it gets this much
	 counted against it in addition to the reloading needed.  */
      int reject = 0;

      this_earlyclobber = 0;

      for (i = 0; i < noperands; i++)
	{
	  register char *p = constraints[i];
	  register int win = 0;
	  int badop = 1;
	  int c;
	  register rtx operand = recog_operand[i];
	  int offset = 0;
	  int force_reload = 0;
	  int offmemok = 0;
	  int earlyclobber = 0;

	  /* If the operand is a SUBREG, extract
	     the REG or MEM within.  */

	  while (GET_CODE (operand) == SUBREG)
	    {
	      offset += SUBREG_WORD (operand);
	      operand = SUBREG_REG (operand);
	      if (GET_CODE (operand) == MEM
/*** This is overcautious, as for BYTES_BIG_ENDIAN it is still possible
     to avoid setting force_reload if the mode of the subreg
     is SImode or bigger.  */
#ifndef BYTES_BIG_ENDIAN
		  && offset != 0
#endif
		  && !offsetable_memref_p (operand))
		force_reload = 1;
	    }

	  this_alternative[i] = (int) NO_REGS;
	  this_alternative_win[i] = 0;
	  this_alternative_offmemok[i] = 0;
	  this_alternative_earlyclobber[i] = 0;
	  this_alternative_matches[i] = -1;

	  /* Scan this alternative's specs for this operand;
	     set WIN if the operand fits any letter in this alternative.
	     Otherwise, clear BADOP if this operand could
	     fit some letter after reloads. */

	  while (*p && (c = *p++) != ',')
	    switch (c)
	      {
	      case '=':
		modified[i] = RELOAD_WRITE;
		break;

	      case '+':
		modified[i] = RELOAD_READ_WRITE;
		break;

	      case '*':
		break;

	      case '%':
		commutative = i;
		break;

	      case '?':
		reject++;
		break;

	      case '!':
		reject = 100;
		break;

	      case '#':
		/* Ignore rest of this alternative as far as
		   reloading is concerned.  */
		while (*p && *p != ',') p++;
		break;

	      case '0':
	      case '1':
	      case '2':
	      case '3':
	      case '4':
		c -= '0';
		this_alternative_matches[i] = c;
		/* We are supposed to match a previous operand.
		   If we do, we win if that one did.
		   If we do not, count both of the operands as losers.
		   (This is too conservative, since most of the time
		   only a single reload insn will be needed to make
		   the two operands win.  As a result, this alternative
		   may be rejected when it is actually desirable.)  */
		if ((swapped && (c != commutative || i != commutative + 1))
		    /* If we are matching as if two operands were swapped,
		       also pretend that operands_match had been computed
		       with swapped.
		       But if I is the second of those and C is the first,
		       don't exchange them, because operands_match is valid
		       only on one side of its diagonal.  */
		    ? (operands_match
		        [(c == commutative || c == commutative + 1)
			 ? 2*commutative + 1 - c : c]
		        [(i == commutative || i == commutative + 1)
			 ? 2*commutative + 1 - i : i])
		    : operands_match[c][i])
		  win = this_alternative_win[c];
		else
		  {
		    /* Operands don't match.  */
		    rtx value;
		    /* Retroactively mark the operand we had to match
		       as a loser, if it wasn't already.  */
		    if (this_alternative_win[c])
		      losers++;
		    this_alternative_win[c] = 0;
		    if (this_alternative[c] == (int) NO_REGS)
		      bad = 1;
		    /* But count the pair only once in the total badness of
		       this alternative, if the pair can be a dummy reload.  */
		    value
		      = find_dummy_reload (recog_operand[i], recog_operand[c],
					   recog_operand_loc[i], recog_operand_loc[c],
					   this_alternative[c], -1);

		    if (value != 0)
		      losers--;
		  }
		/* This can be fixed with reloads if the operand
		   we are supposed to match can be fixed with reloads.  */
		badop = 0;
		break;

	      case 'p':
		/* All necessary reloads for an address_operand
		   were handled in find_reloads_address.  */
		this_alternative[i] = (int) ALL_REGS;
		win = 1;
		break;

	      case 'm':
		if (GET_CODE (operand) == MEM
		    || (GET_CODE (operand) == REG
			&& REGNO (operand) >= FIRST_PSEUDO_REGISTER
			&& reg_renumber[REGNO (operand)] < 0))
		  win = 1;
		if (GET_CODE (operand) == CONST_DOUBLE)
		  badop = 0;
		break;

	      case '<':
		if (GET_CODE (operand) == MEM
		    && (GET_CODE (XEXP (operand, 0)) == PRE_DEC
			|| GET_CODE (XEXP (operand, 0)) == POST_DEC))
		  win = 1;
		break;

	      case '>':
		if (GET_CODE (operand) == MEM
		    && (GET_CODE (XEXP (operand, 0)) == PRE_INC
			|| GET_CODE (XEXP (operand, 0)) == POST_INC))
		  win = 1;
		break;

		/* Memory operand whose address is offsettable.  */
	      case 'o':
		if ((GET_CODE (operand) == MEM
		     && offsetable_memref_p (operand))
		    || (GET_CODE (operand) == REG
			&& REGNO (operand) >= FIRST_PSEUDO_REGISTER
			&& reg_renumber[REGNO (operand)] < 0))
		  win = 1;
		if (GET_CODE (operand) == CONST_DOUBLE
		    || (GET_CODE (operand) == MEM
			&& GET_CODE (XEXP (operand, 0)) != POST_INC
			&& GET_CODE (XEXP (operand, 0)) != POST_DEC
			&& GET_CODE (XEXP (operand, 0)) != PRE_INC
			&& GET_CODE (XEXP (operand, 0)) != PRE_DEC))
		  badop = 0;
		offmemok = 1;
		break;

	      case '&':
		/* Output operand that is stored before the need for the
		   input operands (and their index registers) is over.  */
		if (GET_CODE (operand) == REG)
		  earlyclobber = 1, this_earlyclobber = 1;
		break;

	      case 'F':
		if (GET_CODE (operand) == CONST_DOUBLE)
		  win = 1;
		break;

	      case 'G':
	      case 'H':
		if (GET_CODE (operand) == CONST_DOUBLE
		    && CONST_DOUBLE_OK_FOR_LETTER_P (operand, c))
		  win = 1;
		break;

	      case 's':
		if (GET_CODE (operand) == CONST_INT)
		  break;
	      case 'i':
		if (CONSTANT_P (operand))
		  win = 1;
		break;

	      case 'n':
		if (GET_CODE (operand) == CONST_INT)
		  win = 1;
		break;

	      case 'I':
	      case 'J':
	      case 'K':
	      case 'L':
	      case 'M':
		if (GET_CODE (operand) == CONST_INT
		    && CONST_OK_FOR_LETTER_P (INTVAL (operand), c))
		  win = 1;
		break;

	      case 'g':
		if (GENERAL_REGS == ALL_REGS
		    || GET_CODE (operand) != REG
		    || (REGNO (operand) >= FIRST_PSEUDO_REGISTER
			&& reg_renumber[REGNO (operand)] < 0))
		  win = 1;
		/* Drop through into 'r' case */

	      case 'r':
		this_alternative[i]
		  = (int) reg_class_subunion[this_alternative[i]][(int) GENERAL_REGS];
		goto reg;

	      default:
		this_alternative[i]
		  = (int) reg_class_subunion[this_alternative[i]][(int) REG_CLASS_FROM_LETTER (c)];

	      reg:
		badop = 0;
		if (GET_CODE (operand) == REG
		    && reg_renumbered_fits_class_p (operand,
						    this_alternative[i],
						    offset, GET_MODE (recog_operand[i])))
		  win = 1;
		break;
	      }
	  constraints[i] = p;

	  /* Record which operands fit this alternative.  */
	  this_alternative_earlyclobber[i] = earlyclobber;
	  if (win && ! force_reload)
	    this_alternative_win[i] = 1;
	  else
	    {
	      this_alternative_offmemok[i] = offmemok;
	      losers++;
	      if (badop)
		bad = 1;
	    }
	}

      /* Now see if any output operands that are marked "earlyclobber"
	 in this alternative conflict with any input operands
	 or any memory addresses.  */

      for (i = 0; i < noperands; i++)
	if (this_alternative_earlyclobber[i]
	    && this_alternative_win[i])
	  {
	    int j;
	    for (j = 0; j < noperands; j++)
	      /* Is this an input operand or a memory ref?  */
	      if ((GET_CODE (recog_operand[j]) == MEM
		   || modified[j] != RELOAD_WRITE)
		  /* Does it refer to the earlyclobber operand?  */
		  && refers_to_regno_p (REGNO (recog_operand[i]),
					recog_operand[j], 0))
		break;
	    /* If an earlyclobber operand conflicts with something,
	       it must be reloaded, so request this and count the cost.  */
	    if (j != noperands)
	      {
		losers++;
		this_alternative_win[i] = 0;
	      }
	  }

      /* If one alternative accepts all the operands, no reload required,
	 choose that alternative; don't consider the remaining ones.  */
      if (losers == 0)
	{
	  /* Unswap these so that they are never swapped at `finish'.  */
	  recog_operand[1] = substed_operand[1];
	  recog_operand[2] = substed_operand[2];
	  for (i = 0; i < noperands; i++)
	    {
	      goal_alternative_win[i] = 1;
	      goal_alternative[i] = this_alternative[i];
	      goal_alternative_offmemok[i] = this_alternative_offmemok[i];
	      goal_alternative_matches[i] = this_alternative_matches[i];
	    }
	  goal_alternative_number = this_alternative_number;
	  goal_alternative_swapped = swapped;
	  goal_earlyclobber = this_earlyclobber;
	  goto finish;
	}

      /* REJECT, set by the ! and ? constraint characters,
	 discourages the use of this alternative for a reload goal.  */
      if (reject > 0)
	losers += reject;

      /* If this alternative can be made to work by reloading,
	 and it needs less reloading than the others checked so far,
	 record it as the chosen goal for reloading.  */
      if (! bad && best > losers)
	{
	  for (i = 0; i < noperands; i++)
	    {
	      goal_alternative[i] = this_alternative[i];
	      goal_alternative_win[i] = this_alternative_win[i];
	      goal_alternative_offmemok[i] = this_alternative_offmemok[i];
	      goal_alternative_matches[i] = this_alternative_matches[i];
	    }
	  goal_alternative_swapped = swapped;
	  best = losers;
	  goal_alternative_number = this_alternative_number;
	  goal_earlyclobber = this_earlyclobber;
	}
      this_alternative_number++;
    }

  /* If insn is commutative (it's safe to exchange a certain pair of operands)
     then we need to try each alternative twice,
     the second time matching those two operands
     as if we had exchanged them.
     To do this, really exchange them in operands.

     If we have just tried the alternatives the second time,
     return operands to normal and drop through.  */

  if (commutative >= 0)
    {
      swapped = !swapped;
      if (swapped)
	{
	  recog_operand[commutative] = substed_operand[commutative + 1];
	  recog_operand[commutative + 1] = substed_operand[commutative];

	  bcopy (constraints1, constraints, noperands * sizeof (char *));
	  goto try_swapped;
	}
      else
	{
	  recog_operand[commutative] = substed_operand[commutative];
	  recog_operand[commutative + 1] = substed_operand[commutative + 1];
	}
    }

  /* The operands don't meet the constraints.
     goal_alternative describes the alternative
     that we could reach by reloading the fewest operands.
     Reload so as to fit it.  */

  if (best == MAX_RECOG_OPERANDS + 100)
    {
      /* No alternative works with reloads??  */
      if (insn_code_number >= 0)
	abort ();
      error ("inconsistent operand constraints in an `asm' in this function");
      n_reloads = 0;
      return;
    }

  /* Jump to `finish' from above if all operands are valid already.
     In that case, goal_alternative_win is all 1.  */
 finish:

  /* Right now, for any pair of operands I and J that are required to match,
     with I < J,
     goal_alternative_matches[J] is I.
     Set up goal_alternative_matched as the inverse function:
     goal_alternative_matched[I] = J.  */

  for (i = 0; i < noperands; i++)
    goal_alternative_matched[i] = -1;

  for (i = 0; i < noperands; i++)
    if (! goal_alternative_win[i]
	&& goal_alternative_matches[i] >= 0)
      goal_alternative_matched[goal_alternative_matches[i]] = i;

  /* If the best alternative is with operands 1 and 2 swapped,
     consider them swapped before reporting the reloads.  */

  if (goal_alternative_swapped)
    {
      register rtx tem;

      tem = substed_operand[commutative];
      substed_operand[commutative] = substed_operand[commutative + 1];
      substed_operand[commutative + 1] = tem;
      tem = recog_operand[commutative];
      recog_operand[commutative] = recog_operand[commutative + 1];
      recog_operand[commutative + 1] = tem;
    }

  /* Perform whatever substitutions on the operands we are supposed
     to make due to commutativity or replacement of registers
     with equivalent constants or memory slots.  */

  for (i = 0; i < noperands; i++)
    {
      *recog_operand_loc[i] = substed_operand[i];
      /* While we are looping on operands, initialize this.  */
      operand_reloadnum[i] = -1;
    }

  /* Now record reloads for all the operands that need them.  */
  for (i = 0; i < noperands; i++)
    if (! goal_alternative_win[i])
      {
	/* Operands that match previous ones have already been handled.  */
	if (goal_alternative_matches[i] >= 0)
	  ;
	/* This clause forces a double constant into memory
	   if necessary.  But right now it appears never necessary.
	   Perhaps there should be a heuristic here to detect cases
	   when it is desirable, even though not necessary, to move
	   the constant to memory.  I can't decide when it is desirable.  */
	else if (GET_CODE (recog_operand[i]) == CONST_DOUBLE
		 && alternative_allows_memconst (constraints1[i], goal_alternative_number)
		 && goal_alternative[i] == (int) NO_REGS)
	  {
	    *recog_operand_loc[i] = recog_operand[i]
	      = force_const_double_mem (recog_operand[i]);
	    find_reloads_toplev (recog_operand[i]);
	  }
	/* Handle an operand with a nonoffsetable address
	   appearing where an offsetable address will do
	   by reloading the address into a base register.  */
	else if (goal_alternative_matched[i] == -1
		 && goal_alternative_offmemok[i]
		 && GET_CODE (recog_operand[i]) == MEM
		 && GET_CODE (XEXP (recog_operand[i], 0)) != POST_INC
		 && GET_CODE (XEXP (recog_operand[i], 0)) != POST_DEC
		 && GET_CODE (XEXP (recog_operand[i], 0)) != PRE_INC
		 && GET_CODE (XEXP (recog_operand[i], 0)) != PRE_DEC)
	  push_reload (XEXP (recog_operand[i], 0), 0,
		       &XEXP (recog_operand[i], 0), 0,
		       BASE_REG_CLASS, GET_MODE (XEXP (recog_operand[i], 0)),
		       0, 0, 0);
	else if (goal_alternative_matched[i] == -1)
	  operand_reloadnum[i] =
	    push_reload (modified[i] != RELOAD_WRITE ? recog_operand[i] : 0,
			 modified[i] != RELOAD_READ ? recog_operand[i] : 0,
			 recog_operand_loc[i], 0,
			 (enum reg_class) goal_alternative[i],
			 (modified[i] == RELOAD_WRITE ? VOIDmode : operand_mode[i]),
			 (modified[i] == RELOAD_READ ? VOIDmode : operand_mode[i]),
			 (insn_code_number < 0 ? 0
			  : insn_operand_strict_low[insn_code_number][i]),
			 0);
	/* In a matching pair of operands, one must be input only
	   and the other must be output only.
	   Pass the input operand as IN and the other as OUT.  */
	else if (modified[i] == RELOAD_READ
		 && modified[goal_alternative_matched[i]] == RELOAD_WRITE)
	  operand_reloadnum[goal_alternative_matched[i]]
	    = operand_reloadnum[i]
	    = push_reload (recog_operand[i],
			   recog_operand[goal_alternative_matched[i]],
			   recog_operand_loc[i],
			   recog_operand_loc[goal_alternative_matched[i]],
			   (enum reg_class) goal_alternative[i],
			   operand_mode[i],
			   operand_mode[goal_alternative_matched[i]],
			   VOIDmode, 0);
	else if (modified[i] == RELOAD_WRITE
		 && modified[goal_alternative_matched[i]] == RELOAD_READ)
	  operand_reloadnum[goal_alternative_matched[i]]
	    = operand_reloadnum[i]
	    = push_reload (recog_operand[goal_alternative_matched[i]],
			   recog_operand[i],
			   recog_operand_loc[goal_alternative_matched[i]],
			   recog_operand_loc[i],
			   (enum reg_class) goal_alternative[i],
			   operand_mode[goal_alternative_matched[i]],
			   operand_mode[i],
			   VOIDmode, 0);
	else abort ();
      }
    else if (goal_alternative_matched[i] < 0
	     && goal_alternative_matches[i] < 0)
      {
	rtx operand = recog_operand[i];
	/* For each non-matching operand that's a pseudo-register 
	   that didn't get a hard register, make an optional reload.
	   This may get done even if the insn needs no reloads otherwise.  */
	/* (It would be safe to make an optional reload for a matching pair
	   of operands, but we don't bother yet.)  */
	while (GET_CODE (operand) == SUBREG)
	  operand = XEXP (operand, 0);
	if (GET_CODE (operand) == REG
	    && REGNO (operand) >= FIRST_PSEUDO_REGISTER
	    && reg_renumber[REGNO (operand)] < 0
	    && (enum reg_class) goal_alternative[i] != NO_REGS
	    /* Don't make optional output reloads for jump insns
	       (such as aobjeq on the vax).  */
	    && (modified[i] == RELOAD_READ
		|| GET_CODE (insn) != JUMP_INSN))
	  operand_reloadnum[i]
	    = push_reload (modified[i] != RELOAD_WRITE ? recog_operand[i] : 0,
			   modified[i] != RELOAD_READ ? recog_operand[i] : 0,
			   recog_operand_loc[i], 0,
			   (enum reg_class) goal_alternative[i],
			   (modified[i] == RELOAD_WRITE ? VOIDmode : operand_mode[i]),
			   (modified[i] == RELOAD_READ ? VOIDmode : operand_mode[i]),
			   insn_operand_strict_low[insn_code_number][i],
			   1);
	else
	  operand_reloadnum[i] = -1;
      }

  /* Perhaps an output reload can be combined with another
     to reduce needs by one.  */
  if (!goal_earlyclobber)
    combine_reloads ();

  /* If this insn pattern contains any MATCH_DUP's, make sure that
     they will be substituted if the operands they match are substituted.
     Also do now any substitutions we already did on the operands.  */
  if (insn_code_number >= 0)
    for (i = insn_n_dups[insn_code_number] - 1; i >= 0; i--)
      {
	int opno = recog_dup_num[i];
	*recog_dup_loc[i] = *recog_operand_loc[opno];
	if (operand_reloadnum[opno] >= 0)
	  push_replacement (recog_dup_loc[i], operand_reloadnum[opno],
			    insn_operand_mode[insn_code_number][opno]);
      }

  /* For each reload of a reg into some other class of reg,
     search for an existing equivalent reg (same value now) in the right class.
     We can use it as long as we don't need to change its contents.  */
  for (i = 0; i < n_reloads; i++)
    if (reload_reg_rtx[i] == 0
	&& reload_in[i] != 0
	&& GET_CODE (reload_in[i]) == REG
	&& reload_out[i] == 0)
      {
	reload_reg_rtx[i]
	  = find_equiv_reg (reload_in[i], insn, reload_reg_class[i], -1,
			    static_reload_reg_p, 0, reload_inmode[i]);
	/* Prevent generation of insn to load the value
	   because the one we found already has the value.  */
	if (reload_reg_rtx[i])
	  reload_in[i] = reload_reg_rtx[i];
      }

#else /* no REGISTER_CONSTRAINTS */
  int noperands;
  int insn_code_number;
  register int i;
  rtx body = PATTERN (insn);

  n_reloads = 0;
  n_replacements = 0;
  replace_reloads = replace;
  indirect_ok = ind_ok;
  this_insn = insn;

  /* Find what kind of insn this is.  NOPERANDS gets number of operands.
     Store the operand values in RECOG_OPERAND and the locations
     of the words in the insn that point to them in RECOG_OPERAND_LOC.
     Return if the insn needs no reload processing.  */

  switch (GET_CODE (body))
    {
    case USE:
    case CLOBBER:
    case ASM_INPUT:
    case ADDR_VEC:
    case ADDR_DIFF_VEC:
      return;

    case PARALLEL:
    case SET:
      noperands = asm_noperands (body);
      if (noperands > 0)
	{
	  /* This insn is an `asm' with operands.
	     First, find out how many operands, and allocate space.  */

	  insn_code_number = -1;
	  /* ??? This is a bug! ???
	     Give up and delete this insn if it has too many operands.  */
	  if (noperands > MAX_RECOG_OPERANDS)
	    abort ();

	  /* Now get the operand values out of the insn.  */

	  decode_asm_operands (body, recog_operand, recog_operand_loc, 0, 0);
	  break;
	}

    default:
      /* Ordinary insn: recognize it, allocate space for operands and
	 constraints, and get them out via insn_extract.  */

      insn_code_number = recog_memoized (insn);
      noperands = insn_n_operands[insn_code_number];
      insn_extract (insn);
    }

  if (noperands == 0)
    return;

  for (i = 0; i < noperands; i++)
    {
      register RTX_CODE code = GET_CODE (recog_operand[i]);

      if (insn_code_number >= 0)
	if (insn_operand_address_p[insn_code_number][i])
	  find_reloads_address (VOIDmode, 0,
				recog_operand[i], recog_operand_loc[i]);
      if (code == MEM)
	find_reloads_address (GET_MODE (recog_operand[i]),
			      recog_operand_loc[i],
			      XEXP (recog_operand[i], 0),
			      &XEXP (recog_operand[i], 0));
      if (code == SUBREG)
	find_reloads_toplev (recog_operand[i]);
      if (code == REG)
	{
	  register int regno = REGNO (recog_operand[i]);
	  if (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	      && reg_equiv_constant[regno] != 0)
	    recog_operand[i] = *recog_operand_loc[i]
	      = reg_equiv_constant[regno];
	}
    }
#endif /* no REGISTER_CONSTRAINTS */
}

/* Return 1 if alternative number ALTNUM in constraint-string CONSTRAINT
   accepts a memory operand with constant address.  */

static int
alternative_allows_memconst (constraint, altnum)
     char *constraint;
     int altnum;
{
  register int c;
  /* Skip alternatives before the one requested.  */
  while (altnum > 0)
    {
      while (*constraint++ != ',');
      altnum--;
    }
  /* Scan the requested alternative for 'm' or 'o'.
     If one of them is present, this alternative accepts memory constants.  */
  while ((c = *constraint++) && c != ',' && c != '#')
    if (c == 'm' || c == 'o')
      return 1;
  return 0;
}

/* Scan X for memory references and scan the addresses for reloading.
   Also checks for references to "constant" regs that we want to eliminate
   and replaces them with the values they stand for.
   We may alter X descructively if it contains a reference to such.
   If X is just a constant reg, we return the equivalent value
   instead of X.  */

static rtx
find_reloads_toplev (x)
     rtx x;
{
  register RTX_CODE code = GET_CODE (x);

  register char *fmt = GET_RTX_FORMAT (code);
  register int i;

  if (code == REG)
    {
      /* This code is duplicated for speed in find_reloads.  */
      register int regno = REGNO (x);
      if (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	x = reg_equiv_constant[regno];
      else if (reg_equiv_address[regno] != 0)
	{
	  x = gen_rtx (MEM, GET_MODE (x),
		       reg_equiv_address[regno]);
	  find_reloads_address (GET_MODE (x), 0,
				XEXP (x, 0),
				&XEXP (x, 0));
	}
      return x;


    }
  else if (code == MEM)
    {
      rtx tem = x;
      find_reloads_address (GET_MODE (x), &tem, XEXP (x, 0), &XEXP (x, 0));
      return tem;
    }
  else
    for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
      {
	if (fmt[i] == 'e')
	  XEXP (x, i) = find_reloads_toplev (XEXP (x, i));
      }
  return x;
}

static rtx
make_memloc (ad, regno)
     rtx ad;
     int regno;
{
  register int i;
  rtx tem = reg_equiv_address[regno];
  for (i = 0; i < n_memlocs; i++)
    if (rtx_equal_p (tem, XEXP (memlocs[i], 0)))
      return memlocs[i];
  tem = gen_rtx (MEM, GET_MODE (ad), tem);
  memlocs[n_memlocs++] = tem;
  return tem;
}

/* Record all reloads needed for handling memory address AD
   which appears in *LOC in a memory reference to mode MODE
   which itself is stored in location  *MEMREFLOC.
   (MEMREFLOC may be zero, meaning don't ever bother to copy the memref.)
   Note that we take shortcuts assuming that no multi-reg machine mode
   occurs as part of an address.  */

static void
find_reloads_address (mode, memrefloc, ad, loc)
     enum machine_mode mode;
     rtx *memrefloc;
     rtx ad;
     rtx *loc;
{
  register int regno;
  rtx tem;

  if (GET_CODE (ad) == REG)
    {
      regno = REGNO (ad);

      if (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	{
	  if (strict_memory_address_p (mode, reg_equiv_constant[regno]))
	    {
	      *loc = ad = reg_equiv_constant[regno];
	      return;
	    }
	}
      if (reg_equiv_address[regno] != 0)
	{
	  rtx tem = make_memloc (ad, regno);
	  push_reload (XEXP (tem, 0), 0, &XEXP (tem, 0), 0,
		       BASE_REG_CLASS,
		       GET_MODE (XEXP (tem, 0)), 0, VOIDmode, 0);
	  push_reload (tem, 0, loc, 0, BASE_REG_CLASS,
		       GET_MODE (ad), 0, VOIDmode, 0);
	  return;
	}
      if (! (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	     ? indirect_ok
	     : REGNO_OK_FOR_BASE_P (regno)))
	push_reload (ad, 0, loc, 0, BASE_REG_CLASS,
		     GET_MODE (ad), 0, VOIDmode, 0);
      return;
    }

  if (strict_memory_address_p (mode, ad))
    {
      /* The address appears valid, so reloads are not needed.
	 But the address may contain an eliminable register.
	 This can happen because a machine with indirect addressing
	 may consider a pseudo register by itself a valid address even when
	 it has failed to get a hard reg.
	 So do a tree-walk to find and eliminate all such regs.  */

      /* But first quickly dispose of a common case.  */
      if (GET_CODE (ad) == PLUS
	  && GET_CODE (XEXP (ad, 1)) == CONST_INT
	  && GET_CODE (XEXP (ad, 0)) == REG
	  && reg_equiv_constant[REGNO (XEXP (ad, 0))] == 0)
	return;

      subst_reg_equivs_changed = 0;
      *loc = subst_reg_equivs (ad);

      if (! subst_reg_equivs_changed)
	return;

      /* Check result for validity after substitution.  */
      if (strict_memory_address_p (mode, ad))
	return;
    }

  /* If we have address of a stack slot but it's not valid
     (displacement is too large), compute the sum in a register.  */
  if (GET_CODE (ad) == PLUS
      && (XEXP (ad, 0) == frame_pointer_rtx
#if FRAME_POINTER_REGNUM == ARG_POINTER_REGNUM
	  || XEXP (ad, 0) == arg_pointer_rtx
#endif
	  )
      && GET_CODE (XEXP (ad, 1)) == CONST_INT)
    {
      /* Unshare the MEM rtx so we can safely alter it.  */
      if (memrefloc)
	{
	  *memrefloc = copy_rtx (*memrefloc);
	  loc = &XEXP (*memrefloc, 0);
	}
      push_reload (ad, 0, loc, 0, BASE_REG_CLASS,
		   GET_MODE (ad), 0, VOIDmode, 0);
      return;
    }

  /* See if address becomes valid when an eliminable register
     in a sum is replaced.  */

  tem = ad;
  if (GET_CODE (ad) == PLUS)
    tem = subst_indexed_address (ad);
  if (tem != ad && strict_memory_address_p (mode, tem))
    {
      /* Ok, we win that way.  Replace any additional eliminable
	 registers.  */

      subst_reg_equivs_changed = 0;
      tem = subst_reg_equivs (tem);

      /* Make sure that didn't make the address invalid again.  */

      if (! subst_reg_equivs_changed || strict_memory_address_p (mode, tem))
	{
	  *loc = tem;
	  return;
	}
    }

  /* If constants aren't valid addresses, reload the constant address
     into a register.  */
  if (CONSTANT_ADDRESS_P (ad) && ! strict_memory_address_p (mode, ad))
    {
      push_reload (ad, 0, loc, 0,
		   BASE_REG_CLASS,
		   GET_MODE (ad), 0, VOIDmode, 0);
      return;
    }

  find_reloads_address_1 (ad, 0, loc);
}

/* Find all pseudo regs appearing in AD
   that are eliminable in favor of equivalent values
   and do not have hard regs; replace them by their equivalents.  */

static rtx
subst_reg_equivs (ad)
     rtx ad;
{
  register RTX_CODE code = GET_CODE (ad);
  register int i;
  register char *fmt;

  switch (code)
    {
    case CONST_INT:
    case CONST:
    case CONST_DOUBLE:
    case SYMBOL_REF:
    case LABEL_REF:
    case PC:
    case CC0:
      return ad;

    case REG:
      {
	register int regno = REGNO (ad);

	if (reg_equiv_constant[regno] != 0)
	  {
	    subst_reg_equivs_changed = 1;
	    return reg_equiv_constant[regno];
	  }
      }
      return ad;

    case PLUS:
      /* Quickly dispose of a common case.  */
      if (XEXP (ad, 0) == frame_pointer_rtx
	  && GET_CODE (XEXP (ad, 1)) == CONST_INT)
	return ad;
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    if (fmt[i] == 'e')
      XEXP (ad, i) = subst_reg_equivs (XEXP (ad, i));
  return ad;
}

/* If ADDR is a sum containing a pseudo register that should be
   replaced with a constant (from reg_equiv_constant),
   return the result of doing so, and also apply the associative
   law so that the result is more likely to be a valid address.
   (But it is not guaranteed to be one.)

   In all other cases, return ADDR.  */

static rtx
subst_indexed_address (addr)
     rtx addr;
{
  rtx const_part = 0;
  rtx var_part = 0;
  int regno;

  if (GET_CODE (addr) == PLUS)
    {
      if (CONSTANT_P (XEXP (addr, 0)))
	const_part = XEXP (addr, 0),
	var_part = XEXP (addr, 1);
      else if (CONSTANT_P (XEXP (addr, 1)))
	const_part = XEXP (addr, 1),
	var_part = XEXP (addr, 0);

      if (const_part == 0)
	return addr;

      if (GET_CODE (const_part) == CONST)
	const_part = XEXP (const_part, 0);

      if (GET_CODE (var_part) == REG
	  && (regno = REGNO (var_part)) >= FIRST_PSEUDO_REGISTER
	  && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	return gen_rtx (CONST, VOIDmode,
			gen_rtx (PLUS, Pmode, const_part,
				 reg_equiv_constant[regno]));

      if (GET_CODE (var_part) != PLUS)
	return addr;

      if (GET_CODE (XEXP (var_part, 0)) == REG
	  && (regno = REGNO (XEXP (var_part, 0))) >= FIRST_PSEUDO_REGISTER
	  && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	return gen_rtx (PLUS, Pmode, XEXP (var_part, 1),
			gen_rtx (CONST, VOIDmode,
				 gen_rtx (PLUS, Pmode, const_part,
					  reg_equiv_constant[regno])));

      if (GET_CODE (XEXP (var_part, 1)) == REG
	  && (regno = REGNO (XEXP (var_part, 1))) >= FIRST_PSEUDO_REGISTER
	  && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	return gen_rtx (PLUS, Pmode, XEXP (var_part, 0),
			gen_rtx (CONST, VOIDmode,
				 gen_rtx (PLUS, Pmode, const_part,
					  reg_equiv_constant[regno])));
    }
  return addr;
}

/* Record the pseudo registers we must reload into hard registers
   in a subexpression of a memory address, X.
   CONTEXT = 1 means we are considering regs as index regs,
   = 0 means we are considering them as base regs.

   We return X, whose operands may have been altered,
   or perhaps a RELOAD rtx if X itself was a REG that must be reloaded.  */

/* Note that we take shortcuts assuming that no multi-reg machine mode
   occurs as part of an address.
   Also, this is not fully machine-customizable; it works for machines
   such as vaxes and 68000's and 32000's, but other possible machines
   could have addressing modes that this does not handle right.  */

static void
find_reloads_address_1 (x, context, loc)
     rtx x;
     int context;
     rtx *loc;
{
  register RTX_CODE code = GET_CODE (x);

  if (code == PLUS)
    {
      register rtx op0 = XEXP (x, 0);
      register rtx op1 = XEXP (x, 1);
      register RTX_CODE code0 = GET_CODE (op0);
      register RTX_CODE code1 = GET_CODE (op1);
      if (code0 == MULT || code0 == SIGN_EXTEND || code1 == MEM)
	{
	  find_reloads_address_1 (op0, 1, &XEXP (x, 0));
	  find_reloads_address_1 (op1, 0, &XEXP (x, 1));
	}
      else if (code1 == MULT || code1 == SIGN_EXTEND || code0 == MEM)
	{
	  find_reloads_address_1 (op0, 0, &XEXP (x, 0));
	  find_reloads_address_1 (op1, 1, &XEXP (x, 1));
	}
      else if (code0 == CONST_INT || code0 == CONST
	       || code0 == SYMBOL_REF || code0 == LABEL_REF)
	{
	  find_reloads_address_1 (op1, 0, &XEXP (x, 1));
	}
      else if (code1 == CONST_INT || code1 == CONST
	       || code1 == SYMBOL_REF || code1 == LABEL_REF)
	{
	  find_reloads_address_1 (op0, 0, &XEXP (x, 0));
	}
      else if (code0 == REG && code1 == REG)
	{
	  if (REG_OK_FOR_INDEX_P (op0)
	      && REG_OK_FOR_BASE_P (op1))
	    return;
	  else if (REG_OK_FOR_INDEX_P (op1)
	      && REG_OK_FOR_BASE_P (op0))
	    return;
	  else if (REG_OK_FOR_BASE_P (op1))
	    find_reloads_address_1 (op0, 1, &XEXP (x, 0));
	  else if (REG_OK_FOR_BASE_P (op0))
	    find_reloads_address_1 (op1, 1, &XEXP (x, 1));
	  else if (REG_OK_FOR_INDEX_P (op1))
	    find_reloads_address_1 (op0, 0, &XEXP (x, 0));
	  else if (REG_OK_FOR_INDEX_P (op0))
	    find_reloads_address_1 (op1, 0, &XEXP (x, 1));
	  else
	    {
	      find_reloads_address_1 (op0, 1, &XEXP (x, 0));
	      find_reloads_address_1 (op1, 0, &XEXP (x, 1));
	    }
	}
      else if (code0 == REG)
	{
	  find_reloads_address_1 (op0, 1, &XEXP (x, 0));
	  find_reloads_address_1 (op1, 0, &XEXP (x, 1));
	}
      else if (code1 == REG)
	{
	  find_reloads_address_1 (op1, 1, &XEXP (x, 1));
	  find_reloads_address_1 (op0, 0, &XEXP (x, 0));
	}
    }
  else if (code == POST_INC || code == POST_DEC
	   || code == PRE_INC || code == PRE_DEC)
    {
      if (GET_CODE (XEXP (x, 0)) == REG)
	{
	  register int regno = REGNO (XEXP (x, 0));

	  /* A register that is incremented cannot be constant!  */
	  if (regno >= FIRST_PSEUDO_REGISTER
	      && reg_equiv_constant[regno] != 0)
	    abort ();

	  /* Handle a register that is equivalent to a memory location
	     which cannot be addressed directly.  */
	  if (reg_equiv_address[regno] != 0)
	    {
	      rtx tem = make_memloc (XEXP (x, 0), regno);
	      /* First reload the memory location's address.  */
	      push_reload (XEXP (tem, 0), 0, &XEXP (tem, 0), 0,
			   BASE_REG_CLASS,
			   GET_MODE (XEXP (tem, 0)), 0, VOIDmode, 0);
	      /* Then reload the memory reference itself,
		 pretending it is located in the PRE_INC or whatever.  */
	      push_reload (tem, tem, &XEXP (x, 0), 0,
			   context ? INDEX_REG_CLASS : BASE_REG_CLASS,
			   GET_MODE (tem), GET_MODE (tem), VOIDmode, 0);
	      return;
	    }

	  /* Handle any other sort of register.  */

	  if (reg_renumber[regno] >= 0)
	    regno = reg_renumber[regno];
	  if ((regno >= FIRST_PSEUDO_REGISTER
	       || !(context ? REGNO_OK_FOR_INDEX_P (regno)
		    : REGNO_OK_FOR_BASE_P (regno))))
	    {
	      register rtx link;
	      int reloadnum
		= push_reload (XEXP (x, 0), XEXP (x, 0),
			       &XEXP (x, 0), 0,
			       context ? INDEX_REG_CLASS : BASE_REG_CLASS,
			       GET_MODE (XEXP (x, 0)),
			       GET_MODE (XEXP (x, 0)), VOIDmode, 0);

	      for (link = REG_NOTES (this_insn);
		   link; link = XEXP (link, 1))
		if (REG_NOTE_KIND (link) == REG_INC
		    && REGNO (XEXP (link, 0)) == REGNO (XEXP (x, 0)))
		  push_replacement (&XEXP (link, 0), reloadnum, VOIDmode);
	    }
	  return;
	}
    }
  else if (code == REG)
    {
      register int regno = REGNO (x);

      if (regno >= FIRST_PSEUDO_REGISTER && reg_renumber[regno] < 0
	  && reg_equiv_constant[regno] != 0)
	{
	  push_reload (reg_equiv_constant[regno], 0, loc, 0,
		       context ? INDEX_REG_CLASS : BASE_REG_CLASS,
		       GET_MODE (x), 0, VOIDmode, 0);
	  return;
	}

      if (reg_equiv_address[regno] != 0)
	{
	  x = make_memloc (x, regno);
	  push_reload (XEXP (x, 0), 0, &XEXP (x, 0), 0,
		       BASE_REG_CLASS,
		       GET_MODE (XEXP (x, 0)), 0, VOIDmode, 0);
	}

      if (reg_renumber[regno] >= 0)
	regno = reg_renumber[regno];
      if ((regno >= FIRST_PSEUDO_REGISTER
	   || !(context ? REGNO_OK_FOR_INDEX_P (regno)
		: REGNO_OK_FOR_BASE_P (regno))))
	{
	  push_reload (x, 0, loc, 0,
		       context ? INDEX_REG_CLASS : BASE_REG_CLASS,
		       GET_MODE (x), 0, VOIDmode, 0);
	  return;
	}
    }
  else
    {
      register char *fmt = GET_RTX_FORMAT (code);
      register int i;
      for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
	{
	  if (fmt[i] == 'e')
	    find_reloads_address_1 (XEXP (x, i), context, &XEXP (x, i));
	}
    }
}

/* Substitute into X the registers into which we have reloaded
   the things that need reloading.  The array `replacements'
   says contains the locations of all pointers that must be changed
   and says what to replace them with.

   Return the rtx that X translates into; usually X, but modified.  */

void
subst_reloads ()
{
  register int i;

  for (i = 0; i < n_replacements; i++)
    {
      register struct replacement *r = &replacements[i];
      register rtx reloadreg = reload_reg_rtx[r->what];
      if (reloadreg)
	{
	  /* Encapsulate RELOADREG so its machine mode matches what
	     used to be there.  */
	  if (GET_MODE (reloadreg) != r->mode && r->mode != VOIDmode)
	    reloadreg = gen_rtx (SUBREG, r->mode, reloadreg, 0);
	  *r->where = reloadreg;
	}
      /* If reload got no reg and isn't optional, something's wrong.  */
      else if (! reload_optional[r->what])
	abort ();
    }
}

#if 0

/* [[This function is currently obsolete, now that volatility
   is represented by a special bit `volatil' so VOLATILE is never used;
   and UNCHANGING has never been brought into use.]]

   Alter X by eliminating all VOLATILE and UNCHANGING expressions.
   Each of them is replaced by its operand.
   Thus, (PLUS (VOLATILE (MEM (REG 5))) (CONST_INT 4))
   becomes (PLUS (MEM (REG 5)) (CONST_INT 4)).

   If X is itself a VOLATILE expression,
   we return the expression that should replace it
   but we do not modify X.  */

static rtx
forget_volatility (x)
     register rtx x;
{
  enum rtx_code code = GET_CODE (x);
  register char *fmt;
  register int i;
  register rtx value = 0;

  switch (code)
    {
    case LABEL_REF:
    case SYMBOL_REF:
    case CONST_INT:
    case CONST_DOUBLE:
    case CONST:
    case REG:
    case CC0:
    case PC:
      return x;

    case VOLATILE:
    case UNCHANGING:
      return XEXP (x, 0);
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	XEXP (x, i) = forget_volatility (XEXP (x, i));
      if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = XVECLEN (x, i) - 1; j >= 0; j--)
	    XVECEXP (x, i, j) = forget_volatility (XVECEXP (x, i, j));
	}
    }

  return x;
}

#endif

/* Check the insns before INSN to see if there is a suitable register
   containing the same value as GOAL.
   If OTHER is -1, look for a register in class CLASS.
   Otherwise, just see if register number OTHER shares GOAL's value.

   Return an rtx for the register found, or zero if none is found.

   If RELOAD_REG_P is (short *)1,
   we reject any hard reg that appears in reload_reg_rtx
   because such a hard reg is also needed coming into this insn.

   If RELOAD_REG_P is any other nonzero value,
   it is a vector indexed by hard reg number
   and we reject any hard reg whose element in the vector is nonnegative
   as well as any that appears in reload_reg_rtx.

   If GOAL is zero, then GOALREG is a register number; we look
   for an equivalent for that register.

   MODE is the machine mode of the value we want an equivalence for.
   If GOAL is nonzero and not VOIDmode, then it must have mode MODE.

   This function is used by jump.c as well as in the reload pass.

   If GOAL is a PLUS, we assume it adds the stack pointer to a constant.  */

rtx
find_equiv_reg (goal, insn, class, other, reload_reg_p, goalreg, mode)
     register rtx goal;
     rtx insn;
     enum reg_class class;
     register int other;
     short *reload_reg_p;
     int goalreg;
     enum machine_mode mode;
{
  register rtx p = insn;
  rtx valtry, value, where;
  register rtx pat;
  register int regno = -1;
  int valueno;
  int goal_mem = 0;
  int goal_const = 0;
  int goal_mem_addr_varies = 0;
  int nregs;
  int valuenregs;

  if (goal == 0)
    regno = goalreg;
  else if (GET_CODE (goal) == REG)
    regno = REGNO (goal);
  else if (GET_CODE (goal) == MEM)
    {
      enum rtx_code code = GET_CODE (XEXP (goal, 0));
      /* An address with side effects must be reexecuted.  */
      switch (code)
	{
	case POST_INC:
	case PRE_INC:
	case POST_DEC:
	case PRE_DEC:
	  return 0;
	}
      goal_mem = 1;
    }
  else if (CONSTANT_P (goal))
    goal_const = 1;
  else
    return 0;

  /* On some machines, certain regs must always be rejected
     because they don't behave the way ordinary registers do.  */
  
#ifdef OVERLAPPING_REGNO_P
   if (regno >= 0 && OVERLAPPING_REGNO_P (regno))
     return 0;
#endif      

  /* Scan insns back from INSN, looking for one that copies
     a value into or out of GOAL.
     Stop and give up if we reach a label.  */

  while (1)
    {
      p = PREV_INSN (p);
      if (p == 0 || GET_CODE (p) == CODE_LABEL)
	return 0;
      if (GET_CODE (p) == INSN
	  /* If we don't want spill regs (true for all calls in this file) */
	  && (! (reload_reg_p != 0 && reload_reg_p != (short *)1)
	  /* then ignore insns introduced by reload; they aren't useful
	     and can cause results in reload_as_needed to be different
	     from what they were when calculating the need for spills.
	     If we notice an input-reload insn here, we will reject it below,
	     but it might hide a usable equivalent.  That makes bad code.
	     It may even abort: perhaps no reg was spilled for this insn
	     because it was assumed we would find that equivalent.  */
	      || INSN_UID (p) < reload_first_uid))
	{
	  pat = PATTERN (p);
	  /* First check for something that sets some reg equal to GOAL.  */
	  if (GET_CODE (pat) == SET
	      && ((regno >= 0
		   && GET_CODE (SET_SRC (pat)) == REG
		   && REGNO (SET_SRC (pat)) == regno
		   && GET_CODE (valtry = SET_DEST (pat)) == REG)
		  ||
		  (regno >= 0
		   && GET_CODE (SET_DEST (pat)) == REG
		   && REGNO (SET_DEST (pat)) == regno
		   && GET_CODE (valtry = SET_SRC (pat)) == REG)
		  ||
		  (goal_const && rtx_equal_p (SET_SRC (pat), goal)
		   && GET_CODE (valtry = SET_DEST (pat)) == REG)
		  || (goal_mem
		      && GET_CODE (valtry = SET_DEST (pat)) == REG
		      && rtx_renumbered_equal_p (goal, SET_SRC (pat)))
		  || (goal_mem
		      && GET_CODE (valtry = SET_SRC (pat)) == REG
		      && rtx_renumbered_equal_p (goal, SET_DEST (pat)))))
	    if (valueno = REGNO (valtry),
		other >= 0
		? valueno == other
		: ((unsigned) valueno < FIRST_PSEUDO_REGISTER
		   && TEST_HARD_REG_BIT (reg_class_contents[(int) class],
					 valueno)))
	      {
		value = valtry;
		where = p;
		break;
	      }
	}
    }

  /* We found a previous insn copying GOAL into a suitable other reg VALUE
     (or copying VALUE into GOAL, if GOAL is also a register).
     Now verify that VALUE is really valid.  */

  /* VALUENO is the register number of VALUE; a hard register.  */

  /* Don't find the sp as an equiv, since pushes that we don't notice
     would invalidate it.  */
  if (valueno == STACK_POINTER_REGNUM)
    return 0;

  /* Reject VALUE if the copy-insn moved the wrong sort of datum.  */
  if (GET_MODE (value) != mode)
    return 0;

  /* Reject VALUE if it was loaded from GOAL
     and is also a register that appears in the address of GOAL.  */

  if (goal_mem && value == SET_DEST (PATTERN (where))
      && refers_to_regno_p (valueno, goal, 0))
    return 0;

  /* Reject VALUE if it is one of the regs reserved for reloads.
     Reload1 knows how to reuse them anyway, and it would get
     confused if we allocated one without its knowledge.
     (Now that insns introduced by reload are ignored above,
     this case shouldn't happen, but I'm not positive.)  */

  if (reload_reg_p != 0 && reload_reg_p != (short *)1
      && reload_reg_p[valueno] >= 0)
    return 0;

  /* On some machines, certain regs must always be rejected
     because they don't behave the way ordinary registers do.  */
  
#ifdef OVERLAPPING_REGNO_P
   if (OVERLAPPING_REGNO_P (valueno))
     return 0;
#endif      

  /* Reject VALUE if it is a register being used for an input reload
     even if it is not one of those reserved.  */

  if (reload_reg_p != 0)
    {
      int i;
      for (i = 0; i < n_reloads; i++)
	if (reload_reg_rtx[i] != 0 && reload_in[i])
	  {
	    int regno1 = REGNO (reload_reg_rtx[i]);
	    if (valueno == regno1)
	      return 0;
	  }
    }

  if (goal_mem)
    goal_mem_addr_varies = rtx_addr_varies_p (goal);

  nregs = HARD_REGNO_NREGS (regno, mode);
  valuenregs = HARD_REGNO_NREGS (valueno, mode);

  /* Now verify that the values of GOAL and VALUE remain unaltered
     until INSN is reached.  */

  p = insn;
  while (1)
    {
      p = PREV_INSN (p);
      if (p == where)
	return value;

      /* Don't trust the conversion past a function call
	 if either of the two is in a call-clobbered register, or memory.  */
      if (GET_CODE (p) == CALL_INSN
	  && ((regno >= 0 && regno < FIRST_PSEUDO_REGISTER
	       && call_used_regs[regno])
	      ||
	      (valueno >= 0 && valueno < FIRST_PSEUDO_REGISTER
	       && call_used_regs[valueno])
	      ||
	      goal_mem))
	return 0;

      if (GET_CODE (p) == INSN || GET_CODE (p) == JUMP_INSN
	  || GET_CODE (p) == CALL_INSN)
	{
	  /* If this insn P stores in either GOAL or VALUE, return 0.
	     If GOAL is a memory ref and this insn writes memory, return 0.
	     If GOAL is a memory ref and its address is not constant,
	     and this insn P changes a register, return 0.
	     That is in lieue of checking whether GOAL uses this register.  */

	  pat = PATTERN (p);
	  if (GET_CODE (pat) == SET || GET_CODE (pat) == CLOBBER)
	    {
	      register rtx dest = SET_DEST (pat);
	      while (GET_CODE (dest) == SUBREG
		     || GET_CODE (dest) == ZERO_EXTRACT
		     || GET_CODE (dest) == SIGN_EXTRACT
		     || GET_CODE (dest) == STRICT_LOW_PART)
		dest = XEXP (dest, 0);
	      if (GET_CODE (dest) == REG)
		{
		  register int xregno = REGNO (dest);
		  int xnregs = HARD_REGNO_NREGS (xregno, GET_MODE_SIZE (GET_MODE (dest)));
		  if (xregno < regno + nregs && xregno + xnregs > regno)
		    return 0;
		  if (xregno < valueno + valuenregs
		      && xregno + xnregs > valueno)
		    return 0;
		  if (goal_mem_addr_varies)
		    return 0;
		}
	      else if (goal_mem && GET_CODE (dest) == MEM
		       && ! push_operand (dest, GET_MODE (dest)))
		return 0;
	    }
	  else if (GET_CODE (pat) == PARALLEL)
	    {
	      register int i;
	      for (i = XVECLEN (pat, 0) - 1; i >= 0; i--)
		{
		  register rtx v1 = XVECEXP (pat, 0, i);
		  if (GET_CODE (v1) == SET || GET_CODE (v1) == CLOBBER)
		    {
		      register rtx dest = SET_DEST (v1);
		      while (GET_CODE (dest) == SUBREG
			     || GET_CODE (dest) == ZERO_EXTRACT
			     || GET_CODE (dest) == SIGN_EXTRACT
			     || GET_CODE (dest) == STRICT_LOW_PART)
			dest = XEXP (dest, 0);
		      if (GET_CODE (dest) == REG)
			{
			  register int xregno = REGNO (dest);
			  int xnregs = HARD_REGNO_NREGS (xregno, GET_MODE_SIZE (GET_MODE (dest)));
			  if (xregno < regno + nregs
			      && xregno + xnregs > regno)
			    return 0;
			  if (xregno < valueno + valuenregs
			      && xregno + xnregs > valueno)
			    return 0;
			  if (goal_mem_addr_varies)
			    return 0;
			}
		      else if (goal_mem && GET_CODE (dest) == MEM
			       && ! push_operand (dest, GET_MODE (dest)))
			return 0;
		    }
		}
	    }
	  /* If this insn auto-increments or auto-decrements
	     either regno or valueno, return 0 now.
	     If GOAL is a memory ref and its address is not constant,
	     and this insn P increments a register, return 0.
	     That is in lieue of checking whether GOAL uses this register.  */
	  {
	    register rtx link;

	    for (link = REG_NOTES (p); link; link = XEXP (link, 1))
	      if (REG_NOTE_KIND (link) == REG_INC)
		{
		  register int incno = REGNO (XEXP (link, 0));
		  if (incno < regno + nregs && incno >= regno)
		    return 0;
		  if (incno < valueno + valuenregs && incno >= valueno)
		    return 0;
		  if (goal_mem_addr_varies)
		    return 0;
		}
	  }
	}
    }
}

/* Find a place where INCED appears in an increment or decrement operator
   within X, and return the amount INCED is incremented by
   (negative if decremented).  */

static int
find_inc_amount (x, inced)
     rtx x, inced;
{
  register enum rtx_code code = GET_CODE (x);
  register char *fmt;
  register int i;

  if (code == MEM)
    {
      register rtx addr = XEXP (x, 0);
      if ((GET_CODE (addr) == PRE_DEC
	   || GET_CODE (addr) == POST_DEC)
	  && XEXP (addr, 0) == inced)
	return - GET_MODE_SIZE (GET_MODE (x));
      if ((GET_CODE (addr) == PRE_INC
	   || GET_CODE (addr) == POST_INC)
	  && XEXP (addr, 0) == inced)
	return GET_MODE_SIZE (GET_MODE (x));
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	{
	  register int tem = find_inc_amount (XEXP (x, i), inced);
	  if (tem != 0)
	    return tem;
	}
      if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = XVECLEN (x, i) - 1; j >= 0; j--)
	    {
	      register int tem = find_inc_amount (XVECEXP (x, i, j), inced);
	      if (tem != 0)
		return tem;
	    }
	}
    }

  return 0;
}
