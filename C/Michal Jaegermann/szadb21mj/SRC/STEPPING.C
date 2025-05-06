/* Copyright (c) 1990 by Sozobon, Limited.  Authors: Anthony Howe,
 *						     Michal Jaegermann
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 * Source code in this file consist of additons and modifications
 * to an original szadb code by Johann Ruegg and Don Dugger and is
 * an integral part of expanded version of szadb debugger.
 *
 *	stepping.c		68000 Trace & Break Point Functions
 *		23 Mar 90	ACH
 * 		 1 Apr 90       MJ
 *				added temporary breakpoints
 *			        separated next and jump accross branch
 *		 	        added new instructions to skip
 *			        added counts on breakpoints
 *			        changed way in which return address is found
 *			        set hooks for executing instructions on
 *			        breakpoints
 *              13 Nov 90       MJ
 *                              modified code which searches for a function
 *                              return address in order to marry an original
 *                              method from prstack and ACH heuristic approach
 */


#include <stddef.h>
#include <setjmp.h>
#include "adb.h"
#define IN_STEPPING
#include "lang.h"

extern long     bcount;
extern int      lastc;
extern int      lb_cur, lb_fill;
extern jmp_buf  cont_buf;

#define BPT		0x4afc	/* illegal op */
#define BP_VALID	1
#define BP_ACTIVE	2

/*** not used
#define JSR		0047200
#define JMP		0047300
  ** #define EA_MASK		0177700	 ***//* mask out effective  address */

typedef struct {
    short          *addr;
    short           instr;
    union {
	char           *tmp_cmd[3];
	struct {
	    long            count;
	    long            o_cnt;
	    char           *cmdline;
	}               user;
    }               request;
    int             flag;
}               break_point;

/*  various storage for stepping commands */

static char     bpstat[3] = {SILENT, SILENT, ON};
static char     stp_req[3][LINESZ + 2];
static char     findcmds[] = "=\"returns \";<d0=Xrr;<d0=p\n";
int             print_regs;

/*
 * The first position on the following list is used only for temporary
 * breakpoints and is not available to a user.
 */
/*
 * Initialize explicitely T_BPT - other are set to 0 by default.
 * This union initialization is NOT portable, but Sozobon C accepts it.
 */
static break_point bpt_list[MAXBPTS + 1] = {
	       {(short *) 0, (short) 0, stp_req[0], stp_req[1], findcmds, 0}
};
#define T_BPT		bpt_list[0]

extern char   **bpt_cmds;


static break_point *
free_bpt (addr)
    short          *addr;
/*
 * Find a free slot on a list of user breakpoints
 */
{
    break_point    *bp = &bpt_list[1];
    break_point    *last = &bpt_list[MAXBPTS + 1];

    for (; bp < last; bp++)
	if ((bp->flag & BP_VALID) == 0 || bp->addr == addr)
	    return (bp);

    return (NULL);
}				/* free_bpt */


static break_point *
find_bpt (addr)
    short          *addr;
/*
 * Find if a user breakpoint is set at a given address
 */
{
    break_point    *bp = &bpt_list[1];
    break_point    *last = &bpt_list[MAXBPTS + 1];

    for (; bp < last; bp++)
	if (bp->flag & BP_VALID && bp->addr == addr)
	    return (bp);

    return (NULL);
}				/* find_bpt */

static char    *
find_bcmd (bp, kind)
    break_point    *bp;
    int             kind;
/*
 * Return an address of a buffer with commands which should be
 * executed for a given breakpoint or NULL
 */
{
    char           *cmds;
    int             stat;

    if (CM_CONT == kind) {
	if (NULL != (cmds = bp->request.user.cmdline)) {
	    if (ON != *cmds++)
		cmds = NULL;
	}
    }
    else {			/* temporary breakpoint set by a stepping
				 * command */
	cmds = NULL;
	if (SILENT != (stat = bpstat[--kind])) {
	    for (;;) {
		if (ON == stat || (0 == kind && SILENT != stat)) {
		    cmds = T_BPT.request.tmp_cmd[kind];
		    break;
		}
		if (0 == kind)
		    break;
		stat = bpstat[--kind];
	    }
	}
    }
    return (cmds);
}

static void
exec_break (bp, kind)
    break_point    *bp;
    int             kind;
/*
 * Execute commands associated with a given breakpoint
 */
{
    extern registers regs[];
    extern long     dot;

    if (CM_CONT == kind) {
	if (NULL != bp) {
	    if (bp->request.user.count) {
		--(bp->request.user.count);
		longjmp (cont_buf, 1);
	    }
	    else {
		bp->request.user.count = bp->request.user.o_cnt;
		dot = (long) bp->addr;
		src_line (find_bcmd (bp, kind));
		prtf (BREAK_AT, bp->addr);
	    }
	}
    }
    else {			/* CM_STEP, CM_NEXT, CM_FINISH */
	dot = *regs[PC].value;
	src_line (find_bcmd ((break_point *) NULL, kind));
    }

    if (print_regs)
	prregs ();
    prbpt (dot = *regs[PC].value);
    putchr ('\n');
    return;
}

static void
check_break (kind)
    int             kind;
/*
 * Kind indicates which stepping command caused break.
 * Not used for traps of other kind.
 */
{
    extern int      lasttrap;
    extern registers regs[];
    extern char    *tnm[];
    void            exec_break ();

    switch (lasttrap) {
    case 2:
    case 3:			/* bus & address errors */
	prbuserr ();
	break;
    case 9:
	exec_break (&T_BPT, kind);
	break;			/* trace */
    case 10:
	prt (PROCESS_EXIT);
	seeerr ();
	exit (0);
    case 4:			/* illegal instruction -- breakpoint */

	/*
	 * Give priority to temporary breakpoints set by stepping commands.
	 * One may reprocess if first condition fires but we are going to
	 * miss breakpoint anyway if walked through by :n(ext) which reverted
	 * to :s(tep), so let be consistent.
	 */
	if ((T_BPT.flag & BP_VALID) &&
	    (T_BPT.addr == (short *) (*regs[PC].value))) {
	    exec_break (&T_BPT, kind);
	}
	else {
	    exec_break (find_bpt ((short *) (*regs[PC].value)), kind);
	}			/* if */
	break;
    default:
	prtf ("trap: %s\n", tnm[lasttrap]);
    }				/* switch */
}				/* check_break */


static void
bpts_on ()
/*
 *	Turn on all the break points, user and temporary,
 *	before full speed execution. First go through user
 *      breakpoints.  If T_BPT is on the same location as
 *      a user breakpoint, then the second breakpoint turned
 *      on will get BPT (invalid) instruction stored in it.
 *      Turn off in a reverse order!
 */
{
    int             i = MAXBPTS;
    break_point    *bp = &bpt_list[1];
    extern long     getn ();


    for (;;) {
	if (bp->flag & BP_VALID) {
	    bp->flag |= BP_ACTIVE;
	    bp->instr = (short) getn (bp->addr, 2);
	    putn ((long) BPT, bp->addr, 2);
	}			/* if */
	if (bp == &T_BPT)
	    break;
	if (--i)
	    bp++;
	else
	    bp = &T_BPT;
    }				/* for */
}				/* bpts_on */


static void
bpts_off ()
/*
 *	Turn off all the break points after full speed execution.
 *	This restores the instructions so that they can be viewed normally.
 *      Temporary breakpoint has to be turned off before user breakpoints.
 *      Ordering is critical - otherwise you may got BPT (invalid)
 *      instructions sprinkled over your code
 */
{
    break_point    *bp = &bpt_list[0];
    break_point    *last = &bpt_list[MAXBPTS + 1];

    do {
	if (bp->flag & BP_ACTIVE) {
	    bp->flag &= ~BP_ACTIVE;
	    putn ((long) bp->instr, bp->addr, 2);
	}			/* if */
	bp++;
    } while (bp < last);
}				/* bpts_off */


int
MakeReq (kind)
    short           kind;
/*
 * Handle request line for stepping commands.
 * Return 0 if there was no requests on a command line and non-zero otherwise.
 */
{
    int             idx = kind - 1;
    int             status;
    extern int      getrequs ();

    if (BLANK == (status = getrequs (stp_req[idx]))) {
	return 0;
    }

    if (REVERT == status) {
	if (CM_FINISH != kind) {
	    status = ON;
	}
	else {
	    T_BPT.request.tmp_cmd[idx] = findcmds;
	    bpstat[idx] = ON;
	    status = IGNORE;
	}
    }
    if (DOWN == status && 0 == idx)	/* no way down */
	status = ON;

    if (ON == status || NEW == status) {
	if (stp_req[idx][0] > ' ') {	/* if there is something here */
	    bpstat[idx] = ON;
	    if (CM_FINISH == kind) {
		T_BPT.request.tmp_cmd[idx] = stp_req[idx];
	    }
	}
    }
    else if (IGNORE != status) {
	bpstat[idx] = status;
    }

    return 1;
}				/* MakeReq */

void
PrBptList ()
/*
 *   Print list of user breakpoints
 */
{
    break_point    *bp = &bpt_list[1];
    break_point    *last = &bpt_list[MAXBPTS + 1];
    char           *cmdline;

    for (; bp < last; bp++) {
	if (bp->flag & BP_VALID) {
	    prbpt (bp->addr);
	    if (bp->request.user.o_cnt) {	/* print count only if > 1 */
		align (46);
		prtn (bp->request.user.o_cnt + 1L, 6);
	    }
	    putchr ('\n');
	    if (NULL != (cmdline = bp->request.user.cmdline)) {
		if (ON == *cmdline++)
		    prtf ("  %s", cmdline);
	    }
	}
    }
    putchr ('\n');
    if (NULL != (cmdline = find_bcmd ((break_point *) NULL, CM_FINISH)))
	prtf (":f %s", cmdline);
    if (NULL != (cmdline = find_bcmd ((break_point *) NULL, CM_NEXT)))
	prtf (":n %s", cmdline);
    if (NULL != (cmdline = find_bcmd ((break_point *) NULL, CM_STEP)))
	prtf (":s %s", cmdline);
    return;
}				/* PrBptList */


bool
SetBpt (addr)
    short          *addr;
{
    break_point    *bp;
    char            c;
    char           *cmds;
    int             status;
    extern int      getrequs ();

    if (bp = free_bpt (addr)) {
	bp->addr = addr;
	bp->request.user.count = bp->request.user.o_cnt = (bcount - 1L);
	bp->flag |= BP_VALID;
	if (NULL != bpt_cmds) {
	    cmds = bpt_cmds[(bp - bpt_list) - 1];
	    status = getrequs (&cmds[1]);
	    if (NEW == status) {
		bp->request.user.cmdline = cmds;
		*cmds = ON;
	    }
	    else if (0 != (cmds = bp->request.user.cmdline)) {
		if (SILENT == status || BLANK == status)
		    *cmds = SILENT;
		else if (IGNORE != status)
		    *cmds = ON;
	    }
	}
	status = TRUE;
    }
    else {
	prt (TOO_MANY_BPT);
	status = FALSE;
    }				/* if */

    return (status);
}				/* SetBpt */


bool
ClrBpt (addr)
    short          *addr;
{
    break_point    *bp;
    if (bp = find_bpt (addr)) {
	bp->flag = 0;
	bp->request.user.cmdline = NULL;
	return (TRUE);
    }
    else {
	/* no breakpoint found to remove */
	prt (NO_BPT);
	return (FALSE);
    }				/* if */
}				/* ClrBpt */


void
SingleStep (addr, kind)
    short          *addr;
    int             kind;
{
    extern registers regs[];
    *regs[PC].value = (long) addr;
    ptrace (SSTEP, 0, 0, 0);
    check_break (kind);
}				/* SingleStep */


void
FullStep (addr, target, kind)
    short          *addr;
    short          *target;
    int             kind;
/*
 * Execute full speed until breakpoint hit. Kind indicates a command
 * which caused an execution of FullStep.
 * For kind == CM_CONT breakpoints are taken from a table of user
 * breakpoints, so target does not matter.  For other kinds a temporary
 * breakpoint is set and later removed at a location target.  It is
 * a responsibility of a caller to pass some reasonable argument.
 */
{
    extern registers regs[];

    if (CM_CONT != kind) {	/* set a temporary breakpoint */
	T_BPT.addr = target;
	T_BPT.flag |= BP_VALID;
    }

    *regs[PC].value = (long) addr;
    /* Make sure we're not sitting on a break point */
    if (find_bpt (addr)) {
	ptrace (SSTEP, 0, 0, 0);
	addr = (short *) *regs[PC].value;
    }				/* if */
    if (find_bpt (addr) == NULL) {
	bpts_on ();
	winswtch ();
	ptrace (CONTINUE, 0, 0, 0);
	winswtch ();
	bpts_off ();
    }				/* if */
    check_break (target == (short *) *regs[PC].value ? kind : CM_CONT);
    if (CM_CONT != kind) {	/* remove temporary breakpoint */
	T_BPT.flag = 0;
    }
}				/* FullStep */

next_step       next_list[] = {
			       {0060400, 0177777, 2},	/* bsr.l */
			       {0060400, 0177400, 1},	/* bsr.s */
			       {0047100, 0177760, 1},	/* trap #x */
			       {0041766, 0177777, 1},	/* trapv */
			       {0047271, 0177777, 3},	/* jsr abs.l */
			       {0047220, 0177770, 1},	/* jsr (a) */
			       {0047240, 0177740, 2},	/* jsr d(a) d(a,x) abs.w
							 * d(pc) d(pc,x) */
			       {0, 0, 0}
};				/* next_list */

next_step       jump_list[] = {
			       {0060000, 0170377, 2},	/* bcc, bra long */
			       {0060000, 0170000, 1},	/* bcc, bra short */
			       {0050310, 0170370, 2},	/* dbcc */
			       {0047371, 0177777, 3},	/* jmp abs.l */
			       {0047320, 0177770, 1},	/* jmp (a) */
			       {0047340, 0177740, 2},	/* jmp d(a) d(a,x) abs.w
							 * d(pc) d(pc,x) */
			       {0, 0, 0}
};				/* jump_list */

void
NextStep (addr, skip_list)
    short          *addr;
    next_step       skip_list[];
/*
 * If skip_list == next_list step to next instruction on the same call level.
 * If skip_list == jump_list execute until pc reaches the next instruction
 * in a text of a program.
 * If skip_list none of the above all bets are off!!!
 * After 'jump' adb() automatically restores default request to 'next'.
 */
{
    next_step      *ns;
    short           op_word = *addr;
    extern          putx (), prt ();

    for (;;) {
	for (ns = &skip_list[0]; 0 != ns->code; ns++) {
	    if ((op_word & ns->mask) == ns->code) {
		/* Set temporary breakpoint at addr + ns->len. */
		FullStep (addr, addr + ns->len, CM_NEXT);
		return;
	    }			/* if */
	}			/* for ns */
	if (skip_list == next_list) {
	    SingleStep (addr, CM_NEXT);
	    return;
	}
	skip_list = next_list;
    }				/* for (;;) */
}				/* NextStep */


void
FuncStep (addr)
/*
 *  Execute until we are out of the current function
 */
    short          *addr;
{
    short          *target;
    short          *Unwind();
    extern registers regs[];
    int             at_sp = 1; /* this needed really by prstack() */

    if (target = Unwind (&at_sp, addr, *(regs[SP].value), *(regs[FP].value))) {
	FullStep (addr, target, CM_FINISH);
    }
    else {
	/* no return address found */
	prtf (NO_RETURN);
    }
    return;
}				/* FuncStep */

short *
Unwind (where, addr, sp, fp)
    int            *where;
    short          *addr;
    long            sp;
    long            fp;
/*
 * Search for a spot to return from a function which contains 'addr'.
 * If a value at 'where' is 0 look only at frame pointer, otherwise
 * try to get value examining stack pointer. In any case value at
 * where will be reset if we had to look at frame pointer.
 * Check if computed address falls into the text segment.  If yes
 * it is returned, otherwise the following heuristic is used: 
 * We assume that (1) all function calls lie between tbase and tbase + tlen
 *                (2) sp points somewhere below hitpa
 *                (3) sp grows down toward the text segment.
 * We search from 'addr', by a word step, until hitpa. We try to find
 * the first entry which looks like an address which lies within the
 * text segment.  We decree that to be the return address of the current
 * function.  If everything fails then we return NULL.
 *
 * Part of a code for finding a return address stolen from an original
 * prstack(). Nasty type puns also inherited from there.
 */
{
    extern base_page *bpage;
    extern long     getn (), atbranch ();
    extern int      atrts (), atlink ();
    short          *target;
    short          *tbase = (short *) bpage->p_tbase;
    short          *tend  = tbase +  bpage->p_tlen;
    short          *hitpa, *stp;
    long            brpc;

    if (*where && (atlink (addr) || atrts (addr) ||
	((brpc = atbranch (addr)) && atlink (brpc)))) {
	target = (short *) getn (sp, 4);
    }
    else {
	*where = 0;
	target = (short *) getn (fp + 4, 4);
    }

    if (tbase <= target && target < tend)
	return (target);
    /* target doesn't look good - try harder */
    hitpa = (short *) bpage->p_hitpa;
    for (stp = (short *) sp; stp < hitpa; stp++) {
    	target = * (short **) stp;
	if (tbase <= target && target < tend)
	    return (target);
    }
    /* no return address in sight */
    return (NULL);
}				/* Unwind */
