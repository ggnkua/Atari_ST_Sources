/* EZ-Score Plus 1.1
 * Printer output - staff maintenance (pdraw.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   06 March 1988
 * Last modified: 07 March 1988
 */

overlay "ezp"

#include <gem.h>
#include <misc.h>

#include "ezp.h"
#include "ezprsc.h"
#include "structs.h"
#include "prtcnf.h"
#include "symbdefs.h"
#include "text.h"
#include "extern.h"
#include "cextern.h"
#include "header.h"


draw_staves( sys )
register int sys;
{
   int   b, imgy, nlines, p, staffmt;
   register int   i, midsize, x;
   long  fline;
   char  mn[6];

   /* draw left-most bar line unless in lead-sheet format */
   if (visys > 1) {
      staffmt = getformat();
      if (staffmt == STAFFMT3)
         staffmt = STAFFMT4;
      bar_line( lmarg, staffmt, S_BAR );
   }
   /* draw measure number */
   if (pageptr[HMNSHOWN] && clip_img( measnum[sys], font_info[MYSFONT].fonth,
         &fline, &nlines, &imgy )) {
      gr_clipx1 = 2;
      gr_clipy1 = (int)fline;
      gr_clipx2 = rmarg;
      gr_clipy2 = gr_clipy1 + nlines - 1;
      scrbase = (long)s_image + (imgy? bytln * (long)imgy: -(bytln * fline));
      find_bar( lastb, lastp, &b, &p, 1 );
      x = bp_to_barn( b, p ) + ((int*)pageptr)[HMNOFF];
      if (x > 1) {
         itoa( x, mn, ndigits( x ));
         gr_text( mn, lmarg - strprolen( mn, MYSFONT ),
               font_info[MYSFONT].fonth, 1, MYSFONT );
      }
   }
   for (i = sys * stasys; i < sys * stasys + stasys; i++) {  /* draw staves */
      if (staffy[i]) {
         if (clip_img( staffy[i], staff.height, &fline, &nlines, &imgy )) {
            for (x = lmarg; x + 16 <= rmarg; x += 16)
               draw_img( &staff, fline, nlines, x, imgy, 1 );
         }
      }
   }
   if (brackets[sys].top) {                     /* draw left edge brackets */
      if (clip_img( brackets[sys].top, brackt.height, &fline, &nlines, &imgy ))
         draw_img( &brackt, fline, nlines, lmarg - 8, imgy, 1 );
      midsize = brackets[sys].size - brackt.height - brackb.height;
      if (clip_img( brackets[sys].top + brackt.height, midsize, &fline,
            &nlines, &imgy ))
         draw_img( &brackm, 0L, nlines, lmarg - 8, imgy, nlines );
      if (clip_img( brackets[sys].top + brackt.height + midsize, brackb.height,
            &fline, &nlines, &imgy ))
         draw_img( &brackb, fline, nlines, lmarg - 8, imgy, 1 );
   }
   if (braces[sys].top) {                       /* draw left edge braces */
      if (clip_img( braces[sys].top, (braces[sys].psym)->height, &fline,
            &nlines, &imgy ))
         draw_img( braces[sys].psym, fline, nlines,
               lmarg - ((braces[sys].psym)->bt_width << 3), imgy, 3 );
   }
}


draw_img( bitblk, cline, nlines, img_x, img_y, loop )
PSYM *bitblk;
long cline;
int nlines, img_x, img_y, loop;
{
   register int   bts, bw, cnt, test;
   register short *dest, *src;

   bw = bitblk->bt_width;
   src = &bitblk->image[bw * (cline / loop)];
   dest = &s_image[bytln * img_y + (img_x >> 3)];
   while (nlines > 0) {
      test = min( loop, nlines );
      for (cnt = 0; cnt < test; cnt++) {
         for (bts = 0; bts < bw; bts++)
            dest[bts] |= src[bts];
         dest = &dest[bytln];
         if (!(++cline % loop)) {
            cnt++;
            break;
         }
      }
      src = &src[bw];
      nlines -= cnt;
   }
}

/* EOF */
