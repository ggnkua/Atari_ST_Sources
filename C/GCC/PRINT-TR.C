/* Prints out tree in human readable form - GNU C-compiler
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


#include "config.h"
#include "tree.h"
#include <stdio.h>


/* Names of tree components.
   Used for printing out the tree and error messages.  */
#define DEFTREECODE(SYM, NAME, TYPE, LEN) NAME,

char *tree_code_name[] = {
#include "tree.def"
};
#undef DEFTREECODE

extern char *tree_code_type[];
extern int tree_code_length[];
extern char *mode_name[];

extern char spaces[];

#define MIN(x,y) ((x < y) ? x : y)

static FILE *outfile;

extern int tree_node_counter;

/* markvec[i] is 1 if node number i has been seen already.  */

static char *markvec;

static void dump ();
void dump_tree ();

void
debug_dump_tree (root)
     tree root;
{
  dump_tree (stderr, root);
}

void
dump_tree (outf, root)
     FILE *outf;
     tree root;
{
  markvec = (char *) alloca (tree_node_counter + 1);
  bzero (markvec, tree_node_counter + 1);
  outfile = outf;
  dump (root, 0);
  fflush (outf);
}

static
void
wruid (node)
     tree node;
{
 
  if (node == NULL)
    fputs ("<>", outfile);
  else {
    fprintf (outfile, "%1d", TREE_UID (node));
  }
}

static 
void
part (title, node)
     char title[];
     tree node;
{
  fprintf (outfile, " %s = ", title);
  wruid (node);
  putc (';', outfile);
}

/* Similar to `part' but prefix with @ if value is not constant
   and print the constant value if it is constant.  */
static
void
cpart (title, ct, punct)
     char *title;
     tree ct;
     char punct;
{
  fprintf (outfile, " %s = ", title);
  if (ct == NULL)
    fputs ("<>", outfile);
  else
    {
      if (!TREE_LITERAL (ct))
	{
	  putc ('@', outfile);
	  wruid (ct);
	}
      else
	fprintf (outfile, "%ld", TREE_INT_CST_LOW (ct));
    }
  putc(punct, outfile);
}

static
void
walk (node, leaf, indent)
     tree node;
     tree leaf;
     int indent;
{
  if (node != NULL
      /* Don't walk any global nodes reached from local nodes!
	 The global nodes will be dumped at the end, all together.
	 Also don't mention a FUNCTION_DECL node that is marked local
	 since it was fully described when it was dumped locally.  */
      && (TREE_CODE (node) != FUNCTION_DECL
	  || TREE_PERMANENT (node))
      && (TREE_PERMANENT (leaf) == TREE_PERMANENT (node)))
    dump (node, indent+1);
}

static
void
cwalk (s, leaf, indent)
     tree s;
     tree leaf;
     int indent;
{
  if (s != NULL) 
    if (!TREE_LITERAL (s))
      walk(s, leaf, indent);
}
 
static
void
prtypeinfo (node)
     register tree node;
{
  int first;
  
  part ("type", TREE_TYPE (node));
  first = 1;
  fputs (" [", outfile);
  if (TREE_EXTERNAL (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("external", outfile);
      first = 0;
    }
  if (TREE_PUBLIC (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("public", outfile);
      first = 0;
    }
  if (TREE_STATIC (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("static", outfile);
      first = 0;
    }
  if (TREE_VOLATILE (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("volatile", outfile);
      first = 0;
    }
  if (TREE_PACKED (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("packed", outfile);
      first = 0;
    }
  if (TREE_READONLY (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("readonly", outfile);
      first = 0;
    }
  if (TREE_LITERAL (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("literal", outfile);
      first = 0;
    }
  if (TREE_NONLOCAL (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("nonlocal", outfile);
      first = 0;
    }
  if (TREE_ADDRESSABLE (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("addressable", outfile);
      first = 0;
    }
  if (TREE_REGDECL (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("regdecl", outfile);
      first = 0;
    }
  if (TREE_THIS_VOLATILE (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("this_vol", outfile);
      first = 0;
    }
  if (TREE_UNSIGNED (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("unsigned", outfile);
      first = 0;
    }
  if (TREE_ASM_WRITTEN (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("asm_written", outfile);
      first = 0;
    }
  if (TREE_INLINE (node))
    {
      if (!first) putc (' ', outfile);
      fputs ("inline", outfile);
      first = 0;
    }
  fputs ("] ", outfile);
}

static
void
prdeclmodeinfo(node)
     tree node;
{
  register enum machine_mode mode = DECL_MODE (node);
  fprintf (outfile, " %s;", mode_name[(int) mode]);

  cpart ("size", DECL_SIZE (node), '*');
  fprintf (outfile, "%d;", DECL_SIZE_UNIT (node));

  fprintf (outfile, " alignment = %1d;", DECL_ALIGN (node));
}

static
void
prtypemodeinfo(node)
     tree node;
{
  register enum machine_mode mode = TYPE_MODE (node);
  fprintf (outfile, " %s;", mode_name[(int) mode]);

  cpart ("size", TYPE_SIZE (node), '*');
  fprintf (outfile, "%d;", TYPE_SIZE_UNIT (node));

  fprintf (outfile, " alignment = %1d;", TYPE_ALIGN (node));
}

static
void
skip (indent)
     int indent;
{
  putc ('\n',outfile);
  fputs (spaces + (strlen (spaces) - (12 + MIN (40,(indent+1)*2))), outfile);
}

/* Output a description of the tree node NODE
   if its description has not been output already.  */

static 
void
dump (node, indent)
     tree node;
     int indent;
{
  register enum tree_code code = TREE_CODE (node);
  register int i;
  register int len;
  int nochain = 0;

  if (markvec[TREE_UID (node)])
    return;
  markvec[TREE_UID (node)] = 1;

  fputs ("   ", outfile);
  fprintf (outfile, "%5d", TREE_UID (node));
  fputs (spaces + (strlen (spaces) - MIN (40, (indent+1)*2)), outfile);
  fputs (tree_code_name[(int) code], outfile);

  switch (*tree_code_type[(int) code])
    {
    case 'd':
      fputs (" name = ", outfile);
      if (DECL_NAME (node) == NULL)
	fputs("<>;", outfile);
      else
	fprintf (outfile, "%s;",
		 IDENTIFIER_POINTER (DECL_NAME (node)));
      fprintf (outfile, " at %s line %d;",
	       DECL_SOURCE_FILE (node), DECL_SOURCE_LINE (node));
      skip (indent);
      prdeclmodeinfo (node);
      prtypeinfo (node);
      skip (indent);
      fprintf (outfile, " offset = %1d;", DECL_OFFSET (node));
      if (DECL_VOFFSET (node) != NULL)
	{
	  fputs ("voffset = ", outfile);
	  wruid (DECL_VOFFSET (node));
	  fprintf (outfile, "*%1d;", DECL_VOFFSET_UNIT (node));
	}
      part ("context", DECL_CONTEXT (node));
      if (DECL_ARGUMENTS (node) || DECL_RESULT (node)
	  || DECL_INITIAL (node))
	{
	  skip(indent);
	  part ("arguments", DECL_ARGUMENTS (node));
	  part ("result", DECL_RESULT (node));
	  if ((int) (DECL_INITIAL (node)) == 1)
	    fprintf (outfile, " initial = const 1;");
	  else
	    part ("initial", DECL_INITIAL (node));
	}
      part ("chain", TREE_CHAIN (node));
      fputc ('\n', outfile);
      cwalk (DECL_SIZE (node), node, indent);
      walk (TREE_TYPE (node), node, indent);
      walk (DECL_VOFFSET (node), node, indent);
      walk (DECL_CONTEXT (node), node, indent);
      walk (DECL_ARGUMENTS (node), node, indent);
      walk (DECL_RESULT (node), node, indent);
      if ((int) (DECL_INITIAL (node)) != 1)
	walk (DECL_INITIAL (node), node, indent);
      break;

    case 't':
      prtypemodeinfo (node);
      prtypeinfo (node);
      skip (indent);
      part ("pointers_to_this", TYPE_POINTER_TO (node));
      if (code == ARRAY_TYPE || code == SET_TYPE)
	{
	  part ("domain", TYPE_DOMAIN (node));
	  cpart ("separation", TYPE_SEP (node), '*');
	  fprintf (outfile, "%d;", TYPE_SEP_UNIT (node));
	}
      else if (code == INTEGER_TYPE)
	{
	  cpart ("min", TYPE_MIN_VALUE (node), ';');
	  cpart ("max", TYPE_MAX_VALUE (node), ';');
	  fprintf (outfile, "precision = %d;", TYPE_PRECISION (node));
	}
      else if (code == ENUMERAL_TYPE)
	{
	  cpart ("min", TYPE_MIN_VALUE (node), ';');
	  cpart ("max", TYPE_MAX_VALUE (node), ';');
	  part ("values", TYPE_VALUES (node));
	  fprintf (outfile, "precision = %d;", TYPE_PRECISION (node));
	}
      else if (code == REAL_TYPE)
	{
	  fprintf (outfile, "precision = %d;", TYPE_PRECISION (node));
	}
      else if (code == RECORD_TYPE
	       || code == UNION_TYPE)
	{
	  part ("fields", TYPE_FIELDS (node));
	}
      else if (code == FUNCTION_TYPE)
	{
	  part ("arg_types", TYPE_ARG_TYPES (node));
	}
      /* A type's chain is not printed because the chain of types
	 is not part of the meaning of any particular type.  */
      /* part ("chain", TREE_CHAIN (node)); */
      nochain = 1;
      fputc ('\n', outfile);
      cwalk (TYPE_SIZE (node), node, indent);
      walk (TREE_TYPE (node), node, indent);
      walk (TYPE_VALUES (node), node, indent);
      walk (TYPE_SEP (node), node, indent);
      walk (TYPE_POINTER_TO (node), node, indent);
      break;

    case 'e':
    case 'r':
      prtypeinfo (node);
      fputs (" ops =", outfile);
      len = tree_code_length[(int) code];
      for (i = 0; i < len; i++)
	{
	  fputs (" ", outfile);
	  wruid (TREE_OPERAND (node, i));
	  fputs (";", outfile);
	}
      part ("chain", TREE_CHAIN (node));
      fputc ('\n', outfile);
      walk (TREE_TYPE (node), node, indent);
      for (i = 0; i < len; i++)
	walk (TREE_OPERAND (node, i), node, indent);
      break;

    case 's':
      prtypeinfo (node);
      fprintf (outfile, " at %s line %d;",
	       STMT_SOURCE_FILE (node), STMT_SOURCE_LINE (node));
      fputs (" ops =", outfile);
      len = tree_code_length[(int) code];
      for (i = 0; i < len; i++)
	{
	  fputs (" ", outfile);
	  wruid (TREE_OPERAND (node, i+2));
	  fputs (";", outfile);
	}
      part ("chain", TREE_CHAIN (node));
      fputc ('\n', outfile);
      walk (TREE_TYPE (node), node, indent);
      for (i = 0; i < len; i++)
	walk (TREE_OPERAND (node, i+2), node, indent);
      break;

    case 'c':
      switch (code)
	{
	case INTEGER_CST:
	  if (TREE_INT_CST_HIGH (node) == 0)
	    fprintf (outfile, " = %1u;", TREE_INT_CST_LOW (node));
	  else if (TREE_INT_CST_HIGH (node) == -1
		   && TREE_INT_CST_LOW (node) != 0)
	    fprintf (outfile, " = -%1u;", -TREE_INT_CST_LOW (node));
	  else
	    fprintf (outfile, " = 0x%x%08x;",
		     TREE_INT_CST_HIGH (node),
		     TREE_INT_CST_LOW (node));
	  break;

	case REAL_CST:
	  fprintf (outfile, " = %e;", TREE_REAL_CST (node));
	  break;

	case COMPLEX_CST:
	  part ("realpart", TREE_REALPART (node));
	  part ("imagpart", TREE_IMAGPART (node));
	  walk (TREE_REALPART (node), node, indent);
	  walk (TREE_IMAGPART (node), node, indent);
	  break;

	case STRING_CST:
	  fprintf (outfile, " = \"%s\";", TREE_STRING_POINTER (node));
	}
      prtypeinfo(node);
      part ("chain", TREE_CHAIN (node));
      fputc ('\n', outfile);
      walk (TREE_TYPE (node), node, indent);
      break;

    case 'x':
      if (code == IDENTIFIER_NODE)
	fprintf (outfile, " = %s;\n", IDENTIFIER_POINTER (node));
      else if (code == TREE_LIST)
	{
	  prtypeinfo (node);
	  part ("purpose", TREE_PURPOSE (node));
	  part ("value", TREE_VALUE (node));
	  part ("chain", TREE_CHAIN (node));
	  fputc ('\n', outfile);
	  walk (TREE_TYPE (node), node, indent);
	  walk (TREE_PURPOSE (node), node, indent);
	  walk (TREE_VALUE (node), node, indent);
	}
      else if (code == ERROR_MARK)
	fputc ('\n', outfile);
      else abort ();

      break;

    default:
      abort ();
    } /* switch */

  if (TREE_CHAIN (node) != NULL && ! nochain)
    dump(TREE_CHAIN (node), indent);
}
