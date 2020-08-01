/* xlisp - a small subset of lisp */
/*	Copyright (c) 1985, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

/* system specific definitions */
/*#define _TURBOC_*/

#include <stdio.h>
#include <ctype.h>
#include <setjmp.h>

/* NNODES	number of nodes to allocate in each request (1000) */
/* EDEPTH	evaluation stack depth (2000) */
/* ADEPTH	argument stack depth (1000) */
/* FORWARD	type of a forward declaration () */
/* LOCAL	type of a local function (static) */
/* AFMT		printf format for addresses ("%x") */
/* FIXTYPE	data type for fixed point numbers (long) */
/* ITYPE	fixed point input conversion routine type (long atol()) */
/* ICNV		fixed point input conversion routine (atol) */
/* IFMT		printf format for fixed point numbers ("%ld") */
/* FLOTYPE	data type for floating point numbers (float) */
/* OFFTYPE	number the size of an address (int) */

/* for the Turbo C compiler - MS-DOS, large model */
#ifdef _TURBOC_
#define NNODES		2000
#define AFMT		"%lx"
#define OFFTYPE		long
#define SAVERESTORE
#endif

/* for the AZTEC C compiler - MS-DOS, large model */
#ifdef AZTEC_LM
#define NNODES		2000
#define AFMT		"%lx"
#define OFFTYPE		long
#define CVPTR(x)	ptrtoabs(x)
#define NIL		(void *)0
extern long ptrtoabs();
#define SAVERESTORE
#endif

/* for the AZTEC C compiler - Macintosh */
#ifdef AZTEC_MAC
#define NNODES		2000
#define AFMT		"%lx"
#define OFFTYPE		long
#define NIL		(void *)0
#define SAVERESTORE
#endif

/* for the AZTEC C compiler - Amiga */
#ifdef AZTEC_AMIGA
#define NNODES		2000
#define AFMT		"%lx"
#define OFFTYPE		long
#define NIL		(void *)0
#define SAVERESTORE
#endif

/* for the Lightspeed C compiler - Macintosh */
#ifdef LSC
#define NNODES		2000
#define AFMT		"%lx"
#define OFFTYPE		long
#define NIL		(void *)0
#define SAVERESTORE
#endif

/* for the Microsoft C compiler - MS-DOS, large model */
#ifdef MSC
#define NNODES		2000
#define AFMT		"%lx"
#define OFFTYPE		long
#endif

/* for the Mark Williams C compiler - Atari ST */
#ifdef MWC
#define AFMT		"%lx"
#define OFFTYPE		long
#endif

/* for the Lattice C compiler - Atari ST */
#ifdef LATTICE
#define FIXTYPE		int
#define ITYPE		int atoi()
#define ICNV(n)		atoi(n)
#define IFMT		"%d"
#endif

/* for the Digital Research C compiler - Atari ST */
#ifdef DR
#define LOCAL
#define AFMT		"%lx"
#define OFFTYPE		long
#undef NULL
#define NULL		0L
#endif

/* default important definitions */
#ifndef NNODES
#define NNODES		1000
#endif
#ifndef EDEPTH
#define EDEPTH		2000
#endif
#ifndef ADEPTH
#define ADEPTH		1000
#endif
#ifndef FORWARD
#define FORWARD
#endif
#ifndef LOCAL
#define LOCAL		static
#endif
#ifndef AFMT
#define AFMT		"%x"
#endif
#ifndef FIXTYPE
#define FIXTYPE		long
#endif
#ifndef ITYPE
#define ITYPE		long atol()
#endif
#ifndef ICNV
#define ICNV(n)		atol(n)
#endif
#ifndef IFMT
#define IFMT		"%ld"
#endif
#ifndef FLOTYPE
#define FLOTYPE		double
#endif
#ifndef OFFTYPE
#define OFFTYPE		int
#endif
#ifndef CVPTR
#define CVPTR(x)	(x)
#endif
#ifndef UCHAR
#define UCHAR		unsigned char
#endif

/* useful definitions */
#define TRUE	1
#define FALSE	0
#ifndef NIL
#define NIL	(LVAL )0
#endif

/* include the dynamic memory definitions */
#include "xldmem.h"

/* program limits */
#define STRMAX		100		/* maximum length of a string constant */
#define HSIZE		199		/* symbol hash table size */
#define SAMPLE		100		/* control character sample rate */

/* function table offsets for the initialization functions */
#define FT_RMHASH	0
#define FT_RMQUOTE	1
#define FT_RMDQUOTE	2
#define FT_RMBQUOTE	3
#define FT_RMCOMMA	4
#define FT_RMLPAR	5
#define FT_RMRPAR	6
#define FT_RMSEMI	7
#define FT_CLNEW	10
#define FT_CLISNEW	11
#define FT_CLANSWER	12
#define FT_OBISNEW	13
#define FT_OBCLASS	14
#define FT_OBSHOW	15
	
/* macro to push a value onto the argument stack */
#define pusharg(x)	{if (xlsp >= xlargstktop) xlargstkoverflow();\
			 *xlsp++ = (x);}

/* macros to protect pointers */
#define xlstkcheck(n)	{if (xlstack - (n) < xlstkbase) xlstkoverflow();}
#define xlsave(n)	{*--xlstack = &n; n = NIL;}
#define xlprotect(n)	{*--xlstack = &n;}

/* check the stack and protect a single pointer */
#define xlsave1(n)	{if (xlstack <= xlstkbase) xlstkoverflow();\
                         *--xlstack = &n; n = NIL;}
#define xlprot1(n)	{if (xlstack <= xlstkbase) xlstkoverflow();\
                         *--xlstack = &n;}

/* macros to pop pointers off the stack */
#define xlpop()		{++xlstack;}
#define xlpopn(n)	{xlstack+=(n);}

/* macros to manipulate the lexical environment */
#define xlframe(e)	cons(NIL,e)
#define xlbind(s,v)	xlpbind(s,v,xlenv)
#define xlfbind(s,v)	xlpbind(s,v,xlfenv);
#define xlpbind(s,v,e)	{rplaca(e,cons(cons(s,v),car(e)));}

/* macros to manipulate the dynamic environment */
#define xldbind(s,v)	{xldenv = cons(cons(s,getvalue(s)),xldenv);\
			 setvalue(s,v);}
#define xlunbind(e)	{for (; xldenv != (e); xldenv = cdr(xldenv))\
			   setvalue(car(car(xldenv)),cdr(car(xldenv)));}

/* type predicates */			       
#define atom(x)		((x) == NIL || ntype(x) != CONS)
#define null(x)		((x) == NIL)
#define listp(x)	((x) == NIL || ntype(x) == CONS)
#define consp(x)	((x) && ntype(x) == CONS)
#define subrp(x)	((x) && ntype(x) == SUBR)
#define fsubrp(x)	((x) && ntype(x) == FSUBR)
#define stringp(x)	((x) && ntype(x) == STRING)
#define symbolp(x)	((x) && ntype(x) == SYMBOL)
#define streamp(x)	((x) && ntype(x) == STREAM)
#define objectp(x)	((x) && ntype(x) == OBJECT)
#define fixp(x)		((x) && ntype(x) == FIXNUM)
#define floatp(x)	((x) && ntype(x) == FLONUM)
#define vectorp(x)	((x) && ntype(x) == VECTOR)
#define closurep(x)	((x) && ntype(x) == CLOSURE)
#define charp(x)	((x) && ntype(x) == CHAR)
#define ustreamp(x)	((x) && ntype(x) == USTREAM)
#define structp(x)	((x) && ntype(x) == STRUCT)
#define boundp(x)	(getvalue(x) != s_unbound)
#define fboundp(x)	(getfunction(x) != s_unbound)

/* shorthand functions */
#define consa(x)	cons(x,NIL)
#define consd(x)	cons(NIL,x)

/* argument list parsing macros */
#define xlgetarg()	(testarg(nextarg()))
#define xllastarg()	{if (xlargc != 0) xltoomany();}
#define testarg(e)	(moreargs() ? (e) : xltoofew())
#define typearg(tp)	(tp(*xlargv) ? nextarg() : xlbadtype(*xlargv))
#define nextarg()	(--xlargc, *xlargv++)
#define moreargs()	(xlargc > 0)

/* macros to get arguments of a particular type */
#define xlgacons()	(testarg(typearg(consp)))
#define xlgalist()	(testarg(typearg(listp)))
#define xlgasymbol()	(testarg(typearg(symbolp)))
#define xlgastring()	(testarg(typearg(stringp)))
#define xlgaobject()	(testarg(typearg(objectp)))
#define xlgafixnum()	(testarg(typearg(fixp)))
#define xlgaflonum()	(testarg(typearg(floatp)))
#define xlgachar()	(testarg(typearg(charp)))
#define xlgavector()	(testarg(typearg(vectorp)))
#define xlgastream()	(testarg(typearg(streamp)))
#define xlgaustream()	(testarg(typearg(ustreamp)))
#define xlgaclosure()	(testarg(typearg(closurep)))
#define xlgastruct()	(testarg(typearg(structp)))

/* function definition structure */
typedef struct {
    char *fd_name;	/* function name */
    int fd_type;	/* function type */
    LVAL (*fd_subr)();	/* function entry point */
} FUNDEF;

/* execution context flags */
#define CF_GO		0x0001
#define CF_RETURN	0x0002
#define CF_THROW	0x0004
#define CF_ERROR	0x0008
#define CF_CLEANUP	0x0010
#define CF_CONTINUE	0x0020
#define CF_TOPLEVEL	0x0040
#define CF_BRKLEVEL	0x0080
#define CF_UNWIND	0x0100

/* execution context */
typedef struct context {
    int c_flags;			/* context type flags */
    LVAL c_expr;			/* expression (type dependant) */
    jmp_buf c_jmpbuf;			/* longjmp context */
    struct context *c_xlcontext;	/* old value of xlcontext */
    LVAL **c_xlstack;			/* old value of xlstack */
    LVAL *c_xlargv;			/* old value of xlargv */
    int c_xlargc;			/* old value of xlargc */
    LVAL *c_xlfp;			/* old value of xlfp */
    LVAL *c_xlsp;			/* old value of xlsp */
    LVAL c_xlenv;			/* old value of xlenv */
    LVAL c_xlfenv;			/* old value of xlfenv */
    LVAL c_xldenv;			/* old value of xldenv */
} CONTEXT;

/* external variables */
extern LVAL **xlstktop;       	/* top of the evaluation stack */
extern LVAL **xlstkbase;	/* base of the evaluation stack */
extern LVAL **xlstack;		/* evaluation stack pointer */
extern LVAL *xlargstkbase;	/* base of the argument stack */
extern LVAL *xlargstktop;	/* top of the argument stack */
extern LVAL *xlfp;		/* argument frame pointer */
extern LVAL *xlsp;		/* argument stack pointer */
extern LVAL *xlargv;		/* current argument vector */
extern int xlargc;		/* current argument count */

/* external procedure declarations */
extern LVAL xleval();		/* evaluate an expression */
extern LVAL xlapply();		/* apply a function to arguments */
extern LVAL xlsubr();		/* enter a subr/fsubr */
extern LVAL xlenter();		/* enter a symbol */
extern LVAL xlmakesym();	/* make an uninterned symbol */
extern LVAL xlgetvalue();	/* get value of a symbol (checked) */
extern LVAL xlxgetvalue();	/* get value of a symbol */
extern LVAL xlgetfunction();	/* get functional value of a symbol */
extern LVAL xlxgetfunction();	/* get functional value of a symbol (checked) */
extern LVAL xlexpandmacros();	/* expand macros in a form */
extern LVAL xlgetprop();	/* get the value of a property */
extern LVAL xlclose();		/* create a function closure */

/* argument list parsing functions */
extern LVAL xlgetfile();      	/* get a file/stream argument */
extern LVAL xlgetfname();	/* get a filename argument */

/* error reporting functions (don't *really* return at all) */
extern LVAL xltoofew();		/* report "too few arguments" error */
extern LVAL xlbadtype();	/* report "bad argument type" error */

