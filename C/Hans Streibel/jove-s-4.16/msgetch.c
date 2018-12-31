/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* MSDOS keyboard routines */

#include "jove.h"

#ifdef MSDOS	/* the body is the rest of this file */

#include "chars.h"
#include "disp.h"	/* for redisplay() */

#include <bios.h>
#include <dos.h>


private void rawkey_wait proto((void));

#ifdef IBMPCDOS
private ZXchar	last = EOF;

bool enhanced_keybrd;	/* VAR: exploit "enhanced" keyboard? */

/* Unlike the other _NKEYBRD services, the _NKEYBRD_READY service
 * *requires* specific support within _bios_keybrd.  In particular
 * the key information is returned in the ZF flag, which is not
 * captured otherwise.  If _NKEYBRD_READY is defined in the headers,
 * we presume that _bios_keybrd supports it.
 */
# ifdef _NKEYBRD_READY
#  define jkbready() \
	(_bios_keybrd(enhanced_keybrd? _NKEYBRD_READY : _KEYBRD_READY) != 0)
# else /* !_NKEYBRD_READY */
#  ifdef ZTCDOS
    /* Workaround for Zortech 3.0: use Zortech's asm() capability.
     *
     * Interrupt 16h, service 1h (get keyboard status) and
     * interrupt 16h, service 11h (get enhanced keyboard status)
     * return with ZF cleared iff there is a character.
     * The zkbready macro returns YES iff there is a character.
     *
     * Note that the nature of the Zortech asm facility demands
     * that the "service" argument be a constant expression.
     */
#   define zkbready(service)	(0 == (int) asm( \
	0xB4, service,	/* mov ah,service */ \
	0xCD, 0x16,	/* int 16h */ \
	0x9F,		/* lahf */ \
	0x25, 0x00, 0x40,	/* and ax,04000h */ \
	0x99		/* cwd [needed due to a Zortech bug] */ \
	))
#   define _NKEYBRD_READY	0x11
#   define jkbready()	\
	(enhanced_keybrd? zkbready(_NKEYBRD_READY) : zkbready(_KEYBRD_READY))
#  endif/* ZTCDOS */
# endif /* !_NKEYBRD_READY */

# ifdef jkbready	/* we can support enhanced keyboard */
#  ifndef _NKEYBRD_READ
#   define _NKEYBRD_READ		0x10
#  endif
#  define jkbread()	_bios_keybrd(enhanced_keybrd? _NKEYBRD_READ : _KEYBRD_READ)

#  ifndef _NKEYBRD_SHIFTSTATUS
#   define _NKEYBRD_SHIFTSTATUS	0x12
#  endif
#  define jkbshift()	_bios_keybrd(enhanced_keybrd? _NKEYBRD_SHIFTSTATUS : _KEYBRD_SHIFTSTATUS)
# else /* !kebready */
   /* We don't know how to support the enhanced keyboard, so we won't */
#  define jkbready()	_bios_keybrd(_KEYBRD_READY)
#  define jkbread()	_bios_keybrd(_KEYBRD_READ)
#  define jkbshift()	_bios_keybrd(_KEYBRD_SHIFTSTATUS)
# endif /* !kebready */

/* This table returns an Ascii character corresponding to a Scan Code index.
 * If a key has no ASCII equivalent, the table contains 0.
 */
static const char scanToAsciiLower[] = {
	/* 00 */ 0, '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '-', '=', '\\', '\b',
	/* 10 */ '-', 'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p', '[', ']', 0, 0, 'a',
	/* 20 */ 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l', ';', '\'', 0, '\r', 0, 'z', 'x',
	/* 30 */ 'c', 'v', 'b', 'n', 'm', ',', '.', '/', 0, 0, 0, 0, 0, ' ', 0, 0 };

static const char scanToAsciiUpper[] = {
	/* 00 */ 0, '!', '@', '#', '$', '%', '^', '&', '*', '(', ')', '_', '+', '|', '\177',
	/* 10 */ '_', 'Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P', '{', '}', 0, 0, 'A',
	/* 20 */ 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L', ':', '\"', 0, '\r', 0, 'Z', 'X',
	/* 30 */ 'C', 'V', 'B', 'N', 'M', '<', '>', '?', 0, 0, 0, 0, 0, ' ', 0, 0 };

#endif /* IBMPCDOS */

ZXchar
getrawinchar()
{
#ifdef IBMPCDOS
	unsigned scan;

	if (last != EOF) {
		scan = last;
		last = EOF;
		return scan;
	}

	rawkey_wait();
	scan = jkbread();

	/* check for Ctrl-spacebar and magically turn it into a Ctrl-@
	 * (scan == 0x03, char == 0x00).  Because keystrokes are queued
	 * but shift state is real-time, we add a (heuristic!) check
	 * requiring that no further characters are in the queue.
	 * Warning: the heuristic is not perfect.  The control could be
	 * recognized even if the it was pressed after the spacebar was
	 * released!
	 */
	if ((scan&0xff) == ' ' && (jkbshift() & 0x04) && !jkbready())
		scan = 0x0300;

	if ((scan&0xff) == 0 || (scan&0xff) == 0xe0) {
		ZXchar	next = ZXRC(scan >> 8);
		ZXchar  asciiChar;

		if (MetaKey && next < sizeof(scanToAsciiUpper)
		&& 0 != (asciiChar = ((jkbshift() & 0x03) && !jkbready()
			? scanToAsciiUpper : scanToAsciiLower)[next]))
		{
			last = asciiChar;
			scan = ESC;
		} else {
			/* Re-map shifted arrow keys and shifted Insert, Delete, Home, End,
			 * PgUp, and PgDn from 71-83 to 171-183.  This hack depends on
			 * the same heuristic as the ctrl-spacebar hack.
			 */
			if (71 <= next && next <= 83 && (jkbshift() & 0x03) && !jkbready())
				next += 100;
			/* Re-map keys that should have been ASCII */
			switch (next) {
			case 0x03:	/* ^@ and ^Space key */
				scan = '\0';	/* ASCII NUL */
				break;
			case 0x53:	/* Delete key */
				scan = DEL;	/* ASCII DEL */
				break;
			default:
				last = next;	/* not ASCII: more to come next time */
				scan = PCNONASCII;
				break;
			}
		}
	}
	return scan&0xff;

#else /* !IBMPCDOS */
# ifdef RAINBOW

	union REGS regs;

	rawkey_wait();

	for (;;) {
		regs.x.di = 2;
		int86(0x18, &regs, &regs);
		if (regs.h.al != 0)	/* should never happen, but who knows */
			return regs.h.al;
	}
# else /* !RAINBOW */
	rawkey_wait();
	return bdos(0x06, 0x00ff, 0xff) & 0xff;
# endif /* !RAINBOW */
#endif /* !IBMPCDOS */
}

private bool	waiting = NO;

bool
rawkey_ready()
{
#ifdef IBMPCDOS
	return !waiting && (last != EOF || jkbready());
#else /* !IBMPCDOS */
	union REGS regs;

	if (waiting)
		return NO;
# ifdef RAINBOW
	regs.x.di = 4;
	int86(0x18, &regs, &regs);
	return regs.h.cl != 0;
# else /* !RAINBOW */
	regs.h.ah = 0x44;		/* ioctl call */
	regs.x.bx = 0;			/* stdin file handle */
	regs.h.al = 0x06;		/* get input status */
	intdos(&regs, &regs);
	return regs.h.al & 1;
# endif /* !RAINBOW */
#endif /* !IBMPCDOS */
}

/* Wait for next character, updating the modeline if it displays the time.
 * NOTE: this is a busy wait.
 */
private void
rawkey_wait()
{
	while (!rawkey_ready()) {
		if (UpdModLine) {
			waiting = YES;
			redisplay();
			waiting = NO;
		} else if (TimeDisplayed) {
			struct dostime_t tc;
			static char lastmin = 0;

			_dos_gettime(&tc);
			if (tc.minute != lastmin) {
				UpdModLine = YES;
				lastmin = tc.minute;
			}
		} else {
			/* No reason to busy wait: return to do a blocking read.
			 * This might improve performance in multitasking systems.
			 */
			break;
		}
	}
}

void
ttysetattr(n)
bool	n;	/* also used as subscript! */
{
	static char break_state;

	if (n) {
		/* set the break state to off */
		union REGS regs;

		regs.h.ah = 0x33;		/* break status */
		regs.h.al = 0x00;		/* request current state */
		intdos(&regs, &regs);
		break_state = regs.h.dl;

		bdos(0x33, 0, 1);	/* turn off break */
	} else {
		/* restore the break state */
		bdos(0x33, break_state, 1);
	}
}

#endif /* MSDOS */
