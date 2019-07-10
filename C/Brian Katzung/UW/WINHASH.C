/*
 * This file contains routines which can be used to determine the character
 * present at a given location in a window.  These functions are used to
 * determine the character under the mouse cursor, and for the log-top printer
 * function.
 */

#include <stdio.h>
#include <osbind.h>
#include "windefs.h"

extern struct wi_str w[];

int	highlighted_wdes = -1;	/* make this global now for use in winmain.c*/

/*
 * char_at returns the ascii code of the character in wdes window at
 * (x_loc, y_loc) cursor position.  Zero is returned if the character can
 * not be identified.
 */
int char_at(wdes, x_loc, y_loc)
int wdes, x_loc, y_loc;

{

  register struct wi_str *wp = &w[wdes];
  int ch, width, boffset, count, cur_y, cur_x;
  register unsigned long mask;
  register unsigned long *dptr;
  register int shift;
  register FNT *fnt = wp->font;
  static char pa[32]; 		/* pixel array containing character image */
  
  cur_x = x_loc * fnt->inc_x + X0;
  cur_y = y_loc * fnt->inc_y + wp->top_y;
  
  width = 2 * wp->wi_mf.wwords;
  boffset = wp->m_off+cur_x+fnt->inc_x-1;
  dptr = ((char *)(wp->wi_mf.ptr)) + cur_y * width
    + ((boffset >> 4) << 1) - 2;
  shift = 15 - (boffset & 15);
  mask = (-1L<<(shift+fnt->inc_x)|(1<<shift)-1);
  for (count = 0; count < fnt->inc_y; count ++)
  {
    pa[count] = (*dptr & (~ mask)) >> shift;
    ((char *) dptr) += width;
  }
  
  ch = which_char(fnt, &fnt->f_hash, pa);
  if (ch == 0)		/* Not found, check for inverse vidio case */
  {
    for (count = 0; count < fnt->inc_y; count ++)
      pa[count] = ~pa[count] & (1<< fnt->inc_x) - 1;
    ch = which_char(fnt, &fnt->f_hash, pa);
  }
  return (ch);
}

/*
 * which_char returns the ascii code of the character bitmap in pa from font
 * font using hash table htbl.
 */
int which_char(font, htbl, pa)
FNT *font;
HTBL *htbl;
char *pa;

{
  register int i, h, n;
  
  h = hash_char (pa, font->inc_y);
  if ((htbl->h_t[h] & 128) == 0) /* collision bit set? */
  {
    for (i=0; i<font->inc_y; i++)
      if (font->f_data[(htbl->h_t)[h] * 16 + i] != pa[i])
        break;
    if (i < font->inc_y){
      return 0;
    }
    else
      return (htbl->h_t[h]);
  }
  else				/* collision, search colision list for char */
  {
    n = htbl->h_t[h] & 127;
    while (n != 0)
    {
      for (i=0; i<font->inc_y; i++)
        if (font->f_data[(htbl->h_colision)[n].h_try * 16 + i] != pa[i])
	  break;
      if (i < font->inc_y)
        n = htbl->h_colision[n].h_next;
      else
        return (htbl->h_colision[n].h_try);
    }
    return 0;
  }
}

/*
 * gen_hash initalizes htbl with the hash table for font font.
 */
void gen_hash(font, htbl)
FNT *font;
HTBL *htbl;

{
  register int overflowcnt = 1;
  register int np, tp, i, j;
  int h;
  
  for (i=0; i<128; i++)		/* initalize */
    htbl->h_colision[i].h_next = '\0';
  for (i=0; i<(1<<HASHBITS); i++)
    htbl->h_t[i] = '\0';
  
  for (i=32; i<128; i++)
  {			/* for each character */
    h = hash_char(&font->f_data[i*16], font->inc_y);
    if (htbl->h_t[h] == 0)
      htbl->h_t[h] = i;
    else
    {
      if ((htbl->h_t[h] & 128) == 0) /* already overflowed? */
      { /* No, move first element to overflow list */
	htbl->h_colision[overflowcnt].h_try = htbl->h_t[h];
        htbl->h_t[h] = 128 | overflowcnt;
	overflowcnt++;
      }
	
      tp = htbl->h_t[h] & 127;
      j=0;	/* dbug */
      while ((np = htbl->h_colision[tp].h_next) != 0){
	tp = np;
	j++; /* dbug */
      }
#ifdef DEBUG
      printf("overflow=%d depth=%d hash %d = %d\n",overflowcnt, j, i, h);
#endif
      htbl->h_colision[tp].h_next = overflowcnt;
      htbl->h_colision[overflowcnt].h_try = i;
      ++ overflowcnt;
    }
  }

#ifdef DEBUG 	/* verify sanity of hash table */
  for (i=32; i<128; i++) /* dbug */
    if ((j = which_char(font, htbl, &font->f_data[i*16])) != i)
  {
    printf("%d != %d\n", i, j);
  }
#endif
}

/*
 * hash_char returns the hash code for the character pixel image in pa of
 * height height.
 */
int hash_char(pa, height)
char *pa;
int height;

{
  register int h, i, j;
  
  h=0;
  for (i=0; i<height; i++)
  {
    h += pa[i] << i*3 % HASHBITS;
  }
  j = (1<<HASHBITS) - 1;
  h = (h + (h >> HASHBITS + 1)) & j;

  return h;
}

/*
 * dump_line send the y_coord'th line in the window wdes to the printer.
 * zero is returned if the line was printed ok.
 */
dump_line(wdes, y_coord)
{
  int i;
  char ch;
  
  for (i = 0; i < w[wdes].x_chrs; i++){
    ch = char_at(wdes, i, y_coord);
    if (Cprnout(ch) == 0) {
      w[wdes].ptr_status = LOG_NONE;
      return -1;
    }
  }
  if (Cprnout('\n') == 0 | Cprnout('\r') == 0) {
    w[wdes].ptr_status = LOG_NONE;
    return -1;
  }
  return 0;
}

/*
 * dump_window send the contents of wdes to the printer.
 */
dump_window(wdes)
{
  int i;
  
  for (i = 0; i < w[wdes].y_chrs; i++){
    dump_line(wdes, i);
  }
}
/* copy_word fills buffer with the word at (x1, y1) from wdes
 * No checks are made for buffer overflow.
 */
copy_word(wdes, x1, y1, buffer)
int wdes, x1, y1;
char * buffer;
{
  register int fx, lx, yo, xo;
  
  yo = w[wdes].y_off / w[wdes].font->inc_y; /* adjust for scroll bar action */  
  xo = w[wdes].x_off / w[wdes].font->inc_x;
  fx = x1 - 1;
  lx = x1 + 1;
  
  while (fx + xo >= 0 && char_at(wdes, fx + xo, y1 + yo) != ' ')
    --fx;
  while (lx + xo < w[wdes].x_chrs && char_at(wdes, lx + xo, y1 + yo) != ' ')
    ++lx;
  copy_text(wdes, ++fx, y1, --lx, y1, buffer);
}

/* copy_text fills buffer with the text between (x1, y1) and (x2, y2) from wdes
 * where point 1 is before point 2.  No checks are made for buffer overflow.
 */
copy_text(wdes, x1, y1, x2, y2, buffer)
int wdes, x1, y1, x2, y2;
char * buffer;
{
  static int old_hh;
  static int old_y1;
  register int cx, cy, i, lastnbi, lastnbx;
  int inc_y, inc_x, top_y;

  /* undo any old selected text which might be inverted on screen */
  if (highlighted_wdes > 0 && w[highlighted_wdes].font != NULL)
  {
    w_update(highlighted_wdes, FM_COPY, 0, old_y1,
      w[highlighted_wdes].x_chrs * w[highlighted_wdes].font->inc_x + X0 + 1,
      old_hh);
  }
  if (y1 > y2) return;	/* nothing to do */

  inc_y = w[wdes].font->inc_y;
  inc_x = w[wdes].font->inc_x;
  top_y = w[wdes].top_y;
    
  y1 = y1 + w[wdes].y_off / inc_y;	/* adjust for scroll bar action */  
  y2 = y2 + w[wdes].y_off / inc_y;	/* assumes _off is multiple of inc_ */
  x1 = x1 + w[wdes].x_off / inc_x;
  x2 = x2 + w[wdes].x_off / inc_x;
  i = 0;
  lastnbi = 0;
  lastnbx = x1;

  if (y1 > y2)
  {
    highlighted_wdes = -1;	/* no undo required on next call */
    return;
  }
  
  old_y1 = y1 * inc_y + top_y;
  old_hh = (y2 - y1 + 2) * inc_y + Y0;
  highlighted_wdes = wdes;
  
  cx = x1;
  cy = y1;

  while (cy < y2 || (cy == y2 && cx <= x2))
  {
    buffer[i] = char_at(wdes, cx, cy);
    if (buffer[i] != ' ')
    {
      lastnbi = i;
      lastnbx = cx;
    }
    cx ++;
    if (cx >= w[wdes].x_chrs)
    {
      if (cy == y1)	/* first line */
        w_update(wdes, FM_INVERT, x1 * inc_x, cy * inc_y + top_y,
	  (++lastnbx - x1) * inc_x + X0, inc_y);
      else
        w_update(wdes, FM_INVERT, 0, cy * inc_y + top_y,
	  ++lastnbx * inc_x + X0, inc_y);
      cx = 0;
      cy ++;
      i = ++lastnbi;
      lastnbx = -1;
      buffer[i] = '\r';
    }
    i++;
  }
  if (cy == y1)	/* one line */
    w_update(wdes, FM_INVERT, x1 * inc_x, cy * inc_y + top_y,
      (++lastnbx - x1) * inc_x + X0, inc_y);
  else
    w_update(wdes, FM_INVERT, 0, cy * inc_y + top_y,
      ++lastnbx * inc_x + X0, inc_y);
  buffer[++lastnbi] = '\0';
}

