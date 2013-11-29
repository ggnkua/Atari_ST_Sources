/* EZ-Score Plus 1.1
 * Printer output remapping module for nine-pin printers (remap09.c)
 *
 * by Craig Dickson
 * for Hybrid Arts, Inc.
 * Copyright 1988 Hybrid Arts, Inc.
 * All Rights Reserved
 *
 * File opened:   05 February 1988
 * Last modified: 11 March 1988
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


int   cd_line;
short cd_shift;
short cd_array[24];
long  cd_sbyte;


prt_img09()
{
   int   retval;
   register int   dat, i, j, vlim;
   char  length[2], *mode;

#if DEBUG
   if (dbug)
      blit_it();
#endif
   retval = FALSE;
   init_nextpb();
   mode = (pageptr[HROUGH])? dmode: fmode;
   vlim = printer->vertical_limit;
   for (i = 0; !abortp && i < ahite >> 3; i++) {
      if (!(i % 3) && voff >= vlim) {
         retval = TRUE;
         break;
      }
      if (i % 3 != 2) {
         prtstring( set_1_216[0], 1, &set_1_216[1] );
         setvoff( printer->intrlv_linefeed );
      } else {
         prtstring( set_22_216[0], 1, &set_22_216[1] );
         setvoff( printer->i_nxln_linefeed );
      }
      dat = data_nextpb();
      if (printer->lines_inch == 216 || i % 3 != 1) {
         if (dat && (pageptr[HFINAL] || !(i % 3))) {
            length[0] = (char)(dat & 0xFF);
            length[1] = (char)(dat >> 8);
            prtstring( mode[0], 1, &mode[1] );
            prtstring( 2, 1, length );
            for (j = dat; j; j--)
               Bconout( PRT, get_nextpb() );
            if (!abortp && pageptr[HDSTRKON]) {
               bline_nextpb();
               prtchar( 0x0d );	/* cr */
               prtstring( mode[0], 1, &mode[1] );
               prtstring( 2, 1, length );
               for (j = dat; j; j--)
                  Bconout( PRT, get_nextpb() );
            }
         } else
            jump_nextpb( 1 );
         prtcrlf();
      } else
         jump_nextpb( 1 );
   }
   return retval;
}


init_nextpb()
{
   cd_line = 0;
   cd_sbyte = 0L;
   cd_fillarray();
}


cd_fillarray()
{
   register int   i;
   register int   sbyte;
   register short *array, *image;

   array = cd_array;
   image = &s_image[cd_sbyte];
   sbyte = 0;
   for (i = 7; i >= 0; i--) {
      array[i] = image[sbyte];
      if (!pageptr[HFINAL])
         array[i] |= image[sbyte + bytln] | image[sbyte + bytln + bytln];
      else if (!(cd_line % 3) && printer->lines_inch == 144)
         array[i] |= image[sbyte + bytln];
      sbyte += bytln * 3;
   }
   cd_shift = 7;
}


line_nextpb()
{
   if (cd_sbyte % bytln) {
      cd_sbyte += bytln - (cd_sbyte % bytln);
      if (!(cd_line % 3 - 2))
         cd_sbyte += bytln * 21;
      cd_line++;
      cd_fillarray();
   }
}


bline_nextpb()
{
   if (cd_sbyte) {
      cd_sbyte = (cd_sbyte / bytln) * bytln;
      cd_fillarray();
   }
}


jump_nextpb( lines )
register int lines;
{
   register int   i;

   for (i = 0; i < lines; i++) {
      cd_sbyte++;
      line_nextpb();
   }
}


get_nextpb()
{
   register short *array, shift;
   register int   dbyte, i;
   register long  sbyte;

   shift = cd_shift;
   array = cd_array;
   dbyte = 0;
   for (i = 0; i < 8; i++)
      dbyte |= (array[i] >> shift & 0x01) << i;
   if (shift)
      cd_shift--;
   else {
      sbyte = cd_sbyte;
      sbyte++;
      if (!(sbyte % bytln))   /* prevent overflowing to the next line;  */
         sbyte--;             /* just repeat last byte ad infinitum     */
      cd_sbyte = sbyte;       /* (it IS an error condition, after all)  */
      cd_fillarray();
   }
   return dbyte;
}


data_nextpb()
{
   register short *image;
   register int   dat, i, j, sbyte;

   line_nextpb();
   image = &s_image[cd_sbyte];
   dat = 0;
   for (i = bytln; i; i--) {
      sbyte = i - 1;
      for (j = pageptr[HFINAL]? 8: 24; j; j--) {
         if (image[sbyte] || !(cd_line % 3) && printer->lines_inch == 144 &&
               image[sbyte + bytln]) {
            dat = i << 3;
            break;
         }
         sbyte += (pageptr[HFINAL]? bytln * 3: bytln);
      }
      if (dat)
         break;
   }
   return dat;
}

/* EOF */
