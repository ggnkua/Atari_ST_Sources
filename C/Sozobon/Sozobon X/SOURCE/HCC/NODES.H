/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	nodes.h
 */

/*
 *	stuff common to all nodes
 */
#define COMMON	int cflags;	\
		int fill;	\
		union node *left;	\
		union node *right;	\
		union node *tptr;	\
		union node *nm_ext;	\
		char cname[NMSIZE]

#define n_flags	e.cflags
#define n_left	e.left
#define n_next	e.left
#define n_right e.right
#define n_tptr	e.tptr
#define n_nmx	e.nm_ext
#define n_name	e.cname

/*
 *	expression (and symbol table) node
 */
struct enode {
	COMMON;
	int	token;		/* must be same place as tnode */
	int	eflags;
	char	etype;		/* type of node */
	char	sc;
	char	eprec;
	char	rno;
	union {
		long	vival;
		long	voffs;
		double	vfval;
	} vu;
#ifndef NOFIELDS
	unsigned	fldw:6, fldof:6;	/* use fields just so
						we know fields work */
#else
	char	fldw, fldof;		/* use if cant do fields */
#endif
};

#define e_token	e.token
#define e_flags	e.eflags
#define e_prec	e.eprec
#define e_rno	e.rno
#define e_type	e.etype
#define e_ival	e.vu.vival
#define e_offs	e.vu.voffs
#define e_fval	e.vu.vfval
#define e_sc	e.sc
#define e_fldw	e.fldw
#define e_fldo	e.fldof

/* for e_flags values, see tok.h */

/* values for e_type */

#define E_LEAF	0	/* no descendants */
#define E_UNARY 1	/* left node is expr, no right node */
#define E_BIN	2	/* left and right are expr */
#define E_SPEC	3	/* special '(', '[', '.', '->', ... */

/*
 * code generation node
 */
struct gnode {
	COMMON;
	int	token;
	int	eflags;
	char	etype;
	char	sc;
/* all of above fields must match first fields in enode! */

	char	needs;		/* registers needed */
	char	grno;		/* register used in ret value */
	char	basety;		/* type FLOAT, UNS, INT or AGREG */
	char	basesz;		/* size 1,2,4 or 3 -> see bsize */
	char	gr1, gr2;
	char	*betwc;		/* code for between L and R */
	union {
		long	goffs;		/* offsets for OREG, ONAME */
		double	gfval;		/* value of FCON */
	} gu;
	long	bsize;		/* AGREG size or misc. */
	struct {
#ifndef NOFIELDS
#ifdef AZ_HOST
		unsigned gfldw:6, gfldo:6;	/* BUG! */
#else
		int	gfldw:6, gfldo:6;	/* field info */
#endif
#else
		char	gfldw, gfldo;	/* use if no fields */
#endif
		short	fill;
	} gfl;
};

#define g_token	g.token
#define g_flags	g.eflags
#define g_type	g.etype
#define g_sc	g.sc
#define g_needs g.needs
#define g_rno	g.grno
#define g_offs	g.gu.goffs
#define g_fval	g.gu.gfval
#define g_betw	g.betwc
#define g_ty	g.basety
#define g_sz	g.basesz
#define g_code	g.tptr
#define g_bsize	g.bsize
#define g_fldw	g.gfl.gfldw
#define g_fldo	g.gfl.gfldo
#define g_r1	g.gr1
#define g_r2	g.gr2

/* types of operands -- ordered in cast strength order */
#define ET_S	1	/* signed integer */
#define ET_U	2	/* unsigned integer */
#define ET_F	3	/* float or double */
#define ET_A	4	/* aggregate */

/*
 *	type list node
 */
struct tnode {
	COMMON;
	int	token;		/* must be same place as enode */
	int	tflags;
	char	aln;		/* alignment needed */
	long	tsize;
};

#define t_token	t.token
#define t_flags	t.tflags
#define t_size	t.tsize
#define t_aln	t.aln

/*
 *	name extension node
 */
struct nmext {
	COMMON;
	char nmx[NMXSIZE-NMSIZE];	/* name extension (with name)*/
};

#define x_nm	x.nmx

/*
 *	block info node
 */
struct bnode {
	COMMON;
	union node *syms;
	union node *tags;
	int	regs;		/* reg alloc mask */
	long	lsize;		/* size of locals */
	int	tmsize;		/* max tmps used for 1 expr */
};

#define b_syms	b.syms
#define b_tags	b.tags
#define b_regs	b.regs
#define b_size	b.lsize
#define b_tsize b.tmsize

/*
 *	node to hold case for switch generation
 */
struct cnode {
	COMMON;
	int	c_value;	/* value for case */
	int	c_label;	/* case label or label label */
	int	c_def;		/* label defined */
};

#define c_defined c.c_def
#define c_casev c.c_value
#define c_casel c.c_label

union node {
	struct enode e;
	struct tnode t;
	struct nmext x;
	struct bnode b;
	struct cnode c;
	struct gnode g;
};

typedef union node NODE;
typedef NODE *NODEP;

/* defines for n_flags */

#define N_BRKPR	1	/* break printnode recursion */
#define N_COPYT	2	/* tptr is a copy */
#define N_ISFREE 4	/* node is on free list (error check) */

NODEP allocnode();
