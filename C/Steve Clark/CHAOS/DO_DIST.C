/* Copyright 1990 by Antic Publishing, Inc.  */
#include <gemext.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "easy.h"
#include "chaos.h"

do_dist()

/*
** Routine to determine the proportion of the distance to move between the
** current position and the next vertex.
*/
{
   short          fx, fy, fw, fh, sx, sy, sw, sh, button, oldpercent;

   OBJECT         *form;

   TEDINFO        *string;

   extern char    buffer[120];
   extern short   percent;
   extern double  proportion;
/*
** Set the value of the string, then open the dialog box.
*/
   rsrc_gaddr(R_TREE, FRMDIST, &form);
   string = (TEDINFO *) form[DISTSTR].ob_spec;
   sprintf(buffer, "%2d", percent);
   strcpy(string->te_ptext, buffer);
   form_center(form, &fx, &fy, &fw, &fh);
   objc_box(form, DISTSTR, &sx, &sy, &sw, &sh);
   form_dial(FMD_START, 112, 0, 72, 20, fx, fy, fw, fh);
   form_dial(FMD_GROW, 112, 0, 72, 20, fx, fy, fw, fh);
   objc_draw(form, 0, 8, fx, fy, fw, fh);
/*
** Watch the dialog box to see what is pressed.
*/
   oldpercent = percent;
   do DO
      SHOWMOUSE;
      button = form_do(form, 0);
      HIDEMOUSE;
      if(button EQ DISTUP0) percent += 1;
      if(button EQ DISTUP1) percent += 10;
      if(button EQ DISTDN0) percent -= 1;
      if(button EQ DISTDN1) percent -= 10;
/*
** Check that the value is between 3 and 25.
*/
      if(percent LT 1) percent = 1;
      if(percent GT 99) percent = 99;
/*
** Encode the new value, then update the dialog box.
*/
      sprintf(buffer, "%2d", percent);
      strcpy(string->te_ptext, buffer);
      objc_draw(form, DISTSTR, 8, sx, sy, sw, sh);
   REPEAT while ((button NE DISTCAN) AND (button NE DISTOK));

   if(button EQ DISTCAN) percent = oldpercent;  /* Cancel button chosen */
   proportion = ((double) percent) / 100.0;
/*
** Remove the dialog box and restore the screen underneath it.
*/
   form_dial(FMD_SHRINK, 112, 0, 72, 20, fx, fy, fw, fh);
   form_dial(FMD_FINISH, 112, 0, 72, 20, fx, fy, fw, fh);
}
