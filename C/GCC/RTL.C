/* Manage RTL for C-Compiler
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


/* This file contains the low level primitives for allocating,
   printing and reading rtl expressions and vectors.
   It also contains some functions for semantic analysis
   on rtl expressions.  */

#include "config.h"
#include <ctype.h>
#include <stdio.h>
#include "rtl.h"

#include "obstack.h"
#define	obstack_chunk_alloc	xmalloc
#define	obstack_chunk_free	free
extern int xmalloc ();
extern void free ();

/* Obstack used for allocating RTL objects.
   Between functions, this is the permanent_obstack.
   While parsing and expanding a function, this is maybepermanent_obstack
   so we can save it if it is an inline function.
   During optimization and output, this is temporary_obstack.  */

extern struct obstack *rtl_obstack;

#define MIN(x,y) ((x < y) ? x : y)

extern long ftell();

/* Indexed by rtx code, gives number of operands for an rtx with that code.
   Does NOT include rtx header data (code and links).
   This array is initialized in init_rtx.  */

int rtx_length[NUM_RTX_CODE + 1];

/* Indexed by rtx code, gives the name of that kind of rtx, as a C string.  */

#define DEF_RTL_EXPR(ENUM, NAME, FORMAT)   NAME ,

char *rtx_name[] = {
#include "rtl.def"		/* rtl expressions are documented here */
};

#undef DEF_RTL_EXPR

/* Indexed by machine mode, gives the name of that machine mode.
   This name does not include the letters "mode".  */

#define DEF_MACHMODE(SYM, NAME, CLASS, SIZE, UNIT)  NAME,

char *mode_name[] = {
#include "machmode.def"
};

#undef DEF_MACHMODE

/* Indexed by machine mode, gives the length of the mode, in bytes.
   GET_MODE_CLASS uses this.  */

#define DEF_MACHMODE(SYM, NAME, CLASS, SIZE, UNIT)  CLASS,

enum mode_class mode_class[] = {
#include "machmode.def"
};

#undef DEF_MACHMODE

/* Indexed by machine mode, gives the length of the mode, in bytes.
   GET_MODE_SIZE uses this.  */

#define DEF_MACHMODE(SYM, NAME, CLASS, SIZE, UNIT)  SIZE,

int mode_size[] = {
#include "machmode.def"
};

#undef DEF_MACHMODE

/* Indexed by machine mode, gives the length of the mode's subunit.
   GET_MODE_UNIT_SIZE uses this.  */

#define DEF_MACHMODE(SYM, NAME, CLASS, SIZE, UNIT)  UNIT,

int mode_unit_size[] = {
#include "machmode.def"		/* machine modes are documented here */
};

#undef DEF_MACHMODE

/* Indexed by rtx code, gives a sequence of operand-types for
   rtx's of that code.  The sequence is a C string in which
   each charcter describes one operand.  */

char *rtx_format[] = {
  /* "*" undefined.
         can cause a warning message
     "0" field is unused (or used in a phase-dependent manner)
         prints nothing
     "i" an integer
         prints the integer
     "s" a pointer to a string
         prints the string
     "e" a pointer to an rtl expression
         prints the expression
     "E" a pointer to a vector that points to a number of rtl expressions
         prints a list of the rtl expressions
     "u" a pointer to another insn
         prints the uid of the insn.  */

#define DEF_RTL_EXPR(ENUM, NAME, FORMAT)   FORMAT ,
#include "rtl.def"		/* rtl expressions are defined here */
#undef DEF_RTL_EXPR
};

/* Allocate an rtx vector of N elements.
   Store the length, and initialize all elements to zero.  */

rtvec
rtvec_alloc (n)
     int n;
{
  rtvec rt;
  int i;

  rt = (rtvec) obstack_alloc (rtl_obstack,
			      sizeof (struct rtvec_def)
			      + (( n - 1) * sizeof (rtunion)));

  /* clear out the vector */
  PUT_NUM_ELEM(rt, n);
  for (i=0; i < n; i++)
    rt->elem[i].rtvec = NULL;	/* @@ not portable due to rtunion */

  return rt;
}

/* Allocate an rtx of code CODE.  The CODE is stored in the rtx;
   all the rest is initialized to zero.  */

rtx
rtx_alloc (code)
  RTX_CODE code;
{
  rtx rt;
  register int nelts = GET_RTX_LENGTH (code);
  register int length = sizeof (struct rtx_def)
    + (nelts - 1) * sizeof (rtunion);

  rt = (rtx) obstack_alloc (rtl_obstack, length);

  * (int *) rt = 0;
  PUT_CODE (rt, code);

  return rt;
}

/* Create a new copy of an rtx.
   Recursively copies the operands of the rtx,
   except for those few rtx codes that are sharable.  */

rtx
copy_rtx (orig)
     register rtx orig;
{
  register rtx copy;
  register int i, j;
  register RTX_CODE code;
  register char *format_ptr;

  code = GET_CODE (orig);

  switch (code)
    {
    case REG:
    case QUEUED:
    case CONST_INT:
    case CONST_DOUBLE:
    case SYMBOL_REF:
    case CODE_LABEL:
    case PC:
    case CC0:
      return orig;
    }

  copy = rtx_alloc (code);
  PUT_MODE (copy, GET_MODE (orig));
  copy->in_struct = orig->in_struct;
  copy->volatil = orig->volatil;
  copy->unchanging = orig->unchanging;
  copy->integrated = orig->integrated;
  
  format_ptr = GET_RTX_FORMAT (GET_CODE (copy));

  for (i = 0; i < GET_RTX_LENGTH (GET_CODE (copy)); i++)
    {
      switch (*format_ptr++)
	{
	case 'e':
	  XEXP (copy, i) = copy_rtx (XEXP (orig, i));
	  break;

	case 'E':
	  XVEC (copy, i) = XVEC (orig, i);
	  if (XVEC (orig, i) != NULL)
	    {
	      XVEC (copy, i) = rtvec_alloc (XVECLEN (orig, i));
	      for (j = 0; j < XVECLEN (copy, i); j++)
		XVECEXP (copy, i, j) = copy_rtx (XVECEXP (orig, i, j));
	    }
	  break;

	default:
	  XINT (copy, i) = XINT (orig, i);
	  break;
	}
    }
  return copy;
}

/* Return 1 if the value of X is unstable
   (would be different at a different point in the program).
   The frame pointer, arg pointer, etc. are considered stable
   (within one function) and so is anything marked `unchanging'.  */

int
rtx_unstable_p (x)
     rtx x;
{
  register RTX_CODE code = GET_CODE (x);
  register int i;
  register char *fmt;

  if (code == MEM)
    return ! x->unchanging;

  if (code == QUEUED)
    return 1;

  if (code == CONST || code == CONST_INT)
    return 0;

  if (code == REG)
    return ! (REGNO (x) == FRAME_POINTER_REGNUM
	      || REGNO (x) == ARG_POINTER_REGNUM
	      || x->unchanging);

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    if (fmt[i] == 'e')
      if (rtx_unstable_p (XEXP (x, i)))
	return 1;
  return 0;
}

/* Return 1 if X has a value that can vary even between two
   executions of the program.  0 means X can be compared reliably
   against certain constants or near-constants.
   The frame pointer and the arg pointer are considered constant.  */

int
rtx_varies_p (x)
     rtx x;
{
  register RTX_CODE code = GET_CODE (x);
  register int i;
  register char *fmt;

  if (code == MEM)
    return 1;

  if (code == QUEUED)
    return 1;

  if (code == CONST || code == CONST_INT)
    return 0;

  if (code == REG)
    return ! (REGNO (x) == FRAME_POINTER_REGNUM
	      || REGNO (x) == ARG_POINTER_REGNUM);

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    if (fmt[i] == 'e')
      if (rtx_varies_p (XEXP (x, i)))
	return 1;
  return 0;
}

/* Return 1 if X refers to a memory location whose address 
   cannot be compared reliably with constant addresses,
   or if X refers to a BLKmode memory object.  */

int
rtx_addr_varies_p (x)
     rtx x;
{
  register RTX_CODE code = GET_CODE (x);
  register int i;
  register char *fmt;

  if (code == MEM)
    return GET_MODE (x) == BLKmode || rtx_varies_p (XEXP (x, 0));

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    if (fmt[i] == 'e')
      if (rtx_addr_varies_p (XEXP (x, i)))
	return 1;
  return 0;
}

/* Nonzero if register REG appears somewhere within IN.
   Also works if REG is not a register; in this case it checks
   for a subexpression of IN that is Lisp "equal" to REG.  */

int
reg_mentioned_p (reg, in)
     register rtx reg, in;
{
  register char *fmt;
  register int i;
  register enum rtx_code code;

  if (in == 0)
    return 0;

  if (reg == in)
    return 1;

  code = GET_CODE (in);

  switch (code)
    {
      /* Compare registers by number.  */
    case REG:
      return GET_CODE (reg) == REG && REGNO (in) == REGNO (reg);

      /* These codes have no constituent expressions
	 and are unique.  */
    case CC0:
    case PC:
    case CONST_INT:
    case CONST:
    case CONST_DOUBLE:
    case LABEL_REF:
    case SYMBOL_REF:
      return 0;
    }

  if (GET_CODE (reg) == code && rtx_equal_p (reg, in))
    return 1;

  fmt = GET_RTX_FORMAT (code);

  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      if (fmt[i] == 'E')
	{
	  register int j;
	  for (j = XVECLEN (in, i) - 1; j >= 0; j--)
	    if (reg_mentioned_p (reg, XVECEXP (in, i, j)))
	      return 1;
	}
      else if (fmt[i] == 'e'
	       && reg_mentioned_p (reg, XEXP (in, i)))
	return 1;
    }
  return 0;
}

/* Nonzero if register REG is used in an insn between
   FROM_INSN and TO_INSN (exclusive of those two).  */

int
reg_used_between_p (reg, from_insn, to_insn)
     rtx reg, from_insn, to_insn;
{
  register rtx insn;
  register RTX_CODE code;
  for (insn = NEXT_INSN (from_insn); insn != to_insn; insn = NEXT_INSN (insn))
    if (((code = GET_CODE (insn)) == INSN
	 || code == JUMP_INSN || code == CALL_INSN)
	&& reg_mentioned_p (reg, PATTERN (insn)))
      return 1;
  return 0;
}

/* Return 1 if X and Y are identical-looking rtx's.
   This is the Lisp function EQUAL for rtx arguments.  */

int
rtx_equal_p (x, y)
     rtx x, y;
{
  register int i;
  register int hash = 0;
  register RTX_CODE code = GET_CODE (x);
  register char *fmt;

  if (x == y)
    return 1;

  /* Rtx's of different codes cannot be equal.  */
  if (code != GET_CODE (y))
    return 0;

  /* (MULT:SI x y) and (MULT:HI x y) are NOT equivalent.
     (REG:SI x) and (REG:HI x) are NOT equivalent.  */

  if (GET_MODE (x) != GET_MODE (y))
    return 0;

  /* These three types of rtx's can be compared nonrecursively.  */
  if (code == REG)
    return (REGNO (x) == REGNO (y));
  if (code == LABEL_REF)
    return XEXP (x, 0) == XEXP (y, 0);
  if (code == SYMBOL_REF)
    return XSTR (x, 0) == XSTR (y, 0);

  /* Compare the elements.  If any pair of corresponding elements
     fail to match, return 0 for the whole things.  */

  fmt = GET_RTX_FORMAT (code);
  for (i = GET_RTX_LENGTH (code) - 1; i >= 0; i--)
    {
      switch (fmt[i])
	{
	case 'i':
	  if (XINT (x, i) != XINT (y, i))
	    return 0;
	  break;

	case 'e':
	  if (rtx_equal_p (XEXP (x, i), XEXP (y, i)) == 0)
	    return 0;
	  break;

	case 's':
	  if (strcmp (XSTR (x, i), XSTR (y, i)))
	    return 0;
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
  return 1;
}

/* Call FUN on each register or MEM that is stored into or clobbered by X.
   (X would be the pattern of an insn).
   FUN receives two arguments:
     the REG, MEM, CC0 or PC being stored in or clobbered,
     the SET or CLOBBER rtx that does the store.  */
     
void
note_stores (x, fun)
     register rtx x;
     void (*fun) ();
{
  if ((GET_CODE (x) == SET || GET_CODE (x) == CLOBBER))
    {
      register rtx dest = SET_DEST (x);
      while (GET_CODE (dest) == SUBREG
	     || GET_CODE (dest) == ZERO_EXTRACT
	     || GET_CODE (dest) == SIGN_EXTRACT
	     || GET_CODE (dest) == STRICT_LOW_PART)
	dest = XEXP (dest, 0);
      (*fun) (dest, GET_CODE (x) == CLOBBER);
    }
  else if (GET_CODE (x) == PARALLEL)
    {
      register int i;
      for (i = XVECLEN (x, 0) - 1; i >= 0; i--)
	{
	  register rtx y = XVECEXP (x, 0, i);
	  if (GET_CODE (y) == SET || GET_CODE (y) == CLOBBER)
	    {
	      register rtx dest = SET_DEST (y);
	      while (GET_CODE (dest) == SUBREG
		     || GET_CODE (dest) == ZERO_EXTRACT
		     || GET_CODE (dest) == SIGN_EXTRACT
		     || GET_CODE (dest) == STRICT_LOW_PART)
		dest = XEXP (dest, 0);
	      (*fun) (dest, GET_CODE (y) == CLOBBER);
	    }
	}
    }
}

/* Return nonzero if register REG's old contents don't survive after INSN.
   This can be because REG dies in INSN or because INSN entirely sets REG.

   "Entirely set" means set directly and not through a SUBREG,
   ZERO_EXTRACT or SIGN_EXTRACT, so no trace of the old contents remains.

   REG may be a hard or pseudo reg.  Renumbering is not taken into account,
   but for this use that makes no difference, since regs don't overlap
   during their lifetimes.  Therefore, this function may be used
   at any time after deaths have been computed (in flow.c).  */

int
dead_or_set_p (insn, reg)
     rtx insn;
     rtx reg;
{
  register rtx link;
  register int regno = REGNO (reg);

  for (link = REG_NOTES (insn); link; link = XEXP (link, 1))
    if ((REG_NOTE_KIND (link) == REG_DEAD
	 || REG_NOTE_KIND (link) == REG_INC)
	&& REGNO (XEXP (link, 0)) == regno)
      return 1;

  if (GET_CODE (PATTERN (insn)) == SET)
    return SET_DEST (PATTERN (insn)) == reg;
  else if (GET_CODE (PATTERN (insn)) == PARALLEL)
    {
      register int i;
      for (i = XVECLEN (PATTERN (insn), 0) - 1; i >= 0; i--)
	{
	  if (GET_CODE (XVECEXP (PATTERN (insn), 0, i)) == SET
	      && SET_DEST (XVECEXP (PATTERN (insn), 0, i)) == reg)
	    return 1;
	}
    }
  return 0;
}

/* Return the reg-note of kind KIND in insn INSN, if there is one.
   If DATUM is nonzero, look for one whose datum is DATUM.  */

rtx
find_reg_note (insn, kind, datum)
     rtx insn;
     enum reg_note kind;
     rtx datum;
{
  register rtx link;

  for (link = REG_NOTES (insn); link; link = XEXP (link, 1))
    if (REG_NOTE_KIND (link) == kind
	&& (datum == 0 || datum == XEXP (link, 0)))
      return link;
  return 0;
}

/* Return the reg-note of kind KIND in insn INSN which applies to register
   number REGNO, if any.  Return 0 if there is no such reg-note.  */

rtx
find_regno_note (insn, kind, regno)
     rtx insn;
     enum reg_note kind;
     int regno;
{
  register rtx link;

  for (link = REG_NOTES (insn); link; link = XEXP (link, 1))
    if (REG_NOTE_KIND (link) == kind
	&& REGNO (XEXP (link, 0)) == regno)
      return link;
  return 0;
}

/* Printing rtl for debugging dumps.  */

static FILE *outfile;

char spaces[] = "                                                                                                                                                                ";

static int sawclose = 0;

/* Print IN_RTX onto OUTFILE.  This is the recursive part of printing.  */

static void
print_rtx (in_rtx)
     register rtx in_rtx;
{
  static int indent;
  register int i, j;
  register char *format_ptr;

  if (sawclose)
    {
      fprintf (outfile, "\n%s",
	       (spaces + (sizeof spaces - indent * 2)));
      sawclose = 0;
    }

  if (in_rtx == 0)
    {
      fprintf (outfile, "(nil)");
      sawclose = 1;
      return;
    }

  /* print name of expression code */
  fprintf (outfile, "(%s", GET_RTX_NAME (GET_CODE (in_rtx)));

  if (in_rtx->in_struct)
    fprintf (outfile, "/s");

  if (in_rtx->volatil)
    fprintf (outfile, "/v");

  if (in_rtx->unchanging)
    fprintf (outfile, "/u");

  if (in_rtx->integrated)
    fprintf (outfile, "/i");

  if (GET_MODE (in_rtx) != VOIDmode)
    fprintf (outfile, ":%s", GET_MODE_NAME (GET_MODE (in_rtx)));

  format_ptr = GET_RTX_FORMAT (GET_CODE (in_rtx));

  for (i = 0; i < GET_RTX_LENGTH (GET_CODE (in_rtx)); i++)
    switch (*format_ptr++)
      {
      case 's':
	if (XSTR (in_rtx, i) == 0)
	  fprintf (outfile, " \"\"");
	else
	  fprintf (outfile, " (\"%s\")", XSTR (in_rtx, i));
	sawclose = 1;
	break;

	/* 0 indicates a field for internal use that should not be printed.  */
      case '0':
	break;

      case 'e':
	indent += 2;
	if (!sawclose)
	  fprintf (outfile, " ");
	print_rtx (XEXP (in_rtx, i));
	indent -= 2;
	break;

      case 'E':
	indent += 2;
	if (sawclose)
	  {
	    fprintf (outfile, "\n%s",
		     (spaces + (sizeof spaces - indent * 2)));
	    sawclose = 0;
	  }
	fprintf (outfile, "[ ");
	if (NULL != XVEC (in_rtx, i))
	  {
	    indent += 2;
	    if (XVECLEN (in_rtx, i))
	      sawclose = 1;

	    for (j = 0; j < XVECLEN (in_rtx, i); j++)
	      print_rtx (XVECEXP (in_rtx, i, j));

	    indent -= 2;
	  }
	if (sawclose)
	  fprintf (outfile, "\n%s",
		   (spaces + (sizeof spaces - indent * 2)));

	fprintf (outfile, "] ");
	sawclose = 1;
	indent -= 2;
	break;

      case 'i':
	fprintf (outfile, " %d", XINT (in_rtx, i));
	sawclose = 0;
	break;

      case 'u':
	if (XEXP (in_rtx, i) != NULL)
	  fprintf(outfile, " %d", INSN_UID (XEXP (in_rtx, i)));
	else
	  fprintf(outfile, " 0");
	sawclose = 0;
	break;

      default:
	fprintf (stderr,
		 "switch format wrong in rtl.print_rtx(). format was: %c.\n",
		 format_ptr[-1]);
	abort ();
      }

  fprintf (outfile, ")");
  sawclose = 1;
}

/* Call this function from the debugger to see what X looks like.  */

void
debug_rtx (x)
     rtx x;
{
  outfile = stderr;
  print_rtx (x);
  fprintf (stderr, "\n");
}

/* External entry point for printing a chain of INSNs
   starting with RTX_FIRST onto file OUTF.  */

void
print_rtl (outf, rtx_first)
     FILE *outf;
     rtx rtx_first;
{
  register rtx tmp_rtx;

  outfile = outf;
  sawclose = 0;

  for (tmp_rtx = rtx_first; NULL != tmp_rtx; tmp_rtx = NEXT_INSN (tmp_rtx))
    {
      print_rtx (tmp_rtx);
      fprintf (outfile, "\n");
    }
}

/* Subroutines of read_rtx.  */

/* Dump code after printing a message.  Used when read_rtx finds
   invalid data.  */

static void
dump_and_abort (expected_c, actual_c, infile)
     int expected_c, actual_c;
     FILE *infile;
{
  int c, i;

  fprintf (stderr,
	   "Expected character %c. Read character %c. At file position: %ld\n",
	   expected_c, actual_c, ftell (infile));
  fprintf (stderr, "Following characters are:\n\t");
  for (i = 0; i < 200; i++)
    {
      c = getc (infile);
      if (EOF == c) break;
      putc (c, stderr);
    }
  fprintf (stderr, "Aborting.\n");
  abort ();
}

/* Read chars from INFILE until a non-whitespace char
   and return that.  Comments, both Lisp style and C style,
   are treated as whitespace.
   Tools such as genflags use this function.  */

int
read_skip_spaces (infile)
     FILE *infile;
{
  register int c;
  while (c = getc (infile))
    {
      if (c == ' ' || c == '\n' || c == '\t' || c == '\f')
	;
      else if (c == ';')
	{
	  while ((c = getc (infile)) && c != '\n') ;
	}
      else if (c == '/')
	{
	  register int prevc;
	  c = getc (infile);
	  if (c != '*')
	    dump_and_abort ('*', c, infile);
	  
	  prevc = 0;
	  while (c = getc (infile))
	    {
	      if (prevc == '*' && c == '/')
		break;
	      prevc = c;
	    }
	}
      else break;
    }
  return c;
}

/* Read an rtx code name into the buffer STR[].
   It is terminated by any of the punctuation chars of rtx printed syntax.  */

static void
read_name (str, infile)
     char *str;
     FILE *infile;
{
  register char *p;
  register int c;

  c = read_skip_spaces(infile);

  p = str;
  while (1)
    {
      if (c == ' ' || c == '\n' || c == '\t' || c == '\f')
	break;
      if (c == ':' || c == ')' || c == ']' || c == '"' || c == '/'
	  || c == '(' || c == '[')
	{
	  ungetc (c, infile);
	  break;
	}
      *p++ = c;
      c = getc (infile);
    }
  *p = NULL;
}

/* Read an rtx in printed representation from INFILE
   and return an actual rtx in core constructed accordingly.
   read_rtx is not used in the compiler proper, but rather in
   the utilities gen*.c that construct C code from machine descriptions.  */

rtx
read_rtx (infile)
     FILE *infile;
{
  register int i, j, list_counter;
  RTX_CODE tmp_code;
  register char *format_ptr;
  /* tmp_char is a buffer used for reading decimal integers
     and names of rtx types and machine modes.
     Therefore, 256 must be enough.  */
  char tmp_char[256];
  rtx return_rtx;
  register int c;
  int tmp_int;

  /* Linked list structure for making RTXs: */
  struct rtx_list
    {
      struct rtx_list *next;
      rtx value;		/* Value of this node...		*/
    };

  c = read_skip_spaces (infile); /* Should be open paren.  */
  if (c != '(')
    dump_and_abort ('(', c, infile);

  read_name (tmp_char, infile);

  tmp_code = UNKNOWN;

  for (i=0; i < NUM_RTX_CODE; i++) /* @@ might speed this search up */
    {
      if (!(strcmp (tmp_char, GET_RTX_NAME (i))))
	{
	  tmp_code = (RTX_CODE) i;	/* get value for name */
	  break;
	}
    }
  if (tmp_code == UNKNOWN)
    {
      fprintf (stderr,
	       "Unknown rtx read in rtl.read_rtx(). Code name was %s .",
	       tmp_char);
    }
  /* (NIL) stands for an expression that isn't there.  */
  if (tmp_code == NIL)
    {
      /* Discard the closeparen.  */
      while ((c = getc (infile)) && c != ')');
      return 0;
    }

  return_rtx = rtx_alloc (tmp_code); /* if we end up with an insn expression
				       then we free this space below.  */
  format_ptr = GET_RTX_FORMAT (GET_CODE (return_rtx));

  /* If what follows is `: mode ', read it and
     store the mode in the rtx.  */

  i = read_skip_spaces (infile);
  if (i == ':')
    {
      register int k;
      read_name (tmp_char, infile);
      for (k = 0; k < NUM_MACHINE_MODES; k++)
	if (!strcmp (GET_MODE_NAME (k), tmp_char))
	  break;

      PUT_MODE (return_rtx, (enum machine_mode) k );
    }
  else
    ungetc (i, infile);

  for (i = 0; i < GET_RTX_LENGTH (GET_CODE (return_rtx)); i++)
    switch (*format_ptr++)
      {
	/* 0 means a field for internal use only.
	   Don't expect it to be present in the input.  */
      case '0':
	break;

      case 'e':
      case 'u':
	XEXP (return_rtx, i) = read_rtx (infile);
	break;

      case 'E':
	{
	  register struct rtx_list *next_rtx, *rtx_list_link;
	  struct rtx_list *list_rtx;

	  c = read_skip_spaces (infile);
	  if (c != '[')
	    dump_and_abort ('[', c, infile);

	  /* add expressions to a list, while keeping a count */
	  next_rtx = NULL;
	  list_counter = 0;
	  while ((c = read_skip_spaces (infile)) && c != ']')
	    {
	      ungetc (c, infile);
	      list_counter++;
	      rtx_list_link = (struct rtx_list *)
		alloca (sizeof (struct rtx_list));
	      rtx_list_link->value = read_rtx (infile);
	      if (next_rtx == 0)
		list_rtx = rtx_list_link;
	      else
		next_rtx->next = rtx_list_link;
	      next_rtx = rtx_list_link;
	      rtx_list_link->next = 0;
	    }
	  /* get vector length and allocate it */
	  XVEC (return_rtx, i) = (list_counter
				  ? rtvec_alloc (list_counter)
				  : NULL);
	  if (list_counter > 0) 
	    {
	      next_rtx = list_rtx;
	      for (j = 0; j < list_counter; j++,
		   next_rtx = next_rtx->next)
		XVECEXP (return_rtx, i, j) = next_rtx->value;
	    }
	  /* close bracket gotten */
	}
	break;

      case 's':
	{
	  int saw_paren = 0;
	  register char *stringbuf;
	  int stringbufsize;

	  c = read_skip_spaces (infile);
	  if (c == '(')
	    {
	      saw_paren = 1;
	      c = read_skip_spaces (infile);
	    }
	  if (c != '"')
	    dump_and_abort ('"', c, infile);
	  j = 0;
	  stringbufsize = 10;
	  stringbuf = (char *) xmalloc (stringbufsize + 1);

	  while (1)
	    {
	      if (j >= stringbufsize - 4)
		{
		  stringbufsize *= 2;
		  stringbuf = (char *) xrealloc (stringbuf, stringbufsize + 1);
		}
	      stringbuf[j] = getc (infile); /* Read the string  */
	      if (stringbuf[j] == '\\')
		{
		  stringbuf[j] = getc (infile);	/* Read the string  */
		  /* \; makes stuff for a C string constant containing
		     newline and tab.  */
		  if (stringbuf[j] == ';')
		    {
		      strcpy (&stringbuf[j], "\\n\\t");
		      j += 3;
		    }
		}
	      else if (stringbuf[j] == '"')
		break;
	      j++;
	    }

	  stringbuf[j] = 0;	/* NUL terminate the string  */
	  stringbuf = (char *) xrealloc (stringbuf, j + 1);

	  if (saw_paren)
	    {
	      c = read_skip_spaces (infile);
	      if (c != ')')
		dump_and_abort (')', c, infile);
	    }
	  XSTR (return_rtx, i) = stringbuf;
	}
	break;

      case 'i':
	read_name (tmp_char, infile);
	tmp_int = atoi (tmp_char);
	XINT (return_rtx, i) = tmp_int;
	break;

      default:
	fprintf (stderr,
		 "switch format wrong in rtl.read_rtx(). format was: %c.\n",
		 format_ptr[-1]);
	fprintf (stderr, "\tfile position: %ld\n", ftell (infile));
	abort ();
      }

  c = read_skip_spaces (infile);
  if (c != ')')
    dump_and_abort (')', c, infile);

  return return_rtx;
}

/* This is called once per compilation, before any rtx's are constructed.
   It initializes the vector `rtx_length'.  */

void
init_rtl ()
{
  int i;

  for (i = 0; i < NUM_RTX_CODE; i++)
    rtx_length[i] = strlen (rtx_format[i]);
}
