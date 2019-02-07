/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemext.h>
#include <obdefs.h>
#include <gemdefs.h>
#include "easy.h"
#include "chaos.h"

do_nvert()

/*
** Routine to determine how many vertices to use.
*/
{
   short          fx, fy, fw, fh, sx, sy, sw, sh, button, oldnverts;

   long           prast;   /* Pointer to raster block for saving screen */
   long           saverast();

   OBJECT         *form;

   TEDINFO        *string;

   extern char    buffer[120];
   extern short   nverts;
/*
** Set the value of the string, then open the dialog box.
*/
   rsrc_gaddr(R_TREE, FRMNVERT, &form);
   string = (TEDINFO *) form[NVERTSTR].ob_spec;
   sprintf(buffer, "%2d", nverts);
   strcpy(string->te_ptext, buffer);
   form_center(form, &fx, &fy, &fw, &fh);
   prast = saverast(fx, fy, fw+2, fh+2);   /* Save screen under dialog box */
   objc_box(form, NVERTSTR, &sx, &sy, &sw, &sh);
   form_dial(FMD_START, 112, 0, 72, 20, fx, fy, fw, fh);
   form_dial(FMD_GROW, 112, 0, 72, 20, fx, fy, fw, fh);
   objc_draw(form, 0, 8, fx, fy, fw, fh);
/*
** Watch the dialog box to see what is pressed.
*/
   oldnverts = nverts;
   do DO
      SHOWMOUSE;
      button = form_do(form, 0);
      HIDEMOUSE;
      if(button EQ NVERTUP0) nverts += 1;
      if(button EQ NVERTUP1) nverts += 10;
      if(button EQ NVERTDN0) nverts -= 1;
      if(button EQ NVERTDN1) nverts -= 10;
/*
** Check that the value is between 3 and 25.
*/
      if(nverts LT 3) nverts = 3;
      if(nverts GT 25) nverts = 25;
/*
** Encode the new value, then update the dialog box.
*/
      sprintf(buffer, "%2d", nverts);
      strcpy(string->te_ptext, buffer);
      objc_draw(form, NVERTSTR, 8, sx, sy, sw, sh);
   REPEAT while ((button NE NVERTCAN) AND (button NE NVERTOK));

   if(button EQ NVERTCAN) nverts = oldnverts;  /* Cancel button chosen */
/*
** Remove the dialog box.
*/
   form_dial(FMD_SHRINK, 112, 0, 72, 20, fx, fy, fw, fh);
   form_dial(FMD_FINISH, 112, 0, 72, 20, fx, fy, fw, fh);
}
