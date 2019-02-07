/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "easy.h"
#include "chaos.h"

do_niter()

/*
** Routine to determine the number of points to plot.
*/
{
   short          fx, fy, fw, fh, sx, sy, sw, sh, button;

   long           olditer, tempval;

   OBJECT         *form;

   TEDINFO        *string;

   extern char    buffer[120];
   extern long    niterations;
/*
** Set the value of the string, then open the dialog box.
*/
   tempval = niterations / 1000.0;
   rsrc_gaddr(R_TREE, FRMNITER, &form);
   string = (TEDINFO *) form[NITERSTR].ob_spec;
   sprintf(buffer, "%6D", tempval);
   strcpy(string->te_ptext, buffer);
   form_center(form, &fx, &fy, &fw, &fh);
   objc_box(form, NITERSTR, &sx, &sy, &sw, &sh);
   form_dial(FMD_START, 112, 0, 72, 20, fx, fy, fw, fh);
   form_dial(FMD_GROW, 112, 0, 72, 20, fx, fy, fw, fh);
   objc_draw(form, 0, 8, fx, fy, fw, fh);
/*
** Watch the dialog box to see what is pressed.
*/
   olditer = niterations / 1000.0;
   do DO
      SHOWMOUSE;
      button = form_do(form, 0);
      HIDEMOUSE;
      if(button EQ NITERUP3) tempval += 1;
      if(button EQ NITERUP4) tempval += 10;
      if(button EQ NITERUP5) tempval += 100;
      if(button EQ NITERUP6) tempval += 1000;
      if(button EQ NITERUP7) tempval += 10000;
      if(button EQ NITERUP8) tempval += 100000l;
      if(button EQ NITERDN3) tempval -= 1;
      if(button EQ NITERDN4) tempval -= 10;
      if(button EQ NITERDN5) tempval -= 100;
      if(button EQ NITERDN6) tempval -= 1000;
      if(button EQ NITERDN7) tempval -= 10000;
      if(button EQ NITERDN8) tempval -= 100000l;
/*
** Check that the value is above 1000.
*/
      if(tempval LT 1) tempval = 1;
/*
** Encode the new value, then update the dialog box.
*/
      sprintf(buffer, "%6D", tempval);
      strcpy(string->te_ptext, buffer);
      objc_draw(form, NITERSTR, 8, sx, sy, sw, sh);
   REPEAT while ((button NE NITERCAN) AND (button NE NITEROK));

   if(button EQ NITERCAN) tempval = olditer;
   niterations = tempval * 1000.0;
/*
** Remove the dialog box and restore the screen underneath it.
*/
   form_dial(FMD_SHRINK, 112, 0, 72, 20, fx, fy, fw, fh);
   form_dial(FMD_FINISH, 112, 0, 72, 20, fx, fy, fw, fh);
}

