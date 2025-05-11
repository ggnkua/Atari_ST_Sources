/* Generate from machine description:

   - some #define configuration flags.
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


#include <stdio.h>
#include "config.h"
#include "rtl.h"
#include "obstack.h"

struct obstack obstack;
struct obstack *rtl_obstack = &obstack;

#define obstack_chunk_alloc xmalloc
#define obstack_chunk_free free
extern int xmalloc ();
extern void free ();

/* flags to determine output of machine description dependent #define's.  */
int max_recog_operands_flag;
int max_dup_operands_flag;
int max_sets_per_insn_flag;
int max_clobbers_per_insn_flag;
int register_constraint_flag;

int sets_seen_this_insn;
int clobbers_seen_this_insn;
int dup_operands_seen_this_insn;

void fatal ();

void
walk_insn_part (part)
     rtx part;
{
  register int i, j;
  register RTX_CODE code;
  register char *format_ptr;

  if (part == 0)
    return;

  code = GET_CODE (part);
  switch (code)
    {
    case SET:
      sets_seen_this_insn++;
      break;

    case CLOBBER:
      clobbers_seen_this_insn++;
      break;

    case MATCH_OPERAND:
      if (XINT (part, 0) > max_recog_operands_flag)
	max_recog_operands_flag = XINT (part, 0);
      if (XSTR (part, 2) && *XSTR (part, 2))
	register_constraint_flag = 1;
      return;

    case LABEL_REF:
      if (GET_CODE (XEXP (part, 0)) == MATCH_OPERAND)
	break;
      return;

    case MATCH_DUP:
      ++dup_operands_seen_this_insn;
      if (XINT (part, 0) > max_recog_operands_flag)
	max_recog_operands_flag = XINT (part, 0);

    case REG: case CONST_INT: case SYMBOL_REF:
    case PC: case CC0:
      return;
    }

  format_ptr = GET_RTX_FORMAT (GET_CODE (part));

  for (i = 0; i < GET_RTX_LENGTH (GET_CODE (part)); i++)
    switch (*format_ptr++)
      {
      case 'e':
      case 'u':
	walk_insn_part (XEXP (part, i));
	break;
      case 'E':
	if (XVEC (part, i) != NULL)
	  for (j = 0; j < XVECLEN (part, i); j++)
	    walk_insn_part (XVECEXP (part, i, j));
	break;
      }
}

void
gen_insn (insn)
     rtx insn;
{
  int i;

  /* Walk the insn pattern to gather the #define's status.  */
  sets_seen_this_insn = 0;
  clobbers_seen_this_insn = 0;
  dup_operands_seen_this_insn = 0;
  if (XVEC (insn, 1) != 0)
    for (i = 0; i < XVECLEN (insn, 1); i++)
      walk_insn_part (XVECEXP (insn, 1, i));

  if (sets_seen_this_insn > max_sets_per_insn_flag)
    max_sets_per_insn_flag = sets_seen_this_insn;
  if (clobbers_seen_this_insn > max_clobbers_per_insn_flag)
    max_clobbers_per_insn_flag = clobbers_seen_this_insn;
  if (dup_operands_seen_this_insn > max_dup_operands_flag)
    max_dup_operands_flag = dup_operands_seen_this_insn;
}

/* Similar but scan a define_expand.  */

void
gen_expand (insn)
     rtx insn;
{
  int i;

  /* Walk the insn pattern to gather the #define's status.  */

  /* Note that we don't bother recording the number of MATCH_DUPs
     that occur in a gen_expand, because only reload cares about that.  */
  if (XVEC (insn, 1) != 0)
    for (i = 0; i < XVECLEN (insn, 1); i++)
      {
	/* Compute the maximum SETs and CLOBBERS
	   in any one of the sub-insns;
	   don't sum across all of them.  */
	sets_seen_this_insn = 0;
	clobbers_seen_this_insn = 0;

	walk_insn_part (XVECEXP (insn, 1, i));

	if (sets_seen_this_insn > max_sets_per_insn_flag)
	  max_sets_per_insn_flag = sets_seen_this_insn;
	if (clobbers_seen_this_insn > max_clobbers_per_insn_flag)
	  max_clobbers_per_insn_flag = clobbers_seen_this_insn;
      }
}

void
gen_peephole (peep)
     rtx peep;
{
  int i;

  /* Look through the patterns that are matched
     to compute the maximum operand number.  */
  for (i = 0; i < XVECLEN (peep, 0); i++)
    walk_insn_part (XVECEXP (peep, 0, i));
}

int
xmalloc (size)
{
  register int val = malloc (size);

  if (val == 0)
    fatal ("virtual memory exhausted");

  return val;
}

int
xrealloc (ptr, size)
     char *ptr;
     int size;
{
  int result = realloc (ptr, size);
  if (!result)
    fatal ("virtual memory exhausted");
  return result;
}

void
fatal (s, a1, a2)
{
  fprintf (stderr, "genconfig: ");
  fprintf (stderr, s, a1, a2);
  fprintf (stderr, "\n");
  exit (FATAL_EXIT_CODE);
}

int
main (argc, argv)
     int argc;
     char **argv;
{
  rtx desc;
  FILE *infile;
  extern rtx read_rtx ();
  register int c;

  obstack_init (rtl_obstack);

  if (argc <= 1)
    fatal ("No input file name.");

  infile = fopen (argv[1], "r");
  if (infile == 0)
    {
      perror (argv[1]);
      exit (FATAL_EXIT_CODE);
    }

  init_rtl ();

  printf ("/* Generated automatically by the program `genconfig'\n\
from the machine description file `md'.  */\n\n");

  /* Read the machine description.  */

  while (1)
    {
      c = read_skip_spaces (infile);
      if (c == EOF)
	break;
      ungetc (c, infile);

      desc = read_rtx (infile);
      if (GET_CODE (desc) == DEFINE_INSN)
	gen_insn (desc);
      if (GET_CODE (desc) == DEFINE_EXPAND)
	gen_expand (desc);
      if (GET_CODE (desc) == DEFINE_PEEPHOLE)
	gen_peephole (desc);
    }

  printf ("\n#define MAX_RECOG_OPERANDS %d\n", max_recog_operands_flag + 1);

  if (max_dup_operands_flag == 0)
    max_dup_operands_flag = 1;
  printf ("\n#define MAX_DUP_OPERANDS %d\n", max_dup_operands_flag);

  printf ("#define MAX_SETS_PER_INSN %d\n", max_sets_per_insn_flag);

  printf ("#define MAX_CLOBBERS_PER_INSN %d\n", max_clobbers_per_insn_flag);

  if (register_constraint_flag)
    printf ("#define REGISTER_CONSTRAINTS\n");

  fflush (stdout);
  exit (ferror (stdout) != 0 ? FATAL_EXIT_CODE : SUCCESS_EXIT_CODE);
}
