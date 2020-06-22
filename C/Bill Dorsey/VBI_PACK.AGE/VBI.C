/* vbi.c -- vertical blank interrupt handler [Version 1.0  01/01/87]
 *
 * Copyright (C) 1987 by Amgem, Inc.
 *
 * Permission is hereby granted for anyone to make or distribute copies of
 * this program provided the copyright notice and this permission notice are
 * retained.
 *
 * This software, or software containing all or part of it, may not be sold
 * except with express permission of the authors.
 *
 * Authors:  Bill Dorsey & John Iarocci
 *
 * If you have any questions or comments, the authors may be reached at
 * The Tanj BBS, (301)-251-0675.  Updates and bug fixes may also be obtained
 * through the above service.
 *
 * The code which follows was compiled using the Mark Williams C compiler,
 * but should be portable with little work to other C compilers.  See the
 * associated documentation for notes on how to convert it for use with other
 * C compilers
 */

#include <osbind.h>
#include <basepage.h>
#include "vbi.h"

int count;		/* count remaining until next scheduling */
int curpid;		/* current process id */
PROC proctab[NPROC];	/* process table */

init()				/* initialization */
{
  int i;
  long ssp;
  int schedule();

  count=QUANTUM;		/* # of vblanks per scheduling */
  for (i=0; i<NPROC; i++)
    proctab[i].state=FREE;	/* initialize process table */
  ssp=Super(0L);		/* enter supervisor state */
  for (i=0; i<8; i++) {
    if ((*VBLQUEUE)[i] == (int (*)()) 0) {
      (*VBLQUEUE)[i]=schedule;	/* install scheduler in vblank queue */
      Super(ssp);
      return OK;		/* installation successful */
    }
  }
  Super(ssp);
  return SYSERR;		/* installation failed */
}

vbiexit()			/* exit code (leave VBI handler) */
{
  long prglen;

  prglen=0x100L+BP->p_tlen+BP->p_dlen+BP->p_blen;
  Ptermres(prglen,0);		/* terminate and stay resident */
}

remove()			/* removes VBI handler */
{
  int i;
  long ssp;
  int schedule();

  ssp=Super(0L);		/* enter supervisor mode */
  for (i=0; i<8; i++)
    if ((*VBLQUEUE)[i] == schedule) {
      (*VBLQUEUE)[i]=(int (*)()) 0;	/* remove scheduler from vblqueue */
      Super(ssp);		/* resume user mode */
      return OK;		/* return success */
    }
  Super(ssp);			/* resume user mode */
  return SYSERR;		/* return failure */
}

schedule()			/* process scheduler */
{
  register int i;
  register PROC *pptr;

  DISABLE;			/* disable further vb interrupts */
  if (--count == 0) {		/* schedule when count reaches zero */
    count=QUANTUM;		/* re-initialize count */
    pptr=proctab;		/* get pointer to process table */
    for (i=0; i<NPROC; i++,pptr++)
      switch (pptr->state) {
      case READY:		/* if process ready, set curpid to its */
        curpid=i;		/* process id, and then execute it */
        (*pptr->func)();
        break;
      case SLEEP:		/* if process sleeping, decrement its */
        if (--pptr->count == 0) /* count.  If count reaches zero, set */
          pptr->state=READY;	/* process state back to READY */
        break;
      }
  }
  ENABLE;			/* enable vb interrupts */
}

create(func)			/* process creation */
  int (*func)();
{
  register int i;
  register PROC *pptr;

  pptr=proctab;			/* initialize pointer to process table */
  for (i=0; i<NPROC; i++,pptr++)
    if (pptr->state == FREE) {	/* find free entry in process table */
      pptr->func=func;		/* store pointer to code in table */
      pptr->state=READY;	/* set process state to READY */
      return i;			/* return process id */
    }
  return SYSERR;		/* process table full --> failure */
}

delete(pid)			/* process deletion */
  int pid;
{
  if (proctab[pid].state == FREE)
    return SYSERR;		/* if process already free, return failure */
  proctab[pid].state=FREE;	/* set process state to FREE */
  return OK;			/* return success */
}

sleep(tsec)			/* process sleep */
  int tsec;
{
  proctab[curpid].state=SLEEP;	/* set process state to SLEEP */
  proctab[curpid].count=tsec*INTERVAL;	/* set count to proper amount */
}
