/*
 * The console driver for the Atari ST
 */
#define DEBDMP			/* dump system tables */
#define DEBOUT		/* debugging on console and/or printer */

#include "kernel.h"
#if (MACHINE == ATARI)
#include <minix/com.h>
#include <signal.h>
#include <termios.h>
/*#include <sgtty.h>*/

#include "proc.h"
#include "tty.h"

#ifdef DEBOUT
PRIVATE int	STuseCon = 1;
PRIVATE int	STusePrt = 0;
#endif
#ifdef DEBDMP
PRIVATE int	STdoDump = 1;
#endif
PUBLIC int	STdebKey = 0;		/* set to F1..F10 by stkbd.c */

/*===========================================================================*
 *				func_key				     *
 *===========================================================================*/
PUBLIC void func_key()
{
  int i;

/* handle CTRL-ALT-PFX sequences */
  if (STdebKey == 0) return;

  switch (STdebKey) {
#ifdef DEBDMP
  case 1:	/* PF1: print process table */
	p_dmp(); break;
  case 2:	/* PF2: print memory map */
	map_dmp(); break;
  case 3:	/* PF3: print regs user prog */
	reg_dmp(bill_ptr); break; /* ++jrb */
  case 6:	/* PF6: ON/OFF dump tables on panic */
	STdoDump ^= 1; break;
#endif
#ifdef DEBOUT
  case 4:	/* PF4: ON/OFF console debugging */
	STuseCon ^= 1; break;
  case 5:	/* PF5: ON/OFF printer debugging */
	STusePrt ^= 1; break;
#endif
#ifdef ALLDONE
#ifdef DEBDMP
  case 7:	/* PF7: dump tty info */
	tty_dmp(); break;
#endif
#endif
#ifdef AM_KERNEL
  case 8:	/* PF8: dump Amoeba statistics */
  	amdump(); break;
#endif
  case 10:	/* PF10: issue SIGKILL */
	for (i = 0; i < NR_CONS; i++)
	{
	    sigchar(&tty_table[i], SIGKILL); break;
	}
  default:
	break; /* don't bomb out */
  }
  STdebKey = 0;
/*  tty_events -= EVENT_THRESHOLD;*/
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
/*
  map_dmp();
*/
#endif
}

/*===========================================================================*
 *				putk					     *
 *===========================================================================*/
/* 
 * This procedure is used by the kernel version of printf().
 * The one in the library sends a message to FS, which is not
 * needed for printing within the kernel.
 */
PUBLIC void putk(c)
int c;
{
#ifdef DEBOUT
/*
 * Use any combination of the printer or the console.
 */

  if (STuseCon)
#endif
	out_char(&tty_table[current], c); /* show char on current virtual cons */
#ifdef DEBOUT
  if (STusePrt)
	prtc(c);
#endif
}
#ifdef MESSAGE_DEBUG
/*===========================================================================*
 *				dump_msg				     *
 *===========================================================================*/
void dump_msg(sender, src_dest, kind, mptr)
int sender;
int src_dest;
int kind; 
message *mptr;
{
  int *ip;
  int i, curcon = current;
  char kc;
   
  if (src_dest == ANY) return;
  switch (kind) {
    case RECEIVE: kc = 'R'; break;
    case SEND:    kc = 'S'; break;
    case BOTH:    kc = 'B'; break;
    default:      kc = '?'; break;
  }
  vduswitch(&tty_table[0]);
  printf("%02d-%c>%02d ", sender, kc, src_dest);
  for (ip = (int *) mptr,i=0;i < (sizeof(*mptr)/2)-1; ip++,i++)
   	printf("%04x:", *ip);
  printf("%04x\n", *ip);
  vduswitch(&tty_table[curcon]); 
}
#endif /* MESSAGE_DEBUG */
#endif
