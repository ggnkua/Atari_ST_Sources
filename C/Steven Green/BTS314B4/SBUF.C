/*--------------------------------------------------------------------------*/
/*                                                                          */
/*                                                                          */
/*      ------------         Bit-Bucket Software, Co.                       */
/*      \ 10001101 /         Writers and Distributors of                    */
/*       \ 011110 /          Freely Available<tm> Software.                 */
/*        \ 1011 /                                                          */
/*         ------                                                           */
/*                                                                          */
/*  (C) Copyright 1987-90, Bit Bucket Software Co., a Delaware Corporation. */
/*                                                                          */
/*                                                                          */
/*               Amalgamation of all SB_*.c files                           */
/*            Implementation of virtual fossil screen                       */
/*                                                                          */
/*                                                                          */
/*    For complete  details  of the licensing restrictions, please refer    */
/*    to the License  agreement,  which  is published in its entirety in    */
/*    the MAKEFILE and BT.C, and also contained in the file LICENSE.240.    */
/*                                                                          */
/*    USE  OF THIS FILE IS SUBJECT TO THE  RESTRICTIONS CONTAINED IN THE    */
/*    BINKLEYTERM  LICENSING  AGREEMENT.  IF YOU DO NOT FIND THE TEXT OF    */
/*    THIS  AGREEMENT IN ANY OF THE  AFOREMENTIONED FILES,  OR IF YOU DO    */
/*    NOT HAVE THESE FILES,  YOU  SHOULD  IMMEDIATELY CONTACT BIT BUCKET    */
/*    SOFTWARE CO.  AT ONE OF THE  ADDRESSES  LISTED BELOW.  IN NO EVENT    */
/*    SHOULD YOU  PROCEED TO USE THIS FILE  WITHOUT HAVING  ACCEPTED THE    */
/*    TERMS  OF  THE  BINKLEYTERM  LICENSING  AGREEMENT,  OR  SUCH OTHER    */
/*    AGREEMENT AS YOU ARE ABLE TO REACH WITH BIT BUCKET SOFTWARE, CO.      */
/*                                                                          */
/*                                                                          */
/* You can contact Bit Bucket Software Co. at any one of the following      */
/* addresses:                                                               */
/*                                                                          */
/* Bit Bucket Software Co.        FidoNet  1:104/501, 1:132/491, 1:141/491  */
/* P.O. Box 460398                AlterNet 7:491/0                          */
/* Aurora, CO 80046               BBS-Net  86:2030/1                        */
/*                                Internet f491.n132.z1.fidonet.org         */
/*                                                                          */
/* Please feel free to contact us at any time to share your comments about  */
/* our software and/or licensing policies.                                  */
/*                                                                          */
/*                                                                          */
/*   This module is derived from code developed by Augie Hansen in his      */
/*   book "Proficient C" published by Microsoft Press.  Mr. Hansen was      */
/*   kind enough to give us verbal permission to use his routines, and      */
/*   Bob, Vince and Alan (and all our full screen users) are grateful.      */
/*   If you decide to use this code in some package you are doing, give     */
/*   some thought to going out and buying the book. He deserves that.       */
/*                                                                          */
/*--------------------------------------------------------------------------*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

#include "bink.h"
#include "sbuf.h"
#include "video.h"
#include "box.h"
#include "keybd.h"
#include "ascii.h"
#include "com.h"
#include "vfossil.h"

int SB_ROWS = 23;				/* Default sizes */
int SB_COLS = 80;

static BUFFER Sbuf;				 /* control information */
static CELLP Scrnbuf;			 /* screen buffer array */

#define WHITEBLANK (7 << 8) | ' '

static BOXTYPE box[] = {
   '+'  , '+'  , '+'  , '+'  , '-'  , '-'  , '|'  , '|'  ,
   ULC11, URC11, LLC11, LRC11, HBAR1, HBAR1, VBAR1, VBAR1,
   ULC22, URC22, LLC22, LRC22, HBAR2, HBAR2, VBAR2, VBAR2,
   ULC12, URC12, LLC12, LRC12, HBAR1, HBAR1, VBAR2, VBAR2,
   ULC21, URC21, LLC21, LRC21, HBAR2, HBAR2, VBAR1, VBAR1,
   BLOCK, BLOCK, BLOCK, BLOCK, HBART, HBARB, BLOCK, BLOCK
};

void sb_box (win, type, attr)
REGIONP win;
int type;
int attr;
{
   register int r;
   int x;
   int maxr, maxc;
   BOXTYPE *boxp;

   boxp = &box[type];
   maxc = win->c1 - win->c0;
   maxr = win->r1 - win->r0;
   x = maxc - 1;

   /* draw top row */
   sb_move (win, 0, 0);
   sb_wca (win, boxp->ul, attr, 1);
   sb_move (win, 0, 1);
   sb_wca (win, boxp->tbar, attr, x);
   sb_move (win, 0, maxc);
   sb_wca (win, boxp->ur, attr, 1);

   /* draw left and right sides */
   for (r = 1; r < maxr; r++)
      {
      sb_move (win, r, 0);
      sb_wca (win, boxp->lbar, attr, 1);
      sb_move (win, r, maxc);
      sb_wca (win, boxp->rbar, attr, 1);
      }

   /* draw bottom row */
   sb_move (win, maxr, 0);
   sb_wca (win, boxp->ll, attr, 1);
   sb_move (win, maxr, 1);
   sb_wca (win, boxp->bbar, attr, x);
   sb_move (win, maxr, maxc);
   sb_wca (win, boxp->lr, attr, 1);

   return;
}

void sb_fill (win, ch, attr)
REGIONP win;
int ch;
int attr;
{
   register int i, j;
   unsigned int ca;

   ca = ((unsigned) attr << 8) | (unsigned) ch;

   for (i = win->sr0; i <= win->sr1; i++)
      {
      for (j = win->sc0; j <= win->sc1; j++)
         {
         (Scrnbuf + i * SB_COLS + j)->cap = ca;
         }
      if (win->sc0 < Sbuf.lcol[i])
         {
         Sbuf.lcol[i] = win->sc0;
         }
      if (win->sc1 > Sbuf.rcol[i])
         {
         Sbuf.rcol[i] = win->sc1;
         }
      }

   Sbuf.flags |= SB_DELTA;

   return;
}

void sb_fillc (win, ch)
REGIONP win;
int ch;
{
   register int i, j;

   for (i = win->sr0; i <= win->sr1; i++)
      {
      for (j = win->sc0; j <= win->sc1; j++)
         {
         (Scrnbuf + i * SB_COLS + j)->b.ch = (unsigned char) ch;
         }
      if (win->sc0 < Sbuf.lcol[i])
         {
         Sbuf.lcol[i] = win->sc0;
         }
      if (win->sc1 > Sbuf.rcol[i])
         {
         Sbuf.rcol[i] = win->sc1;
         }
      }

   Sbuf.flags |= SB_DELTA;

   return;
}

void sb_filla (win, attr)
REGIONP win;
int attr;
{
   register int i, j;

   for (i = win->sr0; i <= win->sr1; i++)
      {
      for (j = win->sc0; j <= win->sc1; j++)
         {
         (Scrnbuf + i * SB_COLS + j)->b.attr = (unsigned char) attr;
         }
      if (win->sc0 < Sbuf.lcol[i])
         {
         Sbuf.lcol[i] = win->sc0;
         }
      if (win->sc1 > Sbuf.rcol[i])
         {
         Sbuf.rcol[i] = win->sc1;
         }
      }

   Sbuf.flags |= SB_DELTA;

   return;
}

#define WHITEBLANK (7 << 8) | ' '

void sb_init ()
{
   int i, j;
   CELLP c;
   char q[20];

   Scrnbuf = (CELLP) calloc ((size_t) SB_ROWS * SB_COLS, sizeof(CELL));
   Sbuf.bp = (CELLP) Scrnbuf;

   Sbuf.row = Sbuf.col = 0;
   Sbuf.lcol = (int *) calloc (sizeof (int), (size_t) SB_COLS);
   Sbuf.rcol = (int *) calloc (sizeof (int), (size_t) SB_COLS);
   (void) sprintf (q, "-%d.%ds", SB_COLS - 16, SB_COLS - 16);
   (void) strcpy (&stat_str[19], q);
   (void) sprintf (q, "-%d.%ds", SB_COLS - 22, SB_COLS - 22);
   (void) strcpy (&script_line[19], q);

   if ((Scrnbuf == NULL) ||
	   (Sbuf.lcol == NULL) ||
	   (Sbuf.rcol == NULL))
	  {
	  if (Scrnbuf != NULL)
		 free (Scrnbuf);
	  if (Sbuf.lcol != NULL)
		 free (Sbuf.lcol);
	  if (Sbuf.rcol != NULL)
		 free (Sbuf.rcol);

#ifndef NEW
	  SB_ROWS = 23;
	  SB_COLS = 80;
#endif

	  Scrnbuf = (CELLP) calloc (sizeof (CELL) * (unsigned) SB_ROWS * (unsigned) SB_COLS, 1);
	  Sbuf.bp = (CELLP) Scrnbuf;

	  Sbuf.row = Sbuf.col = 0;
	  Sbuf.lcol = (int *) calloc (sizeof (int), (size_t) SB_COLS);
	  Sbuf.rcol = (int *) calloc (sizeof (int), (size_t) SB_COLS);
	  (void) sprintf (q, "-%d.%ds", SB_COLS - 16, SB_COLS - 16);
	  (void) strcpy (&stat_str[19], q);
	  (void) sprintf (q, "-%d.%ds", SB_COLS - 22, SB_COLS - 22);
	  (void) strcpy (&script_line[19], q);
	  }

   for (i = 0; i < SB_ROWS; i++)
	  {
	  Sbuf.lcol[i] = SB_COLS;
	  Sbuf.rcol[i] = 0;
	  }

   Sbuf.flags = 0;

   c = Scrnbuf;
   for (i = 0; i < SB_ROWS; i++)
	  for (j = 0; j < SB_COLS; j++)
		 {
		 (*c).cap = WHITEBLANK;
		 ++c;
		 }

   return;
}

void sb_move (REGIONP win, int r, int c)
{
   /* don't change anything if request is out of range */
   if ((r < 0) || (r > (win->r1 - win->r0)) ||
       (c < 0) || (c > (win->c1 - win->c0)))
      return; /* (SB_ERR); */

   win->row = r;
   win->col = c;
   Sbuf.row = r + win->r0;
   Sbuf.col = c + win->c0;

   return; /* (SB_OK); */
}

REGIONP sb_new (top, left, height, width)
int top;
int left;
int height;
int width;
{
   REGIONP new;

   new = (REGIONP) malloc (sizeof (REGION));
   if (new != NULL)
      {
      new->r0 = new->sr0 = top;
      new->r1 = new->sr1 = top + height - 1;
      new->c0 = new->sc0 = left;
      new->c1 = new->sc1 = left + width - 1;
      new->row = new->col = 0;
      new->wflags = 0;
      }

   return (new);
}

int sb_popup (top, left, height, width, func, arg)
int top;
int left;
int height;
int width;
int (*func) (SAVEP, int);
int arg;
{
   int x;
   SAVEP tmp;

	if (fullscreen && (un_attended || doing_poll))
	{
		tmp = sb_save (top, left, height, width);
		x = (*func) (tmp, arg);
		sb_restore (tmp);
#ifdef NEW	/* Allow function to clear itself */
   		free (tmp);
#endif
#ifndef NEW	/* Moved into sb_restore */
		sb_show ();
#endif
	}
	else
	{
		x = (*func) (NULL, arg);
	}

   return (x);
}

int sb_putc (win, ch)
REGIONP win;
int ch;
{
   int cmax, rmax;
   int noscroll = 0, puterr = 0;

   /* calculate the screen buffer position and limits */
   cmax = win->c1 - win->c0;
   rmax = win->r1 - win->r0;
   Sbuf.row = win->r0 + win->row;
   Sbuf.col = win->c0 + win->col;

   /* process the character */
   switch (ch)
      {
      case '\b':
         /* Non destructive backspace */
         if (win->col > 0)
            {
            --(win->col);
            --(Sbuf.col);
            return (SB_OK);
            }
         else
            return (SB_ERR);

      case '\r':
         /* clear trailing line segment */
         while (win->col < cmax)
            {
            if (sb_putc (win, ' ') == SB_ERR)
               {
               ++puterr;
               }
            }
         sb_wc (win, ' ', 1);
         break;

      case '\t':
         /* convert tabs to spaces */
/*         lim = win->col + 8 - (win->col & 7);
         while (win->col < lim)
            {
            if (sb_putc (win, ' ') == SB_ERR)
               {
               ++puterr;
               }
            }
         break;*/

      default:
         (Scrnbuf + Sbuf.row * SB_COLS + Sbuf.col)->b.ch = (unsigned char) ch;
         if (Sbuf.col < Sbuf.lcol[Sbuf.row])
            {
            Sbuf.lcol[Sbuf.row] = Sbuf.col;
            }
         if (Sbuf.col > Sbuf.rcol[Sbuf.row])
            {
            Sbuf.rcol[Sbuf.row] = Sbuf.col;
            }
         break;
      }

   /* update the cursor position */
   if (win->col < cmax)
      {
      ++(win->col);
      }
   else if (win->row < rmax)
      {
      win->col = 0;
      ++(win->row);
      }
   else if (win->wflags & SB_SCROLL)
      {
      sb_scrl (win, 1);
      win->col = 0;
      win->row = rmax;
      }
   else
      {
      ++noscroll;
      }

   /* update screen buffer position */
   Sbuf.row = win->r0 + win->row;
   Sbuf.col = win->c0 + win->col;
   Sbuf.flags |= SB_DELTA;

   return ((noscroll || puterr) ? SB_ERR : SB_OK);
}

void sb_puts (win, s)
REGIONP win;
unsigned char *s;
{
   while (*s)
      {
      if (sb_putc (win, *s++) == SB_ERR)
         return; /* (SB_ERR); */
      }

   return; /* (SB_OK); */
}


unsigned char sb_ra (win, r, c)
REGIONP win;
int r, c;
{
   return ((unsigned char) (Scrnbuf + (win->r0 + r) * SB_COLS + win->c0 + c)->b.attr);
}

unsigned char sb_rc (win, r, c)
REGIONP win;
int r, c;
{
   return ((unsigned char) (Scrnbuf + (win->r0 + r) * SB_COLS + win->c0 + c)->b.ch);
}

unsigned int sb_rca (win, r, c)
REGIONP win;
int r, c;
{
   return ((unsigned int) (Scrnbuf + (win->r0 + r) * SB_COLS + win->c0 + c)->cap);
}

int sb_input_chars (REGIONP win, int row, int col, char *str, int len, BOOLEAN upper)
{
	int i;
	int j;

	sb_move (win, row, col);
	for (i = 0; i < len; i++)
		sb_putc (win, '_');
	sb_move (win, row, col);

	i = 0;
	while (i < len)
		{
		sb_show ();
		while (!KEYPRESS ())
			time_release ();
		j = FOSSIL_CHAR ();
		if ((j & 0xff) != 0)
			{
			j &= 0xff;
			if(upper)
				j = toupper (j);
			if (isprint (j))
				{
				sb_putc (win, j & 0xff);
				*str = (char) (j & 0xff);
				++str;
				++i;
				++col;
				continue;
				}
			}

		switch (j)
			{
			case ESC:
				return (1);

			case BS:
			case LFAR:
				if (i > 0)
					{
					--col;
					sb_move (win, row, col);
					sb_putc (win, '_');
					sb_move (win, row, col);
					--str;
					--i;
					}
				break;

			case CR:
			case LF:
				*str = '\0';
				for (j = i; j < len; j++)
					sb_putc (win, ' ');

#ifdef NEW	/* SWG: Always return 0 so as to disinguish between esc and return */
				return 0;
#else
				if (i)
					return (0);
				else
					return (1);
#endif
			}
		}

	*str = '\0';
	sb_show ();
	return (0);
}

/*
 * Do away with this heap storage, which shares the WAZOO buffer
 * because the size of the WAZOO buffer is 8K but the size of a pop
 * buffer for a large screen can be greater than that leading to
 * overwriting of variables and lots of bombs!!!
 */

#ifdef POPBUF

char *pop_malloc (size_t s)
{
	char *p;

	p = popbuf;
	popbuf += s;
	return (p);
}

void pop_free (char *s)
{
	popbuf = s;
}

#else

#define pop_malloc(s) malloc(s)
#define pop_free(ad) free(ad);

#endif

SAVEP sb_save (top, left, height, width)
int top;
int left;
int height;
int width;
{
   SAVEP new;
   CELLP c;
   int i, j;

   new = (SAVEP) malloc (sizeof (SAVE));
   c = new->save_cells = (CELLP) pop_malloc (sizeof (CELL) * height * width);
   new->region = sb_new (top, left, height, width);
   new->save_row = top;
   new->save_col = left;
   new->save_ht  = height;
   new->save_wid = width;

   j = top * SB_COLS + left;
   for (i = 0; i < height; i++)
      {
      memcpy (&c[i * width], &Scrnbuf[j], width * sizeof (CELL));
      j += SB_COLS;
      }

   return (new);
}

void sb_restore (save)
SAVEP save;
{
   int i, j, r;

#ifdef NEW
	if(save->save_cells)
	{
#endif

   		j = save->save_row * SB_COLS + save->save_col;
   		for (r = save->save_row, i = 0; i < save->save_ht; r++, i++)
      	{
      		memcpy (&Scrnbuf[j], &(save->save_cells[i * save->save_wid]), (size_t) save->save_wid * sizeof (CELL));
      		j += SB_COLS;
      		if (save->save_col < Sbuf.lcol[r])
         		Sbuf.lcol[r] = save->save_col;
      		if ((save->save_col + save->save_wid) > Sbuf.rcol[r])
         		Sbuf.rcol[r] = save->save_col + save->save_wid;
      	}

   		Sbuf.flags |= SB_DELTA;

   		pop_free ((char *) (save->save_cells));
   		free (save->region);
#ifndef NEW	/* Do this in sb_popup */
   		free (save);
#endif
#ifdef NEW
		save->save_cells = NULL;
		sb_show ();
	}
#endif
}


void sb_scrl (win, n)
REGIONP win;
int n;
{
   register int r, c;

   c = win->sc0;
   if (n == 0)
	  {
	  /* clear the entire region to spaces */
	  sb_fillc (win, ' ');
	  }
   else if (n > 0)
	  {
	  /* scroll n rows up */
	  for (r = win->sr0; r <= win->sr1 - n; r++)
		 {
		 (void) memcpy (Scrnbuf + r * SB_COLS + c, Scrnbuf + (r + n) * SB_COLS + c,
				 (size_t) (win->sc1 - win->sc0 + 1) * 2);
		 if (win->sc0 < Sbuf.lcol[r])
			{
			Sbuf.lcol[r] = win->sc0;
			}
		 if (win->sc1 > Sbuf.rcol[r])
			{
			Sbuf.rcol[r] = win->sc1;
			}
		 }
	  for (; r <= win->sr1; r++)
		 {
		 for (c = win->sc0; c <= win->sc1; c++)
			{
			(Scrnbuf + r * SB_COLS + c)->b.ch = ' ';
			}
		 if (win->sc0 < Sbuf.lcol[r])
			{
			Sbuf.lcol[r] = win->sc0;
			}
		 if (win->sc1 > Sbuf.rcol[r])
			{
			Sbuf.rcol[r] = win->sc1;
			}
		 }
	  }
   else
	  {
	  /* scroll n rows down */
	  n = -n;
	  for (r = win->sr1; r >= win->sr0 + n; r--)
		 {
		 (void) memcpy (Scrnbuf + r * SB_COLS + c, Scrnbuf + (r - n) * SB_COLS + c,
				 (size_t) (win->sc1 - win->sc0 + 1) * 2);
		 if (win->sc0 < Sbuf.lcol[r])
			{
			Sbuf.lcol[r] = win->sc0;
			}
		 if (win->sc1 > Sbuf.rcol[r])
			{
			Sbuf.rcol[r] = win->sc1;
			}
		 }
	  for (; r >= win->sr0; r--)
		 {
		 for (c = win->sc0; c <= win->sc1; c++)
			{
			(Scrnbuf + r * SB_COLS + c)->b.ch = ' ';
			}
		 if (win->sc0 < Sbuf.lcol[r])
			{
			Sbuf.lcol[r] = win->sc0;
			}
		 if (win->sc1 > Sbuf.rcol[r])
			{
			Sbuf.rcol[r] = win->sc1;
			}
		 }
	  }

   Sbuf.flags |= SB_DELTA;

   return;
}

int sb_set_scrl (win, top, left, bottom, right)
REGIONP win;
int top, left;
int bottom, right;
{
   if ((top < 0) || (left < 0) ||
	   (bottom > win->r1 - win->r0) ||
	   (right > win->c1 - win->c0))
	  return (SB_ERR);

   win->sr0 = win->r0 + top;
   win->sc0 = win->c0 + left;
   win->sr1 = win->r0 + bottom - 1;
   win->sc1 = win->c0 + right - 1;

   return (SB_OK);
}

void sb_show ()
{
	register int r;
	unsigned int src_os;

#if defined(ATARIST)
	static int old_blank = 0;			/* Old value of screenblank */

	if(do_screen_blank)
	{
		if(screen_blank != old_blank)
		{
			old_blank = screen_blank;
			if(screen_blank)
			{
				blank_screen();
				sb_dirty();
				return;
			}
			else
				unblank_screen();
		}
		else
			if(screen_blank)
				return;
	}
#else

	unsigned int far *q;

	if (screen_blank && do_screen_blank)
	{
		for (r = 0; r < SB_ROWS; r++)
		{
			q = (unsigned int far *) blanks;
#if defined(OS_2)
			(void) VioWrtCellStr ((PCH) q, (USHORT) (SB_COLS * 2), (USHORT) r, (USHORT) 0, (HVIO) 0L);
#else
			(void) VioWrtCellStr (q, (size_t)SB_COLS * 2, r, 0, 0);
#endif	/* OS_2 */
		}

		sb_dirty ();
		return;
	}
#endif /* ATARIST */

	/* Anything to do? */
	if (!(Sbuf.flags & SB_DELTA))
	{
		return;
	}

	src_os = 0;
	for (r = 0; r < SB_ROWS; r++)
	{
		/* Copy only changed portions of lines */
		if ((Sbuf.lcol[r] < SB_COLS) && (Sbuf.rcol[r] > 0))
		{
#if defined(ATARIST)
			VioWrtCellStr ((BYTEBUFP)(Scrnbuf + src_os + Sbuf.lcol[r]),
				(size_t) (Sbuf.rcol[r] - Sbuf.lcol[r] + 1) * 2,
				r, Sbuf.lcol[r], 0);
#else
			q = (unsigned int far *) (Scrnbuf + src_os + Sbuf.lcol[r]);
#if defined(OS_2)
			(void) VioWrtCellStr ((PCH) q, (USHORT) ((Sbuf.rcol[r] - Sbuf.lcol[r] + 1) * 2), (USHORT) r, (USHORT) Sbuf.lcol[r], (HVIO) 0L);
#else
			(void) VioWrtCellStr (q, (Sbuf.rcol[r] - Sbuf.lcol[r] + 1) * 2, r, Sbuf.lcol[r], 0);
#endif
#endif
			Sbuf.lcol[r] = SB_COLS;
			Sbuf.rcol[r] = 0;
		}
		src_os += (unsigned) SB_COLS;
	}

	/* the display now matches the buffer -- clear flag bit */
	Sbuf.flags &= ~SB_DELTA;

	gotoxy (cursor_col, cursor_row);
	return;
}

/*
 * Just cleans up the structure to say it is reality - I can use this when
 * I write directly to the screen for single char writes.
 */

void sb_clean ()
{
	int r;

	for (r = 0; r < SB_ROWS; r++)
	{
		Sbuf.lcol[r] = SB_COLS;
		Sbuf.rcol[r] = 0;
	}

	Sbuf.flags &= ~SB_DELTA;
}

/*
 * Make the entire buffer "dirty" so it will be updated.
 */

void sb_dirty ()
{
	int r;

	for (r = 0; r < SB_ROWS; r++)
	{
		Sbuf.lcol[r] = 0;
		Sbuf.rcol[r] = SB_COLS - 1;
	}

	Sbuf.flags |= SB_DELTA;
}

void sb_wa (win, attr, n)
REGIONP win;
int attr;
int n;
{
   int i;
   int row;
   int col;

   i = n;
   row = win->r0 + win->row;
   col = win->c0 + win->col;
   while (i--)
      (Scrnbuf + row * SB_COLS + col + i)->b.attr = (unsigned char) attr;

   /* marked the changed region */
   if (col < Sbuf.lcol[row])
      Sbuf.lcol[row] = col;
   if (col + n > Sbuf.rcol[row])
      Sbuf.rcol[row] = col + n;

   Sbuf.flags |= SB_DELTA;

   return; /* ((i == 0) ? SB_OK : SB_ERR); */
}

void sb_wc (win, ch, n)
REGIONP win;
int ch;
int n;
{
   int i;
   int row;
   int col;

   i = n;
   row = win->r0 + win->row;
   col = win->c0 + win->col;
   while (i--)
      (Scrnbuf + row * SB_COLS + col + i)->b.ch = (unsigned char) ch;

   /* marked the changed region */
   if (col < Sbuf.lcol[row])
      Sbuf.lcol[row] = col;
   if (col + n > Sbuf.rcol[row])
      Sbuf.rcol[row] = col + n;

   Sbuf.flags |= SB_DELTA;

   return; /* ((i == 0) ? SB_OK : SB_ERR); */
}

void sb_wca (win, ch, attr, n)
REGIONP win;
int ch;
int attr;
int n;
{
   int i;
   int row;
   int col;
   unsigned int ca;

   i = n;
   ca = (((unsigned) attr) << 8) | (unsigned) ch;
   row = win->r0 + win->row;
   col = win->c0 + win->col;
   while (i--)
      (Scrnbuf + row * SB_COLS + col + i)->cap = ca;

   /* marked the changed region */
   if (col < Sbuf.lcol[row])
      Sbuf.lcol[row] = col;
   if (col + n > Sbuf.rcol[row])
      Sbuf.rcol[row] = col + n;

   Sbuf.flags |= SB_DELTA;

   return; /* ((i == 0) ? SB_OK : SB_ERR); */
}


