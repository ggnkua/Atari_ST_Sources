/*
 * The video driver for the Atari ST
 */

/* This driver does not deal with multiple consoles and parameter passing
   through tp. Also the tty struct fields row and column are not maintained.

   Multiple console implemented. Also some code cleanups and speedups have
   been done. Cursor control is now local to this file. There are other parts
   of this source, such as the escape sequence handling and the character
   painting functions, which need a cleanup. F.e. the pc-minix specific
   fields should be deleted from tty_struct, and a pointer to the virterm
   structure should be inserted there.			K.-U. Bloem, --kub

   Added/corrected VT100 compatibility - Now looks _almost_ exactly like a
   DEC VT100 to an application.
   Added scroll regions, tab set/clear, underline, disable/enable cursor.
   Added escape code 'esc[24~' to set 24-line mode.
     "     "     "   'esc[25~' to set 25-line mode.
   Still no 132 column, or graphics characters, or device status reports,
   or double height/width lines, or vt52 mode.
   Otherwise, it passes all tests in vttest.c
   				jdoss@jmdst.lonestar.org - December, 1991

   Added BOLD code, and re-worked paint() function back to one generic
   function, rather than resolution-specific functions.
      				jdoss@jmdst.lonestar.org - February, 1992

*/

#include "kernel.h"
#if (MACHINE == ATARI)
#include <termios.h>
#include <sgtty.h>
#include <minix/com.h>

#include "staddr.h"
#include "stvideo.h"
#include "stsound.h"

#include "proc.h"
#include "tty.h"
#include "stvdu.h"

PRIVATE struct virterm virterm[NR_CONS];

char statline[] =
"- - - - - - - - - - - - - - -  24 line mode  - - - - - - - - - - - - - - - - - -";

/* This is a pointer to the currently displayed virtual console device. The
 * keyboard driver needs to know to which tty it must deliver keys from the
 * keyboard. Moreover the kernel sometimes needs to output some text. This
 * should go to the current console device, since things may block after
 * text output.
 */

PRIVATE struct tty *cur_tty = &tty_table[0];

/* the next four variables are for synchronising the setting of the
   video registers with the vertical blanking. Not synchronising 
   gives problems on Mega STe's */
unsigned int vid_res;
unsigned short vid_rgb [16];
char *vid_ram;
int progvdu = 0; /* make 1 to setup video hardware at next vbl */

/* forward declarations for internal procedures */

/* general char output driver and escape sequence handling */
FORWARD _PROTOTYPE( void vdu_char, (struct tty *tp, int c)		);
FORWARD _PROTOTYPE( void vductrl, (struct tty *tp,
			struct virterm *v, int c)			);
FORWARD _PROTOTYPE( void vduesc, (struct tty *tp,
			struct virterm *v, int c)			);
FORWARD _PROTOTYPE( void vduansi, (struct tty *tp,
			struct virterm *v, int c)			);
FORWARD _PROTOTYPE( int vduparam, (struct virterm *v)			);
/* character printing and cursor management */
FORWARD _PROTOTYPE( void vducursor, (struct virterm *v, int onoff)	);
FORWARD _PROTOTYPE( void paint, (struct virterm *v, int c)		);
FORWARD _PROTOTYPE( void beep, (void)					);
FORWARD _PROTOTYPE( void moveto, (struct virterm *v, int r, int c)	);
/* screen modifications apart from char printing */
FORWARD _PROTOTYPE( void vscroll, (struct virterm *v,
			int up, int rl, int ru, int n)			);
FORWARD _PROTOTYPE( void hscroll, (struct virterm *v,
			int rt, int r, int cl, int cu, int n)		);
FORWARD _PROTOTYPE( void clrarea, (struct virterm *v,
			int rl, int cl, int ru, int cu)			);
FORWARD _PROTOTYPE( void clrlines, (struct virterm *v, int r, int n)	);
FORWARD _PROTOTYPE( void clrchars, (struct virterm *v, int r, int c, int n) );

/* Fast cursor positioning macroes for selected directions [see moveto()] */

#define	MOVERT(v)	if ((v)->ccol < NCOL-1) {			\
				(v)->ccol++; (v)->curs++;		\
				if (!(v)->mono && !((v)->ccol & 1))	\
					(v)->curs += 2;			\
			} else						\
				if ((v)->wrap) (v)->ccol = NCOL;

#define	MOVELT(v)	if ((v)->ccol > 0) {				\
				if ((v)->ccol == NCOL) (v)->ccol--;	\
				(v)->ccol--; (v)->curs--;		\
				if (!(v)->mono && ((v)->ccol & 1))	\
					(v)->curs -= 2;			\
			}

#define	MOVEDN(v)	if (((v)->crow < (v)->botscroll) ||		\
			((v)->crow > (v)->botscroll && (v)->crow < (v)->nrow -1 )){ \
				(v)->crow++; (v)->curs += (v)->bytr;	\
				if ((v)->ccol == NCOL) (v)->ccol--;	\
			}
#define	MOVEUP(v)	if (((v)->crow > (v)->topscroll) ||		\
			((v)->crow < (v)->topscroll && (v)->crow > 0 )){ \
				(v)->crow--; (v)->curs -= (v)->bytr;	\
				if ((v)->ccol == NCOL) (v)->ccol--;	\
			}
#define	MOVECR(v)	{ if ((v)->ccol == NCOL) (v)->ccol--;		\
			  if ((v)->mono)				\
				(v)->curs -= (v)->ccol;			\
			  else						\
				(v)->curs -= ((v)->ccol<<1)-((v)->ccol&1); \
			(v)->ccol = 0; }

/*===========================================================================*
 *				flush					     *
 *===========================================================================*/
PUBLIC void flush(tp)
register struct tty *tp;
{
/* There is really no semantic for flush() on 68000. The vdu driver does not
 * store characters in tp->tty_ramqueue, so simply return here.
 */

  return;
}

/*===========================================================================*
 *				console					     *
 *===========================================================================*/
PUBLIC void console(tp)
register tty_t *tp;		/* tells which terminal is to be used */
{
/* Copy as much data as possible to the output queue, then start I/O.  On
 * memory-mapped terminals, such as the IBM console, the I/O will also be
 * finished, and the counts updated.  Keep repeating until all I/O done
 * or output is suspended.
 */
  register struct virterm *v = (struct virterm *) tp->tty_priv;
  register int count = 0;
  register char *tbuf;
  char buf[64];
  phys_bytes user_phys;

  /* Check quickly for nothing to do, so this can be called often without
   * unmodular tests elsewhere.
   */
  if ((count = tp->tty_outleft) == 0 || tp->tty_inhibited) return;

  vducursor(v, 0);

  /* Copy the user bytes to buf[] for decent addressing. Loop over the
   * copies, since the user buffer may be much larger than buf[].
   */
  do {
	if (count > sizeof(buf)) count = sizeof(buf);
	user_phys = proc_vir2phys(proc_addr(tp->tty_outproc), tp->tty_out_vir);
	phys_copy(user_phys, vir2phys(buf), (phys_bytes) count);
	tbuf = buf;

	/* Update terminal data structure. */
	tp->tty_out_vir += count;
	tp->tty_outcum += count;
	tp->tty_outleft -= count;
	do {
		vdu_char(tp, *tbuf++);
	} while (--count != 0);
  } while ((count = tp->tty_outleft) != 0 && !tp->tty_inhibited);

  vducursor(v, 1);

  /* Reply to the writer if all output is finished. */
  if (tp->tty_outleft == 0) {
	tty_reply(tp->tty_outrepcode, tp->tty_outcaller, tp->tty_outproc,
							tp->tty_outcum);
	tp->tty_outcum = 0;
  }
}

/*===========================================================================*
 *				out_char				     *
 *===========================================================================*/
PUBLIC void out_char(tp, c)
tty_t *tp;			/* virtual terminal to use */
char c;				/* character to be output */
{
/* send character to VDU, with cursor control, for kernel putc() call.
 */
  register struct virterm *v = (struct virterm *) tp->tty_priv;

  vducursor(v, 0);
  vdu_char(tp, c);
  vducursor(v, 1);
}

/*===========================================================================*
 *				vdu_char				     *
 *===========================================================================*/
PRIVATE void vdu_char(tp, c)
tty_t *tp;			/* virtual terminal to use */
register char c;		/* character to be output */
{
/* send character to VDU, collecting escape sequences
 */
  register struct virterm *v = (struct virterm *) tp->tty_priv;

  if (v->next == (char *)0) {
	if ((c & ~0x1F) == 0) {		/* control character */
		vductrl(tp, v, c);
		return;
	} else if (c != 0x7F) {
		if (c & 0x80)		/* map to font char 00 - 1F */
			c &= 0x1F;
		/* check if margin wrap is needed */
		if ( v->ccol == NCOL && v->wrap == TRUE ) {
			MOVECR(v);
			if (v->crow == v->botscroll)
				vscroll(v, FALSE, (v)->topscroll, v->botscroll, 1);
			else
				MOVEDN(v);
		}
		paint(v, c);	/* print normal char to screen */
		MOVERT(v);
		return;
	} else				/* do nothing on DEL */
		return;
  }
  if (v->next == v->vbuf && c == '[') {	/* ANSI esc sequence detected */
	*v->next++ = c;
	return;
  }
  if (c >= 060 && (v->next == v->vbuf || v->vbuf[0] != '[')) {
	vduesc(tp, v, c);		/* end of non-ANSI escape sequence */
	v->next = 0;
	return;
  }
  if (c >= 0100) {			/* end of ANSI escape sequence */
	vduansi(tp, v, c);
	v->next = 0;
	return;
  }
  if (c == '\030' || c == '\032') {	/* CAN or SUB cancels esc sequence */
	v->next = 0;
	/* no error char */
	return;
  }
  if ((c & ~0x1F) == 0) {	/* control character in an escape */
	vductrl(tp, v, c);	/* process it, do not save in vbuf */
	return;
  }
  if (v->next <= &v->vbuf[sizeof(v->vbuf)])
	*v->next++ = c;			/* record part of esc sequence */
}

/*
 * control character
 */
PRIVATE void vductrl(tp, v, c)
register tty_t *tp;
register struct virterm *v;
char c;
{
  switch (c) {
  case 000: /* NUL: ignore */
  	return;
  case 005: /* ENQ: Transmit answerback */
  	return;
  case 007: /* BEL */
	beep();
	return;
  case 010: /* BS */
	MOVELT(v);
	return;
  case 011: /* HT */
	do {
#ifdef ALLDONE
		if ((tp->tty_mode & XTABS) == XTABS)
#endif /* ALLDONE */
			paint(v, ' ');
		MOVERT(v);
	} while (v->ccol < NCOL-1 && (v->tabs[v->ccol] == 0));
	return;
  case 012: /* LF */
#ifdef ALLDONE
	if ( !(tp->tty_mode & RAW) && (tp->tty_mode & CRMOD))
#endif /* ALLDONE */
		MOVECR(v);
	/*FALLTHROUGH*/
  case 013: /* VT */
  case 014: /* FF */
	if (v->crow == v->botscroll)
		vscroll(v, FALSE, v->topscroll, v->botscroll, 1);
	else
		MOVEDN(v);
	return;
  case 015: /* CR */
	MOVECR(v);
	return;
  case 016: /* SO: select G1 character set */
  	return;
  case 017: /* SI: select G0 character set */
  	return;
  case 033: /* ESC */
	v->next = v->vbuf;
	return;
  default:
	return;
  }
}

/*
 * execute non-ANSI escape sequence
 */
PRIVATE void vduesc(tp, v, c)
tty_t *tp;
register struct virterm *v;
char c;
{
  int qr, qc;
  
  if (v->next >= &v->vbuf[sizeof(v->vbuf)-1])
	return;
  *v->next = (char)c;
  switch (v->vbuf[0]) {
  case '8': /* DECRC: restore cursor */
	v->ccol = v->savccol;
	v->crow = v->savcrow;
	v->origmode = v->savorigmode;
	v->attr = v->savattr;
	moveto(v, v->crow, v->ccol);
	return;
  case '7': /* DECSC: save cursor */
	v->savccol = v->ccol;
	v->savcrow = v->crow;
	v->savorigmode = v->origmode;
	v->savattr = v->attr;
	return;
  case '=': /* DECKPAM: keypad application mode */
	v->vkeypad = TRUE;
	if (tp == cur_tty) vduswitch(tp);
	return;
  case '>': /* DECKPNM: keypad numeric mode */
	v->vkeypad = FALSE;
	if (tp == cur_tty) vduswitch(tp);
	return;
  case 'E': /* NEL: next line */
	MOVECR(v);
	/*FALLTHROUGH*/
  case 'D': /* IND: index */
	if (v->crow == v->botscroll)
		vscroll(v, FALSE, v->topscroll, v->botscroll, 1);
	else
		MOVEDN(v);
	return;
  case 'M': /* RI: reverse index */
	if (v->crow == v->topscroll)
		vscroll(v, TRUE, v->topscroll, v->botscroll, 1);
	else
		MOVEUP(v);
	return;
  case 'H': /* HTS: Hoizontal tab set */
  	v->tabs[v->ccol] = 1;
  	return;
  case 'c': /* RIS: reset to initial state */
	vduinit(tp);
	/* vduinit() calls vduswitch if neccessary */
	return;
  case '#': /* double height/width or alignment */
	switch (v->vbuf[1]) {
		case '8' :	/* DECALN - alignment screen */
			clrarea(v, 0, 0, v->nrow-1, NCOL-1);  /* clear screen */
			v->attr &= ~(DISPLAY_ATTRIBS);
			for (qr = 0; qr < v->nrow; qr++) {
				for (qc = 0; qc < NCOL; qc++) {
					moveto(v, qr, qc);
					paint(v, 'E');
				}
			}
			return;
		case '3' :	/* DECDHL - double height top */
		case '4' :	/* DECDHL - double height bottom */
		case '6' :	/* DECDWL - double width line */
		case '5' :	/* DECSWL - single width line */
		default:
			return;
	}
	return;
  case '(': /* SCS - select G0 character set */
	switch (v->vbuf[1]) {
		case 'A' :	/* UK char set as G0 */
		case 'B' :	/* US char set as G0 */
		case '0' :	/* Graphics char set as G0 */
		default:
			return;
	}
	return;
  case ')': /* SCS - select G1 character set */
	switch (v->vbuf[1]) {
		case 'A' :	/* UK char set as G1 */
		case 'B' :	/* US char set as G1 */
		case '0' :	/* Graphics char set as G1 */
		default:
			return;
	}
	return;
  case 'N': /* SS2 - select G2 char set for 1 character */
  case 'O': /* SS3 - select G3 char set for 1 character */
  default:
	return;
  }
}

/*
 * execute ANSI escape sequence
 */
PRIVATE void vduansi(tp, v, c)
tty_t *tp;
register struct virterm *v;
char c;
{
  static unsigned colors[] = {		/* color table for ESC [ m */
	RGB_BLACK,
	RGB_RED,
	RGB_GREEN,
	RGB_YELLOW,
	RGB_BLUE,
	RGB_MAGENTA,
	RGB_CYAN,
	RGB_WHITE,
	RGB_LGREY,
	RGB_DGREY,
  };
  register int n, m, dec_private;	/* used for escape sequence params */
  unsigned char tmp_attr;
  
  if (v->next >= &v->vbuf[sizeof(v->vbuf)])
	return;
  *v->next = 0;				/* prepare for parameter scanning */
  dec_private = 0;
  v->next = &v->vbuf[1];
  if ( v->vbuf[1] == '?' ) {
  	dec_private = 1;
  	v->next++;
  }
  n = vduparam(v);			/* all but one sequence use this */
  m = (n <= 0 ? 1 : n);

  switch (c) {
  case 'A': /* CUU: cursor up */
	while (m--) MOVEUP(v);
	return;
  case 'B': /* CUD: cursor down */
	while (m--) MOVEDN(v);
	return;
  case 'C': /* CUF: cursor forward */
	while (m--) MOVERT(v);
	return;
  case 'D': /* CUB: cursor backward */
	while (m--) MOVELT(v);
	return;
  case 'H': /* CUP: cursor position */
  case 'f': /* HVP: horizontal and vertical position */
	m = vduparam(v);
	n = (n <= 0 ? 1 : (n > v->nrow ? v->nrow : n)) - 1;
	m = (m <= 0 ? 1 : (m > NCOL    ? NCOL    : m)) - 1;
	if ( v->origmode ) {	/* adjust for origin mode */
		n = n + v->topscroll;
		if ( n > v->botscroll )
			n = v->botscroll;
	}
	moveto(v, n, m);
	return;
  case 'r': /* DECSTBM: set top and bottom of scroll region */
	m = vduparam(v);
	n = (n <= 0 ? 1 : n ) - 1;
	m = (m <= 0 ? v->nrow : m ) - 1;
	if ( n < m && m < v->nrow ) { /* reasonable margins ? */
		v->topscroll = n;
		v->botscroll = m;
		moveto(v, v->topscroll, 0);
	} else {		/* no go - set margins to the whole screen */
		v->topscroll = 0;
		v->botscroll = v->nrow - 1;
	}
	return;
  case 'J': /* ED: erase in display */
	if	(n <= 0)   clrarea(v, v->crow, v->ccol, v->nrow-1, NCOL-1);
	else if (n == 1)   clrarea(v, 0, 0, v->crow, v->ccol);
	else if (n == 2)   clrarea(v, 0, 0, v->nrow-1, NCOL-1);
	return;
  case 'K': /* EL: erase in line */
	if	(n <= 0)   clrchars(v, v->crow, v->ccol, NCOL - v->ccol);
	else if (n == 1)   clrchars(v, v->crow, 0, v->ccol + 1);
	else if (n == 2)   clrchars(v, v->crow, 0, NCOL);
	return;
#ifdef NEEDED
  case 'n': /* DSR: device status report */
	if (m == 6) {
		kbdput('\033', tp->tty_line);
		kbdput('[', tp->tty_line);
		n = v->crow+1;
		if (n >= 10) kbdput(n/10, tp->tty_line);
		kbdput(n%10, tp->tty_line);
		kbdput(';', tp->tty_line);
		n = v->ccol+1;
		if (n >= 10) kbdput(n/10, tp->tty_line);
		kbdput(n%10, tp->tty_line);
		kbdput('R', tp->tty_line);
	}
	else if (m == 5)
	{
		kbdput('\033', tp->tty_line);
		kbdput('[', tp->tty_line);
		kbdput('0', tp->tty_line);
		kbdput('n', tp->tty_line);
	}
	return;
  case 'c': /* DA: device attributes */
	if (n <= 0)
		kbdput('\033', tp->tty_line);
		kbdput('[', tp->tty_line);
		kbdput('?', tp->tty_line);
		kbdput('1', tp->tty_line);
		kbdput(';', tp->tty_line);
		kbdput('2', tp->tty_line);
		kbdput('c', tp->tty_line);
	return;
#endif
  case 'm': /* SGR: set graphic rendition */
	do {
		if (n <= 0)			v->attr &= ~DISPLAY_ATTRIBS;
		else if (n == 1)		v->attr |= BOLD;
		else if (n == 4)		v->attr |= UNDERLINE;
		else if (n == 7)		v->attr |= REVERSE;
		else if (n == 22)		v->attr &= ~BOLD;
		else if (n == 24)		v->attr &= ~UNDERLINE;
		else if (n == 27)		v->attr &= ~REVERSE;
		else if (n >= 30 && n <= 39)	v->vrgb[1] = colors[n - 30];
		else if (n >= 40 && n <= 49)	v->vrgb[0] = colors[n - 40];
	} while ((n = vduparam(v)) >= 0);
	if (tp == cur_tty) vduswitch(tp);
	return;
  case 'L': /* IL: insert line */
  	if ( v->crow <= v->botscroll && v->crow >= v->topscroll )
		vscroll(v, TRUE, v->crow, v->botscroll, m);
	return;
  case 'M': /* DL: delete line */
  	if ( v->crow <= v->botscroll && v->crow >= v->topscroll )
		vscroll(v, FALSE, v->crow, v->botscroll, m);
	return;
  case '@': /* ICH: insert char */
	hscroll(v, TRUE, v->crow, v->ccol, NCOL-1, m);
	return;
  case 'P': /* DCH: delete char */
	hscroll(v, FALSE, v->crow, v->ccol, NCOL-1, m);
	return;
  case 'g': /* TBC: Tabulation clear */
  	if ( n <= 0 )	v->tabs[v->ccol] = 0;	/* clear a single tab */
	/* clear all tabs */
  	else if ( n == 3 ) for(m = 0; m < NCOL; m++) v->tabs[m] = 0;
  	return;
  case 'h': /* SM: set mode */
	if (dec_private) {
	    do {
	    	switch(n) {
	    	    case 1:	/* DECCKM - set cursor key application mode */
			v->vapmode = TRUE;
			break;
		    case 3:	/* DECCOLM - set 132 column mode */
		    	break;
		    case 4:	/* DECSCLM - smooth scrolling */
		    	break;
		    case 5:	/* DECSCNM - reverse screen */
		    	v->vrgb[0] = DEFAULT_FORGRND;
		    	v->vrgb[1] = DEFAULT_BKGRND;
		    	break;
		    case 6:	/* DECOM - set origin mode in scroll region */
		    	v->origmode = TRUE;
			moveto(v, v->topscroll, 0);
		    	break;
		    case 7:	/* DECAWM - auto-wrap */
		    	v->wrap = TRUE;
		    	break;
		    case 8:	/* DECARM - auto-repeat */
		    	/* v->repeatmode = TRUE */
		    	break;
		    case 9:	/* DECINLM - interlace mode */
		    	break;
		    case 25:	/* DECTCEM - enable cursor */
		    	v->cursenable = TRUE;
			vducursor(v, 1);
			break;
		    default:
		    	break;
		}
	    } while ((n = vduparam(v)) >= 0);
	    if (tp == cur_tty) vduswitch(tp);
	}
	return;

  case 'l': /* RM: reset mode */
	if (dec_private) {
	    do {
	    	switch(n) {
	    	    case 1:	/* DECCKM - set cursor key cursor mode */
			v->vapmode = FALSE;
			break;
		    case 3:	/* DECCOLM - set 80 column mode */
		    	break;
		    case 4:	/* DECSCLM - jump scrolling */
		    	break;
		    case 5:	/* DECSCNM - normal screen */
		    	v->vrgb[0] = DEFAULT_BKGRND;
		    	v->vrgb[1] = DEFAULT_FORGRND;
		    	break;
		    case 6:	/* DECOM - reset origin mode */
		    	v->origmode = FALSE;
		    	moveto(v, 0, 0);
		    	break;
		    case 7:	/* DECAWM - auto-wrap */
		    	v->wrap = FALSE;
		    	break;
		    case 8:	/* DECARM - auto-repeat */
		    	/* v->repeatmode = FALSE */
		    	break;
		    case 9:	/* DECINLM - interlace mode */
		    	break;
		    case 25:	/* DECTCEM - disable cursor */
			vducursor(v, 0);
		    	v->cursenable = FALSE;
			break;
		    default:
		    	break;
		}
	    } while ((n = vduparam(v)) >= 0);
	    if (tp == cur_tty) vduswitch(tp);
	}
	return;

  case '~': /* Minix-ST specific escape sequence */
	/*
	 * Handle the following escape sequence:
	 *   ESC [ l;a;m;r;g;b '~'
	 * where
	 *   if l present:
	 *	16: 25 lines if mono
	 *	12: 33 lines if mono
	 *	 8: 50 lines if mono
	 *	24: 24 line screen (vt100 compatible)
	 *	25: 25 line screen
	 *   if a present:
	 *	attribute byte value (see paint())
	 *   if m present:
	 *	interpret r;g;b as colors for map register m
	 *	only assign color if r, g or b present
	 */
	if (v->mono) {		/* select mono font size */
	    if (n == 16) {			/* 25 lines */
		v->linc = 16;			/* 16 */
		v->nrow = M_LIN_SCR/16;		/* 25 */
		v->bytr = M_BYT_LIN*16;		/* 1280 */
		v->origmode = FALSE;
		v->topscroll = 0;
		v->botscroll = v->nrow - 1;
		moveto(v, v->nrow - 1, 0);
	    } else if (n == 12) {		/* 33 lines */
		v->linc = 12;			/* 12 */
		v->nrow = M_LIN_SCR/12;		/* 33 */
		v->bytr = M_BYT_LIN*12;		/* 960 */
		v->origmode = FALSE;
		v->topscroll = 0;
		v->botscroll = v->nrow - 1;
		moveto(v, v->nrow - 1, 0);
	    } else if (n == 8) {		/* 50 lines */
		v->linc = 8;			/* 8 */
		v->nrow = M_LIN_SCR/8;		/* 50 */
		v->bytr = M_BYT_LIN*8;		/* 640 */
		v->origmode = FALSE;
		v->topscroll = 0;
		v->botscroll = v->nrow - 1;
		moveto(v, v->nrow - 1, 0);
	    }
	}
	if (n == 24) {			/* 24 lines */
		v->nrow = 25;
		if (v->mono) {
			v->linc = 16;			/* 16 */
			v->bytr = M_BYT_LIN*16;		/* 1280 */
		}
		tmp_attr = v->attr;
		v->attr |= REVERSE;
		moveto(v, 24, 0);
		for (n = 0; n < NCOL; n++ ) {
			paint(v, statline[n]);
			MOVERT(v);
		}
		v->attr = tmp_attr;
		v->nrow = 24;
		v->origmode = FALSE;
		v->topscroll = 0;
		v->botscroll = v->nrow - 1;
		moveto(v, v->nrow - 1, 0);
	}
	if (n == 25) {			/* 25 lines */
		v->nrow = 25;
		if (v->mono) {
			v->linc = 16;			/* 16 */
			v->bytr = M_BYT_LIN*16;		/* 1280 */
		}
		v->origmode = FALSE;
		v->topscroll = 0;
		v->botscroll = v->nrow - 1;
		clrchars(v, v->nrow - 1, 0, NCOL);		
		moveto(v, v->nrow - 1, 0);
	}
	if ((n = vduparam(v)) >= 0)	/* attribute byte */
		v->attr = n & 0xFF;
	if ((n = vduparam(v)) >= 0) {	/* change a color */
		register short *w = (short *)&v->vrgb[n & 0x0F];

		if ((n = vduparam(v)) >= 0)
			*w = (*w & ~0x0700) | ((n & 7) << 8);
		if ((n = vduparam(v)) >= 0)
			*w = (*w & ~0x0070) | ((n & 7) << 4);
		if ((n = vduparam(v)) >= 0)
			*w = (*w & ~0x0007) | ((n & 7) << 0);
		if (tp == cur_tty) vduswitch(tp);
	}
	return;
  default:
	return;
  }
}

/*
 * compute next parameter out of ANSI sequence
 */
PRIVATE int vduparam(v)
register struct virterm *v;
{
  register char c;
  register int i;

  i = -1;
  c = *v->next++;
  if (c >= '0' && c <= '9') {
	i = 0;
	do {
		i *= 10;
		i += (c - '0');
		c = *v->next++;
	} while (c >= '0' && c <= '9');
  }

  /* test for empty parameter (counts as zero) */
  if (i == -1 && c == ';') i = 0;
  
  if (c != ';')
	v->next--;
  return(i);
}

/*===========================================================================*
 *				manipulate videoram 			     *
 *===========================================================================*/
/* The routines in this part are all quite cryptic, but are optimized for max
 * speed. --kub
 */

/*
 * clear part of screen between two points inclusive
 */
PRIVATE void clrarea(v, rl, cl, ru, cu)
struct virterm *v;
int rl, cl;
int ru, cu;
{
  if (++cu == NCOL) {
	cu = 0;
	ru++;
  }
  if (cl > 0 && rl < ru) {
	clrchars(v, rl, cl, NCOL-cl);
	cl = 0;
	rl++;
  }
  clrlines(v, rl, ru-rl);
  clrchars(v, ru, cl, cu-cl);
}

/*
 * scroll lines around on the screen. newly created lines are blanked out
 */
PRIVATE void vscroll(v, up, rl, ru, n)
register struct virterm *v;
int up;				/* flag: TRUE = scroll up rather then down */
int rl, ru, n;			/* lower and upper row affected, scroll count */
{
  register char *src, *dst;	/* pointers into the video mem */

  if (n <= 0) return;		/* safety first ... */
  if (n > ru-rl)
	n = ru-rl + 1;

  if (up) {
  	src = &v->vram[(ru-n) * v->bytr];
  	dst = &v->vram[ ru    * v->bytr];
	for (; ru >= rl+n; ru--) {
		phys_copy( (phys_bytes) src, (phys_bytes) dst,
			   (phys_bytes) v->bytr );
		src -= v->bytr; dst -= v->bytr;
	}
	clrlines(v, rl, n);
  } else {
	/* We are using phys_copy() to move all lines at once, but src and
	 * dest may overlap. Trust in phys_copy copying from low to high !
	 * Do not copy the last phys_byte using phys_copy since
	 * phys_copy may use movem and movem does one access beyond the
	 * end of the src dir, which may result in a bus error.
	 * clean way : for (; rl <= ru-n; rl++) phys_copy(...); (see above)
	 */
	register phys_bytes len = (phys_bytes) (ru-rl-n+1) * v->bytr
				- sizeof(phys_bytes);
	src = (char *)&v->vram[(rl+n) * v->bytr];
	dst = (char *)&v->vram[ rl    * v->bytr];
	phys_copy((phys_bytes)src, (phys_bytes)dst, len);
	src += len;
	dst += len;
	*((phys_bytes *)dst) = *((phys_bytes *)src);
	clrlines(v, ru-n+1, n);
  }
}

/*
 * clear lines from r to r+n-1.
 */
PRIVATE void clrlines(v, r, n)
register struct virterm	*v;
int r, n;
{
  register phys_bytes	p, i;

  if (n <= 0) return;

  /* The ST video chips enforce the screen to be on a 256 byte boundary. As
   * long as CLICK_SIZE is smaller than that we can use zeroclicks for the
   * operation. Otherwise use a normal, but slow loop for clearing.
   */
  p = (phys_bytes) &v->vram[r * v->bytr];
  i = (phys_bytes) v->bytr * n;

  if ((p & (CLICK_SIZE-1)) == 0 && (i & (CLICK_SIZE-1)) == 0) {
	zeroclicks( (phys_clicks) (p >> CLICK_SHIFT),
		    (phys_clicks) (i >> CLICK_SHIFT) );
  } else {
	register long *q = (long *)p;

	i = i >> 4;	/* 16 bytes per loop */
	while (i--) {
		*q++ = 0; *q++ = 0; *q++ = 0; *q++ = 0;
	}
  }
}

/* All the character copying/clearing functions need some cleanup ! */

/*
 * scroll chars around in one line. newly created chars are blanked out
 */
PRIVATE void hscroll(v, rt, r, cl, cu, n)
struct virterm *v;
int rt;				/* flag: TRUE = scroll right rather then left */
int r;				/* row number */
int cl, cu;			/* column scroll edges */
int n;				/* scroll count */
{
  char *src, *dst;		/* ptrs into video memory */

/*--------------------------------------------------
 * inline the character copy loop, for greater speed
 * (not really necessary; not called very often --kub)
 */
  register char *p, *q;		/* work pointers into vmem */
  register int nl;		/* line counter */
  register int bl = v->bytc;	/* line distance */
#define cpchr_m(s, d) {	p = (s); q = (d); nl = v->linc;	\
			do {				\
				*q = *p;		\
				p += bl; q += bl;	\
			} while (--nl != 0); }
#define cpchr_c(s, d) {	p = (s); q = (d); nl = v->linc;	\
			do {				\
				*q = *p; *(q+2) = *(p+2); \
				p += bl; q += bl;	\
			} while (--nl != 0); }
/*------------------------------------------------*/

  if (n <= 0) return;		/* safety checks */
  if (n > cu-cl)
	n = cu-cl + 1;

  if (rt) {
	if (v->mono) {
		src = &v->vram[(r * v->bytr) + (cu-n)];
		dst = &v->vram[(r * v->bytr) +  cu   ];
		while (cu >= cl + n) {
			cpchr_m(src, dst);
			src--; dst--;
			cu--;
		}
	} else {	/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
		src = &v->vram[(r * v->bytr) + ((cu-n) << 1) - ((cu-n) & 1)];
		dst = &v->vram[(r * v->bytr) + ( cu    << 1) - ( cu    & 1)];
		while (cu >= cl + n) {
			cpchr_c(src, dst);
			if (!((long)src & 1)) src -= 3; else src--;
			if (!((long)dst & 1)) dst -= 3; else dst--;
			cu--;
		}
	}
  } else {
	if (v->mono) {
		src = &v->vram[(r * v->bytr) + (cl+n)];
		dst = &v->vram[(r * v->bytr) +  cl   ];
		while (cl <= cu - n) {
			cpchr_m(src, dst);
			src++; dst++;
			cl++;
		}
	} else {	/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
		src = &v->vram[(r * v->bytr) + ((cl+n) << 1) - ((cl+n) & 1)];
		dst = &v->vram[(r * v->bytr) + ( cl    << 1) - ( cl    & 1)];
		while (cl <= cu - n) {
			cpchr_c(src, dst);
			if ((long)src & 1) src += 3; else src++;
			if ((long)dst & 1) dst += 3; else dst++;
			cl++;
		}
	}
  }
  clrchars(v, r, cl, n);
}

/*
 * clear n chars on pos (r,c).
 */
PRIVATE void clrchars(v, r, c, n)
register struct virterm *v;
int r, c, n;
{
  register char *p, *q;		/* ptr into video memory */
  register int nl;		/* scan lines per char */
  register int bl = v->bytc;	/* bytes per scan line */

  if (n > NCOL-c)
	n = NCOL-c;
  if (n <= 0) return;

  if (v->mono) {
	p = q = &v->vram[(r * v->bytr) + c];
	while (n != 0) {
		if ((c & 1) || (n < sizeof(long))) {
			nl = v->linc >> 1;	/* align to word boundary */
			do {
				*p = 0;	p += bl;
				*p = 0;	p += bl;
			} while (--nl != 0);
			p = ++q;
			n--;
		}
		while (n >= sizeof(long)) {	/* then clear 4 chars at once */
			nl = v->linc >> 1;
			do {
				*(long *)p = 0; p += bl;
				*(long *)p = 0; p += bl;
			} while (--nl != 0);
			p = (q += sizeof(long));
			n -= sizeof(long);
		}
	}
  } else {		/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
	p = q = &v->vram[(r * v->bytr) + (c << 1) - (c & 1)];
	while (n != 0) {		/* same as aboce, for color display */
		if ((c & 1) || (n < sizeof(long))) {
			nl = v->linc;
			do {
				*p = 0;
				*(p+2) = 0;
				p += bl;
			} while (--nl != 0);
			if ((long)q & 1)	/* bit plane alignment */
				p = (q += 3);
			else	p = ++q;
			n--;
		}
		while (n >= sizeof(long)) {
			nl = v->linc;
			do {
				*(long *)p = 0;
				*((long *)p+1) = 0;
				p += bl;
			} while (--nl != 0);
			p = (q += 2*sizeof(long));
			n -= sizeof(long);
		}
	}
  }
}

/*===========================================================================*
 *				vducursor				     *
 *===========================================================================*/
PRIVATE void vducursor(v, onoff)
register struct virterm *v;
int	onoff;
{
/* (un-)display the cursor. onoff may eventually later have more semantic,
 * such as blinking. At the moment, (non)zero means cursor off(on).
 */

  register char *vp;
  register int nl;
  register int bl;

  if (onoff == v->curmode) return;	/* no action if no change */
  if (v->cursenable == FALSE) return;  /* no action while cursor is inhibited */
  v->curmode = onoff;

  bl = v->bytc;
  if ((v->attr & INHIB_PLANE0) == 0) {		/* plane 0: color and mono */
	nl = v->linc >> 2;
	vp = v->curs;
	do {
		*vp = ~(*vp); vp += bl;
		*vp = ~(*vp); vp += bl;
		*vp = ~(*vp); vp += bl;
		*vp = ~(*vp); vp += bl;
	} while (--nl != 0);
  }
  if (v->mono == 0 && (v->attr & INHIB_PLANE1) == 0) {	/* plane 1: color */
	nl = v->linc >> 2;
	vp = v->curs + 2;
	do {
		*vp = ~(*vp); vp += bl;
		*vp = ~(*vp); vp += bl;
		*vp = ~(*vp); vp += bl;
		*vp = ~(*vp); vp += bl;
	} while (--nl != 0);
  }
}


/*===========================================================================*
 *				paint					     *
 *===========================================================================*/
PRIVATE void paint(v, c)
register struct virterm *v;
char c;
{
/* copy from font memory into video memory. Implementation tries to make
 * inner loop as fast as possible by repeating instructions rather then
 * loop over them.
 *
 */

  register unsigned char *fp;	/* ptr into font */
  register unsigned char *vp;	/* ptr into video memory */
  register int nl;		/* scan lines per char */
  register int bl = v->bytc;	/* bytes per scan line */
  register int bf;		/* bold flag */
  c &= 0x7F;

  /* find the chararacter in the appropriate font */
  if (v->linc == 16)
	fp = &font16[c<<4];
  else
  if (v->linc == 12)
	fp = &font12[c * 12];
  else
	fp = &font8[c<<3];

	
  if ((v->attr & INHIB_PLANE0) == 0) {		/* plane 0: color and mono */
	vp =  (unsigned char *)v->curs;
	nl = v->linc >> 2;
	bf = v->attr & BOLD_PLANE0;
	if (v->attr & REV_PLANE0) do {	/* reverse image */
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
	} while (--nl != 0);
	else do {			/* normal (not reversed) */
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
	} while (--nl != 0);
	if ( v->attr & UL_PLANE0 ) {
		vp -= bl;
		*vp = (v->attr & REV_PLANE0) ? 0x00 : 0xff;
	}
	fp -= v->linc;

  }


  if (v->mono == 0 && (v->attr & 8) == 0) {	/* plane 1: color */
	vp =  (unsigned char *)v->curs + 2;
	nl = v->linc >> 2;
	bf = v->attr & BOLD_PLANE1;
	if (v->attr & REV_PLANE1) do {	/* reverse image */
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
		*vp = ~(bf ? *fp | (*fp++>>1) : *fp++); vp += bl;
	} while (--nl != 0);
	else do {			/* normal (not reversed) */
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
		*vp = bf ? *fp | (*fp++>>1) : *fp++; vp += bl;
	} while (--nl != 0);
	if ( v->attr & UL_PLANE1 ) {
		vp -= bl;
		*vp = (v->attr & REV_PLANE1) ? 0x00 : 0xff;
	}
  }
}


/*===========================================================================*
 *				beep					     *
 *===========================================================================*/
PRIVATE void beep()
{
/* ring the console bell. This is independent from virtual consoles, just
 * because ringing the bell is an alarm signal for the user. He can then
 * switch to the appropriate virtual terminal and see what has happened.
 */

  register int	i, s;
  static char	sound[] = {
	0xA8,0x01,0xA9,0x01,0xAA,0x01,0x00,
	0xF8,0x10,0x10,0x10,0x00,0x20,0x03
  };

  s = lock();
  for (i = 0; i < sizeof(sound); i++) {
	SOUND->sd_selr = i;
	SOUND->sd_wdat = sound[i];
  }
  restore(s);
}

/*===========================================================================*
 *				moveto					     *
 *===========================================================================*/
PRIVATE void moveto(v, r, c)
register struct virterm *v;
int r, c;
{
/* move cursor to another position. The index operation to v->vram costs time
 * due to the multiplication, thus use the quick-and-dirty macros for simple
 * moves.
 */

  if (r < 0 || r >= v->nrow || c < 0 || c >= NCOL)
	return;
  if (v->origmode && (r < v->topscroll || r > v->botscroll ))
  	return;
  v->crow = r;
  v->ccol = c;

  if (v->mono)
	v->curs = &v->vram[(r * v->bytr) + c];
  else				/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
	v->curs = &v->vram[(r * v->bytr) + (c << 1) - (c & 1)];
}

/*===========================================================================*
 *				vduswitch				     *
 *===========================================================================*/
PUBLIC void vduswitch(tp)
struct tty *tp;
{
/* switch to another virtual console. The keyboard driver selects a new
 * virtual console by handling some special alt-key sequences. This procedure
 * is internally used to make changes to the current console visible. It's the
 * only place where keyboard variables and video controller are changed.
 */

  register struct virterm	*v = (struct virterm *) tp->tty_priv;

  keypad = v->vkeypad;			/* keyboard initialization */
  app_mode = v->vapmode;

  vdusetup((unsigned int)(v->vres), v->vram, v->vrgb);

  cur_tty= tp;
}

/*===========================================================================*
 *				vdusetup				     *
 *===========================================================================*/
PUBLIC void vdusetup(vres, vram, vrgb)
  unsigned int vres;
  char *vram;
  unsigned short *vrgb;
{
/* This routine prepares the video hardware programming. Doing it straight
 * away will often cause strange visual effects on the Mega-STe. It's safer
 * (and quite harmless for the other models) to wait until the next Vertical
 * Blank interrupt.
 */
  int i;

  while (progvdu) ;	/* Unlikely, but not impossible. wait a bit here */

  vid_res = vres;
  vid_ram = vram;
  for (i = 0; i < 16; i++)
	vid_rgb [i] = vrgb [i];

  progvdu = 1;
}

/*===========================================================================*
 *				vbl					     *
 *===========================================================================*/
PUBLIC void vbl()
{
/* handle the Vertical-Blank interrupt. This routine should be called only
 * when needed; namely when the video hardware needs reprogramming.
 */
  register int i;

  VIDEO->vd_st_res = vid_res;		/* screen resolution */
#if (ATARI_TYPE == DETECT_TYPE)
  if (atari_type != ST)
	VIDEO->vd_raml = (phys_bytes) vid_ram;	/* STe extra */
  VIDEO->vd_ramm = (phys_bytes) vid_ram >> 8; /* screen image address */
  VIDEO->vd_ramh = (phys_bytes) vid_ram >> 16;
#else
#if (ATARI_TYPE != ST)		/* ST does not have raml register */
  VIDEO->vd_raml = (phys_bytes) vid_ram;	/* STe extra */
#endif /* ATARI_TYPE == ST */
  VIDEO->vd_ramm = (phys_bytes) vid_ram >> 8; /* screen image address */
  VIDEO->vd_ramh = (phys_bytes) vid_ram >> 16;
#endif /* ATARI_TYPE == DETECT_TYPE */

  for (i = 0; i < 16; i++)		/* color table */
	VIDEO->vd_st_rgb[i] = vid_rgb[i];
/*  VIDEO->vd_loff = 0;
  VIDEO->vd_ste_hscroll = 0;*/
  progvdu = 0;
}

/*===========================================================================*
 *				vduinit					     *
 *===========================================================================*/
PUBLIC void vduinit(tp)
struct tty *tp;
{
/* Initialize a virtual console. This routine is not only called during system
 * startup, thus be careful with memory allocation. Don't allocate if that has
 * already been done. All other fields may be safely overwritten. Make changes
 * visible if they occur on the current virtual console.
 */

  register struct virterm	*v = (struct virterm *) tp->tty_priv;
  unsigned long	p;
  int tabpos;

  VIDEO->vd_st_res = RES_HIGH;
#if (ATARI_TYPE == TT)
  VIDEO->vd_tt_res = 0x200;
  VIDEO->vd_tt_rgb[254] = 0;
  VIDEO->vd_tt_rgb[255] = 0xfff;
#endif /* ATARI_TYPE == TT */

  if (VIDEO->vd_st_res & RES_HIGH) {
	v->vres = RES_HIGH;
	v->mono = 1;
	v->linc = FONTM;		/* 16 (or 8) */
	v->bytc = M_BYT_LIN;		/* 80 */
	v->nrow = M_LIN_SCR/FONTM;	/* 25 (or 50) */
	v->bytr = M_BYT_LIN*FONTM;	/* 1280 (or 640) */
	v->attr = 0;			/* display mono plane */
	v->vrgb[0] = RGB_BLACK;		/* background */
  } else {
	v->vres = RES_MID;
	v->mono = 0;
	v->linc = FONTC;		/* 8 */
	v->bytc = C_BYT_LIN;		/* 160 */
	v->nrow = C_LIN_SCR/FONTC;	/* 25 */
	v->bytr = C_BYT_LIN*FONTC;	/* 1280 */
	v->attr = 0x08;			/* inhibit second plane */
	v->vrgb[1] = RGB_WHITE;		/* foreground */
	v->vrgb[0] = RGB_BLACK;		/* background */
  }
  if (v->vram == (char *)0) {		/* no image allocated yet */
	if (tp == &tty_table[0]) {
	    /* First console gets original screen image */
#if (ATARI_TYPE == DETECT_TYPE)
	    if (atari_type == ST)
	    	v->vram = (char *)(((long)(VIDEO->vd_ramh & 0xFF) << 16) |
				   ((long)(VIDEO->vd_ramm & 0xFF) << 8)  | 0);
	    else
	    	v->vram = (char *)(((long)(VIDEO->vd_ramh & 0xFF) << 16) |
				   ((long)(VIDEO->vd_ramm & 0xFF) << 8)  |
				   ((long)(VIDEO->vd_raml & 0xFF)     )  );
#else
	    v->vram = (char *)(	((long)(VIDEO->vd_ramh & 0xFF) << 16) |
				((long)(VIDEO->vd_ramm & 0xFF) << 8)  |
#if (ATARI_TYPE == ST)		/* ST does not have raml register */
				0 );
#else
				((long)(VIDEO->vd_raml & 0xFF)     )  );
#endif /* ATARI_TYPE == ST */
#endif /* ATARI_TYPE == DETECT_TYPE */

	 } else {
	    /* subtract video memory from physical top of memory */
	    p = (unsigned long)(mem[0].base + mem[0].size) << CLICK_SHIFT;
	    /* align on 256 byte boundary for ST */
	    p = p & 0xffffff00;
#if (ATARI_TYPE == TT)
	    p -= 320*480L; /* VIDEORAM will eventually work here ? */
#else
	    p -= 0x7d00; /* VIDEORAM will eventually work here ? */
#endif /* ATARI_TYPE == TT */
	    mem[0].size = (vir_bytes)(p >> CLICK_SHIFT) - mem[0].base;
	    v->vram = (char *)p;
	}
  }
  v->vkeypad = FALSE;			/* default keyboard settings */
  v->vapmode = FALSE;
  /* set default tabs */
  for (tabpos = 0; tabpos < NCOL; tabpos++)
  	v->tabs[tabpos] = (tabpos & TAB_MASK) ? 0 : 1;
#if LINEWRAP
  v->wrap = TRUE;			/* line-wrap on  */
#else	/* LINEWRAP */
  v->wrap = FALSE;			/* line-wrap off */
#endif	/* LINEWRAP */
  v->topscroll = 0;			/* top of scroll region */
  v->botscroll = v->nrow - 1;		/* bottom of scroll region */
  v->origmode = FALSE;
  v->cursenable = TRUE;			/* start off with cursor on */
  v->curmode = 0;			/* clear screen wipes cursor */
  clrarea(v, 0, 0, v->nrow-1, NCOL-1);	/* clear the entire screen */
  moveto(v, 0, 0);			/* move cursor to upper left corner */
  if (tp == cur_tty) vduswitch(tp);	/* initialize vdu controller */
}

/*===========================================================================*
 *				scr_init				     *
 *===========================================================================*/
PUBLIC void scr_init(tp)
tty_t *tp;
{
/* Initialize the screen driver. */
  struct virterm *cons;
  int line;
  
  /* Associate console and TTY. */
  line = tp - &tty_table[0];
  if (line >= NR_CONS) return;
  cons = &virterm[line];
  cons->c_tty = tp;
  tp->tty_priv = cons;

  /* Initailize the screen driver. */
  vduinit(tp);
    
  /* Initialize the keyboard driver. */
  kb_init(tp);
  
  /* Output functions. */
  tp->tty_devwrite = console;
  tp->tty_echo = out_char;
}

/*===========================================================================*
 *				vdu_loadfont				     *
 *===========================================================================*/
PUBLIC int vdu_loadfont(m_ptr)
message *m_ptr;
{
    register phys_bytes	address;
    struct fnthdr *hdr;
    phys_bytes size;

    address = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS,
				(vir_bytes) sizeof(struct fnthdr));
    hdr = (struct fnthdr *)address;
    size = (phys_bytes) (128 / 8) * hdr->width * hdr->heigth; /* table size */
    if (hdr->width != 8) return(EINVAL);
    address = numap(m_ptr->PROC_NR, (vir_bytes) hdr->addr, (vir_bytes) size);
    switch (hdr->heigth) {
 	case 8:
		phys_copy((phys_bytes)address, (phys_bytes)font8, size);
		break;
 	case 12:
		phys_copy((phys_bytes)address, (phys_bytes)font12, size);
		break;
 	case 16:
		phys_copy((phys_bytes)address, (phys_bytes)font16, size);
		break;
	default:
		return(EINVAL);
    }
    return(OK);
}
#endif
