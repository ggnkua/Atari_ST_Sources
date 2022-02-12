#if (CHIP == M68000)

/* This driver does not deal with multiple consoles and parameter passing
   through tp. Also the tty struct fields row and column are not maintained
*/

/*
 * The video driver for the Atari ST
 */
#include "kernel.h"
#include <sgtty.h>

#include "staddr.h"
#include "stvideo.h"
#include "stsound.h"

#include "tty.h"

/* Constants relating to the video RAM and fonts */
#define	VIDEORAM	32000	/* size of video ram */
#define NCOL		80	/* characters on a row */
#define	PIX_LIN		640	/* pixels per video line */
#define	PIX_CHR		8	/* pixels in char (width) */
#define	M_LIN_SCR	400	/* video lines on mono screen */
#define	C_LIN_SCR	200	/* video lines on color screen */
#define	M_BYT_LIN	80	/* bytes in mono video line */
#define	C_BYT_LIN	160	/* bytes in color video line */

#define	FONTC		8	/* 25 lines color */
#define	FONTM		16	/* 25 lines mono (or 8 for 50 lines) */

PRIVATE struct vduinfo {
	char	*vram;		/* base of video ram */
	char	*curs;		/* cursor position in video RAM */
	int	linc;		/* video lines in char */
	int	nrow;		/* char rows on screen */
	int	bytr;		/* bytes in row of chars */
	char	mono;		/* 1 if mono, 0 if color */
	char	attr;		/* current attribute byte */
	int	ccol;		/* current char column */
	int	crow;		/* current char row */
	char	savattr;	/* saved attribute byte */
	int	savccol;	/* saved char column */
	int	savcrow;	/* saved char row */
	char	vbuf[20];	/* partial escape sequence */
	char	*next;		/* next char in vbuf[] */
} vduinfo;

/*===========================================================================*
 *				flush					     *
 *===========================================================================*/
EXTERN void flush(tp)
register struct tty_struct *tp;
{
  register char *rq;

  if (tp->tty_rwords == 0)
	return;
  vducursor(0);
  rq = (char *)tp->tty_ramqueue;
  do {
	if (tp->tty_inhibited == TRUE) {
		vducursor(1);
		return;
	}
	out_char(tp, *rq++);	/* write 1 byte to terminal */
	tp->tty_phys++;		/* advance physical data pointer */
	tp->tty_cum++;		/* number of characters printed */
  } while (--tp->tty_rwords != 0);
  vducursor(1);
  return;
}

/*===========================================================================*
 *				console					     *
 *===========================================================================*/
PRIVATE void console(tp)
register struct tty_struct *tp;	/* tells which terminal is to be used */
{
/* Copy as much data as possible to the output queue, then start I/O.  On
 * memory-mapped terminals, such as the IBM console, the I/O will also be
 * finished, and the counts updated.  Keep repeating until all I/O done.
 */

  int count = 0;
  char c;
#if (CHIP == M68000)
  char *charptr = (char *)tp->tty_phys;

  vducursor(0);
#else
  extern char get_byte();
  unsigned segment, offset, offset1;

  /* Loop over the user bytes one at a time, outputting each one. */
  segment = (tp->tty_phys >> 4) & WORD_MASK;
  offset = tp->tty_phys & OFF_MASK;
  offset1 = offset;
#endif

  while (tp->tty_outleft > 0 && tp->tty_inhibited == RUNNING) {
#if (CHIP == M68000)
	out_char(tp, *charptr++);	/* write 1 byte to terminal */
	count++;
#else
	c = get_byte(segment, offset);	/* fetch 1 byte from user space */
	out_char(tp, c);	/* write 1 byte to terminal */
	offset++;		/* advance one character in user buffer */
#endif
	tp->tty_outleft--;	/* decrement count */
  }
#if (CHIP == M68000)
  vducursor(1);
#endif
  flush(tp);			/* clear out the pending characters */

  /* Update terminal data structure. */
#if (CHIP != M68000)
  count = offset - offset1;	/* # characters printed */
#endif
  tp->tty_phys += count;	/* advance physical data pointer */
  tp->tty_cum += count;		/* number of characters printed */

  /* If all data has been copied to the terminal, send the reply. */
  if (tp->tty_outleft == 0) finish(tp, tp->tty_cum);
}

/*===========================================================================*
 *				out_char				     *
 *===========================================================================*/
/*
 * send character to VDU, collecting escape sequences
 */
PUBLIC void out_char(tp, c)
struct tty_struct *tp;	/* not yet used */
register c;			/* character to be output */
{
  register struct vduinfo *v = &vduinfo;

  if (c == 0x7F)
	return;
  if ((c & 0140) == 0) {
	/*
	 * control character
	 */
	vductrl(c);
	return;
  }
  if (c & 0x80)
	/*
	 * display a fancy character (fonts 00 - 1f)
	 */
	c &= 0x1F;
  if (v->next == 0) {
	/*
	 * normal character
	 */
	paint(c);
	moveto(v->crow, v->ccol + 1);
	return;
  }
  if (v->next == v->vbuf && c == '[') {
	/*
	 * start of ANSI sequence
	 */
	*v->next++ = (char)c;
	return;
  }
  if (c >= 060 && (v->next == v->vbuf || v->vbuf[0] != '[')) {
	/*
	 * end of non-ANSI escape sequence
	 */
	vduesc(c);
	v->next = 0;
	return;
  }
  if (c >= 0100) {
	/*
	 * end of ANSI sequence
	 */
	vduansi(c);
	v->next = 0;
	return;
  }
  /*
   * part of escape sequence
   */
  *v->next = (char)c;
  if (v->next < &v->vbuf[sizeof(v->vbuf)])
	v->next++;
}

/*
 * control character
 */
PRIVATE vductrl(c)
{
  register struct vduinfo *v = &vduinfo;
  register i;
  register struct tty_struct *tp = &tty_struct[CONSOLE];
  
  switch (c) {
  case 007: /* BEL */
	beep(); return;
  case 010: /* BS */
	moveto(v->crow, v->ccol - 1); return;
  case 011: /* HT */
	do
		if ((tp->tty_mode & XTABS) == XTABS)
			out_char(tp, ' ');
		else
			moveto(v->crow, v->ccol + 1);
	while (v->ccol & TAB_MASK);
	return;
  case 012: /* LF */
	if (tp->tty_mode & CRMOD)
		out_char(tp, '\r');
  case 013: /* VT */
  case 014: /* FF */
	if (v->crow == v->nrow - 1) {
		for (i = 0; i < v->nrow-1; i++)
			cpyline(i + 1, i);
		clrline(i);
	} else
		moveto(v->crow + 1, v->ccol);
	return;
  case 015: /* CR */
	moveto(v->crow, 0);
	return;
  case 030: /* CAN */
  case 032: /* SUB */
	v->next = 0;
	/* no error char */
	return;
  case 033: /* ESC */
	v->next = v->vbuf;
	return;
  default:
	return;
  }
}

/*
 * execute ANSI escape sequence
 */
PRIVATE vduansi(c)
{
  register struct vduinfo *v = &vduinfo;
  register i;
  register j;

  if (v->next >= &v->vbuf[sizeof(v->vbuf)])
	return;
  *v->next = 0;
  v->next = &v->vbuf[1];
  j = vduparam();
  if ((i = j) <= 0)
	i = 1;
  switch (c) {
  case 'A': /* CUU: cursor up */
	if ((i = v->crow - i) < 0)
		i = 0;
	moveto(i, v->ccol);
	return;
  case 'B': /* CUD: cursor down */
	if ((i += v->crow) >= v->nrow)
		i = v->nrow-1;
	moveto(i, v->ccol);
	return;
  case 'C': /* CUF: cursor forward */
	if ((i += v->ccol) >= NCOL)
		i = NCOL-1;
	moveto(v->crow, i);
	return;
  case 'D': /* CUB: cursor backward */
	if ((i = v->ccol - i) < 0)
		i = 0;
	moveto(v->crow, i);
	return;
  case 'H': /* CUP: cursor position */
  case 'f': /* HVP: horizontal and vertical position */
	j = vduparam();
	if (j <= 0)
		j = 1;
	if (i > v->nrow)
		i = v->nrow;
	if (j > NCOL)
		j = NCOL;
	moveto(i - 1, j - 1);
	return;
  case 'J': /* ED: erase in display */
	if (j <= 0)
		clrarea(v->crow, v->ccol, v->nrow-1, NCOL-1);
	else if (j == 1)
		clrarea(0, 0, v->crow, v->ccol);
	else if (j == 2)
		clrarea(0, 0, v->nrow-1, NCOL-1);
	return;
  case 'K': /* EL: erase in line */
	if (j <= 0)
		clrarea(v->crow, v->ccol, v->crow, NCOL-1);
	else if (j == 1)
		clrarea(v->crow, 0, v->crow, v->ccol);
	else if (j == 2)
		clrarea(v->crow, 0, v->crow, NCOL-1);
	return;
#if (CHIP != M68000)
#ifdef NEEDED
  case 'n': /* DSR: device status report */
	if (i == 6)
		kbdinput("\033[%d;%dR", v->crow+1, v->ccol+1);
	return;
#endif NEEDED
#endif
  case 'm': /* SGR: set graphic rendition */
	do {
		static colors[] = {
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

		if (j <= 0)
			v->attr &= ~3;
		else if (j == 4 || j == 7)
			v->attr |= 3;
		else if (j >= 30 && j <= 39)
			VIDEO->vd_rgb[1] = colors[j - 30];
		else if (j >= 40 && j <= 49)
			VIDEO->vd_rgb[0] = colors[j - 40];
	} while ((j = vduparam()) >= 0);
	return;
  case 'L': /* IL: insert line */
	if (i > v->nrow - v->crow)
		i = v->nrow - v->crow;
	for (j = v->nrow-1; j >= v->crow+i; j--)
		cpyline(j - i, j);
	while (--i >= 0)
		clrline(j--);
	return;
  case 'M': /* DL: delete line */
	if (i > v->nrow - v->crow)
		i = v->nrow - v->crow;
	for (j = v->crow; j < v->nrow-i; j++)
		cpyline(j + i, j);
	while (--i >= 0)
		clrline(j++);
	return;
  case '@': /* ICH: insert char */
	j = NCOL - v->ccol;
	if (i > j)
		i = j;
	j -= i;
	while (--j >= 0)
		cpychar(v->crow, v->ccol + j, v->crow, v->ccol + j + i);
	clrarea(v->crow, v->ccol, v->crow, v->ccol + i - 1);
	return;
  case 'P': /* DCH: delete char */
	j = NCOL - v->ccol;
	if (i > j)
		i = j;
	j -= i;
	while (--j >= 0)
		cpychar(v->crow, NCOL-1 - j, v->crow, NCOL-1 - j - i);
	clrarea(v->crow, NCOL - i, v->crow, NCOL-1);
	return;
  case 'l': /* RM: reset mode */
  case 'h': /* SM: set mode */
	if (v->next[0] == '?') { /* DEC private modes */
		if (v->next[1] == '5' && v->mono) /* DECSCNM */
			VIDEO->vd_rgb[0] = c == 'l' ? RGB_BLACK : RGB_WHITE;
		else if (v->next[1] == '1')	  /* DECCKM */
			app_mode = c == 'l' ? TRUE : FALSE;
	}
	return;
  case '~': /* Minix-ST specific escape sequence */
	/*
	 * Handle the following escape sequence:
	 *   ESC [ l;a;m;r;g;b '~'
	 * where
	 *   if l present:
	 *	0: 25 lines if mono
	 *	1: 50 lines if mono
	 *   if a present:
	 *	low 4 bits are attribute byte value (see paint())
	 *   if m present:
	 *	interpret r;g;b as colors for map register m
	 *	only assign color if r, g or b present
	 */
	if (j == 0 && v->mono) {	/* 25 lines */
		v->linc = 16;		/* 16 */
		v->nrow = M_LIN_SCR/16;	/* 25 */
		v->bytr = M_BYT_LIN*16;	/* 1280 */
		moveto(v->nrow - 1, 0);
	}
	if (j == 1 && v->mono) {	/* 50 lines */
		v->linc = 8;		/* 8 */
		v->nrow = M_LIN_SCR/8;	/* 50 */
		v->bytr = M_BYT_LIN*8;	/* 640 */
		moveto(v->nrow - 1, 0);
	}
	j = vduparam();
	if (j >= 0)
		v->attr = j & 0x0F;
	j = vduparam();
	if (j >= 0) {
		register short *w;

		w = (short *)&VIDEO->vd_rgb[j & 0x0F];
		j = vduparam();
		if (j >= 0)
			*w = (*w & ~0x0700) | ((j & 7) << 8);
		j = vduparam();
		if (j >= 0)
			*w = (*w & ~0x0070) | ((j & 7) << 4);
		j = vduparam();
		if (j >= 0)
			*w = (*w & ~0x0007) | ((j & 7) << 0);
	}
	return;
  default:
	return;
  }
}

/*
 * execute non-ANSI escape sequence
 */
PRIVATE vduesc(c)
{
  register struct vduinfo *v = &vduinfo;
  register i;

  if (v->next >= &v->vbuf[sizeof(v->vbuf)-1])
	return;
  *v->next = (char)c;
  switch (v->vbuf[0]) {
  case '8': /* DECRC: restore cursor */
	v->ccol = v->savccol;
	v->crow = v->savcrow;
	v->attr = v->savattr;
	moveto(v->crow, v->ccol);
	return;
  case '7': /* DECSC: save cursor */
	v->savccol = v->ccol;
	v->savcrow = v->crow;
	v->savattr = v->attr;
	return;
  case '=': /* DECKPAM: keypad application mode */ 
	keypad = TRUE;
	return;
  case '>': /* DECKPNM: keypad numeric mode */ 
	keypad = FALSE;
	return;
  case 'E': /* NEL: next line */
	vductrl(015);
	/* fall through */
  case 'D': /* IND: index */
	vductrl(012);
	return;
  case 'M': /* RI: reverse index */
	if (v->crow == 0) {
		for (i = v->nrow - 1; i > 0; i--)
			cpyline(i - 1, i);
		clrline(i);
	} else
		moveto(v->crow - 1, v->ccol);
	return;
  case 'c': /* RIS: reset to initial state */
	vduinit();
	vducursor(0);
	keypad = FALSE;
	app_mode = FALSE;
	return;
  default:
	return;
  }
}

/*
 * compute next parameter out of ANSI sequence
 */
PRIVATE vduparam()
{
  register struct vduinfo *v = &vduinfo;
  register c;
  register i;

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
  if (c != ';')
	v->next--;
  return(i);
}

/*===========================================================================*
 *				manipulate videoram 			     *
 *===========================================================================*/
/*
 * copy line r1 to r2
 */
PRIVATE cpyline(r1, r2)
{
  register struct vduinfo *v = &vduinfo;
  register long *src;
  register long *dst;
  register i;

  src = (long*)&v->vram[r1 * v->bytr];
  dst = (long*)&v->vram[r2 * v->bytr];
  i = v->bytr >> 4;	/* 16 bytes per iteration */
  while (--i >= 0) {
	*dst++ = *src++;
	*dst++ = *src++;
	*dst++ = *src++;
	*dst++ = *src++;
  }
}

/*
 * copy char (r1,c1) to (r2,c2)
 */
PRIVATE cpychar(r1, c1, r2, c2)
{
  register char *src;		/* ptr into video memory */
  register char *dst;		/* ptr into video memory */
  register nl;			/* scan lines per char */
  register bl;			/* bytes per scan line */
  register struct vduinfo *v = &vduinfo;

  bl = M_BYT_LIN;
  if (!v->mono) {
	bl = C_BYT_LIN;
	c1 <<= 1;		/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
	if (c1 & 2)
		c1--;
	c2 <<= 1;		/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
	if (c2 & 2)
		c2--;
  }
  src = &v->vram[(r1 * v->bytr) + c1];
  dst = &v->vram[(r2 * v->bytr) + c2];
  nl = v->linc;
  do {
	*dst = *src;
	src += bl;
	dst += bl;
  } while (--nl != 0);
  if (v->mono)
	return;
  src += 2;
  dst += 2;
  nl = v->linc;
  do {
	src -= bl;
	dst -= bl;
	*dst = *src;
  } while (--nl != 0);
}

/*
 * clear part of screen between two points inclusive
 */
PRIVATE clrarea(r1, c1, r2, c2)
{
  if (++c2 == NCOL) {
	c2 = 0;
	r2++;
  }
  if (c1 > 0 && r1 < r2) {
	do
		clrchar(r1, c1);
	while (++c1 < NCOL);
	c1 = 0;
	r1++;
  }
  while (r1 < r2)
	clrline(r1++);
  while (c1 < c2)
	clrchar(r1, c1++);
}

/*
 * clear line r
 */
PRIVATE clrline(r)
{
  register struct vduinfo	*v = &vduinfo;
  register long			*p;
  register			i;

  p = (long*)&v->vram[r * v->bytr];
  i = v->bytr >> 4;	/* 16 bytes per iteration */
  while (--i >= 0) {
	*p++ = 0;
	*p++ = 0;
	*p++ = 0;
	*p++ = 0;
  }
}

/*
 * clear char (r,c)
 */
PRIVATE clrchar(r, c)
{
  register char *p;		/* ptr into video memory */
  register nl;			/* scan lines per char */
  register bl;			/* bytes per scan line */
  register struct vduinfo *v = &vduinfo;

  bl = M_BYT_LIN;
  if (!v->mono) {
	bl = C_BYT_LIN;
	c <<= 1;		/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
	if (c & 2)
		c--;
  }
  p = &v->vram[(r * v->bytr) + c];
  nl = v->linc;
  do {
	*p = 0;
	p += bl;
  } while (--nl != 0);
  if (v->mono)
	return;
  p += 2;
  nl = v->linc;
  do {
	p -= bl;
	*p = 0;
  } while (--nl != 0);
}

/*===========================================================================*
 *				moveto					     *
 *===========================================================================*/
PRIVATE moveto(r, c)
{
  register struct vduinfo *v = &vduinfo;

  if (r < 0 || r >= v->nrow || c < 0 || c > NCOL)
	return;
  v->crow = r;
  v->ccol = c;
  if (c == NCOL)
	c--;			/* show cursor in last column */
  if (!v->mono) {		/* 0->0, 1->1, 2->4, 3->5, 4->8, ... */
	c <<= 1;
	if (c & 2)
		c--;
  }
  v->curs = &v->vram[(r * v->bytr) + c];
}

/*===========================================================================*
 *				beep					     *
 *===========================================================================*/
PRIVATE	char sound[] = {
	0xA8,0x01,0xA9,0x01,0xAA,0x01,0x00,
	0xF8,0x10,0x10,0x10,0x00,0x20,0x03
};

PRIVATE beep()
{
  register i, s;

  s = lock();
  for (i = 0; i < sizeof(sound); i++) {
	SOUND->sd_selr = i;
	SOUND->sd_wdat = sound[i];
  }
  restore(s);
}

/*===========================================================================*
 *				paint					     *
 *===========================================================================*/
/*
 * copy from font memory into video memory
 * implementation tries to make the inner loop as fast as possible
 * attributes:
 *   0000xxx1: invert plane 0
 *   0000xx1x: invert plane 1 (color only)
 *   0000x1xx: inhibit plane 0
 *   00001xxx: inhibit plane 1 (color only)
 */
PRIVATE paint(c)
{
  register unsigned char *vp;	/* ptr into video memory */
  register unsigned char *fp;	/* ptr into font */
  register nl;			/* scan lines per char */
  register bl;			/* bytes per scan line */
  register struct vduinfo *v = &vduinfo;

  c &= 0x7F;
  if (v->linc == 16)
	fp = &font16[c<<4];
  else
	fp = &font8[c<<3];
  bl = v->mono ? M_BYT_LIN : C_BYT_LIN;
  if ((v->attr & 4) == 0) {		/* plane 0: color and mono */
	nl = v->linc;
	vp = (unsigned char *)v->curs;
	if ((v->attr & 1) == 0) {
		do {
			*vp = *fp++;
			vp += bl;
		} while (--nl != 0);
	} else {
		do {
			*vp = ~(*fp++);
			vp += bl;
		} while (--nl != 0);
	}
  }
  if (v->mono == 0 && (v->attr & 8) == 0) {	/* plane 1: color */
	nl = v->linc;
	fp -= nl;
	vp = (unsigned char *)v->curs + 2;
	if ((v->attr & 2) == 0) {
		do {
			*vp = *fp++;
			vp += bl;
		} while (--nl != 0);
	} else {
		do {
			*vp = ~(*fp++);
			vp += bl;
		} while (--nl != 0);
	}
  }
}

/*===========================================================================*
 *				vducursor				     *
 *===========================================================================*/
/*
 * (un-)display the cursor
 * parameter onoff reserved for future use (e.g. blinking)
 */
PUBLIC void vducursor(onoff)
int	onoff;
{
  register char *vp;
  register nl;
  register bl;
  register struct vduinfo *v = &vduinfo;

  bl = v->mono ? M_BYT_LIN : C_BYT_LIN;
  if ((v->attr & 4) == 0) {		/* plane 0: color and mono */
	nl = v->linc;
	vp = v->curs;
	do {
		*vp = ~(*vp);
		vp += bl;
	} while (--nl != 0);
  }
  if (v->mono == 0 && (v->attr & 8) == 0) {	/* plane 1: color */
	nl = v->linc;
	vp = v->curs + 2;
	do {
		*vp = ~(*vp);
		vp += bl;
	} while (--nl != 0);
  }
}

/*===========================================================================*
 *				vduinit				     *
 *===========================================================================*/
PUBLIC void vduinit()
{
  register struct vduinfo	*v = &vduinfo;

  tty_struct[CONSOLE].tty_devstart = (int (*)())console;
  if (VIDEO->vd_res & RES_HIGH) {
	v->mono = 1;
	v->linc = FONTM;		/* 16 (or 8) */
	v->nrow = M_LIN_SCR/FONTM;	/* 25 (or 50) */
	v->bytr = M_BYT_LIN*FONTM;	/* 1280 (or 640) */
	VIDEO->vd_rgb[0] = RGB_BLACK;	/* background */
  } else {
	VIDEO->vd_res = RES_MID;
	v->linc = FONTC;		/* 8 */
	v->nrow = C_LIN_SCR/FONTC;	/* 25 */
	v->bytr = C_BYT_LIN*FONTC;	/* 1280 */
	v->attr = 0x08;			/* inhibit second plane */
	VIDEO->vd_rgb[1] = RGB_WHITE;	/* foreground */
	VIDEO->vd_rgb[0] = RGB_BLACK;	/* background */
  }
  v->vram = (char *)(
		((long)(VIDEO->vd_ramh & 0xFF) << 16L)
		|
		((long)(VIDEO->vd_ramm & 0xFF) << 8L)
	     );
  moveto(0, 0);		/* move cursor to upper left corner */
  clrarea(0, 0, v->nrow-1, NCOL-1);
  vducursor(1);		/* init the cursor */
}
#endif
