/* EZ-Score Plus 1.1
 * Page text module (ptext.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   06 March 1988
 * Last modified: 22 March 1988
 */

overlay "ezp"

#include <gem.h>
#include <misc.h>

#include "ezp.h"
#include "structs.h"
#include "prtcnf.h"
#include "text.h"
#include "extern.h"
#include "header.h"
#include "cextern.h"

extern int  hpgline[];        /* declared in dialogs.c   */


setup_liney()
{
   register int   blines, i, lines, vertoff;

   erase_liney();
   if (pageptr[HTISHOWN]) {
      for (lines = MAXTITLE; lines > 0; lines--) {
         if (pageptr[(hpgline[lines])] != '\0')
            break;
      }
      for (blines = MAXCOPR; blines > 0; blines--) {
         if (pageptr[(hpgline[blines+MAXTITLE])] != '\0')
            break;
      }
      if (blines) {
         vertoff = font_info[MYTFONT].fonth * blines;
         bmarg = bm - vertoff;
         liney[MAXTITLE].top = bmarg;
         liney[MAXTITLE].size = font_info[MYTFONT].fonth;
         if (blines == 2) {
            liney[MAXTITLE+1].top = liney[MAXTITLE].top + liney[MAXTITLE].size;
            liney[MAXTITLE+1].size = font_info[MYTFONT].fonth;
         }
      }
      if (lines) {
         vertoff = tm;
         for (i = 0; i < lines; i++) {
            liney[i].top = vertoff;
            liney[i].size = ((pageptr[PGTLRG+i])? font_info[MYLFONT].fonth:
                  font_info[MYSFONT].fonth);
            vertoff += liney[i].size;
         }
         tmarg = vertoff;
      }
   }
}


mod_liney()
{
   register int   i, systop;

   if (pageptr[HTISHOWN]) {
      systop = max( systems[0].top + (systems[0].size - rasys >> 1) - SYSTOPX,
            systems[0].top );
      for (i = MAXTITLE - 1; i >= 0; i--)             /* skip unused lines */
         if (liney[i].top)
            break;
      for (; i >= 0; i--)
         if (pageptr[PGTLRG+i] || pageptr[PGTCNT+i])
            break;
         else {
            liney[i].top = systop - font_info[MYSFONT].fonth;
            systop -= liney[i].size;
         }
   }
}


erase_liney()
{
   register int   i;

   for (i = 0; i < MAXLIN; i++) {
      liney[i].top = 0;
      liney[i].size = 0;
   }
}


print_titcop()
{
   register int   anything, font, i, j;
   int   more, nl, secondoff, secondx, x, y;
   long  fl;
   register char  *lin, *split;

   i = 0;
   do {
      more = FALSE;
      if (clip_img( liney[i].top, liney[i].size, &fl, &nl, &y )) {
         gr_clipx1 = 2;
         gr_clipy1 = (int)fl;
         gr_clipx2 = bitln - 2;
         gr_clipy2 = gr_clipy1 + nl - 1;
         scrbase = (long)s_image + (y? bytln * (long)y: -(bytln * fl));
         x = get_stringx( i, &secondoff, &secondx );
         font = (i < MAXTITLE)? (pageptr[PGTLRG+i]? MYLFONT: MYSFONT):
               MYTFONT;
         lin = &pageptr[(hpgline[i+1])];
         if (secondoff)
            *(split = &lin[secondoff - 1]) = '\0';
         gr_text( lin, x, font_info[font].fonth, 1, font );
         if (secondoff) {
            gr_text( ++split, secondx, font_info[font].fonth, 1, font );
            *(--split) = SPLITCHAR;
         }
      }
      if (voff + ahite >= liney[i].top + liney[i].size) {
         if (++i < MAXLIN)
            more = TRUE;
      }
   } while (!abortp && more);
}


get_stringx( s, o2, x2 )
register int s;
register int *o2, *x2;
{
   register int   i, len;

   *o2 = *x2 = 0;
   if (s < MAXTITLE) {
      if (pageptr[PGTCNT+s]) {
         len = strprolen( &pageptr[(hpgline[s+1])], (pageptr[PGTLRG+s])?
               MYLFONT: MYSFONT );
         return (max( 0, (rm - lm >> 1) + lm - (len >> 1) ));
      } else {
         for (i = 0; pageptr[(hpgline[s+1]) + i] != '\0'; i++) {
            if (pageptr[(hpgline[s+1]) + i] == SPLITCHAR) {
               *o2 = i + 1;
               break;
            }
         }
         if (*o2) {
            len = strprolen( &pageptr[(hpgline[s+1]) + *o2],
                  (pageptr[PGTLRG+s])? MYLFONT: MYSFONT );
            *x2 = rm - len;
         }
         return lm;
      }
   } else {
      len = strprolen( &pageptr[(hpgline[s+1])], MYTFONT );
      return (max( 0, (rm - lm >> 1) + lm - (len >> 1) ));
   }
}


print_pagenum( page )
register int page;
{
   int   fh, len, nl, y;
   register int   x;
   register unsigned number;
   long  fl;
   register char  restore;
   char  pagenum[6];

   fh = font_info[MYSFONT].fonth;
   if (clip_img( pageptr[HPNPTOP]? printer->pagenum_top:
         printer->pagenum_bottom - fh, fh, &fl, &nl, &y )) {
      number = page + ((int*)pageptr)[HPNOFF];
      if (pageptr[HPNPALT]) {
         if (number & 0x01) {
            restore = pageptr[HPNPRIGT];
            pageptr[HPNPRIGT] = pageptr[HPNPALT];
         } else {
            restore = pageptr[HPNPLEFT];
            pageptr[HPNPLEFT] = pageptr[HPNPALT];
         }
      }
      itoa( number, pagenum, ndigits( number ));
      if (pageptr[HPNPLEFT])
         x = printer->pagenum_left;
      else {
         len = strprolen( pagenum, MYSFONT );
         x = (pageptr[HPNPRIGT])? printer->pagenum_right - len:
               (rm - lm >> 1) + lm - (len >> 1);
      }
      gr_clipx1 = 2;
      gr_clipy1 = (int)fl;
      gr_clipx2 = bitln - 2;
      gr_clipy2 = gr_clipy1 + nl - 1;
      scrbase = (long)s_image + (y? bytln * (long)y: -(bytln * fl));
      gr_text( pagenum, x, fh, 1, MYSFONT );
      if (pageptr[HPNPALT]) {
         if (number & 0x01)
            pageptr[HPNPRIGT] = restore;
         else
            pageptr[HPNPLEFT] = restore;
      }
   }
}

/* EOF */
