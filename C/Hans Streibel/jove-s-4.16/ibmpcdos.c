/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#include "jove.h"

#ifdef IBMPCDOS	/* the body is the rest of this file */

#include "fp.h"	/* scr_putchar */
#include "chars.h"
#include "screen.h"
#include "term.h"

/* here come the actual emulation routines */

#include <dos.h>
#include <conio.h>

typedef unsigned char	BYTE;
typedef unsigned int	WORD;

#define VBS_set_cursor_position	0x02
#define VBS_get_cursor_position_and_size	0x03
#define VBS_select_active_display_page	0x05
#define VBS_scroll_window_up	0x06
#define VBS_scroll_window_down	0x07
#define VBS_read_character_and_attribute	0x08
#define VBS_write_character_and_attribute	0x09
#define VBS_TTY_character_output	0x0e
#define VBS_get_current_video_state	0x0f

#define VBSF_get_font_information	0x1130

#define VideoBIOS(r)	int86(0x10, (r), (r));

private BYTE
	c_attr = 0x07,	/* current attribute white on black */
	c_row = 0,	/* current row */
	c_col = 0;	/* current column */

int
	Txattr = 0x07,	/* VAR: text-attribute (white on black) */
	Mlattr = 0x70,	/* VAR: mode-line-attribute (black on white) */
	Hlattr = 0x10;	/* VAR: highlight-attribute */

void
getTERM()
{
	/* Check if 101- or 102-key keyboard is installed.
	 * This test is apparently unreliable, so we allow override.
	 * Courtesy of Ralph Brown's interrupt list.
	 */
	char _far *kbd_stat_byte3 = (char _far *)0x00400096UL;
	enhanced_keybrd = (0x10 & *kbd_stat_byte3) != 0;
	pcSetTerm();
}

private void
setcolor(attr)
BYTE attr;
{
	c_attr = attr;
}

private void
set_cur()
{
	union REGS vr;

	vr.h.ah = VBS_set_cursor_position;
	vr.h.bh = 0;	/* video page 0 */
	vr.h.dl = c_col;
	vr.h.dh = c_row;
	VideoBIOS(&vr);
}

private void
get_cur()
{
	union REGS vr;

	vr.h.ah = VBS_get_cursor_position_and_size;
	vr.h.bh = 0;	/* video page 0 */
	VideoBIOS(&vr);
	c_col = vr.h.dl;
	c_row = vr.h.dh;
}

private BYTE
chpl()
{
	union REGS vr;

	vr.h.ah = VBS_get_current_video_state;
	VideoBIOS(&vr);
	return vr.h.ah;
}

#define cur_mov(r, c)	{ c_row = (r); c_col = (c); set_cur(); }

private void
scr_win(op, no, ur, lr)
int op, no, ur, lr;
{
	union REGS vr;

	vr.h.ah = op;	/* scroll window up or down */
	vr.h.al = no;	/* number of rows to scroll */

	vr.h.ch = ur;	/* upper row */
	vr.h.cl = 0;	/* left column */
	vr.h.dh = lr;	/* lower row */
	vr.h.dl = CO-1;	/* right column */

	vr.h.bh = c_attr;
	VideoBIOS(&vr);
}

void
i_lines(top, bottom, num)
int top, bottom, num;
{
	scr_win(VBS_scroll_window_down, num, top, bottom);
}

void
d_lines(top, bottom, num)
int top, bottom, num;
{
	scr_win(VBS_scroll_window_up, num, top, bottom);
}

void
clr_page()
{
	SO_off();
	/* Note: VBS_scroll_window_up with a count of 0 clears the screen! */
	scr_win(VBS_scroll_window_up, 0, 0, ILI);
	cur_mov(0, 0);
}

private void
ch_out(c, n)
BYTE c, n;
{
	union REGS vr;

	vr.h.ah = VBS_write_character_and_attribute;
	vr.h.al = c;
	vr.h.bl = c_attr;
	vr.h.bh = 0;	/* video page 0 */
	vr.x.cx = n;
	VideoBIOS(&vr);
}

void
clr_eoln()
{
	ch_out(' ', CO-c_col);
}

/* Video mode setting derived from code posted to comp.os.msdos.programmer
 * by Joe Huffman 1990 August 15 (found on SIMTEL in msdos/screen/vidmode.zip)
 */

private BYTE
lpp()
{
	union REGS vr;
	int	lines;

	vr.x.ax = VBSF_get_font_information;
	vr.h.bh = 0;	/* we don't care which pointer we get back */
	vr.h.dl = 0;	/* default, if BIOS doesn't know how to this */
	VideoBIOS(&vr);
	lines = vr.h.dl;	/* number of last line on screen */
	switch (lines) {
	default:
		return lines + 1;
	case 25:
	case 28:
	case 43:
	case 50:
		return lines;	/* IBM EGA BUG!*/
	case 0:
		return 25;	/* Who knows?  Just a guess. */
	}
}

/* discover current video attribute */

private void
get_c_attr()
{
	union REGS vr;

	vr.h.dl = ' ';	/* write out a SPace, using DOS */
	vr.h.ah = 0x02;
	int86(0x21, &vr, &vr);

	vr.h.ah = VBS_TTY_character_output;	/* backspace over it, using BIOS */
	vr.h.al = BS;
	vr.h.bh = 0;	/* page number 0 */
	VideoBIOS(&vr);

	vr.h.ah = VBS_read_character_and_attribute;	/* find out attribute */
	VideoBIOS(&vr);
	c_attr = vr.h.ah;
}

/* codes for selecting scan lines for alpha mode (service 0x12, function 0x30) */

#define EGA200	0
#define EGA350	1
#define EGA400	2

/* codes for selecting ROM font (function code for service 0x11)
 * Notes from Ralf Brown's Interrupt List:
 *	  The routines called with AL=1xh are designed to be called only
 *	  immediately after a mode set and are similar to the routines called
 *	  with AL=0xh, except that:
 *	      Page 0 must be active.
 *	      Bytes/character is recalculated.
 *	      Max character rows is recalculated.
 *	      CRT buffer length is recalculated.
 *	      CRTC registers are reprogrammed as follows:
 *		     R09 = bytes/char-1 ; max scan line (mode 7 only)
 *		     R0A = bytes/char-2 ; cursor start
 *		     R0B = 0		; cursor end
 *		     R12 = ((rows+1)*(bytes/char))-1 ; vertical display end
 *		     R14 = bytes/char	; underline loc
 *			   (*** BUG: should be 1 less ***)
 *	the current block specifiers may be determined with INT 10/AH=1Bh,
 *	  looking at offsets 2Bh and 2Ch of the returned data (VGA only)
 */

#define	EGA8x8	0x12	/* not 0x02 or 0x23 */
#define	EGA8x14	0x11	/* not 0x01 or 0x22 */
#define	EGA8x16	0x14	/* not 0x04 or 0x24 */

private void
EGAsetup(scanlines, font)
BYTE	scanlines;
BYTE	font;
{
	union REGS vr;
	vr.h.ah = VBS_select_active_display_page;
	vr.h.al = 0;	/* page 0 */
	VideoBIOS(&vr);

	vr.h.ah = 0x12;	/* request EGA information */
	vr.h.bl = 0x10;	/* function number */
	vr.x.cx = 0x0000;
	VideoBIOS(&vr);

	if (vr.x.cx != 0) {
		/* the display seems to be EGA or better */
		vr.h.ah = 0x12;	/* select scan lines for alpha mode */
		vr.h.al = scanlines;
		vr.h.bl = 0x30;
		VideoBIOS(&vr);

		/* Note: bh is left over from VideoBIOS call *before* last! */
		if (vr.h.bh == 0)
			vr.x.ax = 0x0003;	/* monochrome */
		else
			vr.x.ax = 0x0007;	/* 80x25 color text */
		VideoBIOS(&vr);

		vr.h.ah = 0x11;	/* load ROM font */
		vr.h.al = font;
		vr.h.bl = 0;	/* into block 0 */
		VideoBIOS(&vr);
	}
	get_c_attr();
}

private bool
set_lines(lines)
int	lines;
{
	switch (lines) {
	case 25:
		EGAsetup(EGA400, EGA8x16);
		break;
	case 28:
		EGAsetup(EGA400, EGA8x14);
		break;
	case 43:
		EGAsetup(EGA350, EGA8x8);
		break;
	case 50:
		EGAsetup(EGA400, EGA8x8);
		break;
	default:
		return NO;
	}
	return YES;
}

private bool	pc_set = NO;
private int	unsetLI;

void
pcSetTerm()
{
	char	*t = getenv("TERM");

	if (!pc_set) {
		int	lines = lpp();

		unsetLI = lines;
		if (t != NULL) {
			if (stricmp(t, "ega25") == 0)
				lines = 25;
			else if (stricmp(t, "ega28") == 0)
				lines = 28;
			else if (stricmp(t, "ega43") == 0)
				lines = 43;
			else if (stricmp(t, "ega50") == 0)
				lines = 50;
		}
		if (lines != unsetLI && set_lines(lines))
			pc_set = YES;
	}
	CO = chpl();
	if (CO > MAXCOLS)
		CO = MAXCOLS;
	LI = lpp();
	ILI = LI - 1;
	get_cur();
}

void
ttsize()
{
}

void
pcUnsetTerm()
{
	if (pc_set) {
		pc_set = NO;
		(void) set_lines(unsetLI);
	}
}

private void
line_feed()
{
	if (++c_row > ILI) {
		c_row = ILI;
		scr_win(VBS_scroll_window_up, 1, 0, ILI);
	}
	set_cur();
}

#define BELL_P 0x61			/* speaker */
#define BELL_D 0x2dc			/* 550 hz  */
#define TIME_P 0x40			/* timer   */
#define TINI   182			/* 10110110b timer initialization */

void
dobell(n)	/* declared in term.h */
int	n;
{
	unsigned char	spkr_state = inp(BELL_P);

	/* ??? Should accesses to timer be run with interrupts disabled?
	 * It looks as if the timer would be in a bad state if a sequence
	 * of accesses is interrupted. -- DHR 1995 Sept.
	 */
	outp(TIME_P+3, TINI);
	outp(TIME_P+2, BELL_D&0xff);
	outp(TIME_P+2, BELL_D>>8);
	outp(BELL_P, spkr_state|3);		/* turn speaker on  */
	while (n-- > 0) {
#ifdef NEVER
		/* Control duration by counting half cycles of the audio tone.
		 * We detect a half-cycle boundary by noting when the high-order
		 * byte of the counter changes between zero and non-zero.
		 * This should be unaffected by CPU speed.
		 * We can't use the BIOS interval timer facility because
		 * I think it would use the timer channel we're already using.
		 */
		int	half_cycs = 200;	/* number of half-cycles to play */
		bool	hi_is_0 = NO;	/* detect zero transitions; initial lie unimportant */

		for (;;) {
			(void) inp(TIME_P+2);	/* low-order counter 2 byte */
			if ((inp(TIME_P+2) == 0) != hi_is_0) {
				hi_is_0 = !hi_is_0;
				if (--half_cycs <= 0)
					break;
			}
		}
#else
		unsigned int i = 0x8888;	/* a CPU-speed dependent duration */

		do ; while (--i > 0);
#endif
	}
	outp(BELL_P, spkr_state);
}

/* scr_putchar: put char on screen.  Declared in fp.h */

#ifdef USE_PROTOTYPES
/* char is subject to default argument promotions */
void
scr_putchar(char c)
#else
void
scr_putchar(c)
char c;
#endif
{
	switch (c) {
	case LF:
		line_feed();
		break;
	case CR:
		c_col = 0;
		set_cur();
		break;
	case BS:
		if (c_col > 0)
			c_col--;
		set_cur();
		break;
	case CTL('G'):	/* ??? is this ever used? */
		dobell(1);
		break;
	default:
		ch_out((c), 1);
		if (++c_col > CO-1) {
			c_col = 0;
			line_feed();
		}
		set_cur();
		break;
	}
}

/* No cursor optimization on an IBMPCDOS, this simplifies things a lot.
 * Think about it: it would be silly!
 */

void
Placur(line, col)
int line,
    col;
{
	cur_mov(line, col);
	CapCol = col;
	CapLine = line;
}

private bool
	doing_so = NO,
	doing_us = NO;

private void
doattr()
{
	setcolor((doing_so? Mlattr : Txattr) ^ (doing_us? Hlattr : 0));
}

void
SO_effect(f)
bool f;
{
	doing_so = f;
	doattr();
}

void
US_effect(f)
bool	f;
{
	doing_us = f;
	doattr();
}

#endif /* IBMPCDOS */
