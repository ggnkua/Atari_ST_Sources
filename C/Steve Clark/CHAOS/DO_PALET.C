/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include "easy.h"

/*
** These routines get and set the screen palette. The format of the data in 
** PALETTE is that expected by the XBIOS routine SETPALLET, since it takes 
** less storage space and is much easier to type in. Each colour value 
** takes 4 bits. The bits 0-3 are for blue, bits 4-7 are for green and 
** bits 8-11 are for red. VQ_COLOR() and VS_COLOR() require an array of 3 shorts,
** one for each colour, with a range of 0-1000. For reference, the default 
** palette is:

colour   value (hex)

   0        777   (white)
   1        000   (black)
   2        700   (red)
   3        070   (green)
   4        007   (blue)
   5        077   (cyan)
   6        770   (yellow)
   7        707   (magenta)
   8        555   (light grey)
   9        333   (dark grey)
   10       733   (light red)
   11       373   (light green)
   12       337   (light blue)
   13       377   (light cyan)
   14       773   (light yellow)
   15       737   (light magenta)
*/
setpalet(palette)

short palette[16];

{
   short i, rgb[3];
   
   for(i=0; i LT 16; ++i) DO
      rgb[0] = (palette[i] >> 8) * 1000 / 7;
      rgb[1] = ((palette[i] >> 4) & 15) * 1000 / 7;
      rgb[2] = (palette[i] & 15) * 1000 / 7;
      vs_color(handle, i, rgb);
   ENDDO
}

getpalet(palette)

short palette[16];
{
   short i, j, rgb[3];

   for(i=0; i LT 16; ++i) DO
      vq_color(handle, i, 1, rgb);
      for(j=0; j LT 3; ++j) rgb[j] = (++rgb[j] * 7) / 1000;
      palette[i] = rgb[2] + (rgb[1] << 4) + (rgb[0] << 8);
   ENDDO
}

