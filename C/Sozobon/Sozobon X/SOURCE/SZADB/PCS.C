/* Copyright (c) 1990 by Sozobon, Limited.  Authors: Johann Ruegg, Don Dugger
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	pcs.c
 */

#include <setjmp.h>
#include "adb.h"

#define IN_PCS
#include "lang.h"

#ifndef NULL
#define NULL	0L
#endif

unsigned long esp;
char cmdbuf[256];
struct basepg *bpage;
extern long dot;
extern int dotset;
extern int dotoff;
extern struct regs regs[];

struct bpt bpt[MAXBPTS] = 0;

struct bpt *findbpt();

prstack(argsflg)
{
	int first;
	long pc, fp, sp, ap;
	long npc, nfp, brpc;
	long getn(), atbranch();
	struct basepg *bp = bpage;

	pc = *(regs[PC].value);
	fp = *(regs[FP].value);
	sp = *(regs[SP].value);
	first = 1;

	while (pc >= (long)bp->p_tbase && 
	       pc < (long)bp->p_tbase + bp->p_tlen) {
		prtf("%A", pc);
		if (first && (atlink(pc) || atrts(pc) ||
		    ((brpc = atbranch(pc)) && atlink(brpc)))) {
			npc = getn(sp, 4);
			nfp = fp;
			ap = sp+4;
		} else {
			nfp = getn(fp,4);
			npc = getn(fp+4,4);
			ap = fp+8;
		}
		if (argsflg)
			funargs(npc, ap, nfp);
		putchr('\n');

		if (nfp < (long)bp->p_bbase+bp->p_blen ||
		    nfp > (long)bp->p_hitpa ||
		    nfp <= sp || nfp < fp ||
		    (nfp == fp && !first))
			break;
		pc = npc;
		fp = nfp;
		first = 0;
	}
}

funargs(retpc, argp, limit)
long retpc, argp, limit;
{
	int i, n;
	unsigned w;

	n = numargs(retpc);

	if (n == 0) {		/* optimized out maybe */
/*		prtf("(? at %I)", argp); */
		prtf(M1, argp);
		return;
	}

	putchr('(');
	for (i=0; i<n; i++, argp += 2) {
		w = getn(argp, 2);
		prt4x(w);
		if (argp+2 >= limit)
			break;
		if ((i+1) < n)
			putchr(',');
	}
	putchr(')');
}

prt4x(w)
unsigned w;
{
	int i, j, k;

	k = 12;
	for (k=12; k >= 0; k -= 4) {
		j = w >> k;
		j &= 0xf;
		putchr("0123456789abcdef"[j]);
	}
}

numargs(retpc)
long retpc;
{
	int ins, n;
	long getn();

	ins = getn(retpc, 2);
	if ((ins & 0xf1ff) == 0x504f ||
	    (ins & 0xf1ff) == 0x508f) {	/* addq.[wl] #n,A7 */
		n = (ins>>9) & 7;
		if (n == 0)
			n = 8;
	} else if (ins == 0xdefc) {	/* adda.w #n,A7 */
		n = getn(retpc+2, 2);
	} else if (ins == 0xdffc) {	/* adda.l #n,A7 */
		n = getn(retpc+2, 4);
	} else
		n = 0;

	if (n < 0)
		n = 0;
	return n/2;
}

long
atbranch(loc)
long loc;
{
	int ins, i;

	ins = getn(loc, 2);
	if ((ins & 0xff00) == 0x6000) {
		i = ins & 0xff;
		if (i == 0)
			i = getn(loc+2, 2);
		return loc+2+i;
	}
	return 0;
}

atlink(loc)
long loc;
{
	int ins;

	ins = getn(loc, 2);
	return (ins == 0x4e56);	/* link a6,#N */
}

atrts(loc)
long loc;
{
	int ins;

	ins = getn(loc, 2);
	return (ins == 0x4e75);
}

prbasepg()
{
	int n, i;
	unsigned char c;
	struct basepg *bp;

	if (dotset)
		bp = (struct basepg *)dot;
	else
		bp = bpage;

/*	prtf("base page at %I", bp); */
	prtf(M2, bp);
/*	prt("low tpa ");	*/
	prt(M3);
	prtn(bp->p_lowtpa, 10);
/*	prt("  hi tpa  ");	*/
	prt(M4);
	prtn(bp->p_hitpa, 10);
/*	prt("\ntext at ");	*/
	prt(M5);
	prtn(bp->p_tbase, 10);
/*	prt("  size    ");	*/
	prt(M6);
	prtn(bp->p_tlen, 10);
/*	prt("\ndata at ");	*/
	prt(M7);
	prtn(bp->p_dbase, 10);
/*	prt("  size    ");	*/
	prt(M6);
	prtn(bp->p_dlen, 10);
/*	prt("\nbss at  ");	*/
	prt(M8);
	prtn(bp->p_bbase, 10);
/*	prt("  size    ");	*/
	prt(M6);
	prtn(bp->p_blen, 10);
/*	prt("\nenv ptr ");	*/
	prt(M9);
	prtn(bp->p_env, 10);
/*	prt("  parent  ");	*/
	prt(M10);
	prtn(bp->p_parent, 10);

	prtf("\nargs: ");
	n = bp->p_cmdlin[0];
	for (i=0; i<n; i++) {
		c = bp->p_cmdlin[1+i];
		if (c < ' ') {
			putchr('^');
			c += 'A';
		}
		putchr(c);
	}
	putchr('\n');
}

loadpcs()
{
	int **ip;
	char parms[80], *envp;
	extern struct basepg *gemdos();
	extern struct file binary;
	extern struct basepg *_base;
	extern unsigned long ossp;

	parms[0] = '\0';
	envp = _base->p_env;
	if ((bpage = gemdos(0x4b, 3, binary.name, parms, envp)) < 0) {
/*		prtf("can't load %s\n", binary.name);	*/
		prtf(M11, binary.name);
		return -1;
	}
	ip = (int **)(bpage->p_hitpa);
	*--ip = (int *)bpage;
	--ip;
	*(regs[SP].value) = (unsigned long)ip;
	*(regs[PC].value) = (unsigned long)bpage->p_tbase;
	*(regs[XSP].value) = ossp;
#ifdef OLD
	bpage->p_parent = _base;
#else
	bpage->p_parent = 0;
#endif
	return 0;
}

cmdcol(c, fmt, get)
int c;
char *fmt;
long (*get)();
{
	extern struct bpt *freebpt();
	struct bpt *bp;
	extern int lasttrap;
	extern char *tnm[];

	switch (c) {
	case 's':		/* single step a sub-process */
	case 'S':
	case 'c':		/* continue a sub-program */
	case 'C':
		if (dotset)
			*(regs[PC].value) = dot;
		else
			dot = *(regs[PC].value);
		getargs();
		if (c == 'c' || c == 'C') {
			if (findbpt(dot)) {
				ptrace(SSTEP, 0, 0, 0);
				dot = *(regs[PC].value);
			}
			if (findbpt(dot) == NULL) {
				setbpt(bpt, MAXBPTS);
				winswtch();
				ptrace(CONTINUE, 0, 0, 0);
				winswtch();
				clrbpt(bpt, MAXBPTS);
			}
		} else
			ptrace(SSTEP, 0, 0, 0);
		dot = *(regs[PC].value);

		switch (lasttrap) {
		case 2:
		case 3:
			prbuserr();
			break;
		case 4:		/* illegal instruction */
			if (bp = findbpt(dot)) {
				hitbpt(bp);
				break;
			}
			/* fall through */
		default:
			prtf("trap: %s\n", tnm[lasttrap]);
			break;
		case 9:		/* trace trap */
			break;
		case 10:	/* exit */
/*			prt("process exited\n");	*/
			prt(M12);
			seeerr();
			exit(0);
		}

		if (c == 'S' || c == 'C')
			prregs();
		prbpt(dot);
		return(0);
	case 'b':		/* set break point */
		if (bp = freebpt(dot)) {
			bp->flag |= BP_VALID;
			bp->addr = dot;
		} else
/*			prt("too many breakpoints\n");	*/
			prt(M15);
		break;
	case 'd':		/* clear break point */
		if (bp = findbpt(dot))
			bp->flag = 0;
		else
/*			prt("no breakpoint found\n");	*/
			prt(M16);
		break;
	default:
/*		prt("unknown command\n");	*/
		prt(M13);
		break;
	}
	return(0);
}

getargs()
{
	char c, *cp;
	int n;
	static int gotargs = 0;

	c = nb();
	if (c == '\n')
		return;

	if (gotargs)
		return;
	gotargs++;

	n = 1;
	cp = &bpage->p_cmdlin[1];
	*cp++ = c;
	while ((c = getchr()) != '\n') {
		*cp++ = c;
		n++;
		if (n >= 0x7e)
			break;
	}
	bpage->p_cmdlin[0] = n;
	*cp = 0;
	pushc('\n');
}

cleanup(fp)
struct file *fp;
{

	ptrace(KILL_PID, fp->pid, 0, 0);
	return;
}

prbpt(pc)
long pc;
{
	dot = pc;
	dotoff = 0;
	prtad(dot+dotoff);
	putchr(':');
	puti();
	putchr('\n');
	return;
}

setbpt(bp, n)
struct bpt *bp;
int n;
{

	while (n--) {
		if (bp->flag & BP_VALID) {
			bp->flag |= BP_ACTIVE;
			bp->instr = getn(bp->addr, 2);
			putn((long)BPT, bp->addr, 2);
		}
		bp++;
	}
	return;
}

clrbpt(bp, n)
struct bpt *bp;
int n;
{
	while (n--) {
		if (bp->flag & BP_ACTIVE) {
			bp->flag &= ~BP_ACTIVE;
			putn((long)bp->instr, bp->addr, 2);
		}
		bp++;
	}
	return;
}

struct bpt *
freebpt(dot)
long dot;
{
	extern struct bpt bpt[];
	struct bpt *bp, *lp;
	int n;

	bp = bpt;
	lp = 0;
	n = MAXBPTS;
	while (n--)
		if ((bp->flag & BP_VALID) == 0 && lp == 0)
			lp = bp;
		else if (bp->addr == dot)
			return(bp);
		else
			bp++;
	return(lp);
}

struct bpt *
findbpt(dot)
long dot;
{
	extern struct bpt bpt[];
	struct bpt *bp;
	int n;

	bp = bpt;
	n = MAXBPTS;
	while (n--)
		if ((bp->flag & BP_VALID) && bp->addr == dot)
			return(bp);
		else
			bp++;
	return NULL;
}

hitbpt(bp)
struct bpt *bp;
{
/*	prtf("break at %I\n", dot);	*/
	prtf(M14, dot);
}
