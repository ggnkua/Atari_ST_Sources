/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "easy.h"
#include "chaos.h"

about()

/*
** Routine to display the ABOUT CHAOS dialog box. There are three different
** dialog boxes, depending on the display resolution: FRMABTH, FRMABTM and 
** FRMABTL for high, medium and low resolution, respectively. Besides displaying
** the relevent info, the dialog box has an representation of an Atari monitor,
** in which is being drawn the default chaos pattern. It draws 1000 points, then
** start deleting points as it draws more. For example, it deletes the first 
** point, then draws the 1001st point, deletes the second point, then draws the
** 1002nd point, etc. This process is stopped when any keyboard key is pressed.
*/

{
   short x, y, w, h, dialbox, screen, sx, sy, sw, sh;
   short target, i, xy[1000][2], status, pos;
   
   OBJECT *form;
   
   double xvert[3], yvert[3], xpos, ypos, oldx, oldy;
   
   char string[4];
   
   LOGICAL palflag;
   
   extern short newpalet[16], oldpalet[16];
   
   extern LOGICAL chaospalet;
   
/*
** Set the palette back to normal if using a colour screen.
*/
   palflag = chaospalet;
   if(chaospalet) THEN  /* Switch palet to normal */
      chaospalet = FALSE;
      setpalet(oldpalet);
   ENDIF
/*
** Determine which dialog box to open, then open it.
*/
   switch(nplanes) DO
      case 1: DO
         dialbox = FRMABTH;
         screen = ABTHSCRN;
         break;
      ENDCASE
      case 2: DO
         dialbox = FRMABTM;
         screen = ABTMSCRN;
         break;
      ENDCASE
      case 4: DO
         dialbox = FRMABTL;
         screen = ABTLSCRN;
         break;
      ENDCASE
   ENDSWITCH
   
   rsrc_gaddr(R_TREE, dialbox, &form);
   form_center(form, &x, &y, &w, &h);
   objc_box(form, screen, &sx, &sy, &sw, &sh);  /* Position of "screen" */
   form_dial(FMD_START, 0, 20, 60, 10, x, y, w, h);
   form_dial(FMD_GROW, 0, 20, 60, 10, x, y, w, h);
   objc_draw(form, 0, 8, x, y, w, h);
/*
** Now the dialog box is up on the screen. Draw the chaos in the Atari screen.
*/
   xvert[0] = sx + sw/2;   /* Top center */
   yvert[0] = sy;
   xvert[1] = sx;          /* Bottom left */
   yvert[1] = sy + sh;
   xvert[2] = sx + sw;     /* Bottom right */
   yvert[2] = sy + sh;
   target = (rand() MOD 3);
   oldx = xvert[target];
   oldy = yvert[target];
   vsm_color(handle, BLACK);
   vsin_mode(handle, 4, 2);
   for(i=0; i LT 1000; ++i) DO
      target = (rand() MOD 3);
      xpos = oldx + (xvert[target] - oldx) / 2.0;
      ypos = oldy + (yvert[target] - oldy) / 2.0;
      xy[i][0] = xpos;
      xy[i][1] = ypos;
      v_pmarker(handle, 1, xy[i]);
      oldx = xpos;
      oldy = ypos;
   ENDDO
/*
** Now start erasing the old points before drawing new ones. Check for a
** keystroke to exit the loop.
*/
   for(i=1000; ; ++i) DO
      target = (rand() MOD 3);
      xpos = oldx + (xvert[target]-oldx) / 2.0;
      ypos = oldy + (yvert[target]-oldy) / 2.0;
      vsm_color(handle, WHITE);
      pos = i MOD 1000;
      v_pmarker(handle, 1, xy[pos]);   /* Erase the old point */
      xy[pos][0] = xpos;
      xy[pos][1] = ypos;
      vsm_color(handle, BLACK);
      v_pmarker(handle, 1, xy[pos]);
      oldx = xpos;
      oldy = ypos;
      status = vsm_string(handle, 1, 0, xy, string); /*  Check for keypress */
      if(status EQ 1) break;
      if(i GT 32000) break;   /* Check for overflow of short */
   ENDDO
/*
** Remove the dialog box.
*/
   if(palflag NE chaospalet) THEN
      chaospalet = palflag;
      setpalet(newpalet);
   ENDIF
   form_dial(FMD_SHRINK, 0, 20, 60, 10, x, y, w, h);
   form_dial(FMD_FINISH, 0, 20, 60, 10, x, y, w, h);
}
