/* Generate code from machine description to perform peephole optimizations.
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

void match_rtx ();
void gen_exp ();
void fatal ();


int max_opno;

/* While tree-walking an instruction pattern, we keep a chain
   of these `struct link's to record how to get down to the
   current position.  In each one, POS is the operand number,
   and if the operand is a vector VEC is the element number.
   VEC is -1 if the operand is not a vector.  */

struct link
{
  struct link *next;
  int pos;
  int vecelt;
};

/* Number of operands used in current peephole definition.  */

int n_operands;

/* Peephole optimizations get insn codes just like insn patterns.
   Count them so we know the code of the define_peephole we are handling.  */

int insn_code_number = 0;

void print_path ();
void print_code ();

void
gen_peephole (peep)
     rtx peep;
{
  int ninsns = XVECLEN (peep, 0);
  int i;

  n_operands = 0;

  printf ("  insn = ins1;\n");

  for (i = 0; i < ninsns; i++)
    {
      if (i > 0)
	{
	  printf ("  do { insn = NEXT_INSN (insn);\n");
	  printf ("       if (insn == 0) goto L%d; }\n",
		  insn_code_number);
	  printf ("  while (GET_CODE (insn) == NOTE);\n");
	}

      printf ("  if (GET_CODE (insn) == CODE_LABEL) goto L%d;\n",
	      insn_code_number);

      printf ("  pat = PATTERN (insn);\n");
      /* Walk the insn's pattern, remembering at all times the path
	 down to the walking point.  */

      match_rtx (XVECEXP (peep, 0, i), 0, insn_code_number);
    }

  /* We get this far if the pattern matches.
     Now test the extra condition.  */

  if (XSTR (peep, 1) && XSTR (peep, 1)[0])
    printf ("  if (! (%s)) goto L%d;\n",
	    XSTR (peep, 1), insn_code_number);

  /* If that matches, construct new pattern and put it in the first insn.
     This new pattern will never be matched.
     It exists only so that insn-extract can get the operands back.
     So use a simple regular form: a PARALLEL containing a vector
     of all the operands.  */

  printf ("  PATTERN (ins1) = gen_rtx (PARALLEL, VOIDmode, gen_rtvec_v (%d, operands));\n", n_operands);
  printf ("  insn = ins1;\n");

  /* Make sure that labels referred to by the insns
     don't get deleted because of their counts' going to zero.  */
  printf ("  for (i = 0; i < %d; i++)\n", n_operands);
  printf ("    if (GET_CODE (operands[i]) == CODE_LABEL)\n");
  printf ("      LABEL_NUSES (operands[i])++;\n");

  /* Record this define_peephole's insn code in the insn,
     as if it had been recognized to match this.  */
  printf ("  INSN_CODE (insn) = %d;\n",
	  insn_code_number);

  /* Delete the remaining insns.  */
  for (i = 1; i < ninsns; i++)
    {
      printf ("  do insn = NEXT_INSN (insn);\n");
      printf ("  while (GET_CODE (insn) == NOTE);\n");
      printf ("  delete_insn (insn);\n");
    }

  printf ("  return 1;\n");

  printf (" L%d:\n\n", insn_code_number);
}

void
match_rtx (x, path, fail_label)
     rtx x;
     struct link *path;
     int fail_label;
{
  register RTX_CODE code;
  register int i;
  register int len;
  register char *fmt;
  struct link link;

  if (x == 0)
    return;


  code = GET_CODE (x);

  switch (code)
    {
    case MATCH_OPERAND:
      if (XINT (x, 0) > max_opno)
	max_opno = XINT (x, 0);
      if (XINT (x, 0) >= n_operands)
	n_operands = 1 + XINT (x, 0);

      printf ("  x = ");
      print_path (path);
      printf (";\n");

      printf ("  operands[%d] = x;\n", XINT (x, 0));
      if (XSTR (x, 1) && XSTR (x, 1)[0])
	printf ("  if (! %s (x, %smode)) goto L%d;\n",
		XSTR (x, 1), GET_MODE_NAME (GET_MODE (x)), fail_label);
      return;

    case MATCH_DUP:
      printf ("  x = ");
      print_path (path);
      printf (";\n");

      printf ("  if (!rtx_equal_p (operands[%d], x)) goto L%d;\n",
	      XINT (x, 0), fail_label);
      return;

    case ADDRESS:
      match_rtx (XEXP (x, 0), path, fail_label);
      return;
    }

  printf ("  x = ");
  print_path (path);
  printf (";\n");

  printf ("  if (GET_CODE (x) != ");
  print_code (code);
  printf (") goto L%d;\n", fail_label);

  if (GET_MODE (x) != VOIDmode)
    {
      printf ("  if (GET_MODE (x) != %smode) goto L%d;\n",
	      GET_MODE_NAME (GET_MODE (x)), fail_label);
    }

  link.next = path;
  link.vecelt = -1;
  fmt = GET_RTX_FORMAT (code);
  len = GET_RTX_LENGTH (code);
  for (i = 0; i < len; i++)
    {
      link.pos = i;
      if (fmt[i] == 'e' || fmt[i] == 'u')
	match_rtx (XEXP (x, i), &link, fail_label);
      else if (fmt[i] == 'E')
	{
	  int j;
	  printf ("  if (XVECLEN (x, %d) != %d) goto L%d;\n",
		  i, XVECLEN (x, i), fail_label);
	  for (j = XVECLEN (x, i) - 1; j >= 0; j--)
	    {
	      link.vecelt = j;
	      match_rtx (XVECEXP (x, i, j), &link, fail_label);
	    }
	}
      else if (fmt[i] == 'i')
	{
	  /* Make sure that at run time `x' is the RTX we want to test.  */
	  if (i != 0)
	    {
	      printf ("  x = ");
	      print_path (path);
	      printf (";\n");
	    }

	  printf ("  if (XINT (x, %d) != %d) goto L%d;\n",
		  i, XINT (x, i), fail_label);
	}
      else if (fmt[i] == 's')
	{
	  /* Make sure that at run time `x' is the RTX we want to test.  */
	  if (i != 0)
	    {
	      printf ("  x = ");
	      print_path (path);
	      printf (";\n");
	    }

	  printf ("  if (strcmp (XSTR (x, %d), \"%s\")) goto L%d;\n",
		  i, XSTR (x, i), fail_label);
	}
    }
}

/* Given a PATH, representing a path down the instruction's
   pattern from the root to a certain point, output code to
   evaluate to the rtx at that point.  */

void
print_path (path)
     struct link *path;
{
  if (path == 0)
    printf ("pat");
  else if (path->vecelt >= 0)
    {
      printf ("XVECEXP (");
      print_path (path->next);
      printf (", %d, %d)", path->pos, path->vecelt);
    }
  else
    {
      printf ("XEXP (");
      print_path (path->next);
      printf (", %d)", path->pos);
    }
}

void
print_code (code)
     RTX_CODE code;
{
  register char *p1;
  for (p1 = GET_RTX_NAME (code); *p1; p1++)
    {
      if (*p1 >= 'a' && *p1 <= 'z')
	putchar (*p1 + 'A' - 'a');
      else
	putchar (*p1);
    }
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
  fprintf (stderr, "genpeep: ");
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
  register int c, i;

  max_opno = -1;

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

  printf ("/* Generated automatically by the program `genpeep'\n\
from the machine description file `md'.  */\n\n");

  printf ("#include \"rtl.h\"\n\n");
  printf ("#include \"config.h\"\n\n");
  printf ("#include \"regs.h\"\n\n");

  printf ("extern rtx peep_operand[];\n\n");
  printf ("#define operands peep_operand\n\n");

  printf ("int\npeephole (ins1)\n     rtx ins1;\n{\n");
  printf ("  rtx insn, x, pat;\n");
  printf ("  int i;\n");

  /* Read the machine description.  */

  while (1)
    {
      c = read_skip_spaces (infile);
      if (c == EOF)
	break;
      ungetc (c, infile);

      desc = read_rtx (infile);
      if (GET_CODE (desc) == DEFINE_PEEPHOLE)
	{
	  gen_peephole (desc);
	  insn_code_number++;
	}
      if (GET_CODE (desc) == DEFINE_INSN || GET_CODE (desc) == DEFINE_EXPAND)
	{
	  insn_code_number++;
	}
    }

  printf ("  return 0;\n}\n\n");

  if (max_opno == -1)
    max_opno = 1;

  printf ("rtx peep_operand[%d];\n", max_opno + 1);

  fflush (stdout);
  exit (ferror (stdout) != 0 ? FATAL_EXIT_CODE : SUCCESS_EXIT_CODE);
}
