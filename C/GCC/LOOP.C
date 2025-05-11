/* Move constant computations out of loops.
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


/* This is the loop optimization pass of the compiler.
   It finds invariant computations within loops and moves them
   to the beginning of the loop.

   It also finds cases where
   a register is set within the loop by zero-extending a narrower value
   and changes these to zero the entire register once before the loop
   and merely copy the low part within the loop.

   Most of the complexity is in heuristics to decide when it is worth
   while to do these things.  */

/* ??? verify_loop would run faster if we made one table
   of the minimum and maximum luids from which each label is reached.
   Also, it would be faster if loop_store_addrs were a hash table.  */

#include "config.h"
#include "rtl.h"
#include "insn-config.h"
#include "regs.h"
#include "recog.h"
#include <stdio.h>

/* Vector mapping INSN_UIDs to luids.
   The luids are like uids but increase monononically always.
   We use them to see whether a jump comes from outside a given loop.  */

static short *uid_luid;

/* Get the luid of an insn.  */

#define INSN_LUID(INSN) (uid_luid[INSN_UID (INSN)])

/* 1 + largest uid of any insn.  */

static int max_uid;

/* 1 + luid of last insn.  */

static int max_luid;

/* Nonzero if somewhere in the current loop
   there is either a subroutine call,
   or a store into a memory address that is not fixed,
   or a store in a BLKmode memory operand,
   or too many different fixed addresses stored in
   to record them all in `loop_store_addrs'.

   In any of these cases, no memory location can be regarded
   as invariant.  */

static int unknown_address_altered;

/* Nonzero if somewhere in the current loop there is a store
   into a memory address that is not fixed but is known to be
   part of an aggregate.

   In this case, no memory reference in an aggregate may be
   considered invariant.  */

static int unknown_aggregate_altered;

/* Nonzero if somewhere in the current loop there is a store
   into a memory address other than a fixed address not in an aggregate.

   In this case, no memory reference in an aggregate at a varying address
   may be considered invariant.  */

static int fixed_aggregate_altered;

/* Nonzero if there is a subroutine call in the current loop.
   (unknown_address_altered is also nonzero in this case.)  */

static int loop_has_call;

/* Array of fixed memory addresses that are stored in this loop.
   If there are too many to fit here,
   we just turn on unknown_address_altered.  */

#define NUM_STORES 10
static rtx loop_store_addrs[NUM_STORES];
static int loop_store_widths[NUM_STORES];

/* Index of first available slot in above array.  */
static int loop_store_addrs_idx;

/* During the analysis of a loop, a chain of `struct movable's
   is made to record all the movable insns found.
   Then the entire chain can be scanned to decide which to move.  */

struct movable
{
  rtx insn;			/* A movable insn */
  int consec;			/* Number of consecutive following insns 
				   that must be moved with this one.  */
  int regno;			/* The register it sets */
  short lifetime;		/* lifetime of that register;
				   may be adjusted when matching movables
				   that load the same value are found.  */
  short times_used;		/* Number of times the register is used,
				   plus uses of related insns that could
				   be moved if this one is.  */
  unsigned int cond : 1;	/* 1 if only conditionally movable */
  unsigned int force : 1;	/* 1 means MUST move this insn */
  unsigned int global : 1;	/* 1 means reg is live outside this loop */
  unsigned int done : 1;	/* 1 inhibits further processing of this */
  unsigned int partial : 1;	/* Moving this doesn't make it invariant.  */
  struct movable *match;	/* First entry for same value */
  struct movable *forces;	/* An insn that must be moved if this is */
  struct movable *next;
};

static FILE *loop_dump_stream;

static rtx verify_loop ();
static int invariant_p ();
static int consec_sets_invariant_p ();
static int can_jump_into_range_p ();
static void count_loop_regs_set ();
static void note_addr_stored ();
static int loop_reg_used_before_p ();
static void constant_high_bytes ();
static void scan_loop ();
static rtx replace_regs ();
static void move_movables ();
static int may_trap_p ();

/* Entry point of this file.  Perform loop optimization
   on the current function.  F is the first insn of the function
   and NREGS is the number of register numbers used.  */

void
loop_optimize (f, nregs, dumpfile)
     /* f is the first instruction of a chain of insns for one function */
     rtx f;
     /* nregs is the total number of registers used in it */
     int nregs;
     FILE *dumpfile;
{
  register rtx insn;
  register int i;
  rtx end;
  rtx last_insn;

  loop_dump_stream = dumpfile;

  init_recog ();

  /* First find the last real insn, and count the number of insns,
     and assign insns their suids.  */

  for (insn = f, i = 0; insn; insn = NEXT_INSN (insn))
    if (INSN_UID (insn) > i)
      i = INSN_UID (insn);

  max_uid = i + 1;
  uid_luid = (short *) alloca ((i + 1) * sizeof (short));
  bzero (uid_luid, (i + 1) * sizeof (short));

  /* Compute the mapping from uids to luids.
     LUIDs are numbers assigned to insns, like uids,
     except that luids increase monotonically through the code.  */

  for (insn = f, i = 0; insn; insn = NEXT_INSN (insn))
    {
      last_insn = insn;
      INSN_LUID (insn) = ++i;
    }

  max_luid = i;

  /* Don't leave gaps in uid_luid for insns that have been
     deleted.  It is possible that the first or last insn
     using some register has been deleted by cross-jumping.
     Make sure that uid_luid for that former insn's uid
     points to the general area where that insn used to be.  */
  for (i = 0; i < max_uid; i++)
    {
      uid_luid[0] = uid_luid[i];
      if (uid_luid[0] != 0)
	break;
    }
  for (i = 0; i < max_uid; i++)
    if (uid_luid[i] == 0)
      uid_luid[i] = uid_luid[i - 1];

  /* Find and process each loop.
     We scan from the end, and process each loop when its start is seen,
     so we process innermost loops first.  */

  for (insn = last_insn; insn; insn = PREV_INSN (insn))
    if (GET_CODE (insn) == NOTE
	&& NOTE_LINE_NUMBER (insn) == NOTE_INSN_LOOP_BEG)
      {
	/* Make sure it really is a loop -- no jumps in from outside.  */
	end = verify_loop (f, insn);
	if (end != 0)
	  /* If so, optimize this loop.  */
	  scan_loop (insn, end, nregs);
	else if (loop_dump_stream)
	  fprintf (loop_dump_stream,
		   "\nLoop at %d ignored due to multiple entry points.\n",
		   INSN_UID (insn));
      }
}

/* Optimize one loop whose start is LOOP_START and end is END.
   LOOP_START is the NOTE_INSN_LOOP_BEG and END is the matching
   NOTE_INSN_LOOP_END.  */

static void
scan_loop (loop_start, end, nregs)
     rtx loop_start, end;
     int nregs;
{
  register int i;
  register rtx p = NEXT_INSN (loop_start);
  /* 1 if we are scanning insns that could be executed zero times.  */
  int maybe_never = 0;
  /* 1 if we are scanning insns that might never be executed
     due to a subroutine call which might exit before they are reached.  */
  int call_passed = 0;
  /* For a rotated loop that is entered near the bottom,
     this is the label at the top.  Otherwise it is zero.  */
  rtx loop_top = 0;
  /* This is the insn (whatever kind) before the NOTE that starts the loop.
     Any insns moved out of the loop will follow it.  */
  rtx before_start = PREV_INSN (loop_start);
  /* Jump insn that enters the loop, or 0 if control drops in.  */
  rtx loop_entry_jump = 0;
  /* Place in the loop where control enters.  */
  rtx scan_start;
  /* Number of insns in the loop.  */
  int insn_count;
  int tem;
  /* Indexed by register number, contains the number of times the reg
     is set during the loop being scanned, or -1 if the insns that set it
     have all been scanned as candidates for being moved out of the loop.
     0 indicates an invariant register; -1 a conditionally invariant one.  */
  short *n_times_set;
  /* Indexed by register number, contains the number of times the reg
     was used during the loop being scanned, not counting changes due
     to moving these insns out of the loop.  */
  short *n_times_used;
  /* Indexed by register number, contains 1 for a register whose
     assignments may not be moved out of the loop.  */
  char *may_not_move;
  /* Chain describing insns movable in current loop.  */
  struct movable *movables = 0;
  /* Last element in `movables' -- so we can add elements at the end.  */
  struct movable *last_movable = 0;
  /* Ratio of extra register life span we can justify
     for saving an instruction.  More if loop doesn't call subroutines
     since in that case saving an insn makes more difference
     and more registers are available.  */
  int threshold = loop_has_call ? 17 : 34;

  n_times_set = (short *) alloca (nregs * sizeof (short));
  n_times_used = (short *) alloca (nregs * sizeof (short));
  may_not_move = (char *) alloca (nregs);

  /* Determine whether this loop starts with a jump down
     to a test at the end.  */
  while (p != end
	 && GET_CODE (p) != CODE_LABEL && GET_CODE (p) != JUMP_INSN)
    p = NEXT_INSN (p);

  /* "Loop" contains neither jumps nor labels;
     it must have been a dummy.  Think no more about it.  */
  if (p == end)
    return;

  scan_start = p;

  /* If loop has a jump before the first label,
     the true entry is the target of that jump.
     Start scan from there.
     But record in LOOP_TOP the place where the end-test jumps
     back to so we can scan that after the end of the loop.  */
  if (GET_CODE (p) == JUMP_INSN)
    {
      loop_entry_jump = p;
      loop_top = NEXT_INSN (p);
      /* Loop entry will never be a conditional jump.
	 If we see one, this must not be a real loop.  */
      if (GET_CODE (loop_top) != BARRIER)
	return;
      p = JUMP_LABEL (p);
      /* Check to see whether the jump actually
	 jumps out of the loop (meaning it's no loop).
	 This case can happen for things like
	 do {..} while (0).  */
      if (p == 0
	  || INSN_LUID (p) < INSN_LUID (loop_start)
	  || INSN_LUID (p) >= INSN_LUID (end))
	{
	  if (loop_dump_stream)
	    fprintf (loop_dump_stream, "\nLoop from %d to %d is phony.\n\n",
		     INSN_UID (loop_start), INSN_UID (end));
	  return;
	}

      /* Find the first label after the entry-jump.  */
      while (GET_CODE (loop_top) != CODE_LABEL)
	{
	  loop_top = NEXT_INSN (loop_top);
	  if (loop_top == 0)
	    abort ();
	}

      /* Maybe rearrange the loop to drop straight in
	 with a new test to jump around it entirely.
	 (The latter is considered outside the loop.)
	 If this is done, we no longer enter with a jump.  */
      if (loop_skip_over (loop_start, end, loop_entry_jump))
	loop_top = 0;
      else
	/* We really do enter with a jump;
	   scan the loop from the place where the jump jumps to.  */
	scan_start = p;
    }

  /* Count number of times each reg is set during this loop.
     Set MAY_NOT_MOVE[I] if it is not safe to move out
     the setting of register I.  */

  bzero (n_times_set, nregs * sizeof (short));
  bzero (may_not_move, nregs);
  count_loop_regs_set (loop_top ? loop_top : loop_start, end,
		       n_times_set, may_not_move, 
		       &insn_count, nregs);
  for (i = 0; i < FIRST_PSEUDO_REGISTER; i++)
    may_not_move[i] = 1, n_times_set[i] = 1;
  bcopy (n_times_set, n_times_used, nregs * sizeof (short));

  if (loop_dump_stream)
    fprintf (loop_dump_stream, "\nLoop from %d to %d: %d real insns\n\n",
	     INSN_UID (loop_start), INSN_UID (end), insn_count);

  /* Scan through the loop finding insns that are safe to move.
     In each such insn, store QImode as the mode, to mark it.
     Then set n_times_set to -1 for the reg being set, so that
     this reg will be considered invariant for subsequent insns.
     We consider whether subsequent insns use the reg
     in deciding whether it is worth actually moving.

     MAYBE_NEVER is nonzero if we have passed a conditional jump insn
     and therefore it is possible that the insns we are scanning
     would never be executed.  At such times, we must make sure
     that it is safe to execute the insn once instead of zero times.
     When MAYBE_NEVER is 0, all insns will be executed at least once
     so that is not a problem.  */

  p = scan_start;
  while (1)
    {
      p = NEXT_INSN (p);
      /* At end of a straight-in loop, we are done.
	 At end of a loop entered at the bottom, scan the top.  */
      if (p == scan_start)
	break;
      if (p == end)
	{
	  if (loop_top != 0)
	    p = NEXT_INSN (loop_top);
	  else
	    break;
	  if (p == scan_start)
	    break;
	}
      if (GET_CODE (p) == INSN
	  && GET_CODE (PATTERN (p)) == SET
	  && GET_CODE (SET_DEST (PATTERN (p))) == REG
	  && ! may_not_move[REGNO (SET_DEST (PATTERN (p)))])
	{
	  int tem1 = 0;
	  /* If this register is used or set outside the loop,
	     then we can move it only if we know this insn is
	     executed exactly once per iteration,
	     and we can check all the insns executed before it
	     to make sure none of them used the value that
	     was lying around at entry to the loop.  */
	  if ((uid_luid[regno_last_uid[REGNO (SET_DEST (PATTERN (p)))]] > INSN_LUID (end)
	       || uid_luid[regno_first_uid[REGNO (SET_DEST (PATTERN (p)))]] < INSN_LUID (loop_start))
	      && (maybe_never
		  || loop_reg_used_before_p (p, loop_start, scan_start, end)))
	    ;
	  else if ((tem = invariant_p (SET_SRC (PATTERN (p)), n_times_set))
		   && (n_times_set[REGNO (SET_DEST (PATTERN (p)))] == 1
		       || (tem1
			   = consec_sets_invariant_p (SET_DEST (PATTERN (p)),
						      n_times_set[REGNO (SET_DEST (PATTERN (p)))],
						      p, n_times_set)))
		   /* If the insn can cause a trap (such as divide by zero),
		      can't move it unless it's guaranteed to be executed
		      once loop is entered.  Even a function call might
		      prevent the trap insn from being reached
		      (since it might exit!)  */
		   && ! ((maybe_never || call_passed)
			 && may_trap_p (SET_SRC (PATTERN (p)))))
	    {
	      register struct movable *m;
	      register int regno = REGNO (SET_DEST (PATTERN (p)));
	      int count;
	      m = (struct movable *) alloca (sizeof (struct movable));
	      m->next = 0;
	      m->insn = p;
	      m->force = 0;
	      m->consec = n_times_set[REGNO (SET_DEST (PATTERN (p)))] - 1;
	      m->done = 0;
	      m->forces = 0;
	      m->partial = 0;
	      m->regno = regno;
	      /* Set M->cond if either invariant_p or consec_sets_invariant_p
		 returned 2 (only conditionally invariant).  */
	      m->cond = ((tem | tem1) > 1);
	      m->global = (uid_luid[regno_last_uid[regno]] > INSN_LUID (end)
			   || uid_luid[regno_first_uid[regno]] < INSN_LUID (loop_start));
	      m->match = 0;
	      m->lifetime = (uid_luid[regno_last_uid[regno]]
			     - uid_luid[regno_first_uid[regno]]);
	      m->times_used = n_times_used[regno];
	      n_times_set[regno] = -1;
	      /* Add M to the end of the chain MOVABLES.  */
	      if (movables == 0)
		movables = m;
	      else
		last_movable->next = m;
	      last_movable = m;
	      /* Skip the consecutive insns, if there are any.  */
	      for (count = m->consec - 1; count >= 0; count--)
		{
		  do p = NEXT_INSN (p);
		  while (GET_CODE (p) == NOTE);
		}
	    }
	  /* If this register is always set within a STRICT_LOW_PART
	     or set to zero, then its high bytes are constant.
	     So clear them outside the loop and within the loop
	     just load the low bytes.
	     We must check that the machine has an instruction to do so.
	     Also, if the value loaded into the register
	     depends on the same register, this cannot be done.  */
	  else if (SET_SRC (PATTERN (p)) == const0_rtx
		   && GET_CODE (NEXT_INSN (p)) == INSN
		   && GET_CODE (PATTERN (NEXT_INSN (p))) == SET
		   && (GET_CODE (SET_DEST (PATTERN (NEXT_INSN (p))))
		       == STRICT_LOW_PART)
		   && (GET_CODE (XEXP (SET_DEST (PATTERN (NEXT_INSN (p))), 0))
		       == SUBREG)
		   && (SUBREG_REG (XEXP (SET_DEST (PATTERN (NEXT_INSN (p))), 0))
		       == SET_DEST (PATTERN (p)))
		   && !reg_mentioned_p (SET_DEST (PATTERN (p)),
					SET_SRC (PATTERN (NEXT_INSN (p)))))
	    {
	      register int regno = REGNO (SET_DEST (PATTERN (p)));
	      if (n_times_set[regno] == 2)
		{
		  register struct movable *m;
		  int count;
		  m = (struct movable *) alloca (sizeof (struct movable));
		  m->next = 0;
		  m->insn = p;
		  m->force = 0;
		  m->consec = 0;
		  m->done = 0;
		  m->forces = 0;
		  m->partial = 1;
		  m->regno = regno;
		  m->cond = 0;
		  /* Say "global" so this register is not combined
		     with any other.  In fact, it is sometimes possible
		     to combine two of these registers, but the criteria
		     are special and have not been programmed in.  */
		  m->global = 1;
		  m->match = 0;
		  m->lifetime = (uid_luid[regno_last_uid[regno]]
				 - uid_luid[regno_first_uid[regno]]);
		  m->times_used = n_times_used[regno];
		  n_times_set[regno] = -1;
		  /* Add M to the end of the chain MOVABLES.  */
		  if (movables == 0)
		    movables = m;
		  else
		    last_movable->next = m;
		  last_movable = m;
		  /* Skip the consecutive insns, if there are any.  */
		  for (count = m->consec - 1; count >= 0; count--)
		    {
		      do p = NEXT_INSN (p);
		      while (GET_CODE (p) == NOTE);
		    }
		}
	    }
	}
      /* Past a call insn, we get to insns which might not be executed
	 because the call might exit.  This matters for insns that trap.  */
      else if (GET_CODE (p) == CALL_INSN)
	call_passed = 1;
      /* Past a label or a jump, we get to insns for which we
	 can't count on whether or how many times they will be
	 executed during each iteration.  Therefore, we can
	 only move out sets of trivial variables
	 (those not used after the loop).  */
      else if (GET_CODE (p) == CODE_LABEL || GET_CODE (p) == JUMP_INSN)
	maybe_never = 1;
    }

  /* For each movable insn, see if the reg that it loads
     leads when it dies right into another conditionally movable insn.
     If so, record that the second insn "forces" the first one,
     since the second can be moved only if the first is.  */

  {
    register struct movable *m, *m1;
    for (m1 = movables; m1; m1 = m1->next)
      {
	int regno = m1->regno;
	for (m = m1->next; m; m = m->next)
	  if (INSN_UID (m->insn) == regno_last_uid[regno])
	    break;
	if (m != 0 && SET_SRC (PATTERN (m->insn)) == SET_DEST (PATTERN (m1->insn)))
	  m = 0;

	/* Increase the priority of the moving the first insn
	   since it permits the second to be moved as well.  */
	if (m != 0)
	  {
	    m->forces = m1;
	    m1->lifetime += m->lifetime;
	    m1->times_used += m1->times_used;
	  }
      }
  }

  /* See if there are multiple movable insns that load the same value.
     If there are, make all but the first point at the first one
     through the `match' field, and add the priorities of them
     all together as the priority of the first.  */

  {
    register struct movable *m;
    char *matched_regs = (char *) alloca (nregs);

    /* Regs that are used more than once are not allowed to match
       or be matched.  I'm no longer sure why not.  */

    for (m = movables; m; m = m->next)
      if (m->match == 0 && n_times_used[m->regno] == 1)
	{
	  register struct movable *m1;
	  int regno = m->regno;

	  bzero (matched_regs, nregs);
	  matched_regs[regno] = 1;

	  for (m1 = m->next; m1; m1 = m1->next)
	    if (m1->match == 0 && n_times_used[m1->regno] == 1
		/* A reg used outside the loop mustn't be eliminated.  */
		&& !m1->global
		&& (matched_regs[m1->regno]
		    ||
		    (
		     /* Can't combine regs with different modes
			even if loaded from the same constant.  */
		     (GET_MODE (SET_DEST (PATTERN (m->insn)))
		      == GET_MODE (SET_DEST (PATTERN (m1->insn))))
		     /* See if the source of M1 says it matches M.  */
		     && ((GET_CODE (SET_SRC (PATTERN (m1->insn))) == REG
			  && matched_regs[REGNO (SET_SRC (PATTERN (m1->insn)))])
			 || rtx_equal_p (SET_SRC (PATTERN (m->insn)),
					 SET_SRC (PATTERN (m1->insn)))
			 || (REG_NOTES (m->insn) && REG_NOTES (m1->insn)
			     && REG_NOTE_KIND (REG_NOTES (m->insn)) == REG_EQUIV
			     && REG_NOTE_KIND (REG_NOTES (m1->insn)) == REG_EQUIV
			     && rtx_equal_p (XEXP (REG_NOTES (m->insn), 0),
					     XEXP (REG_NOTES (m1->insn), 0)))))))
	      {
		m->lifetime += m1->lifetime;
		m->times_used += m1->times_used;
		m1->match = m;
		matched_regs[m1->regno] = 1;
	      }
	}
  }
	
  /* Now consider each movable insn to decide whether it is worth moving.  */

  move_movables (movables, n_times_set, n_times_used, threshold,
		 insn_count, loop_start, end, nregs);
}

/* Scan MOVABLES, and move the insns that deserve to be moved.
   If two matching movables are combined, replace one reg with the
   other throughout.  */

static void
move_movables (movables, n_times_set, n_times_used, threshold,
	       insn_count, loop_start, end, nregs)
     struct movable *movables;
     short *n_times_set;
     short *n_times_used;
     int threshold;
     int insn_count;
     rtx loop_start;
     rtx end;
     int nregs;
{
  rtx new_start = 0;
  register struct movable *m;
  register rtx p;
  /* Map of pseudo-register replacements to handle combining
     when we move several insns that load the same value
     into different pseudo-registers.  */
  rtx *reg_map = (rtx *) alloca (nregs * sizeof (rtx));
  char *already_moved = (char *) alloca (nregs);

  bzero (already_moved, nregs);
  bzero (reg_map, nregs * sizeof (rtx));

  for (m = movables; m; m = m->next)
    {
      /* Describe this movable insn.  */

      if (loop_dump_stream)
	{
	  fprintf (loop_dump_stream, "Insn %d: regno %d (life %d), ",
		   INSN_UID (m->insn), m->regno, m->lifetime);
	  if (m->consec > 0)
	    fprintf (loop_dump_stream, "consec %d, ", m->consec);
	  if (m->cond)
	    fprintf (loop_dump_stream, "cond ");
	  if (m->force)
	    fprintf (loop_dump_stream, "force ");
	  if (m->global)
	    fprintf (loop_dump_stream, "global ");
	  if (m->done)
	    fprintf (loop_dump_stream, "done ");
	  if (m->match)
	    fprintf (loop_dump_stream, "matches %d ",
		     INSN_UID (m->match->insn));
	  if (m->forces)
	    fprintf (loop_dump_stream, "forces %d ",
		     INSN_UID (m->forces->insn));
	}

      /* Ignore the insn if it's already done (it matched something else).
	 Otherwise, see if it is now safe to move.  */

      if (!m->done
	  && (! m->cond
	      || (1 == invariant_p (SET_SRC (PATTERN (m->insn)), n_times_set)
		  && (m->consec == 0
		      || 1 == consec_sets_invariant_p (SET_DEST (PATTERN (m->insn)),
						       m->consec + 1,
						       m->insn, n_times_set))))
	  && (! m->forces || m->forces->done))
	{
	  register int regno;
	  register rtx p;
	  int times_used = m->times_used + m->consec;

	  /* We have an insn that is safe to move.
	     Compute its desirability.  */

	  p = m->insn;
	  regno = m->regno;

	  if (loop_dump_stream)
	    fprintf (loop_dump_stream, "reg uses %d ", times_used);

	  /* An insn MUST be moved if we already moved something else
	     which is safe only if this one is moved too: that is,
	     if already_moved[REGNO] is nonzero.  */

	  /* An insn is desirable to move if the new lifetime of the
	     register is no more than THRESHOLD times the old lifetime.
	     If it's not desirable, it means the loop is so big
	     that moving won't speed things up much,
	     and it is liable to make register usage worse.  */

	  /* It is also desirable to move if it can be moved at no
	     extra cost because something else was already moved.  */

	  if (already_moved[regno]
	      || (threshold * times_used * m->lifetime) >= insn_count
	      || (m->forces && m->forces->done
		  && n_times_used[m->forces->regno] == 1))
	    {
	      int count;
	      register struct movable *m1;

	      for (count = m->consec; count >= 0; count--)
		{
		  rtx i1 = emit_insn_before (PATTERN (p), loop_start);
		  if (new_start == 0)
		    new_start = i1;

		  if (loop_dump_stream)
		    fprintf (loop_dump_stream, "moved to %d", INSN_UID (i1));

		  /* Mark the moved, invariant reg as being equivalent to
		     its constant value.  */
		  REG_NOTES (i1) = REG_NOTES (p);
		  if (REG_NOTES (i1) == 0
		      && ! m->partial /* But not if its a zero-extend clr. */
		      && ! m->global /* and not if used outside the loop
					(since it might get set outside).  */
		      && CONSTANT_P (SET_SRC (PATTERN (p))))
		    REG_NOTES (i1)
		      = gen_rtx (EXPR_LIST, REG_EQUIV,
				 SET_SRC (PATTERN (p)), REG_NOTES (i1));
		  delete_insn (p);
		  do p = NEXT_INSN (p);
		  while (GET_CODE (p) == NOTE);

		  /* The more insns we move, the less we like moving them.  */
		  threshold -= 2;
		}

	      /* Any other movable that loads the same register
		 MUST be moved.  */
	      already_moved[regno] = 1;

	      /* The reg set here is now invariant.  */
	      if (! m->partial)
		n_times_set[regno] = 0;

	      m->done = 1;

	      /* Combine with this moved insn any other matching movables.  */

	      for (m1 = m->next; m1; m1 = m1->next)
		if (m1->match == m)
		  {
		    /* Schedule the reg loaded by M1
		       for replacement so that shares the reg of M.  */
		    reg_map[m1->regno] = SET_DEST (PATTERN (m->insn));
		    /* Get rid of the matching insn
		       and prevent further processing of it.  */
		    m1->done = 1;
		    delete_insn (m1->insn);

		    /* Any other movable that loads the same register
		       MUST be moved.  */
		    already_moved[m1->regno] = 1;

		    /* The reg merged here is now invariant.  */
		    if (m->partial)
		      n_times_set[m1->regno] = 0;
		  }
	    }
	  else if (loop_dump_stream)
	    fprintf (loop_dump_stream, "not desirable");
	}
      else if (loop_dump_stream && !m->match)
	fprintf (loop_dump_stream, "not safe");

      if (loop_dump_stream)
	fprintf (loop_dump_stream, "\n");
    }

  if (new_start == 0)
    new_start = loop_start;

  /* Go through all the instructions in the loop, making
     all the register substitutions scheduled in REG_MAP.  */
  for (p = new_start; p != end; p = NEXT_INSN (p))
    if (GET_CODE (p) == INSN || GET_CODE (p) == JUMP_INSN
	|| GET_CODE (p) == CALL_INSN)
      replace_regs (PATTERN (p), reg_map);
}

/* Optionally change a loop which enters just before the endtest
   to one which falls straight in
   after skipping around the entire loop if the endtest would drop out.
   Returns 1 if the change was made, 0 if the loop was not really suitable.  */

int
loop_skip_over (start, end, loop_entry_jump)
     rtx start;
     rtx end;
     rtx loop_entry_jump;
{
  rtx endtestjump;
  register rtx p = JUMP_LABEL (loop_entry_jump);

  while (GET_CODE (p) != INSN && GET_CODE (p) != JUMP_INSN
	 && GET_CODE (p) != CALL_INSN)
    p = NEXT_INSN (p);
  endtestjump = next_real_insn (p);

  /* Check that we (1) enter at a compare insn and (2)
     the insn (presumably a jump) following that compare
     is the last in the loop and jumps back to the loop beginning.  */

  if (GET_CODE (PATTERN (p)) == SET
      && SET_DEST (PATTERN (p)) == cc0_rtx
      && endtestjump == prev_real_insn (end)
      && prev_real_insn (JUMP_LABEL (endtestjump)) == loop_entry_jump)
    {
      rtx newlab;
      /* This is the jump that we insert.  */
      rtx new_jump;

      /* Ok, duplicate that test before start of loop.  */
      emit_insn_before (copy_rtx (PATTERN (p)), start);
      /* Make a new entry-jump (before the original one)
	 whose condition is opposite to the loop-around endtest
	 and which jumps around the loop (to just after the endtest).  */
      newlab = gen_label_rtx ();
      emit_label_after (newlab, endtestjump);
      emit_jump_insn_before (copy_rtx (PATTERN (endtestjump)), start);
      new_jump = PREV_INSN (start);
      JUMP_LABEL (new_jump) = JUMP_LABEL (endtestjump);
      LABEL_NUSES (JUMP_LABEL (endtestjump))++;
      invert_jump (new_jump, newlab);
      /* Delete the original entry-jump.  */
      delete_insn (loop_entry_jump);

      return 1;
    }

  return 0;
}

/* Throughout the rtx X, replace many registers according to REG_MAP.
   Return the replacement for X (which may be X with altered contents).
   REG_MAP[R] is the replacement for register R, or 0 for don't replace.  */

static rtx
replace_regs (x, reg_map)
     rtx x;
     rtx *reg_map;
{
  register RTX_CODE code = GET_CODE (x);
  register int i;
  register char *fmt;

  switch (code)
    {
    case PC:
    case CC0:
    case CONST_INT:
    case CONST_DOUBLE:
    case CONST:
    case SYMBOL_REF:
    case LABEL_REF:
      return x;

    case REG:
      if (reg_map[REGNO (x)] != 0)
	return reg_map[REGNO (x)];
      return x;
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	XEXP (x, i) = replace_regs (XEXP (x, i), reg_map);
      if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = 0; j < XVECLEN (x, i); j++)
	    XVECEXP (x, i, j) = replace_regs (XVECEXP (x, i, j), reg_map);
	}
    }
  return x;
}

#if 0
/* P is an instruction that sets a register to the result of a ZERO_EXTEND.
   Replace it with an instruction to load just the low bytes
   if the machine supports such an instruction,
   and insert above LOOP_START an instruction to clear the register.  */

static void
constant_high_bytes (p, loop_start)
     rtx p, loop_start;
{
  register rtx new;
  register int insn_code_number;

  /* Try to change (SET (REG ...) (ZERO_EXTEND (..:B ...)))
     to (SET (STRICT_LOW_PART (SUBREG:B (REG...))) ...).  */

  new = gen_rtx (SET, VOIDmode,
		 gen_rtx (STRICT_LOW_PART, VOIDmode,
			  gen_rtx (SUBREG, GET_MODE (XEXP (SET_SRC (PATTERN (p)), 0)),
				   SET_DEST (PATTERN (p)),
				   0)),
		 XEXP (SET_SRC (PATTERN (p)), 0));
  insn_code_number = recog (new, p);

  if (insn_code_number)
    {
      register int i;

      /* Clear destination register before the loop.  */
      emit_insn_before (gen_rtx (SET, VOIDmode,
				 SET_DEST (PATTERN (p)),
				 const0_rtx),
			loop_start);

      /* Inside the loop, just load the low part.  */
      PATTERN (p) = new;
    }
}
#endif

/* Verify that the ostensible loop starting at START
   really is a loop: nothing jumps into it from outside.
   Return the marker for the end of the loop, or zero if not a real loop.

   Also set the variables `unknown_*_altered' and `loop_has_call',
   and fill in the array `loop_store_addrs'.  */

static rtx
verify_loop (f, start)
     rtx f, start;
{
  register int level = 1;
  register rtx insn, end;

  /* First find the LOOP_END that matches.
     Also check each insn for storing in memory and record where.  */

  unknown_address_altered = 0;
  unknown_aggregate_altered = 0;
  fixed_aggregate_altered = 0;
  loop_has_call = 0;
  loop_store_addrs_idx = 0;

  for (insn = NEXT_INSN (start); level > 0; insn = NEXT_INSN (insn))
    {
      if (insn == 0)
	/* Parse errors can cause a loop-beg with no loop-end.  */
	return 0;
      if (GET_CODE (insn) == NOTE)
	{
	  if (NOTE_LINE_NUMBER (insn) == NOTE_INSN_LOOP_BEG)
	    ++level;
	  else if (NOTE_LINE_NUMBER (insn) == NOTE_INSN_LOOP_END)
	    {
	      --level;
	      if (level == 0)
		{
		  end = insn;
		  break;
		}
	    }
	}
      else if (GET_CODE (insn) == CALL_INSN)
	{
	  unknown_address_altered = 1;
	  loop_has_call = 1;
	}
      else if (! unknown_address_altered)
	{
	  if (GET_CODE (insn) == INSN || GET_CODE (insn) == JUMP_INSN)
	    note_stores (PATTERN (insn), note_addr_stored);
	}
    }

  /* Now scan all jumps in the function and see if any of them can
     reach a label within the range of the loop.  */

  for (insn = f; insn; insn = NEXT_INSN (insn))
    if (GET_CODE (insn) == JUMP_INSN
	/* Don't get fooled by jumps inserted by loop-optimize.
	   They don't have valid LUIDs, and they never jump into loops.  */
	&& INSN_UID (insn) < max_uid
	&& (INSN_LUID (insn) < INSN_LUID (start)
	    || INSN_LUID (insn) > INSN_LUID (end))
	/* We have a jump that is outside the loop.
	   Does it jump into the loop?  */
	&& can_jump_into_range_p (PATTERN (insn),
				  INSN_LUID (start), INSN_LUID (end)))
      return 0;

#if 0      
  /* Now scan all labels between them and check for any jumps from outside.
     This uses the ref-chains set up by find_basic_blocks.
     This code is not used because it's more convenient for other reasons
     to do the loop optimization before find_basic_blocks.  */

  for (insn = start; insn != end; insn = NEXT_INSN (insn))
    if (GET_CODE (insn) == CODE_LABEL)
      {
	register rtx y;
	for (y = LABEL_REFS (insn); y != insn; y = LABEL_NEXTREF (y))
	  if (INSN_LUID (CONTAINING_INSN (y)) < INSN_LUID (start)
	      || INSN_LUID (CONTAINING_INSN (y)) > INSN_LUID (end))
	    return 0;
      }
#endif

  return end;
}

/* Return 1 if somewhere in X is a LABEL_REF to a label
   located between BEG and END.  */

static int
can_jump_into_range_p (x, beg, end)
     rtx x;
     int beg, end;
{
  register RTX_CODE code = GET_CODE (x);
  register int i;
  register char *fmt;

  if (code == LABEL_REF)
    {
      register int luid = INSN_LUID (XEXP (x, 0));
      return luid > beg && luid < end;
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	{
	  if (can_jump_into_range_p (XEXP (x, i), beg, end))
	    return 1;
	}
      else if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = 0; j < XVECLEN (x, i); j++)
	    if (can_jump_into_range_p (XVECEXP (x, i, j), beg, end))
	      return 1;
	}
    }

  return 0;
}

/* Record that a memory reference X is being set.  */

static void
note_addr_stored (x)
     rtx x;
{
  rtx addr;
  if (x == 0 || GET_CODE (x) != MEM)
    return;
  if (GET_MODE (x) == BLKmode)
    unknown_address_altered = 1;
  else if (rtx_addr_varies_p (x))
    {
      if (GET_CODE (XEXP (x, 0)) == PLUS)
	unknown_aggregate_altered = 1;
      else
	unknown_address_altered = 1;
    }
  else
    {
      register int i;
      register rtx addr = XEXP (x, 0);

      if (x->in_struct)
	fixed_aggregate_altered = 1;
      for (i = 0; i < loop_store_addrs_idx; i++)
	if (rtx_equal_p (loop_store_addrs[i], addr))
	  {
	    if (loop_store_widths[i] < GET_MODE_SIZE (GET_MODE (x)))
	      loop_store_widths[i] = GET_MODE_SIZE (GET_MODE (x));
	    break;
	  }
      if (i == NUM_STORES)
	unknown_address_altered = 1;
      else if (i == loop_store_addrs_idx)
	{
	  loop_store_widths[i] = GET_MODE_SIZE (GET_MODE (x));
	  loop_store_addrs[loop_store_addrs_idx++] = addr;
	}
    }
}

/* Return nonzero if the rtx X is invariant over the current loop.
   N_TIMES_SET is a vector whose element I is nonzero if register I
   is set during the loop.

   The value is 2 if we refer to something only conditionally invariant.

   If `unknown_address_altered' is nonzero, no memory ref is invariant.
   Otherwise if `unknown_aggregate_altered' is nonzero,
   a memory ref is invariant if it is not part of an aggregate
   and its address is fixed and not in `loop_store_addrs'.
   Otherwise if `fixed_aggregate_altered' is nonzero,
   a memory ref is invariant
   if its address is fixed and not in `loop_store_addrs'.
   Otherwise, a memory ref is invariant if its address is fixed and not in
   `loop_store_addrs' or if it is not an aggregate.  */

static int
invariant_p (x, n_times_set)
     register rtx x;
     short *n_times_set;
{
  register int i;
  register RTX_CODE code = GET_CODE (x);
  register char *fmt;
  int conditional = 0;

  switch (code)
    {
    case CONST_INT:
    case CONST_DOUBLE:
    case SYMBOL_REF:
    case LABEL_REF:
    case CONST:
      return 1;

    case PC:
    case CC0:
      return 0;

    case REG:
      if (x == frame_pointer_rtx || x == arg_pointer_rtx
	  || x->unchanging)
	return 1;
      if (n_times_set[REGNO (x)] == -1)
	return 2;
      return n_times_set[REGNO (x)] == 0;

    case MEM:
      /* A store in a varying-address scalar (or a subroutine call)
	 could clobber anything in memory.  */
      if (unknown_address_altered)
	return 0;
      /* Don't mess with volatile memory references.  */
      if (x->volatil)
	return 0;
      /* If it's declared read-only, it is invariant
	 if its address is invariant.  */
      if (x->unchanging)
	return invariant_p (XEXP (x, 0), n_times_set);
      /* A store in a varying-address aggregate component
	 could clobber anything except a scalar with a fixed address.  */
      if (unknown_aggregate_altered
	  && ((x->in_struct || GET_CODE (XEXP (x, 0)) == PLUS)
	      || rtx_addr_varies_p (x)))
	return 0;
      /* A store in a fixed-address aggregate component
	 could clobber anything whose address is not fixed,
	 even an aggregate component.  */
      if (fixed_aggregate_altered
	  && rtx_addr_varies_p (x))
	return 0;
      /* Any store could clobber a varying-address scalar.  */
      if (loop_store_addrs_idx
	  && !(x->in_struct || GET_CODE (XEXP (x, 0)) == PLUS)
	  && rtx_addr_varies_p (x))
	return 0;
      /* A store in a fixed address clobbers overlapping references.  */
      for (i = loop_store_addrs_idx - 1; i >= 0; i--)
	if (addr_overlap_p (x, loop_store_addrs[i], loop_store_widths[i]))
	  return 0;
      /* It's not invalidated by a store in memory
	 but we must still verify the address is invariant.  */
      break;

    case ASM_OPERANDS:
      /* Don't mess with insns declared volatile.  */
      if (x->volatil)
	return 0;
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	{
	  int tem = invariant_p (XEXP (x, i), n_times_set);
	  if (tem == 0)
	    return 0;
	  if (tem == 2)
	    conditional = 1;
	}
      else if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = 0; j < XVECLEN (x, i); j++)
	    {
	      int tem = invariant_p (XVECEXP (x, i, j), n_times_set);
	      if (tem == 0)
		return 0;
	      if (tem == 2)
		conditional = 1;
	    }

	}
    }

  return 1 + conditional;
}

/* Return 1 if OTHER (a mem ref) overlaps the area of memory
   which is SIZE bytes starting at BASE.  */

int
addr_overlap_p (other, base, size)
     rtx other;
     rtx base;
     int size;
{
  int start = 0, end;

  if (GET_CODE (base) == CONST)
    base = XEXP (base, 0);
  if (GET_CODE (base) == PLUS
      && GET_CODE (XEXP (base, 1)) == CONST_INT)
    {
      start = INTVAL (XEXP (base, 1));
      base = XEXP (base, 0);
    }

  end = start + size;
  return refers_to_mem_p (other, base, start, end);
}

/* Return nonzero if all the insns in the loop that set REG
   are INSN and the immediately following insns,
   and if each of those insns sets REG in an invariant way
   according to TABLE (not counting uses of REG in them).

   The value is 2 if some of these insns are only conditionally invariant.

   We assume that INSN itself is the first set of REG
   and that its source is invariant.  */

static int
consec_sets_invariant_p (reg, n_sets, insn, table)
     int n_sets;
     rtx reg, insn;
     short *table;
{
  register rtx p = insn;
  register int regno = REGNO (reg);
  /* Number of sets we have to insist on finding after INSN.  */
  int count = n_sets - 1;
  int old = table[regno];
  int tem = 0;

  table[regno] = 0;

  while (count > 0)
    {
      register enum rtx_code code;
      p = NEXT_INSN (p);
      code = GET_CODE (p);
      if (code == INSN && GET_CODE (PATTERN (p)) == SET
	  && GET_CODE (SET_DEST (PATTERN (p))) == REG
	  && REGNO (SET_DEST (PATTERN (p))) == regno
	  && (tem |= invariant_p (SET_SRC (PATTERN (p)), table)))
	count--;
      else if (code != NOTE)
	{
	  table[regno] = old;
	  return 0;
	}
    }

  table[regno] = old;
  /* If invariant_p ever returned 2, we return 2.  */
  return 1 + (tem & 2);
}

#if 0
/* I don't think this condition is sufficient to allow INSN
   to be moved, so we no longer test it.  */

/* Return 1 if all insns in the basic block of INSN and following INSN
   that set REG are invariant according to TABLE.  */

static int
all_sets_invariant_p (reg, insn, table)
     rtx reg, insn;
     short *table;
{
  register rtx p = insn;
  register int regno = REGNO (reg);

  while (1)
    {
      register enum rtx_code code;
      p = NEXT_INSN (p);
      code = GET_CODE (p);
      if (code == CODE_LABEL || code == JUMP_INSN)
	return 1;
      if (code == INSN && GET_CODE (PATTERN (p)) == SET
	  && GET_CODE (SET_DEST (PATTERN (p))) == REG
	  && REGNO (SET_DEST (PATTERN (p))) == regno)
	{
	  if (!invariant_p (SET_SRC (PATTERN (p)), table))
	    return 0;
	}
    }
}
#endif /* 0 */

/* Increment N_TIMES_SET at the index of each register
   that is modified by an insn between FROM and TO.
   If the value of an element of N_TIMES_SET becomes 2 or more,
   do not keep incrementing it; all values >= 2 would be
   equivalent anyway, and this way we avoid danger of overflow.

   Store in *COUNT_PTR the number of actual instruction
   in the loop.  We use this to decide what is worth moving out.  */

/* last_set[n] is nonzero iff reg n has been set in the current basic block.
   In that case, it is the insn that last set reg n.  */

static void
count_loop_regs_set (from, to, n_times_set, may_not_move, count_ptr, nregs)
     register rtx from, to;
     short *n_times_set;
     char *may_not_move;
     int *count_ptr;
     int nregs;
{
  register rtx *last_set = (rtx *) alloca (nregs * sizeof (rtx));
  register rtx insn;
  register int count = 0;
  register rtx dest;

  bzero (last_set, nregs * sizeof (rtx));
  for (insn = from; insn != to; insn = NEXT_INSN (insn))
    {
      if (GET_CODE (insn) == CALL_INSN)
	{
	  /* If a register is used as a subroutine address,
	     don't allow this register's setting to be moved out of the loop.
	     This condition is not at all logically correct
	     but it averts a very common lossage pattern
	     and creates lossage much less often.  */
	  if (GET_CODE (PATTERN (insn)) == CALL
	      && GET_CODE (XEXP (PATTERN (insn), 0)) == MEM
	      && GET_CODE (XEXP (XEXP (PATTERN (insn), 0), 0)) == REG)
	    {
	      register int regno
		= REGNO (XEXP (XEXP (PATTERN (insn), 0), 0));
	      may_not_move[regno] = 1;
	    }
	  else if (GET_CODE (PATTERN (insn)) == SET
	      && GET_CODE (SET_SRC (PATTERN (insn))) == CALL
	      && GET_CODE (XEXP (SET_SRC (PATTERN (insn)), 0)) == MEM
	      && GET_CODE (XEXP (XEXP (SET_SRC (PATTERN (insn)), 0), 0)) == REG)
	    {
	      register int regno
		= REGNO (XEXP (XEXP (SET_SRC (PATTERN (insn)), 0), 0));
	      may_not_move[regno] = 1;
	      /* The call insn itself sets a reg, which cannot be moved.  */
	      may_not_move[REGNO (SET_DEST (PATTERN (insn)))] = 1;
	      n_times_set[REGNO (SET_DEST (PATTERN (insn)))]++;
	    }
	}
      if (GET_CODE (insn) == INSN || GET_CODE (insn) == JUMP_INSN) 
	{
	  ++count;
	  if (GET_CODE (PATTERN (insn)) == CLOBBER
	      && GET_CODE (XEXP (PATTERN (insn), 0)) == REG)
	    /* Don't move a reg that has an explicit clobber.
	       We might do so sometimes, but it's not worth the pain.  */
	    may_not_move[REGNO (XEXP (PATTERN (insn), 0))] = 1;
	  else if (GET_CODE (PATTERN (insn)) == SET)
	    {
	      dest = SET_DEST (PATTERN (insn));
	      while (GET_CODE (dest) == SUBREG
		     || GET_CODE (dest) == ZERO_EXTRACT
		     || GET_CODE (dest) == SIGN_EXTRACT
		     || GET_CODE (dest) == STRICT_LOW_PART)
		dest = XEXP (dest, 0);
	      if (GET_CODE (dest) == REG)
		{
		  register int regno = REGNO (dest);
		  /* If this is the first setting of this reg
		     in current basic block, and it was set before,
		     it must be set in two basic blocks, so it cannot
		     be moved out of the loop.  */
		  if (n_times_set[regno] > 0 && last_set[regno] == 0)
		    may_not_move[regno] = 1;
		  /* If this is not first setting in current basic block,
		     see if reg was used in between previous one and this.
		     If so, neither one can be moved.  */
		  if (last_set[regno] != 0
		      && reg_used_between_p (dest, last_set[regno], insn))
		    may_not_move[regno] = 1;
		  ++n_times_set[regno];
		  last_set[regno] = insn;
		}
	    }
	  else if (GET_CODE (PATTERN (insn)) == PARALLEL)
	    {
	      register int i;
	      for (i = XVECLEN (PATTERN (insn), 0) - 1; i >= 0; i--)
		{
		  register rtx x = XVECEXP (PATTERN (insn), 0, i);
		  if (GET_CODE (x) == CLOBBER && GET_CODE (XEXP (x, 0)) == REG)
		    /* Don't move a reg that has an explicit clobber.
		       It's not worth the pain to try to do it correctly.  */
		    may_not_move[REGNO (XEXP (x, 0))] = 1;
		  if (GET_CODE (x) == SET)
		    {
		      dest = SET_DEST (x);
		      while (GET_CODE (dest) == SUBREG
			     || GET_CODE (dest) == ZERO_EXTRACT
			     || GET_CODE (dest) == SIGN_EXTRACT
			     || GET_CODE (dest) == STRICT_LOW_PART)
			dest = XEXP (dest, 0);
		      if (GET_CODE (dest) == REG)
			{
			  register int regno = REGNO (dest);
			  ++n_times_set[regno];
			  may_not_move[regno] = 1;
			  last_set[regno] = insn;
			}
		    }
		}
	    }
	}
      if (GET_CODE (insn) == CODE_LABEL || GET_CODE (insn) == JUMP_INSN)
	bzero (last_set, nregs * sizeof (rtx));
    }
  *count_ptr = count;
}

/* Given a loop that is bounded by LOOP_START and LOOP_END
   and that is entered at SCAN_START,
   return 1 if the register set by insn INSN is used by
   any insn that precedes INSN in cyclic order starting
   from the loop entry point.  */

static int
loop_reg_used_before_p (insn, loop_start, scan_start, loop_end)
     rtx insn, loop_start, scan_start, loop_end;
{
  rtx reg = SET_DEST (PATTERN (insn));
  if (INSN_LUID (scan_start) > INSN_LUID (insn))
    return (reg_used_between_p (reg, scan_start, loop_end)
	    || reg_used_between_p (reg, loop_start, insn));
  else
    return reg_used_between_p (reg, scan_start, insn);
}

/* Return nonzero if evaluating rtx X might cause a trap.  */

static int
may_trap_p (x)
     rtx x;
{
  int i;
  enum rtx_code code = GET_CODE (x);
  char *fmt;

  switch (code)
    {
      /* Handle these cases fast.  */
    case CONST_INT:
    case CONST_DOUBLE:
    case SYMBOL_REF:
    case LABEL_REF:
    case CONST:
    case PC:
    case CC0:
    case REG:
      return 0;

      /* Division by a non-constant might trap.  */
    case DIV:
    case MOD:
    case UDIV:
    case UMOD:
      if (! CONSTANT_P (XEXP (x, 1))
	  && GET_CODE (XEXP (x, 1)) != CONST_DOUBLE)
	return 1;
      break;

      /* Memory ref can trap unless it's a static var or a stack slot.  */
    case MEM:
      return rtx_varies_p (XEXP (x, 0));

    case SET:
      /* Any floating arithmetic may trap.  */
      if (GET_MODE_CLASS (GET_MODE (SET_DEST (x))) == MODE_FLOAT
	  && GET_CODE (SET_SRC (x)) != REG
	  && GET_CODE (SET_SRC (x)) != MEM)
	return 1;
    }

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'e')
	{
	  if (may_trap_p (XEXP (x, i)))
	    return 1;
	}
      else if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = 0; j < XVECLEN (x, i); j++)
	    if (may_trap_p (XVECEXP (x, i, j)))
	      return 1;
	}
    }
  return 0;
}
