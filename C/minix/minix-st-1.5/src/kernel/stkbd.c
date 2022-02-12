
#if (CHIP == M68000)
/*
 * The ACIA driver for the Atari ST, both MDI and KBD
 *
 * Modified the original 1.1 code to support more
 * function keys and provide a robust way of determing
 * which keys are function keys. 
 * Note: defining KEYBOARD as PC (in <minix/config.h>
 *	 will result in key definitions
 *       that are the same as for Minix 1.1 with the
 *       exception that <Shift><ClrHome> works and
 *       <Insert> generates ESC [I
 *                                    S.Poole 21.1.89 
 */
#include "kernel.h"
#include <minix/com.h>
#include <sgtty.h>

#include "staddr.h"
#include "stacia.h"

#include "tty.h"

#define THRESHOLD                 20	/* # chars to accumulate before msg */

static void kbdkey();
static int national();
static void kbdkeypad();
static void kbdarrow();
static void kbdpf();

/*
 * Translation from keyboard codes into internal (ASCII like) codes
 * These tables represents a US keyboard, so MINIX.IMG as found on
 * the MINIX-ST BOOT floppy works well in the US.
 * The TOS program FIXKEYS.PRG is supplied to replace the keyboard
 * tables compiled into MINIX.IMG on the BOOT floppy, by the proper
 * national version of the keyboard tables used by TOS at the time
 * of running FIXKEYS.PRG.
 *
 * Since these three tables are not fully sufficient to deal with
 * all the differences, some special code is added in this driver
 * to cope with the national combinations with the ALT key. See
 * the routine national() below.
 *
 * Currently there are no provisions for non-ASCII characters.
 * Only the problem of entering the ASCII character set from a
 * variety of different keyboard layout is solved.
 * Non-ASCII characters cause three kinds of problems:
 *  - character codes above 127 loose their 8th bit in the TTY driver,
 *    if not in RAW mode
 *  - application programs do not know what to do with non-ASCII,
 *    and certainly not with the character codes Atari did assign
 *  - only ASCII characters can be displayed on the screen, since the
 *    font tables used by MINIX-ST have only 128 entries.
 */
 
#include "keymap.h"

/*
 * Flag for keypad mode
 * this can be set by code in stvdu.c
 */
#if (KEYBOARD == IBM_PC)
PUBLIC int keypad = FALSE;
#else
PUBLIC int keypad = TRUE;
#endif
/*
 * Flag for arrow key application mode
 * this can be set by code in stvdu.c
 */
PUBLIC int app_mode = FALSE;

/* 
 * Map function keys to an index into the 
 * table of function key values 
 */
PRIVATE unsigned char f_keys[] = {
/*00*/	   0,   0,   0,   0,   0,   0,   0,   0,
/*08*/	   0,   0,   0,   0,   0,   0,   0,   0,
/*10*/	   0,   0,   0,   0,   0,   0,   0,   0,
/*18*/	   0,   0,   0,   0,   0,   0,   0,   0,
/*20*/	   0,   0,   0,   0,   0,   0,   0,   0,
/*28*/	   0,   0,   0,   0,   0,   0,   0,   0,
/*30*/	   0,   0,   0,   0,   0,   0,   0,   0,
/*38*/	   0,   0,   0,   1,   2,   3,   4,   5,
/*40*/	   6,   7,   8,   9,  10,   0,   0,  17,
/*48*/	  16,   0,  26,  13,   0,  15,  30,   0,
/*50*/	  14,   0,  18,   0,   1,   2,   3,   4,
/*58*/	   5,   6,   7,   8,   9,  10,   0,   0,
/*60*/	   0,  11,  12,  19,  20,  21,  22,  23,
/*68*/	  24,  25,  27,  28,  29,  31,  32,  33,
/*70*/	  34,  35,  36,   0,   0,   0,   0,   0,
/*78*/	   0,   0,   0,   0,   0,   0,   0,   0
};

/*
 * Numbering of the function keys, this scheme was chosen
 * so that it easy to determine which function to call to actually
 * generate the string.
 *
 * Note: the <Help> and <Undo> keys are considered to be function
 *       keys 11 and 12.
 *
 * F-keys:    -----------------------------------------
 *            | 1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10|
 *            -----------------------------------------
 *
 * Arrow-Keys:    -------------
 *                |  12 |  11 |
 *                -------------
 *                | 18| 16| 17|
 *                -------------
 *                | 13| 14| 15|
 *                -------------
 *
 * Keypad:    -----------------
 *            | 19| 20| 21| 22|
 *            -----------------
 *            | 23| 24| 25| 26|
 *            -----------------
 *            | 27| 28| 29| 30|
 *            -----------------
 *            | 31| 32| 33|   |
 *            ------------- 36|
 *            |   34  | 35|   |
 *            -----------------
 */     

/* 
 * There is no problem with  expanding this struct to
 * have a field for <Control> and <Alternate> (and combinations
 * of them),  but who needs > 152 function keys? 
 */
struct fkey {
	char norm, shift;
};

PRIVATE struct fkey ftbl[] = {
#if (KEYBOARD == IBM_PC)
	/* 1  = F1      */ {'P',   0},
	/* 2  = F2      */ {'Q',   0},
	/* 3  = F3      */ {'R',   0},
	/* 4  = F4      */ {'S',   0},
	/* 5  = F5      */ {'T',   0},
	/* 6  = F6      */ {'U',   0},
	/* 7  = F7      */ {'V',   0},
	/* 8  = F8      */ {'W',   0},
	/* 9  = F9      */ {'X',   0},
	/* 10 = F10     */ {'Y',   0},
	/* 11 = Undo    */ {  0,   0},
	/* 12 = Help    */ {  0,   0},
#else
/* 
 * So that we can produce VT200 style function-key codes, 
 * the values here are integer values that are converted
 * to a string in kbdpf(). 
 *
 * The assignment of numbers to keys is rather chaotic,
 * but at least all the VT200 keys are there.
 */
	/* ST key       */		/* VT200 key	*/
	/* 1  = F1      */ {  1,  21},	/* Find	  F10	*/
	/* 2  = F2      */ {  2,  23},	/* Insert F11	*/
	/* 3  = F3      */ {  3,  24},	/* Remove F12	*/
	/* 4  = F4      */ {  4,  25},	/* Select F13	*/
	/* 5  = F5      */ {  5,  26},	/* Prev.  F14	*/
	/* 6  = F6      */ {  6,  31},	/* Next	  F17	*/
	/* 7  = F7      */ { 17,  32},	/* F6	  F18	*/
	/* 8  = F8      */ { 18,  33},	/* F7	  F19	*/
	/* 9  = F9      */ { 19,  34},	/* F8	  F20	*/
	/* 10 = F10     */ { 20,  35},	/* F9		*/
	/* 11 = Undo    */ { 36,  37},	/*		*/
	/* 12 = Help    */ { 28,  29},	/* Help	  Do	*/
#endif
/* 
 * The following codes are more conventional 
 */
	/* 13 = Left    */ {'D',   0},
	/* 14 = Down    */ {'B',   0},
	/* 15 = Right   */ {'C',   0},
	/* 16 = Up      */ {'A',   0},
	/* 17 = ClrHome */ {'H', 'J'},
	/* 18 = Insert  */ {'I',   0},
/* 
 * Keypad starts here 
 */
	/* 19 = (       */ {'P',   0},
	/* 20 = )       */ {'Q',   0},
	/* 21 = /       */ {'R',   0},
	/* 22 = *       */ {'S',   0},
	/* 23 = 7       */ {'w',   0},
	/* 24 = 8       */ {'x',   0},
	/* 25 = 9       */ {'y',   0},
	/* 26 = -       */ {'m',   0},
	/* 27 = 4       */ {'t',   0},
	/* 28 = 5       */ {'u',   0},
	/* 29 = 6       */ {'v',   0},
	/* 30 = +       */ {'l',   0},
	/* 31 = 1       */ {'q',   0},
	/* 32 = 2       */ {'r',   0},
	/* 33 = 3       */ {'s',   0},
	/* 34 = 0       */ {'p',   0},
	/* 35 = .       */ {'n',   0},
	/* 36 = Enter   */ {'M',   0}
};

PRIVATE message	kbdmes;		/* message used for console input chars */
PRIVATE int	repeatkey;	/* character to repeat */
PRIVATE int	repeattic;	/* time to next repeat */

/*===========================================================================*
 *				kbdint					     *
 *===========================================================================*/
PUBLIC void kbdint()
{
  register code, make, k;
  int s = lock();

  k = tty_buf_count(tty_driver_buf);
  /*
   * There may be multiple keys available. Read them all.
   */
  while (KBD->ac_cs & A_IRQ) {
	code = KBD->ac_da;
/*	printf("kbd: got %x\n", code & 0xFF); */
	/*
	 * The ST's keyboard interrupts twice per key,
	 * once when depressed, once when released.
	 * Filter out the latter, ignoring all but
	 * the shift-type keys.
         */
	make = code & 0x80 ? 0 : 1;	/* 1=depressed, 0=released */
	code &= 0x7F;
	switch (code) {
	case 0x2A:	/* shift key on left */
		shift1 = make; continue;
	case 0x36:	/* shift key on right */
		shift2 = make; continue;
	case 0x1D:	/* control */
		control = make; continue;
	case 0x38:	/* alt key */
		alt = make; continue;
	case 0x3A:	/* caps lock */
		if (make) capslock ^= 1; continue;
	}
	if (make == 0) {
		repeattic = 0;
		continue;
	}
	repeatkey = code;
	repeattic = 24;	/* delay: 24 * 16 msec == 0.4 sec */
	kbdkey(code);
  }
  if (tty_buf_count(tty_driver_buf) < THRESHOLD) {
	/* Don't send message.  Just accumulate.  Let clock do it. */
	INT_CTL_ENABLE;
	flush_flag++;
  } else rs_flush();			/* send TTY task a message */
  restore(s);
}

/*===========================================================================*
 *				kbdkey					     *
 *===========================================================================*/
PRIVATE void kbdkey(code)
int code;
{
  register int c,f,fc;

  f = f_keys[code];
  if (shift1 || shift2)
	c = keyshft[code];
  else if (capslock)
	c = keycaps[code];
  else
	c = keynorm[code];
  /* 
   * check if the key is not a function key 
   */
  if (!f) {
	if (alt)
		c = national(code, c | 0x80);
	if (control) {
		if (c == 0xFF) reboot(); /* CTRL-ALT-DEL */
		c &= 0x1F;
	}
	/* Check to see if character is XOFF, to stop output. */
	if (
		(tty_struct[CONSOLE].tty_mode & (RAW | CBREAK)) == 0
		&&
		tty_struct[CONSOLE].tty_xoff == c
	) {
		tty_struct[CONSOLE].tty_inhibited = STOPPED;
		return;
	}
	kbdput(c, CONSOLE);
	return;
  }
  if (control && alt && code >= 0x3B && code <= 0x44) {
	/*
	 * some special sequences
	 */
	kbdput(code - 0x3B + 1, OPERATOR);
	return;
  }
  f--; /* correct for index into ftbl */
  if (shift1 || shift2)
	fc = ftbl[f].shift;
  else
	fc = ftbl[f].norm;
  /* 
   * f naturally has to be >= 0 for this piece 
   * of code to work 
   */
  if (fc) {
	if (f < 12)
#if (KEYBOARD == IBM_PC)
		kbdkeypad(fc);
#else
		kbdpf(fc);
#endif
	else if (f < 18) {
#if (KEYBOARD == VT100)
		if (app_mode)
			kbdkeypad(fc);
		else
#endif
			kbdarrow(fc);
	}
	else if (keypad)
		/*
		 * keypad should be set by stvdu
		 */
		kbdkeypad(fc);
	else
		kbdput(c,CONSOLE);
  }
}

/*
 * Cope with national ALT and SHIFT-ALT combinations.
 * Currently only for Germany, France and Spain.
 * Extension are straightforward.
 */
PRIVATE int national(code, c)
int code, c;
{
  static char germany[] = {
	0x1A, '@', '\\',
	0x27, '[', '{',
	0x28, ']', '}',
	0
  };
  static char france[] = {
	0x1A, '[', '{',
	0x1B, ']', '}',
	0x28, '\\', 0,
	0x2B, '@', '~',
	0
  };
  static char spain[] = {
	0x1A, '[', '{',
	0x1B, ']', '}',
	0x28, 0x81, 0x9A,	/* lower/upper u-umlaut */
	0x2B, '#', '@',
	0
  };
  register char *p;

  /*
   * Distinguish the right keyboard version somehow
   */
  if (keynorm[0x1A] == 0x81)	/* lower u-umlaut */
	p = germany;
  else if (keynorm[0x1A] == '^')
	p = france;
  else if (keynorm[0x1A] == '\'')
	p = spain;
  else
	return(c);
  /*
   * See if it is one of the keys that need special attention
   */
  while (*p != code) {
	if (*p == 0)
		return(c);
	p += 3;
  }
  /*
   * It is indeed special. Distinguish between upper and lower case.
   */
  p++;
  if (shift1 || shift2)
	p++;
  if (*p == 0)
	return(c);
  return(*p);
}

/*
 * Store the character in memory
 */
PUBLIC void kbdput(c, line)
int c;
int line;
{
  register int k;

  /* Store the character in memory so the task can get at it later.
   * tty_driver_buf[0] is the current count, and tty_driver_buf[2] is the
   * maximum allowed to be stored.
   */
  if ( (k = tty_buf_count(tty_driver_buf)) >= tty_buf_max(tty_driver_buf)) 
	/*
	 * Too many characters have been buffered.
	 * Discard excess.
	 */
	return;
  /* There is room to store this character; do it. */
  k <<= 1;				/* each entry uses two bytes */
  tty_driver_buf[k+4] = c;		/* store the char code */
  tty_driver_buf[k+5] = line;		/* which line it came from */
  tty_buf_count(tty_driver_buf)++;	/* increment counter */
}

/*
 * Input escape sequence for keypad keys
 */
PRIVATE void kbdkeypad(c)
register int c;
{
	kbdput('\033', CONSOLE);
	kbdput('O', CONSOLE);
	kbdput(c, CONSOLE);
}

/*
 * Input escape sequence for arrow keys
 */
PRIVATE void kbdarrow(c)
register int c;
{
	kbdput('\033', CONSOLE);
	kbdput('[', CONSOLE);
	kbdput(c, CONSOLE);
}

#if (KEYBOARD == VT100)
/*
 * Input escape sequence for function keys
 */
PRIVATE void kbdpf(c)
register int c;
{
	register int t;

	kbdput('\033', CONSOLE);
	kbdput('[', CONSOLE);
	/* this stuff is not robust */
	if ((t = c / 10) > 0)
	  kbdput(t + '0', CONSOLE);	
	kbdput((c % 10) + '0', CONSOLE);
	kbdput('~', CONSOLE);
}
#endif

/*===========================================================================*
 *				kb_timer				     *
 *===========================================================================*/
PUBLIC void kb_timer()
{
  register int k, s;

  s = lock();
  if (repeattic == 0) {
	restore(s);
	return;
  }
  if (--repeattic != 0) {
	restore(s);
	return;
  }
  k = tty_buf_count(tty_driver_buf);
  kbdkey(repeatkey);
  if (k != tty_buf_count(tty_driver_buf))
  {
    if (tty_buf_count(tty_driver_buf) < THRESHOLD) {
	/* Don't send message.  Just accumulate.  Let clock do it. */
	INT_CTL_ENABLE;
	flush_flag++;
    }
    else rs_flush();			/* send TTY task a message */
  }
  repeattic = 4;	/* repeat: 4 * 16 msec == 0.066 sec */
  restore(s);
}

/*===========================================================================*
 *				kbdinit				     	     *
 *===========================================================================*/
PUBLIC void kbdinit()
{
  KBD->ac_cs = KBD_INIT | A_RXINT;
	/* divide by 16, 8 data, 1 stop, no parity, enable interrupts */
  KBD->ac_da = 0x12;
	/* mouse off */
}
#endif
