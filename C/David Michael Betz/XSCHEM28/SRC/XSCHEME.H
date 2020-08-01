/* xscheme.h - xscheme definitions */
/*	Copyright (c) 1988, by David Michael Betz
	All Rights Reserved
	Permission is granted for unrestricted non-commercial use	*/

#include <stdio.h>
#include <ctype.h>
#include <setjmp.h>

/* AFMT		printf format for addresses ("%x") */
/* OFFTYPE	number the size of an address (int) */
/* FIXTYPE	data type for fixed point numbers (long) */
/* ITYPE	fixed point input conversion routine type (long atol()) */
/* ICNV		fixed point input conversion routine (atol) */
/* IFMT		printf format for fixed point numbers ("%ld") */
/* FLOTYPE	data type for floating point numbers (float) */
/* FFMT		printf format for floating point numbers (%.15g) */

/* for the Lightspeed C compiler - Macintosh */
#ifdef LSC
#define AFMT		"%lx"
#define OFFTYPE		long
#define NIL		(void *)0
#define MACINTOSH
#endif

/* for the UNIX System V C compiler */
#ifdef UNIX
#endif

/* for the Aztec C compiler - Amiga */
#ifdef AZTEC_AMIGA
#define AFMT		"%lx"
#define OFFTYPE		long
#endif

/* for the Mark Williams C compiler - Atari ST */
#ifdef MWC
#define AFMT		"%lx"
#define OFFTYPE		long
#endif

/* for the Microsoft C 6.0 compiler */
#ifdef MSC
#ifndef MSDOS
#define MSDOS
#endif
#define SEGADDR
#endif

/* for the Turbo (Borland) C compiler */
#ifdef TURBOC
#ifndef MSDOS
#define MSDOS
#endif
#define SEGADDR
#endif

/* for the Zortec C++ compiler */
#ifdef ZTC
#ifndef MSDOS
#define MSDOS	1
#endif
#define SEGADDR
void free(void *);
#endif

/* for the TopSpeed C compiler */
#ifdef TSC
#ifndef MSDOS
#define MSDOS	1
#endif
#define SEGADDR
#endif

/* for the Watcom C compiler */
#ifdef WTC
#ifndef MSDOS
#define MSDOS
#endif
#endif

/* for the Metaware High C compiler */
#ifdef HIGHC
#ifndef MSDOS
#define MSDOS
#endif
#endif

/* for the Intel Code Builder C compiler */
#ifdef CODEBLDR
#ifndef MSDOS
#define MSDOS
#endif
#endif

/* for the Microway NDP C compiler */
#ifdef NDPC
#ifndef MSDOS
#define MSDOS
#endif
#endif

/* for the MS-DOS compilers */
#ifdef MSDOS
#define AFMT		"%lx"
#define OFFTYPE		long
#endif

/* for segmented addresses on Intel processors */
#ifdef SEGADDR
#define INSEGMENT(n,s)	((unsigned long)(n) >> 16 \
		      == (unsigned long)(s) >> 16)
#endif


/* size of each type of memory segment */
#ifndef NSSIZE
#define NSSIZE	4000	/* number of nodes per node segment */
#endif
#ifndef VSSIZE
#define VSSIZE	10000	/* number of LVAL's per vector segment */
#endif

/* default important definitions */
#ifndef AFMT
#define AFMT		"%x"
#endif
#ifndef OFFTYPE
#define OFFTYPE		int
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
#ifndef FFMT
#define FFMT		"%.15g"
#endif
#ifndef SFIXMIN
#define SFIXMIN		-1048576
#define SFIXMAX		1048575
#endif
#ifndef INSEGMENT
#define INSEGMENT(n,s)	((n) >= &(s)->ns_data[0] \
                      && (n) <  &(s)->ns_data[0] + (s)->ns_size)
#endif
#ifndef VCOMPARE
#define VCOMPARE(f,s,t)	((f) + (s) <= (t))
#endif

/* useful definitions */
#define TRUE	1
#define FALSE	0
#ifndef NIL
#define NIL	(LVAL)0
#endif

/* program limits */
#define STRMAX		100		/* maximum length of a string constant */
#define HSIZE		199		/* symbol hash table size */
#define SAMPLE		100		/* control character sample rate */

/* stack manipulation macros */
#define check(n)	{ if (xlsp - (n) < xlstkbase) xlstkover(); }
#define cpush(v)	{ if (xlsp > xlstkbase) push(v); else xlstkover(); }
#define push(v)		(*--xlsp = (v))
#define pop()		(*xlsp++)
#define top()		(*xlsp)
#define settop(v)	(*xlsp = (v))
#define drop(n)		(xlsp += (n))

/* argument list parsing macros */
#define xlgetarg()	(testarg(nextarg()))
#define xllastarg()	{if (xlargc != 0) xltoomany();}
#define xlpoprest()	{xlsp += xlargc;}
#define testarg(e)	(moreargs() ? (e) : xltoofew())
#define typearg(tp)	(tp(*xlsp) ? nextarg() : xlbadtype(*xlsp))
#define nextarg()	(--xlargc, *xlsp++)
#define moreargs()	(xlargc > 0)

/* macros to get arguments of a particular type */
#define xlgacons()	(testarg(typearg(consp)))
#define xlgalist()	(testarg(typearg(listp)))
#define xlgasymbol()	(testarg(typearg(symbolp)))
#define xlgastring()	(testarg(typearg(stringp)))
#define xlgaobject()	(testarg(typearg(objectp)))
#define xlgafixnum()	(testarg(typearg(fixp)))
#define xlganumber()	(testarg(typearg(numberp)))
#define xlgachar()	(testarg(typearg(charp)))
#define xlgavector()	(testarg(typearg(vectorp)))
#define xlgaport()	(testarg(typearg(portp)))
#define xlgaiport()	(testarg(typearg(iportp)))
#define xlgaoport()	(testarg(typearg(oportp)))
#define xlgaclosure()	(testarg(typearg(closurep)))
#define xlgaenv()	(testarg(typearg(envp)))

/* node types */
#define FREE		0
#define CONS		1
#define SYMBOL		2
#define FIXNUM		3
#define FLONUM		4
#define STRING		5
#define OBJECT		6
#define PORT		7
#define VECTOR		8
#define CLOSURE		9
#define METHOD		10
#define CODE		11
#define SUBR		12
#define XSUBR		13
#define CSUBR		14
#define CONTINUATION	15
#define CHAR		16
#define PROMISE		17
#define ENV		18

/* node flags */
#define MARK		1
#define LEFT		2

/* port flags */
#define PF_INPUT	1
#define PF_OUTPUT	2
#define PF_BINARY	4

/* new node access macros */
#define ntype(x)	((OFFTYPE)(x) & 1 ? FIXNUM : (x)->n_type)

/* macro to determine if a non-nil value is a pointer */
#define ispointer(x)	(((OFFTYPE)(x) & 1) == 0)

/* type predicates */			       
#define atom(x)		((x) == NIL || ntype(x) != CONS)
#define null(x)		((x) == NIL)
#define listp(x)	((x) == NIL || ntype(x) == CONS)
#define numberp(x)	((x) && (ntype(x) == FIXNUM || ntype(x) == FLONUM))
#define boundp(x)	(getvalue(x) != s_unbound)
#define iportp(x)	(portp(x) && (getpflags(x) & PF_INPUT) != 0)
#define oportp(x)	(portp(x) && (getpflags(x) & PF_OUTPUT) != 0)

/* basic type predicates */			       
#define consp(x)	((x) && ntype(x) == CONS)
#define stringp(x)	((x) && ntype(x) == STRING)
#define symbolp(x)	((x) && ntype(x) == SYMBOL)
#define portp(x)	((x) && ntype(x) == PORT)
#define objectp(x)	((x) && ntype(x) == OBJECT)
#define fixp(x)		((x) && ntype(x) == FIXNUM)
#define floatp(x)	((x) && ntype(x) == FLONUM)
#define vectorp(x)	((x) && ntype(x) == VECTOR)
#define closurep(x)	((x) && ntype(x) == CLOSURE)
#define continuationp(x) ((x) && ntype(x) == CONTINUATION)
#define codep(x)	((x) && ntype(x) == CODE)
#define methodp(x)	((x) && ntype(x) == METHOD)
#define subrp(x)	((x) && ntype(x) == SUBR)
#define xsubrp(x)	((x) && ntype(x) == XSUBR)
#define charp(x)	((x) && ntype(x) == CHAR)
#define promisep(x)	((x) && ntype(x) == PROMISE)
#define envp(x)		((x) && ntype(x) == ENV)
#define booleanp(x)	((x) == NIL || ntype(x) == BOOLEAN)

/* vector update macro
   This is necessary because the memory pointed to by the n_vdata field
   of a vector object can move during a garbage collection.  This macro
   guarantees that evaluation happens in the right order.
*/
#define vupdate(x,i,v)	{ LVAL vutmp=(v); (x)->n_vdata[i] = vutmp; }

/* cons access macros */
#define car(x)		((x)->n_car)
#define cdr(x)		((x)->n_cdr)
#define rplaca(x,y)	((x)->n_car = (y))
#define rplacd(x,y)	((x)->n_cdr = (y))

/* symbol access macros */
#define getvalue(x)	 ((x)->n_vdata[0])
#define setvalue(x,v)	 vupdate(x,0,v)
#define getpname(x)	 ((x)->n_vdata[1])
#define setpname(x,v)	 vupdate(x,1,v)
#define getplist(x)	 ((x)->n_vdata[2])
#define setplist(x,v)	 vupdate(x,2,v)
#define SYMSIZE		3

/* vector access macros */
#define getsize(x)	((x)->n_vsize)
#define getelement(x,i)	((x)->n_vdata[i])
#define setelement(x,i,v) vupdate(x,i,v)

/* object access macros */
#define getclass(x)	((x)->n_vdata[1])
#define setclass(x,v)	vupdate(x,1,v)
#define getivar(x,i)	((x)->n_vdata[i])
#define setivar(x,i,v)	vupdate(x,i,v)

/* promise access macros */
#define getpproc(x)	((x)->n_car)
#define setpproc(x,v)	((x)->n_car = (v))
#define getpvalue(x)	((x)->n_cdr)
#define setpvalue(x,v)	((x)->n_cdr = (v))

/* closure access macros */
#define getcode(x)	((x)->n_car)
#define getenv(x)	((x)->n_cdr)

/* code access macros */
#define getbcode(x)		((x)->n_vdata[0])
#define setbcode(x,v)		vupdate(x,0,v)
#define getcname(x)		((x)->n_vdata[1])
#define setcname(x,v)		vupdate(x,1,v)
#define getvnames(x)		((x)->n_vdata[2])
#define setvnames(x,v)		vupdate(x,2,v)
#define FIRSTLIT		3

/* fixnum/flonum/character access macros */
#define getfixnum(x)	((OFFTYPE)(x) & 1 ? getsfixnum(x) : (x)->n_int)
#define getflonum(x)	((x)->n_flonum)
#define getchcode(x)	((x)->n_chcode)

/* small fixnum access macros */
#define cvsfixnum(x)	((LVAL)(((OFFTYPE)x << 1) | 1))
#define getsfixnum(x)	((FIXTYPE)((OFFTYPE)(x) >> 1))

/* string access macros */
#define getstring(x)	((char *)(x)->n_vdata)
#define getslength(x)	((x)->n_vsize)

/* iport/oport access macros */
#define getfile(x)	((x)->n_fp)
#define setfile(x,v)	((x)->n_fp = (v))
#define getsavech(x)	((x)->n_savech)
#define setsavech(x,v)	((x)->n_savech = (v))
#define getpflags(x)	((x)->n_pflags)
#define setpflags(x,v)	((x)->n_pflags = (v))

/* subr access macros */
#define getsubr(x)	((x)->n_subr)
#define getoffset(x)	((x)->n_offset)

/* list node */
#define n_car		n_info.n_xlist.xl_car
#define n_cdr		n_info.n_xlist.xl_cdr

/* integer node */
#define n_int		n_info.n_xint.xi_int

/* flonum node */
#define n_flonum	n_info.n_xflonum.xf_flonum

/* character node */
#define n_chcode	n_info.n_xchar.xc_chcode

/* file pointer node */
#define n_fp		n_info.n_xfptr.xf_fp
#define n_savech	n_info.n_xfptr.xf_savech
#define n_pflags	n_info.n_xfptr.xf_pflags

/* vector/object node */
#define n_vsize		n_info.n_xvect.xv_size
#define n_vdata		n_info.n_xvect.xv_data

/* subr node */
#define n_subr		n_info.n_xsubr.xs_subr
#define n_offset	n_info.n_xsubr.xs_offset

/* node structure */
typedef struct node {
    char n_type;		/* type of node */
    char n_flags;		/* flag bits */
    union ninfo { 		/* value */
	struct xlist {		/* list node (cons) */
	    struct node *xl_car;	/* the car pointer */
	    struct node *xl_cdr;	/* the cdr pointer */
	} n_xlist;
	struct xint {		/* integer node */
	    FIXTYPE xi_int;		/* integer value */
	} n_xint;
	struct xflonum {	/* flonum node */
	    FLOTYPE xf_flonum;		/* flonum value */
	} n_xflonum;
	struct xchar {		/* character node */
	    int xc_chcode;		/* character code */
	} n_xchar;
	struct xfptr {		/* file pointer node */
	    FILE *xf_fp;		/* the file pointer */
	    short xf_savech;		/* lookahead character for input files */
	    short xf_pflags;		/* port flags */
	} n_xfptr;
	struct xvect {		/* vector node */
	    int xv_size;		/* vector size */
	    struct node **xv_data;	/* vector data */
	} n_xvect;
	struct xsubr {		/* subr/fsubr node */
	    struct node *(*xs_subr)();	/* function pointer */
	    int xs_offset;		/* offset into funtab */
	} n_xsubr;
    } n_info;
} NODE,*LVAL;

/* memory allocator definitions */

/* macros to compute the size of a segment */
#define nsegsize(n) (sizeof(NSEGMENT)+((n)-1)*sizeof(struct node))
#define vsegsize(n) (sizeof(VSEGMENT)+((n)-1)*sizeof(LVAL))

/* macro to convert a byte size to a word size */
#define btow_size(n)	(((n) + sizeof(LVAL) - 1) / sizeof(LVAL))

/* node segment structure */
typedef struct nsegment {
    struct nsegment *ns_next;	/* next node segment */
    unsigned int ns_size;	/* number of nodes in this segment */
    struct node ns_data[1];	/* segment data */
} NSEGMENT;

/* vector segment structure */
typedef struct vsegment {
    struct vsegment *vs_next;	/* next vector segment */
    LVAL *vs_free;		/* next free location in this segment */
    LVAL *vs_top;		/* top of segment (plus one) */
    LVAL vs_data[1];		/* segment data */
} VSEGMENT;

/* function definition structure */
typedef struct {
    char *fd_name;	/* function name */
    LVAL (*fd_subr)();	/* function entry point */
} FUNDEF;

/* external variables */
extern LVAL *xlstkbase; 	/* base of value stack */
extern LVAL *xlstktop;		/* top of value stack */
extern LVAL *xlsp;    		/* value stack pointer */
extern int xlargc;		/* argument count for current call */

/* external routine declarations */
#ifdef __STDC__
#include "xsproto.h"
#else
extern LVAL cons();		/* (cons x y) */
extern LVAL xlenter();		/* enter a symbol */
extern LVAL xlgetprop();	/* get the value of a property */
extern LVAL cvsymbol(); 	/* convert a string to a symbol */
extern LVAL cvstring(); 	/* convert a string */
extern LVAL cvfixnum(); 	/* convert a fixnum */
extern LVAL cvflonum();       	/* convert a flonum */
extern LVAL cvchar(); 		/* convert a character */
extern LVAL cvclosure();	/* convert code and an env to a closure */
extern LVAL cvmethod();		/* convert code and an env to a method */
extern LVAL cvsubr();		/* convert a function into a subr */
extern LVAL cvport();		/* convert a file pointer to an input port */
extern LVAL cvpromise();	/* convert a procedure to a promise */
extern LVAL newstring();	/* create a new string */
extern LVAL newobject();	/* create a new object */
extern LVAL newvector();	/* create a new vector */
extern LVAL newcode();		/* create a new code object */
extern LVAL newcontinuation();	/* create a new continuation object */
extern LVAL newframe();		/* create a new environment frame */
extern LVAL xltoofew();		/* report "too few arguments" */
extern LVAL xlbadtype();	/* report "wrong argument type" */
extern LVAL curinput();		/* get the current input port */
extern LVAL curoutput();	/* get the current output port */
#endif

