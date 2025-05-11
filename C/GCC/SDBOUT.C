/* Output sdb-format symbol table information from GNU compiler.
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

#ifdef SDB_DEBUGGING_INFO

#include "tree.h"
#include "rtl.h"
#include "c-tree.h"
#include <stdio.h>
#include <syms.h>
/* #include <storclass.h>  used to be this instead of syms.h.  */

/* Line number of beginning of current function, minus one.  */

int sdb_begin_function_line = 0;

/* Counter to generate unique "names" for nameless struct members.  */

static int unnamed_struct_number = 0;

extern FILE *asm_out_file;

extern tree current_function_decl;

void sdbout_init ();
void sdbout_syms ();
void sdbout_symbol ();
void sdbout_tags();
void sdbout_types();

static void sdbout_one_type ();

/* Random macros describing parts of SDB data.  */

/* Put something here if lines get too long */
#define CONTIN

#define PUT_SDB_SCL(a) fprintf(asm_out_file, "\t.scl\t%d;", (a))
#define PUT_SDB_INT_VAL(a) fprintf (asm_out_file, "\t.val\t%d;", (a))
#define PUT_SDB_VAL(a)				\
( fputs (".val\t", asm_out_file),		\
  output_addr_const (asm_out_file, (a)),	\
  fputc (';', asm_out_file))
#define PUT_SDB_DEF(a) fprintf(asm_out_file, "\t.def\t%s;", a)
#define PUT_SDB_ENDEF fputs("\t.endef\n", asm_out_file)
#define PUT_SDB_TYPE(a) fprintf(asm_out_file, "\t.type\t0%o;", a)
#define PUT_SDB_TAG(a) fprintf(asm_out_file, "\t.tag\t%s;", a)
#define PUT_SDB_SIZE(a) fprintf(asm_out_file, "\t.size\t%d;", a)

/* Return the sdb tag identifier string for TYPE
   if TYPE has already been defined; otherwise return a null pointer.   */
  
#define KNOWN_TYPE_TAG(type) (char *)(TYPE_SYMTAB_ADDRESS (type))

/* Set the sdb tag identifier string for TYPE to NAME.  */

#define SET_KNOWN_TYPE_TAG(TYPE, NAME) \
  (TYPE_SYMTAB_ADDRESS (TYPE) = (int)(NAME))

/* Return the name (a string) of the struct, union or enum tag
   described by the TREE_LIST node LINK.  This is 0 for an anonymous one.  */

#define TAG_NAME(link) \
  (((link) && TREE_PURPOSE((link)) \
    && IDENTIFIER_POINTER(TREE_PURPOSE((link)))) \
   ? IDENTIFIER_POINTER(TREE_PURPOSE((link))) : (char *) 0)

void
sdbout_init (asm_file, input_file_name)
     FILE *asm_file;
     char *input_file_name;
{
  /* Get all permanent types not yet gotten
     and output them.  */

  sdbout_types (nreverse (get_permanent_types ()));
}

#if 0

/* return the tag identifier for type
 */

{
char *
tag_of_ru_type (type,link)
     tree type,link;
{
  if (TYPE_SYMTAB_ADDRESS (type))
    return (char *)TYPE_SYMTAB_ADDRESS (type);
  if (link &&
      TREE_PURPOSE (link)
      && IDENTIFIER_POINTER (TREE_PURPOSE (link)))
    TYPE_SYMTAB_ADDRESS (type) =
      (int)IDENTIFIER_POINTER (TREE_PURPOSE (link));
  else
    return (char *) TYPE_SYMTAB_ADDRESS (type);
}
#endif

/* Return a unique string to name an anonymous type.  */

static char *
gen_fake_label ()
{
  char label[10];
  char *labelstr;
  sprintf (label, ".%dfake", unnamed_struct_number++);
  labelstr = (char *) permalloc (strlen (label) + 1);
  strcpy (labelstr, label);
  return labelstr;
}

/* Return the number which describes TYPE for SDB.
   For pointers, etc., this function is recursive.
   Each record, union or enumeral type must already have had a
   tag number output.  */

/* The number is given by d6d5d4d3d2d1bbbb 
   where bbbb is 4 bit basic type, and di indicate  one of notype,ptr,fn,array.
   Thus, char *foo () has bbbb=T_CHAR
			  d1=D_FCN
			  d2=D_PTR
 N_BTMASK=     017       1111     basic type field.
 N_TSHIFT=       2                derived type shift
 N_BTSHFT=       4                Basic type shift */

/* Produce the number that describes a pointer, function or array type.
   PREV is the number describing the target, value or element type.
   DT_type describes how to transform that type.  */
#define PUSH_DERIVED_LEVEL(DT_type,PREV) \
  ((((PREV)&~N_BTMASK)<<N_TSHIFT)|(DT_type<<N_BTSHFT)|(PREV&N_BTMASK))

static int
plain_type (type)
     tree type;
{
  if (type == 0)  
    type = void_type_node;
  if (type == error_mark_node)
    type = integer_type_node;
  switch (TREE_CODE (type))
    {
    case VOID_TYPE:
      return T_INT;
    case INTEGER_TYPE:
      switch (int_size_in_bytes (type))
	{
	case 4:
	  return (TREE_UNSIGNED (type) ? T_UINT : T_INT);
	case 1:
	  return (TREE_UNSIGNED (type) ? T_UCHAR : T_CHAR);
	case 2:
	  return (TREE_UNSIGNED (type) ? T_USHORT : T_SHORT);
	default:
	  return 0;
	}
    case REAL_TYPE:
      switch (int_size_in_bytes (type))
	{
	case 4:
	  return T_FLOAT;
	default:
	  return T_DOUBLE;
	}
    case ARRAY_TYPE:
      {
	int m = plain_type (TREE_TYPE (type));
	return PUSH_DERIVED_LEVEL (DT_ARY, m);
      }
    case RECORD_TYPE:
    case UNION_TYPE:
    case ENUMERAL_TYPE:
      {
	char *tag;
	tag = KNOWN_TYPE_TAG (type);
	if (tag) PUT_SDB_TAG (tag);
	PUT_SDB_SIZE (int_size_in_bytes (type));
	return ((TREE_CODE (type) == RECORD_TYPE) ? T_STRUCT :
		(TREE_CODE (type) == UNION_TYPE) ? T_UNION :
		T_ENUM);
      }
    case POINTER_TYPE:
      {
	int m = plain_type (TREE_TYPE (type));
	return PUSH_DERIVED_LEVEL (DT_PTR, m);
      }
    case FUNCTION_TYPE:
      {
	int m = plain_type (TREE_TYPE (type));
	return PUSH_DERIVED_LEVEL (DT_FCN, m);
      }
    default:
      return 0;
    }
}

/* Output the symbols defined in block number DO_BLOCK.
   Set NEXT_BLOCK_NUMBER to 0 before calling.

   This function works by walking the tree structure,
   counting blocks, until it finds the desired block.  */

static int do_block = 0;

static int next_block_number;

static void
sdbout_block (stmt)
     register tree stmt;
{
  while (stmt)
    {
      switch (TREE_CODE (stmt))
	{
	case COMPOUND_STMT:
	case LOOP_STMT:
	  sdbout_block (STMT_BODY (stmt));
	  break;

	case IF_STMT:
	  sdbout_block (STMT_THEN (stmt));
	  sdbout_block (STMT_ELSE (stmt));
	  break;

	case LET_STMT:
	  /* When we reach the specified block, output its symbols.  */
	  if (next_block_number == do_block)
	    {
	      sdbout_tags (STMT_TYPE_TAGS (stmt));
	      sdbout_syms (STMT_VARS (stmt));
	    }

	  /* If we are past the specified block, stop the scan.  */
	  if (next_block_number < do_block)
	    return;

	  next_block_number++;

	  /* Scan the blocks within this block.  */
	  sdbout_block (STMT_BODY (stmt));
	}
      stmt = TREE_CHAIN (stmt);
    }
}

/* Call sdbout_symbol on each decl in the chain SYMS.  */

static void
sdbout_syms (syms)
     tree syms;
{
  while (syms)
    {
      sdbout_symbol (syms, 1);
      syms = TREE_CHAIN (syms);
    }
}

/* Output SDB information for a symbol described by DECL.
   LOCAL is nonzero if the symbol is not file-scope.  */

void
sdbout_symbol (decl, local)
     tree decl;
     int local;
{
  int letter = 0;
  tree type = TREE_TYPE (decl);

  /* If global, first output all types and all
     struct, enum and union tags that have been created
     and not yet output.  */

  if (local == 0)
    {
      sdbout_tags (gettags ());
      sdbout_types (nreverse (get_permanent_types ()));
    }

  switch (TREE_CODE (decl))
    {
    case CONST_DECL:
      /* Enum values are defined by defining the enum type.  */
      return;

    case FUNCTION_DECL:
      if (TREE_EXTERNAL (decl))
	return;
      if (GET_CODE (DECL_RTL (decl)) != MEM
	  || GET_CODE (XEXP (DECL_RTL (decl), 0)) != SYMBOL_REF)
	return;
      PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (decl)));
      PUT_SDB_VAL (XEXP (DECL_RTL (decl), 0));
      PUT_SDB_SCL (TREE_PUBLIC (decl) ? C_EXT : C_STAT);
      break;

    case TYPE_DECL:
      /* Output typedef name.  */
      PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (decl)));
      PUT_SDB_SCL (C_TPDEF);
      break;
      
    case PARM_DECL:
      /* Parm decls go in their own separate chains
	 and are output by sdbout_reg_parms and sdbout_parms.  */
      abort ();

    case VAR_DECL:
      /* Don't mention a variable that is external.
	 Let the file that defines it describe it.  */
      if (TREE_EXTERNAL (decl))
	return;

      /* Don't mention a variable at all
	 if it was completely optimized into nothingness.  */
      if (GET_CODE (DECL_RTL (decl)) == REG
	  && (REGNO (DECL_RTL (decl)) < 0
	      || REGNO (DECL_RTL (decl)) >= FIRST_PSEUDO_REGISTER))
	return;

      /* Ok, start a symtab entry and output the variable name.  */
      PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (decl)));

      if (GET_CODE (DECL_RTL (decl)) == MEM
	  && GET_CODE (XEXP (DECL_RTL (decl), 0)) == SYMBOL_REF)
	{
	  if (TREE_PUBLIC (decl))
	    {
	      PUT_SDB_VAL (XEXP (DECL_RTL (decl), 0));
              PUT_SDB_SCL (C_EXT);
	    }
	  else
	    {
	      PUT_SDB_VAL (XEXP (DECL_RTL (decl), 0));
              PUT_SDB_SCL (C_STAT);
	    }
	}
      else if (GET_CODE (DECL_RTL (decl)) == REG)
	{
	  PUT_SDB_INT_VAL (DBX_REGISTER_NUMBER (REGNO (DECL_RTL (decl))));
	  PUT_SDB_SCL (C_REG);
	}
      else if (GET_CODE (DECL_RTL (decl)) == MEM
	       && (GET_CODE (XEXP (DECL_RTL (decl), 0)) == MEM
		   || (GET_CODE (XEXP (DECL_RTL (decl), 0)) == REG
		       && REGNO (XEXP (DECL_RTL (decl), 0)) != FRAME_POINTER_REGNUM)))
	/* If the value is indirect by memory or by a register
	   that isn't the frame pointer
	   then it means the object is variable-sized and address through
	   that register or stack slot.  DBX has no way to represent this
	   so all we can do is output the variable as a pointer.  */
	{
	  if (GET_CODE (XEXP (DECL_RTL (decl), 0)) == REG)
	    {
	      PUT_SDB_INT_VAL (DBX_REGISTER_NUMBER (REGNO (DECL_RTL (decl))));
	      PUT_SDB_SCL (C_REG);
	    }
	  else
	    {
	      /* DECL_RTL looks like (MEM (MEM (PLUS (REG...)
		 (CONST_INT...)))).
		 We want the value of that CONST_INT.  */
	      /* Encore compiler hates a newline in a macro arg, it seems.  */
	      PUT_SDB_INT_VAL (INTVAL (XEXP (XEXP (XEXP (DECL_RTL (decl), 0), 0), 1)));
	      PUT_SDB_SCL (C_AUTO);
	    }

	  type = build_pointer_type (TREE_TYPE (decl));
	}
      else if (GET_CODE (DECL_RTL (decl)) == MEM
	       && XEXP (DECL_RTL (decl), 0) != const0_rtx)
	/* const0_rtx is used as the address for a variable that
	   is a dummy due to an erroneous declaration.
	   Ignore such vars.  */
	{
	  /* DECL_RTL looks like (MEM (PLUS (REG...) (CONST_INT...))).
	     We want the value of that CONST_INT.  */
	  PUT_SDB_INT_VAL (INTVAL (XEXP (XEXP (DECL_RTL (decl), 0), 1)));
	  PUT_SDB_SCL (C_AUTO);
	}
      break;
    }
  PUT_SDB_TYPE (plain_type (type));
  PUT_SDB_ENDEF;
}

/* Given a list of TREE_LIST nodes that point at types,
   output those types for SDB.
   We must check to include those that have been mentioned already with
   only a cross-reference.  */

void
sdbout_tags (tags)
     tree tags;
{
  register tree link;

  for (link = tags; link; link = TREE_CHAIN (link))
    {
      register tree type = TREE_VALUE (link);

      if (TREE_PURPOSE (link) != 0
	  && ! KNOWN_TYPE_TAG (type)
	  && TYPE_SIZE (type) != 0)
	sdbout_one_type (type, TAG_NAME (link));
    }
}

/* Given a chain of ..._TYPE nodes, all of which have names,
   output definitions of those names, as typedefs.  */

void
sdbout_types (types)
     register tree types;
{
  register tree link;

  for (link = types; link; link = TREE_CHAIN (link))
    sdbout_one_type (link, 0);
}

static void
sdbout_type (type)
     tree type;
{
  register tree tem;
  if (type == error_mark_node)
    type = integer_type_node;
  PUT_SDB_TYPE (plain_type (type));
}

/* Use this to put out the top level defined record and union types
   for later reference.  If this is a struct with a name, then put that
   name out.  Other unnamed structs will have .xxfake labels generated so
   that they may be referred to later.
   The label will be stored in the KNOWN_TYPE_TAG slot of a type.
   It may NOT be called recursively.  */

static void
sdbout_one_type (type, name)
     char *name;
     tree type;
{
  switch (TREE_CODE (type))
    {
    case RECORD_TYPE:
    case UNION_TYPE:
    case ENUMERAL_TYPE:
      /* Don't output a type twice.  */
      if (KNOWN_TYPE_TAG (type))
	return;

      /* Output a structure type.  */
      {
	int size = int_size_in_bytes (type);
	int member_scl;
	tree tem;

	if (!name || !*name)
	  name = gen_fake_label ();
	SET_KNOWN_TYPE_TAG (type, name);
	PUT_SDB_DEF (name);

	switch (TREE_CODE (type))
	  {
	  case UNION_TYPE:
	    PUT_SDB_SCL (C_UNTAG);
	    PUT_SDB_TYPE (T_UNION);
	    member_scl = C_MOU;
	    break;

	  case RECORD_TYPE:
	    PUT_SDB_SCL (C_STRTAG);
	    PUT_SDB_TYPE (T_STRUCT);
	    member_scl = C_MOS;
	    break;

	  case ENUMERAL_TYPE:
	    PUT_SDB_SCL (C_ENTAG);
	    PUT_SDB_TYPE (T_ENUM);
	    member_scl = C_MOE;
	    break;
	  }

	PUT_SDB_SIZE (size);
	PUT_SDB_ENDEF;

	/* output the individual fields */

	if (TREE_CODE (type) == ENUMERAL_TYPE)
	  for (tem = TYPE_FIELDS (type); tem; tem = TREE_CHAIN (tem))
	    {
	      PUT_SDB_DEF (IDENTIFIER_POINTER (TREE_PURPOSE (tem)));
	      PUT_SDB_INT_VAL (TREE_INT_CST_LOW (TREE_VALUE (tem)));
	      PUT_SDB_SCL (C_MOE);
	      PUT_SDB_TYPE (T_MOE);
	      PUT_SDB_ENDEF;
	    }
      
	else			/* record or union type */
	  for (tem = TYPE_FIELDS (type); tem; tem = TREE_CHAIN (tem))
	    /* Output the name, type, position (in bits), size (in bits)
	       of each field.  */
	    /* Omit here the nameless fields that are used to skip bits.  */
	    if (DECL_NAME (tem) != 0)
	      {
		CONTIN;
		PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (tem)));
		if (tem->decl.mode == BImode)
		  {
		    PUT_SDB_INT_VAL (DECL_OFFSET (tem));
		    PUT_SDB_SCL (C_FIELD);
		    sdbout_type (TREE_TYPE (tem));
		  }
		else
		  {
		    PUT_SDB_INT_VAL (DECL_OFFSET (tem) / BITS_PER_UNIT);
		    PUT_SDB_SCL (member_scl);
		    sdbout_type (TREE_TYPE (tem));
		  }
		PUT_SDB_ENDEF;
	      }
	/* output end of a structure,union, or enumeral definition */
   
	PUT_SDB_DEF (".eos");
	PUT_SDB_INT_VAL (size);
	PUT_SDB_SCL (C_EOS);
	PUT_SDB_TAG (name);
	PUT_SDB_SIZE (size);
	PUT_SDB_ENDEF;
	break;
      }
    }
}

/* Output definitions of all parameters, referring when possible to the
   place where the parameters were passed rather than the copies used
   within the function.     This is done as part of starting the function.
   PARMS is a chain of PARM_DECL nodes.  */

static void
sdbout_parms (parms1)
     tree parms1;
{
  tree type;
  tree parms;

  for (parms = parms1; parms; parms = TREE_CHAIN (parms))
    {
      int current_sym_value = DECL_OFFSET (parms) / BITS_PER_UNIT;

      PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (parms)));
      if (GET_CODE (DECL_RTL (parms)) == REG
	  && REGNO (DECL_RTL (parms)) >= 0
	  && REGNO (DECL_RTL (parms)) < FIRST_PSEUDO_REGISTER)
	type = DECL_ARG_TYPE (parms);
      else
	{
	  /* This is the case where the parm is passed as an int or double
	     and it is converted to a char, short or float and stored back
	     in the parmlist.  In this case, describe the parm
	     with the variable's declared type, and adjust the address
	     if the least significant bytes (which we are using) are not
	     the first ones.  */
#ifdef BYTES_BIG_ENDIAN
	  if (TREE_TYPE (parms) != DECL_ARG_TYPE (parms))
	    current_sym_value +=
	      (GET_MODE_SIZE (TYPE_MODE (DECL_ARG_TYPE (parms)))
	       - GET_MODE_SIZE (GET_MODE (DECL_RTL (parms))));
#endif
	  if (GET_CODE (DECL_RTL (parms)) == MEM
	      && GET_CODE (XEXP (DECL_RTL (parms), 0)) == PLUS
	      && GET_CODE (XEXP (XEXP (DECL_RTL (parms), 0), 1)) == CONST_INT
	      && (INTVAL (XEXP (XEXP (DECL_RTL (parms), 0), 1))
		  == current_sym_value))
	    type = TREE_TYPE (parms);
	  else
	    {
	      current_sym_value = DECL_OFFSET (parms) / BITS_PER_UNIT;
	      type = DECL_ARG_TYPE (parms);
	    }
	}
     
      PUT_SDB_INT_VAL (current_sym_value);
      PUT_SDB_SCL (C_ARG);
      PUT_SDB_TYPE (plain_type (type));
      PUT_SDB_ENDEF;
    }
}

/* Output definitions, referring to registers,
   of all the parms in PARMS which are stored in registers during the function.
   PARMS is a chain of PARM_DECL nodes.
   This is done as part of starting the function.  */

static void
sdbout_reg_parms (parms)
     tree parms;
{
  while (parms)
    {
      if (GET_CODE (DECL_RTL (parms)) == REG
	  && REGNO (DECL_RTL (parms)) >= 0
	  && REGNO (DECL_RTL (parms)) < FIRST_PSEUDO_REGISTER)
	{
	  PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (parms)));
	  PUT_SDB_INT_VAL (DBX_REGISTER_NUMBER (REGNO (DECL_RTL (parms))));
  	  PUT_SDB_SCL (C_REG);
	  PUT_SDB_TYPE (plain_type (TREE_TYPE (parms), 0));
	  PUT_SDB_ENDEF;
	}
      else if (GET_CODE (DECL_RTL (parms)) == MEM
	       && GET_CODE (XEXP (DECL_RTL (parms), 0)) == PLUS
	       && GET_CODE (XEXP (XEXP (DECL_RTL (parms), 0), 1)) == CONST_INT)
	{
	  int offset = DECL_OFFSET (parms) / BITS_PER_UNIT;
	  /* A parm declared char is really passed as an int,
	     so it occupies the least significant bytes.
	     On a big-endian machine those are not the low-numbered ones.  */
#ifdef BYTES_BIG_ENDIAN
	  if (TREE_TYPE (parms) != DECL_ARG_TYPE (parms))
	    offset += (GET_MODE_SIZE (TYPE_MODE (DECL_ARG_TYPE (parms)))
		       - GET_MODE_SIZE (GET_MODE (DECL_RTL (parms))));
#endif
	  if (INTVAL (XEXP (XEXP (DECL_RTL (parms), 0), 1)) != offset)
	    {
	      PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (parms)));	      
	      PUT_SDB_INT_VAL (INTVAL (XEXP (XEXP (DECL_RTL (parms), 0), 1)));
	      PUT_SDB_SCL (C_AUTO);
	      PUT_SDB_TYPE (plain_type (TREE_TYPE (parms)));
	      PUT_SDB_ENDEF;
	    }
	}
      parms = TREE_CHAIN (parms);
    }
}

/* Describe the beginning of an internal block within a function.
   Also output descriptions of variables defined in this block.

   N is the number of the block, by order of beginning, counting from 1,
   and not counting the outermost (function top-level) block.
   The blocks match the LET_STMTS in DECL_INITIAL (current_function_decl),
   if the count starts at 0 for the outermost one.  */

void
sdbout_begin_block (file, line, n)
     FILE *file;
     int line;
     int n;
{
  tree decl = current_function_decl;
  fprintf (file,
	   "\t.def\t.bb;\t.val\t.;\t.scl\t100;\t.line\t%d;\t.endef\n",
	   line - sdb_begin_function_line);
  if (n == 1)
    {
      /* Include the outermost LET_STMT's variables in block 1.  */
      next_block_number = 0;
      do_block = 0;
      sdbout_block (DECL_INITIAL (decl), DECL_ARGUMENTS (decl));
    }
  next_block_number = 0;
  do_block = n;
  sdbout_block (DECL_INITIAL (decl), DECL_ARGUMENTS (decl));
}

/* Describe the end line-number of an internal block within a function.  */
	 
void
sdbout_end_block (file, line)
     FILE *file;
     int line;
{
  fprintf (file,
	   "\t.def\t.eb;.val\t.;\t.scl\t100;\t.line\t%d;\t.endef\n" ,
	   line - sdb_begin_function_line);
}

/* Called at beginning of function (after prologue).
   Record the function's starting line number, so we can output
   relative line numbers for the other lines.
   Describe beginning of outermost block.
   Also describe the parameter list.  */

void
sdbout_begin_function (line)
     int line;
{
  sdb_begin_function_line = line - 1;
  fprintf (asm_out_file,
	   "\t.def\t.bf;\t.val\t.;\t.scl\t101;\t.line\t%d;\t.endef\n",
	   line);
  sdbout_parms (DECL_ARGUMENTS (current_function_decl));
  sdbout_reg_parms (DECL_ARGUMENTS (current_function_decl));
}

/* Called at end of function (before epilogue).
   Describe end of outermost block.  */

void
sdbout_end_function (line)
     int line;
{
  fprintf (asm_out_file,
	   "\t.def\t.ef;\t.val\t.;\t.scl\t101;\t.line\t%d;\t.endef\n",
	   line - sdb_begin_function_line);
}

/* Output sdb info for the current function name.
   Called from assemble_function.  */

sdbout_mark_begin_function ()
{
  sdbout_symbol (current_function_decl, 0);
}

/* Output end-of-definition address for current function and linenumber.  */

void
sdbout_mark_end_function ()
{
  PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (current_function_decl)));
  fputs ("\t.val\t.;", asm_out_file);
  PUT_SDB_SCL (C_EFCN);
  PUT_SDB_ENDEF;
}

#endif
