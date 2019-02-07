/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include <gemdefs.h>
#include "easy.h"

long saverast(x, y, w, h)

short x, y, w, h;    /* Coordinates on screen of raster to be saved */

/*
** This routine saves the specified screen raster to memory using the
** GEM routine vro_cpyfm(). It returns a pointer to the position of the raster
** in memory.
*/
{
   short xy[8], i;

   char *malloc();

   static FDB source = {0, 0, 0, 0, 0, 0, 0, 0, 0};
   FDB dest;

   HIDEMOUSE;
/*
** Determine the size of the raster and allocate the memory for it.
*/
   w += 2; h += 2;   /* Bug fixes */
   dest.fd_w = w;
   dest.fd_h = h;
   i = w / 16;
   dest.fd_wdwidth = ((w MOD 16) EQ 0) ? i : i+1;
   dest.fd_stand = 0;
   dest.fd_nplanes = nplanes;
   dest.fd_r1 = 0;
   dest.fd_r2 = 0;
   dest.fd_r3 = 0;
   dest.fd_addr = (long) malloc(2 * dest.fd_wdwidth * h * nplanes);
   if(dest.fd_addr EQ NULL) THEN
      form_alert(1, "[1][Insufficient memory|to store raster][Okay]");
      return(NULL);
   ENDIF
/*
** Copy the raster to memory.
*/
   xy[0] = x; xy[1] = y; xy[2] = x+w-1; xy[3] = y+h-1;
   xy[4] = 0; xy[5] = 0; xy[6] = w; xy[7] = h;
   vro_cpyfm(handle, 3, xy, &source, &dest);
   SHOWMOUSE;
   return(dest.fd_addr);
}

/******************************************************  PUTRAST  ***********/

putrast(x, y, w, h, pmem, mode, clipx, clipy, clipw, cliph)  

short x, y, w, h;    /* Position to write raster to screen */
long pmem;           /* Pointer to location in memory where raster is stored */
short mode;          /* Passed on to vro_cpyfm() */
short clipx, clipy, clipw, cliph;   /* Clipping rectangle */

/*
** This routine displays on the screen a raster that has been stored in memory
** by the function saverast().
** NOTE: It is the responsibility of the calling program to make sure that the
** raster saved at PMEM is of the width and height specified in the call to 
** this routine.
*/
{
   short xy[8], i;

   static FDB dest = {0, 0, 0, 0, 0, 0, 0, 0, 0};

   FDB source;

   LOGICAL clip;

   HIDEMOUSE;
   w += 2; h += 2; clipw += 2; cliph += 2;   /* Bug fixes */
   source.fd_addr = pmem;
   source.fd_w = w;
   source.fd_h = h;
   i = w / 16;
   source.fd_wdwidth = ((w MOD 16) EQ 0) ? i : i+1;
   source.fd_stand = 0;
   source.fd_nplanes = nplanes;
   source.fd_r1 = 0;
   source.fd_r2 = 0;
   source.fd_r3 = 0;
/*
** Set the clipping rectangle.
*/
   clip = FALSE;
   if((clipw NE 0) AND ( cliph NE 0)) THEN
      clip = TRUE;
      xy[0] = clipx; xy[1] = clipy; 
      xy[2] = clipx+clipw-1; xy[3]= clipy+cliph-1;
      vs_clip(handle, TRUE, xy);
   ENDIF
/*
** Copy the raster back to the screen.
*/
   xy[0] = 0; xy[1] = 0; xy[2] = w; xy[3] = h;
   xy[4] = x; xy[5] = y; xy[6] = x+w-1; xy[7] = y+h-1;
   vro_cpyfm(handle, mode, xy, &source, &dest);
/*
** Turn off the clipping rectangle.
*/
   if(clip) vs_clip(handle, FALSE, xy);

   SHOWMOUSE;
}
