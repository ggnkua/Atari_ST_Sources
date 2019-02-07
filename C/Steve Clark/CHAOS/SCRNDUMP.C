/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include "easy.h"

scrndump(x1, y1, x2, y2)

short x1, y1, x2, y2;

/*
** This routine dumps the specified rectangle of the screen (points passed are
** the uppper left and lower right corners) to an Epson-compatible printer.
** There are two printing speeds available. For colour, the slower one uses a
** 3 x 6 attay of dots per screen pixel and therefore can have produce 19
** shades of grey. The faster one uses a 3 x 2 grid, so can have only 7 shades.
** However, this only requires one pass of the print head per 3 rows of pixels,
** rather than 3. The following discussion is for the slower, more accurate
** mode.

    screen       dots per inch        dots per screen pixel     max number of
  resolution     horiz.   vert.        horizont.  vertical     possible shades

   High           80       144            1           2              2
   
   Medium         240      216            3           6              19
   
   Low            120      216            3           6              19
   
** The screen colours are printed as different shades. The shades are chosen
** by the brightness of the colour. Each colour can have a value of 0 - 7 for
** each of red, green and blue, where 0 is none of the colour, and 7 is 
** brightest. Therefore the brightest colour, white, has a brightness of 
** 21 = 7 + 7 + 7. Since there are 21 brightness values and 512 possible 
** colours, and just 19 possible shades of grey, the three darkest colours 
** (0=black, 1 and 2) will be printed as black. The patterns for the 3x6 grids
** are held in the array SHADE. This is a 2D array, where the first dimension
** represents the 19 shades and the second dimention is the three columns for
** each shade grid. The rows of the grid are specified in the lowest six bits
** of the byte, where the most significant bit will be printed at the top. The
** array STRIP contains the bit-map of each strip that is sent to the printer:
** each byte is interpretted by the printer as a vertical column of 8 dots, high
** bit at the top. The array MASK contains three masks for the three interleaved
** strips that have to be printed for the colour resolutions.
**
** For the quick and dirty print mode,

    screen       dots per inch        dots per screen pixel     max number of
  resolution     horiz.   vert.        horizont.  vertical     possible shades

   High           80       72             1           1              2
   
   Medium         240      72             3           2              7
   
   Low            120      72             3           2              7
   
** The method of determining the shading is similar with the accurate printing,
** except there are only 7 grey shades. White gets pattern 6 (no dots) and
** the remaining patterns are split amoungst the remaining 20 intensities. The
** array is called FSHADE.
*/

{
   static unsigned char stripmask[2][3] = {{32, 16, 8}, {4, 2, 1}};
   static unsigned char shade[19][3] = {{63,63,63}, {63,59,63}, {63,45,63},
            {59,47,61}, {55,29,59}, {42,63,29}, {21,63,42}, {21,62,21},
            {42,29,42}, {21,42,21}, {42,17,42}, {21,32,21}, {42,0,21},
            {21,0,34}, {8,34,4}, {4,16,2}, {0,18,0}, {0,4,0}, {0,0,0}};
   static unsigned char fshade[7][3] = {{3,3,3}, {3,2,3}, {3,0,3}, {1,2,1},
            {2,0,1}, {0,2,0}, {0,0,0}};

   unsigned char strip[1920], lf1[5], lf2[5], bitmask;
   
   short ibit, x, y, flag, colour, byte, istrip, mode, palette[16], intens[16];
   short oldy, i, last, button, nstrips;
   
   LOGICAL fast;
   
/*
** Determine whether the printing should be quick and dirty or slow and
** accurate.
*/
   SHOWMOUSE;
   sprintf(strip, "[2][%s| |%s][Fast|Accurate|Cancel]", 
         "          Print how?        ", 
         "   (Press any key to stop)");
   button = form_alert(1, strip);
   HIDEMOUSE;
   if(button EQ 3) return;
   fast = FALSE;
   if(button EQ 1) fast = TRUE;
   
   sprintf(lf1, "%c@", ESCAPE);
   printcha(lf1, 2, 0); /* Reset printer to power-on defaults */
   y = y1;

   if(nplanes EQ 1) THEN    /* Hi-resolution monochrome */
      sprintf(lf1, "%c~0%c", ESCAPE, 1);  /* Set to 1/144" LF */
      sprintf(lf2, "%c~0%c", ESCAPE, 15);  /* Set LF to 15/144" */
      do DO
         for(byte=0; byte LT 640; ++byte) strip[byte] = 0;  /* Zero out strip */
         last = 0;
         for(ibit=7; ibit GE 0; --ibit) DO
            if(y GT y2) break;
            bitmask = 1 << ibit;
            byte = 0;
            for(x=x1; x LE x2; ++x) DO    /* Once for each column */
               v_get_pixel(handle, x, y, &flag, &colour);
               if(flag) THEN
                  strip[byte] |= bitmask;
                  last = max(last,x);
               ENDIF
               ++byte;
            ENDDO
            ++y;
         ENDDO
      printcha(lf1, 4, 0); /* Set LF to 1/144" */
      plotline(strip, last, 4, 1);  /* Plot the strip */
      if(NOT fast) THEN    /* Print the same line again, advanced 1/144" */
         plotline(strip, last, 4, 0);
      ENDIF
      printcha(lf2, 4, 1);    /* Advance 15/144" */
      if(chk_stop() EQ 1) return;
      REPEAT while (y LE y2);
   ELSE THEN   /* Colour monitor of one sort or another */
/*
** Determine the intensity of each colour within the palette.
*/
   getpalet(palette);
   for(i=0; i LT 16; ++i) DO
      intens[i] = (palette[i]>>8) + ((palette[i]>>4)&15) + (palette[i]&15) - 3;
      if(intens[i] LT 0) intens[i] = 0;
      if(fast) intens[i] /= 3;   /* Only 7 intensities available */
   ENDDO
   mode = 3;   /* 240 dpi horizontally */
   if(nplanes EQ 4) mode = 1; /* Low-speed double density */
   if (fast) THEN
      sprintf(lf1, "%c~0%c", ESCAPE, 15);    /* Set LF to 15/144" */
      nstrips = 1;
   ELSE THEN
      nstrips = 3;
      sprintf(lf1, "%c3%c%c", ESCAPE, 1, NULL);  /* Set printer to 1/216" LF */
      sprintf(lf2, "%cJ%c\r", ESCAPE, 21);  /* One-time LF of 21/216" */
   ENDIF
   last = 1920;
   printcha(lf1, 4, 0);
   do DO
      oldy = y;
      for(istrip=0; istrip LT nstrips; ++istrip) DO   /* Once for each stip */
         y = oldy;                                    /* per row of pixels */
         for(byte=0; byte LT last; ++byte) strip[byte] = 0; /* Zero array */
         last = 0;
         for(ibit=3; ibit GE 0; --ibit) DO   /* Two bits per row of pixels */
            if(y GT y2) break;
            byte = 0;
            for(x = x1; x LE x2; ++x) DO  /* Once for each column */
               v_get_pixel(handle, x, y, &flag, &colour);
               if(flag) THEN
                  if(fast) THEN
                     for (i=0; i LT 3; ++i) DO  /* 3 dots horiz per pixel */
                        strip[byte] |= (fshade[intens[colour]][i]) << (2*ibit);
                        ++byte;
                     ENDDO
                  ELSE THEN   /* Accurate representation */
                     for(i=0; i LT 3; ++i) DO /* 3 dots horiz per pixel */
                        if(stripmask[0][istrip]&shade[intens[colour]][i])
                                 strip[byte] |= 1 << (2*ibit + 1);
                        if(stripmask[1][istrip]&shade[intens[colour]][i])
                                 strip[byte] |= 1 << 2*ibit;
                        ++byte;
                     ENDDO
                  ENDDO
                  last = max(last, byte);
               ELSE byte += 3;
            ENDDO
            ++y;
         ENDDO
         plotline(strip, last, mode, 1);  /* Plot the strip */
      ENDDO
      if (NOT fast) printcha(lf2, 4, 0);  /* Linefeed to next set of 3 strips */
      oldy += 4;
      if(chk_stop() EQ 1) return;
   REPEAT while(y LE y2);
   ENDIF
}

chk_stop()

/*
** Routine to see if any key has been pressed. If one has, return a 1 to 
** indicate to the calling routine to stop printing.
*/
{
   short status, button, xy[2];
   char string[3];
   
   vsin_mode(handle, 4, 2);
   xy[0] = 0;
   xy[1] = 0;
   status = vsm_string(handle, 1, 0, xy, string);
   if (status EQ 1) THEN   /* A key has been pressed */
      SHOWMOUSE;
      button = form_alert(2,"[2][   Really stop?   ][Right NOW|Continue]");
      HIDEMOUSE;
      if (button EQ 1) return(1);
   ENDIF
   return(0);
}
