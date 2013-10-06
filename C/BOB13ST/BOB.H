/* bob.h - bob definitions */
/*
	Copyright (c) 1991, by David Michael Betz
	All rights reserved
*/

#include <stdio.h>
#include <ctype.h>

/* limits */
#define TKNSIZE		50		/* maximum token size */
#define SMAX		500		/* runtime stack size */
#define CMAX		32767	/* code buffer size */

/* useful definitions */
#define TRUE		1
#define FALSE		0

/* token definitions */
#define T_NOTOKEN	-1
#define T_EOF		 0

/* non-character tokens */
#define _TMIN			256
#define T_STRING		256
#define T_IDENTIFIER	257
#define T_NUMBER		258
#define T_CLASS			259
#define T_STATIC		260
#define T_IF			261
#define T_ELSE			262
#define T_WHILE			263
#define T_RETURN		264
#define T_FOR			265
#define T_BREAK			266
#define T_CONTINUE		267
#define T_DO			268
#define T_NEW			269
#define T_NIL			270
#define T_LE			271	/* '<=' */
#define T_EQ			272	/* '==' */
#define T_NE			273	/* '!=' */
#define T_GE			274	/* '>=' */
#define T_SHL			275	/* '<<' */
#define T_SHR			276	/* '>>' */
#define T_AND			277	/* '&&' */
#define T_OR			278	/* '||' */
#define T_INC			279	/* '++' */
#define T_DEC			280	/* '--' */
#define T_ADDEQ			281	/* '+=' */
#define T_SUBEQ			282	/* '-=' */
#define T_MULEQ			283	/* '*=' */
#define T_DIVEQ			284	/* '/=' */
#define T_REMEQ			285	/* '%=' */
#define T_ANDEQ			286	/* '&=' */
#define T_OREQ			287	/* '|=' */
#define T_XOREQ			288	/* '^=' */
#define T_SHLEQ			289	/* '<<=' */
#define T_SHREQ			290	/* '>>=' */
#define T_CC			291	/* '::' */
#define T_MEMREF		292	/* '->' */
#define _TMAX			292

/* stack manipulation macros */
#define check(n)	 	 { if (sp - (n) < stkbase) stackover(); }
#define chktype(o,t)	 { if (sp[o].v_type != t) badtype(o,t); }
#define push(x,t,f)	 	 (--sp, sp->v_type = (t), sp->v.f = (x))
#define push_integer(x)	 push(x,DT_INTEGER,v_integer)
#define push_class(x)	 push(x,DT_CLASS,v_class)
#define push_object(x)	 push(x,DT_OBJECT,v_object)
#define push_bytecode(x) push(x,DT_BYTECODE,v_vector)
#define push_var(x)	 	 push(x,DT_VAR,v_var)
#define push_nil()	 	 (--sp, sp->v_type = DT_NIL)

/* macros to set values */
#define set(s,x,t,f)	    ((s)->v.f = (x), (s)->v_type = (t))
#define set_integer(s,x)    set(s,x,DT_INTEGER,v_integer)
#define set_class(s,x)	    set(s,x,DT_CLASS,v_class)
#define set_object(s,x)     set(s,x,DT_OBJECT,v_object)
#define set_code(s,x)       set(s,x,DT_CODE,v_code)
#define set_bytecode(s,x)   set(s,x,DT_BYTECODE,v_vector)
#define set_dictionary(s,x) set(s,x,DT_DICTIONARY,v_dictionary)
#define set_var(s,x)        set(s,x,DT_VAR,v_var)
#define set_string(s,x)	    set(s,x,DT_STRING,v_string)
#define set_vector(s,x)	    set(s,x,DT_VECTOR,v_vector)
#define set_file(s,x)	    set(s,x,DT_FILE,v_fp)
#define set_nil(s)	    	((s)->v_type = DT_NIL)

/* value field access macros */
#define valtype(x)			((x)->v_type)
#define isnil(x)			((x)->v_type == DT_NIL)

/* class field access macros */
#define claddr(x)			((x)->v.v_class)
#define clgetname(x)		(&claddr(x)->cl_name)
#define clgetbase(x)		(&claddr(x)->cl_base)
#define clgetmembers(x)		(&claddr(x)->cl_members)
#define clgetfunctions(x)	(&claddr(x)->cl_functions)
#define clgetsize(x)		(claddr(x)->cl_size)

/* object field access macros */
#define objaddr(x)			((x)->v.v_object)
#define objgetclass(x)		(&objaddr(x)->obj_class)
#define objgetmember(x,i)	(&objaddr(x)->obj_members[i])
#define objsetmember(x,i,v)	(objaddr(x)->obj_members[i] = (v))

/* vector field access macros */
#define vecaddr(x)				((x)->v.v_vector)
#define vecgetsize(x)			(vecaddr(x)->vec_size)
#define vecgetelement(x,i)		(&vecaddr(x)->vec_data[i])
#define vecsetelement(x,i,v)	(vecaddr(x)->vec_data[i] = (v))

/* string field access macros */
#define straddr(x)			((x)->v.v_string)
#define strgetsize(x)		(straddr(x)->str_size)
#define strgetdata(x)		(straddr(x)->str_data)

/* dictionary field access macros */
#define diaddr(x)			((x)->v.v_dictionary)
#define digetclass(x)		(&diaddr(x)->di_class)
#define digetcontents(x)	(&diaddr(x)->di_contents)

/* dictionary entry field access macros */
#define deaddr(x)			((x)->v.v_var)
#define degetdictionary(x)	(&deaddr(x)->de_dictionary)
#define degetkey(x)			(&deaddr(x)->de_key)
#define degetvalue(x)		(&deaddr(x)->de_value)
#define degetnext(x)		(&deaddr(x)->de_next)
#define degettype(x)		(deaddr(x)->de_type)

/* value descriptor structure */
typedef struct value 
{
	int v_type;								/* data type */
	union 
	{										/* value */
		struct class *v_class;				/*   class (in heap) */
		struct object *v_object;			/*   object (in heap) */
		struct vector *v_vector;			/*   vector (in heap) */
		struct string *v_string;    		/*   string (in heap) */
		struct dictionary *v_dictionary;	/*   dictionary (in heap) */
		struct dict_entry *v_var;			/*   variable (in heap) */
		int (*v_code)();					/*   code for built-in function */
		long v_integer;						/*   integer */
		FILE *v_fp;							/*   file pointer */
		struct hdr *v_hdr;					/*   (used by garbage collector) */
		struct value *v_chain;				/*   (used by garbage collector) */
	} v;
} VALUE;

typedef struct hdr 
{
    char   hdr_type;
    char   hdr_flags;
    VALUE *hdr_chain;
} HDR;

typedef struct class 
{
    HDR   cl_hdr;
    VALUE cl_name;
    VALUE cl_base;
    VALUE cl_members;
    VALUE cl_functions;
    int   cl_size;
} CLASS;

typedef struct object 
{
    HDR   obj_hdr;
    VALUE obj_class;
    VALUE obj_members[1];
} OBJECT;

typedef struct vector 
{
    HDR   vec_hdr;
    int   vec_size;
    VALUE vec_data[1];
} VECTOR;

typedef struct string 
{
    HDR  str_hdr;
    int  str_size;
    char str_data[1];
} STRING;

typedef struct dictionary 
{
    HDR   di_hdr;
    VALUE di_class;
    VALUE di_contents;
} DICTIONARY;

/* dictionary entry structure */
typedef struct dict_entry 
{
    HDR   de_hdr;
    VALUE de_dictionary;	/* backpointer to dictionary */
    VALUE de_key;			/* symbol name */
    int   de_type;			/* symbol type */
    VALUE de_value;			/* symbol value */
    VALUE de_next;			/* next entry */
} DICT_ENTRY;

/* symbol types */
#define ST_CLASS		1	/* class definition */
#define ST_DATA			2	/* data member */
#define ST_SDATA		3	/* static data member */
#define ST_FUNCTION		4	/* function member */
#define ST_SFUNCTION	5	/* static function member */

/* data types */
#define _DTMIN			0
#define DT_NIL			0
#define DT_CLASS		1
#define DT_OBJECT		2
#define DT_VECTOR		3
#define DT_INTEGER		4
#define DT_STRING		5
#define DT_BYTECODE		6
#define DT_CODE			7
#define DT_DICTIONARY	8
#define DT_VAR			9
#define DT_FILE			10
#define _DTMAX			10

/* function argument structure */
typedef struct argument 
{
    char *arg_name;				/* argument name */
    struct argument *arg_next;	/* next argument */
} ARGUMENT;

/* literal structure */
typedef struct literal 
{
    VALUE lit_value;			/* literal value */
    struct literal *lit_next;	/* next literal */
} LITERAL;

/* opcodes */
#define OP_BRT		0x01	/* branch on true */
#define OP_BRF		0x02	/* branch on false */
#define OP_BR		0x03	/* branch unconditionally */
#define OP_NIL		0x04	/* load top of stack with nil */
#define OP_PUSH		0x05	/* push nil onto stack */
#define OP_NOT		0x06	/* logical negate top of stack */
#define OP_NEG		0x07	/* negate top of stack */
#define OP_ADD		0x08	/* add top two stack entries */
#define OP_SUB		0x09	/* subtract top two stack entries */
#define OP_MUL		0x0A	/* multiply top two stack entries */
#define OP_DIV		0x0B	/* divide top two stack entries */
#define OP_REM		0x0C	/* remainder of top two stack entries */
#define OP_BAND		0x0D	/* bitwise and of top two stack entries */
#define OP_BOR		0x0E	/* bitwise or of top two stack entries */
#define OP_XOR		0x0F	/* bitwise xor of top two stack entries */
#define OP_BNOT		0x10	/* bitwise not of top two stack entries */
#define OP_SHL		0x11	/* shift left top two stack entries */
#define OP_SHR		0x12	/* shift right top two stack entries */
#define OP_LT		0x13	/* less than */
#define OP_LE		0x14	/* less than or equal to */
#define OP_EQ		0x15	/* equal to */
#define OP_NE		0x16	/* not equal to */
#define OP_GE		0x17	/* greater than or equal to */
#define OP_GT		0x18	/* greater than */
#define OP_INC		0x19	/* increment */
#define OP_DEC		0x1A	/* decrement */
#define OP_LIT		0x1B	/* load literal */
#define OP_RETURN	0x1C	/* return from interpreter */
#define OP_CALL		0x1D	/* call a function */
#define OP_REF		0x1E	/* load a variable value */
#define OP_SET		0x1F	/* set the value of a variable */
#define OP_VREF		0x20	/* load a vector element */
#define OP_VSET		0x21	/* set a vector element */
#define OP_MREF		0x22	/* load a member variable value */
#define OP_MSET		0x23	/* set a member variable */
#define OP_AREF		0x24	/* load an argument value */
#define OP_ASET		0x25	/* set an argument value */
#define OP_TREF		0x26	/* load a temporary variable value */
#define OP_TSET		0x27	/* set a temporary variable */
#define OP_TSPACE	0x28	/* allocate temporary variable space */
#define OP_SEND		0x29	/* send a message to an object */
#define OP_DUP2		0x2A	/* duplicate top two elements on the stack */
#define OP_NEW		0x2B	/* create a new class object */

/* external variables */
extern VALUE *stkbase,*sp,*fp,*stktop;
extern VALUE  nil;

/* external routines */
extern CLASS *newclass();
extern OBJECT *newobject();
extern VECTOR *newvector();
extern STRING *newstring();
extern STRING *makestring();
extern DICTIONARY *newdictionary();
extern DICT_ENTRY *findentry();
extern DICT_ENTRY *addentry();
extern char *getcstring();
