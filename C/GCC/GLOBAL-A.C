/* Allocate registers for pseudo-registers that span basic blocks.
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


#include <stdio.h>
#include "config.h"
#include "rtl.h"
#include "flags.h"
#include "basic-block.h"
#include "hard-reg-set.h"
#include "regs.h"
#include "insn-config.h"

/* This pass of the compiler performs global register allocation.
   It assigns hard register numbers to all the pseudo registers
   that were not handled in local_alloc.  Assignments are recorded
   in the vector reg_renumber, not by changing the rtl code.
   (Such changes are made by final).  The entry point is
   the function global_alloc.

   After allocation is complete, the reload pass is run as a subroutine
   of this pass, so that when a pseudo reg loses its hard reg due to
   spilling it is possible to make a second attempt to find a hard
   reg for it.  The reload pass is independent in other respects
   and it is run even when stupid register allocation is in use.

   1. count the pseudo-registers still needing allocation
   and assign allocation-numbers (allocnos) to them.
   Set up tables reg_allocno and allocno_reg to map 
   reg numbers to allocnos and vice versa.
   max_allocno gets the number of allocnos in use.

   2. Allocate a max_allocno by max_allocno conflict bit matrix and clear it.
   Allocate a max_allocno by FIRST_PSEUDO_REGISTER conflict matrix
   for conflicts between allocnos and explicit hard register use
   (which includes use of pseudo-registers allocated by local_alloc).

   3. for each basic block
    walk forward through the block, recording which
    unallocated registers and which hardware registers are live.
    Build the conflict matrix between the unallocated registers
    and another of unallocated registers versus hardware registers.
    Someday also record the preferred hardware registers
    for each unallocated one.

   4. Sort a table of the allocnos into order of
   desirability of the variables.

   5. Allocate the variables in that order; each if possible into
   an preferred register, else into another register.  */

/* Number of pseudo-registers still requiring allocation
   (not allocated by local_allocate).  */

static int max_allocno;

/* Indexed by (pseudo) reg number, gives the allocno, or -1
   for pseudo registers already allocated by local_allocate.  */

static int *reg_allocno;

/* Indexed by allocno, gives the reg number.  */

static int *allocno_reg;

/* A vector of the integers from 0 to max_allocno-1,
   sorted in the order of first-to-be-allocated first.  */

static int *allocno_order;

/* Indexed by an allocno, gives the number of consecutive
   hard registers needed by that pseudo reg.  */

static int *allocno_size;

/* Indexed by allocno, gives number of preferred hard reg, or -1 if none.  */

static int *allocno_preferred_reg;

/* max_allocno by max_allocno array of bits,
   recording whether two allocno's conflict (can't go in the same
   hardware register).

   `conflicts' is not symmetric; a conflict between allocno's i and j
   is recorded either in element i,j or in element j,i.  */

static int *conflicts;

/* Number of ints require to hold max_allocno bits.
   This is the length of a row in `conflicts'.  */

static int allocno_row_words;

/* Two macros to test or store 1 in an element of `conflicts'.  */

#define CONFLICTP(I, J) \
 (conflicts[(I) * allocno_row_words + (J) / INT_BITS]	\
  & (1 << ((J) % INT_BITS)))

#define SET_CONFLICT(I, J) \
 (conflicts[(I) * allocno_row_words + (J) / INT_BITS]	\
  |= (1 << ((J) % INT_BITS)))

/* Set of hard regs currently live (during scan of all insns).  */

static HARD_REG_SET hard_regs_live;

/* Indexed by N, set of hard regs conflicting with allocno N.  */

static HARD_REG_SET *hard_reg_conflicts;

#if 0
/* Indexed by N, set of hard regs preferred by allocno N.
   This was intended to be used to make allocnos go into regs
   that they are loaded from, when possible, to reduce register shuffling.  */

static HARD_REG_SET *hard_reg_preferences;
#endif

/* Set of registers that global-alloc isn't supposed to use.  */

static HARD_REG_SET no_global_alloc_regs;

/* Test a bit in TABLE, a vector of HARD_REG_SETs,
   for vector element I, and hard register number J.  */

#define REGBITP(TABLE, I, J)     TEST_HARD_REG_BIT (TABLE[I], J)

/* Set to 1 a bit in a vector of HARD_REG_SETs.  Works like REGBITP.  */

#define SET_REGBIT(TABLE, I, J)  SET_HARD_REG_BIT (TABLE[I], J)

/* Bit mask for allocnos live at current point in the scan.  */

static int *allocnos_live;

#define INT_BITS HOST_BITS_PER_INT

/* Test, set or clear bit number I in allocnos_live,
   a bit vector indexed by allocno.  */

#define ALLOCNO_LIVE_P(I) \
  (allocnos_live[(I) / INT_BITS] & (1 << ((I) % INT_BITS)))

#define SET_ALLOCNO_LIVE(I) \
  (allocnos_live[(I) / INT_BITS] |= (1 << ((I) % INT_BITS)))

#define CLEAR_ALLOCNO_LIVE(I) \
  (allocnos_live[(I) / INT_BITS] &= ~(1 << ((I) % INT_BITS)))

static int allocno_compare ();
static void mark_reg_store ();
static void mark_reg_live_nc ();
static void mark_reg_death ();
static void dump_conflicts ();
static void find_reg ();
static void global_conflicts ();
static void record_conflicts ();


/* Tables describing and classifying the hardware registers.  */

/* Perform allocation of pseudo-registers not allocated by local_alloc.
   FILE is a file to output debugging information on,
   or zero if such output is not desired.  */

void
global_alloc (file)
     FILE *file;
{
  register int i;

  max_allocno = 0;

  /* A machine may have certain hard registers that
     are safe to use only within a basic block.  */

  CLEAR_HARD_REG_SET (no_global_alloc_regs);
#if 0
  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    if (OVERLAPPING_REGNO_P (i))
      SET_HARD_REG_BIT (no_global_alloc_regs, i);
#endif

  /* Establish mappings from register number to allocation number
     and vice versa.  In the process, count the allocnos.  */

  reg_allocno = (int *) alloca (max_regno * sizeof (int));

  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    reg_allocno[i] = -1;

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    /* Note that reg_live_length[i] < 0 indicates a "constant" reg
       that we are supposed to refrain from putting in a hard reg.
       -2 means do make an allocno but don't allocate it.  */
    if (reg_n_refs[i] != 0 && reg_renumber[i] < 0 && reg_live_length[i] != -1)
      {
	reg_allocno[i] = max_allocno++;
	if (reg_live_length[i] == 0)
	  abort ();
      }
    else
      reg_allocno[i] = -1;

  allocno_reg = (int *) alloca (max_allocno * sizeof (int));
  allocno_size = (int *) alloca (max_allocno * sizeof (int));
  allocno_preferred_reg = (int *) alloca (max_allocno * sizeof (int));
  bzero (allocno_size, max_allocno * sizeof (int));

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    if (reg_allocno[i] >= 0)
      {
	allocno_reg[reg_allocno[i]] = i;
	allocno_size[reg_allocno[i]] = PSEUDO_REGNO_SIZE (i);
	allocno_preferred_reg[reg_allocno[i]] = -1;
      }

  /* Allocate the space for the conflict tables.  */

  hard_reg_conflicts = (HARD_REG_SET *)
    alloca (max_allocno * sizeof (HARD_REG_SET));
  bzero (hard_reg_conflicts, max_allocno * sizeof (HARD_REG_SET));

#if 0
  hard_reg_preferences = (HARD_REG_SET *)
    alloca (max_allocno * sizeof (HARD_REG_SET));
  bzero (hard_reg_preferences, max_allocno * sizeof (HARD_REG_SET));
#endif

  allocno_row_words = (max_allocno + INT_BITS - 1) / INT_BITS;

  conflicts = (int *)
    alloca (max_allocno * allocno_row_words * sizeof (int));
  bzero (conflicts, max_allocno * allocno_row_words * sizeof (int));

  allocnos_live = (int *) alloca (allocno_row_words * sizeof (int));

  /* If there is work to be done (at least one reg to allocate),
     perform global conflict analysis and allocate the regs.  */

  if (max_allocno > 0)
    {
      /* Scan all the insns and compute the conflicts among allocnos
	 and between allocnos and hard regs.  */

      global_conflicts ();

      /* Determine the order to allocate the remaining pseudo registers.  */

      allocno_order = (int *) alloca (max_allocno * sizeof (int));
      for (i = 0; i < max_allocno; i++)
	allocno_order[i] = i;

      /* Default the size to 1, since allocno_compare uses it to divide by.  */

      for (i = 0; i < max_allocno; i++)
	if (allocno_size[i] == 0)
	  allocno_size[i] = 1;

      qsort (allocno_order, max_allocno, sizeof (int), allocno_compare);

      if (file)
	dump_conflicts (file);

      /* Try allocating them, one by one, in that order,
	 except for parameters marked with reg_live_length[regno] == -2.  */

      for (i = 0; i < max_allocno; i++)
	if (reg_live_length[allocno_reg[allocno_order[i]]] >= 0)
	  {
	    /* If we have a preferred hard register, try that first.  */
	    if (allocno_preferred_reg[allocno_order[i]] >= 0)
	      {
		find_reg (allocno_order[i], 0, 0,
			  allocno_preferred_reg[allocno_order[i]]);
		if (reg_renumber[allocno_reg[allocno_order[i]]] >= 0)
		  continue;
	      }
	    /* If we have more than one register class,
	       first try allocating in the class that is cheapest
	       for this pseudo-reg.  If that fails, try any reg.  */
	    if (N_REG_CLASSES > 1)
	      {
		find_reg (allocno_order[i], 0, 0, -1);
		if (reg_renumber[allocno_reg[allocno_order[i]]] >= 0)
		  continue;
	      }
	    if (!reg_preferred_or_nothing (allocno_reg[allocno_order[i]]))
	      find_reg (allocno_order[i], 0, 1, -1);
	  }
    }

  /* Do the reloads now while the allocno data still exist, so that we can
     try to assign new hard regs to any pseudo regs that are spilled.  */

  if (n_basic_blocks > 0)
    reload (basic_block_head[0], 1, file);
}

/* Sort predicate for ordering the allocnos.
   Returns -1 (1) if *v1 should be allocated before (after) *v2.  */

static int
allocno_compare (v1, v2)
     int *v1, *v2;
{
  register int r1 = allocno_reg[*v1];
  register int r2 = allocno_reg[*v2];
  register double v 
    = ((double) (floor_log2 (reg_n_refs[r1]) * reg_n_refs[r1])
       / (reg_live_length[r1] * allocno_size[*v1]))
      - ((double) (floor_log2 (reg_n_refs[r2]) * reg_n_refs[r2])
	 / (reg_live_length[r2] * allocno_size[*v2]));
  if (v < 0)
    return 1;
  if (v > 0)
    return -1;
  return 0;
}

/* Scan the rtl code and record all conflicts in the conflict matrices.  */

static void
global_conflicts ()
{
  register int b, i;
  register rtx insn;
  short *block_start_allocnos;

  block_start_allocnos = (short *) alloca (max_allocno * sizeof (short));

  for (b = 0; b < n_basic_blocks; b++)
    {
      bzero (allocnos_live, allocno_row_words * sizeof (int));

      /* Initialize table of registers currently live
	 to the state at the beginning of this basic block.
	 This also marks the conflicts among them.

	 For pseudo-regs, there is only one bit for each one
	 no matter how many hard regs it occupies.
	 This is ok; we know the size from PSEUDO_REGNO_SIZE.
	 For explicit hard regs, we cannot know the size that way
	 since one hard reg can be used with various sizes.
	 Therefore, we must require that all the hard regs
	 implicitly live as part of a multi-word hard reg
	 are explicitly marked in basic_block_live_at_start.  */

      {
	register int offset, bit;
	register regset old = basic_block_live_at_start[b];
	int ax = 0;

#ifdef HARD_REG_SET
	hard_regs_live = old[0];
#else
	COPY_HARD_REG_SET (hard_regs_live, old);
#endif
	for (offset = 0, i = 0; offset < regset_size; offset++)
	  if (old[offset] == 0)
	    i += HOST_BITS_PER_INT;
	  else
	    for (bit = 1; bit; bit <<= 1, i++)
	      {
		if (i >= max_regno)
		  break;
		if (old[offset] & bit)
		  {
		    register int a = reg_allocno[i];
		    if (a >= 0)
		      {
			SET_ALLOCNO_LIVE (a);
			block_start_allocnos[ax++] = a;
		      }
		    else if ((a = reg_renumber[i]) >= 0)
		      mark_reg_live_nc (a, PSEUDO_REGNO_MODE (i));
		  }
	      }

	/* Record that each allocno now live conflicts with each other
	   allocno now live, and with each hard reg now live.  */

	record_conflicts (block_start_allocnos, ax);
      }

      insn = basic_block_head[b];

      /* Scan the code of this basic block, noting which allocnos
	 and hard regs are born or die.  When one is born,
	 record a conflict with all others currently live.  */

      while (1)
	{
	  register RTX_CODE code = GET_CODE (insn);
	  register rtx link;
	  rtx regs_set[MAX_SETS_PER_INSN + MAX_CLOBBERS_PER_INSN];
	  int n_regs_set = 0;

	  if (code == INSN || code == CALL_INSN || code == JUMP_INSN)
	    {
	      /* Mark any registers dead after INSN as dead now.  */

	      for (link = REG_NOTES (insn); link; link = XEXP (link, 1))
		if (REG_NOTE_KIND (link) == REG_DEAD)
		  mark_reg_death (XEXP (link, 0));

	      /* Mark any registers set in INSN as live,
		 and mark them as conflicting with all other live regs.  */

	      if ((GET_CODE (PATTERN (insn)) == SET
		   || GET_CODE (PATTERN (insn)) == CLOBBER)
		  && GET_CODE (SET_DEST (PATTERN (insn))) == REG)
		{
		  register rtx z = SET_DEST (PATTERN (insn));
		  regs_set[n_regs_set++] = z;
		  mark_reg_store (z);
		}
	      if ((GET_CODE (PATTERN (insn)) == SET
		   || GET_CODE (PATTERN (insn)) == CLOBBER)
		  && GET_CODE (SET_DEST (PATTERN (insn))) == SUBREG)
		{
		  register rtx z = SUBREG_REG (SET_DEST (PATTERN (insn)));
		  if (GET_CODE (z) == REG)
		    {
		      regs_set[n_regs_set++] = z;
		      mark_reg_store (z);
		    }
		}
	      else if (GET_CODE (PATTERN (insn)) == PARALLEL)
		{
		  register rtx y = PATTERN (insn);
		  for (i = XVECLEN (y, 0) - 1;
		       i >= 0; i--)
		    if (GET_CODE (XVECEXP (y, 0, i)) == SET
			|| GET_CODE (XVECEXP (y, 0, i)) == CLOBBER)
		      {
			rtx z = SET_DEST (XVECEXP (y, 0, i));
			if (GET_CODE (z) == REG)
			  {
			    regs_set[n_regs_set++] = z;
			    mark_reg_store (z);
			  }
			if (GET_CODE (z) == SUBREG
			    && GET_CODE (SUBREG_REG (z)) == REG)
			  {
			    regs_set[n_regs_set++] = SUBREG_REG (z);
			    mark_reg_store (SUBREG_REG (z));
			  }
		      }
		}

	      /* Mark any registers both set and dead after INSN as dead.
		 This is not redundant!
		 A register may be set and killed in the same insn.
		 It is necessary to mark them as live, above, to get
		 the right conflicts within the insn.  */

	      while (n_regs_set > 0)
		if (find_regno_note (insn, REG_DEAD, REGNO (regs_set[--n_regs_set])))
		  mark_reg_death (regs_set[n_regs_set]);
		
	      /* Likewise for regs set by incrementation.  */

	      for (link = REG_NOTES (insn); link; link = XEXP (link, 1))
		if (REG_NOTE_KIND (link) == REG_INC
		    && find_regno_note (insn, REG_DEAD, REGNO (XEXP (link, 0))))
		  mark_reg_death (XEXP (link, 0));
	    }

	  if (insn == basic_block_end[b])
	    break;
	  insn = NEXT_INSN (insn);
	}
    }
}

/* Assign a hard register to ALLOCNO; look for one that is the beginning
   of a long enough stretch of hard regs none of which conflicts with ALLOCNO.
   If PREFREG is >= 0, try that hard reg first.

   If ALL_REGS_P is zero, consider only the preferred class of ALLOCNO's reg.
   Otherwise ignore that preferred class.

   If we find one, record it in reg_renumber.
   If not, do nothing.  */

static void
find_reg (allocno, losers, all_regs_p, prefreg)
     int allocno;
     register short *losers;
     int all_regs_p;
     int prefreg;
{
  register int i;
#ifdef HARD_REG_SET
  register		/* Declare it register if it's a scalar.  */
#endif
    HARD_REG_SET used;

  enum reg_class class 
    = all_regs_p ? GENERAL_REGS : reg_preferred_class (allocno_reg[allocno]);
  enum machine_mode mode = PSEUDO_REGNO_MODE (allocno_reg[allocno]);

  COPY_HARD_REG_SET (used,
		     (reg_crosses_call[allocno_reg[allocno]]
		      ? call_used_reg_set : fixed_reg_set));

  /* Some registers should not be allocated in global-alloc.  */
  IOR_HARD_REG_SET (used, no_global_alloc_regs);

  IOR_COMPL_HARD_REG_SET (used, reg_class_contents[(int) class]);
  IOR_HARD_REG_SET (used, hard_reg_conflicts[allocno]);
  if (frame_pointer_needed)
    SET_HARD_REG_BIT (used, FRAME_POINTER_REGNUM);

  /* If a preferred register was specified, try it first.  */

  i = -1;
  if (prefreg >= 0)
    if (! TEST_HARD_REG_BIT (used, prefreg)
	&& (losers == 0 || losers[prefreg] < 0)
	&& HARD_REGNO_MODE_OK (prefreg, mode))
      {
	register int j;
	register int lim = prefreg + HARD_REGNO_NREGS (prefreg, mode);
	for (j = prefreg + 1;
	     (j < lim
	      && ! TEST_HARD_REG_BIT (used, j)
	      && (losers == 0 || losers[j] < 0));
	     j++);
	if (j == lim)
	  i = prefreg;
      }

  /* Otherwise try each hard reg to see if it fits.  */

  if (i < 0)
    for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
      if (! TEST_HARD_REG_BIT (used, i)
	  && (losers == 0 || losers[i] < 0)
	  && HARD_REGNO_MODE_OK (i, mode))
	{
	  register int j;
	  register int lim = i + HARD_REGNO_NREGS (i, mode);
	  for (j = i + 1;
	       (j < lim
		&& ! TEST_HARD_REG_BIT (used, j)
		&& (losers == 0 || losers[j] < 0));
	       j++);
	  if (j == lim)
	    break;
	  i = j;			/* Skip starting points we know will lose */
	}

  /* Did we find a register?  */

  if (i < FIRST_PSEUDO_REGISTER)
    {
      register int lim, j;
      HARD_REG_SET this_reg;

      /* Yes.  Record it as the hard register of this pseudo-reg.  */
      reg_renumber[allocno_reg[allocno]] = i;
      /* For each other pseudo-reg conflicting with this one,
	 mark it as conflicting with the hard regs this one occupies.  */
      CLEAR_HARD_REG_SET (this_reg);
      lim = i + HARD_REGNO_NREGS (i, mode);
      for (j = i; j < lim; j++)
	SET_HARD_REG_BIT (this_reg, j);
      lim = allocno;
      for (j = 0; j < max_allocno; j++)
	if (CONFLICTP (lim, j) || CONFLICTP (j, lim))
	  {
	    IOR_HARD_REG_SET (hard_reg_conflicts[j], this_reg);
	  }
    }
}

/* Called from `reload' to look for a hard reg to put pseudo reg REGNO in.
   Perhaps it had previously seemed not worth a hard reg,
   or perhaps its old hard reg has been commandeered for reloads.
   FORBIDDEN_REGS is a vector that indicates certain hard regs
   that may not be used, even if they do not appear to be allocated.
   A nonnegative element means the corresponding hard reg is forbidden.
   If FORBIDDEN_REGS is zero, no regs are forbidden.  */

void
retry_global_alloc (regno, forbidden_regs)
     int regno;
     short *forbidden_regs;
{
  int allocno = reg_allocno[regno];
  if (allocno >= 0)
    {
      /* If we have more than one register class,
	 first try allocating in the class that is cheapest
	 for this pseudo-reg.  If that fails, try any reg.  */
      if (N_REG_CLASSES > 1)
	find_reg (allocno, forbidden_regs, 0, -1);
      if (reg_renumber[regno] < 0
	  && !reg_preferred_or_nothing (regno))
	find_reg (allocno, forbidden_regs, 1, -1);
    }
}

/* Called from reload pass to see if current function's pseudo regs
   require a frame pointer to be allocated and set up.

   Return 1 if so, 0 otherwise.
   We may alter the hard-reg allocation of the pseudo regs
   in order to make the frame pointer unnecessary.
   However, if the value is 1, nothing has been altered.

   Args grant access to some tables used in reload1.c.
   See there for info on them.  */

int
check_frame_pointer_required (reg_equiv_constant, reg_equiv_mem)
     rtx *reg_equiv_constant, *reg_equiv_mem;
{
  register int i;
  HARD_REG_SET *old_hard_reg_conflicts;
  short *old_reg_renumber;
  char old_regs_ever_live[FIRST_PSEUDO_REGISTER];

  /* If any pseudo reg has no hard reg and no equivalent,
     we must have a frame pointer.  */

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    if (reg_renumber[i] < 0 && reg_equiv_mem[i] == 0
	&& reg_equiv_constant[i] == 0 && reg_n_refs[i] > 0)
      return 1;

  /* If we might not need a frame pointer,
     try finding a hard reg for any pseudo that has a memory equivalent.
     That is because the memory equivalent probably refers to a frame
     pointer.  */

  old_reg_renumber = (short *) alloca (max_regno * sizeof (short));
  old_hard_reg_conflicts = (HARD_REG_SET *)
    alloca (max_allocno * sizeof (HARD_REG_SET));

  bcopy (reg_renumber, old_reg_renumber, max_regno * sizeof (short));
  bcopy (hard_reg_conflicts, old_hard_reg_conflicts,
	 max_allocno * sizeof (HARD_REG_SET));
  bcopy (regs_ever_live, old_regs_ever_live, sizeof regs_ever_live);

  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    if (reg_renumber[i] < 0 && reg_equiv_mem[i] != 0)
      {
	retry_global_alloc (i, 0);
	/* If we can't find a hard reg for ALL of them,
	   or if a previously unneeded hard reg is used that requires saving,
	   we fail: set all those pseudos back as they were.  */
	if (reg_renumber[i] < 0
	    || (! old_regs_ever_live[reg_renumber[i]]
		&& ! call_used_regs[reg_renumber[i]]))
	  {
	    bcopy (old_reg_renumber, reg_renumber,
		   max_regno * sizeof (short));
	    bcopy (old_hard_reg_conflicts, hard_reg_conflicts,
		   max_allocno * sizeof (HARD_REG_SET));
	    bcopy (old_regs_ever_live, regs_ever_live, sizeof regs_ever_live);
	    return 1;
	  }
	mark_home_live (i);
      }

  return 0;
}

/* Record a conflict between register REGNO
   and everything currently live.
   REGNO must not be a pseudo reg that was allocated
   by local_alloc; such numbers must be translated through
   reg_renumber before calling here.  */

static void
record_one_conflict (regno)
     int regno;
{
  register int j;

  if (regno < FIRST_PSEUDO_REGISTER)
    /* When a hard register becomes live,
       record conflicts with live pseudo regs.  */
    for (j = 0; j < max_allocno; j++)
      {
	if (ALLOCNO_LIVE_P (j))
	  SET_HARD_REG_BIT (hard_reg_conflicts[j], regno);
      }
  else
    /* When a pseudo-register becomes live,
       record conflicts first with hard regs,
       then with other pseudo regs.  */
    {
      register int ialloc = reg_allocno[regno];
      register int ialloc_prod = ialloc * allocno_row_words;
      IOR_HARD_REG_SET (hard_reg_conflicts[ialloc], hard_regs_live);
      for (j = allocno_row_words - 1; j >= 0; j--)
	conflicts[ialloc_prod + j] |= allocnos_live[j];
    }
}

/* Record all allocnos currently live as conflicting
   with each other and with all hard regs currently live.
   ALLOCNO_VEC is a vector of LEN allocnos, all allocnos that
   are currently live.  Their bits are also flagged in allocnos_live.  */

static void
record_conflicts (allocno_vec, len)
     register short *allocno_vec;
     register int len;
{
  register int allocno;
  register int j;
  register int ialloc_prod;

  while (--len >= 0)
    {
      allocno = allocno_vec[len];
      ialloc_prod = allocno * allocno_row_words;
      IOR_HARD_REG_SET (hard_reg_conflicts[allocno], hard_regs_live);
      for (j = allocno_row_words - 1; j >= 0; j--)
	conflicts[ialloc_prod + j] |= allocnos_live[j];
    }
}

/* Handle the case where REG is set by the insn being scanned,
   during the forward scan to accumulate conflicts.
   Store a 1 in regs_live or allocnos_live for this register, record how many
   consecutive hardware registers it actually needs,
   and record a conflict with all other registers already live.

   Note that even if REG does not remain alive after this insn,
   we must mark it here as live, to ensure a conflict between
   REG and any other regs set in this insn that really do live.
   This is because those other regs could be considered after this.  */

static void
mark_reg_store (reg)
     rtx reg;
{
  register int regno = REGNO (reg);

  if (reg_renumber[regno] >= 0)
    regno = reg_renumber[regno];

  /* Either this is one of the max_allocno pseudo regs not allocated,
     or it is or has a hardware reg.  First handle the pseudo-regs.  */
  if (regno >= FIRST_PSEUDO_REGISTER)
    {
      if (reg_allocno[regno] >= 0)
	{
	  SET_ALLOCNO_LIVE (reg_allocno[regno]);
	  record_one_conflict (regno);
	}
    }
  /* Handle hardware regs (and pseudos allocated to hard regs).  */
  else if (! fixed_regs[regno])
    {
      register int last = regno + HARD_REGNO_NREGS (regno, GET_MODE (reg));
      while (regno < last)
	{
	  record_one_conflict (regno);
	  SET_HARD_REG_BIT (hard_regs_live, regno);
	  regno++;
	}
    }
}

/* Mark REG as being dead (following the insn being scanned now).
   Store a 0 in regs_live or allocnos_live for this register.  */

static void
mark_reg_death (reg)
     rtx reg;
{
  register int regno = REGNO (reg);

  /* For pseudo reg, see if it has been assigned a hardware reg.  */
  if (reg_renumber[regno] >= 0)
    regno = reg_renumber[regno];

  /* Either this is one of the max_allocno pseudo regs not allocated,
     or it is a hardware reg.  First handle the pseudo-regs.  */
  if (regno >= FIRST_PSEUDO_REGISTER)
    {
      if (reg_allocno[regno] >= 0)
	CLEAR_ALLOCNO_LIVE (reg_allocno[regno]);
    }
  /* Handle hardware regs (and pseudos allocated to hard regs).  */
  else if (! fixed_regs[regno])
    {
      /* Pseudo regs already assigned hardware regs are treated
	 almost the same as explicit hardware regs.  */
      register int last = regno + HARD_REGNO_NREGS (regno, GET_MODE (reg));
      while (regno < last)
	{
	  CLEAR_HARD_REG_BIT (hard_regs_live, regno);
	  regno++;
	}
    }
}

/* Mark hard reg REGNO as currently live, assuming machine mode MODE
   for the value stored in it.  MODE determines how many consecutive
   registers are actually in use.  Do not record conflicts;
   it is assumed that the caller will do that.  */

static void
mark_reg_live_nc (regno, mode)
     register int regno;
     enum machine_mode mode;
{
  register int last = regno + HARD_REGNO_NREGS (regno, mode);
  while (regno < last)
    {
      SET_HARD_REG_BIT (hard_regs_live, regno);
      regno++;
    }
}

/* Print debugging trace information if -greg switch is given,
   showing the information on which the allocation decisions are based.  */

static void
dump_conflicts (file)
     FILE *file;
{
  register int i;
  fprintf (file, ";; %d regs to allocate:", max_allocno);
  for (i = 0; i < max_allocno; i++)
    {
      fprintf (file, " %d", allocno_reg[allocno_order[i]]);
      if (allocno_size[allocno_order[i]] != 1)
	fprintf (file, " (%d)", allocno_size[allocno_order[i]]);
    }
  fprintf (file, "\n");

  for (i = 0; i < max_allocno; i++)
    {
      register int j;
      fprintf (file, ";; %d conflicts:", allocno_reg[i]);
      for (j = 0; j < max_allocno; j++)
	if (CONFLICTP (i, j) || CONFLICTP (j, i))
	  fprintf (file, " %d", allocno_reg[j]);
      for (j = 0; j < FIRST_PSEUDO_REGISTER; j++)
	if (TEST_HARD_REG_BIT (hard_reg_conflicts[i], j))
	  fprintf (file, " %d", j);
      fprintf (file, "\n");
    }
  fprintf (file, "\n");
}

void
dump_global_regs (file)
     FILE *file;
{
  register int i;

  fprintf (file, ";; Register dispositions:");
  for (i = FIRST_PSEUDO_REGISTER; i < max_regno; i++)
    {
      if (reg_renumber[i] >= 0)
	fprintf (file, " %d in %d ", i, reg_renumber[i]);
    }

  fprintf (file, "\n\n;; Hard regs used: ");
  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    if (regs_ever_live[i])
      fprintf (file, " %d", i);
  fprintf (file, "\n\n");
}
