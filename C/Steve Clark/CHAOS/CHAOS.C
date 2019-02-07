/* Copyright 1990 by Antic Publishing, Inc. */
#include <gemstuff.h>
#include <gemdefs.h>
#include <obdefs.h>
#include "easy.h"
#include "chaos.h"

char buffer[120];

short nverts, percent, workarea[4], oldpalet[16], whandle;
short newpalet[16] = {0x777, 0x000, 0x111, 0x222, 0x223, 0x333, 0x334, 0x344,
                      0x444, 0x445, 0x554, 0x555, 0x655, 0x566, 0x666, 0x776};

long niterations, _stksize=10000;

double proportion, xvert[25], yvert[25];

LOGICAL chaospalet;

/*
**This program demonstrates the structured nature of chaotic events. A number
** of vertices are indicated by the user. This program chooses one randomly
** as the starting point. Another vertex is chosen, then a point is plotted 
** half way to the second vertex. A third vertex is chosen, and a second point
** is plotted half way between the first point and third vertex. This process
** repeats for the specified number of times. In practice, the user can specify
** the distance between the current point and vertex for plotting the next
** point.
*/

main()
{
   short       message[8], x, y, w, h;

   long        menu_adr, prast, saverast();

/*
** Start up GEM and display the menu bar.
*/
   gemstart();
   if(NOT rsrc_load("chaos.rsc")) THEN
      form_alert(1, "[3][Resource file not found!][Sorry]");
      gemend();
      exit(1);
   ENDIF
   rsrc_gaddr(R_TREE, MENUBAR, &menu_adr);
   menu_bar(menu_adr, TRUE);
/*
** Disable COLOURS menu item if hi-rez.
*/
   if(nplanes EQ 1) menu_ienable(menu_adr, COLOURS, 0);
/*
** Set the new palette after saving the current one.
*/
   if(nplanes EQ 2) THEN   /* Medium rez */
         newpalet[3] = 0x555;
         newpalet[2] = 0x333;
         newpalet[1] = 0x000;
   ENDIF
   getpalet(oldpalet);
   setpalet(newpalet);
   chaospalet = TRUE;
/*
** Get the size of the workarea and clear it to white. Need to open a full 
** screen window to be able to tell when a desk accessory has bee active.
*/
   wind_get(0, WF_FULLXYWH, &x, &y, &w, &h);
   whandle = wind_create(0, x, y, w, h);
   wind_open(whandle, x, y, w, h);
   workarea[0] = x;
   workarea[1] = y;
   workarea[2] = x + w - 1;
   workarea[3] = y + h - 1;
   vsf_interior(handle, 1);      /* Solid interior pattern */
   vsf_color(handle, 0);         /* White fill pattern */
   v_bar(handle, workarea);
   prast = saverast(x, y, w, h); /* Save the screen */
/*
** Initialize the values.
*/
   vsm_color(handle, 1);         /* Set marker colour to black */
   vsm_type(handle, 1);          /* Set polymarker type to points */
   niterations = 10000;
   nverts = 3;
   xvert[0] = workarea[2] / 2;
   yvert[0] = workarea[1];
   xvert[1] = workarea[0];
   yvert[1] = workarea[3];
   xvert[2] = workarea[2];
   yvert[2] = workarea[3];
   proportion = 0.50;
   percent = 50;
/*
** Watch the menu bar to see what is chosen.
*/
   MOUSEARROW;
   do DO
      SHOWMOUSE;
      evnt_mesag(message);
      HIDEMOUSE;
      if(message[0] EQ WM_REDRAW) THEN
         putrast(x, y, w, h, prast, 3, x, y, w, h);
         continue;
      ENDIF
      if(message[0] NE MN_SELECTED) continue; /* Skip the rest of the loop */
      HIDEMOUSE;
      switch (message[3]) DO
         case MENUDESK:
            switch (message[4]) DO
               case ABOUT:
                  about();
               break;
            ENDSWITCH
         break;

         case MENUFILE:
            switch (message[4]) DO
               case PRINT:
                  scrndump(workarea[0], workarea[1], workarea[2], workarea[3]);
               break;

               case SAVE:
                  writeone();
               break;
               
               case LOAD:
                  readone();
               break;

               case QUIT:
                  menu_bar(menu_adr, FALSE);
                  wind_close(whandle);
                  wind_delete(whandle);
                  setpalet(oldpalet);
                  free((char *) prast);
                  gemend();
                  exit(0);
               break;
            ENDSWITCH
         break;

         case MENUOPTS:
            switch (message[4]) DO
               case CLEAR:    /* Clear the workarea */
                  v_bar(handle, workarea);
                  free((char *) prast);
                  prast = saverast(x, y, w, h);
               break;

               case NVERTICE: /* Set the number of vertices */
                  do_nvert();
               break;

               case PVERTICE: /* Set the positions of the vertices */
                  menu_ienable(menu_adr, MENUDESK, 0);
                  menu_ienable(menu_adr, MENUFILE, 0);
                  menu_ienable(menu_adr, MENUOPTS, 0);
                  do_pvert();
                  menu_ienable(menu_adr, MENUDESK, 1);
                  menu_ienable(menu_adr, MENUFILE, 1);
                  menu_ienable(menu_adr, MENUOPTS, 1);
               break;

               case DISTANCE: /* Set the distance to move between points */
                  do_dist();
               break;

               case NITER:    /* Set the number of points to plot */
                  do_niter();
               break;

               case COLOURS:  /* Switch between grey and user's palette */
                  if(chaospalet) THEN  /* Switch to user-defined palette */
                     chaospalet = FALSE;
                     menu_icheck(menu_adr, COLOURS, 1);   /* Check mark on */
                     setpalet(oldpalet);
                  ELSE THEN
                     chaospalet = TRUE;
                     menu_icheck(menu_adr, COLOURS, 0);    /* Check mark off */
                     setpalet(newpalet);
                  ENDIF
               break;
               
               case START:    /* Draw the points on the screen */
                  do_chaos();
                  free((char *) prast);
                  prast = saverast(x, y, w, h);
               break;
            ENDSWITCH
         break;
      ENDSWITCH

      menu_tnormal(menu_adr, message[3], TRUE);
   REPEAT while(TRUE);
}
