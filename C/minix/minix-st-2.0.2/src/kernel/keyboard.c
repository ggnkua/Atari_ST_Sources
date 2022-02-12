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
#define ESC_SCAN	   1	/* Reboot key when panicking */
#define SLASH_SCAN	  53	/* to recognize numeric slash */
#define HOME_SCAN	  71	/* first key on the numeric keypad */
#define DEL_SCAN	  83	/* DEL for use in CTRL-ALT-DEL reboot */
#define CONSOLE		   0	/* line number for console */
#define MEMCHECK_ADR   0x472	/* address to stop memory check after reboot */
#define MEMCHECK_MAG  0x1234	/* magic number to stop memory check */

#define kb_addr()	(&kb_lines[0])	/* there is only one keyboard */
#define KB_IN_BYTES	  32	/* size of keyboard input buffer */

PRIVATE int alt1;		/* left alt key state */
PRIVATE int alt2;		/* right alt key state */
PRIVATE int capslock;		/* caps lock key state */
PRIVATE int esc;		/* escape scan code detected? */
PRIVATE int control;		/* control key state */
PRIVATE int caps_off;		/* 1 = normal position, 0 = depressed */
PRIVATE int numlock;		/* number lock key state */
PRIVATE int num_off;		/* 1 = normal position, 0 = depressed */
PRIVATE int slock;		/* scroll lock key state */
PRIVATE int slock_off;		/* 1 = normal position, 0 = depressed */
PRIVATE int shift;		/* shift key state */

PRIVATE char numpad_map[] =
		{'H', 'Y', 'A', 'B', 'D', 'C', 'V', 'U', 'G', 'S', 'T', '@'};

/* Keyboard structure, 1 per console. */
struct kb_s {
  char *ihead;			/* next free spot in input buffer */
  char *itail;			/* scan code to return to TTY */
  int icount;			/* # codes in buffer */
  char ibuf[KB_IN_BYTES];	/* input buffer */
};

PRIVATE struct kb_s kb_lines[NR_CONS];

FORWARD _PROTOTYPE( int kb_ack, (void) );
FORWARD _PROTOTYPE( int kb_wait, (void) );
FORWARD _PROTOTYPE( int func_key, (int scode) );
FORWARD _PROTOTYPE( int scan_keyboard, (void) );
FORWARD _PROTOTYPE( unsigned make_break, (int scode) );
FORWARD _PROTOTYPE( void set_leds, (void) );
FORWARD _PROTOTYPE( int kbd_hw_int, (int irq) );
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

  int caps, column;
  u16_t *keyrow;

  if (scode == SLASH_SCAN && esc) return '/';	/* don't map numeric slash */

  keyrow = &keymap[scode * MAP_COLS];

  caps = shift;
  if (numlock && HOME_SCAN <= scode && scode <= DEL_SCAN) caps = !caps;
  if (capslock && (keyrow[0] & HASCAPS)) caps = !caps;

  if (alt1 || alt2) {
	column = 2;
	if (control || alt2) column = 3;	/* Ctrl + Alt1 == Alt2 */
	if (caps) column = 4;
  } else {
	column = 0;
	if (caps) column = 1;
	if (control) column = 5;
  }
  return keyrow[column] & ~HASCAPS;
}


/*===========================================================================*
 *				kbd_hw_int				     *
 *===========================================================================*/
PRIVATE int kbd_hw_int(irq)
int irq;
{
/* A keyboard interrupt has occurred.  Process it. */

  int code;
  unsigned km;
  register struct kb_s *kb;

  /* Fetch the character from the keyboard hardware and acknowledge it. */
  code = scan_keyboard();

  /* The IBM keyboard interrupts twice per key, once when depressed, once when
   * released.  Filter out the latter, ignoring all but the shift-type keys.
   * The shift-type keys 29, 42, 54, 56, 58, and 69 must be processed normally.
   */

  if (code & 0200) {
	/* A key has been released (high bit is set). */
	km = map_key0(code & 0177);
	if (km != CTRL && km != SHIFT && km != ALT && km != CALOCK
			&& km != NLOCK && km != SLOCK && km != EXTKEY)
		return 1;
  }

  /* Store the character in memory so the task can get at it later. */
  kb = kb_addr();
  if (kb->icount < KB_IN_BYTES) {
	*kb->ihead++ = code;
	if (kb->ihead == kb->ibuf + KB_IN_BYTES) kb->ihead = kb->ibuf;
	kb->icount++;
	tty_table[current].tty_events = 1;
	force_timeout();
  }
  /* Else it doesn't fit - discard it. */
  return 1;	/* Reenable keyboard interrupt */
}


/*==========================================================================*
 *				kb_read					    *
 *==========================================================================*/
PRIVATE void kb_read(tp)
tty_t *tp;
{
/* Process characters from the circular keyboard buffer. */

  struct kb_s *kb;
  char buf[3];
  int scode;
  unsigned ch;

  kb = kb_addr();
  tp = &tty_table[current];		/* always use the current console */

  while (kb->icount > 0) {
	scode = *kb->itail++;			/* take one key scan code */
	if (kb->itail == kb->ibuf + KB_IN_BYTES) kb->itail = kb->ibuf;
	lock();
	kb->icount--;
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
	} else
	if (ch == ARIGHT) {
		/* Choose higher numbered console as current console. */
		select_console(current + 1);
	} else
	if (AF1 <= ch && ch <= AF12) {
		/* Alt-F1 is console, Alt-F2 is ttyc1, etc. */
		select_console(ch - AF1);
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
  int ch, make;
  static int CAD_count = 0;

  /* Check for CTRL-ALT-DEL, and if found, halt the computer. This would
   * be better done in keyboard() in case TTY is hung, except control and
   * alt are set in the high level code.
   */
  if (control && (alt1 || alt2) && scode == DEL_SCAN)
  {
	if (++CAD_count == 3) wreboot(RBT_HALT);
	cause_sig(INIT_PROC_NR, SIGABRT);
	return -1;
  }

  /* High-order bit set on key release. */
  make = (scode & 0200 ? 0 : 1);	/* 0 = release, 1 = press */

  ch = map_key(scode & 0177);		/* map to ASCII */

  switch (ch) {
  	case CTRL:
		control = make;
		ch = -1;
		break;
  	case SHIFT:
		shift = make;
		ch = -1;
		break;
  	case ALT:
		if (make) {
			if (esc) alt2 = 1; else alt1 = 1;
		} else {
			alt1 = alt2 = 0;
		}
		ch = -1;
		break;
  	case CALOCK:
		if (make && caps_off) {
			capslock = 1 - capslock;
			set_leds();
		}
		caps_off = 1 - make;
		ch = -1;
		break;
  	case NLOCK:
		if (make && num_off) {
			numlock = 1 - numlock;
			set_leds();
		}
		num_off = 1 - make;
		ch = -1;
		break;
  	case SLOCK:
		if (make & slock_off) {
			slock = 1 - slock;
			set_leds();
		}
		slock_off = 1 - make;
		ch = -1;
		break;
  	case EXTKEY:
		esc = 1;
		return(-1);
  	default:
		if (!make) ch = -1;
  }
  esc = 0;
  return(ch);
}


/*===========================================================================*
 *				set_leds				     *
 *===========================================================================*/
PRIVATE void set_leds()
{
/* Set the LEDs on the caps lock and num lock keys */

  unsigned leds;

  if (!pc_at) return;	/* PC/XT doesn't have LEDs */

  /* encode LED bits */
  leds = (slock << 0) | (numlock << 1) | (capslock << 2);

  kb_wait();			/* wait for buffer empty  */
  out_byte(KEYBD, LED_CODE);	/* prepare keyboard to accept LED values */
  kb_ack();			/* wait for ack response  */

  kb_wait();			/* wait for buffer empty  */
  out_byte(KEYBD, leds);	/* give keyboard LED values */
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
		&& (status = in_byte(KB_STATUS)) & (KB_IN_FULL|KB_OUT_FULL)) {
	if (status & KB_OUT_FULL) (void) in_byte(KEYBD);	/* discard */
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
  while (--retries != 0 && in_byte(KEYBD) != KB_ACK)
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

  register struct kb_s *kb;

  /* Input function. */
  tp->tty_devread = kb_read;

  kb = kb_addr();

  /* Set up input queue. */
  kb->ihead = kb->itail = kb->ibuf;

  /* Set initial values. */
  caps_off = 1;
  num_off = 1;
  slock_off = 1;
  esc = 0;

  set_leds();			/* turn off numlock led */

  scan_keyboard();		/* stop lockup from leftover keystroke */

  put_irq_handler(KEYBOARD_IRQ, kbd_hw_int);	/* set the interrupt handler */
  enable_irq(KEYBOARD_IRQ);	/* safe now everything initialised! */
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

  code = map_key0(scode);			/* first ignore modifiers */
  if (code < F1 || code > F12) return(FALSE);	/* not our job */

  switch (map_key(scode)) {			/* include modifiers */

  case F1:	p_dmp(); break;		/* print process table */
  case F2:	map_dmp(); break;	/* print memory map */
  case F3:	toggle_scroll(); break;	/* hardware vs. software scrolling */

#if ENABLE_NETWORKING
  case F5:	dp_dump(); break;		/* network statistics */
#endif
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

  code = in_byte(KEYBD);	/* get the scan code for the key struck */
  val = in_byte(PORT_B);	/* strobe the keyboard to ack the char */
  out_byte(PORT_B, val | KBIT);	/* strobe the bit high */
  out_byte(PORT_B, val);	/* now strobe it low */
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
  out_byte(INT_CTLMASK, ~0);

  /* Tell several tasks to stop. */
  cons_stop();
#if ENABLE_NETWORKING
  dp8390_stop();
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
	out_byte(INT_CTLMASK, 0);
	out_byte(INT2_CTLMASK, 0);

	/* Return to the boot monitor. */
	if (how == RBT_HALT) {
		reboot_code = vir2phys("");
	} else
	if (how == RBT_REBOOT) {
		reboot_code = vir2phys("delay;boot");
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
