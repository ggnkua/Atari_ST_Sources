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

/*
 * Misc. define's, etc. for instruction parsing.
 */

struct	opnd {
	unsigned char	amode;	/* addressing mode used */
	unsigned char	areg;	/* primary register */
	unsigned char	ireg;	/* index register, if applicable */
	union {
		long	i_disp;		/* also used for immediate data */
		char	*i_astr;	/* pointer to any symbol present */
	} i_data;
};
#define	disp	i_data.i_disp
#define	astr	i_data.i_astr

/*
 * is_astr(m)	macro to determine, based on the amode field, whether
 *		the 'astr' field of the structure is active.
 */
#define	is_astr(m)	(((m) == ABS) || ((m) == (IMM|SYMB)))

/*
 * Addressing modes (in 'amode')
 */
#define	NONE	0		/* operand unused */
#define	REG	1		/* register direct */
#define	IMM	2		/* immediate */
#define	ABS	3		/* absolute */
#define	REGI	4		/* reg. indirect */
#define	REGID	5		/* reg. indirect, w/ displacement */
#define	REGIDX	6		/* reg. indirect, w/ displacement & index */
#define	PCD	7		/* PC relative, w/ displacement */
#define	PCDX	8		/* PC relative, w/ displacement & index */

#define	XLONG	0x10		/* long index register used */
#define	SYMB	0x20		/* symbol used, not constant */
#define	INC	0x40		/* auto-increment */
#define	DEC	0x80		/* auto-decrement */

#define	MMASK	0x0f		/* mode mask */
#define	FMASK	0xf0		/* flag mask */

#define	M(x)	((x) & MMASK)
#define	F(x)	((x) & FMASK)

/*
 * Registers
 */

#define	FIRSTREG	0
#define	A0	0
#define	A1	1
#define	A2	2
#define	A3	3
#define	A4	4
#define	A5	5
#define	A6	6
#define	A7	7
#define	SP	7	/* alias for A7 */
#define	D0	8
#define	D1	9
#define	D2	10
#define	D3	11
#define	D4	12
#define	D5	13
#define	D6	14
#define	D7	15
#define	LASTREG	15

#define	ISD(x)	((x) >= D0 && (x) <= D7)	/* is 'x' a  D reg. */
#define	ISA(x)	((x) >= A0 && (x) <= A7)	/* is 'x' an A reg. */
#define	RM(x)	(1 << (x))			/* form a register mask */

/*
 * DOK(x) - evaluates TRUE if 'x' is okay for a displacement value.
 *
 * 'x' must be of type "long"
 */
#define	DOK(x)	(((x) >= -32768L) && ((x) <= 32767L))

/*
 * D8OK(x) - like DOK but for 8-bit displacements
 */
#define	D8OK(x)	(((x) >= -128) && ((x) <= 127))

struct	inst {
	char	opcode;			/* type of instruction */
	char	flags;			/* length, etc. */
	struct	opnd	src, dst;	/* optional operands */
	int	rref, rset;
	int	live;			/* regs. live after this inst. */
	struct	inst	*next;
	struct	inst	*prev;
};

/*
 * Instruction flags
 */

#define	LENB	0x01
#define	LENW	0x02
#define	LENL	0x04
