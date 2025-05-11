/* Output variables, constants and external declarations, for GNU compiler.
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


/* This file handles generation of all the assembler code
   *except* the instructions of a function.
   This includes declarations of variables and their initial values.

   We also output the assembler code for constants stored in memory
   and are responsible for combining constants with the same value.  */

#include <stdio.h>
/* #include <stab.h> */
#include "config.h"
#include "rtl.h"
#include "tree.h"
#include "flags.h"
#include "expr.h"

#include "obstack.h"

#define MIN(a, b) ((a) < (b) ? (a) : (b))

/* File in which assembler code is being written.  */

extern FILE *asm_out_file;

extern struct obstack *current_obstack;
extern struct obstack *saveable_obstack;
extern struct obstack permanent_obstack;
#define obstack_chunk_alloc xmalloc
extern int xmalloc ();

/* Number for making the label on the next
   constant that is stored in memory.  */

int const_labelno;

/* Number for making the label on the next
   static variable internal to a function.  */

int var_labelno;

extern FILE *asm_out_file;

static char *compare_constant_1 ();
static void record_constant_1 ();
void assemble_name ();
void output_addressed_constants ();
void output_constant ();
void output_constructor ();

/* Output a string of literal assembler code
   for an `asm' keyword used between functions.  */

void
assemble_asm (string)
     tree string;
{
  app_enable ();

  fprintf (asm_out_file, "\t%s\n", TREE_STRING_POINTER (string));
}

/* Output assembler code associated with defining the name of a function
   as described by DECL.  */

void
assemble_function (decl)
     tree decl;
{
  rtx x, n;
  char *fnname;

  /* Get the function's name, as described by its RTL.
     This may be different from the DECL_NAME name used in the source file.  */

  x = DECL_RTL (decl);
  if (GET_CODE (x) != MEM)
    abort ();
  n = XEXP (x, 0);
  if (GET_CODE (n) != SYMBOL_REF)
    abort ();
  fnname = XSTR (n, 0);

  /* The following code does not need preprocessing in the assembler.  */

  app_disable ();

  /* Tell assembler to switch to text segment.  */

  fprintf (asm_out_file, "%s\n", TEXT_SECTION_ASM_OP);

#ifdef SDB_DEBUGGING_INFO
  /* Make sure types are defined for debugger before fcn name is defined.  */
  if (write_symbols == SDB_DEBUG)
    sdbout_tags (gettags ());
#endif

  /* Tell assembler to move to target machine's alignment for functions.  */

  ASM_OUTPUT_ALIGN (asm_out_file, floor_log2 (FUNCTION_BOUNDARY / BITS_PER_UNIT));

#ifdef SDB_DEBUGGING_INFO
  /* Output SDB definition of the function.  */
  if (write_symbols == SDB_DEBUG)
    sdbout_mark_begin_function ();
#endif

  /* Make function name accessible from other files, if appropriate.  */

  if (TREE_PUBLIC (decl))
    ASM_GLOBALIZE_LABEL (asm_out_file, fnname);

  /* Do any machine/system dependent processing of the function name */
#ifdef ASM_DECLARE_FUNCTION_NAME
  ASM_DECLARE_FUNCTION_NAME (asm_out_file, fnname, current_function_decl);
#else
  /* Standard thing is just output label for the function.  */
  ASM_OUTPUT_LABEL (asm_out_file, fnname);
#endif /* ASM_DECLARE_FUNCTION_NAME */
}

/* Assemble " .int 0\n" or whatever this assembler wants.  */

void
assemble_integer_zero ()
{
  ASM_OUTPUT_INT (asm_out_file, const0_rtx);
}

/* Create the rtx to represent a function in calls to it.
   DECL is a FUNCTION_DECL node which describes which function.
   The rtl is stored in DECL.  */

void
make_function_rtl (decl)
     tree decl;
{
  if (DECL_RTL (decl) == 0)
    DECL_RTL (decl)
      = gen_rtx (MEM, DECL_MODE (decl),
		 gen_rtx (SYMBOL_REF, Pmode,
			  IDENTIFIER_POINTER (DECL_NAME (decl))));
}

/* Assemble everything that is needed for a variable or function declaration.
   Not used for automatic variables, and not used for function definitions.
   Should not be called for variables of incomplete structure type.

   ASMSPEC is the user's specification of assembler symbol name to use.
   TOP_LEVEL is nonzero if this variable has file scope.
   WRITE_SYMBOLS is DBX_DEBUG if writing dbx symbol output.
   The dbx data for a file-scope variable is written here.
   AT_END is nonzero if this is the special handling, at end of compilation,
   to define things that have had only tentative definitions.  */

void
assemble_variable (decl, asmspec, top_level, write_symbols, at_end)
     tree decl;
     tree asmspec;
     int top_level;
     enum debugger write_symbols;
     int at_end;
{
  register char *name = IDENTIFIER_POINTER (DECL_NAME (decl));
  register int i;

  if (asmspec != 0)
    {
      if (TREE_CODE (asmspec) != STRING_CST)
	abort ();
      name = (char *) obstack_alloc (saveable_obstack,
				     strlen (TREE_STRING_POINTER (asmspec)) + 2);
      name[0] = '*';
      strcpy (&name[1], TREE_STRING_POINTER (asmspec));
    }

  /* For a duplicate declaration, we can be called twice on the
     same DECL node.  Don't alter the RTL already made
     unless the old mode is wrong (which can happen when
     the previous rtl was made when the type was incomplete).  */
  if (DECL_RTL (decl) == 0
      || GET_MODE (DECL_RTL (decl)) != DECL_MODE (decl))
    {
      if (DECL_RTL (decl) && asmspec == 0)
	name = XSTR (XEXP (DECL_RTL (decl), 0), 0);

      /* Can't use just the variable's own name for a variable
	 whose scope is less than the whole file.
	 Concatenate a distinguishing number.  */
      else if (!top_level && !TREE_EXTERNAL (decl) && asmspec == 0)
	{
	  char *label;

	  ASM_FORMAT_PRIVATE_NAME (label, name, var_labelno);
	  name = obstack_copy0 (saveable_obstack, label, strlen (label));
	  var_labelno++;
	}

      DECL_RTL (decl) = gen_rtx (MEM, DECL_MODE (decl),
				 gen_rtx (SYMBOL_REF, Pmode, name));
      if (TREE_VOLATILE (decl))
	DECL_RTL (decl)->volatil = 1;
      if (TREE_READONLY (decl))
	DECL_RTL (decl)->unchanging = 1;
      DECL_RTL (decl)->in_struct
	= (TREE_CODE (TREE_TYPE (decl)) == ARRAY_TYPE
	   || TREE_CODE (TREE_TYPE (decl)) == RECORD_TYPE
	   || TREE_CODE (TREE_TYPE (decl)) == UNION_TYPE);
    }

  /* Output no assembler code for a function declaration.
     Only definitions of functions output anything.  */

  if (TREE_CODE (decl) == FUNCTION_DECL)
    return;

  /* Normally no need to say anything for external references,
     since assembler considers all undefined symbols external.  */

  if (TREE_EXTERNAL (decl))
    {
#ifdef ASM_OUTPUT_EXTERNAL
      /* Some systems do require some output.  */
      ASM_OUTPUT_EXTERNAL (asm_out_file, decl, name);
#endif
      return;
    }
  /* Don't output anything when a tentative file-scope definition is seen.
     But at end of compilation, do output code for them.  */
  if (! at_end && top_level
      && (DECL_INITIAL (decl) == 0 || DECL_INITIAL (decl) == error_mark_node))
    return;

  /* If type was incomplete when the variable was declared,
     see if it is complete now.  */

  if (DECL_SIZE (decl) == 0)
    layout_decl (decl);

  /* Still incomplete => don't allocate it; treat the tentative defn
     (which is what it must have been) as an `extern' reference.  */

  if (DECL_SIZE (decl) == 0)
    {
      error_with_file_and_line (DECL_SOURCE_FILE (decl),
				DECL_SOURCE_LINE (decl),
				"storage size of static var `%s' isn't known",
				IDENTIFIER_POINTER (DECL_NAME (decl)));
      return;
    }

  /* The first declaration of a variable that comes through this function
     decides whether it is global (in C, has external linkage)
     or local (in C, has internal linkage).  So do nothing more
     if this function has already run.  */

  if (TREE_ASM_WRITTEN (decl))
    return;

  TREE_ASM_WRITTEN (decl) = 1;

#ifdef DBX_DEBUGGING_INFO
  /* File-scope global variables are output here.  */
  if (write_symbols == DBX_DEBUG && top_level)
    dbxout_symbol (decl, 0);
#endif
#ifdef SDB_DEBUGGING_INFO
  if (write_symbols == SDB_DEBUG)
    sdbout_symbol (decl, 0);
#endif
  else if (write_symbols == GDB_DEBUG)
    /* Make sure the file is known to GDB even if it has no functions.  */
    set_current_gdbfile (DECL_SOURCE_FILE (decl));

  /* If storage size is erroneously variable, just continue.
     Error message was already made.  */

  if (! TREE_LITERAL (DECL_SIZE (decl)))
    return;

  app_disable ();

  /* Handle uninitialized definitions.  */

  if (DECL_INITIAL (decl) == 0 || DECL_INITIAL (decl) == error_mark_node)
    {
      int size = (TREE_INT_CST_LOW (DECL_SIZE (decl))
		  * DECL_SIZE_UNIT (decl)
		  / BITS_PER_UNIT);
      /* Round size up to multiple of BIGGEST_ALIGNMENT bits
	 so that each uninitialized object starts on such a boundary.  */
      size = ((size + (BIGGEST_ALIGNMENT / BITS_PER_UNIT) - 1)
	      / (BIGGEST_ALIGNMENT / BITS_PER_UNIT)
	      * (BIGGEST_ALIGNMENT / BITS_PER_UNIT));
      if (TREE_PUBLIC (decl))
	ASM_OUTPUT_COMMON (asm_out_file, name, size);
      else
	ASM_OUTPUT_LOCAL (asm_out_file, name, size);
      return;
    }

  /* Handle initialized definitions.  */

  if (TREE_PUBLIC (decl))
    ASM_GLOBALIZE_LABEL (asm_out_file, name);

  output_addressed_constants (DECL_INITIAL (decl));

  if (TREE_READONLY (decl) && ! TREE_VOLATILE (decl))
    fprintf (asm_out_file, "%s\n", TEXT_SECTION_ASM_OP);
  else
    fprintf (asm_out_file, "%s\n", DATA_SECTION_ASM_OP);

  for (i = 0; DECL_ALIGN (decl) >= BITS_PER_UNIT << (i + 1); i++);

  ASM_OUTPUT_ALIGN (asm_out_file, i);

  ASM_OUTPUT_LABEL (asm_out_file, name);
  output_constant (DECL_INITIAL (decl), int_size_in_bytes (TREE_TYPE (decl)));
}

/* Output to FILE a reference to the assembler name of a C-level name NAME.
   If NAME starts with a *, the rest of NAME is output verbatim.
   Otherwise NAME is transformed in an implementation-defined way
   (usually by the addition of an underscore).
   Many macros in the tm file are defined to call this function.  */

void
assemble_name (file, name)
     FILE *file;
     char *name;
{
  if (name[0] == '*')
    fputs (&name[1], file);
  else
    ASM_OUTPUT_LABELREF (file, name);
}

/* Here we combine duplicate floating constants to make
   CONST_DOUBLE rtx's, and force those out to memory when necessary.  */

/* Chain of all CONST_DOUBLE rtx's constructed for the current function.
   They are chained through the third operand slot.  */

extern rtx real_constant_chain;

/* Return a CONST_DOUBLE for a specified `double' value
   and machine mode.  */

rtx
immed_real_const_1 (d, mode)
     double d;
     enum machine_mode mode;

{
  register rtx r;
  union {double d; int i[2];} u;
  register int i0, i1;

  /* Get the desired `double' value as two ints
     since that is how they are stored in a CONST_DOUBLE.  */

  u.d = d;
  i0 = u.i[0];
  i1 = u.i[1];

  /* Search the chain for an existing CONST_DOUBLE with the right value.
     If one is found, return it.  */

  for (r = real_constant_chain; r; r = XEXP (r, 3))
    if (XINT (r, 0) == i0 && XINT (r, 1) == i1
	&& GET_MODE (r) == mode)
      return r;

  /* No; make a new one and add it to the chain.  */

  r = gen_rtx (CONST_DOUBLE, mode, i0, i1, 0);
  XEXP (r, 3) = real_constant_chain;
  real_constant_chain = r;

  /* Store const0_rtx in slot 2 just so most things won't barf.
     Actual use of slot 2 is only through force_const_double_mem.  */

  XEXP (r, 2) = const0_rtx;

  return r;
}

/* Return a CONST_DOUBLE rtx for a value specified by EXP,
   which must be a REAL_CST tree node.  Make only one CONST_DOUBLE
   for each distinct value.  */

rtx
immed_real_const (exp)
     tree exp;
{
  register rtx r;
  r = immed_real_const_1 (TREE_REAL_CST (exp), TYPE_MODE (TREE_TYPE (exp)));

  /* Associate exp and with this rtl value.  */
  TREE_CST_RTL (exp) = r;

  return r;
}

/* Given a CONST_DOUBLE, cause a constant in memory to be created
   (unless we already have one for the same value)
   and return a MEM rtx to refer to it.  */

rtx
force_const_double_mem (r)
     rtx r;
{
  if (XEXP (r, 2) == const0_rtx)
    {
      XEXP (r, 2) = force_const_mem (GET_MODE (r), r);
    }
  /* XEXP (r, 2) is now a MEM with a constant address.
     If that is legitimate, return it.
     Othewise it will need reloading, so return a copy of it.  */
  if (memory_address_p (GET_MODE (r), XEXP (XEXP (r, 2), 0)))
    return XEXP (r, 2);
  return gen_rtx (MEM, GET_MODE (r), XEXP (XEXP (r, 2), 0));
}

/* At the start of a function, forget the memory-constants
   previously made for CONST_DOUBLEs.  */

static void
clear_const_double_mem ()
{
  register rtx r;

  for (r = real_constant_chain; r; r = XEXP (r, 3))
    XEXP (r, 2) = 0;
}

/* Given an expression EXP with a constant value,
   reduce it to the sum of an assembler symbol and an integer.
   Store them both in the structure *VALUE.
   Abort if EXP does not reduce.  */

struct addr_const
{
  rtx base;
  int offset;
};

static void
decode_addr_const (exp, value)
     tree exp;
     struct addr_const *value;
{
  register tree target = TREE_OPERAND (exp, 0);
  register int offset = 0;
  register rtx x;

  while (1)
    {
      if (TREE_CODE (target) == COMPONENT_REF)
	{
	  offset += DECL_OFFSET (TREE_OPERAND (target, 1)) / BITS_PER_UNIT;
	  target = TREE_OPERAND (target, 0);
	}
      else if (TREE_CODE (target) == ARRAY_REF)
	{
	  if (TREE_CODE (TREE_OPERAND (target, 1)) != INTEGER_CST
	      || TREE_CODE (TYPE_SIZE (TREE_TYPE (target))) != INTEGER_CST)
	    abort ();
	  offset += ((TYPE_SIZE_UNIT (TREE_TYPE (target))
		      * TREE_INT_CST_LOW (TYPE_SIZE (TREE_TYPE (target)))
		      * TREE_INT_CST_LOW (TREE_OPERAND (target, 1)))
		     / BITS_PER_UNIT);
	  target = TREE_OPERAND (target, 0);
	}
      else break;
    }

  if (TREE_CODE (target) == VAR_DECL
      || TREE_CODE (target) == FUNCTION_DECL)
    x = DECL_RTL (target);
  else if (TREE_LITERAL (target))
    x = TREE_CST_RTL (target);
  else
    abort ();

  if (GET_CODE (x) != MEM)
    abort ();
  x = XEXP (x, 0);

  value->base = x;
  value->offset = offset;
}

/* Uniquize all constants that appear in memory.
   Each constant in memory thus far output is recorded
   in `const_hash_table' with a `struct constant_descriptor'
   that contains a polish representation of the value of
   the constant.

   We cannot store the trees in the hash table
   because the trees may be temporary.  */

struct constant_descriptor
{
  struct constant_descriptor *next;
  char *label;
  char contents[1];
};

#define HASHBITS 30
#define MAX_HASH_TABLE 1007
static struct constant_descriptor *const_hash_table[MAX_HASH_TABLE];

/* Compute a hash code for a constant expression.  */

int
const_hash (exp)
     tree exp;
{
  register char *p;
  register int len, hi, i;
  register enum tree_code code = TREE_CODE (exp);

  if (code == INTEGER_CST)
    {
      p = (char *) &TREE_INT_CST_LOW (exp);
      len = 2 * sizeof TREE_INT_CST_LOW (exp);
    }
  else if (code == REAL_CST)
    {
      p = (char *) &TREE_REAL_CST (exp);
      len = sizeof TREE_REAL_CST (exp);
    }
  else if (code == STRING_CST)
    p = TREE_STRING_POINTER (exp), len = TREE_STRING_LENGTH (exp);
  else if (code == COMPLEX_CST)
    return const_hash (TREE_REALPART (exp)) * 5
      + const_hash (TREE_IMAGPART (exp));
  else if (code == CONSTRUCTOR)
    {
      register tree link;
      hi = 5;
      for (link = CONSTRUCTOR_ELTS (exp); link; link = TREE_CHAIN (link))
	hi = (hi * 603 + const_hash (TREE_VALUE (link))) % MAX_HASH_TABLE;
      return hi;
    }
  else if (code == ADDR_EXPR)
    {
      struct addr_const value;
      decode_addr_const (exp, &value);
      p = (char *) &value;
      len = sizeof value;
    }
  else if (code == PLUS_EXPR || code == MINUS_EXPR)
    return const_hash (TREE_OPERAND (exp, 0)) * 9
      +  const_hash (TREE_OPERAND (exp, 1));
  else if (code == NOP_EXPR || code == CONVERT_EXPR)
    return const_hash (TREE_OPERAND (exp, 0)) * 7 + 2;

  /* Compute hashing function */
  hi = len;
  for (i = 0; i < len; i++)
    hi = ((hi * 613) + (unsigned)(p[i]));

  hi &= (1 << HASHBITS) - 1;
  hi %= MAX_HASH_TABLE;
  return hi;
}

/* Compare a constant expression EXP with a constant-descriptor DESC.
   Return 1 if DESC describes a constant with the same value as EXP.  */

static int
compare_constant (exp, desc)
     tree exp;
     struct constant_descriptor *desc;
{
  return 0 != compare_constant_1 (exp, desc->contents);
}

/* Compare constant expression EXP with a substring P of a constant descriptor.
   If they match, return a pointer to the end of the substring matched.
   If they do not match, return 0.

   Since descriptors are written in polish prefix notation,
   this function can be used recursively to test one operand of EXP
   against a subdescriptor, and if it succeeds it returns the
   address of the subdescriptor for the next operand.  */

static char *
compare_constant_1 (exp, p)
     tree exp;
     char *p;
{
  register char *strp;
  register int len;
  register enum tree_code code = TREE_CODE (exp);

  if (code != (enum tree_code) *p++)
    return 0;

  if (code == INTEGER_CST)
    {
      strp = (char *) &TREE_INT_CST_LOW (exp);
      len = 2 * sizeof TREE_INT_CST_LOW (exp);
    }
  else if (code == REAL_CST)
    {
      /* Real constants are the same only if the same width of type.  */
      if (*p++ != TYPE_PRECISION (TREE_TYPE (exp)))
	return 0;
      strp = (char *) &TREE_REAL_CST (exp);
      len = sizeof TREE_REAL_CST (exp);
    }
  else if (code == STRING_CST)
    {
      if (flag_writable_strings)
	return 0;
      strp = TREE_STRING_POINTER (exp);
      len = TREE_STRING_LENGTH (exp);
      if (bcmp (&TREE_STRING_LENGTH (exp), p,
		sizeof TREE_STRING_LENGTH (exp)))
	return 0;
      p += sizeof TREE_STRING_LENGTH (exp);
    }
  else if (code == COMPLEX_CST)
    {
      p = compare_constant_1 (TREE_REALPART (exp), p);
      if (p == 0) return 0;
      p = compare_constant_1 (TREE_IMAGPART (exp), p);
      return p;
    }
  else if (code == CONSTRUCTOR)
    {
      register tree link;
      int length = list_length (CONSTRUCTOR_ELTS (exp));
      if (bcmp (&length, p, sizeof length))
	return 0;
      p += sizeof length;
      for (link = CONSTRUCTOR_ELTS (exp); link; link = TREE_CHAIN (link))
	if ((p = compare_constant_1 (TREE_VALUE (link), p)) == 0)
	  return 0;
      return p;
    }
  else if (code == ADDR_EXPR)
    {
      struct addr_const value;
      decode_addr_const (exp, &value);
      strp = (char *) &value;
      len = sizeof value;
    }
  else if (code == PLUS_EXPR || code == MINUS_EXPR)
    {
      if (*p++ != (char) code)
	return 0;
      p = compare_constant_1 (TREE_OPERAND (exp, 0), p);
      if (p == 0) return 0;
      p = compare_constant_1 (TREE_OPERAND (exp, 1), p);
      return p;
    }
  else if (code == NOP_EXPR || code == CONVERT_EXPR)
    {
      if (*p++ != (char) code)
	return 0;
      p = compare_constant_1 (TREE_OPERAND (exp, 0), p);
      return p;
    }

  /* Compare constant contents.  */
  while (--len >= 0)
    if (*p++ != *strp++)
      return 0;

  return p;
}

/* Construct a constant descriptor for the expression EXP.
   It is up to the caller to enter the descriptor in the hash table.  */

static struct constant_descriptor *
record_constant (exp)
     tree exp;
{
  struct constant_descriptor *ptr = 0;
  int buf;

  obstack_grow (&permanent_obstack, &ptr, sizeof ptr);
  obstack_grow (&permanent_obstack, &buf, sizeof buf);
  record_constant_1 (exp);
  return (struct constant_descriptor *) obstack_finish (&permanent_obstack);
}

/* Add a description of constant expression EXP
   to the object growing in `permanent_obstack'.
   No need to return its address; the caller will get that
   from the obstack when the object is complete.  */

static void
record_constant_1 (exp)
     tree exp;
{
  register char *strp;
  register int len;
  register enum tree_code code = TREE_CODE (exp);

  obstack_1grow (&permanent_obstack, (unsigned char) code);

  if (code == INTEGER_CST)
    {
      strp = (char *) &TREE_INT_CST_LOW (exp);
      len = 2 * sizeof TREE_INT_CST_LOW (exp);
    }
  else if (code == REAL_CST)
    {
      obstack_1grow (&permanent_obstack, TYPE_PRECISION (TREE_TYPE (exp)));
      strp = (char *) &TREE_REAL_CST (exp);
      len = sizeof TREE_REAL_CST (exp);
    }
  else if (code == STRING_CST)
    {
      if (flag_writable_strings)
	return;
      strp = TREE_STRING_POINTER (exp);
      len = TREE_STRING_LENGTH (exp);
      obstack_grow (&permanent_obstack, (char *) &TREE_STRING_LENGTH (exp),
		    sizeof TREE_STRING_LENGTH (exp));
    }
  else if (code == COMPLEX_CST)
    {
      record_constant_1 (TREE_REALPART (exp));
      record_constant_1 (TREE_IMAGPART (exp));
      return;
    }
  else if (code == CONSTRUCTOR)
    {
      register tree link;
      int length = list_length (CONSTRUCTOR_ELTS (exp));
      obstack_grow (&permanent_obstack, (char *) &length, sizeof length);

      for (link = CONSTRUCTOR_ELTS (exp); link; link = TREE_CHAIN (link))
	record_constant_1 (TREE_VALUE (link));
      return;
    }
  else if (code == ADDR_EXPR)
    {
      struct addr_const value;
      decode_addr_const (exp, &value);
      strp = (char *) &value;
      len = sizeof value;
    }
  else if (code == PLUS_EXPR || code == MINUS_EXPR)
    {
      obstack_1grow (&permanent_obstack, (char) code);
      record_constant_1 (TREE_OPERAND (exp, 0));
      record_constant_1 (TREE_OPERAND (exp, 1));
      return;
    }
  else if (code == NOP_EXPR || code == CONVERT_EXPR)
    {
      obstack_1grow (&permanent_obstack, (char) code);
      record_constant_1 (TREE_OPERAND (exp, 0));
      return;
    }

  /* Record constant contents.  */
  obstack_grow (&permanent_obstack, strp, len);
}

/* Return the constant-label-string for constant value EXP.
   If no constant equal to EXP has yet been output,
   define a new label and output assembler code for it.
   The const_hash_table records which constants already have label strings.  */

static char *
get_or_assign_label (exp)
     tree exp;
{
  register int hash, i;
  register struct constant_descriptor *desc;
  char label[10];

  /* Make sure any other constants whose addresses appear in EXP
     are assigned label numbers.  */

  output_addressed_constants (exp);

  /* Compute hash code of EXP.  Search the descriptors for that hash code
     to see if any of them describes EXP.  If yes, the descriptor records
     the label number already assigned.  */

  hash = const_hash (exp) % MAX_HASH_TABLE;

  for (desc = const_hash_table[hash]; desc; desc = desc->next)
    if (compare_constant (exp, desc))
      return desc->label;

  /* No constant equal to EXP is known to have been output.
     Make a constant descriptor to enter EXP in the hash table.
     Assign the label number and record it in the descriptor for
     future calls to this function to find.  */

  desc = record_constant (exp);
  desc->next = const_hash_table[hash];
  const_hash_table[hash] = desc;

  /* Now output assembler code to define that label
     and follow it with the data of EXP.  */

  /* First switch to text segment, except for writable strings.  */
  if ((TREE_CODE (exp) == STRING_CST) && flag_writable_strings)
    fprintf (asm_out_file, "%s\n", DATA_SECTION_ASM_OP);
  else
    fprintf (asm_out_file, "%s\n", TEXT_SECTION_ASM_OP);

  /* Align the location counter as required by EXP's data type.  */
  for (i = 0; TYPE_ALIGN (TREE_TYPE (exp)) >= BITS_PER_UNIT << (i + 1); i++);
  ASM_OUTPUT_ALIGN (asm_out_file, i);

  /* Output the label itself.  */
  ASM_OUTPUT_INTERNAL_LABEL (asm_out_file, "LC", const_labelno);

  /* Output the value of EXP.  */
  output_constant (exp,
		   (TREE_CODE (exp) == STRING_CST
		    ? TREE_STRING_LENGTH (exp)
		    : int_size_in_bytes (TREE_TYPE (exp))));

  /* Create a string containing the label name, in LABEL.  */
  ASM_GENERATE_INTERNAL_LABEL (label, "LC", const_labelno);

  ++const_labelno;

  desc->label
    = (char *) obstack_copy0 (&permanent_obstack, label, strlen (label));

  return desc->label;
}

/* Return an rtx representing a reference to constant data in memory
   for the constant expression EXP.
   If assembler code for such a constant has already been output,
   return an rtx to refer to it.
   Otherwise, output such a constant in memory and generate
   an rtx for it.  The TREE_CST_RTL of EXP is set up to point to that rtx.  */

rtx
output_constant_def (exp)
     tree exp;
{
  register rtx def;
  char label[10];

  if (TREE_CST_RTL (exp))
    return TREE_CST_RTL (exp);

  def = gen_rtx (SYMBOL_REF, Pmode, get_or_assign_label (exp));

  TREE_CST_RTL (exp)
    = gen_rtx (MEM, TYPE_MODE (TREE_TYPE (exp)), def);
  TREE_CST_RTL (exp)->unchanging = 1;

  return TREE_CST_RTL (exp);
}

/* Similar hash facility for making memory-constants
   from constant rtl-expressions.  It is used on RISC machines
   where immediate integer arguments and constant addresses are restricted
   so that such constants must be stored in memory.

   This pool of constants is reinitialized for each function
   so each function gets its own constants-pool that comes right before it.  */

#define MAX_RTX_HASH_TABLE 61
static struct constant_descriptor *const_rtx_hash_table[MAX_RTX_HASH_TABLE];

void
init_const_rtx_hash_table ()
{
  bzero (const_rtx_hash_table, sizeof const_rtx_hash_table);
  clear_const_double_mem ();
}

struct rtx_const
{
  enum kind { RTX_DOUBLE, RTX_INT } kind : 16;
  enum machine_mode mode : 16;
  union {
    int d[2];
    struct addr_const addr;
  } un;
};

/* Express an rtx for a constant integer (perhaps symbolic)
   as the sum of a symbol or label plus an explicit integer.
   They are stored into VALUE.  */

static void
decode_rtx_const (x, value)
     rtx x;
     struct rtx_const *value;
{
  value->kind = RTX_INT;	/* Most usual kind. */
  value->mode = GET_MODE (x);
  value->un.addr.base = 0;
  value->un.addr.offset = 0;

  switch (GET_CODE (x))
    {
    case CONST_DOUBLE:
      value->kind = RTX_DOUBLE;
      value->mode = GET_MODE (x);
      value->un.d[0] = XINT (x, 0);
      value->un.d[1] = XINT (x, 1);
      break;

    case CONST_INT:
      value->un.addr.offset = INTVAL (x);
      break;

    case SYMBOL_REF:
      /* Use the string's address, not the SYMBOL_REF's address,
	 for the sake of addresses of library routines.  */
      value->un.addr.base = XEXP (x, 0);
      break;

    case LABEL_REF:
      /* Return the CODE_LABEL, not the LABEL_REF.  */
      value->un.addr.base = XEXP (x, 0);
      break;
    
    case CONST:
      x = XEXP (x, 0);
      if (GET_CODE (x) == PLUS)
	{
	  value->un.addr.base = XEXP (x, 0);
	  if (GET_CODE (XEXP (x, 1)) != CONST_INT)
	    abort ();
	  value->un.addr.offset = INTVAL (XEXP (x, 1));
	}
      else if (GET_CODE (x) == MINUS)
	{
	  value->un.addr.base = XEXP (x, 0);
	  if (GET_CODE (XEXP (x, 1)) != CONST_INT)
	    abort ();
	  value->un.addr.offset = - INTVAL (XEXP (x, 1));
	}
      else
	abort ();
      break;

    default:
      abort ();
    }
}

/* Compute a hash code for a constant RTL expression.  */

int
const_hash_rtx (x)
     rtx x;
{
  register int hi, i, len;
  register char *p;

  struct rtx_const value;
  decode_rtx_const (x, &value);

  /* Compute hashing function */
  hi = 0;
  for (i = 0; i < sizeof value / sizeof (int); i++)
    hi += ((int *) &value)[i];

  hi &= (1 << HASHBITS) - 1;
  hi %= MAX_RTX_HASH_TABLE;
  return hi;
}

/* Compare a constant rtl object X with a constant-descriptor DESC.
   Return 1 if DESC describes a constant with the same value as X.  */

static int
compare_constant_rtx (x, desc)
     rtx x;
     struct constant_descriptor *desc;
{
  register int *p = (int *) desc->contents;
  register int *strp;
  register int len;
  struct rtx_const value;

  decode_rtx_const (x, &value);
  strp = (int *) &value;
  len = sizeof value / sizeof (int);

  /* Compare constant contents.  */
  while (--len >= 0)
    if (*p++ != *strp++)
      return 0;

  return 1;
}

/* Construct a constant descriptor for the rtl-expression X.
   It is up to the caller to enter the descriptor in the hash table.  */

static struct constant_descriptor *
record_constant_rtx (x)
     rtx x;
{
  struct constant_descriptor *ptr = 0;
  int buf;
  struct rtx_const value;

  decode_rtx_const (x, &value);

  obstack_grow (saveable_obstack, &ptr, sizeof ptr);
  obstack_grow (saveable_obstack, &buf, sizeof buf);

  /* Record constant contents.  */
  obstack_grow (saveable_obstack, &value, sizeof value);

  return (struct constant_descriptor *) obstack_finish (saveable_obstack);
}

/* Given a constant rtx X, make (or find) a memory constant for its value
   and return a MEM rtx to refer to it in memory.  */

rtx
force_const_mem (mode, x)
     enum machine_mode mode;
     rtx x;
{
  register int hash, i;
  register struct constant_descriptor *desc;
  char label[10];
  char *found = 0;
  rtx def;

  /* Compute hash code of X.  Search the descriptors for that hash code
     to see if any of them describes X.  If yes, the descriptor records
     the label number already assigned.  */

  hash = const_hash_rtx (x);

  for (desc = const_rtx_hash_table[hash]; desc; desc = desc->next)
    if (compare_constant_rtx (x, desc))
      {
	found = desc->label;
	break;
      }

  if (found == 0)
    {
      int align;

      /* No constant equal to X is known to have been output.
	 Make a constant descriptor to enter X in the hash table.
	 Assign the label number and record it in the descriptor for
	 future calls to this function to find.  */

      desc = record_constant_rtx (x);
      desc->next = const_rtx_hash_table[hash];
      const_rtx_hash_table[hash] = desc;

      /* Now output assembler code to define that label
	 and follow it with the data of EXP.  */

      /* First switch to text segment.  */
      fprintf (asm_out_file, "%s\n", TEXT_SECTION_ASM_OP);

      /* Align the location counter as required by EXP's data type.  */
      align = (mode == VOIDmode) ? UNITS_PER_WORD : GET_MODE_SIZE (mode);
      if (align > BIGGEST_ALIGNMENT / BITS_PER_UNIT)
	align = BIGGEST_ALIGNMENT / BITS_PER_UNIT;

      ASM_OUTPUT_ALIGN (asm_out_file, exact_log2 (align));

      /* Output the label itself.  */
      ASM_OUTPUT_INTERNAL_LABEL (asm_out_file, "LC", const_labelno);

      /* Output the value of EXP.  */
      if (GET_CODE (x) == CONST_DOUBLE)
	{
	  union {double d; int i[2];} u;

	  u.i[0] = XINT (x, 0);
	  u.i[1] = XINT (x, 1);
	  if (GET_MODE_SIZE (GET_MODE (x)) == GET_MODE_SIZE (DFmode))
	    ASM_OUTPUT_DOUBLE (asm_out_file, u.d);
	  else
	    ASM_OUTPUT_FLOAT (asm_out_file, u.d);
	}
      else
	ASM_OUTPUT_INT (asm_out_file, x);

      /* Create a string containing the label name, in LABEL.  */
      ASM_GENERATE_INTERNAL_LABEL (label, "LC", const_labelno);

      ++const_labelno;

      desc->label = found
	= (char *) obstack_copy0 (&permanent_obstack, label, strlen (label));
    }

  /* We have a symbol name; construct the SYMBOL_REF and the MEM.  */

  def = gen_rtx (MEM, mode, gen_rtx (SYMBOL_REF, Pmode, desc->label));

  def->unchanging = 1;
  /* Mark the symbol_ref as belonging to this constants pool.  */
  XEXP (def, 0)->unchanging = 1;

  return def;
}

/* Find all the constants whose addresses are referenced inside of EXP,
   and make sure assembler code with a label has been output for each one.  */

void
output_addressed_constants (exp)
     tree exp;
{
  switch (TREE_CODE (exp))
    {
    case ADDR_EXPR:
      {
	register tree constant = TREE_OPERAND (exp, 0);

	while (TREE_CODE (constant) == COMPONENT_REF)
	  {
	    constant = TREE_OPERAND (constant, 0);
	  }

	if (TREE_LITERAL (constant))
	  /* No need to do anything here
	     for addresses of variables or functions.  */
	  output_constant_def (constant);
      }
      break;

    case PLUS_EXPR:
    case MINUS_EXPR:
      output_addressed_constants (TREE_OPERAND (exp, 0));
      output_addressed_constants (TREE_OPERAND (exp, 1));
      break;

    case NOP_EXPR:
    case CONVERT_EXPR:
      output_addressed_constants (TREE_OPERAND (exp, 0));
      break;

    case CONSTRUCTOR:
      {
	register tree link;
	for (link = CONSTRUCTOR_ELTS (exp); link; link = TREE_CHAIN (link))
	  output_addressed_constants (TREE_VALUE (link));
      }
      break;

    case ERROR_MARK:
      break;

    default:
      if (! TREE_LITERAL (exp))
	abort ();
    }
}

/* Output assembler code for constant EXP to FILE, with no label.
   This includes the pseudo-op such as ".int" or ".byte", and a newline.
   Assumes output_addressed_constants has been done on EXP already.

   Generate exactly SIZE bytes of assembler data, padding at the end
   with zeros if necessary.  SIZE must always be specified.

   SIZE is important for structure constructors,
   since trailing members may have been omitted from the constructor.
   It is also important for initialization of arrays from string constants
   since the full length of the string constant might not be wanted.
   It is also needed for initialization of unions, where the initializer's
   type is just one member, and that may not be as long as the union.

   There a case in which we would fail to output exactly SIZE bytes:
   for a structure constructor that wants to produce more than SIZE bytes.
   But such constructors will never be generated for any possible input.  */

void
output_constant (exp, size)
     register tree exp;
     register int size;
{
  register enum tree_code code = TREE_CODE (TREE_TYPE (exp));
  rtx x;

  if (size == 0)
    return;

  switch (code)
    {
    case INTEGER_TYPE:
    case ENUMERAL_TYPE:
    case POINTER_TYPE:
      while (TREE_CODE (exp) == NOP_EXPR || TREE_CODE (exp) == CONVERT_EXPR)
	exp = TREE_OPERAND (exp, 0);
      x = expand_expr (exp, 0, VOIDmode, EXPAND_SUM);

      if (size == 1)
	{
	  ASM_OUTPUT_CHAR (asm_out_file, x);
	  size -= 1;
	}
      else if (size == 2)
	{
	  ASM_OUTPUT_SHORT (asm_out_file, x);
	  size -= 2;
	}
      else if (size == 4)
	{
	  ASM_OUTPUT_INT (asm_out_file, x);
	  size -= 4;
	}
      else
	abort ();

      break;

    case REAL_TYPE:
      if (TREE_CODE (exp) != REAL_CST)
	error ("initializer for floating value is not a floating constant");

      if (size < 4)
	break;
      else if (size < 8)
	{
	  ASM_OUTPUT_FLOAT (asm_out_file, TREE_REAL_CST (exp));
	  size -= 4;
	}
      else
	{
	  ASM_OUTPUT_DOUBLE (asm_out_file, TREE_REAL_CST (exp));
	  size -= 8;
	}
      break;

    case COMPLEX_TYPE:
      output_constant (TREE_REALPART (exp), size / 2);
      output_constant (TREE_IMAGPART (exp), size / 2);
      size -= (size / 2) * 2;
      break;

    case ARRAY_TYPE:
      if (TREE_CODE (exp) == CONSTRUCTOR)
	{
	  output_constructor (exp, size);
	  return;
	}
      else if (TREE_CODE (exp) == STRING_CST)
	{
	  register int i;
	  register unsigned char *p
	    = (unsigned char *) TREE_STRING_POINTER (exp);
	  int excess = 0;

	  if (size > TREE_STRING_LENGTH (exp))
	    {
	      excess = size - TREE_STRING_LENGTH (exp);
	      size = TREE_STRING_LENGTH (exp);
	    }

#ifdef ASM_OUTPUT_ASCII
	  ASM_OUTPUT_ASCII (asm_out_file, p, size);
#else
	  fprintf (asm_out_file, "\t.ascii \"");

	  for (i = 0; i < size; i++)
	    {
	      register int c = p[i];
	      if (c == '\"' || c == '\\')
		putc ('\\', asm_out_file);
	      if (c >= ' ' && c < 0177)
		putc (c, asm_out_file);
	      else
		{
		  fprintf (asm_out_file, "\\%o", c);
		  /* After an octal-escape, if a digit follows,
		     terminate one string constant and start another.
		     The Vax assembler fails to stop reading the escape
		     after three digits, so this is the only way we
		     can get it to parse the data properly.  */
		  if (i < size - 1 && p[i + 1] >= '0' && p[i + 1] <= '9')
		    fprintf (asm_out_file, "\"\n\t.ascii \"");
		}
	    }
	  fprintf (asm_out_file, "\"\n");
#endif /* no ASM_OUTPUT_ASCII */

	  size = excess;
	}
      else
	abort ();
      break;

    case RECORD_TYPE:
    case UNION_TYPE:
      if (TREE_CODE (exp) == CONSTRUCTOR)
	output_constructor (exp, size);
      else
	abort ();
      return;
    }

  if (size > 0)
    ASM_OUTPUT_SKIP (asm_out_file, size);
}

/* Subroutine of output_constant, used for CONSTRUCTORs
   (aggregate constants).
   Generate at least SIZE bytes, padding if necessary.  */

void
output_constructor (exp, size)
     tree exp;
     int size;
{
  register tree link, field = 0;
  register int byte;
  int total_bytes = 0;
  int byte_offset = -1;

  if (TREE_CODE (TREE_TYPE (exp)) == RECORD_TYPE
      || TREE_CODE (TREE_TYPE (exp)) == UNION_TYPE)
    field = TYPE_FIELDS (TREE_TYPE (exp));

  /* As LINK goes through the elements of the constant,
     FIELD goes through the structure fields, if the constant is a structure.
     But the constant could also be an array.  Then FIELD is zero.  */
  for (link = CONSTRUCTOR_ELTS (exp);
       link;
       link = TREE_CHAIN (link),
       field = field ? TREE_CHAIN (field) : 0)
    {
      if (field == 0
	  || (DECL_MODE (field) != BImode))
	{
	  register int fieldsize;

	  /* An element that is not a bit-field.
	     Output any buffered-up bit-fields preceding it.  */
	  if (byte_offset >= 0)
	    {
	      ASM_OUTPUT_BYTE (asm_out_file, byte);
	      total_bytes++;
	      byte_offset = -1;
	    }

	  /* Align to this element's alignment,
	     if it isn't aligned properly by its predecessors.  */
	  if (field && (total_bytes * BITS_PER_UNIT) % DECL_ALIGN (field) != 0)
	    {
	      int byte_align = DECL_ALIGN (field) / BITS_PER_UNIT;
	      int to_byte = (((total_bytes + byte_align - 1) / byte_align)
			     * byte_align);
	      ASM_OUTPUT_SKIP (asm_out_file, to_byte - total_bytes);
	      total_bytes = to_byte;
	    }

	  /* Output the element's initial value.  */
	  if (field)
	    {
	      if (! TREE_LITERAL (DECL_SIZE (field)))
		abort ();
	      fieldsize = TREE_INT_CST_LOW (DECL_SIZE (field))
		* DECL_SIZE_UNIT (field);
	      fieldsize = (fieldsize + BITS_PER_UNIT - 1) / BITS_PER_UNIT;
	    }
	  else
	    fieldsize = int_size_in_bytes (TREE_TYPE (TREE_TYPE (exp)));

	  output_constant (TREE_VALUE (link), fieldsize);

	  /* Count its size.  */
	  total_bytes += fieldsize;
	}
      else if (TREE_CODE (TREE_VALUE (link)) != INTEGER_CST)
	error ("invalid initial value for member `%s'",
	       IDENTIFIER_POINTER (DECL_NAME (field)));
      else
	{
	  /* Element that is a bit-field.  */

	  int next_offset = DECL_OFFSET (field);
	  int end_offset
	    = (next_offset
	       + (TREE_INT_CST_LOW (DECL_SIZE (field))
		  * DECL_SIZE_UNIT (field)));

	  /* We must split the element into pieces that fall within
	     separate bytes, and combine each byte with previous or
	     following bit-fields.  */

	  /* next_offset is the offset n fbits from the begining of
	     the structure to the next bit of this element to be processed.
	     end_offset is the offset of the first bit past the end of
	     this element.  */
	  while (next_offset < end_offset)
	    {
	      int this_time;
	      int next_byte = next_offset / BITS_PER_UNIT;
	      int next_bit = next_offset % BITS_PER_UNIT;
	      if (byte_offset < 0)
		{
		  byte_offset = next_byte;
		  byte = 0;
		}
	      else
		while (next_byte != byte_offset)
		  {
		    ASM_OUTPUT_BYTE (asm_out_file, byte);
		    byte_offset++;
		    total_bytes++;
		    byte = 0;
		  }
	      /* Number of bits we can process at once
		 (all part of the same byte).  */
	      this_time = MIN (end_offset - next_offset,
			       BITS_PER_UNIT - next_bit);
#ifdef BYTES_BIG_ENDIAN
	      /* On big-endian machine, take the most significant bits
		 first (of the bits that are significant)
		 and put them into bytes from the most significant end.  */
	      byte |= (((TREE_INT_CST_LOW (TREE_VALUE (link))
			 >> (end_offset - next_offset - this_time))
			& ((1 << this_time) - 1))
		       << (BITS_PER_UNIT - this_time - next_bit));
#else
	      /* On little-endian machines,
		 take first the least significant bits of the value
		 and pack them starting at the least significant
		 bits of the bytes.  */
	      byte |= ((TREE_INT_CST_LOW (TREE_VALUE (link))
			>> (next_offset - DECL_OFFSET (field)))
		       & ((1 << this_time) - 1)) << next_bit;
#endif
	      next_offset += this_time;
	    }
	}
    }
  if (byte_offset >= 0)
    {
      ASM_OUTPUT_BYTE (asm_out_file, byte);
      byte_offset = -1;
      total_bytes++;
    }
  if (total_bytes < size)
    ASM_OUTPUT_SKIP (asm_out_file, size - total_bytes);
}
