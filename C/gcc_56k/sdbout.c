/* Output sdb-format symbol table information from GNU compiler.
   Copyright (C) 1988 Free Software Foundation, Inc.

   $Id: sdbout.c,v 1.16 92/04/22 10:48:39 pete Exp $

This file is part of GNU CC.

GNU CC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU CC; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */


#include "config.h"

#ifdef SDB_DEBUGGING_INFO

#include "tree.h"
#include "rtl.h"
#include <stdio.h>
#if defined( DSP56000 ) || defined( DSP96000 )
/*	Defines for "special" symbols   */

enum memory_map
{
    memory_map_p, 
    memory_map_x,
    memory_map_y,
    memory_map_l,
    memory_map_none,
    memory_map_error=666666
};

union addr_map
{
    enum memory_map mape;
    long l;
    unsigned long u;
};

struct core_addr_struct
{
    union addr_map w0;
    union addr_map w1;
};

typedef struct core_addr_struct CORE_ADDR;


#define _ETEXT	"etext"
#define _EDATA	"edata"
#define _END	"end"

#define _START	"__start"

/*
 *   STORAGE CLASSES
 */

#define  C_EFCN          -1    /* physical end of function */
#define  C_NULL          0
#define  C_AUTO          1     /* automatic variable */
#define  C_EXT           2     /* external symbol */
#define  C_STAT          3     /* static */
#define  C_REG           4     /* register variable */
#define  C_EXTDEF        5     /* external definition */
#define  C_LABEL         6     /* label */
#define  C_ULABEL        7     /* undefined label */
#define  C_MOS           8     /* member of structure */
#define  C_ARG           9     /* function argument */
#define  C_STRTAG        10    /* structure tag */
#define  C_MOU           11    /* member of union */
#define  C_UNTAG         12    /* union tag */
#define  C_TPDEF         13    /* type definition */
#define  C_USTATIC	 14    /* undefined static */
#define  C_ENTAG         15    /* enumeration tag */
#define  C_MOE           16    /* member of enumeration */
#define  C_REGPARM	 17    /* register parameter */
#define  C_FIELD         18    /* bit field */
#define  C_BLOCK         100   /* ".bb" or ".eb" */
#define  C_FCN           101   /* ".bf" or ".ef" */
#define  C_EOS           102   /* end of structure */
#define  C_FILE          103   /* file name */

	/*
	 * The following storage class is a "dummy" used only by STS
	 * for line number entries reformatted as symbol table entries
	 */

#define  C_LINE		 104
#define  C_ALIAS	 105   /* duplicate tag */
#define  C_HIDDEN	 106   /* special storage class for external */

/*		Number of characters in a symbol name */
#define  SYMNMLEN	8
/*		Number of characters in a file name */
#define  FILNMLEN	14
/*		Number of array dimensions in auxiliary entry */
#define  DIMNUM		4


struct syment
{
	union
	{
		char		_n_name[SYMNMLEN];	/* old COFF version */
		struct
		{
			long	_n_zeroes;	/* new == 0 */
			long	_n_offset;	/* offset into string table */
		} _n_n;
		char		*_n_nptr[2];	/* allows for overlaying */
	} _n;
	union {
		CORE_ADDR _n_address; /* when an address */
		unsigned long _n_val[2]; /* _n_val[0] is least significant */
		}_n_value;	/* value of symbol */
	short			n_scnum;	/* section number */
	unsigned short		n_type;		/* type and derived type */
	char			n_sclass;	/* storage class */
	char			n_numaux;	/* number of aux. entries */
};

#define n_name		_n._n_name
#define n_nptr		_n._n_nptr[1]
#define n_zeroes	_n._n_n._n_zeroes
#define n_offset	_n._n_n._n_offset
#define n_value _n_value._n_address
/*
   Relocatable symbols have a section number of the
   section in which they are defined.  Otherwise, section
   numbers have the following meanings:
*/
        /* undefined symbol */
#define  N_UNDEF	0
        /* value of symbol is absolute */
#define  N_ABS		-1
        /* special debugging symbol -- value of symbol is meaningless */
#define  N_DEBUG	-2

/*
   The fundamental type of a symbol packed into the low 
   4 bits of the word.
*/

#define  _EF	".ef"

#define  T_NULL     0
#define  T_ARG      1          /* function argument (only used by compiler) */
#define  T_CHAR     2          /* character */
#define  T_SHORT    3          /* short integer */
#define  T_INT      4          /* integer */
#define  T_LONG     5          /* long integer */
#define  T_FLOAT    6          /* floating point */
#define  T_DOUBLE   7          /* double word */
#define  T_STRUCT   8          /* structure  */
#define  T_UNION    9          /* union  */
#define  T_ENUM     10         /* enumeration  */
#define  T_MOE      11         /* member of enumeration */
#define  T_UCHAR    12         /* unsigned character */
#define  T_USHORT   13         /* unsigned short */
#define  T_UINT     14         /* unsigned integer */
#define  T_ULONG    15         /* unsigned long */

/*
 * derived types are:
 */

#define  DT_NON      0          /* no derived type */
#define  DT_PTR      1          /* pointer */
#define  DT_FCN      2          /* function */
#define  DT_ARY      3          /* array */

/*
 *   type packing constants
 */

#define  N_BTMASK     017
#define  N_TMASK      060
#define  N_TMASK1     0300
#define  N_TMASK2     0360
#define  N_BTSHFT     4
#define  N_TSHIFT     2

/*
 *   MACROS
 */

	/*   Basic Type of  x   */

#define  BTYPE(x)  ((x) & N_BTMASK)

	/*   Is  x  a  pointer ?   */

#define  ISPTR(x)  (((x) & N_TMASK) == (DT_PTR << N_BTSHFT))

	/*   Is  x  a  function ?  */

#define  ISFCN(x)  (((x) & N_TMASK) == (DT_FCN << N_BTSHFT))

	/*   Is  x  an  array ?   */

#define  ISARY(x)  (((x) & N_TMASK) == (DT_ARY << N_BTSHFT))

	/* Is x a structure, union, or enumeration TAG? */

#define ISTAG(x)  ((x)==C_STRTAG || (x)==C_UNTAG || (x)==C_ENTAG)

#define  INCREF(x) ((((x)&~N_BTMASK)<<N_TSHIFT)|(DT_PTR<<N_BTSHFT)|(x&N_BTMASK))

#define  DECREF(x) ((((x)>>N_TSHIFT)&~N_BTMASK)|((x)&N_BTMASK))

/*
 *	AUXILIARY ENTRY FORMAT
 */

union auxent
{
	struct
	{
		long		x_tagndx;	/* str, un, or enum tag indx */
		union
		{
			struct
			{
				unsigned short	x_lnno;	/* declaration line number */
				unsigned short	x_size;	/* str, union, array size */
			} x_lnsz;
			long	x_fsize;	/* size of function */
		} x_misc;
		union
		{
			struct			/* if ISFCN, tag, or .bb */
			{
				long	x_lnnoptr;	/* ptr to fcn line # */
				long	x_endndx;	/* entry ndx past block end */
			} 	x_fcn;
			struct			/* if ISARY, up to 4 dimen. */
			{
				unsigned short	x_dimen[DIMNUM];
			} 	x_ary;
		}		x_fcnary;
		unsigned short  x_tvndx;		/* tv index */
	} 	x_sym;
	struct
	{
		char	x_fname[FILNMLEN]; /* filename here if x_foff==0 */
		unsigned long x_foff; /* if !0 then x_fname in string table */
	} 	x_file;
        struct
        {
                long    x_scnlen;          /* section length */
                unsigned short  x_nreloc;  /* number of relocation entries */
                unsigned short  x_nlinno;  /* number of line numbers */
               unsigned long x_soff; /* section name offset in string table (for named sections) */
        }       x_scn;

	struct
	{
		long		x_tvfill;	/* tv fill value */
		unsigned short	x_tvlen;	/* length of .tv */
		unsigned short	x_tvran[2];	/* tv range */
	}	x_tv;	/* info about .tv section (in auxent of symbol .tv)) */
struct syment filler; /* to fill out to size of syment */
};

#define	SYMENT	struct syment
#define	SYMESZ	(sizeof(SYMENT))

#define	AUXENT	union auxent
#define	AUXESZ	(sizeof(AUXENT)) 

#endif
/* #include <storclass.h>  used to be this instead of syms.h.  */

/* Line number of beginning of current function, minus one.  */

int sdb_begin_function_line = 0;

/* Counter to generate unique "names" for nameless struct members.  */

static int unnamed_struct_number = 0;

extern FILE *asm_out_file;

extern tree current_function_decl;

#if defined( _MSDOS )
void warning ( char * s, ... );
#endif

void sdbout_init ();
void sdbout_symbol ();
void sdbout_tags();
void sdbout_types();

static void sdbout_syms ();
static void sdbout_one_type ();
static int plain_type_1 ();

/* Random macros describing parts of SDB data.  */

/* Put something here if lines get too long */
#define CONTIN

#ifndef PUT_SDB_SCL
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_SCL(a) fprintf(asm_out_file, "\t.scl\t%d;", (a))
#else
#define PUT_SDB_SCL(a) fprintf(asm_out_file, "\t.scl\t%d\n", (a))
#endif /* dsp */
#endif

#ifndef PUT_SDB_INT_VAL
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_INT_VAL(a) fprintf (asm_out_file, "\t.val\t%d;", (a))
#else
#define PUT_SDB_INT_VAL(a) fprintf (asm_out_file, "\t.val\t%d\n", (a))
#endif /* dsp */
#endif

#ifndef PUT_SDB_VAL
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_VAL(a)				\
( fputs ("\t.val\t", asm_out_file),		\
  output_addr_const (asm_out_file, (a)),	\
  fputc (';', asm_out_file))
#else
#define PUT_SDB_VAL(a)				\
( fputs ("\t.val\t", asm_out_file),		\
  output_addr_const (asm_out_file, (a)),	\
  fputc ('\n', asm_out_file))
#endif /* dsp */
#endif

#ifndef PUT_SDB_DEF
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_DEF(a)				\
do { fprintf (asm_out_file, "\t.def\t");	\
     ASM_OUTPUT_LABELREF (asm_out_file, a); 	\
     fprintf (asm_out_file, ";"); } while (0)
#else
#define PUT_SDB_DEF(a)				\
do { fprintf (asm_out_file, "\t.def\t");	\
     ASM_OUTPUT_LABELREF (asm_out_file, a); 	\
     fprintf (asm_out_file, "\n"); } while (0)
#endif
#endif

#ifndef PUT_SDB_PLAIN_DEF
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_PLAIN_DEF(a) fprintf(asm_out_file,"\t.def\t.%s;",a)
#else
#define PUT_SDB_PLAIN_DEF(a) fprintf(asm_out_file,"\t.def\t.%s\n",a)
#endif /* dsp */
#endif

#ifndef PUT_SDB_ENDEF
#define PUT_SDB_ENDEF fputs("\t.endef\n", asm_out_file)
#endif

#ifndef PUT_SDB_TYPE
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_TYPE(a) fprintf(asm_out_file, "\t.type\t0%o;", a)
#else
#define PUT_SDB_TYPE(a) fprintf(asm_out_file, "\t.type\t$%x\n", a)
#endif /* dsp */
#endif

#ifndef PUT_SDB_SIZE
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_SIZE(a) fprintf(asm_out_file, "\t.size\t%d;", a)
#else
#define PUT_SDB_SIZE(a) fprintf(asm_out_file, "\t.size\t%d\n", a)
#endif /* dsp */
#endif

#ifndef PUT_SDB_DIM
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_DIM(a) fprintf(asm_out_file, "\t.dim\t%d;", a)
#else
#define PUT_SDB_DIM(a) fprintf(asm_out_file, "\t.dim\t%d\n", a)
#endif /* dsp */
#endif

#ifndef PUT_SDB_TAG
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_TAG(a)				\
do { fprintf (asm_out_file, "\t.tag\t");	\
     ASM_OUTPUT_LABELREF (asm_out_file, a);	\
     fprintf (asm_out_file, ";"); } while (0)
#else
#define PUT_SDB_TAG(a)				\
do { fprintf (asm_out_file, "\t.tag\t");	\
     ASM_OUTPUT_LABELREF (asm_out_file, a);	\
     fprintf (asm_out_file, "\n"); } while (0)
#endif /* dsp */
#endif

#ifndef PUT_SDB_BLOCK_START
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_BLOCK_START(LINE)		\
  fprintf (asm_out_file,			\
	   "\t.def\t.bb;\t.val\t.;\t.scl\t100;\t.line\t%d;\t.endef\n",	\
	   (LINE))
#else
#define PUT_SDB_BLOCK_START(LINE)		\
    fprintf( asm_out_file, "\t.bb\t%d\n", (LINE) )
#endif /* dsp5/96k */
#endif

#ifndef PUT_SDB_BLOCK_END
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_BLOCK_END(LINE)			\
  fprintf (asm_out_file,			\
	   "\t.def\t.eb;.val\t.;\t.scl\t100;\t.line\t%d;\t.endef\n",	\
	   (LINE))
#else
#define PUT_SDB_BLOCK_END(LINE)			\
    fprintf( asm_out_file, "\t.eb\t%d\n", (LINE) )
#endif /* dsp */
#endif

#ifndef PUT_SDB_FUNCTION_START
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_FUNCTION_START(LINE)		\
  fprintf (asm_out_file,			\
	   "\t.def\t.bf;\t.val\t.;\t.scl\t101;\t.line\t%d;\t.endef\n",	\
	   (LINE))
#else
#define PUT_SDB_FUNCTION_START(LINE)		\
    fprintf( asm_out_file, "\t.bf\t%d,%d\n", (LINE), logue_index )
#endif /* dsp */
#endif

#ifndef PUT_SDB_FUNCTION_END
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_FUNCTION_END(LINE)		\
  fprintf (asm_out_file,			\
	   "\t.def\t.ef;\t.val\t.;\t.scl\t101;\t.line\t%d;\t.endef\n",	\
	   (LINE))
#else
#define PUT_SDB_FUNCTION_END(LINE)		\
    fprintf( asm_out_file, "\t.ef\t%d\n", (LINE) )
#endif /* dsp */
#endif

#ifndef PUT_SDB_EPILOGUE_END
#if ! defined( DSP56000 ) && ! defined( DSP96000 )
#define PUT_SDB_EPILOGUE_END(NAME)		\
  fprintf (asm_out_file,			\
	   "\t.def\t%s;\t.val\t.;\t.scl\t-1;\t.endef\n",	\
	   (NAME))
#else
#define PUT_SDB_EPILOGUE_END(NAME)		\
  fprintf (asm_out_file,			\
	   "\t.def\tF%s\n\t.val\t*\n\t.scl\t-1\n\t.endef\n",	\
	   (NAME))
#endif /* dsp */
#endif

#ifndef SDB_GENERATE_FAKE
#define SDB_GENERATE_FAKE(BUFFER, NUMBER) \
  sprintf ((BUFFER), ".%dfake", (NUMBER));
#endif

/* Return the sdb tag identifier string for TYPE
   if TYPE has already been defined; otherwise return a null pointer.   */
  
#define KNOWN_TYPE_TAG(type) (char *)(TYPE_SYMTAB_ADDRESS (type))

/* Set the sdb tag identifier string for TYPE to NAME.  */

#define SET_KNOWN_TYPE_TAG(TYPE, NAME) \
  (TYPE_SYMTAB_ADDRESS (TYPE) = (int)(NAME))

/* Return the name (a string) of the struct, union or enum tag
   described by the TREE_LIST node LINK.  This is 0 for an anonymous one.  */

#define TAG_NAME(link) \
  (((link) && TREE_PURPOSE ((link)) \
    && IDENTIFIER_POINTER (TREE_PURPOSE ((link)))) \
   ? IDENTIFIER_POINTER (TREE_PURPOSE ((link))) : (char *) 0)

/* Ensure we don't output a negative line number.  */
#define MAKE_LINE_SAFE(line)  \
  if (line <= sdb_begin_function_line) line = sdb_begin_function_line + 1

/* Tell the assembler the source file name.
   On systems that use SDB, this is done whether or not -g,
   so it is called by ASM_FILE_START.

   ASM_FILE is the assembler code output file,
   INPUT_NAME is the name of the main input file.  */

void
sdbout_filename (asm_file, input_name)
     FILE *asm_file;
     char *input_name;
{
#if defined( DSP56000 ) || defined( DSP96000 )
#ifdef ASM_OUTPUT_SOURCE_FILENAME
  ASM_OUTPUT_SOURCE_FILENAME (asm_file, input_name);
#else
  fprintf (asm_file, "\t.file\t\"%s\",%d\n", input_name,
	   (( 'l' == memory_model ) ? 3 : (( 'x' == memory_model ) ? 2 : 1 )));
#endif
#else
  int len = strlen (input_name);
  char *na = input_name + len;

  /* we want the path here */
  /* NA gets INPUT_NAME sans directory names.  */
  while (na > input_name)
    {
      if (na[-1] == '/')
	break;
      na--;
    }

#ifdef ASM_OUTPUT_SOURCE_FILENAME
  ASM_OUTPUT_SOURCE_FILENAME (asm_file, na);
#else
  fprintf (asm_file, "\t.file\t\"%s\"\n", na);
#endif
#endif
}

/* Set up for SDB output at the start of compilation.  */

void
sdbout_init ()
{
  /* Output all the initial permanent types.  */
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
  SDB_GENERATE_FAKE (label, unnamed_struct_number);
  unnamed_struct_number++;
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
#if defined( DSP56000 ) || defined( DSP96000 )
static int push_derived_level( );
#define PUSH_DERIVED_LEVEL(DT_type,PREV) \
  push_derived_level(DT_type,PREV)
#else
#define PUSH_DERIVED_LEVEL(DT_type,PREV) \
  ((((PREV)&~N_BTMASK)<<N_TSHIFT)|(DT_type<<N_BTSHFT)|(PREV&N_BTMASK))
#endif

static int
plain_type (type)
     tree type;
{
  int val = plain_type_1 (type);
  if (TREE_CODE (type) == ARRAY_TYPE)
    {
      int size = int_size_in_bytes (type);
      /* Don't kill sdb if type is not laid out or has variable size.  */
      if (size < 0)
	size = 0;
      PUT_SDB_SIZE (size);
    }
  return val;
}

static void
sdbout_record_type_name (type)
     tree type;
{
  char *name = 0;

  if (KNOWN_TYPE_TAG (type))
    return;

  if (TYPE_NAME (type) != 0) 
    {
      tree t = 0;
      /* Find the IDENTIFIER_NODE for the type name.  */
      if (TREE_CODE (TYPE_NAME (type)) == IDENTIFIER_NODE)
	{
	  t = TYPE_NAME (type);
	}
      else if (TREE_CODE (TYPE_NAME (type)) == TYPE_DECL)
	{
	  t = DECL_NAME (TYPE_NAME (type));
	}

      /* Now get the name as a string, or invent one.  */
      if (t != 0)
	name = IDENTIFIER_POINTER (t);
    }

  if (name == 0)
    name = gen_fake_label ();

  SET_KNOWN_TYPE_TAG (type, name);
}

static int
plain_type_1 (type)
    tree type;
{
    if (type == 0)
    {
	type = void_type_node;
    }
    
    if (type == error_mark_node)
    {
	type = integer_type_node;
    }
    
    type = TYPE_MAIN_VARIANT (type);

    switch (TREE_CODE (type))
    {
    case VOID_TYPE:
	return T_INT;
	
    case INTEGER_TYPE:
	switch (int_size_in_bytes (type))
	{
#if ! defined( DSP56000 ) && ! defined ( DSP96000 )
	case 4:
	    return (TREE_UNSIGNED (type) ? T_UINT : T_INT);
	case 1:
	    return (TREE_UNSIGNED (type) ? T_UCHAR : T_CHAR);
	case 2:
	    return (TREE_UNSIGNED (type) ? T_USHORT : T_SHORT);
#else
	    /* char, short, int are all same size */
	    /* don't forget that long is also the same size in l-memory */
	case 1:
	    if ( char_type_node == type )
	    {
		return T_CHAR;
	    }
	    else if ( unsigned_char_type_node == type )
	    {
		return T_UCHAR;
	    }
	    else if ( long_integer_type_node == type )
	    {
		return T_LONG;
	    }
	    else if ( long_unsigned_type_node == type )
	    {
		return T_ULONG;
	    }
	    else
	    {
		return (TREE_UNSIGNED (type) ? T_UINT : T_INT);
	    }

	case 2:
	    return(TREE_UNSIGNED (type) ? T_ULONG : T_LONG);
#endif
	default:
	    return 0;
	}

    case REAL_TYPE:
	switch (int_size_in_bytes (type))
	{
#if defined( DSP56000 ) || defined( DSP96000 )
	default:
	    return (( double_type_node == type ) ? T_DOUBLE : T_FLOAT );
#else
	case 4:
	    return T_FLOAT;
	default:
	    return T_DOUBLE;
#endif
	}

    case ARRAY_TYPE:
    {
	int m = plain_type (TREE_TYPE (type));
	PUT_SDB_DIM (TYPE_DOMAIN (type)
		     ? TREE_INT_CST_LOW (TYPE_MAX_VALUE (TYPE_DOMAIN (type))) + 1
		     : 0);
	return PUSH_DERIVED_LEVEL (DT_ARY, m);
    }

    case RECORD_TYPE:
    case UNION_TYPE:
    case ENUMERAL_TYPE:
    {
	char *tag;
	int size;
	sdbout_record_type_name (type);

	if (TREE_ASM_WRITTEN (type))
	{
	    /* Output the referenced structure tag name
	       only if the .def has already been output.
	       At least on 386, the Unix assembler
	       cannot handle forward references to tags.  */
	    tag = KNOWN_TYPE_TAG (type);
	    PUT_SDB_TAG (tag);
	}
	size = int_size_in_bytes (type);

	if (size < 0)
	{
	    size = 0;
	}
	
	PUT_SDB_SIZE (size);

	return ((TREE_CODE (type) == RECORD_TYPE) ? T_STRUCT
		: (TREE_CODE (type) == UNION_TYPE) ? T_UNION
		: T_ENUM);
    }

    case POINTER_TYPE:
    case REFERENCE_TYPE:
    {
	int m = plain_type (TREE_TYPE (type));
	return PUSH_DERIVED_LEVEL (DT_PTR, m);
    }

    case FUNCTION_TYPE:
    case METHOD_TYPE:
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
	  /* Ignore LET_STMTs for blocks never really used to make RTL.  */
	  if (! TREE_USED (stmt))
	    break;
	  /* When we reach the specified block, output its symbols.  */
	  if (next_block_number == do_block)
	    {
	      sdbout_tags (STMT_TYPE_TAGS (stmt));
	      sdbout_syms (STMT_VARS (stmt));
	    }

	  /* If we are past the specified block, stop the scan.  */
	  if (next_block_number > do_block)
	    return;

	  next_block_number++;

	  /* Scan the blocks within this block.  */
	  sdbout_block (STMT_SUBBLOCKS (stmt));
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
#if defined( __WATCOMC__ )
	extern tree gettags();
#endif
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
#if defined( DSP56000 ) || defined( DSP56100 ) || defined( DSP96000 )
      put_sdb_def( decl );
#else
      PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (decl)));
#endif

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
	       && GET_CODE (XEXP (DECL_RTL (decl), 0)) == PLUS
	       && GET_CODE (XEXP (XEXP (DECL_RTL (decl), 0), 0)) == REG
	       && GET_CODE (XEXP (XEXP (DECL_RTL (decl), 0), 1)) == CONST_INT)
	{
	  /* DECL_RTL looks like (MEM (PLUS (REG...) (CONST_INT...))).
	     We want the value of that CONST_INT.  */
	  PUT_SDB_INT_VAL (INTVAL (XEXP (XEXP (DECL_RTL (decl), 0), 1)));
	  PUT_SDB_SCL (C_AUTO);
	}
      else
	{
	  /* It is something we don't know how to represent for SDB.  */
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
	  && TYPE_SIZE (type) != 0)
	sdbout_one_type (type);
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
    sdbout_one_type (link);
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

/* Output types of the fields of type TYPE, if they are structs.
   Don't chase through pointer types, since that could be circular.
   They must come before TYPE, since forward refs are not allowed.

   This is not actually used, since the COFF assembler rejects the
   results.  No one knows why it rejects them.  */

static void
sdbout_field_types (type)
     tree type;
{
  tree tail;
  for (tail = TYPE_FIELDS (type); tail; tail = TREE_CHAIN (tail))
    sdbout_one_type (TREE_TYPE (tail));
}

/* Use this to put out the top level defined record and union types
   for later reference.  If this is a struct with a name, then put that
   name out.  Other unnamed structs will have .xxfake labels generated so
   that they may be referred to later.
   The label will be stored in the KNOWN_TYPE_TAG slot of a type.
   It may NOT be called recursively.  */

static void
sdbout_one_type (type)
     tree type;
{
  text_section ();

  switch (TREE_CODE (type))
    {
    case RECORD_TYPE:
    case UNION_TYPE:
    case ENUMERAL_TYPE:
      type = TYPE_MAIN_VARIANT (type);
      /* Don't output a type twice.  */
      if (TREE_ASM_WRITTEN (type))
	return;

      TREE_ASM_WRITTEN (type) = 1;
#if 0  /* This change, which ought to make better output,
	  makes the COFF assembler unhappy.  */
      /* Before really doing anything, output types we want to refer to.  */
      if (TREE_CODE (type) != ENUMERAL_TYPE)
	sdbout_field_types (type);
#endif

      sdbout_record_type_name (type);

      /* Output a structure type.  */
      {
	int size = int_size_in_bytes (type);
	int member_scl;
	tree tem;

	PUT_SDB_DEF (KNOWN_TYPE_TAG (type));

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
		if (TREE_PACKED (tem))
		  {
		    PUT_SDB_INT_VAL (DECL_OFFSET (tem));
		    PUT_SDB_SCL (C_FIELD);
		    sdbout_type (TREE_TYPE (tem));
		    PUT_SDB_SIZE (TREE_INT_CST_LOW (DECL_SIZE (tem))
				  * DECL_SIZE_UNIT (tem));
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
   
	PUT_SDB_PLAIN_DEF ("eos");
	PUT_SDB_INT_VAL (size);
	PUT_SDB_SCL (C_EOS);
	PUT_SDB_TAG (KNOWN_TYPE_TAG (type));
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

      if (DECL_NAME (parms))
	PUT_SDB_DEF (IDENTIFIER_POINTER (DECL_NAME (parms)));
      else
	PUT_SDB_DEF (gen_fake_label ());

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
     
#if defined( DSP56000 ) || defined( DSP96000 )
      if (GET_CODE (DECL_RTL (parms)) == REG
	  && REGNO (DECL_RTL (parms)) >= 0
	  && REGNO (DECL_RTL (parms)) < FIRST_PSEUDO_REGISTER)
      {
	  PUT_SDB_INT_VAL (DBX_REGISTER_NUMBER (REGNO (DECL_RTL (parms))));
  	  PUT_SDB_SCL (C_REGPARM);
	  PUT_SDB_TYPE (plain_type (type));
	  PUT_SDB_ENDEF;
      }
      else
      {
	  PUT_SDB_INT_VAL (current_sym_value);
	  PUT_SDB_SCL (C_ARG);
	  PUT_SDB_TYPE (plain_type (type));
	  PUT_SDB_ENDEF;
      }
#else
      PUT_SDB_INT_VAL (current_sym_value);
      PUT_SDB_SCL (C_ARG);
      PUT_SDB_TYPE (plain_type (type));
      PUT_SDB_ENDEF;
#endif
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
#if defined( DSP56000 ) || defined( DSP96000 )
	  PUT_SDB_TYPE (plain_type (TREE_TYPE (parms)));
#else
	  PUT_SDB_TYPE (plain_type (TREE_TYPE (parms), 0));
#endif
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
  MAKE_LINE_SAFE (line);
  PUT_SDB_BLOCK_START (line - sdb_begin_function_line);
  if (n == 1)
    {
      /* Include the outermost LET_STMT's variables in block 1.  */
      next_block_number = 0;
      do_block = 0;
#if defined( DSP56000 ) || defined( DSP96000 )
      sdbout_block (DECL_INITIAL (decl));
#else
      sdbout_block (DECL_INITIAL (decl), DECL_ARGUMENTS (decl));
#endif
    }
  next_block_number = 0;
  do_block = n;
#if defined( DSP56000 ) || defined( DSP96000 )
  sdbout_block (DECL_INITIAL (decl));
#else
  sdbout_block (DECL_INITIAL (decl), DECL_ARGUMENTS (decl));
#endif
}

/* Describe the end line-number of an internal block within a function.  */
	 
void
sdbout_end_block (file, line)
     FILE *file;
     int line;
{
  MAKE_LINE_SAFE (line);
  PUT_SDB_BLOCK_END (line - sdb_begin_function_line);
}

/* Output sdb info for the current function name.
   Called from assemble_function.  */

void
sdbout_mark_begin_function ()
{
  sdbout_symbol (current_function_decl, 0);
}

/* Called at beginning of function body (after prologue).
   Record the function's starting line number, so we can output
   relative line numbers for the other lines.
   Describe beginning of outermost block.
   Also describe the parameter list.  */

void
sdbout_begin_function (line)
     int line;
{
  sdb_begin_function_line = line - 1;
  PUT_SDB_FUNCTION_START (line);
  sdbout_parms (DECL_ARGUMENTS (current_function_decl));
  sdbout_reg_parms (DECL_ARGUMENTS (current_function_decl));
}

/* Called at end of function (before epilogue).
   Describe end of outermost block.  */

void
sdbout_end_function (line)
     int line;
{
  MAKE_LINE_SAFE (line);
  PUT_SDB_FUNCTION_END (line - sdb_begin_function_line);

  /* Indicate we are between functions, for line-number output.  */
  sdb_begin_function_line = 0;
}

/* Output sdb info for the absolute end of a function.
   Called after the epilogue is output.  */

void
sdbout_end_epilogue ()
{
  char *name = IDENTIFIER_POINTER (DECL_NAME (current_function_decl));
  PUT_SDB_EPILOGUE_END (name);
}

#if defined( DSP56000 ) || defined( DSP56100 ) || defined( DSP96000 )
static int
push_derived_level ( dt_type, prev )
    int dt_type, prev;
{
    int result = ((((prev)&~N_BTMASK)<<N_TSHIFT)|(dt_type<<N_BTSHFT)|(prev&N_BTMASK));
    
    if ( 0xffff0000 & result )
    {
	/* if we have a type bigger than 16 bits, the assembler (and coff in 
	   general) will not accept it. */

	warning( "derived type too big for coff: this will affect debugging only." );
	
	return prev;
    }
    return result;
}

put_sdb_def( decl )
    tree decl;
{
    fputs( "\t.def\t", asm_out_file);

    /* check to see if the "value was changed by the programmer using the
       god damn __asm construct */
    if ( GET_CODE( DECL_RTL( decl ) ) ==  MEM &&
	 GET_CODE( XEXP( DECL_RTL( decl ), 0 ) ) == SYMBOL_REF )
    {
	assemble_name( asm_out_file, XSTR( XEXP( DECL_RTL( decl ), 0 ), 0 ) );
    }
    else
	ASM_OUTPUT_LABELREF( asm_out_file, IDENTIFIER_POINTER( DECL_NAME( decl ) ) );

    fputc( '\n', asm_out_file );
}
#endif
#endif /* SDB_DEBUGGING_INFO */
