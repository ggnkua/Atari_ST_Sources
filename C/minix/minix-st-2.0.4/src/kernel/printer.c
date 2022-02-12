/* This file contains the printer driver. It is a fairly simple driver,
 * supporting only one printer.  Characters that are written to the driver
 * are written to the printer without any changes at all.
 *
 * The valid messages and their parameters are:
 *
 *   HARD_INT:     interrupt handler has finished current chunk of output
 *   DEV_WRITE:    a process wants to write on a terminal
 *   CANCEL:       terminate a previous incomplete system call immediately
 *
 *    m_type      TTY_LINE   PROC_NR    COUNT    ADDRESS
 * -------------------------------------------------------
 * | HARD_INT    |         |         |         |         |
 * |-------------+---------+---------+---------+---------|
 * | DEV_WRITE   |minor dev| proc nr |  count  | buf ptr |
 * |-------------+---------+---------+---------+---------|
 * | CANCEL      |minor dev| proc nr |         |         |
 * -------------------------------------------------------
 * 
 * Note: since only 1 printer is supported, minor dev is not used at present.
 */

#include "kernel.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

#if ENABLE_PRINTER

/* Control bits (in port_base + 2).  "+" means positive logic and "-" means
 * negative logic.  Most of the signals are negative logic on the pins but
 * many are converted to positive logic in the ports.  Some manuals are
 * misleading because they only document the pin logic.
 *
 *	+0x01	Pin 1	-Strobe
 *	+0x02	Pin 14	-Auto Feed
 *	-0x04	Pin 16	-Initialize Printer
 *	+0x08	Pin 17	-Select Printer
 *	+0x10	IRQ7 Enable
 *
 * Auto Feed and Select Printer are always enabled. Strobe is enabled briefly
 * when characters are output.  Initialize Printer is enabled briefly when
 * the task is started.  IRQ7 is enabled when the first character is output
 * and left enabled until output is completed (or later after certain
 * abnormal completions).
 */
#define ASSERT_STROBE   0x1D	/* strobe a character to the interface */
#define NEGATE_STROBE   0x1C	/* enable interrupt on interface */
#define SELECT          0x0C	/* select printer bit */
#define INIT_PRINTER    0x08	/* init printer bits */

/* Status bits (in port_base + 2).
 *
 *	-0x08	Pin 15	-Error
 *	+0x10	Pin 13	+Select Status
 *	+0x20	Pin 12	+Out of Paper
 *	-0x40	Pin 10	-Acknowledge
 *	-0x80	Pin 11	+Busy
 */
#define BUSY_STATUS     0x10	/* printer gives this status when busy */
#define NO_PAPER        0x20	/* status bit saying that paper is out */
#define NORMAL_STATUS   0x90	/* printer gives this status when idle */
#define ON_LINE         0x10	/* status bit saying that printer is online */
#define STATUS_MASK	0xB0	/* mask to filter out status bits */ 

/* Centronics interface timing that must be met by software (in microsec).
 *
 * Strobe length:	0.5u to 100u (not sure about the upper limit).
 * Data set up:		0.5u before strobe.
 * Data hold:		        0.5u after strobe.
 * Init pulse length:	   over 200u (not sure).
 *
 * The strobe length is about 50u with the code here and function calls for
 * outb() - not much to spare.  The 0.5u minimums may be violated if
 * outb() is generated in-line on a fast machine.  Some printer boards
 * are slower than 0.5u anyway.
 */

PRIVATE int caller;		/* process to tell when printing done (FS) */
PRIVATE int done_status;	/* status of last output completion */
PRIVATE int oleft;		/* bytes of output left in obuf */
PRIVATE char obuf[128];		/* output buffer */
PRIVATE int opending;		/* nonzero while expected printing not done */
PRIVATE char *optr;		/* ptr to next char in obuf to print */
PRIVATE int orig_count;		/* original byte count */
PRIVATE int port_base;		/* I/O port for printer */
PRIVATE int proc_nr;		/* user requesting the printing */
PRIVATE int user_left;		/* bytes of output left in user buf */
PRIVATE vir_bytes user_vir;	/* address of remainder of user buf */
PRIVATE int writing;		/* nonzero while write is in progress */
PRIVATE irq_hook_t p_hook;	/* interrupt hook */

FORWARD _PROTOTYPE( void do_cancel, (message *m_ptr) );
FORWARD _PROTOTYPE( void do_done, (void) );
FORWARD _PROTOTYPE( void do_write, (message *m_ptr) );
FORWARD _PROTOTYPE( void pr_start, (void) );
FORWARD _PROTOTYPE( void print_init, (void) );
FORWARD _PROTOTYPE( void reply, (int code, int replyee, int process,
		int status) );
FORWARD _PROTOTYPE( int pr_handler, (irq_hook_t *hook) );

/*===========================================================================*
 *				printer_task				     *
 *===========================================================================*/
PUBLIC void printer_task()
{
/* Main routine of the printer task. */

  message pr_mess;		/* buffer for all incoming messages */

  while (TRUE) {
	receive(ANY, &pr_mess);
	switch(pr_mess.m_type) {
	    case DEV_OPEN:
		print_init();			/* initialize */
	    case DEV_CLOSE:
		reply(TASK_REPLY, pr_mess.m_source, pr_mess.PROC_NR, OK);
		break;
	    case DEV_WRITE:	do_write(&pr_mess);	break;
	    case CANCEL   :	do_cancel(&pr_mess);	break;
	    case HARD_INT :	do_done();		break;
	    default:
		reply(TASK_REPLY, pr_mess.m_source, pr_mess.PROC_NR, EINVAL);
	}
  }
}


/*===========================================================================*
 *				do_write				     *
 *===========================================================================*/
PRIVATE void do_write(m_ptr)
register message *m_ptr;	/* pointer to the newly arrived message */
{
/* The printer is used by sending DEV_WRITE messages to it. Process one. */

  register int r;

  /* Reject command if last write is not finished, count not positive, or
   * user address bad.
   */
  if (writing) {
  	r = EIO;
  } else
  if (m_ptr->COUNT <= 0) {
  	r = EINVAL;
  } else
  if (numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS, m_ptr->COUNT) == 0) {
	r = EFAULT;
  } else {
	/* Save information needed later. */
	caller = m_ptr->m_source;
	proc_nr = m_ptr->PROC_NR;
	user_left = m_ptr->COUNT;
	orig_count = m_ptr->COUNT;
	user_vir = (vir_bytes) m_ptr->ADDRESS;
	pr_start();
	writing = TRUE;
	r = SUSPEND;
  }

  /* Reply to FS, no matter what happened. */
  reply(TASK_REPLY, m_ptr->m_source, m_ptr->PROC_NR, r);
}


/*===========================================================================*
 *				do_done					     *
 *===========================================================================*/
PRIVATE void do_done()
{
/* Previous chunk of printing is finished.  Continue if OK and more.
 * Otherwise, reply to caller (FS).
 */

  register int status;

  if (!writing) return;		/* interrupt while canceling */
  if (done_status != OK) {
	/* Printer error. */
	status = EIO;
	if ((done_status & ON_LINE) == 0) {
		printf("Printer is not on line\n");
	} else
	if (done_status & NO_PAPER) {
		status = EAGAIN;	/* out of paper */
	} else {
		printf("Printer error, status is 0x%02X\n", done_status);
	}
	if (status == EAGAIN && user_left < orig_count) {
		/* Some characters have been printed, tell how many. */
		status = orig_count - user_left;
	}
	oleft = 0;		/* cancel output by interrupt handler */
  } else if (user_left != 0) {
	pr_start();
	return;
  } else {
	status = orig_count;
  }
  reply(REVIVE, caller, proc_nr, status);
  writing = FALSE;
}


/*===========================================================================*
 *				do_cancel				     *
 *===========================================================================*/
PRIVATE void do_cancel(m_ptr)
register message *m_ptr;	/* pointer to the newly arrived message */
{
/* Cancel a print request that has already started.  Usually this means that
 * the process doing the printing has been killed by a signal.  It is not
 * clear if there are race conditions.  Try not to cancel the wrong process,
 * but rely on FS to handle the EINTR reply and de-suspension properly.
 */

  if (writing && m_ptr->PROC_NR == proc_nr) {
	oleft = 0;		/* cancel output by interrupt handler */
	writing = FALSE;
  }
  reply(TASK_REPLY, m_ptr->m_source, m_ptr->PROC_NR, EINTR);
}


/*===========================================================================*
 *				reply					     *
 *===========================================================================*/
PRIVATE void reply(code, replyee, process, status)
int code;			/* TASK_REPLY or REVIVE */
int replyee;			/* destination for message (normally FS) */
int process;			/* which user requested the printing */
int status;			/* number of  chars printed or error code */
{
/* Send a reply telling FS that printing has started or stopped. */

  message pr_mess;

  pr_mess.m_type = code;	/* TASK_REPLY or REVIVE */
  pr_mess.REP_STATUS = status;	/* count or EIO */
  pr_mess.REP_PROC_NR = process;	/* which user does this pertain to */
  send(replyee, &pr_mess);	/* send the message */
}


/*===========================================================================*
 *				print_init				     *
 *===========================================================================*/
PRIVATE void print_init()
{
/* Set global variables.  Get the port base for the first printer from the
 * BIOS and initialize the printer.
 */
  static int inited;

  if (inited) return;
  inited = 1;

  phys_copy(0x408L, vir2phys(&port_base), 2L);
  outb(port_base + 2, INIT_PRINTER);
  milli_delay(2);		/* easily satisfies Centronics minimum */
  outb(port_base + 2, SELECT);
  put_irq_handler(&p_hook, PRINTER_IRQ, pr_handler);
  enable_irq(&p_hook);		/* ready for printer interrupts */
}


/*==========================================================================*
 *				pr_start				    *
 *==========================================================================*/
PRIVATE void pr_start()
{
/* Start next chunk of printer output. */

  register int chunk;
  phys_bytes user_phys;

  if ( (chunk = user_left) > sizeof obuf) chunk = sizeof obuf;
  user_phys = proc_vir2phys(proc_addr(proc_nr), user_vir);
  phys_copy(user_phys, vir2phys(obuf), (phys_bytes) chunk);
  optr = obuf;
  opending = TRUE;
  oleft = chunk;		/* now interrupt handler is enabled */
}


/*===========================================================================*
 *				pr_handler				     *
 *===========================================================================*/
PRIVATE int pr_handler(hook)
irq_hook_t *hook;
{
/* This is the interrupt handler.  When a character has been printed, an
 * interrupt occurs, and the assembly code routine trapped to calls
 * pr_handler().
 *
 * One problem is that the 8259A controller generates spurious interrupts to
 * IRQ7 when it gets confused by mistimed interrupts on any line.  (IRQ7 for
 * the first controller happens to be the printer IRQ.)  Such an interrupt is
 * ignored as a side-affect of the method of checking the busy status.  This
 * is harmless for the printer task but probably fatal to the task that missed
 * the interrupt.  It may be possible to recover by doing more work here.
 */

  register int status;

  if (oleft == 0) {
	/* Nothing more to print.  Turn off printer interrupts in case they
	 * are level-sensitive as on the PS/2.  This should be safe even
	 * when the printer is busy with a previous character, because the
	 * interrupt status does not affect the printer.
	 */
	outb(port_base + 2, SELECT);
	return 1;
  }

  do {
	/* Loop to handle fast (buffered) printers.  It is important that
	 * processor interrupts are not disabled here, just printer interrupts.
	 */
	status = inb(port_base + 1);
	if ((status & STATUS_MASK) == BUSY_STATUS) {
		/* Still busy with last output.  This normally happens
		 * immediately after doing output to an unbuffered or slow
		 * printer.  It may happen after a call from pr_start or
		 * pr_restart, since they are not synchronized with printer
		 * interrupts.  It may happen after a spurious interrupt.
		 */
		return 1;
	}
	if ((status & STATUS_MASK) == NORMAL_STATUS) {
		/* Everything is all right.  Output another character. */
		outb(port_base, *optr++);	/* output character */
		lock();		/* ensure strobe is not too long */
		outb(port_base + 2, ASSERT_STROBE);
		outb(port_base + 2, NEGATE_STROBE);
		unlock();
		opending = FALSE;	/* show interrupt is working */

		user_vir++;
		user_left--;
	} else {
		/* Error.  This would be better ignored (treat as busy). */
		done_status = status;
		interrupt(PRINTER);
		return 1;
	}
  }
  while (--oleft != 0);

  /* Finished printing chunk OK. */
  done_status = OK;
  interrupt(PRINTER);
  return 1;	/* Reenable printer interrupt */
}


/*==========================================================================*
 *				pr_restart				    *
 *==========================================================================*/
PUBLIC void pr_restart()
{
/* Check if printer is hung up, and if so, restart it.
 * Disable_irq() returns true if the irq could be disabled, so that
 * pr_restart() is not reentered.
 */

  if (oleft != 0) {
	if (opending && disable_irq(&p_hook)) {
		(void) pr_handler(&p_hook);

		/* ready for printer interrupts again */
		enable_irq(&p_hook);
	}
	opending = TRUE;	/* expect some printing before next call */
  }
}
#endif /* ENABLE_PRINTER */
