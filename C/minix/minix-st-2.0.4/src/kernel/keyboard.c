/* Keyboard driver for PC's and AT's.
 *
 * Changed by Marcus Hampel	(04/02/1994)
 *  - Loadable keymaps
 */

#include "kernel.h"
#include <termios.h>
#include <signal.h>
#include <unistd.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include <minix/keymap.h>
#include "tty.h"
#include "keymaps/us-std.src"

/* Standard and AT keyboard.  (PS/2 MCA implies AT throughout.) */
#define KEYBD		0x60	/* I/O port for keyboard data */

/* AT keyboard. */
#define KB_COMMAND	0x64	/* I/O port for commands on AT */
#define KB_STATUS	0x64	/* I/O port for status on AT */
#define KB_ACK		0xFA	/* keyboard ack response */
#define KB_OUT_FULL	0x01	/* status bit set when keypress char pending */
#define KB_IN_FULL	0x02	/* status bit set when not ready to receive */
#define LED_CODE	0xED	/* command to keyboard to set LEDs */
#define MAX_KB_ACK_RETRIES 0x1000	/* max #times to wait for kb ack */
#define MAX_KB_BUSY_RETRIES 0x1000	/* max #times to loop while kb busy */
#define KBIT		0x80	/* bit used to ack characters to keyboard */

/* Miscellaneous. */
#define ESC_SCAN	0x01	/* Reboot key when panicking */
#define SLASH_SCAN	0x35	/* to recognize numeric slash */
#define RSHIFT_SCAN	0x36	/* to distinguish left and right shift */
#define HOME_SCAN	0x47	/* first key on the numeric keypad */
#define INS_SCAN	0x52	/* INS for use in CTRL-ALT-INS reboot */
#define DEL_SCAN	0x53	/* DEL for use in CTRL-ALT-DEL reboot */
#define CONSOLE		   0	/* line number for console */
#define MEMCHECK_ADR   0x472	/* address to stop memory check after reboot */
#define MEMCHECK_MAG  0x1234	/* magic number to stop memory check */

#define KB_IN_BYTES	  32	/* size of keyboard input buffer */

PRIVATE char ibuf[KB_IN_BYTES];	/* input buffer */
PRIVATE char *ihead = ibuf;	/* next free spot in input buffer */
PRIVATE char *itail = ibuf;	/* scan code to return to TTY */
PRIVATE int icount;		/* # codes in buffer */

PRIVATE int esc;		/* escape scan code detected? */
PRIVATE int alt_l;		/* left alt key state */
PRIVATE int alt_r;		/* right alt key state */
PRIVATE int alt;		/* either alt key */
PRIVATE int ctrl_l;		/* left control key state */
PRIVATE int ctrl_r;		/* right control key state */
PRIVATE int ctrl;		/* either control key */
PRIVATE int shift_l;		/* left shift key state */
PRIVATE int shift_r;		/* right shift key state */
PRIVATE int shift;		/* either shift key */
PRIVATE int num_down;		/* num lock key depressed */
PRIVATE int caps_down;		/* caps lock key depressed */
PRIVATE int scroll_down;	/* scroll lock key depressed */
PRIVATE int locks[NR_CONS];	/* per console lock keys state */

/* Lock key active bits.  Chosen to be equal to the keyboard LED bits. */
#define SCROLL_LOCK	0x01
#define NUM_LOCK	0x02
#define CAPS_LOCK	0x04

PRIVATE char numpad_map[] =
		{'H', 'Y', 'A', 'B', 'D', 'C', 'V', 'U', 'G', 'S', 'T', '@'};

FORWARD _PROTOTYPE( int kb_ack, (void) );
FORWARD _PROTOTYPE( int kb_wait, (void) );
FORWARD _PROTOTYPE( int func_key, (int scode) );
FORWARD _PROTOTYPE( int scan_keyboard, (void) );
FORWARD _PROTOTYPE( unsigned make_break, (int scode) );
FORWARD _PROTOTYPE( void set_leds, (void) );
FORWARD _PROTOTYPE( int kbd_hw_int, (irq_hook_t *hook) );
FORWARD _PROTOTYPE( void kb_read, (struct tty *tp) );
FORWARD _PROTOTYPE( unsigned map_key, (int scode) );


/*===========================================================================*
 *				map_key0				     *
 *===========================================================================*/
/* Map a scan code to an ASCII code ignoring modifiers. */
#define map_key0(scode)	 \
	((unsigned) keymap[(scode) * MAP_COLS])


/*===========================================================================*
 *				map_key					     *
 *===========================================================================*/
PRIVATE unsigned map_key(scode)
int scode;
{
/* Map a scan code to an ASCII code. */

  int caps, column, lk;
  u16_t *keyrow;

  if (scode == SLASH_SCAN && esc) return '/';	/* don't map numeric slash */

  keyrow = &keymap[scode * MAP_COLS];

  caps = shift;
  lk = locks[current];
  if ((lk & NUM_LOCK) && HOME_SCAN <= scode && scode <= DEL_SCAN) caps = !caps;
  if ((lk & CAPS_LOCK) && (keyrow[0] & HASCAPS)) caps = !caps;

  if (alt) {
	column = 2;
	if (ctrl || alt_r) column = 3;	/* Ctrl + Alt == AltGr */
	if (caps) column = 4;
  } else {
	column = 0;
	if (caps) column = 1;
	if (ctrl) column = 5;
  }
  return keyrow[column] & ~HASCAPS;
}


/*===========================================================================*
 *				kbd_hw_int				     *
 *===========================================================================*/
PRIVATE int kbd_hw_int(hook)
irq_hook_t *hook;
{
/* A keyboard interrupt has occurred.  Process it. */

  int scode;

  /* Fetch the character from the keyboard hardware and acknowledge it. */
  scode = scan_keyboard();

  /* Store the scancode in memory so the task can get at it later. */
  if (icount < KB_IN_BYTES) {
	*ihead++ = scode;
	if (ihead == ibuf + KB_IN_BYTES) ihead = ibuf;
	icount++;
	tty_table[current].tty_events = 1;
	force_timeout();
  }
  return 1;	/* Reenable keyboard interrupt */
}


/*==========================================================================*
 *				kb_read					    *
 *==========================================================================*/
PRIVATE void kb_read(tp)
tty_t *tp;
{
/* Process characters from the circular keyboard buffer. */

  char buf[3];
  int scode;
  unsigned ch;

  tp = &tty_table[current];		/* always use the current console */

  while (icount > 0) {
	scode = *itail++;			/* take one key scan code */
	if (itail == ibuf + KB_IN_BYTES) itail = ibuf;
	lock();
	icount--;
	unlock();

	/* Function keys are being used for debug dumps. */
	if (func_key(scode)) continue;

	/* Perform make/break processing. */
	ch = make_break(scode);

	if (ch <= 0xFF) {
		/* A normal character. */
		buf[0] = ch;
		(void) in_process(tp, buf, 1);
	} else
	if (HOME <= ch && ch <= INSRT) {
		/* An ASCII escape sequence generated by the numeric pad. */
		buf[0] = ESC;
		buf[1] = '[';
		buf[2] = numpad_map[ch - HOME];
		(void) in_process(tp, buf, 3);
	} else
	if (ch == ALEFT) {
		/* Choose lower numbered console as current console. */
		select_console(current - 1);
		set_leds();
	} else
	if (ch == ARIGHT) {
		/* Choose higher numbered console as current console. */
		select_console(current + 1);
		set_leds();
	} else
	if (AF1 <= ch && ch <= AF12) {
		/* Alt-F1 is console, Alt-F2 is ttyc1, etc. */
		select_console(ch - AF1);
		set_leds();
	}
  }
}


/*===========================================================================*
 *				make_break				     *
 *===========================================================================*/
PRIVATE unsigned make_break(scode)
int scode;			/* scan code of key just struck or released */
{
/* This routine can handle keyboards that interrupt only on key depression,
 * as well as keyboards that interrupt on key depression and key release.
 * For efficiency, the interrupt routine filters out most key releases.
 */
  int ch, make, escape;
  static int CAD_count = 0;

  /* Check for CTRL-ALT-DEL, and if found, halt the computer. This would
   * be better done in keyboard() in case TTY is hung, except control and
   * alt are set in the high level code.
   */
  if (ctrl && alt && (scode == DEL_SCAN || scode == INS_SCAN))
  {
	if (++CAD_count == 3) wreboot(RBT_HALT);
	cause_sig(INIT_PROC_NR, SIGABRT);
	return -1;
  }

  /* High-order bit set on key release. */
  make = (scode & 0200) == 0;		/* true if pressed */

  ch = map_key(scode &= 0177);		/* map to ASCII */

  escape = esc;		/* Key is escaped?  (true if added since the XT) */
  esc = 0;

  switch (ch) {
  	case CTRL:		/* Left or right control key */
		*(escape ? &ctrl_r : &ctrl_l) = make;
		ctrl = ctrl_l | ctrl_r;
		break;
  	case SHIFT:		/* Left or right shift key */
		*(scode == RSHIFT_SCAN ? &shift_r : &shift_l) = make;
		shift = shift_l | shift_r;
		break;
  	case ALT:		/* Left or right alt key */
		*(escape ? &alt_r : &alt_l) = make;
		alt = alt_l | alt_r;
		break;
  	case CALOCK:		/* Caps lock - toggle on 0 -> 1 transition */
		if (caps_down < make) {
			locks[current] ^= CAPS_LOCK;
			set_leds();
		}
		caps_down = make;
		break;
  	case NLOCK:		/* Num lock */
		if (num_down < make) {
			locks[current] ^= NUM_LOCK;
			set_leds();
		}
		num_down = make;
		break;
  	case SLOCK:		/* Scroll lock */
		if (scroll_down < make) {
			locks[current] ^= SCROLL_LOCK;
			set_leds();
		}
		scroll_down = make;
		break;
  	case EXTKEY:		/* Escape keycode */
		esc = 1;		/* Next key is escaped */
		return(-1);
  	default:		/* A normal key */
		if (make) return(ch);
  }

  /* Key release, or a shift type key. */
  return(-1);
}


/*===========================================================================*
 *				set_leds				     *
 *===========================================================================*/
PRIVATE void set_leds()
{
/* Set the LEDs on the caps, num, and scroll lock keys */

  if (!pc_at) return;	/* PC/XT doesn't have LEDs */

  kb_wait();			/* wait for buffer empty  */
  outb(KEYBD, LED_CODE);	/* prepare keyboard to accept LED values */
  kb_ack();			/* wait for ack response  */

  kb_wait();			/* wait for buffer empty  */
  outb(KEYBD, locks[current]);	/* give keyboard LED values */
  kb_ack();			/* wait for ack response  */
}


/*==========================================================================*
 *				kb_wait					    *
 *==========================================================================*/
PRIVATE int kb_wait()
{
/* Wait until the controller is ready; return zero if this times out. */

  int retries, status;

  retries = MAX_KB_BUSY_RETRIES + 1;	/* wait until not busy */
  while (--retries != 0
		&& (status = inb(KB_STATUS)) & (KB_IN_FULL|KB_OUT_FULL)) {
	if (status & KB_OUT_FULL) (void) inb(KEYBD);	/* discard */
  }
  return(retries);		/* nonzero if ready */
}


/*==========================================================================*
 *				kb_ack					    *
 *==========================================================================*/
PRIVATE int kb_ack()
{
/* Wait until kbd acknowledges last command; return zero if this times out. */

  int retries;

  retries = MAX_KB_ACK_RETRIES + 1;
  while (--retries != 0 && inb(KEYBD) != KB_ACK)
	;			/* wait for ack */
  return(retries);		/* nonzero if ack received */
}

/*===========================================================================*
 *				kb_init					     *
 *===========================================================================*/
PUBLIC void kb_init(tp)
tty_t *tp;
{
/* Initialize the keyboard driver. */
  static irq_hook_t kbd_hook;

  tp->tty_devread = kb_read;	/* Input function */

  set_leds();			/* Turn off numlock led */

  scan_keyboard();		/* Discard leftover keystroke */

  /* Set interrupt handler and enable keyboard IRQ. */
  put_irq_handler(&kbd_hook, KEYBOARD_IRQ, kbd_hw_int);
  enable_irq(&kbd_hook);
}


/*===========================================================================*
 *				kbd_loadmap				     *
 *===========================================================================*/
PUBLIC int kbd_loadmap(user_phys)
phys_bytes user_phys;
{
/* Load a new keymap. */

  phys_copy(user_phys, vir2phys(keymap), (phys_bytes) sizeof(keymap));
  return(OK);
}


/*===========================================================================*
 *				func_key				     *
 *===========================================================================*/
PRIVATE int func_key(scode)
int scode;			/* scan code for a function key */
{
/* This procedure traps function keys for debugging and control purposes. */

  unsigned code;

  if (scode & 0200) return(FALSE);		/* key release */
  code = map_key0(scode);			/* first ignore modifiers */
  if (code < F1 || code > F12) return(FALSE);	/* not our job */

  switch (map_key(scode)) {			/* include modifiers */

  case F1:	p_dmp(); break;		/* print process table */
  case F2:	map_dmp(); break;	/* print memory map */
  case F3:	toggle_scroll(); break;	/* hardware vs. software scrolling */

  case F5:				/* network statistics */
#if ENABLE_DP8390
		dp8390_dump();
#endif
#if ENABLE_RTL8139
		rtl8139_dump();
#endif
		break;
  case CF7:	sigchar(&tty_table[CONSOLE], SIGQUIT); break;
  case CF8:	sigchar(&tty_table[CONSOLE], SIGINT); break;
  case CF9:	sigchar(&tty_table[CONSOLE], SIGKILL); break;
  default:	return(FALSE);
  }
  return(TRUE);
}


/*==========================================================================*
 *				scan_keyboard				    *
 *==========================================================================*/
PRIVATE int scan_keyboard()
{
/* Fetch the character from the keyboard hardware and acknowledge it. */

  int code;
  int val;

  code = inb(KEYBD);		/* get the scan code for the key struck */
  val = inb(PORT_B);		/* strobe the keyboard to ack the char */
  outb(PORT_B, val | KBIT);	/* strobe the bit high */
  outb(PORT_B, val);		/* now strobe it low */
  return code;
}


/*==========================================================================*
 *				wreboot					    *
 *==========================================================================*/
PUBLIC void wreboot(how)
int how;		/* 0 = halt, 1 = reboot, 2 = panic!, ... */
{
/* Wait for keystrokes for printing debugging info and reboot. */

  int quiet, code;
  static u16_t magic = MEMCHECK_MAG;
  struct tasktab *ttp;

  /* Mask all interrupts. */
  outb(INT_CTLMASK, ~0);

  /* Tell several tasks to stop. */
  cons_stop();
#if ENABLE_DP8390
  dp8390_stop();
#endif
#if ENABLE_RTL8139
  rtl8139_stop();
#endif
  floppy_stop();
  clock_stop();
#if ENABLE_DOSFILE
  dosfile_stop();
#endif

  if (how == RBT_HALT) {
	printf("System Halted\n");
	if (!mon_return) how = RBT_PANIC;
  }

  if (how == RBT_PANIC) {
	/* A panic! */
	printf("Hit ESC to reboot, F-keys for debug dumps\n");

	(void) scan_keyboard();	/* ack any old input */
	quiet = scan_keyboard();/* quiescent value (0 on PC, last code on AT)*/
	for (;;) {
		milli_delay(100);	/* pause for a decisecond */
		code = scan_keyboard();
		if (code != quiet) {
			/* A key has been pressed. */
			if (code == ESC_SCAN) break; /* reboot if ESC typed */
			(void) func_key(code);	     /* process function key */
			quiet = scan_keyboard();
		}
	}
	how = RBT_REBOOT;
  }

  if (how == RBT_REBOOT) printf("Rebooting\n");

  if (mon_return && how != RBT_RESET) {
	/* Reinitialize the interrupt controllers to the BIOS defaults. */
	intr_init(0);
	outb(INT_CTLMASK, 0);
	outb(INT2_CTLMASK, 0);

	/* Return to the boot monitor. */
	if (how == RBT_HALT) {
		phys_copy(vir2phys(""), mon_params, 2);
	} else
	if (how == RBT_REBOOT) {
		phys_copy(vir2phys("delay;boot"), mon_params, 11);
	}
	level0(monitor);
  }

  /* Stop BIOS memory test. */
  phys_copy(vir2phys(&magic), (phys_bytes) MEMCHECK_ADR,
						(phys_bytes) sizeof(magic));

  /* Reset the system by jumping to the reset address (real mode), or by
   * forcing a processor shutdown (protected mode).
   */
  level0(reset);
}
