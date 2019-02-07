/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include <gemdefs.h>
#include "easy.h"

do_pvert()  /***********************  DO_PVERT  **************************/

/*
** Subroutine to determine the positions of the vertices. See where the mouse 
** is when the left button is pressed, convert the position to double-precision
** and store it in XVERT and YVERT, then mark the spot on the screen. Also list
** the number of vertices on the menu bar at the right end. To aid in the 
** positioning of the vertices, temperarily draw a grid on the screen, 16
** across and 10 down.
** The specifying of points can be aborted by pressing any keyboard key.
*/

{
   extern short nverts; /* number of vertices */

   extern double xvert[25], yvert[25];    /* position of the vertices */

   short i, xy[25][2], dummy, xmsg, ymsg, event, button;
   
   extern char buffer[120];
   
   vsl_color(handle, 1);   /* Set polyline colour to black */
   vsm_type(handle, 3); /* Star polymarker */
   vswr_mode(handle, 3);   /* XOR writing mode */
   do_grid();     /* Write background grid */   
   xmsg = xrez - 6*letterw;
   ymsg = letterh - 2;
   for (i=0; i LT nverts; ++i) DO
      sprintf(buffer, "%2d/%-2d", i, nverts);
      vswr_mode(handle, 1);   /* REPLACE writing mode */
      v_gtext(handle, xmsg, ymsg, buffer);
      vswr_mode(handle, 3);   /* XOR writing mode */
      SHOWMOUSE;
         /*
         ** The evnt_button() waits for the left mouse button to be released.
         ** Without it, all vertices end up on top of each other, because
         ** evnt_multi() continues and soon as the mouse buttons goes down,
         ** and continues defining vertices since the button will still be down
         ** on subsequent passes throught the loop.
         */
      evnt_button(1, 1, 0, &dummy, &dummy, &dummy, &dummy);  /* Button up */
         /*
         ** Watch for a mouse or keyboard event. For evnt_multi() to work, we
         ** have to ignore what the MWC manual says and use the example provided
         ** by the Abacus book, "GEM Programers Reference," pg 319.
         */
      event = MU_KEYBD | MU_BUTTON;
      event = evnt_multi(event, 1, 1, 1, 0,0,0,0,0,0,0,0,0,0, &dummy,
               0, 0, &xy[i][0], &xy[i][1], &dummy, &dummy, &dummy, &dummy);
      if(event & MU_KEYBD) THEN  /* Keyboard key pressed. Abort this function? */
         button = form_alert(2, "[2][Abort?][Yes|No]");
         HIDEMOUSE;
         if(button EQ 2) THEN    /* Don't abort */
            --i;
            continue;
         ENDIF
         goto abort;
      ENDIF
      HIDEMOUSE;
      v_pmarker(handle, 1, xy[i]);
   ENDDO
   evnt_button(1, 1, 0, &dummy, &dummy, &dummy, &dummy);  /* Button up */
/*
** Write the temporary vertice positions into the permanent array.
*/
   for(i=0; i LT nverts; ++i) DO
      xvert[i] = (double)xy[i][0];
      yvert[i] = (double)xy[i][1];
   ENDDO
   
abort:;

/*
** Now erase the points and reset the polymarker type.
*/
   v_pmarker(handle, i, xy);
   vswr_mode(handle, 1);   /* REPLACE writing mode */
   v_gtext(handle, xmsg, ymsg, "     ");
   vswr_mode(handle, 3);   /* XOR writing mode */
   do_grid();     /* Erase the background grid */
   vsm_type(handle, 1);
   vswr_mode(handle, 1);   /* REPLACE writing mode */
}


do_grid()   /*******************************  DO_GRID  ***********************/

/*
** Draw a background grid, in XOR mode so that no point that are presently on
** the screen will be lost.
*/
{
   short x, y, xy[4], xinc, yinc;
   
   extern short workarea[4];

   xinc = (workarea[2] + 1) / 16;
   yinc = (workarea[3] - workarea[1]) / 10;
   xy[1] = workarea[1];
   xy[3] = workarea[3];
   for (x=xinc; x LT workarea[2]; x+=xinc) DO   /* Vertical lines */
      xy[0] = x;
      xy[2] = x;
      v_pline(handle, 2, xy);
   ENDDO
   xy[0] = workarea[0];
   xy[2] = workarea[2];
   for (y=workarea[1]+yinc; y LT workarea[3]; y+=yinc) DO   /* Horizont lines */
      xy[1] = y;
      xy[3] = y;
      v_pline(handle, 2, xy);
   ENDDO
}
