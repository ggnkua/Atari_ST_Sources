/*
 *  Operator-precedence parse table
 *
 */

#define	PER	0
#define	PLT	1
#define	PEQ	2
#define	PGT	3

char ptab[12][12] = {
	PER, PLT, PLT, PER, PLT, PLT, PLT, PLT, PLT, PLT, PLT, PLT, /* END */
	PGT, PER, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, /* ID */
	PER, PLT, PLT, PEQ, PLT, PLT, PLT, PLT, PLT, PLT, PLT, PLT, /* OPAR */
	PGT, PER, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, /* CPAR */
	PGT, PLT, PLT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, /* UNARY */
	PGT, PLT, PLT, PGT, PLT, PGT, PGT, PGT, PGT, PGT, PGT, PGT, /* MULT */
	PGT, PLT, PLT, PGT, PLT, PLT, PGT, PGT, PGT, PGT, PGT, PGT, /* ADD */
	PGT, PLT, PLT, PGT, PLT, PLT, PLT, PGT, PGT, PGT, PGT, PGT, /* SHIFT */
	PGT, PLT, PLT, PGT, PLT, PLT, PLT, PLT, PGT, PGT, PGT, PGT, /* REL */
	PGT, PLT, PLT, PGT, PLT, PLT, PLT, PLT, PLT, PGT, PGT, PGT, /* AND */
	PGT, PLT, PLT, PGT, PLT, PLT, PLT, PLT, PLT, PLT, PGT, PGT, /* XOR */
	PGT, PLT, PLT, PGT, PLT, PLT, PLT, PLT, PLT, PLT, PLT, PGT  /* OR */
};
