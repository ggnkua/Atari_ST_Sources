/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	nodedefs.h
 */

#include "cache.h"

/* nodetypes */
enum
{
	STNODE = 1,		/* xnode unused */
	FIRSTTY=STNODE,
	DFNODE,			/* xnode */
	EXNODE,			/* enode */
	GENODE,			/* gnode */
	TLNODE,			/* tnode = symbol tables & type lists */
	BLNODE,			/* snode = scopes */
	FLNODE,			/* flown = flow node */
	CSNODE,			/* cnode = switches */
	TPNODE,			/* mnode = code templates */
	PRNODE,			/* fnode = proc,func nesting */
	RLNODE,			/* rnode = 96 bit real value */
	LLNODE,			/* lnode = 64 bit int value */
	IFNODE,			/* pnode #if #elif #endif tracking */
	LBNODE,			/* label node */
	INNODE,			/* inode */
	BKNODE,			/* bnode */
	LASTTY,
};

typedef struct
{
	char x,
	     a,
#if FLOAT
	     f,
#else
		 filler,
#endif
	     d;
} ALREG;

typedef struct
{
	unsigned int
		x : 4,
		a : 4,
#if FLOAT
		f : 4,
#else
		filler : 4,
#endif
		d : 4;
} NREG;

typedef union
{
	long	i;
#if FLOAT
	float	f;
	struct vnode	*dbl;
#endif
} Value;

typedef void node_zero(void *xp);

typedef struct nodespace
{
	size_t	nodesize;
	long	start;
	bool	exponential;
	long	tel, noem;
	node_zero *zer;
	char *	name;
	void	*space, *list;
	short 	made, avail;
} NODESPACE;

extern NODESPACE xspace[];

typedef enum
{
	XNr, TLr, EXr, VNr, INr, BKr, XXr
} ROOTS;

/* generic node definition: describes commen part only.
   Nota Maxima Bene! Do never use sizeof() on this node
 */

typedef union
{
	struct
	{
	  ubits
		free	: 1,		/* node is on free list				*/
		nexp	: 1,		/* dont expand						*/
		spar	: 1,		/* for DPARAM node's	(#param)	*/
		lcat	: 1,		/* left of ##						*/
		rcat	: 1,		/* right of ##						*/
		res		: 1,		/* node is resident (in data section) */
		n_ct    : 1,		/* type or tseq is NOT a copy		*/
		brk_l   : 1,		/* break list  recursion			*/
#if BIP_ASM
		asmac	: 1,		/* macro from asm */
		p1ws	: 1,		/* White space from character pos 1	*/
		follows : 1,		/* White space following identifier */
		dot     : 1,		/* Dot preceding identifier			*/
#else
		b9_12   : 4,
#endif
		nheap	: 1,		/* Name is malloc'd, must be free'd */
							/* otherwise is absent or in dictionary */
		b14_b15	: 2;
	} f;
	ushort i;
} NFLAGS;

/* NB!!! the E,G and T FLAGS must at any time be kept in the same order
         and on the same bit position.
*/
typedef union
{
	struct
	{
	  ubits
		typed : 1,			/* Argument to call is properly typed */
		varg  : 1,			/* Ellipsis seen stop allocating args to regs */
		rname : 1,			/* my name is my right child's name	*/
		lname : 1,			/* my name is my left child's name	*/
		imm   : 1,			/* Ptr to ID which is really Array of or Fun ret */
		cc    : 1,			/* cc set as side effect of op		*/
		see_f : 1,			/*  F seen on constant				*/
		see_l : 1,			/*  L seen on integer constant		*/
		see_u : 1,			/*  U seen on integer constant		*/
		l_ass : 1,			/* SREG is left of assignemt		*/
#if COLDFIRE
		cfl   : 1,			/* Long forced for Coldfire			*/
#endif
#if BIP_ASM
		asm_w : 1,			/* long size in asm expressions		*/
		asm_l : 1,			/* word size in asm expressions		*/
#endif
#if LL
		see_ll: 1,			/* LL seen on integer constant		*/
#endif
		pu    : 1,			/* Pointer Union */
		ftyp  : 1;			/* form_types() called for this node */
	} f;
	ushort i;
} EFLAGS;

typedef union
{
	struct
	{
	  ubits
		formal    : 1,		/* Array declaration is formal (empty [])			*/
		saw_array : 1,		/* genuine []'d array seen but converted to pointer */
		old_args  : 1,		/* old style function declaration	*/
		o_s_conv  : 1,		/* 11'19 HR v6: converted to ansi */
		ans_args  : 1,		/* ANSI prototype					*/
		asm_func  : 1,		/* declaration of embedded assembly */
		saw_proc  : 1,		/* proc --> &proc */
		pu        : 1,		/* Pointer Union */
		tm        : 1,		/* typemaker type: parent must be not_nct'd */
		lpr       : 1,		/* break left  recursion */
		rpr       : 1,		/* break right recursion */
		qd        : 1,		/* already qualified in this run */
#if USAGE
		isarg     : 1,		/* Is a argument (old style function declarations)	*/
		used      : 1,
		inid      : 1,
#else
		b12_13    : 2,
#endif
		dflt      : 1;		/* 07'19 HR: v6 type is default (empty declarer) */
	} f;
	ushort i;
} TFLAGS;

typedef union
{
	struct
	{
	  ubits
		undef   : 1,		/* Name is undefined */
		see_reg : 1,		/* register declaration */
		is_arg  : 1,		/* object in function is argument */
		rlop    : 1,		/* floating point monadyc operator */
	  	cfop	: 1,		/*   idem  on Coldfire */
		ided    : 1,		/* prevent from matching again */
		leaf    : 1,		/* leaf identifier */
		s_ef    : 1,		/* has side effects */
		equ     : 1,
		qc      : 1,
		qv      : 1,		/* qualifications */
		q 		: 1,		/* qualified */
		cp		: 1,		/* 07'19 HR: v6 flag for Pure C style offsetof. */
		of		: 1;		/* 09'19 HR: v6 flag for offsetof. (see __O__ ) */
		b14_15 	: 2;
	} f;
	ushort i;
} CFLAGS;

typedef union
{
	struct
	{
	  ubits
		cdec    : 1,		/* cdecl function 	*/
		sysc    : 1,		/* __syscall__ */
		pasc	: 1,		/* pascal function	*/
		inl_v   : 1,		/* inlined single value (like Pure C) */
		asm_f   : 1,		/* __asm__ (assembler) function body */
		b5_15   : 11;
	} f;
	ushort i;
} XFLAGS;		/* 09'19 HR: v6 needs more flags :-/ */

enum
{
	Null, CONST, VOLAT
};

#if FOR_A
typedef union
{
	struct
	{
	  ubits
		deref : 1,		/* Implicit dereferencing of ptr			 		*/
		lproc : 1,		/* Local procedure */
		ns    : 1,		/* name contexts ns: string$, no context or np int32, nf float~ */
		np    : 1,
		nf    : 1;
	} f;
	ushort i;
} AFLAGS;

#define STR_SZ AFLAGS aflgs; long str_sz; short adum;

#else
#define STR_SZ
#endif

typedef struct
{
	ubits
		offset	: 5,
		shift	: 5,
		width	: 6;
} BITS;

typedef struct
{
	short n;
	long ln;
} FINFO;

/* 09'19 HR: v6 needed more flags :-/ :: XFLAGS */
#if C_DEBUG
#define NODECOMMON(a,b,c,d)\
	struct a *b,*c; \
	Cstr 	name;	\
	NFLAGS	nflgs;	\
	uchar	nt, sc; \
	ulong	diags;  \
	short	d;
#else
#define NODECOMMON(a,b,c,d)\
	struct a *b,*c; \
	Cstr 	name;	\
	NFLAGS	nflgs;	\
	uchar	nt, sc; \
	short	d;
#endif

/* smallest node,  same as vnode upto node data (nd) */
typedef struct allnodes
{
	NODECOMMON(allnodes, left, right, token)
	FINFO fl;
	Value	val;				/* almost every node type needs some value */

	union
	{
		struct allnodes *info;
		struct xnode    *tseq;
		struct tlnode   *type;
		struct bnode    *symbol;
		struct vnode    *codep;
		struct opnd     *arg;
		struct snode    *b_syms;
	} var;
} ANODE, *AP;

/*
 *	input & preprocessor node
 */

typedef struct xnode
{
/*
 *	stuff common to all nodes
 */
	NODECOMMON(xnode, next, down, token)
	FINFO fl;
	Value	val;
	struct  xnode *tseq;				/* token sequence */

/*  ---------------- */
	CFLAGS	cflgs;
	XFLAGS	xflgs;
	short xxx;
	EFLAGS	zflgs;
	STR_SZ
	ushort	cat0;
	uchar	cat1;	/* Pure C doesnt support long enums */
	uchar	prec;
	LEX_RECORD * catp;
#if BIP_ASM
	struct exnode *xpr;				/* equ expression */
#endif
} XNODE, *XP;

#if offsetof(XNODE, cflgs) != sizeof(ANODE)
#error incorrect common part of XNODE
#endif

/*
 *	symbol table & type list
 */

/* Normalized part
typedef struct tl_info
{
} TL_INFO, *TL;
*/

typedef struct tlnode
{
/*
 *	stuff common to all nodes
 */
	NODECOMMON(tlnode, next, list, token)
	FINFO fl;
	long	offset;		/* relative offset (stackframe or member) */
	struct	tlnode *type;

/*  ------------ */
	CFLAGS	cflgs;
	XFLAGS	xflgs;
	short xxx;
	TFLAGS	tflgs;
	STR_SZ
	ushort	cat0;
	uchar	cat1;	/* Pure C doesnt support long enums */
	uchar	dum;
	long	size;
	AREA_INFO area_info;
	VREG_INFO vreg;
	char	tt,			/* type of tree branch (binary, unary or leaf) */
			rno,
			aln,
			ty;
	short	lbl;		/* for static names (static means: extent is permanent, scope is local) */
						/* name number if assembler name */
	BITS	fld;
} TNODE, *TP;

#if offsetof(TNODE, cflgs) != sizeof(ANODE)
#error incorrect common part of TNODE
#endif

/*
 *	expression node and generation node data
 */

typedef struct exnode			/* enode & gnode amalgamated */
{
/*
 *	stuff common to all nodes
 */
	NODECOMMON(exnode, left, right, token)
	FINFO fl;
	Value val;
	TP     type;

/*  ------------ */
	CFLAGS	cflgs;		/* must be same place as tnode	*/
	XFLAGS	xflgs;
	short xxx;
	EFLAGS	eflgs;
	STR_SZ
	ushort	cat0;
	uchar	cat1;	/* Pure C doesnt support long enums */
	uchar	prec;
	long	size;
	AREA_INFO area_info;
	VREG_INFO vreg;
	char	tt,			/* type of tree branch (bin, un or leaf) */
			rno,
			aln,
			ty;			/* type DOUBLE, UNS, INT or AGGREG */
	short	lbl;
	BITS	fld;

	struct vnode
			*betw;		/* code for between L and R					*/
	NREG	needs;
	short 	Tl,
			Fl,
			brt;		/* 				branch token				*/
	char	r1,
			r2,
			chunk_size,	/* aggreg chunk size (strasn)				*/
			misc1;
	long	misc;
	RMASK   reserve;
} NODE, *NP;

#if offsetof(NODE, cflgs) != sizeof(ANODE)
#error incorrect common part of NODE
#endif


/* preprocessor node became necessary
	because of the a-symmetric syntax of #elif */

struct pnode
{
	short kind;				/* of nests */
	short nest;
	bool truth;
	short lvl;				/* of include files */
	void *cur_LEX;			/* remember position */
	short fileno;
	CP cache;
/*	short (*cmp)(Cstr s1, Cstr s2); */
};

#define p nd.pn

/*
 *	node data to hold case for switch generation
 */
struct cnode
{
	short lbl;		/* case label or label label */
	short def;		/* label defined */
};

#define cs nd.cn

/*
 * node data to hold flow information of function per statement
 *	right/inner    is  then ...
 *  out            is  else cq default
 */
struct flown
{
	short nr;
	struct vnode
		*out,			/* else ...; or default */
		*caselist;		/* sorted casevalues */
/*		*loc;			/* location of result of statement's last expression */
*/	short escape,		/* whether normal flow or discontinuous */
						/* cq  break; return; continue; fall thru; goto */
		deflbl,			/* default lable or -1 */
		size;			/* of switch expression */
	struct
	{
		short brk,		/* stmt's break    label (replaces prtab->curbrk) */
			cont;		/* stmt's continue label (replaces prtab->curcont) */
		struct vnode
			*base,		/* back to start of level */
			*root;		/* points to flow node of switch or loop statement */
	} fd;				/* flow data for inheriting */
};

#define F nd.fn
#define FF nd.fn.fd

#define TPLMAX (sizeof(struct flown)/sizeof(char *))-1

/*
 *	code template node
 */
struct mnode		/* template node */
{
	short tno;
	Cstr templates[TPLMAX];
};

#define tnr nd.mn.tno
#define ts  nd.mn.templates

#include "optimize.h"

typedef union
{
	struct ubits
	{
		b15_2  : 14,
		branch : 1,
		flt    : 1;
	} f;
	ushort i;
} IFLAGS;

typedef struct inode
{
	NODECOMMON(inode, next, prior, opcode)
	short 	reg, sz;
	OPND	*arg;			/* argument list */
	RMASK	rref,
			rset,
			live;			/* regs live after this inst. */
	IFLAGS	iflg;
#if C_DEBUG || OPTBUG		/* debug optimizer */
	long inr;				/* IXC line number */
	long snr;				/* original source line number */
	Cstr bugstr;			/* static debug info */
#endif
} INODE, *IP;

/*
 * Basic Block:
 *
 * References a linked list of instructions that make up the block.
 * Each block can be exited via one of two branches, which are
 * represented by pointers to two other blocks, or null.
 * There are 24 registers a0-a7, d0-d7 and f0-f7,
 */
typedef struct bnode
{
	NODECOMMON(bnode, next, chain, token)
	struct bnode *symbol;
	struct
	inode *first,		/* first instruction in block */
	      *last;		/* last instruction in block */
	RMASK rref,			/* registers referenced by block */
	      rset;		    /* registers modified   by block */

	short bn;
	BFLAGS bflg;		/* flags relating to this block */
	ASMOP opcode;		/* type of exiting branch */

	/*
	 * Execution traversals
	 */
	struct
	bnode *cond,		/* conditional branch (or nil) */
		  *fall;		/* "fall through" branch */

	/*
	 * Information for data-flow analysis
	 */
	RMASK live;			/* registers live at the beginning ? */
} BNODE, *BP;

#if LL
#include "ll.h"			/* internal long long definitions */
/* AHCC internally doesnt use long long; It is emulated as long as
   I want to be able to compile by Pure C.
 */
#endif

typedef struct vnode
{
/*
 *	stuff common to all nodes
 */
	NODECOMMON(vnode, next, inner, token)
	FINFO fl;
	ulong vval;

	struct vnode *codep;
/*
 *	various
 */
	union nd						/*	node data */
	{
		struct mnode mn;
		struct cnode cn;
		struct pnode pn;
		struct flown fn;
#if FLOAT
		double val;					/* for RLNODE */
#endif
#if LL
		__llasd lval;				/* for LLNODE */
#endif
	} nd;
} VNODE, *VP;

#define rval nd.val
#define llval nd.lval.m

#if offsetof(VNODE, nd) != sizeof(ANODE)
#error incorrect common part of VNODE
#endif


/*
 *	block info node
 */
typedef struct snode		/* scope information */
{
	NODECOMMON(snode, outer, _right, token)
	long   b_size;		/* size of locals cumulative	*/
	TP	b_syms;

	TP	b_tags,
		b_ops,		/* s/w dbl inline ops & casts		*/
		b_casts;
	short  b_tsize;		/* max tmps used for 1 expr		*/
	long   b_locs;		/* size of locals of 1 block	*/
	ALREG	b_regs;	 	/* loc vars allocated			*/
	VREG_INFO vreg;
#if FOR_A
	Cstr do_lbl;
	short brk, cnt;
#endif
} SNODE, *SCP;


typedef struct fnode			/* proc decl nesting */
{
	NODECOMMON(fnode, outer, _right, token)
	RMASK wregmsk,			/* for extra work regs */
	      resv;

	TP    type;
	VP    labels;
	short level;
	short lkxl,				/* for lkx local name space amount */
		  mmxl,				/* for reglist */
	      fretl;
	ALREG maxregs;
	short maxlocs,
	      insc,				/* current init context */
	      tmps;				/* temporaries */
} FNODE, *FP;

#if sizeof(XNODE)&3
#error size of xnode not multiple of 4
#endif

#if sizeof(NODE)&3
#error size of node not multiple of 4
#endif

#if sizeof(TNODE)&3
#error size of tnode not multiple of 4
#endif

#if sizeof(BNODE)&3
#error size of bnode not multiple of 4
#endif

#if sizeof(INODE)&3
#error size of inode not multiple of 4
#endif

#if FOR_A
typedef struct
{
	short loop_back,
	      loop_break,
	      loop_continue;
	NP xfor, xfrom, xby, xto, xwhile;
	bool any, have_scope, id, for_row, for_ref,
	     after, done, returns, here;
} LOOP_CONTROL;
#endif

