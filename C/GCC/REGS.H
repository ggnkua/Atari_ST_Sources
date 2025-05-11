/* Define per-register tables for data flow info and register allocation.
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



#define REG_BYTES(R) mode_size[(int) GET_MODE (R)]

/* Get the number of consecutive hard regs required to hold the REG rtx R.
   When something may be an explicit hard reg, REG_SIZE is the only
   valid way to get this value.  You cannot get it from the regno.  */

#define REG_SIZE(R) \
  ((mode_size[(int) GET_MODE (R)] + UNITS_PER_WORD - 1) / UNITS_PER_WORD)

/* Maximum register number used in this function, plus one.  */

extern int max_regno;

/* Indexed by n, gives number of times (REG n) is used or set.
   References within loops may be counted more times.  */

extern short *reg_n_refs;

/* Indexed by n, gives number of times (REG n) is set.  */

extern short *reg_n_sets;

/* Indexed by N, gives number of insns in which register N dies.
   Note that if register N is live around loops, it can die
   in transitions between basic blocks, and that is not counted here.
   So this is only a reliable indicator of how many regions of life there are
   for registers that are contained in one basic block.  */

extern short *reg_n_deaths;

/* Get the number of consecutive words required to hold pseudo-reg N.  */

#define PSEUDO_REGNO_SIZE(N) \
  ((GET_MODE_SIZE (PSEUDO_REGNO_MODE (N)) + UNITS_PER_WORD - 1)		\
   / UNITS_PER_WORD)

/* Get the number of bytes required to hold pseudo-reg N.  */

#define PSEUDO_REGNO_BYTES(N) \
  GET_MODE_SIZE (PSEUDO_REGNO_MODE (N))

/* Get the machine mode of pseudo-reg N.  */

#define PSEUDO_REGNO_MODE(N) GET_MODE (regno_reg_rtx[N])

/* Indexed by N, gives 1 if (REG n) is live across a CALL_INSN.  */

extern char *reg_crosses_call;

/* Total number of instructions at which (REG n) is live.
   The larger this is, the less priority (REG n) gets for
   allocation in a hard register (in global-alloc).
   This is set in flow.c and remains valid for the rest of the compilation
   of the function; it is used to control register allocation.

   local-alloc.c may alter this number to change the priority.

   Negative values are special.
   -1 is used to mark a pseudo reg which has a constant or memory equivalent
   and is used infrequently enough that it should not get a hard register.
   -2 is used to mark a pseudo reg for a parameter, when a frame pointer
   is not required.  global-alloc.c makes an allocno for this but does
   not try to assign a hard register to it.  */

extern int *reg_live_length;

/* Vector of substitutions of register numbers,
   used to map pseudo regs into hardware regs.  */

extern short *reg_renumber;

/* Vector indexed by hardware reg
   saying whether that reg is ever used.  */

extern char regs_ever_live[FIRST_PSEUDO_REGISTER];

/* Vector indexed by regno; gives uid of first insn using that reg.
   This is computed by reg_scan and not adjusted for subsequent changes. */

extern short *regno_first_uid;

/* Vector indexed by regno; gives uid of last insn using that reg.
   This is computed by reg_scan and not adjusted for subsequent changes. */

extern short *regno_last_uid;

/* Vector indexed by regno; contains 1 for a register is considered a pointer.
   Reloading, etc. will use a pointer register rather than a non-pointer
   as the base register in an address, when there is a choice of two regs.  */

extern char *regno_pointer_flag;
#define REGNO_POINTER_FLAG(REGNO) regno_pointer_flag[REGNO]

/* Vector mapping pseudo regno into the REG rtx for that register.
   This is computed by reg_scan.  */

extern rtx *regno_reg_rtx;
