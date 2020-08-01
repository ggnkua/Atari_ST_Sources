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
 * Defines for the instructions
 */

#define	OR	0
#define	BTST	1
#define	MOVEP	2
#define	BCHG	3
#define	BCLR	4
#define	BSET	5
#define	AND	6
#define	SUB	7
#define	ADD	8
#define	EOR	9
#define	CMP	10
#define	MOVE	11
#define	NEGX	12
#define	CHK	13
#define	LEA	14
#define	CLR	15
#define	NEG	16
#define	NOT	17
#define	NBCD	18
#define	SWAP	19
#define	PEA	20
#define	EXT	21
#define	MOVEM	22
#define	TST	23
#define	TAS	24
#define	TRAP	25
#define	LINK	26
#define	UNLK	27
#define	RESET	28
#define	NOP	29
#define	STOP	30
#define	RTE	31
#define	RTS	32
#define	TRAPV	33
#define	RTR	34
#define	JSR	35
#define	JMP	36
#define	ADDQ	37
#define	ST	38
#define	DBT	39
#define	SUBQ	40
#define	SF	41
#define	DBRA	42	/* aka DBF */
#define	SHI	43
#define	DBHI	44
#define	SLS	45
#define	DBLS	46
#define	SCC	47
#define	DBCC	48
#define	SCS	49
#define	DBCS	50
#define	SNE	51
#define	DBNE	52
#define	SEQ	53
#define	DBEQ	54
#define	SVC	55
#define	DVC	56
#define	SVS	57
#define	DVS	58
#define	SPL	59
#define	SMI	60
#define	DBMI	61
#define	SGE	62
#define	DBGE	63
#define	SLT	64
#define	DBLT	65
#define	SGT	66
#define	DBGT	67
#define	SLE	68
#define	DBLE	69
#define	BRA	70
#define	BSR	71
#define	BHI	72
#define	BLS	73
#define	BCC	74
#define	BCS	75
#define	BNE	76
#define	BEQ	77
#define	BVC	78
#define	BVS	79
#define	BPL	80
#define	BMI	81
#define	BGE	82
#define	BLT	83
#define	BGT	84
#define	BLE	85
#define	MOVEQ	86
#define	DIVU	87
#define	SBCD	88
#define	DIVS	89
#define	SUBX	90
#define	CMPM	91
#define	MULU	92
#define	ABCD	93
#define	EXG	94
#define	MULS	95
#define	ADDX	96
#define	ASR	97
#define	LSR	98
#define	ROXR	99
#define	ROR	100
#define	ASL	101
#define	LSL	102
#define	ROXL	103
#define	ROL	104
/*
 * Pseudo-ops
 */
#define	DC	105
