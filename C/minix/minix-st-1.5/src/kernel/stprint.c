#if (CHIP == M68000)
/* This file contains the printer driver for the Atari ST.
 * It is a fairly simple driver, supporting only one printer.
 * Characters that are written to the driver
 * are written to the printer without any changes at all.
 *
 * The valid messages and their parameters are:
 *
 *   HARD_INT:     output completed
 *   TTY_WRITE:    a process wants to write on a terminal
 *   CANCEL:       terminate a previous incomplete system call immediately
 *
 *    m_type      TTY_LINE   PROC_NR    COUNT    ADDRESS
 * -------------------------------------------------------
 * | HARD_INT    |minor dev|         |         |         |
 * |-------------+---------+---------+---------+---------|
 * | TTY_WRITE   |minor dev| proc nr |  count  | buf ptr |
 * |-------------+---------+---------+---------+---------|
 * | CANCEL      |minor dev| proc nr |         |         |
 * -------------------------------------------------------
 * 
 * Note: since only 1 printer is supported, minor dev is not used at present.
 */

#define	DEBOUT		/* debugging on console and/or printer */

#include "kernel.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

#include "staddr.h"
#include "stsound.h"
#include "stmfp.h"

static void do_write();
static void do_done();
static void do_cancel();
static void reply();
static void outc();
void piaint();

#define CANCELED        -999	/* indicates that command has been killed */

PRIVATE int caller;		/* process to tell when done (FS) */
PRIVATE int procno;		/* user requesting the printing */
PRIVATE int orig;		/* original byte count */
PRIVATE int left;		/* number of bytes left to print */
PRIVATE char *addr;		/* print, i.e., in the user's buffer */
PRIVATE int busy;		/* TRUE when printing, else FALSE */

/*===========================================================================*
 *				printer_task				     *
 *===========================================================================*/
PUBLIC void printer_task()
{
  message m;		/* buffer for all incoming messages */

  while (TRUE) {
	receive(ANY, &m);
	switch(m.m_type) {
	    case TTY_WRITE:	do_write(&m);	break;
	    case CANCEL   :	do_cancel(&m);	break;
	    case HARD_INT :	do_done(&m);	break;
    	    default:				break;
	}
  }
}


/*===========================================================================*
 *				do_write				     *
 *===========================================================================*/
PRIVATE void do_write(mp)
register message *mp;
{
  register r;
  register struct proc *rp;

  r = OK;			/* so far, no errors */

  /* Reject command if printer is busy or count is not positive. */
  if (busy)
	r = EAGAIN;
  caller = mp->m_source;
  procno = mp->PROC_NR;
  orig = mp->COUNT;
  left = mp->COUNT;
  if (left <= 0)
	r = EINVAL;

  /* Compute the physical address of the data buffer within user space. */
  rp = proc_addr(procno);
  addr = (char *)umap(rp, D, (vir_bytes) mp->ADDRESS, (vir_bytes) orig);
  if (addr == 0)
	r = E_BAD_ADDR;

  if (MFP->mf_gpip & IO_PBSY) {
	printf("Printer is not available\n");
	r = EIO;
  }

  if (r == OK) {
	busy = TRUE;
	piaint();	/* print first character */
	r = SUSPEND;	/* tell FS to suspend user until done */
  }

  /* Reply to FS, no matter what happened. */
  reply(TASK_REPLY, caller, procno, r);
}


/*===========================================================================*
 *				do_done					     *
 *===========================================================================*/
PRIVATE void do_done(mp)
message *mp;
{
/* Printing is finished.  Reply to caller (FS). */

  register status;

  busy = FALSE;
  if (procno == CANCELED)
	return;
#if 0
  status = (mp->REP_STATUS == OK ? orig : EIO);
#endif
  status = orig;
  reply(REVIVE, caller, procno, status);
  if (status == EIO)
	printf("Printer error\n");
}


/*===========================================================================*
 *				do_cancel				     *
 *===========================================================================*/
PRIVATE void do_cancel(mp)
message *mp;			/* pointer to the newly arrived message */
{
/* Cancel a print request that has already started.  Usually this means
 * that the process doing the printing has been killed by a signal.
 */

  if (busy == FALSE)
	return;			/* this test avoids race conditions */
  busy = FALSE;			/* mark printer as idle */
  left = 0;			/* causes printing to stop at next interrupt*/
  reply(TASK_REPLY, mp->m_source, mp->PROC_NR, EINTR);
  procno = CANCELED;		/* marks process as canceled */
}


/*===========================================================================*
 *				reply					     *
 *===========================================================================*/
PRIVATE void reply(code, replyee, process, status)
int code;			/* TASK_REPLY or REVIVE */
int replyee;			/* destination for message (normally FS) */
int process;			/* which user requested the printing */
int status;			/* number of chars printed or error code */
{
  message m;
  register struct proc *rp;

  rp = proc_addr(procno);
  rp->p_physio = busy;
  m.m_type = code;		/* TASK_REPLY or REVIVE */
  m.REP_STATUS = status;	/* count or EIO */
  m.REP_PROC_NR = process;	/* which user does this pertain to */
  send(replyee, &m);		/* send the message */
}


/*===========================================================================*
 *				piaint				     *
 *===========================================================================*/
PUBLIC void piaint()
{
/* This is the Parallel Interface Adapter interrupt handler.
 * When a character has been printed, an
 * interrupt occurs, and the assembly code calls piaint().
 */
  if (busy == FALSE) {
/*	printf("printer: spurious interrupt\n"); */
	return;
  }
  if (MFP->mf_gpip & IO_PBSY) {
	printf("printer: still busy\n");
	return;
  }

  while (left > 0) {
	outc(*addr++); left--;
	if (MFP->mf_gpip & IO_PBSY)
		return;
  }
  interrupt(PRINTER);
}


PRIVATE void outc(c)
int c;
{
  register char b;
  register int s;

  s = lock();

  SOUND->sd_selr = YM_MFR;
  b = SOUND->sd_rdat;
  b |= PB_OUT;
  SOUND->sd_wdat = b;

  SOUND->sd_selr = YM_IOB;
  SOUND->sd_wdat = c;

  SOUND->sd_selr = YM_IOA;
  b = SOUND->sd_rdat;
  b &= ~PA_PSTROBE;
  SOUND->sd_wdat = b;
  b |= PA_PSTROBE;
  SOUND->sd_wdat = b;

  restore(s);
}

#ifdef DEBOUT
PUBLIC void prtc(c)
int c;
{
  register long l;
  static offline = 1;

  if (c == '\n')
	prtc('\r');
  if ((MFP->mf_gpip & IO_PBSY) == 0)
	offline = 0;
  if (offline)
	return;
  for (l = 1000000; MFP->mf_gpip & IO_PBSY; )
	if (--l == 0) {
		offline = 1;
		return;
	}
  outc(c);
}
#endif
#endif
