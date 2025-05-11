/* Dummy data flow analysis for GNU compiler in nonoptimizing mode.
   Copyright (C) 1987 Free Software Foundation, Inc.

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


/* This file performs stupid register allocation, which is used
   when cc1 gets the -noreg switch (which is when cc does not get -O).

   Stupid register allocation goes in place of the the flow_analysis,
   local_alloc and global_alloc passes.  combine_instructions cannot
   be done with stupid allocation because the data flow info that it needs
   is not computed here.

   In stupid allocation, the only user-defined variables that can
   go in registers are those declared "register".  They are assumed
   to have a life span equal to their scope.  Other user variables
   are given stack slots in the rtl-generation pass and are not
   represented as pseudo regs.  A compiler-generated temporary
   is assumed to live from its first mention to its last mention.

   Since each pseudo-reg's life span is just an interval, it can be
   represented as a pair of numbers, each of which identifies an insn by
   its position in the function (number of insns before it).  The first
   thing done for stupid allocation is to compute such a number for each
   insn.  It is called the suid.  Then the life-interval of each
   pseudo reg is computed.  Then the pseudo regs are ordered by priority
   and assigned hard regs in priority order.  */

#include <stdio.h>
#include "config.h"
#include "rtl.h"
#include "hard-reg-set.h"
#include "regs.h"

/* Vector mapping INSN_UIDs to suids.
   The suids are like uids but increase monononically always.
   We use them to see whether a subroutine call came
   between a variable's birth and its death.  */

static short *uid_suid;

/* Get the suid of an insn.  */

#define INSN_SUID(INSN) (uid_suid[INSN_UID (INSN)])

/* Record the suid of the last CALL_INSN
   so we can tell whether a potential combination crosses any calls.  */

static int last_call_suid;

/* Element N is suid of insn where life span of pseudo reg N ends.
   Element is  0 if register N has not been seen yet on backward scan.  */

static short *reg_where_dead;

/* Element N is suid of insn where life span of pseudo reg N begins.  */

static short *reg_where_born;

/* Numbers of pseudo-regs to be allocated, highest priority first.  */

static short *reg_order;

/* Indexed by reg number (hard or pseudo), nonzero if register is live
   at the current point in the instruction stream.  */

static char *regs_live;

/* Indexed by insn's suid, the set of hard regs live after that insn.  */

static HARD_REG_SET *after_insn_hard_regs;

/* Record that hard reg REGNO is live after insn INSN.  */

#define MARK_LIVE_AFTER(INSN,REGNO)  \
  SET_HARD_REG_BIT (after_insn_hard_regs[INSN_SUID (INSN)], (REGNO))

static void stupid_mark_refs ();
static int stupid_reg_compare ();
static int stupid_find_reg ();

/* Stupid life analysis is for the case where only variables declared
   `register' go in registers.  For this case, we mark all
   pseudo-registers that belong to register variables as
   dying in the last instruction of the function, and all other
   pseudo registers as dying in the last place they are referenced.
   Hard registers are marked as dying in the last reference before
   the end or before each store into them.  */

void
stupid_life_analysis (f, nregs, file)
     rtx f;
     int nregs;
     FILE *file;
{
  register int i;
  register rtx last, insn;
  int max_uid;

  bzero (regs_ever_live, sizeof regs_ever_live);

  regs_live = (char *) alloca (nregs);

  /* First find the last real insn, and count the number of insns,
     and assign insns their suids.  */

  for (insn = f, i = 0; insn; insn = NEXT_INSN (insn))
    if (INSN_UID (insn) > i)
      i = INSN_UID (insn);

  max_uid = i + 1;
  uid_suid = (short *) alloca ((i + 1) * sizeof (short));

  /* Compute the mapping from uids to suids.
     Suids are numbers assigned to insns, like uids,
     except that suids increase monotonically through the code.  */

  last = 0;			/* In case of empty function body */
  for (insn = f, i = 0; insn; insn = NEXT_INSN (insn))
    {
      if (GET_CODE (insn) == INSN || GET_CODE (insn) == CALL_INSN
	  || GET_CODE (insn) == JUMP_INSN)
	last = insn;
      INSN_SUID (insn) = ++i;
    }

  last_call_suid = 0;

  max_regno = nregs;

  /* Allocate tables to record info about regs.  */

  reg_where_dead = (short *) alloca (nregs * sizeof (short));
  bzero (reg_where_dead, nregs * sizeof (short));

  reg_where_born = (short *) alloca (nregs * sizeof (short));
  bzero (reg_where_born, nregs * sizeof (short));

  reg_order = (short *) alloca (nregs * sizeof (short));
  bzero (reg_order, nregs * sizeof (short));

  reg_renumber = (short *) oballoc (nregs * sizeof (short));
  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    reg_renumber[i] = i;

  after_insn_hard_regs = (HARD_REG_SET *) alloca (max_uid * sizeof (HARD_REG_SET));
  bzero (after_insn_hard_regs, max_uid * sizeof (HARD_REG_SET));

  /* Allocate and zero out many data structures
     that will record the data from lifetime analysis.  */

  allocate_for_life_analysis ();

  for (i = 0; i < max_regno; i++)
    {
      reg_n_deaths[i] = 1;
    }

  bzero (regs_live, nregs);

  /* Find where each pseudo register is born and dies,
     by scanning all insns from the end to the start
     and noting all mentions of the registers.

     Also find where each hard register is live
     and record that info in after_insn_hard_regs.
     regs_live[I] is 1 if hard reg I is live
     at the current point in the scan.  */

  for (insn = last; insn; insn = PREV_INSN (insn))
    {
      register HARD_REG_SET *p = after_insn_hard_regs + INSN_SUID (insn);

      /* Copy the info in regs_live
	 into the element of after_insn_hard_regs
	 for the current position in the rtl code.  */

      for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
	if (regs_live[i])
	  SET_HARD_REG_BIT (*p, i);

      /* Mark all call-clobbered regs as live after each call insn
	 so that a pseudo whose life span includes this insn
	 will not go in one of them.
	 Then mark those regs as all dead for the continuing scan
	 of the insns before the call.  */

      if (GET_CODE (insn) == CALL_INSN)
	{
	  last_call_suid = INSN_SUID (insn);
	  IOR_HARD_REG_SET (after_insn_hard_regs[last_call_suid],
			    call_used_reg_set);
	  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
	    if (call_used_regs[i])
	      regs_live[i] = 0;
	}

      /* Update which hard regs are currently live
	 and also the birth and death suids of pseudo regs
	 based on the pattern of this insn.  */

      if (GET_CODE (insn) == INSN
	  || GET_CODE (insn) == CALL_INSN
	  || GET_CODE (insn) == JUMP_INSN)
	{
	  stupid_mark_refs (PATTERN (insn), insn);
	}
    }

  /* Now decide the order in which to allocate the pseudo registers.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    reg_order[i] = i;

  qsort (&reg_order[FIRST_PSEUDO_REGISTER],
	 max_regno - FIRST_PSEUDO_REGISTER, sizeof (short),
	 stupid_reg_compare);

  /* Now, in that order, try to find hard registers for those pseudo regs.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    {
      register int r = reg_order[i];
      enum reg_class class;

      /* Now find the best hard-register class for this pseudo register */
      if (N_REG_CLASSES > 1)
	class = reg_preferred_class (r);

      reg_renumber[r] = stupid_find_reg (reg_crosses_call[r], class,
					 PSEUDO_REGNO_MODE (r),
					 reg_where_born[r],
					 reg_where_dead[r]);

      /* If no reg available in that class,
	 try any reg.  */
      if (reg_renumber[r] == -1)
	reg_renumber[r] = stupid_find_reg (reg_crosses_call[r], GENERAL_REGS,
					   PSEUDO_REGNO_MODE (r),
					   reg_where_born[r],
					   reg_where_dead[r]);
    }

  if (file)
    dump_flow_info (file);
}

/* Comparison function for qsort.
   Returns -1 (1) if register *R1P is higher priority than *R2P.  */

static int
stupid_reg_compare (r1p, r2p)
     short *r1p, *r2p;
{
  register int r1 = *r1p, r2 = *r2p;
  register int len1 = reg_where_dead[r1] - reg_where_born[r1];
  register int len2 = reg_where_dead[r2] - reg_where_born[r2];

  if (len1 != len2)
    return len2 - len1;

  return reg_n_refs[r1] - reg_n_refs[r2];
}

/* Find a block of SIZE words of hard registers in reg_class CLASS
   that can hold a value of machine-mode MODE
     (but actually we test only the first of the block for holding MODE)
   currently free from after insn whose suid is BIRTH
   through the insn whose suid is DEATH,
   and return the number of the first of them.
   Return -1 if such a block cannot be found.
   If CALL_PRESERVED is nonzero, insist on registers preserved
   over subroutine calls, and return -1 if cannot find such.  */

static int
stupid_find_reg (call_preserved, class, mode,
		 born_insn, dead_insn)
     int call_preserved;
     enum reg_class class;
     enum machine_mode mode;
     int born_insn, dead_insn;
{
  register int i, ins;
#ifdef HARD_REG_SET
  register		/* Declare them register if they are scalars.  */
#endif
    HARD_REG_SET used, this_reg;

  COPY_HARD_REG_SET (used,
		     call_preserved ? call_used_reg_set : fixed_reg_set);

  for (ins = born_insn; ins < dead_insn; ins++)
    IOR_HARD_REG_SET (used, after_insn_hard_regs[ins]);

  IOR_COMPL_HARD_REG_SET (used, reg_class_contents[(int) class]);

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    if (! TEST_HARD_REG_BIT (used, i)
	&& HARD_REGNO_MODE_OK (i, mode))
      {
	register int j;
	register int size1 = HARD_REGNO_NREGS (i, mode);
	for (j = 1; j < size1 && ! TEST_HARD_REG_BIT (used, i + j); j++);
	if (j == size1)
	  {
	    CLEAR_HARD_REG_SET (this_reg);
	    while (--j >= 0)
	      SET_HARD_REG_BIT (this_reg, i + j);
	    for (ins = born_insn; ins < dead_insn; ins++)
	      {
		IOR_HARD_REG_SET (after_insn_hard_regs[ins], this_reg);
	      }
	    return i;
	  }
	i += j;			/* Skip starting points we know will lose */
      }
  return -1;
}

/* Walk X, noting all assignments and references to registers
   and recording what they imply about life spans.
   INSN is the current insn, supplied so we can find its suid.  */

static void
stupid_mark_refs (x, insn)
     rtx x, insn;
{
  register RTX_CODE code = GET_CODE (x);
  register char *fmt;
  register int regno, i;

  if (code == SET || code == CLOBBER)
    {
      if (SET_DEST (x) != 0 && GET_CODE (SET_DEST (x)) == REG)
	{
	  /* Register is being assigned.  */
	  regno = REGNO (SET_DEST (x));

	  /* For hard regs, update the where-live info.  */
	  if (regno < FIRST_PSEUDO_REGISTER)
	    {
	      register int j
		= HARD_REGNO_NREGS (regno, GET_MODE (SET_DEST (x)));
	      while (--j >= 0)
		{
		  regs_ever_live[regno+j] = 1;
		  regs_live[regno+j] = 0;
		  /* The following line is for unused outputs;
		     they do get stored even though never used again.  */
		  MARK_LIVE_AFTER (insn, regno);
		}
	    }
	  /* For pseudo regs, record where born, where dead, number of
	     times used, and whether live across a call.  */
	  else
	    {
	      /* Update the life-interval bounds of this reg.  */
	      reg_where_born[regno] = INSN_SUID (insn);

	      /* The reg must live at least one insn even
		 if it is never again used--because it has to go
		 in SOME hard reg.  */
	      if (reg_where_dead[regno] < INSN_SUID (insn) + 1)
		reg_where_dead[regno] = INSN_SUID (insn) + 1;

	      /* Count the refs of this reg.  */
	      reg_n_refs[regno]++;

	      if (last_call_suid < reg_where_dead[regno])
		reg_crosses_call[regno] = 1;
	    }
	}
      /* Record references from the value being set,
	 or from addresses in the place being set if that's not a reg.
	 If setting a SUBREG, we treat the entire reg as *used*.  */
      if (code == SET)
	{
	  stupid_mark_refs (SET_SRC (x), insn);
	  if (GET_CODE (SET_DEST (x)) != REG)
	    stupid_mark_refs (SET_DEST (x), insn);
	}
      return;
    }

  /* Register value being used, not set.  */

  if (code == REG)
    {
      regno = REGNO (x);
      if (regno < FIRST_PSEUDO_REGISTER)
	{
	  /* Hard reg: mark it live for continuing scan of previous insns.  */
	  register int j = HARD_REGNO_NREGS (regno, GET_MODE (x));
	  while (--j >= 0)
	    {
	      regs_ever_live[regno+j] = 1;
	      regs_live[regno+j] = 1;
	    }
	}
      else
	{
	  /* Pseudo reg: record first use, last use and number of uses.  */

	  reg_where_born[regno] = INSN_SUID (insn);
	  reg_n_refs[regno]++;
	  if (regs_live[regno] == 0)
	    {
	      regs_live[regno] = 1;
	      reg_where_dead[regno] = INSN_SUID (insn);
	    }
	}
      return;
    }

  /* Recursive scan of all other rtx's.  */

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	stupid_mark_refs (XEXP (x, i), insn);
      if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = XVECLEN (x, i) - 1; j >= 0; j--)
	    stupid_mark_refs (XVECEXP (x, i, j), insn);
	}
    }
}
