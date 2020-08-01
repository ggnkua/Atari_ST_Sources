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
 *	trace.c
 */

#include <setjmp.h>
#include "adb.h"

#define IN_TRACE
#include "lang.h"

extern int trap2(), trap3(), trap4(), trap5(), trap6(), 
	trap7(), trap8(), trap9(), trapx();

int myvecs;
int running;
int lasttrap;

struct vlist {
	int	number;
	int	(*vector)();
	long	oldv;
} vlist[] = {
	{2,	trap2},
	{3,	trap3},
	{4,	trap4},
	{5,	trap5},
	{6,	trap6},
	{7,	trap7},
	{8,	trap8},
	{9,	trap9},
	{0x102,  trapx},
	{0,	0}
};

jmp_buf xqt_buf;
extern jmp_buf trp_buf;

long
ptrace(req, pid, addr, data)
int req, pid;
long *addr;
long data;
{
	extern struct regs regs[];
	extern int xqt();
	extern long gemdos();

	switch (req) {

	case RD_TEXT:
	case RD_DATA:
		if ((int)addr & (sizeof(data) - 1))
			return(-1);
		data = *addr;
		return(data);
	case WR_TEXT:
	case WR_DATA:
		if ((int)addr & (sizeof(data) - 1))
			return(-1);
		*addr = data;
		return(data);
	case SSTEP:
		*(regs[SR].value) = (*(regs[SR].value) & ~TBITS) | ITRACE;
		xqt();
		return(0);
	case CONTINUE:
		*(regs[SR].value) = *(regs[SR].value) & ~TBITS;
		xqt();
		return(0);
	case START_DBG:
		return(0);
	case RD_USER:
	case WR_USER:
		return(-1);

	}
	return(-1);
}

xqt()
{
	running = 1;
	if (setjmp(xqt_buf) == 0)
		go();
	running = 0;
	return;
}

int detail, be_instr;
long be_addr;

prbuserr()
{
	prtf("trap: %s\n", tnm[lasttrap]);
	prtf("%s %c ", fcnm[detail & 7],
		(detail & 0x10) ? 'r' : 'w');
	if (detail & 8)
/*		prt("(not instr) ");	*/
		prt(M1);
/*	prtf("addr %I instr %i\n",	*/
	prtf(M2,
		be_addr, be_instr);
}

trap(type, sr, pc)
unsigned int type, sr;
unsigned long pc;
{
	extern struct regs regs[];

	if (!running) {
/*		prt("internal trap: ");	*/
		prt(M3);
		prt(tnm[type]);
		putchr('\n');
		longjmp(trp_buf, 1);
	}
	*(regs[SR].value) = (unsigned long)sr;
	*(regs[PC].value) = pc;
	lasttrap = type;
	longjmp(xqt_buf, 1);
}

vects()
{
	long bios();
	struct vlist *vp;

	vp = vlist;
	while (vp->number) {
		vp->oldv = bios(5, vp->number, vp->vector);
		vp++;
	}
	myvecs = 1;
}

oldvects()
{
	struct vlist *vp;

	if (!myvecs)
		return;
	vp = vlist;
	while (vp->number) {
		bios(5, vp->number, vp->oldv);
		vp++;
	}
	myvecs = 0;
}
