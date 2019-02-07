/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include "easy.h"
#include "chaos.h"

do_chaos()  /********************************  DO_CHAOS  *******************/

/*
** Routine to plot the points on the screen. For colour monitors, the palette
** is set up such that each pixel gets darker each time a point lands on it. It
** starts off at colour 0 (background: white). After the first hit, it is colour
** 15 (or 3 for medium rez), which is the lightest, and progresses towards 1
** (black) with each subsequent hit. The palette is set so that color 1 remains
** black so the menu, dialog boxes, etc, are not screwed up.
** After every 128 points are drawn, check for a keypress to stop plotting.
*/

{
   static short target, xy[2], xmsg, ymsg, completed, limit, colour, flag;
   short stopflag;

   static double x, y, oldx, oldy;

   static long i, update, n;
   
   extern long niterations;
   extern double proportion, xvert[25], yvert[25];
   extern short nverts;
   extern char buffer[120];

/*
** Set the initial conditions.
*/
   target = (rand() MOD nverts);
   oldx = xvert[target];
   oldy = yvert[target];
   colour = 1;
   limit = 15;
   if(nplanes EQ 2) limit = 3;
/*
** Figure out where to put the "% completion" message (on the title bar at the
** right side.
*/
   xmsg = xrez - 6*letterw;
   ymsg = letterh - 2;
   v_gtext(handle, xmsg, ymsg, "   0\%");
   completed = 0;
   update = niterations / 20;
   n = 0;
   stopflag = 0;
   for(i=1; i LE niterations; ++i) DO
      if(++stopflag EQ 128) THEN /* Check for a keypress to stop plotting */
         if(chk_stop() EQ 1) break;
         stopflag = 0;
      ENDIF
      target = (rand() MOD nverts);
      x = oldx + proportion * (xvert[target] - oldx);
      y = oldy + proportion * (yvert[target] - oldy);
      if(nplanes NE 1) THEN   /* Colour display */
         v_get_pixel(handle, (short)x, (short)y, &flag, &colour);/* Get color */
         if(colour EQ 0) colour = limit + 1;
         colour = max(--colour, 1);
         vsm_color(handle, colour);    /* Set polymarker colour index */
      ENDIF
      xy[0] = x;
      xy[1] = y;
      v_pmarker(handle, 1, xy);
      oldx = x;
      oldy = y;
      if(++n GE update) THEN  /* Update "% completed" message */
         n = 0;
         completed += 5;
         sprintf(buffer, "%4d\%", completed);
         v_gtext(handle, xmsg, ymsg, buffer);
      ENDIF
   ENDDO
   SHOWMOUSE;
}
