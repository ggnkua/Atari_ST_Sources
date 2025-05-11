/* Generate code from machine description to extract operands from insn as rtl.
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

void walk_rtx ();
void print_path ();
void fatal ();

/* Number instruction patterns handled, starting at 0 for first one.  */

int insn_code_number;

/* Number the occurrences of MATCH_DUP in each instruction,
   starting at 0 for the first occurrence.  */

int dup_count;

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

void
gen_insn (insn)
     rtx insn;
{
  register int i;

  dup_count = 0;

  /* Output the function name and argument declaration.  */
  /* It would be cleaner to make `int' the return type
     but 4.2 vax compiler doesn't accept that in the array
     that these functions are supposed to go in.  */
  printf ("VOID\nextract_%d (insn)\n     rtx insn;\n", insn_code_number);
  printf ("{\n");

  /* Walk the insn's pattern, remembering at all times the path
     down to the walking point.  */

  if (XVECLEN (insn, 1) == 1)
    walk_rtx (XVECEXP (insn, 1, 0), 0);
  else
    for (i = XVECLEN (insn, 1) - 1; i >= 0; i--)
      {
	struct link link;
	link.next = 0;
	link.pos = 0;
	link.vecelt = i;
	walk_rtx (XVECEXP (insn, 1, i), &link);
      }
  printf ("}\n\n");
}

/* Like gen_insn but handles `define_peephole'.  */

void
gen_peephole (peep)
     rtx peep;
{
  /* Output the function name and argument declaration.  */
  printf ("VOID\nextract_%d (insn)\n     rtx insn;\n", insn_code_number);
  printf ("{\n");
  /* The vector in the insn says how many operands it has.
     And all it contains are operands.  In fact, the vector was
     created just for the sake of this function.  */
  printf ("\
  bcopy (&XVECEXP (insn, 0, 0), recog_operand,\
         UNITS_PER_WORD * XVECLEN (insn, 0));\n");
  printf ("}\n\n");
}

void
walk_rtx (x, path)
     rtx x;
     struct link *path;
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
    case PC:
    case CC0:
    case CONST_INT:
    case SYMBOL_REF:
      return;

    case MATCH_OPERAND:
      printf ("  recog_operand[%d] = *(recog_operand_loc[%d]\n    = &",
	      XINT (x, 0), XINT (x, 0));
      print_path (path);
      printf (");\n");
      break;

    case MATCH_DUP:
      printf ("  recog_dup_loc[%d] = &", dup_count);
      print_path (path);
      printf (";\n");
      printf ("  recog_dup_num[%d] = %d;\n", dup_count, XINT (x, 0));
      dup_count++;
      break;

    case ADDRESS:
      walk_rtx (XEXP (x, 0), path);
      return;
    }

  link.next = path;
  link.vecelt = -1;
  fmt = GET_RTX_FORMAT (code);
  len = GET_RTX_LENGTH (code);
  for (i = 0; i < len; i++)
    {
      link.pos = i;
      if (fmt[i] == 'e' || fmt[i] == 'u')
	{
	  walk_rtx (XEXP (x, i), &link);
	}
      else if (fmt[i] == 'E')
	{
	  int j;
	  for (j = XVECLEN (x, i) - 1; j >= 0; j--)
	    {
	      link.vecelt = j;
	      walk_rtx (XVECEXP (x, i, j), &link);
	    }
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
    printf ("insn");
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
  fprintf (stderr, "genextract: ");
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

  /* Assign sequential codes to all entries in the machine description
     in parallel with the tables in insn-output.c.  */

  insn_code_number = 0;

  printf ("/* Generated automatically by the program `genextract'\n\
from the machine description file `md'.  */\n\n");

  printf ("#include \"config.h\"\n");
  printf ("#include \"rtl.h\"\n\n");

  printf ("extern rtx recog_operand[];\n");
  printf ("extern rtx *recog_operand_loc[];\n");
  printf ("extern rtx *recog_dup_loc[];\n");
  printf ("extern char recog_dup_num[];\n\n");

  /* The extractor functions really should return `void';
     but old C compilers don't seem to be able to handle the array
     definition if `void' is used.  So use `int' in non-ANSI C compilers.  */

  printf ("#ifdef __STDC__\n#define VOID void\n#else\n#define VOID int\n#endif\n\n");

  /* Read the machine description.  */

  while (1)
    {
      c = read_skip_spaces (infile);
      if (c == EOF)
	break;
      ungetc (c, infile);

      desc = read_rtx (infile);
      if (GET_CODE (desc) == DEFINE_INSN)
	{
	  gen_insn (desc);
	  ++insn_code_number;
	}
      if (GET_CODE (desc) == DEFINE_PEEPHOLE)
	{
	  gen_peephole (desc);
	  ++insn_code_number;
	}
      if (GET_CODE (desc) == DEFINE_EXPAND)
	{
	  printf ("VOID extract_%d () {}\n\n", insn_code_number);
	  ++insn_code_number;
	}
    }

  printf ("VOID (*insn_extract_fn[]) () =\n{ ");
  for (i = 0; i < insn_code_number; i++)
    {
      if (i % 4 != 0)
	printf (", ");
      else if (i != 0)
	printf (",\n  ");
      printf ("extract_%d", i);
    }
  printf ("\n};\n\n");

  printf ("void\ninsn_extract (insn)\n");
  printf ("     rtx insn;\n");
  printf ("{\n  if (INSN_CODE (insn) == -1) abort ();\n");
  printf ("  (*insn_extract_fn[INSN_CODE (insn)]) (PATTERN (insn));\n}\n");

  fflush (stdout);
  exit (ferror (stdout) != 0 ? FATAL_EXIT_CODE : SUCCESS_EXIT_CODE);
}
