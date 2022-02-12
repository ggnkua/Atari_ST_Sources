#if (CHIP == M68000)
/*
 * The console driver for the Atari ST
 */
#define DEBDMP		/* dump system tables */
#undef	TTYDMP		/* dump tty info  */
#define DEBOUT		/* debugging on console and/or printer */

#include "kernel.h"
#include <signal.h>
#include <sgtty.h>

#include "proc.h"
#include "tty.h"

#ifdef DEBOUT
PRIVATE int	STuseCon = 0;
PRIVATE int	STusePrt = 0;
#endif
#ifdef DEBDMP
PRIVATE int	STdoDump = 0;
#endif

/*===========================================================================*
 *				tty_init				     *
 *===========================================================================*/
PUBLIC void tty_init()
{
  struct tty_struct *tp;

  for (tp = &tty_struct[0]; tp < &tty_struct[NR_CONS]; tp++) {
	tp->tty_inhead = tp->tty_inqueue;
	tp->tty_intail = tp->tty_inqueue;
	tp->tty_mode = CRMOD | XTABS | ECHO;

#if (CHIP != M68000)
	/* atari does this in vduinit() */
	tp->tty_devstart = console;
#endif
	tp->tty_makebreak = TWO_INTS;
#if (CHIP != M68000)
	tp->tty_attribute = BLANK;
#endif
	tp->tty_erase = ERASE_CHAR;
	tp->tty_kill  = KILL_CHAR;
	tp->tty_intr  = INTR_CHAR;
	tp->tty_quit  = QUIT_CHAR;
	tp->tty_xon   = XON_CHAR;
	tp->tty_xoff  = XOFF_CHAR;
	tp->tty_eof   = EOT_CHAR;
  }

  tty_buf_max(tty_driver_buf) = MAX_OVERRUN;	/* set up limit on keyboard buffering*/
  tty_buf_count(tty_driver_buf) = 0;

  vduinit();
  kbdinit();
#ifdef DEBOUT
  STuseCon = 1;		/* debugging putc() goes (also) to console */
#endif
}

/*===========================================================================*
 *				func_key				     *
 *===========================================================================*/
PUBLIC int func_key(pfx)
int pfx;
{
    int i;

/* handle CTRL-ALT-PFX sequences */
    
  switch (pfx) {
#ifdef DEBDMP
  case F1:	/* PF1: print process table */
	p_dmp(); return;
  case F2:	/* PF2: print memory map */
	map_dmp(); return;
  case F3:	/* PF3: print regs user prog */
	reg_dmp(bill_ptr); return; /* ++jrb */
  case F6:	/* PF6: ON/OFF dump tables on panic */
	STdoDump ^= 1; return;
#endif
#ifdef DEBOUT
  case F4:	/* PF4: ON/OFF console debugging */
	STuseCon ^= 1; return;
  case F5:	/* PF5: ON/OFF printer debugging */
	STusePrt ^= 1; return;
#endif
#ifdef DEBDMP
#ifdef TTYDMP
  case F7:	/* PF7: dump tty info */
	tty_dmp(); return;
#endif
#endif
  case F10:	/* PF10: issue SIGKILL */
	for (i = 0; i < NR_CONS; i++)
	{
	    sigchar(&tty_struct[i], SIGKILL); return;
	}
  default:
	return; /* don't bomb out */
  }
}

/*===========================================================================*
 *				dump					     *
 *===========================================================================*/
PUBLIC void dump()
{
#ifdef DEBDMP
  if (STdoDump == 0)
	return;
  printf("dump\n");
  reg_dmp(proc_ptr); /* ++jrb */
  p_dmp();
  map_dmp();
#endif
}

/*===========================================================================*
 *				putc					     *
 *===========================================================================*/
/* 
 * This procedure is used by the kernel version of printf().
 * The one in the library sends a message to FS, which is not
 * needed for printing within the kernel.
 */
PUBLIC void putc(c)
int c;
{
#ifdef DEBOUT
/*
 * Use any combination of the printer or the console.
 */

  if (STuseCon) {
#endif
	vducursor(0);
	out_char(&tty_struct[CONSOLE], c);
	vducursor(1);
#ifdef DEBOUT
  }
  if (STusePrt)
	prtc(c);
#endif
}
#endif
