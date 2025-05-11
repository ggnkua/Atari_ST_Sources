/* Reload pseudo regs into hard regs for insns that require hard regs.
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
#include "flags.h"
#include "regs.h"
#include "hard-reg-set.h"
#include "reload.h"
#include "insn-config.h"
#include "basic-block.h"
#include <stdio.h>

#define min(A,B) ((A) < (B) ? (A) : (B))

/* This file contains the reload pass of the compiler, which is
   run after register allocation has been done.  It checks that
   each insn is valid (operands required to be in registers really
   are in registers of the proper class) and fixes up invalid ones
   by copying values temporarily into registers for the insns
   that need them.

   The results of register allocation are described by the vector
   reg_renumber; the insns still contain pseudo regs, but reg_renumber
   can be used to find which hard reg, if any, a pseudo reg is in.

   The technique we always use is to free up a few hard regs that are
   called ``reload regs'', and for each place where a pseudo reg
   must be in a hard reg, copy it temporarily into one of the reload regs.

   All the pseudos that were formerly allocated to the hard regs that
   are now in use as reload regs must be ``spilled''.  This means
   that they go to other hard regs, or to stack slots if no other
   available hard regs can be found.  Spilling can invalidate more
   insns, requiring additional need for reloads, so we must keep checking
   until the process stabilizes.

   For machines with different classes of registers, we must keep track
   of the register class needed for each reload, and make sure that
   we allocate enough reload registers of each class.

   The file reload.c contains the code that checks one insn for
   validity and reports the reloads that it needs.  This file
   is in charge of scanning the entire rtl code, accumulating the
   reload needs, spilling, assigning reload registers to use for
   fixing up each insn, and generating the new insns to copy values
   into the reload registers.  */

/* During reload_as_needed, element N contains a REG rtx for the hard reg
   into which pseudo reg N has been reloaded (perhaps for a previous insn). */
static rtx *reg_last_reload_reg;

/* Element N is the constant value to which pseudo reg N is equivalent,
   or zero if pseudo reg N is not equivalent to a constant.
   find_reloads looks at this in order to replace pseudo reg N
   with the constant it stands for.  */
rtx *reg_equiv_constant;

/* Element N is the address of stack slot to which pseudo reg N is equivalent.
   This is used when the address is not valid as a memory address
   (because its displacement is too big for the machine.)  */
rtx *reg_equiv_address;

/* Element N is the memory slot to which pseudo reg N is equivalent,
   or zero if pseudo reg N is not equivalent to a memory slot.  */
static rtx *reg_equiv_mem;

/* Element N is the insn that initialized reg N from its equivalent
   constant or memory slot.  */
static rtx *reg_equiv_init;

/* During reload_as_needed, element N contains the last pseudo regno
   reloaded into the Nth reload register.  This vector is in parallel
   with spill_regs.  */
static int reg_reloaded_contents[FIRST_PSEUDO_REGISTER];

/* Number of spill-regs so far; number of valid elements of spill_regs.  */
static int n_spills;

/* In parallel with spill_regs, contains REG rtx's for those regs.
   Holds the last rtx used for any given reg, or 0 if it has never
   been used for spilling yet.  This rtx is reused, provided it has
   the proper mode.  */
static rtx spill_reg_rtx[FIRST_PSEUDO_REGISTER];

/* In parallel with spill_regs, contains nonzero for a spill reg
   that was stored after the last time it was used.
   The precise value is the insn generated to do the store.  */
static rtx spill_reg_store[FIRST_PSEUDO_REGISTER];

/* This table is the inverse mapping of spill_regs:
   indexed by hard reg number,
   it contains the position of that reg in spill_regs,
   or -1 for something that is not in spill_regs.  */
static short spill_reg_order[FIRST_PSEUDO_REGISTER];

/* This table contains 1 for a register that may not be used
   for retrying global allocation, or -1 for a register that may be used.
   The registers that may not be used include all spill registers
   and the frame pointer (if we are using one).  */
static short forbidden_regs[FIRST_PSEUDO_REGISTER];

/* Describes order of use of registers for reloading
   of spilled pseudo-registers.  `spills' is the number of
   elements that are actually valid; new ones are added at the end.  */
static char spill_regs[FIRST_PSEUDO_REGISTER];

/* Describes order of preference for putting regs into spill_regs.
   Contains the numbers of all the hard regs, in order most preferred first.
   This order is different for each function.
   It is set up by order_regs_for_reload.
   Empty elements at the end contain -1.  */
static short potential_reload_regs[FIRST_PSEUDO_REGISTER];

/* 1 for a hard register that appears explicitly in the rtl
   (for example, function value registers, special registers
   used by insns, structure value pointer registers).  */
static char regs_explicitly_used[FIRST_PSEUDO_REGISTER];

/* Nonzero if spilling (REG n) does not require reloading it into
   a register in order to do (MEM (REG n)).  */

static char spill_indirect_ok;

/* Indexed by basic block number, nonzero if there is any need
   for a spill register in that basic block.
   The pointer is 0 if we did stupid allocation and don't know
   the structure of basic blocks.  */

char *basic_block_needs;

/* First uid used by insns created by reload in this function.
   Used in find_equiv_reg.  */
int reload_first_uid;

void mark_home_live ();
static void reload_as_needed ();
static rtx alter_frame_pointer_addresses ();
static void alter_reg ();
static int new_spill_reg();
static int spill_hard_reg ();
static void choose_reload_targets ();
static void forget_old_reloads ();
static void order_regs_for_reload ();
static void eliminate_frame_pointer ();

extern void remove_death ();
extern rtx adj_offsetable_operand ();

/* Main entry point for the reload pass, and only entry point
   in this file.

   FIRST is the first insn of the function being compiled.

   GLOBAL nonzero means we were called from global_alloc
   and should attempt to reallocate any pseudoregs that we
   displace from hard regs we will use for reloads.
   If GLOBAL is zero, we do not have enough information to do that,
   so any pseudo reg that is spilled must go to the stack.

   DUMPFILE is the global-reg debugging dump file stream, or 0.
   If it is nonzero, messages are written to it to describe
   which registers are seized as reload regs, which pseudo regs
   are spilled from them, and where the pseudo regs are reallocated to.  */

void
reload (first, global, dumpfile)
     rtx first;
     int global;
     FILE *dumpfile;
{
  register int class;
  register int i;
  register rtx insn;

  int something_changed;
  int something_needs_reloads;
  int new_basic_block_needs;

  /* The basic block number currently being processed for INSN.  */
  int this_block;

  /* Enable find_equiv_reg to distinguish insns made by reload.  */
  reload_first_uid = get_max_uid ();

  basic_block_needs = 0;

  /* Remember which hard regs appear explicitly
     before we merge into `regs_ever_live' the ones in which
     pseudo regs have been allocated.  */
  bcopy (regs_ever_live, regs_explicitly_used, sizeof regs_ever_live);

  /* Compute which hard registers are now in use
     as homes for pseudo registers.
     This is done here rather than (eg) in global_alloc
     because this point is reached even if not optimizing.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    mark_home_live (i);

  /* Find all the pseudo registers that didn't get hard regs
     but do have known equivalent constants or memory slots.
     These include parameters (known equivalent to parameter slots)
     and cse'd or loop-moved constant memory addresses.

     Record constant equivalents in reg_equiv_constant
     so they will be substituted by find_reloads.
     Record memory equivalents in reg_mem_equiv so they can
     be substituted eventually by altering the REG-rtx's.  */

  reg_equiv_constant = (rtx *) alloca (max_regno * sizeof (rtx));
  bzero (reg_equiv_constant, max_regno * sizeof (rtx));
  reg_equiv_mem = (rtx *) alloca (max_regno * sizeof (rtx));
  bzero (reg_equiv_mem, max_regno * sizeof (rtx));
  reg_equiv_init = (rtx *) alloca (max_regno * sizeof (rtx));
  bzero (reg_equiv_init, max_regno * sizeof (rtx));
  reg_equiv_address = (rtx *) alloca (max_regno * sizeof (rtx));
  bzero (reg_equiv_address, max_regno * sizeof (rtx));

  for (insn = first; insn; insn = NEXT_INSN (insn))
    if (GET_CODE (insn) == INSN
	&& GET_CODE (PATTERN (insn)) == SET
	&& GET_CODE (SET_DEST (PATTERN (insn))) == REG)
      {
	rtx note = find_reg_note (insn, REG_EQUIV, 0);
	if (note)
	  {
	    rtx x = XEXP (note, 0);
	    i = REGNO (SET_DEST (PATTERN (insn)));
	    if (GET_CODE (x) == MEM)
	      reg_equiv_mem[i] = x;
	    else if (immediate_operand (x))
	      reg_equiv_constant[i] = x;
	    else
	      continue;

	    reg_equiv_init[i] = insn;
	  }
      }

  /* Does this function require a frame pointer?  */

  frame_pointer_needed
    |= (! global || FRAME_POINTER_REQUIRED);

  if (! frame_pointer_needed)
    frame_pointer_needed
      = check_frame_pointer_required (reg_equiv_constant, reg_equiv_mem);

  /* Alter each pseudo-reg rtx to contain its hard reg number.
     Delete initializations of pseudos that don't have hard regs
     and do have equivalents.
     Assign stack slots to the pseudos that lack hard regs or equivalents.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    alter_reg (i);

#ifndef REGISTER_CONSTRAINTS
  /* If all the pseudo regs have hard regs,
     except for those that are never referenced,
     we know that no reloads are needed.  */
  /* But that is not true if there are register constraints, since
     in that case some pseudos might be in the wrong kind of hard reg.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    if (reg_renumber[i] == -1 && reg_n_refs[i] != 0)
      break;

  if (i == max_regno && frame_pointer_needed)
    return;
#endif

  /* Compute the order of preference for hard registers to spill.
     Store them by decreasing preference in potential_reload_regs.  */

  order_regs_for_reload ();

  /* So far, no hard regs have been spilled.  */
  n_spills = 0;
  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    {
      spill_reg_order[i] = -1;
      forbidden_regs[i] = -1;
    }

  if (frame_pointer_needed)
    {
      forbidden_regs[FRAME_POINTER_REGNUM] = 1;
      spill_hard_reg (FRAME_POINTER_REGNUM, global, dumpfile);
    }

  if (global)
    {
      basic_block_needs = (char *)alloca (n_basic_blocks);
      bzero (basic_block_needs, n_basic_blocks);
    }

  /* This loop scans the entire function each go-round
     and repeats until one repetition spills no additional hard regs.  */

  /* This flag is set when a psuedo reg is spilled,
     to require another pass.  Note that getting an additional reload
     reg does not necessarily imply any pseudo reg was spilled;
     sometimes we find a reload reg that no pseudo reg was allocated in.  */
  something_changed = 1;
  /* This flag is set if there are any insns that require reloading.  */
  something_needs_reloads = 0;
  while (something_changed)
    {
      /* For each class, number of reload regs needed in that class.
	 This is the maximum over all insns of the needs in that class
	 of the individual insn.  */
      int max_needs[N_REG_CLASSES];
      /* For each class, size of group of consecutive regs
	 that is needed for the reloads of this class.  */
      int group_size[N_REG_CLASSES];
      /* For each class, max number of consecutive groups needed.
	 (Each group contains max_needs_size[CLASS] consecutive registers.)  */
      int max_groups[N_REG_CLASSES];
      /* For each class, max number needed of regs that don't belong
	 to any of the groups.  */
      int max_nongroups[N_REG_CLASSES];
      /* For each class, the machine mode which requires consecutive
	 groups of regs of that class.
	 If two different modes ever require groups of one class,
	 they must be tieable and the same number of regs;
	 otherwise we can't handle the complexity.  */
      enum machine_mode group_mode[N_REG_CLASSES];
      /* For each register, 1 if it was counted against the need for
	 groups.  0 means it can count against max_nongroup instead.  */
      char counted_for_groups[FIRST_PSEUDO_REGISTER];
      /* For each register, 1 if it was counted against the need for
	 non-groups.  0 means it can become part of a new group.  */
      char counted_for_nongroups[FIRST_PSEUDO_REGISTER];

      something_changed = 0;
      bzero (max_needs, sizeof max_needs);
      bzero (max_groups, sizeof max_groups);
      bzero (max_nongroups, sizeof max_nongroups);
      bzero (group_size, sizeof group_size);
      for (i = 0; i < N_REG_CLASSES; i++)
	group_mode[i] = VOIDmode;

      /* Keep track of which basic blocks are needing the reloads.  */
      this_block = 0;

      /* Remember whether any element of basic_block_needs
	 changes from 0 to 1 in this pass.  */
      new_basic_block_needs = 0;

      /* Compute the most additional registers needed by any instruction.
	 Collect information separately for each class of regs.  */

      for (insn = first; insn; insn = NEXT_INSN (insn))
	{
	  if (global && insn == basic_block_head[this_block+1])
	    ++this_block;

	  if (GET_CODE (insn) == INSN || GET_CODE (insn) == JUMP_INSN
	      || GET_CODE (insn) == CALL_INSN)
	    {
	      int insn_needs[N_REG_CLASSES];
	      int insn_groups[N_REG_CLASSES];
	      int insn_total_groups = 0;

	      for (i = 0; i < N_REG_CLASSES; i++)
		insn_needs[i] = 0, insn_groups[i] = 0;

#if 0
	      /* Optimization: a bit-field instruction whose field
		 happens to be a byte or halfword in memory
		 can be changed to a move instruction.  */

	      if (GET_CODE (PATTERN (insn)) == SET)
		{
		  rtx dest = SET_DEST (PATTERN (insn));
		  rtx src = SET_SRC (PATTERN (insn));

		  if (GET_CODE (dest) == ZERO_EXTRACT
		      || GET_CODE (dest) == SIGN_EXTRACT)
		    optimize_bit_field (PATTERN (insn), insn, reg_equiv_mem);
		  if (GET_CODE (src) == ZERO_EXTRACT
		      || GET_CODE (src) == SIGN_EXTRACT)
		    optimize_bit_field (PATTERN (insn), insn, reg_equiv_mem);
		}
#endif

	      /* Analyze the instruction.  */

	      find_reloads (insn, 0, spill_indirect_ok, global, spill_reg_order);

	      if (n_reloads == 0)
		continue;

	      something_needs_reloads = 1;

	      /* Count each reload once in every class
		 containing the reload's own class.  */

	      for (i = 0; i < n_reloads; i++)
		{
		  register enum reg_class *p;
		  int size;
		  enum machine_mode mode;

		  /* Don't count the dummy reloads, for which one of the
		     regs mentioned in the insn can be used for reloading.
		     Don't count optional reloads.
		     Don't count reloads that got combined with others.  */
		  if (reload_reg_rtx[i] != 0
		      || reload_optional[i] != 0
		      || (reload_out[i] == 0 && reload_in[i] == 0))
		    continue;

		  mode = reload_inmode[i];
		  if (GET_MODE_SIZE (reload_outmode[i]) > GET_MODE_SIZE (mode))
		    mode = reload_outmode[i];
		  size = CLASS_MAX_NREGS (reload_reg_class[i], mode);
		  if (size > 1)
		    {
		      /* Count number of groups needed separately from
			 number of individual regs needed.  */
		      insn_groups[(int) reload_reg_class[i]]++;
		      p = reg_class_superclasses[(int) reload_reg_class[i]];
		      while (*p != LIM_REG_CLASSES)
			insn_groups[(int) *p++]++;
		      insn_total_groups++;

		      /* If a group of consecutive regs are needed,
			 record which machine mode needs them.
			 Crash if two dissimilar machine modes both need
			 groups of consecutive regs of the same class.  */

		      if (group_mode[(int) reload_reg_class[i]] != VOIDmode
			  &&
			  (!MODES_TIEABLE_P (group_mode[(int) reload_reg_class[i]], mode)
			   ||
			   group_size[(int) reload_reg_class[i]] != size))
			abort ();

		      /* Record size and mode of a group of this class.  */
		      group_size[(int) reload_reg_class[i]] = size;
		      group_mode[(int) reload_reg_class[i]] = mode;
		    }
		  else if (size == 1)
		    {
		      insn_needs[(int) reload_reg_class[i]] += 1;
		      p = reg_class_superclasses[(int) reload_reg_class[i]];
		      while (*p != LIM_REG_CLASSES)
			insn_needs[(int) *p++] += 1;
		    }
		  else
		    abort ();

		  if (global)
		    {
		      if (! basic_block_needs[this_block])
			new_basic_block_needs = 1;
		      basic_block_needs[this_block] = 1;
		    }
		}

	      /* Remember for later shortcuts which insns had any reloads.  */

	      PUT_MODE (insn, n_reloads ? QImode : VOIDmode);

	      /* For each class, collect maximum need of any insn */

	      for (i = 0; i < N_REG_CLASSES; i++)
		{
		  if (max_needs[i] < insn_needs[i])
		    max_needs[i] = insn_needs[i];
		  if (max_groups[i] < insn_groups[i])
		    max_groups[i] = insn_groups[i];
		  if (insn_total_groups > 0)
		    if (max_nongroups[i] < insn_needs[i])
		      max_nongroups[i] = insn_needs[i];
		}
	    }
	  /* Note that there is a continue statement above.  */
	}

      /* Now deduct from the needs for the registers already
	 available (already spilled).  */

      bzero (counted_for_groups, sizeof counted_for_groups);
      bzero (counted_for_nongroups, sizeof counted_for_nongroups);

      /* Find all consecutive groups of spilled registers
	 and mark each group off against the need for such groups.  */

      for (i = 0; i < N_REG_CLASSES; i++)
	if (group_size[i] > 1)
	  {
	    char regmask[FIRST_PSEUDO_REGISTER];
	    int j;

	    bzero (regmask, sizeof regmask);
	    /* Make a mask of all the regs that are spill regs in class I.  */
	    for (j = 0; j < n_spills; j++)
	      if (TEST_HARD_REG_BIT (reg_class_contents[i], spill_regs[j])
		  && !counted_for_groups[spill_regs[i]])
		regmask[spill_regs[j]] = 1;
	    /* Find each consecutive group of them.  */
	    for (j = 0; j < FIRST_PSEUDO_REGISTER && max_groups[i] > 0; j++)
	      if (regmask[j] && j + group_size[i] <= FIRST_PSEUDO_REGISTER
		  /* Next line in case group-mode for this class
		     demands an even-odd pair.  */
		  && HARD_REGNO_MODE_OK (j, group_mode[i]))
		{
		  int k;
		  for (k = 1; k < group_size[i]; k++)
		    if (! regmask[j + k])
		      break;
		  if (k == group_size[i])
		    {
		      /* We found a group.  Mark it off against this class's
			 need for groups, and against each superclass too.  */
		      register enum reg_class *p;
		      max_groups[i]--;
		      p = reg_class_superclasses[i];
		      while (*p != LIM_REG_CLASSES)
			max_groups[(int) *p++]--;
		      /* Don't count these registers again.  */ 
		      counted_for_groups[j] = 1;
		      for (k = 1; k < group_size[i]; k++)
			counted_for_groups[j + k] = 1;
		    }
		  j += k;
		}
	  }

      /* Now count all remaining spill regs against the individual need.
	 Those that weren't counted_for_groups in groups can also count against
	 the not-in-group need.  */

      for (i = 0; i < n_spills; i++)
	{
	  register enum reg_class *p;
	  class = (int) REGNO_REG_CLASS (spill_regs[i]);

	  max_needs[class]--;
	  p = reg_class_superclasses[class];
	  while (*p != LIM_REG_CLASSES)
	    max_needs[(int) *p++]--;

	  if (! counted_for_groups[spill_regs[i]])
	    {
	      if (max_nongroups[class] > 0)
		counted_for_nongroups[spill_regs[i]] = 1;
	      max_nongroups[class]--;
	      p = reg_class_superclasses[class];
	      while (*p != LIM_REG_CLASSES)
		{
		  if (max_nongroups[(int) *p] > 0)
		    counted_for_nongroups[spill_regs[i]] = 1;
		  max_nongroups[(int) *p++]--;
		}
	    }
	}

      /* If all needs are met, we win.  */

      for (i = 0; i < N_REG_CLASSES; i++)
	if (max_needs[i] > 0 || max_groups[i] > 0 || max_nongroups[i] > 0)
	  break;
      if (i == N_REG_CLASSES && !new_basic_block_needs)
	break;

      /* Not all needs are met; must spill more hard regs.  */

      /* If any element of basic_block_needs changed from 0 to 1,
	 re-spill all the regs already spilled.  This may spill
	 additional pseudos that didn't spill before.  */

      if (new_basic_block_needs)
	for (i = 0; i < n_spills; i++)
	  something_changed
	    |= spill_hard_reg (spill_regs[i], global, dumpfile);

      /* Now find more reload regs to satisfy the remaining need
	 First satisfy all need for groups of registers.
	 Count them in `spills', and add entries to
	 `spill_regs' and `spill_reg_order'.  */

      for (class = 0; class < N_REG_CLASSES; class++)
	while (max_groups[class] > 0)
	  {
	    register enum reg_class *p;

	    /* First, if we need more groups of consecutive regs, get them.
	       Either get a spill register that completes a group
	       or, if that cannot be done, get one that starts a group.
	       Here we do not yet handle groups of size > 2.  */
	    if (max_groups[class] > 0)
	      {
		if (group_size[class] > 2)
		  abort ();

		for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
		  {
		    int j = potential_reload_regs[i];
		    if (j >= 0
			&&
			((j > 0 && spill_reg_order[j - 1] >= 0
			  && TEST_HARD_REG_BIT (reg_class_contents[class], j)
			  && TEST_HARD_REG_BIT (reg_class_contents[class], j - 1)
			  && HARD_REGNO_MODE_OK (j - 1, group_mode[class])
			  && ! counted_for_nongroups[j - 1])
			 ||
			 (j < FIRST_PSEUDO_REGISTER - 1
			  && spill_reg_order[j + 1] >= 0
			  && TEST_HARD_REG_BIT (reg_class_contents[class], j)
			  && TEST_HARD_REG_BIT (reg_class_contents[class], j + 1)
			  && HARD_REGNO_MODE_OK (j, group_mode[class])
			  && ! counted_for_nongroups[j + 1])))
		      {
			/* We have found one that will complete a group,
			   so count off one group as provided.  */
			max_groups[class]--;
			p = reg_class_superclasses[class];
			while (*p != LIM_REG_CLASSES)
			  max_groups[(int) *p++]--;
			break;
		      }
		  }
		/* We can't complete any group, so start one.  */
		if (i == FIRST_PSEUDO_REGISTER)
		  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
		    {
		      int j = potential_reload_regs[i];
		      if (j >= 0 && j + 1 < FIRST_PSEUDO_REGISTER
			  && spill_reg_order[j] < 0 && spill_reg_order[j + 1] < 0
			  && TEST_HARD_REG_BIT (reg_class_contents[class], j)
			  && TEST_HARD_REG_BIT (reg_class_contents[class], j + 1)
			  && HARD_REGNO_MODE_OK (j, group_mode[class])
			  && ! counted_for_nongroups[j + 1])
			break;
		    }
	      }

	    /* I should be the index in potential_reload_regs
	       of the new reload reg we have found.  */

	    something_changed
	      |= new_spill_reg (i, class, max_needs, 0,
				global, dumpfile);
	}

      /* Now similarly satisfy all need for single registers.  */

      for (class = 0; class < N_REG_CLASSES; class++)
	while (max_needs[class] > 0 || max_nongroups[class] > 0)
	  {
	    /* Consider the potential reload regs that aren't
	       yet in use as reload regs, in order of preference.
	       Find the most preferred one that's in this class.  */

	    for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
	      if (potential_reload_regs[i] >= 0
		  && TEST_HARD_REG_BIT (reg_class_contents[class],
					potential_reload_regs[i]))
		break;

	    /* I should be the index in potential_reload_regs
	       of the new reload reg we have found.  */

	    something_changed
	      |= new_spill_reg (i, class, max_needs, max_nongroups,
				global, dumpfile);
	}
    }

  /* Now we know for certain whether we have a frame pointer.
     If not, correct all references to go through the stack pointer.
     This must be done before reloading, since reloading could generate
     insns where sp+const cannot validly replace the frame pointer.
     *This will lose if an insn might need more spill regs after
     frame pointer elimination than it needed before.*  */

  if (! frame_pointer_needed)
    eliminate_frame_pointer (first);

  /* Use the reload registers where necessary
     by generating move instructions to move the must-be-register
     values into or out of the reload registers.  */

  if (something_needs_reloads)
    reload_as_needed (first, global);

  /* Now eliminate all pseudo regs by modifying them into
     their equivalent memory references.
     The REG-rtx's for the pseudos are modified in place,
     so all insns that used to refer to them now refer to memory.

     For a reg that has a reg_equiv_address, all those insns
     were changed by reloading so that no insns refer to it any longer;
     but the DECL_RTL of a variable decl may refer to it,
     and if so this causes the debugging info to mention the variable.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    {
      rtx addr = 0;
      if (reg_equiv_mem[i])
	addr = XEXP (reg_equiv_mem[i], 0);
      if (reg_equiv_address[i])
	addr = reg_equiv_address[i];
      if (addr)
	{
	  if (reg_renumber[i] < 0)
	    {
	      rtx reg = regno_reg_rtx[i];
	      XEXP (reg, 0) = addr;
	      PUT_CODE (reg, MEM);
	    }
	  else if (reg_equiv_mem[i])
	    {
	      if (! frame_pointer_needed)
		FIX_FRAME_POINTER_ADDRESS (addr, 0);
	      XEXP (reg_equiv_mem[i], 0) = addr;
	    }
	}
    }
}

/* Add a new register REGNO to the tables of available spill-registers
    (as well as spilling all pseudos allocated to the register).
   CLASS is the regclass whose need is being satisfied.
   MAX_NEEDS and MAX_NONGROUPS are the vectors of needs,
    so that this register can count off against them.
    MAX_NONGROUPS is 0 if this register is part of a group.
   GLOBAL and DUMPFILE are the same as the args that `reload' got.  */

static int
new_spill_reg (regno, class, max_needs, max_nongroups, global, dumpfile)
     int regno;
     int class;
     int *max_needs;
     int *max_nongroups;
     int global;
     FILE *dumpfile;
{
  register enum reg_class *p;
  int val;

  if (regno >= FIRST_PSEUDO_REGISTER)
    abort ();	/* Caller failed to find any register.  */

  /* Make potential_reload_regs[REGNO] an additional reload reg.  */

  spill_regs[n_spills] = potential_reload_regs[regno];
  spill_reg_order[potential_reload_regs[regno]] = n_spills;
  forbidden_regs[potential_reload_regs[regno]] = 1;
  potential_reload_regs[regno] = -1;
  if (dumpfile)
    fprintf (dumpfile, "Spilling reg %d.\n", spill_regs[n_spills]);

  /* Clear off the needs we just satisfied.  */

  max_needs[class]--;
  p = reg_class_superclasses[class];
  while (*p != LIM_REG_CLASSES)
    max_needs[(int) *p++]--;

  if (max_nongroups)
    {
      max_nongroups[class]--;
      p = reg_class_superclasses[class];
      while (*p != LIM_REG_CLASSES)
	max_nongroups[(int) *p++]--;
    }

  /* Spill every pseudo reg that was allocated to this reg
     or to something that overlaps this reg.  */

  val = spill_hard_reg (spill_regs[n_spills], global, dumpfile);

  regs_ever_live[spill_regs[n_spills]] = 1;
  n_spills++;

  return val;
}

/* Scan all insns, computing the stack depth, and convert all
   frame-pointer-relative references to stack-pointer-relative references.  */

static void
eliminate_frame_pointer (first)
     rtx first;
{
  int depth = 0;
  int max_uid = get_max_uid ();
  int *label_depth = (int *) alloca ((max_uid + 1) * sizeof (int));
  int i;
  rtx insn;

  for (i = 0; i <= max_uid; i++)
    label_depth[i] = -1;

  /* In this loop, for each forward branch we record the stack
     depth of the label it jumps to.  We take advantage of the fact
     that the stack depth at a label reached by a backward branch
     is always, in GCC output, equal to the stack depth of the preceding
     unconditional jump, because it was either a loop statement or
     statement label.  */

  for (insn = first; insn; insn = NEXT_INSN (insn))
    {
      rtx pattern = PATTERN (insn);
      switch (GET_CODE (insn))
	{
	case INSN:
	  alter_frame_pointer_addresses (pattern, depth);
#ifdef PUSH_ROUNDING
	  /* Notice pushes and pops; update DEPTH.  */
	  if (GET_CODE (pattern) == SET)
	    {
	      if (push_operand (SET_DEST (pattern),
				GET_MODE (SET_DEST (pattern))))
		depth += PUSH_ROUNDING (GET_MODE_SIZE (GET_MODE (SET_DEST (pattern))));
	      if (GET_CODE (SET_DEST (pattern)) == REG
		  && REGNO (SET_DEST (pattern)) == STACK_POINTER_REGNUM)
		{
		  int delta;
		  if (GET_CODE (SET_SRC (pattern)) == PLUS
		      && GET_CODE (XEXP (SET_SRC (pattern), 0)) == REG
		      && REGNO (XEXP (SET_SRC (pattern), 0)) == STACK_POINTER_REGNUM)
		    delta = INTVAL (XEXP (SET_SRC (pattern), 1));
		  else if (GET_CODE (SET_SRC (pattern)) == MINUS
			   && GET_CODE (XEXP (SET_SRC (pattern), 0)) == REG
			   && REGNO (XEXP (SET_SRC (pattern), 0)) == STACK_POINTER_REGNUM)
		    delta = -INTVAL (XEXP (SET_SRC (pattern), 1));
		  else abort ();
#ifdef STACK_GROWS_DOWNWARD
		  depth -= delta;
#else
		  depth += delta;
#endif
		}
	    }
#endif
	  break;

	case JUMP_INSN:
	  alter_frame_pointer_addresses (pattern, depth);
	  if (GET_CODE (pattern) == ADDR_VEC)
	    for (i = 0; i < XVECLEN (pattern, 0); i++)
	      label_depth[INSN_UID (XEXP (XVECEXP (pattern, 0, i), 0))] = depth;
	  else if (GET_CODE (pattern) == ADDR_DIFF_VEC)
	    {
	      label_depth[INSN_UID (XEXP (XEXP (pattern, 0), 0))] = depth;
	      for (i = 0; i < XVECLEN (pattern, 1); i++)
		label_depth[INSN_UID (XEXP (XVECEXP (pattern, 1, i), 0))] = depth;
	    }
	  else if (JUMP_LABEL (insn))
	    label_depth[INSN_UID (JUMP_LABEL (insn))] = depth;
	  else
	  break;

	case CODE_LABEL:
	  if (label_depth [INSN_UID (insn)] >= 0)
	    depth = label_depth [INSN_UID (insn)];
	  break;

	case CALL_INSN:
	  alter_frame_pointer_addresses (pattern, depth);
	  break;
	}
    }
}

/* Walk the rtx X, converting all frame-pointer refs to stack-pointer refs
   on the assumption that the current temporary stack depth is DEPTH.
   (The size of saved registers must be added to DEPTH
   to get the actual offset between the logical frame-pointer and the
   stack pointer.  FIX_FRAME_POINTER_ADDRESS takes care of that.)  */

static rtx
alter_frame_pointer_addresses (x, depth)
     register rtx x;
     int depth;
{
  register int i;
  register char *fmt;
  register enum rtx_code code = GET_CODE (x);

  switch (code)
    {
    case CONST_INT:
    case CONST:
    case SYMBOL_REF:
    case LABEL_REF:
    case CONST_DOUBLE:
    case CC0:
    case PC:
      return x;

    case REG:
      /* Frame ptr can occur outside a PLUS if a stack slot
	 can occur with offset 0.  */
      if (x == frame_pointer_rtx)
	{
	  FIX_FRAME_POINTER_ADDRESS (x, depth);
	}
      return x;

    case MEM:
      {
	rtx addr = XEXP (x, 0);
	FIX_FRAME_POINTER_ADDRESS (addr, depth);
	XEXP (x, 0) = addr;
      }
      break;

    case PLUS:
      /* Handle addresses being loaded or pushed, etc.,
	 rather than referenced.  */
      FIX_FRAME_POINTER_ADDRESS (x, depth);
      break;
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	XEXP (x, i) = alter_frame_pointer_addresses (XEXP (x, i), depth);
      else if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = XVECLEN (x, i) - 1; j >=0; j--)
	    XVECEXP (x, i, j)
	      = alter_frame_pointer_addresses (XVECEXP (x, i, j), depth);
	}
    }
  return x;
}

static void
alter_reg (i)
     register int i;
{
  /* If the reg got changed to a MEM at rtl-generation time,
     ignore it.  */
  if (GET_CODE (regno_reg_rtx[i]) != REG)
    return;

  /* Modify the reg-rtx to contain the new hard reg
     number or else to contain its pseudo reg number.  */
  REGNO (regno_reg_rtx[i])
    = reg_renumber[i] >= 0 ? reg_renumber[i] : i;

  if (reg_renumber[i] < 0 && reg_equiv_init[i])
    {
      /* Delete the insn that loads the pseudo register.  */
      PUT_CODE (reg_equiv_init[i], NOTE);
      NOTE_LINE_NUMBER (reg_equiv_init[i])
	= NOTE_INSN_DELETED;
      NOTE_SOURCE_FILE (reg_equiv_init[i]) = 0;
    }

  /* If we have a pseudo that is needed but has no hard reg or equivalent,
     allocate a stack slot for it.  */

  if (reg_renumber[i] < 0
      && reg_n_refs[i] > 0
      && reg_equiv_constant[i] == 0
      && reg_equiv_mem[i] == 0)
    {
      register rtx x = assign_stack_local (GET_MODE (regno_reg_rtx[i]),
					   PSEUDO_REGNO_BYTES (i));
      register rtx addr = XEXP (x, 0);
      /* If the stack slot is directly addressable, substitute
	 the MEM we just got directly for the old REG.
	 Otherwise, record the address; we will generate hairy code
	 to compute the address in a register each time it is needed.  */
      if (memory_address_p (GET_MODE (regno_reg_rtx[i]), addr))
	reg_equiv_mem[i] = x;
      else
	reg_equiv_address[i] = XEXP (x, 0);
    }
}

/* Mark the slots in regs_ever_live for the hard regs
   used by pseudo-reg number REGNO.  */

void
mark_home_live (regno)
     int regno;
{
  register int i, lim;
  i = reg_renumber[regno];
  if (i < 0)
    return;
  lim = i + HARD_REGNO_NREGS (i, PSEUDO_REGNO_MODE (regno));
  while (i < lim)
    regs_ever_live[i++] = 1;
}

/* Kick all pseudos out of hard register REGNO.
   If GLOBAL is nonzero, try to find someplace else to put them.
   If DUMPFILE is nonzero, log actions taken on that file.

   Return nonzero if any pseudos needed to be kicked out.  */

static int
spill_hard_reg (regno, global, dumpfile)
     register int regno;
     int global;
     FILE *dumpfile;
{
  int something_changed = 0;
  register int i;

  /* Spill every pseudo reg that was allocated to this reg
     or to something that overlaps this reg.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    if (reg_renumber[i] >= 0
	&& reg_renumber[i] <= regno
	&& (reg_renumber[i] 
	    + HARD_REGNO_NREGS (reg_renumber[i],
				PSEUDO_REGNO_MODE (i))
	    > regno))
      {
#if 1
	/* If this register belongs solely to a basic block
	   which needed no spilling, leave it be.  */
	if (basic_block_needs
	    && reg_basic_block[i] >= 0
	    && basic_block_needs[reg_basic_block[i]] == 0)
	  continue;
#endif

	/* Mark it as no longer having a hard register home.  */
	reg_renumber[i] = -1;
	/* We will need to scan everything again.  */
	something_changed = 1;
	if (global)
	  {
	    retry_global_alloc (i, forbidden_regs);
	    /* Update regs_ever_live for new home (if any).  */
	    mark_home_live (i);
	    /* If something gets spilled to the stack,
	       we must have a frame pointer, so spill the frame pointer.  */
	    if (reg_renumber[i] == -1 && ! frame_pointer_needed)
	      {
		frame_pointer_needed = 1;
		forbidden_regs[FRAME_POINTER_REGNUM] = 1;
		spill_hard_reg (FRAME_POINTER_REGNUM, global, dumpfile);
	      }
	  }
	alter_reg (i);
	if (dumpfile)
	  {
	    if (reg_renumber[i] == -1)
	      fprintf (dumpfile, " Register %d now on stack.\n\n", i);
	    else
	      fprintf (dumpfile, " Register %d now in %d.\n\n",
		       i, reg_renumber[i]);
	  }
      }

  return something_changed;
}

struct hard_reg_n_uses { int regno; int uses; };

static int
hard_reg_use_compare (p1, p2)
     struct hard_reg_n_uses *p1, *p2;
{
  return p1->uses - p2->uses;
}

/* Choose the order to consider regs for use as reload registers
   based on how much trouble would be caused by spilling one.
   Store them in order of decreasing preference in potential_reload_regs.  */

static void
order_regs_for_reload ()
{
  register int i;
  register int o = 0;
  int large = 0;

  struct hard_reg_n_uses hard_reg_n_uses[FIRST_PSEUDO_REGISTER];

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    potential_reload_regs[i] = -1;

  /* Count number of uses of each hard reg by pseudo regs allocated to it
     and then order them by decreasing use.  */

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    {
      hard_reg_n_uses[i].uses = 0;
      hard_reg_n_uses[i].regno = i;
    }

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    {
      if (reg_renumber[i] >= 0)
	hard_reg_n_uses[reg_renumber[i]].uses += reg_n_refs[i];
      large += reg_n_refs[i];
    }

  /* Now fixed registers (which cannot safely be used for reloading)
     get a very high use count so they will be considered least desirable.
     Likewise registers used explicitly in the rtl code.  */

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    if (fixed_regs[i] || regs_explicitly_used[i])
      hard_reg_n_uses[i].uses = large;
  hard_reg_n_uses[FRAME_POINTER_REGNUM].uses = large;

  qsort (hard_reg_n_uses, FIRST_PSEUDO_REGISTER,
	 sizeof hard_reg_n_uses[0], hard_reg_use_compare);

  /* Prefer registers not so far used, for use in temporary loading.
     Among them, prefer registers not preserved by calls.  */

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    if (regs_ever_live[i] == 0 && call_used_regs[i]
	&& ! fixed_regs[i])
      potential_reload_regs[o++] = i;

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    if (regs_ever_live[i] == 0 && ! call_used_regs[i]
	&& i != FRAME_POINTER_REGNUM)
      potential_reload_regs[o++] = i;

  /* Now add the regs that are already used,
     preferring those used less often.  */

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    if (regs_ever_live[hard_reg_n_uses[i].regno] != 0)
      potential_reload_regs[o++] = hard_reg_n_uses[i].regno;

#if 0
  /* For regs that are used, don't prefer those not preserved by calls
     because those are likely to contain high priority things
     that are live for short periods of time.  */

  for (i = FIRST_PSEUDO_REGISTER - 1; i >= 0; i--)
    if (regs_ever_live[i] != 0 && ! call_used_regs[i])
      potential_reload_regs[o++] = i;
#endif
}

/* Reload pseudo-registers into hard regs around each insn as needed.
   Additional register load insns are output before the insn that needs it
   and perhaps store insns after insns that modify the reloaded pseudo reg.

   reg_last_reload_reg and reg_reloaded_contents keep track of
   which pseudo-registers are already available in reload registers.
   We update these for the reloads that we perform,
   as the insns are scanned.  */

static void
reload_as_needed (first, live_known)
     rtx first;
     int live_known;
{
  register rtx insn;
  register int i;

  /* Often (MEM (REG n)) is still valid even if (REG n) is put on the stack.
     Set spill_indirect_ok if so.  */
  register rtx tem
    = gen_rtx (MEM, SImode,
	       gen_rtx (PLUS, Pmode,
			gen_rtx (REG, Pmode, FRAME_POINTER_REGNUM),
			gen_rtx (CONST_INT, VOIDmode, 4)));

  spill_indirect_ok = memory_address_p (QImode, tem);

  bzero (spill_reg_rtx, sizeof spill_reg_rtx);
  reg_last_reload_reg = (rtx *) alloca (max_regno * sizeof (rtx));
  bzero (reg_last_reload_reg, max_regno * sizeof (rtx));
  for (i = 0; i < n_spills; i++)
    reg_reloaded_contents[i] = -1;

  for (insn = first; insn;)
    {
      register rtx next = NEXT_INSN (insn);
      if (GET_CODE (insn) == INSN || GET_CODE (insn) == JUMP_INSN
	  || GET_CODE (insn) == CALL_INSN)
	{
	  if (GET_MODE (insn) == VOIDmode)
	    n_reloads = 0;
	  /* First find the pseudo regs that must be reloaded for this insn.
	     This info is returned in the tables reload_... (see reload.h).
	     Also modify the body of INSN by substituting RELOAD
	     rtx's for those pseudo regs.  */
	  else
	    find_reloads (insn, 1, spill_indirect_ok, live_known, spill_reg_order);

	  if (n_reloads > 0)
	    {
	      /* Now compute which reload regs to reload them into.  Perhaps
		 reusing reload regs from previous insns, or else output
		 load insns to reload them.  Maybe output store insns too.
		 Record the choices of reload reg in reload_reg_rtx.  */
	      choose_reload_targets (insn, n_spills);
	      /* Substitute the chosen reload regs from reload_reg_rtx
		 into the insn's body (or perhaps into the bodies of other
		 load and store insn that we just made for reloading
		 and that we moved the structure into).  */
	      subst_reloads ();
	    }
	  /* Any previously reloaded spilled pseudo reg, stored in this insn,
	     is no longer validly lying around to save a future reload.
	     Note that this does not detect pseudos that were reloaded
	     for this insn in order to be stored in
	     (obeying register constraints).  That is correct; such reload
	     registers ARE still valid.  */
	  forget_old_reloads (PATTERN (insn));
	}
      /* A reload reg's contents are unknown after a label.  */
      if (GET_CODE (insn) == CODE_LABEL)
	for (i = 0; i < n_spills; i++)
	  reg_reloaded_contents[i] = -1;

      /* Don't assume a reload reg is still good after a call insn
	 if it is a call-used reg.  */
      if (GET_CODE (insn) == CODE_LABEL || GET_CODE (insn) == CALL_INSN)
	for (i = 0; i < n_spills; i++)
	  if (call_used_regs[spill_regs[i]])
	    reg_reloaded_contents[i] = -1;

      /* In case registers overlap, allow certain insns to invalidate
	 particular hard registers.  */

#ifdef INSN_CLOBBERS_REGNO_P
      for (i = 0 ; i < n_spills ; i++)
	if (INSN_CLOBBERS_REGNO_P (insn, spill_regs[i]))
	  reg_reloaded_contents[i] = -1;
#endif

      insn = next;
    }
}

/* If we see a pseudo-reg being stored into,
   don't try to reuse an old reload reg
   which previously contained a copy of it.  */

static void
forget_old_reloads (x)
     rtx x;
{
  if (GET_CODE (x) == SET && GET_CODE (SET_DEST (x)) == REG)
    {
      register int regno = REGNO (SET_DEST (x));
      int nr;

      if (regno >= FIRST_PSEUDO_REGISTER)
	nr = 1;
      else
	{
	  int i;
	  nr = HARD_REGNO_NREGS (regno, GET_MODE (SET_DEST (x)));
	  /* Storing into a spilled-reg invalidates its contents.
	     This can happen if a block-local pseudo is allocated to that reg
	     and it wasn't spilled because this block's total need is 0.
	     Then some insn might have an optional reload and use this reg.  */
	  for (i = 0; i < nr; i++)
	    if (spill_reg_order[regno + i] >= 0)
	      reg_reloaded_contents[spill_reg_order[regno + i]] = -1;
	}
      
      while (nr-- > 0) reg_last_reload_reg[regno + nr] = 0;
    }
  else if (GET_CODE (x) == PARALLEL)
    {
      register int i;
      for (i = 0; i < XVECLEN (x, 0); i++)
	{
	  register rtx y = XVECEXP (x, 0, i);
	  if (GET_CODE (y) == SET && GET_CODE (SET_DEST (y)) == REG)
	    forget_old_reloads (y);
	}
    }
}

/* Comparison function for qsort to decide which of two reloads
   should be handled first.  *P1 and *P2 are the reload numbers.  */

static int
reload_reg_class_lower (p1, p2)
     short *p1, *p2;
{
  register int r1 = *p1, r2 = *p2;
  register int t;
  register enum machine_mode mode1, mode2;
  
  /* Consider required reloads before optional ones.  */
  t = reload_optional[r1] - reload_optional[r2];
  if (t != 0)
    return t;
  /* Consider all multi-reg groups first.
     This is safe because `reload' fills all group-need before
     filling all non-group need.  */
  mode1 = (reload_inmode[r1] == VOIDmode ? reload_outmode[r1] : reload_inmode[r1]);
  mode2 = (reload_inmode[r2] == VOIDmode ? reload_outmode[r2] : reload_inmode[r2]);
  t = (CLASS_MAX_NREGS (reload_reg_class[r2], mode2)
       - CLASS_MAX_NREGS (reload_reg_class[r1], mode1));
  if (t != 0)
    return t;
  /* Consider reloads in order of increasing reg-class number.  */
  t = (int) reload_reg_class[r1] - (int) reload_reg_class[r2];
  return t;
}

/* Assign hard reg targets for the pseudo-registers we must reload
   into hard regs for this insn.
   Also output the instructions to copy them in and out of the hard regs.

   For machines with register classes, we are responsible for
   finding a reload reg in the proper class.  */

static void
choose_reload_targets (insn)
     rtx insn;
{
  register int j;
  char reload_reg_in_use[FIRST_PSEUDO_REGISTER];
  short reload_order[FIRST_PSEUDO_REGISTER];
  char reload_inherited[FIRST_PSEUDO_REGISTER];
  /* Elt N nonzero if reg_last_reload_reg[N] has been set in this insn
     for an output reload that stores into reg N.  */
  char *reg_has_output_reload;
  int have_groups = 0;

  /* For each reload, the index in spill_regs of the spill register used,
     or -1 if we did not need one of the spill registers for this reload.  */
  int reload_spill_index[FIRST_PSEUDO_REGISTER];

  bzero (reload_inherited, FIRST_PSEUDO_REGISTER);
  bzero (reload_reg_in_use, FIRST_PSEUDO_REGISTER);

  reg_has_output_reload = (char *) alloca (max_regno);
  bzero (reg_has_output_reload, max_regno);

  /* In order to be certain of getting the registers we need,
     we must sort the reloads into order of increasing register class.
     Then our grabbing of reload registers will parallel the process
     that provided the reload registers.  */

  /* Also note whether any of the reloads wants a consecutive group of regs.
     When that happens, we must when processing the non-group reloads
     avoid (when possible) using a reload reg that would break up a group.  */

  /* This used to look for an existing reloaded home for all
     of the reloads, and only then perform any new reloads.
     But that could lose if the reloads were done out of reg-class order
     because a later reload with a looser constraint might have an old
     home in a register needed by an earlier reload with a tighter constraint.
     It would be possible with even hairier code to detect such cases
     and handle them, but it doesn't seem worth while yet.  */

  for (j = 0; j < n_reloads; j++)
    {
      enum machine_mode mode;
      reload_order[j] = j;
      reload_spill_index[j] = -1;
      mode = (reload_inmode[j] == VOIDmode ? reload_outmode[j] : reload_inmode[j]);
      if (CLASS_MAX_NREGS (reload_reg_class[j], mode) > 1)
	have_groups = 1;
    }

  if (n_reloads > 1)
    qsort (reload_order, n_reloads, sizeof (short), reload_reg_class_lower);

  for (j = 0; j < n_reloads; j++)
    {
      register int r = reload_order[j];
      register int i;
      register rtx new;
      enum machine_mode reload_mode = reload_inmode[r];

      if (GET_MODE_SIZE (reload_outmode[r]) > GET_MODE_SIZE (reload_mode))
	reload_mode = reload_outmode[r];
      if (reload_strict_low[r])
	reload_mode = GET_MODE (SUBREG_REG (reload_out[r]));

      /* Ignore reloads that got marked inoperative.  */
      if (reload_out[r] == 0 && reload_in[r] == 0)
	continue;

      /* No need to find a reload-register if find_reloads chose one.  */

      if (reload_reg_rtx[r] != 0)
	{
#if 0
	  /* But do see if the chosen reload-reg already contains
	     a copy of the desired value.  */
	  if (reload_in[r] != 0)
	    {
	      register rtx equiv
		= find_equiv_reg (reload_in[r], insn, 0,
				  REGNO (reload_reg_rtx[r]), 0, 0,
				  reload_mode);
	      if (equiv != 0)
		reload_inherited[r] = 1;
	    }
#endif
	  continue;
	}

      /* First see if this pseudo is already available as reloaded
	 for a previous insn.
	 This feature is disabled for multi-register groups
	 because we haven't yet any way to tell whether the entire
	 value is properly preserved.
	 It is also disabled when there are other reloads for mult-register
	 groups, lest the inherited reload reg break up a needed group.  */

      {
	register int regno = -1;

	if (reload_in[r] == 0)
	  ;
	else if (GET_CODE (reload_in[r]) == REG)
	  regno = REGNO (reload_in[r]);
#if 0
	/* This won't work, since REGNO can be a pseudo reg number.
	   Also, it takes much more hair to keep track of all the things
	   that can invalidate an inherited reload of part of a pseudoreg.  */
	else if (GET_CODE (reload_in[r]) == SUBREG
		 && GET_CODE (SUBREG_REG (reload_in[r])) == REG)
	  regno = REGNO (SUBREG_REG (reload_in[r])) + SUBREG_WORD (reload_in[r]);
#endif

	if (regno >= 0
	    && GET_MODE_SIZE (reload_mode) <= UNITS_PER_WORD
	    && reg_last_reload_reg[regno] != 0
	    && ! have_groups)
	  {
	    i = spill_reg_order[REGNO (reg_last_reload_reg[regno])];

	    if (reg_reloaded_contents[i] == regno
		&& TEST_HARD_REG_BIT (reg_class_contents[(int) reload_reg_class[r]],
				      spill_regs[i])
		&& ! reload_reg_in_use[spill_regs[i]])
	      {
		/* Mark the reload register as in use for this insn.  */
		reload_reg_rtx[r] = reg_last_reload_reg[regno];
		reload_reg_in_use[spill_regs[i]] = 1;
		reload_inherited[r] = 1;
		reload_spill_index[r] = i;
	      }
	  }
      }

      /* If this is not a pseudo, here's a different way to see
	 if it is already lying around.  */
      if (reload_in[r] != 0
	  && reload_out[r] == 0
	  && (CONSTANT_P (reload_in[r])
	      || GET_CODE (reload_in[r]) == PLUS
	      || GET_CODE (reload_in[r]) == MEM)
	  && ! have_groups)
	{
	  register rtx equiv
	    = find_equiv_reg (reload_in[r], insn, reload_reg_class[r],
			      -1, (short *)1, 0, reload_mode);
	  /* If we found an equivalent reg, say no code need be generated
	     to load it, and use it as our reload reg.  */
	  if (equiv != 0
	      && REGNO (equiv) != FRAME_POINTER_REGNUM)
	    {
	      reload_reg_rtx[r] = equiv;
	      reload_inherited[r] = 1;
	      /* If it is a spill reg,
		 mark the spill reg as in use for this insn.  */
	      i = spill_reg_order[REGNO (equiv)];
	      if (i >= 0)
		{
		  int nr = HARD_REGNO_NREGS (spill_regs[i], reload_mode);
		  while (nr > 0)
		    reload_reg_in_use[REGNO (equiv) + --nr] = 1;
		}
	    }
	}

      /* If it isn't lying around, and isn't optional,
	 find a place to reload it into.  */
      if (reload_reg_rtx[r] != 0 || reload_optional[r] != 0)
	continue;

      /* Value not lying around; find a register to reload it into.
	 Here I is not a regno, it is an index into spill_regs.  */
      i = n_spills;

#if 0
      /* The following is no longer needed now that all multi-register
	 (group) reloads are processed before all solitary register reloads
	 (due to changes in `reg_class_lower_p' and `reload'.  */
      /* The following also fails to test HARD_REGNO_MODE_OK appropriately,
	 which was hard to fix because we don't know the mode that the
	 group might have that would want this register.  */

      /* If we want just one reg, and other reloads want groups,
	 first try to find a reg that can't be part of a group.  */
      if (have_groups
	  && CLASS_MAX_NREGS (reload_reg_class[r], reload_mode) == 1)
	for (i = 0; i < n_spills; i++)
	  {
	    int regno = spill_regs[i];
	    int class = (int) reload_reg_class[r];
	    if (reload_reg_in_use[regno] == 0
		&& TEST_HARD_REG_BIT (reg_class_contents[class],
				      regno)
		&& !(regno + 1 < FIRST_PSEUDO_REGISTER
		     && spill_reg_order[regno + 1] >= 0
		     && reload_reg_in_use[regno + 1] == 0
		     && TEST_HARD_REG_BIT (reg_class_contents[class],
					   regno + 1))
		&& !(regno > 0
		     && spill_reg_order[regno - 1] >= 0
		     && reload_reg_in_use[regno - 1] == 0
		     && TEST_HARD_REG_BIT (reg_class_contents[class],
					   regno - 1)))
	      break;
	  }

      /* If that didn't work, try to find a register that has only one
	 neighbor that could make a group with it.  That way, if the
	 available registers are three consecutive ones, we avoid taking
	 the middle one (which would leave us with no possible groups).  */

      if (have_groups
	  && CLASS_MAX_NREGS (reload_reg_class[r], reload_mode) == 1
	  && i == n_spills)
	for (i = 0; i < n_spills; i++)
	  {
	    int regno = spill_regs[i];
	    int class = (int) reload_reg_class[r];
	    if (reload_reg_in_use[regno] == 0
		&& TEST_HARD_REG_BIT (reg_class_contents[class],
				      regno)
		&& (!(regno + 1 < FIRST_PSEUDO_REGISTER
		      && spill_reg_order[regno + 1] >= 0
		      && reload_reg_in_use[regno + 1] == 0
		      && TEST_HARD_REG_BIT (reg_class_contents[class],
					    regno + 1))
		    || !(regno > 0
			 && spill_reg_order[regno - 1] >= 0
			 && reload_reg_in_use[regno - 1] == 0
			 && TEST_HARD_REG_BIT (reg_class_contents[class],
					       regno - 1))))
	      break;
	  }
#endif

      /* Now, if we want a single register and haven't yet found one,
	 take any reg in the right class and not in use.
	 If we want a consecutive group, here is where we look for it.  */
      if (i == n_spills)
	for (i = 0; i < n_spills; i++)
	  {
	    int class = (int) reload_reg_class[r];
	    if (reload_reg_in_use[spill_regs[i]] == 0
		&& TEST_HARD_REG_BIT (reg_class_contents[class],
				      spill_regs[i]))
	      {
		int nr = HARD_REGNO_NREGS (spill_regs[i], reload_mode);
		/* If we need only one reg, we have already won.  */
		if (nr == 1)
		  break;
		/* Otherwise check that as many consecutive regs as we need
		   are available here.  */
		if (HARD_REGNO_MODE_OK (spill_regs[i], reload_mode))
		  while (nr > 1)
		    {
		      if (!(TEST_HARD_REG_BIT (reg_class_contents[class],
					       spill_regs[i] + nr - 1)
			    && spill_reg_order[spill_regs[i] + nr - 1] >= 0
			    && reload_reg_in_use[spill_regs[i] + nr - 1] == 0))
			break;
		      nr--;
		    }
		if (nr == 1)
		  break;
	      }
	  }

      /* We should have found a spill register by now.  */
      if (i == n_spills)
	abort ();

      /* Mark as in use for this insn the reload regs we use for this.  */
      {
	int nr = HARD_REGNO_NREGS (spill_regs[i], reload_mode);
	while (nr > 0)
	  reload_reg_in_use[spill_regs[i] + --nr] = 1;
      }

      new = spill_reg_rtx[i];

      if (new == 0 || GET_MODE (new) != reload_mode)
	spill_reg_rtx[i] = new = gen_rtx (REG, reload_mode, spill_regs[i]);

      reload_reg_rtx[r] = new;
      reload_spill_index[r] = i;
      reg_reloaded_contents[i] = -1;

      /* Detect when the reload reg can't hold the reload mode.  */
      if (! HARD_REGNO_MODE_OK (REGNO (reload_reg_rtx[r]), reload_mode))
	{
	  if (! asm_noperands (PATTERN (insn)))
	    /* It's the compiler's fault.  */
	    abort ();
	  /* It's the user's fault; the operand's mode and constraint
	     don't match.  Disable this reload so we don't crash in final.
	     Maybe we should print an error message too??  */
	  reload_in[r] = 0;
	  reload_out[r] = 0;
	  reload_reg_rtx[r] = 0;
	  reload_optional[r] = 1;
	}
    }

  /* For all the spill regs newly reloaded in this instruction,
     record what they were reloaded from, so subsequent instructions
     can inherit the reloads.  */

  for (j = 0; j < n_reloads; j++)
    {
      register int r = reload_order[j];
      register int i = reload_spill_index[r];

      /* I is nonneg if this reload used one of the spill regs.
	 If reload_reg_rtx[r] is 0, this is an optional reload
	 that we opted to ignore.  */
      if (i >= 0 && reload_reg_rtx[r] != 0)
	{
	  /* Maybe the spill reg contains a copy of reload_out.  */
	  if (reload_out[r] != 0 && GET_CODE (reload_out[r]) == REG)
	    {
	      register int nregno = REGNO (reload_out[r]);
	      reg_last_reload_reg[nregno] = reload_reg_rtx[r];
	      reg_reloaded_contents[i] = nregno;
	      reg_has_output_reload[nregno] = 1;
	    }
	  /* Maybe the spill reg contains a copy of reload_in.  */
	  else if (reload_out[r] == 0 && GET_CODE (reload_in[r]) == REG)
	    {
	      register int nregno = REGNO (reload_in[r]);
	      /* If there are two separate reloads (one in and one out)
		 for the same (hard or pseudo) reg, set reg_last_reload_reg
		 based on the output reload.  */
	      if (!reg_has_output_reload[nregno])
		{
		  reg_last_reload_reg[nregno] = reload_reg_rtx[r];
		  reg_reloaded_contents[i] = nregno;
		}
	    }
	  /* Otherwise, the spill reg doesn't contain a copy of any reg.
	     Clear out its records, lest it be taken for a copy
	     of reload_in when that is no longer true.  */
	  else
	    reg_reloaded_contents[i] = -1;
	}
    }

  /* Now output the instructions to copy the data into and out of the
     reload registers.  Do these in the order that the reloads were reported,
     since reloads of base and index registers precede reloads of operands
     and the operands may need the base and index registers reloaded.  */

  for (j = 0; j < n_reloads; j++)
    {
      register rtx old;
      rtx store_insn;

      old = reload_in[j];
      if (old != 0 && ! reload_inherited[j]
	  && reload_reg_rtx[j] != old
	  && reload_reg_rtx[j] != 0)
	{
	  register rtx reloadreg = reload_reg_rtx[j];
	  rtx oldequiv = 0;
	  enum machine_mode mode;

	  /* Strip off of OLD any size-increasing SUBREGs such as
	     (SUBREG:SI foo:QI 0).  */

	  while (GET_CODE (old) == SUBREG && SUBREG_WORD (old) == 0
		 && (GET_MODE_SIZE (GET_MODE (old))
		     > GET_MODE_SIZE (GET_MODE (SUBREG_REG (old)))))
	    old = SUBREG_REG (old);

	  /* Determine the mode to reload in.
	     This is very tricky because we have three to choose from.
	     There is the mode the insn operand wants (reload_inmode[J]).
	     There is the mode of the reload register RELOADREG.
	     There is the intrinsic mode of the operand, revealed now
	     in OLD because we have stripped SUBREGs.
	     It turns out that RELOADREG's mode is irrelevant:
	     we can change that arbitrarily.

	     Neither of the other two is always right.  For example, consider
	     (SUBREG:SI foo:QI)) appearing as an operand that must be SImode;
	     then suppose foo is in memory.  This must be loaded in QImode
	     because we cannot fetch a byte as a word.  In this case OLD's
	     mode is correct.

	     Then consider a one-word union which has SImode and one of its
	     members is a float, being fetched as (SUBREG:SF union:SI).
	     We must fetch that as SFmode because we could be loading into
	     a float-only register.  In this case OLD's mode is also correct.

	     Consider an immediate integer: it has VOIDmode.  Here we need
	     to get a mode from something else.

	     In some cases, there is a fourth mode, the operand's
	     containing mode.  If the insn specifies a containing mode for
	     this operand, it overrides all others.

	     I am not sure whether the algorithm here is always right,
	     but it does the right things in those cases.  */

	  mode = GET_MODE (old);
	  if (mode == VOIDmode)
	    mode = reload_inmode[j];
	  if (reload_strict_low[j])
	    mode = GET_MODE (SUBREG_REG (reload_in[j]));

	  /* If reloading from memory, see if there is a register
	     that already holds the same value.  If so, reload from there.
	     We can pass 0 as the reload_reg_p argument because
	     any other reload has either already been emitted,
	     in which case find_equiv_reg will see the reload-insn,
	     or has yet to be emitted, in which case it doesn't matter
	     because we will use this equiv reg right away.  */

	  if (GET_CODE (old) == MEM
	      || (GET_CODE (old) == REG
		  && REGNO (old) >= FIRST_PSEUDO_REGISTER
		  && reg_renumber[REGNO (old)] < 0))
	    oldequiv = find_equiv_reg (old, insn, GENERAL_REGS,
				       -1, 0, 0, mode);

	  if (oldequiv == 0)
	    oldequiv = old;

	  /* Encapsulate both RELOADREG and OLDEQUIV into that mode,
	     then load RELOADREG from OLDEQUIV.  */

	  if (GET_MODE (reloadreg) != mode)
	    reloadreg = gen_rtx (SUBREG, mode, reloadreg, 0);
	  if (GET_MODE (oldequiv) != VOIDmode
	      && mode != GET_MODE (oldequiv))
	    oldequiv = gen_rtx (SUBREG, mode, oldequiv, 0);

	  /* If we are reloading a pseudo-register that was set by the previous
	     insn, see if we can get rid of that pseudo-register entirely
	     by redirecting the previous insn into our reload register.  */

	  if (optimize && GET_CODE (old) == REG
	      && REGNO (old) >= FIRST_PSEUDO_REGISTER
	      && PREV_INSN (insn) && GET_CODE (PREV_INSN (insn)) == INSN
	      && GET_CODE (PATTERN (PREV_INSN (insn))) == SET
	      && SET_DEST (PATTERN (PREV_INSN (insn))) == old
	      && dead_or_set_p (insn, old)
	      && reg_n_deaths[REGNO (old)] == 1
	      && reg_n_sets[REGNO (old)] == 1)
	    {
	      /* For the debugging info,
		 say the pseudo lives in this reload reg.  */
	      reg_renumber[REGNO (old)] = REGNO (reload_reg_rtx[j]);
	      alter_reg (REGNO (old));
	      /* Store into the reload register instead of the pseudo.  */
	      SET_DEST (PATTERN (PREV_INSN (insn))) = reloadreg;
	    }
	  else
	    /* We can't do that, so output an insn to load RELOADREG.  */
	    emit_insn_before (gen_move_insn (reloadreg, oldequiv), insn);

	  /* For some registers it is important to keep the REG_DEATH
	     notes accurate for the final pass.
	     If we are inheriting an old output-reload out of such a reg,
	     the reg no longer dies there, so remove the death note.  */
	  
#ifdef PRESERVE_DEATH_INFO_REGNO_P
	  if (PRESERVE_DEATH_INFO_REGNO_P (REGNO (reloadreg)))
	    {
	      int was_dead = 0;
	      if (REG_P (oldequiv)
		  && regno_dead_p (REGNO (oldequiv), insn))
		{
		  was_dead = 1;
		  remove_death (REGNO (oldequiv), insn);
		}

	      /* Add a death note to this insn, for an input reload.  */

	      if (! dead_or_set_p (insn, reloadreg))
		REG_NOTES (insn)
		  = gen_rtx (EXPR_LIST, REG_DEAD,
			     reloadreg, REG_NOTES (insn));
	    }
#endif

	  /* If this reload wants reload_in[j] incremented by a constant,
	     output code to get this done before the insn reloaded for.  */

	  if (reload_inc[j] != 0)
	    {
	      /* If reload_in[j] is a register, assume we can
		 output an insn to increment it directly.  */
	      if (GET_CODE (old) == REG &&
		  (REGNO (old) < FIRST_PSEUDO_REGISTER
		   || reg_renumber[REGNO (old)] >= 0))
		emit_insn_before (gen_add2_insn (old,
						 gen_rtx (CONST_INT, VOIDmode,
							  reload_inc[j])),
				  insn);
	      else
		/* Else we must not assume we can increment reload_in[j]
		   (even though on many target machines we can);
		   increment the copy in the reload register,
		   save that back, then decrement the reload register
		   so it has its original contents.  */
		{
		  rtx oldreal = old;
		  /* OLDREAL is OLDEQUIV encapsulated in that mode,
		     in case we need to write back to it.
		     OLDEQUIV is good only for reading.  */
		  if (GET_MODE (old) != VOIDmode
		      && mode != GET_MODE (old))
		    oldreal = gen_rtx (SUBREG, mode, oldreal, 0);

		  emit_insn_before (gen_add2_insn (reloadreg,
						   gen_rtx (CONST_INT, VOIDmode,
							    reload_inc[j])),
				    insn);
		  emit_insn_before (gen_move_insn (oldreal, reloadreg), insn);
		  emit_insn_before (gen_sub2_insn (reloadreg,
						   gen_rtx (CONST_INT, VOIDmode,
							    reload_inc[j])),
				    insn);
		}
	    }
	}

      /* If we are reloading a register that was recently stored in with an
	 output-reload, see if we can prove there was
	 actually no need to store the old value in it.  */

      if (optimize && reload_inherited[j] && reload_spill_index[j] >= 0
	  && GET_CODE (reload_in[j]) == REG
	  && spill_reg_store[reload_spill_index[j]] != 0
	  && dead_or_set_p (insn, reload_in[j]))
	{
	  register rtx i1;
	  /* If the pseudo-reg we are reloading is no longer referenced
	     anywhere between the store into it and here,
	     and no jumps or labels intervene, then the value can get
	     here through the reload reg alone.  */
	  for (i1 = NEXT_INSN (spill_reg_store[reload_spill_index[j]]);
	       i1 != insn; i1 = NEXT_INSN (i1))
	    {
	      if (GET_CODE (i1) == CODE_LABEL || GET_CODE (i1) == JUMP_INSN)
		break;
	      if ((GET_CODE (i1) == INSN || GET_CODE (i1) == CALL_INSN)
		  && reg_mentioned_p (reload_in[j], PATTERN (i1)))
		break;
	    }
	  if (i1 == insn)
	    {
	      /* If this insn will store in the pseudo again,
		 the previous store can be removed.  */
	      if (reload_out[j] == reload_in[j])
		delete_insn (spill_reg_store[reload_spill_index[j]]);

	      /* See if the pseudo reg has been completely replaced
		 with reload regs.  If so, delete the store insn
		 and forget we had a stack slot for the pseudo.  */
	      if (reg_n_deaths[REGNO (reload_in[j])] == 1
		  && reg_basic_block[REGNO (reload_in[j])] >= 0)
		{
		  /* We know that it was used only between here
		     and the beginning of the current basic block.
		     Search that range; see if any ref remains.  */
		  for (i1 = PREV_INSN (insn); i1; i1 = PREV_INSN (i1))
		    {
		      if (GET_CODE (i1) == CODE_LABEL
			  || GET_CODE (i1) == JUMP_INSN)
			break;
		      if ((GET_CODE (i1) == INSN || GET_CODE (i1) == CALL_INSN)
			  && reg_mentioned_p (reload_in[j], PATTERN (i1)))
			goto still_used;
		    }
		  /* For the debugging info,
		     say the pseudo lives in this reload reg.  */
		  reg_renumber[REGNO (old)] = REGNO (reload_reg_rtx[j]);
		  alter_reg (REGNO (old));
		  delete_insn (spill_reg_store[reload_spill_index[j]]);
		still_used: ;
		}
	    }
	}

      /* Input-reloading is done.  Now do output-reloading,
	 storing the value from the reload-register after the main insn
	 if reload_out[j] is nonzero.  */
      old = reload_out[j];
      if (old != 0
	  && reload_reg_rtx[j] != old
	  && reload_reg_rtx[j] != 0)
	{
	  register rtx reloadreg = reload_reg_rtx[j];
	  enum machine_mode mode;

	  /* Strip off of OLD any size-increasing SUBREGs such as
	     (SUBREG:SI foo:QI 0).  */

	  while (GET_CODE (old) == SUBREG && SUBREG_WORD (old) == 0
		 && (GET_MODE_SIZE (GET_MODE (old))
		     > GET_MODE_SIZE (GET_MODE (SUBREG_REG (old)))))
	    old = SUBREG_REG (old);

	  /* Determine the mode to reload in.
	     See comments above (for input reloading).  */

	  mode = GET_MODE (old);
	  if (mode == VOIDmode)
	    abort ();		/* Should never happen for an output.  */
#if 0
	    mode = reload_inmode[j];
#endif
	  if (reload_strict_low[j])
	    mode = GET_MODE (SUBREG_REG (reload_out[j]));

	  /* Encapsulate both RELOADREG and OLD into that mode,
	     then load RELOADREG from OLD.  */
	  if (GET_MODE (reloadreg) != mode)
	    reloadreg = gen_rtx (SUBREG, mode, reloadreg, 0);
	  if (GET_MODE (old) != VOIDmode
	      && mode != GET_MODE (old))
	    old = gen_rtx (SUBREG, mode, old, 0);
	  store_insn = emit_insn_after (gen_move_insn (old, reloadreg), insn);
	  /* If final will look at death notes for this reg,
	     put one on each output-reload insn.  */
#ifdef PRESERVE_DEATH_INFO_REGNO_P
	  if (PRESERVE_DEATH_INFO_REGNO_P (REGNO (reloadreg)))
	    REG_NOTES (store_insn)
		= gen_rtx (EXPR_LIST, REG_DEAD,
			   reloadreg, REG_NOTES (store_insn));
#endif
	}
      else store_insn = 0;

      if (reload_spill_index[j] >= 0)
	spill_reg_store[reload_spill_index[j]] = store_insn;
    }
}
