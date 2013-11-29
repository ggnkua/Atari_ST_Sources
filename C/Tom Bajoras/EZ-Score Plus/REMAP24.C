/* EZ-Score Plus 1.1
 * Printer output remapping module for 24-pin printers (remap24.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   24 February 1988
 * Last modified: 30 March 1988
 */

overlay "ezp"

#include <gem.h>
#include <tos.h>
#include <misc.h>

#include "ezp.h"
#include "structs.h"
#include "prtcnf.h"
#include "extern.h"
#include "header.h"
#include "cextern.h"


extern int     cd_line;
extern short   cd_shift;
extern short   cd_array[];
extern long    cd_sbyte;

int   cd_count;


prt_img24()
{
   int   retval;
   register int   dat, i, j, vlim;
   char  length[2], *mode;

#if DEBUG
   if (dbug)
      blit_it();
#endif
   retval = FALSE;
   init_nex24();
   mode = (pageptr[HROUGH])? dmode: fmode;
   vlim = printer->vertical_limit;
   prtstring( set_8_72[0], 1, &set_8_72[1] );
   setvoff( printer->full_linefeed );
   for (i = 0; !abortp && i < ahite / 29; i++) {
      if (voff >= vlim) {
         retval = TRUE;
         break;
      }
      dat = data_nex24();
      if (dat) {
         length[0] = (char)(dat & 0xFF);
         length[1] = (char)(dat >> 8);
         prtstring( mode[0], 1, &mode[1] );
         prtstring( 2, 1, length );
         for (j = dat * 3; j; j--)
            Bconout( PRT, get_nex24() );
         if (!abortp && pageptr[HDSTRKON]) {
            bline_nex24();
            prtchar( 0x0d );		/* cr */
            prtstring( mode[0], 1, &mode[1] );
            prtstring( 2, 1, length );
            for (j = dat * 3; j; j--)
               Bconout( PRT, get_nex24() );
         }
      } else
         jump_nex24( 1 );
      prtcrlf();
   }
   return retval;
}


init_nex24()
{
   cd_line = 0;
   cd_sbyte = 0L;
   cd_fill24();
}


cd_fill24()
{
   register int   count, i, sbyte;
   register short *array, *image;
   register long  rastercount;

   array = cd_array;
   image = &s_image[cd_sbyte];
   count = sbyte = 0;
   for (i = 23, rastercount = cd_line * 24; i >= 0; i--, rastercount++) {
      array[i] = image[sbyte];
      sbyte += bytln;
      count++;
      if (!(rastercount % 5)) {     /* compensate for odd aspect ratio by  */
         array[i] |= image[sbyte];  /* condensing each set of 6 lines to 5 */
         sbyte += bytln;
         count++;
      }
   }
   if (count == 28)                 /* this happens every fifth pass; must */
      array[0] |= image[sbyte];     /* always be 29 rasters for 24 pins!   */
   cd_shift = 7;
   cd_count = 24;
}


line_nex24()
{
   if (cd_sbyte % bytln) {
      cd_sbyte += (bytln - (cd_sbyte % bytln)) + bytln * 28;
      cd_line++;
      cd_fill24();
   }
}


bline_nex24()
{
   if (cd_sbyte % bytln) {
      cd_sbyte = (cd_sbyte / bytln) * bytln;
      cd_fill24();
   }
}


jump_nex24( lines )
register int lines;
{
   register int   i;

   for (i = 0; i < lines; i++) {
      cd_sbyte++;
      line_nex24();
   }
}


get_nex24()
{
   register short *array, shift;
   register int   dbyte, i;
   register long  sbyte;

   shift = cd_shift;
   array = cd_array;
   dbyte = 0;
   cd_count -= 8;
   for (i = cd_count + 7; i >= cd_count; i--)
      dbyte |= (array[i] >> shift & 0x01) << (i & 0x07);
   if (!cd_count) {
      cd_count = 24;
      if (shift)
         cd_shift--;
   }
   if (!shift && cd_count == 24) {
      sbyte = cd_sbyte;
      if (!(++sbyte % bytln))
         sbyte--;
      cd_sbyte = sbyte;
      cd_fill24();
   }
   return dbyte;
}


data_nex24()
{
   register short *image;
   register int   dat, i, j, sbyte;

   line_nex24();
   image = &s_image[cd_sbyte];
   dat = 0;
   for (i = bytln; i; i--) {
      sbyte = i - 1;
      for (j = 29; j; j--) {
         if (image[sbyte]) {
            dat = i << 3;
            break;
         }
         sbyte += bytln;
      }
      if (dat)
         break;
   }
   return dat;
}

/* EOF */
