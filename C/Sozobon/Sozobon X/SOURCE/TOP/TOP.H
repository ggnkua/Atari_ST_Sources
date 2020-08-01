/* Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#include <stdio.h>
#include <ctype.h>

#include "inst.h"
#include "opcodes.h"

#define	DEBUG		/* enable debug code */

#ifdef	DEBUG
#define	DBG(x)		if (debug) { x; }
#else
#define	DBG(x)
#endif

#ifndef	void
#define	void	int
#endif

/*
 * Basic defines and declarations for the optimizer.
 */

typedef	int	bool;

#ifndef	FALSE
#define	FALSE	0
#define	TRUE	1
#endif

/*
 * Basic Block:
 *
 * References a linked list of instructions that make up the block.
 * Each block can be exited via one of two branches, which are
 * represented by pointers to two other blocks, or null.
 */
struct	block {
	int	flags;			/* flags relating to this block */
	int	ref;			/* # of references to this block */
	int	bcode;			/* type of exiting branch */
	char	*name;			/* symbol name that starts the block */

	struct	inst	*first,		/* first instruction in block */
			*last;		/* last instruction in block */

	/*
	 * Execution traversals
	 */
	struct	block	*bcond,		/* conditional branch (or NULL) */
			*bfall;		/* "fall through" branch */

	/*
	 * Logical traversals
	 */
	struct	block	*chain;		/* links all blocks together */
	struct	block	*next;		/* next block in the file */

	/*
	 * Information for data-flow analysis
	 */
	int	rref;			/* registers ref'd before set */
	int	rset;			/* registers modified by block */
};

typedef	struct block	BLOCK;
typedef	struct inst	INST;

/*
 * Block flags
 */

#define	B_GLOBAL	0x01		/* is the block's symbol global? */
#define	B_TOUCHED	0x02		/* used in traversals */
#define	B_LABEL		0x04		/* the block needs a label */
#define	B_ISREACHED	0x08		/* block IS reached (for switches) */
#define	B_RET		0x10		/* block terminates with a 'return' */
#define	B_MARK		0x20		/* temporary 'touched' mark */

/*
 * Global data
 */

extern	FILE	*ifp, *ofp;		/* input and output file pointers */

/*
 * Option flags set in main
 */
extern	bool	debug;
extern	bool	do_peep;		/* enable peephole opt. */
extern	bool	do_brev;		/* enable branch reversals */
extern	bool	do_regs;		/* enable "registerizing" */
extern	bool	do_lrot;		/* enable loop rotations */
extern	bool	gflag;			/* set when using the debugger */
extern	bool	verbose;

/*
 * Optimization stats
 */
extern	int	s_bdel;
extern	int	s_badd;
extern	int	s_brev;
extern	int	s_peep1;
extern	int	s_peep2;
extern	int	s_peep3;
extern	int	s_idel;
extern	int	s_reg;
extern	int	s_lrot;

/*
 * These are set after calling readline.
 */
extern	char	*t_line;	/* text of the last line */
extern	char	*t_lab;		/* label (if any) on the last line */
extern	char	*t_op;		/* opcode */
extern	char	*t_arg;		/* arguments */


extern	char	*opnames[];	/* mnemonics for the instructions */

extern	BLOCK	*fhead;		/* head of the current function */

/*
 * Function declarations
 */

/*
 * branch.c
 */
extern	void	bopt();

/*
 * data.c
 */
extern	int	reg_ref(), reg_set();
extern	bool	sets(), refs(), uses();

/*
 * health.c
 */
extern	void	rhealth(), bprep();

/*
 * inst.c
 */
extern	void	addinst(), delinst(), putinst();
extern	bool	opeq();

/*
 * io.c
 */
extern	bool	readline();

/*
 * peep1.c
 */
extern	void	peep();

/*
 * reg.c
 */
extern	void	addvar(), setreg(), clrvar();

/*
 * util.c
 */
extern	char	*alloc();
extern	char	*strsave();

/*
 * sym.c
 */
extern	void	freeop(), freesym();
extern	BLOCK	*getsym(), *mksym();
extern	char	*mktmp();
