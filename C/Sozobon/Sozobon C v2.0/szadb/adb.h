/* Copyright (c) 1988 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	adb.h
 */

#define NUMERIC		3
#define HEX		7
#define ALPHA		5
#define SPECCMD		8
#define SPECX		16

#define ALPHANUM	1
#define HEXDIG		2
#define ALPHAONLY	4

#define BSIZE		512
#define LOGBS		9
#define SYMSZ		10

/*
 *	Error types
 */
#define ACCESS		0	/* access outside address map */
#define UNBAL		1	/* unbalanced parenthesis */
#define UNKNOWN		2	/* unknown command */
#define BADCMD		3	/* bad command at this time */
#define BADNAME		4	/* cant find symbol */
#define BADRNAME	5	/* cant find register */

#define sreg(a)	((a) & 7)
#define smod(a)	(((a) >> 3) & 7)
#define dreg(a)	(((a) >> 9) & 7)
#define dmod(a)	(((a) >> 6) & 7)

struct symbol {
	char		flags;
	unsigned long	value;
	struct symbol * next;
	char		name[1];	/* must be last */
};

struct file {
	int	fid;
	int	flags;
	int	pid;
	char *	name;
	struct symbol *symptr;
	long	cblock;
	char	buf[BSIZE + BSIZE];
};

#define SUBPCS	1

/*
 *	Base page layout
 */

struct basepg {
	char *		p_lowtpa;	/* base address of TPA */
	char *		p_hitpa;	/* end of TPA */
	char *		p_tbase;	/* base address of text */
	unsigned long	p_tlen;		/* length of text */
	char *		p_dbase;	/* base of data */
	unsigned long	p_dlen;		/* length of data */
	char *		p_bbase;	/* base of bss */
	unsigned long	p_blen;		/* length of bss */
	char *		p_dta;
	struct basepg * p_parent;
	long		p_res;
	char *		p_env;		/* ptr to environment string */
	long		p_fill[20];
	char		p_cmdlin[0x80];	/* command line image */
};

struct regs {
	char *		name;
	unsigned long *	value;
};

#define TBITS	0xc000
#define ITRACE	0x8000

#define PC	0
#define SR	1
#define XSP	2
#define D0	3
#define A0	11
#define FP	(A0 + 6)
#define SP	(A0 + 7)
#define MAXBPTS		10

#define BPT		0x4afc

#define BP_VALID	1
#define BP_ACTIVE	2

struct bpt {
	int	flag;
	int	instr;
	long	addr;
};
#define START_DBG	0
#define RD_TEXT		1
#define RD_DATA		2
#define RD_USER		3
#define WR_TEXT		4
#define WR_DATA		5
#define WR_USER		6
#define CONTINUE	7
#define KILL_PID	8
#define SSTEP		9

long ptrace();

struct fheader {
	short	magic;
	long	tsize;
	long	dsize;
	long	bsize;
	long	ssize;
	long	stksize;
	long	entry;
	short	flag;
};

#define MAGIC	0x601a

struct filsym {
	char	name[8];
	short	flag;
	long	value;
};

#define S_DEF	0100000
#define S_EQU	0040000
#define S_EXT	0020000
#define S_REG	0010000
#define S_REF	0004000
#define S_DATA	0002000
#define S_TEXT	0001000
#define S_BSS	0000400
#define S_FIL	0000200

#define S_EXTEND	(S_TEXT|S_EQU)
#define NAMEMAX		80
