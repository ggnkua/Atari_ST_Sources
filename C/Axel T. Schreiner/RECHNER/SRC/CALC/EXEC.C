/*
 *	GEM calculator
 *	resource-dependent part: execution
 *	Copyright 1985 Axel T. Schreiner, Ulm, W-Germany
 */

#include "b:\calc\calc.h"			/* resource */

/*
 *	tunable
 */

#define	MAXSTACK	20		/* stack size kludge */

typedef	long	number;			/* computational object */

#define	MINLEN	6			/* minimum display length */
#define	FMTd	"%c %*ld"		/* decimal output */
#define	FMTx	"%c 0x%0*lx"		/* hexadecimal output */
#define	FMTo	"%c 0%0*lo"		/* octal output */

/*
 *	definitions
 */

#define	IDLE	0			/* no number started */
#define	NUMBER	1			/* number started */

typedef struct stack {			/* value and operator stack */
	struct stack * next;
	number val;			/* must also contain int operator */
	} stack;

					/* need fake dynamic stack, since
					   GEMLIB does not support malloc */
static stack elts[MAXSTACK], *avail, *top = elts;

/*
 *	calculator utilities
 */

static int pos(op)			/* packed operator index */
	register int op;
{	static int list[] = {
		BLPAR, BOR, BXOR, BAND, BLSH,
		BRSH, BADD, BSUB, BMULT, BDIV,
		BREM
		};
	register int i;

	for (i = 0; list[i] != op; ++ i)
		;
	return i;			/* assume we find it... */
}
	
static int high(a, b)			/* true if a has priority over b */
	register int a, b;
{	static int prio[] = {		/* operator priority */
		/* BLPAR */		1,
		/* BOR */		2,
		/* BXOR */		3,
		/* BAND */		4,
		/* BLSH, BRSH */	5, 5,
		/* BADD, BSUB */	6, 6,
		/* BMULT, BDIV, BREM */	7, 7, 7
		};

	return prio[pos(a)] > prio[pos(b)];
}

static number bin(op, a, b)		/* execute binary operator */
	register int op;
	number a, b;
{
	switch (op) {
	case BOR:	return a | b;
	case BXOR:	return a ^ b;
	case BAND:	return a & b;
	case BLSH:	return a << b;
	case BRSH:	return a >> b;
	case BADD:	return a + b;
	case BSUB:	return a - b;
	case BMULT:	return a * b;
	case BDIV:	return b? a / b: 0;
	case BREM:	return b? a % b: 0;
	}
}

static stack * push(next, val)
	register stack * next;		/* onto this stack */
	number val;			/* this value */
{	register stack * p;

	if (avail)			/* recycle */
		p = avail, avail = avail->next;
	else if (top)			/* use new element */
	{	p = top;
		if (++ top >= elts + MAXSTACK)
			top = (stack *) 0;
	}
	else				/* sorry, Charlie... */
	{	Alert(ASTACK);
		return (stack *) 0;
	}
	p->next = next;
	p->val = val;
	return p;
}

static free(p)
	stack * p;
{
	p->next = avail, avail = p;
}

/*
 *	calculator
 */

int Calc(code, bp, l)			/* true if we should quit */
	register int code;		/* digit or operation */
	char * bp;			/* first call: output buffer */
	int l;				/* first call: text length */
{	static stack * opr,		/* operator stack */
		* ond;			/* operand stack */
	static int state = IDLE,	/* of automaton */
		sign = 1,		/* extra sign of display */
		base = 10,		/* base for display */
		lpar = 0;		/* open ( */
	static number display = 0,	/* assembled number */
		value = 0;		/* sign included */
	static char * buf;		/* display buffer */
	static int len;

	register stack * p;

	if (! buf)			/* first call */
		if ((len = l) < MINLEN)
		{	Alert(ASMALL);
			return 1;
		}
		else
			buf = bp;

	switch (code) {
	case BZERO:	code = 0;  goto digit;
	case BONE:	code = 1;  goto digit;
	case BTWO:	code = 2;  goto digit;
	case BTHREE:	code = 3;  goto digit;
	case BFOUR:	code = 4;  goto digit;
	case BFIVE:	code = 5;  goto digit;
	case BSIX:	code = 6;  goto digit;
	case BSEVEN:	code = 7;  goto digit;
	case BEIGHT:	code = 8;  goto digit;
	case BNINE:	code = 9;  goto digit;
	case BA:	code = 10;  goto digit;
	case BB:	code = 11;  goto digit;
	case BC:	code = 12;  goto digit;
	case BD:	code = 13;  goto digit;
	case BE:	code = 14;  goto digit;
	case BF:	code = 15;
	digit:
		if (state == IDLE)
			display = 0, state = NUMBER;
		display = display * base + code;
		value = sign*display;
		break;
	case BMINUS:
		sign = - sign;
		value = sign*display;
		break;
	case BCOMP:			/* hmmmm... */
		display = ~display;
		value = sign*display;
		break;
	case BDEC:
		base = 10;
		break;
	case BOCT:
		base = 8;
		break;
	case BHEX:
		base = 16;
		break;
	case BEQUAL:
		while (opr)
		{	if (opr->val != BLPAR)
			{	value = bin((int) opr->val, ond->val, value);
				p = ond->next, free(ond), ond = p;
			}
			p = opr->next, free(opr), opr = p;
		}
		display = value, sign = 1, state = IDLE;
		break;
	case BOR:
	case BXOR:
	case BAND:
	case BLSH:
	case BRSH:
	case BADD:
	case BSUB:
	case BMULT:
	case BDIV:
	case BREM:
		while (opr && ! high(code, (int) opr->val))
		{	value = bin((int) opr->val, ond->val, value);
			p = ond->next, free(ond), ond = p;
			p = opr->next, free(opr), opr = p;
		}
		if (! (p = push(opr, (number) code)))
			goto clear;
		opr = p;
		if (! (p = push(ond, value)))
			goto clear;
		ond = p;
		display = value, sign = 1, state = IDLE;
		break;
	case BLPAR:
		if (state == IDLE)
		{	++ lpar;
			if (! (p= push(opr, (number) code)))
				goto clear;
			opr = p;
		}
		else
			Alert(APAREN);
		return 0;
	case BRPAR:
		if (state == IDLE || ! lpar)
		{	Alert(APAREN);
			return 0;
		}
		while (opr && opr->val != BLPAR)
		{	value = bin((int) opr->val, ond->val, value);
			p = ond->next, free(ond), ond = p;
			p = opr->next, free(opr), opr = p;
		}
		--lpar, p = opr->next, free(opr), opr = p;
		display = value, sign = 1, state = IDLE;
		break;
	case BCLEAR:
	clear:
		while (opr)
			p = opr->next, free(opr), opr = p;
		while (ond)
			p = ond->next, free(ond), ond = p;
		lpar = 0;
		base = 10;
	case BCENTRY:
		display = value = 0;
		sign = 1;
		state = IDLE;
	}
	sprintf(buf,
		base == 8? FMTo: base == 16? FMTx: FMTd,
		value < 0? '-': ' ',
		base == 8? len-4: base == 16? len-5: len-3,
		value < 0? -value: value);
	return 0;
}
