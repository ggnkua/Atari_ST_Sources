/* Copyright (c) 1989,1991 by Sozobon, Limited.  Author: Tony Andrews
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
 * The code in this file deals with "registerizing" local variables and
 * parameters. The general idea is to look for highly referenced local
 * variables and parameters and effectively turn them into register
 * variables automatically. Only the D registers are used, currently, so
 * for pointer variables, a manual "register" declaration in the source
 * code is actually better.
 *
 * We need to be certain of several things about a variable before placing
 * it in a register. It's address must not be taken, and it must not be
 * referred to through "aliases" (e.g. when casting to a shorter object).
 * It must be able to fit in a register. And to keep things like printf from
 * breaking, parameters can only be registerized if none of the parameters
 * have their address taken.
 *
 * The compiler makes this all possible by placing "hints" within the
 * generated assembly code. These hints appear as comments, but are parsed
 * by the optimizer, and the information is stashed away by calling addvar().
 * The hints give us the size and offset of each parameter and local variable.
 * Their names are also given, although that information isn't needed here.
 *
 * There are tradeoffs to be wary of when registerizing. If no register
 * variables exist yet, then "movem" instructions have to be added, requiring
 * more references to make this worthwhile. In the case of parameters, the
 * register has to be initialized from the stack. The four cases are:
 *
 *	Locals	w/ other regs:	1 reference  required
 *		no other regs:	4 references required
 *	Parms	w/ other regs:	2 references required
 *		no other regs:	6 references required
 *
 * The numbers above represent the break-even point based on a savings of
 * 2 bytes per reference, and the incremental cost of adding "movem" or
 * "move" instructions as needed.
 *
 * This optimizes for space only. To optimize for time, each reference would
 * be weighted based on the loop nesting level at which it occurs.
 */

#include "top.h"

#define	MAXLOCALS	100

static	struct	linfo {
	long	offset;		/* offset from A6 */
	int	size;		/* size of the object */
	int	ref;		/* # of references to the local */
	int	reg;		/* reg. we assigned it to */
	int	flags;		/* length, etc. */
} locals[MAXLOCALS];

#define	ALIASED		0x1	/* offset is aliased with another */
#define	ADDR_TAKEN	0x2	/* address of the variable was taken */

#define	IS_LOCAL(x)	(locals[(x)].offset < 0)
#define	IS_PARM(x)	(locals[(x)].offset > 0)

static	bool	paddr;		/* address of a parameter was taken */
static	int	lcnt;		/* number of local variables we've seen */
static	int	rcnt;		/* number of locals that got registerized */

static	int	omask, nmask;	/* old and new register masks */

/*
 * addvar(size, off) - add a variable entry for the current function
 *
 * These come from hints the compiler gives us about local variables.
 * We use the size and offset here to make sure we don't have aliasing
 * problems with the local variables we want to registerize.
 */
void
addvar(size, off)
int	size;
int	off;
{
	locals[lcnt].offset = off;
	locals[lcnt].size = size;
	locals[lcnt].flags = 0;
	locals[lcnt].ref = 0;

	lcnt++;
}

/*
 * clrvar() - clear the variable list
 */
void
clrvar()
{
	register int	i;

	/*
	 * re-initialize the local information
	 */
	for (i=0; i < MAXLOCALS ;i++) {
		locals[i].ref = 0;
		locals[i].reg = -1;
		locals[i].flags = 0;
		locals[i].offset = 0;
		locals[i].size = 0;
	}
	paddr = FALSE;
	rcnt = lcnt = 0;
}

/*
 * setreg() - try to "registerize" local variables in the given function
 */
void
setreg(bp)
BLOCK	*bp;
{
	void	lcheck(), lassign(), lrewrite();

	lcheck(bp);
	lassign();

#ifdef	DEBUG
	if (debug)
		dump_table();
#endif

	if (rcnt > 0)
		lrewrite(bp);

	s_reg += rcnt;		/* keep totals for accounting */
}

/*
 * lcheck() - scan for local variable references in the given function
 */
static void
lcheck(bp)
BLOCK	*bp;
{
	void	ckref();
	register int	i;
	register BLOCK	*cb;
	register INST	*ci;

	for (cb = bp; cb != NULL ;cb = cb->next) {
		for (ci = cb->first; ci != NULL ;ci = ci->next) {
			ckref(ci, &ci->src);
			ckref(ci, &ci->dst);
		}
	}

	/*
	 * Now figure out which registers are currently used.
	 */
	ci = bp->first->next;

	if (ci != NULL && ci->opcode == MOVEM) {
		if (ci->src.amode == REG)
			omask = RM(ci->src.areg);
		else
			omask = stomask(ci->src.astr);
	} else
		omask = 0;
}

/*
 * ckref() - check for a local variable reference
 *
 * If a local variable reference is found, it's added to the table or
 * (if already there) its reference count is incremented. If we're
 * taking its address, note that too.
 */
static void
ckref(ip, op)
INST	*ip;
struct	opnd	*op;
{
	register int	i;
	register int	sz;

	if (op->amode != REGID || op->areg != A6)
		return;

	switch (ip->flags) {
	case LENL:
		sz = 4;
		break;
	case LENW:
		sz = 2;
		break;
	case LENB:
	default:		/* for LEA and PEA */
		sz = 1;
		break;
	}

	/*
	 * is the local variable already in the table?
	 */
	for (i=0; i < lcnt ;i++) {
		if (locals[i].offset == op->disp && locals[i].size == sz) {
			locals[i].ref++;
			break;
		}
	}

	/*
	 * If not in the table, add an entry for it. If we add an entry
	 * here, it must be an alias for one of the entries we got via
	 * the compiler hints.
	 */
	if (i == lcnt) {
		locals[lcnt].offset = op->disp;
		locals[lcnt].size = sz;
		locals[lcnt].flags = 0;
		locals[lcnt].ref = 1;

		lcnt++;
	}

	if (ip->opcode == LEA || ip->opcode == PEA) {
		locals[i].flags = ADDR_TAKEN;
		/*
		 * If we took the address of a parameter, note that
		 * by setting 'paddr'.
		 */
		if (IS_PARM(i))
			paddr = TRUE;
	}
}

/*
 * lassign() - assign local variable to registers
 *
 * Check for aliases, sort the table, and then decide how to assign
 * the local variables to registers.
 */
static void
lassign()
{
	void	ck_aliases(), sort_table(), do_sort();
	register int	i;
	register int	r;
	int	minlref;	/* min. required references for a local */
	int	minpref;	/* min. required references for a parameter */

	ck_aliases();		/* disqualify any "aliased" references */
	sort_table();		/* and sort by reference count */

	/*
	 * If there were already "movem" instructions, then we should
	 * convert as many locals as possible to registers. If we're
	 * going to have to add the movem's, then we need at least 4
	 * references for this to be worthwhile. The 2 movem instructions
	 * take 8 bytes, and each reference conversion saves 2 bytes.
	 * This analysis optimizes for size.
	 */
	minlref = (omask != 0) ? 1 : 4;
	minpref = (omask != 0) ? 2 : 6;

	nmask = omask;

	for (i=0, r=D3; r <= D7 ;) {

		/*
		 * If the register is already in use, skip it.
		 */
		if (omask & RM(r)) {
			r++;
			continue;
		}

		/*
		 * If no more eligible variables, then stop.
		 */
		if (locals[i].ref <= 0)
			break;

		/*
		 * If something meets the minimums, then assign it to
		 * the current register, and adjust the minimums.
		 */
		if ((IS_LOCAL(i) && locals[i].ref >= minlref) ||
		    (IS_PARM(i)  && locals[i].ref >= minpref)) {
			locals[i].reg = r;
			nmask |= RM(r);
			minlref = 1;
			minpref = 2;
			r++;
			i++;
		} else {
			/*
			 * If we run into something that isn't referenced
			 * enough, disqualify it and re-sort. There might
			 * still be something else worth doing.
			 */
			locals[i].ref = -locals[i].ref;
			do_sort();
		}
	}
	rcnt = i;
}

/*
 * ck_aliases() - check for aliases in the locals table
 *
 * An alias occurs when two different offsets off of A6 both reference
 * the same local. This can happen when casting to a smaller type. Since
 * these references would be a pain to rewrite, we just bag it.
 */
static void
ck_aliases()
{
	static	bool	ck_aref();
	register int	i;
	register int	s;
	register long	d;

	for (i=0; i < lcnt ;i++) {
		d = locals[i].offset;
		s = locals[i].size;

		if (ck_aref(d, s))
			locals[i].flags |= ALIASED;
	}
}

/*
 * ck_aref() - check for an aliased reference
 */
static bool
ck_aref(d, len)
register long	d;
register int	len;
{
	register int	i;

	for (i=0; i < lcnt ;i++) {
		if (locals[i].offset == d && locals[i].size == len)
			continue;

		if (overlaps(d, len, locals[i].offset, locals[i].size)) {
			locals[i].flags |= ALIASED;
			return TRUE;
		}
	}
	return FALSE;
}

static bool
overlaps(d1, s1, d2, s2)
register long	d1, d2;
int		s1, s2;
{
	register long	e1, e2;

	e1 = d1 + s1 - 1;
	e2 = d2 + s2 - 1;

	if (d1 >= d2 && d1 <= e2)	/* d1 inside d2 <=> e2 */
		return TRUE;

	if (e1 >= d2 && e1 <= e2)	/* e1 inside d2 <=> e2 */
		return TRUE;

	return FALSE;
}

static void
sort_table()
{
	register int	i;

	/*
	 * Remove uninteresting references from consideration:
	 *
	 * 1. Variables whose address was taken, or are aliased with another.
	 * 2. Variables that don't fit in a register.
	 */
	for (i=0; i < lcnt ;i++) {
		if (locals[i].flags&(ADDR_TAKEN|ALIASED) || locals[i].size > 4)
			locals[i].ref = -locals[i].ref;
	}

	/*
	 * If paddr is set, remove any parameters from consideration. We
	 * have to do this so that things like printf (that take the address
	 * of a parameter and increment it) don't break. Only if no parameter
	 * addresses are taken, can we consider registerizing any of them.
	 */
	if (paddr) {
		for (i=0; i < lcnt ;i++) {
			if (IS_PARM(i) && (locals[i].ref > 0))
				locals[i].ref = -locals[i].ref;
		}
	}

	do_sort();
}

static void
do_sort()
{
	register int	i;
	struct	linfo	l;

	/*
	 * simple bubble sort
	 */
	for (i=0; i < (lcnt-1) ;) {
		if (locals[i].ref < locals[i+1].ref) {
			l = locals[i];
			locals[i] = locals[i+1];
			locals[i+1] = l;
			if (i > 0)
				i--;
		} else
			i++;
	}
}

/*
 * lrewrite() - rewrite the function based on the new register assignments
 *
 * Fixing the references is easy, but we have to fix up (or add) the movem
 * instructions as well. Also, we call addinits() to initialize any registers
 * that will contain parameters.
 */
static void
lrewrite(bp)
BLOCK	*bp;
{
	void	fixref(), fixmove(), addmovem();
	INST	*findlnk();
	register int	i;
	register BLOCK	*cb;
	register INST	*ci;

	/*
	 * First, rewrite all the references to the locals that
	 * we've reassigned to registers.
	 */
	for (cb = bp; cb != NULL ;cb = cb->next) {
		for (ci = cb->first; ci != NULL ;ci = ci->next) {
			fixref(&ci->src);
			fixref(&ci->dst);
		}
	}

	/*
	 * If the movem's are there, just find them and fix up the
	 * register specs.
	 */
	ci = bp->first->next;
	if (ci != NULL && ci->opcode == MOVEM) {

		/*
		 * First, add the initialization instructions.
		 */
		addinits(bp, bp->first->next);

		fixmove(&ci->src);

		for (cb = bp; cb != NULL ;cb = cb->next) {
			if (cb->flags & B_RET) {
				for (ci=cb->last; ci != NULL ;ci=ci->prev) {
					if (ci->opcode == MOVEM) {
						fixmove(&ci->dst);
						return;
					}
				}
			}
		}
		return;
	}

#ifdef	DEBUG
	if (debug)
		printf("adding movem instructions\n");
#endif
	/*
	 * There aren't any movem instructions, so we have to add
	 * them here. What a pain...
	 */
	addmovem(bp, findlnk(bp), TRUE);
	addinits(bp, findlnk(bp)->next);

	for (cb = bp; cb != NULL ;cb = cb->next) {
		if (cb->last->opcode == RTS) {
			for (ci=cb->last; ci != NULL ;ci=ci->prev) {
				if (ci->opcode == UNLK) {
					addmovem(cb, ci, FALSE);
					return;
				}
			}
		}
	}
	/*
	 * Reaching this point would be an error, you'd think. It means
	 * we didn't find the exit from this function. Strangely enough,
	 * this can actually happen in routines with infinite loops.
	 * Since the "return" block isn't reachable, branch optimization
	 * actually removes it. So we can't consider it an error here if
	 * we don't find any "unlk" instruction.
	 */
}

static void
fixmove(op)
struct	opnd	*op;
{
	char	*masktos();

	freeop(op);
	op->amode = ABS;
	op->astr = strsave(masktos(nmask));
}

/*
 * findlnk() - find the LINK instruction in the given block
 *
 * When profiling, the LINK isn't the first instruction in the entry
 * block. This function lets us handle both cases cleanly.
 */
static	INST *
findlnk(bp)
BLOCK	*bp;
{
	INST	*ip;

	for (ip=bp->first; ip != NULL ;ip = ip->next) {
		if (ip->opcode == LINK)
			return ip;
	}
	return NULL;
}

static void
addmovem(bp, ip, is_entry)
BLOCK	*bp;			/* block where we're working */
INST	*ip;			/* instruction before or after the movem */
bool	is_entry;		/* true if we're doing the entry code */
{
	char	*masktos();
	register INST	*ni;
	struct	opnd	*op;
	register int	i;

	if (ip == NULL)		/* no LINK found */
		return;

	/*
	 * Allocate and initialize a new instruction
	 */
	ni = (INST *) alloc(sizeof(INST));

	ni->flags = LENL;
	ni->opcode = MOVEM;
	ni->live = 0;
	ni->rref = ni->rset = 0;

	ni->src.areg = ni->dst.areg = 0;
	ni->src.ireg = ni->dst.ireg = 0;
	ni->src.disp = ni->dst.disp = 0;

	/*
	 * Set up the SP reference
	 */
	op = (is_entry) ? &ni->dst : &ni->src;
	op->amode = (is_entry) ? REGI|DEC : REGI|INC;
	op->areg = SP;

	/*
	 * Set up the register spec operand
	 */
	op = (is_entry) ? &ni->src : &ni->dst;

	op->amode = ABS;
	op->astr = strsave(masktos(nmask));

	/*
	 * If there's only one register being used, we should really
	 * change the operand to be register direct. This way, the
	 * peephole optimization will turn the "movem" into a simple
	 * "move". Since we're adding an instruction here, we really
	 * need to make it as painless as possible.
	 */
	if (rcnt == 1) {
		free(op->astr);
		op->amode = REG;

		for (i=D0; i <= D7 ;i++) {
			if (nmask & RM(i)) {
				op->areg = i;
				break;
			}
		}
	}

	/*
	 * Link the instruction into the block
	 */
	if (is_entry) {
		ni->next = ip->next;	/* link the MOVEM to its neighbors */
		ni->prev = ip;

		ip->next = ni;		/* link its neighbors to the MOVEM */

		if (bp->last == ip)
			bp->last = ni;
		else
			ni->next->prev = ni;
	} else {
		ni->next = ip;		/* link the MOVEM to its neighbors */
		ni->prev = ip->prev;

		ip->prev = ni;		/* link its neighbors to the MOVEM */

		if (bp->first == ip)
			bp->first = ni;
		else
			ni->prev->next = ni;
	}
}

static void
addinits(bp, ip)
BLOCK	*bp;			/* block where we're working */
INST	*ip;			/* instruction before the moves */
{
	char	*masktos();
	register INST	*ni;
	struct	opnd	*op;
	register int	i;

	if (ip == NULL)		/* no LINK found */
		return;

	for (i=0; i < rcnt ;i++) {
		/*
		 * If it's a local variable, we don't have to do anything.
		 */
		if (IS_LOCAL(i))
			continue;

		/*
		 * Allocate and initialize a new instruction
		 */
		ni = (INST *) alloc(sizeof(INST));
	
		switch (locals[i].size) {
		case 1:
			ni->flags = LENB;
			break;
		case 2:
			ni->flags = LENW;
			break;
		case 4:
			ni->flags = LENL;
			break;
		default:
			fprintf(stderr, "Invalid length\n");
			exit(1);
		}

		ni->opcode = MOVE;
		ni->live = 0;
		ni->rref = ni->rset = 0;
		ni->src.ireg = ni->dst.ireg = 0;
	
		/*
		 * Set up the variable reference.
		 */
		ni->src.amode = REGID;
		ni->src.areg  = A6;
		ni->src.disp  = locals[i].offset;
	
		/*
		 * Set up the register spec operand
		 */
		ni->dst.amode = REG;
		ni->dst.areg  = locals[i].reg;
		ni->dst.disp  = 0;

		/*
		 * Link the instruction into the block
		 */
		ni->next = ip->next;	/* link MOVE to its neighbors */
		ni->prev = ip;

		ip->next = ni;		/* link neighbors to the MOVE */

		if (bp->last == ip)
			bp->last = ni;
		else
			ni->next->prev = ni;
	}
}

static void
fixref(op)
struct	opnd	*op;
{
	register int	i;

	if (op->amode != REGID || op->areg != A6)
		return;

	/*
	 * Does the reference need to be changed?
	 */
	for (i=0; i < rcnt ;i++) {
		if (locals[i].offset == op->disp) {
			op->amode = REG;
			op->areg = locals[i].reg;
			return;
		}
	}
}

/*
 * stomask() - convert a register list to a mask
 *
 * Convert a string like "Rm-Rn/Ro-Rp" or "Rm-Rn" to the appropriate
 * mask value.
 */
static int
stomask(s)
char	*s;
{
	register int	mask;
	register char	*p;

	mask = dorspec(s);

	for (p=s; *p && *p != '/' ;p++)
		;

	if (*p == '/')
		mask |= dorspec(p+1);

	return mask;
}

/*
 * dorspec() - convert a partial register spec
 *
 * Convert a string like "Rm" or "Rm-Rn" to a mask.
 */
static int
dorspec(s)
register char	*s;
{
	register int	base;
	register int	m, n;
	register int	mask;

	base = (s[0] == 'd') ? D0 : A0;

	m = s[1] - '0' + base;

	if (s[2] != '-')
		return RM(m);

	n = s[4] - '0' + base;

	for (mask=0; m <= n ;m++)
		mask |= RM(m);

	return mask;
}

/*
 * masktos() - convert a register mask to a descriptive string
 *
 * Generates a string of the form "Rm/Rn/Ro/..."
 */
static char *
masktos(mask)
register int	mask;
{
	static	char	buf[64];
	register char	*p = buf;
	register int	r;

	for (r = D0; r <= D7 ;r++) {
		if (mask & RM(r)) {
			if (p != buf)
				*p++ = '/';
			*p++ = 'd';
			*p++ = (r - D0) + '0';
		}
	}
	for (r = A0; r <= A7 ;r++) {
		if (mask & RM(r)) {
			if (p != buf)
				*p++ = '/';
			*p++ = 'a';
			*p++ = (r - A0) + '0';
		}
	}
	*p = '\0';

	return buf;
}

#ifdef	DEBUG
dump_table()
{
	register int	i;

	printf("%d local variables and parameters found\n", lcnt);
	for (i=0; i < lcnt ;i++) {
		printf("len = %d\n", locals[i].size);
		printf("%02d: disp=%3ld, len=%d ref=%2d reg=%s",
			i, locals[i].offset,
			locals[i].size,
			locals[i].ref,
			locals[i].reg >= 0 ? masktos(RM(locals[i].reg)) : "-");
		if (locals[i].flags & ADDR_TAKEN)
			printf(" ADDR_TAKEN");
		if (locals[i].flags & ALIASED)
			printf(" ALIASED");
		printf("\n");
	}
}
#endif
