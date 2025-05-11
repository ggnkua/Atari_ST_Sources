/* Define control and data flow tables, and regsets.
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


/* Define the type for a pointer to a set with a bit for each
   (hard or pseudo) register.  */

typedef long *regset;

/* Size of a regset for the current function,
   in (1) bytes and (2) elements.  */

extern int regset_bytes;
extern int regset_size;

/* Number of bits in each actual element of a regset.  */

#define REGSET_ELT_BITS HOST_BITS_PER_INT

/* Number of basic blocks in the current function.  */

extern int n_basic_blocks;

/* Index by basic block number, get first insn in the block.  */

extern rtx *basic_block_head;

/* Index by basic block number, get last insn in the block.  */

extern rtx *basic_block_end;

/* Index by basic block number, get address of regset
   describing the registers live at the start of that block.  */

extern regset *basic_block_live_at_start;

/* Indexed by n, gives number of basic block that  (REG n) is used in.
   Or gives -2 if (REG n) is used in more than one basic block.
   Or -1 if it has not yet been seen so no basic block is known.  */

extern short *reg_basic_block;
