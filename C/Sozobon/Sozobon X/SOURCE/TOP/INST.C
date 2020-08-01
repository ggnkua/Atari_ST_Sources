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
 * Routines dealing with the parsing and output of instructions.
 */

#include "top.h"

static	void	getarg();
static	int	isreg();

/*
 * addinst(bp, op, args) - add an instruction to block 'bp'
 */
void
addinst(bp, op, args)
register BLOCK	*bp;
char	*op, *args;
{
	register INST	*ni;
	register int	i;
	register char	*s;
	char	*arg2 = "";

	if (*op == '\0')	/* no instruction there */
		return;

	ni = (INST *) alloc(sizeof(INST));

	ni->flags = 0;
	ni->opcode = -1;
	ni->next = NULL;
	ni->prev = NULL;
	ni->live = 0;
	ni->rref = ni->rset = 0;

	ni->src.areg = ni->dst.areg = 0;
	ni->src.ireg = ni->dst.ireg = 0;
	ni->src.disp = ni->dst.disp = 0;
	ni->src.amode = ni->dst.amode = NONE;

	/*
	 * Link into the block appropriately
	 */
	if (bp->first == NULL) {
		bp->first = bp->last = ni;
	} else {
		bp->last->next = ni;
		ni->prev = bp->last;

		bp->last = ni;
	}

	for (s = op; *s ;s++) {
		/*
		 * Pseudo-ops start with a period, so the length
		 * specifier can't be the first character.
		 */
		if (*s == '.' && s != op) {	/* length specifier */
			*s++ = '\0';
			switch (*s) {
			case 'b':
				ni->flags |= LENB;
				break;
			case 'w':
				ni->flags |= LENW;
				break;
			case 'l':
				ni->flags |= LENL;
				break;
			default:
				fprintf(stderr, "Bad length spec '%c'\n", *s);
				exit(1);
			}
		}
	}

	for (i=0; opnames[i] ;i++) {
		if (strcmp(op, opnames[i]) == 0) {
			ni->opcode = i;
			break;
		}
	}

	if (ni->opcode < 0) {
		fprintf(stderr, "Unknown op '%s'\n", op);
		exit(1);
	}

	/*
	 * Look for the split between the first and second operands.
	 */
	for (s = args; *s ;s++) {
		/*
		 * skip chars in parens, since an operand split can't
		 * occur within.
		 */
		if (*s == '(') {
			while (*s != ')')
				s++;
		}
		if (*s == ',') {
			*s++ = '\0';
			arg2 = s;
			break;
		}
	}

	getarg(&ni->src, args);
	getarg(&ni->dst, arg2);
}

/*
 * delinst(bp, ip) - delete instruction 'ip' in block 'bp'
 */
void
delinst(bp, ip)
BLOCK	*bp;
register INST	*ip;
{
	register INST	*pi, *ni;	/* previous and next instructions */

	pi = ip->prev;
	ni = ip->next;

	if (pi != NULL)
		pi->next = ni;
	else
		bp->first = ni;

	if (ni != NULL)
		ni->prev = pi;
	else
		bp->last = pi;

	/*
	 * Free space used by the instruction.
	 */
	freeop(&ip->src);
	freeop(&ip->dst);
	free(ip);

	s_idel++;
}

/*
 * getarg(op, s) - parse string 's' into the operand structure 'op'
 *
 * Hack alert!! The following code parses the operands only to the
 * extent needed by the optimizer. We're primarily interested in
 * details about addressing modes used, not in any expressions that
 * might be present. This code is highly tuned to the output of the
 * compiler.
 */
static	void
getarg(op, s)
register struct	opnd	*op;
register char	*s;
{
	extern	long	atol();
	register int	reg;
	register char	*p;

	if (*s == '\0') {
		op->amode = NONE;
		return;
	}

	if (*s == '#') {				/* immediate data */
		op->amode = IMM;
		s += 1;
		if (isdigit(s[0]) || s[0] == '-')
			op->disp  = atol(s);
		else {
			op->amode |= SYMB;
			op->astr = strsave(s);
		}
		return;
	} else if ((reg = isreg(s)) >= 0) {		/* reg. direct */
		op->amode = REG;
		op->areg = reg;
	} else if (s[0] == '(' || (s[0] == '-' && s[1] == '(')) {
		op->amode = REGI;
		if (s[0] == '-') {
			op->amode |= DEC;
			s++;
		}
		s++;		/* skip the left paren */
		if ((op->areg = isreg(s)) < 0) {
			fprintf(stderr, "bad reg. '%s'\n", s);
			exit(1);
		}
		s += 3;		/* skip the register and right paren */

		if (s[0] == '+')
			op->amode |= INC;
	} else if (!isdigit(s[0]) && (s[0] != '-')) {
		op->amode = ABS;
		op->astr = strsave(s);
	} else {
		for (p=s; isdigit(*p) || *p == '-' ;p++)
			;
		if (*p != '(') {
			/*
			 * Must have been absolute, but with an
			 * address instead of a symbol.
			 */
			op->amode = ABS;
			op->astr = strsave(s);
			return;
		}
		*p++ = '\0';
		op->disp = atol(s);
		s = p;
		if (s[0] == 'p' && s[1] == 'c') {	/* PC relative */
			if (s[2] == ')') {
				op->amode = PCD;
				return;
			}
			op->amode = PCDX;
			op->ireg = isreg(s+3);
			if (s[6] == 'l')
				op->amode |= XLONG;
		} else if ((reg = isreg(s)) >= 0) {
			op->areg = reg;
			if (s[2] == ')') {
				op->amode = REGID;
				return;
			}
			op->amode = REGIDX;
			op->ireg = isreg(s+3);
			if (s[6] == 'l')
				op->amode |= XLONG;
		} else {
			fprintf(stderr, "bad reg. '%s' after disp\n", s);
			exit(1);
		}
	}
}

/*
 * characters that can terminate a register name
 */
#define	isterm(c) ((c) == '\0' || (c) == ')' || (c) == ',' || (c) == '.')

static	int
isreg(s)
register char	*s;
{
	if (s[0] == 'd' && isdigit(s[1]) && isterm(s[2]))
		return D0 + (s[1] - '0');
	if (s[0] == 'a' && isdigit(s[1]) && isterm(s[2]))
		return A0 + (s[1] - '0');
	if (s[0] == 's' && s[1] == 'p' && isterm(s[2]))
		return SP;

	return -1;
}


/*
 * Routines for printing out instructions
 */

static	char	*rstr();
static	void	putop();

void
putinst(ip)
register INST	*ip;
{
	char	c;

	fprintf(ofp, "\t%s", opnames[ip->opcode]);

	switch (ip->flags) {
	case LENB:
		c = 'b';
		break;
	case LENW:
		c = 'w';
		break;
	case LENL:
		c = 'l';
		break;
	default:
		c = '\0';
		break;
	}
	if (c)
		fprintf(ofp, ".%c", c);

	if (ip->src.amode != NONE) {
		fprintf(ofp, "\t");
		putop(&ip->src);
	}

	if (ip->dst.amode != NONE) {
		fprintf(ofp, ",");
		putop(&ip->dst);
	}
#ifdef	DEBUG
	if (debug)
		fprintf(ofp, "\t\t* ref(%04x), set(%04x), live(%04x)",
			reg_ref(ip), reg_set(ip), ip->live);
#endif
	fprintf(ofp, "\n");
}

static	void
putop(op)
register struct	opnd	*op;
{
	switch (op->amode & MMASK) {
	case NONE:
		break;
	case REG:
		fprintf(ofp, "%s", rstr(op->areg));
		break;
	case IMM:
		if (op->amode & SYMB)
			fprintf(ofp, "#%s", op->astr);
		else
			fprintf(ofp, "#%ld", op->disp);
		break;
	case ABS:
		fprintf(ofp, "%s", op->astr);
		break;
	case REGI:
		if (op->amode & DEC)
			fprintf(ofp, "-");
		fprintf(ofp, "(%s)", rstr(op->areg));
		if (op->amode & INC)
			fprintf(ofp, "+");
		break;
	case REGID:
		fprintf(ofp, "%ld(%s)", op->disp, rstr(op->areg));
		break;
	case REGIDX:
		fprintf(ofp, "%ld(%s,", op->disp, rstr(op->areg));
		fprintf(ofp, "%s.%c)", rstr(op->ireg),
			(op->amode & XLONG) ? 'l' : 'w');
		break;
	case PCD:
		fprintf(ofp, "%ld(pc)", op->disp);
		break;
	case PCDX:
		fprintf(ofp, "%ld(pc,%s.%c)", op->disp, rstr(op->ireg),
			(op->amode & XLONG) ? 'l' : 'w');
		break;
	default:
		fprintf(stderr, "bad addr. mode in putop: %d\n", op->amode);
		exit(1);
	}
}

static	char *
rstr(r)
register char	r;
{
	static	char	buf[3];

	if (r == SP) {
		buf[0] = 's';
		buf[1] = 'p';
	} else if (r >= A0 && r <= A6) {
		buf[0] = 'a';
		buf[1] = '0' + (r - A0);
	} else {
		buf[0] = 'd';
		buf[1] = '0' + (r - D0);
	}
	buf[2] = '\0';

	return buf;
}

/*
 * opeq(op1, op2) - test equality of the two instruction operands
 */
bool
opeq(op1, op2)
register struct	opnd	*op1, *op2;
{
	if (op1->amode != op2->amode || op1->areg != op2->areg ||
	    op1->ireg  != op2->ireg)
		return FALSE;

	/*
	 * Depending on the addressing mode, we either need to
	 * compare the "astr" strings, or the displacements.
	 */
	if ((op1->amode == ABS) || (op1->amode == (IMM|SYMB))) {
		/* compare strings */
		if (op1->astr == NULL)
			return (op2->astr == NULL);
		else {
			if (op2->astr == NULL)
				return FALSE;
	
			return (strcmp(op1->astr, op2->astr) == 0);
		}
	} else {
		/* compare displacements */
		return (op1->disp == op2->disp);
	}
}
