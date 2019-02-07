
/* Copyright 1990 by Antic Publishing, Inc. */

/* Tab expansion/compression spacing should be set to '4' in your editor. */

/**************************************************************************
 *
 * SPINWEEL.C       Main module.
 *
 *   Authors:       Pete Ewing - Voodoo math in do_spyro() routine.
 *                  Ian Lepore - Everything else.
 *
 *   Related and Required Modules:
 *
 *                  Source Code:
 *
 *                    SPINWEEL C source...
 *
 *                       main.c     - Main drivers and spyro math code.
 *                       input.c    - Input & user interaction code.
 *                       gemstuff.c - GEM routines (init, window redraw, etc).
 *                       datadefs.c - Variable definitions.
 *
 *                    Header files...
 *
 *                       datadefs.h - Variable definitions.
 *                       gemsystm.h - Compatibility between GEM bindings.
 *                       gemfast.h  - VDI/AES header (like obdefs+gemdefs).
 *                       aesblit.h  - Header for aesblit routine.
 *                       picsave.h  - Header for picsave routines.
 *                       fastplot.h - Header for FastPlot routines.
 *                       osbind.h   - Standard DOS, BIOS, and XBIOS stuff.
 *
 *                    Canned Source Library routines...
 *
 *                       minipalt.c - Mini Pallete dialog.
 *                       aesblit.c  - Blit using AES buffer.
 *                       simumenu.c - Simulate AES menu handling.
 *                       picsave.c  - Save screen image as NEO or DEGAS.
 *                       fastplot.s - Fast pixel plotting routine.
 *
 *                  Link Libraries:
 *
 *                      (Your compiler may call some of these files by 
 *                       different names.)
 *
 *                       minstart.o - Application startup object file.
 *                       vdifast.a  - VDI bindings.
 *                       aesfast.a  - AES bindings.
 *                       libf.a     - Floating point math routines.
 *                       dlibs.a    - C compiler runtime library.
 *
 *                  Resource File Stuff:
 *
 *                       spinweel.rsc - Resource file.
 *                       spinweel.rsd - Resource definitions (for Kuma RCS).
 *                       spinweel.h   - Resource object names header.
 *
 *   Notes:
 *
 *                  Because the ST world currently has nothing like a 
 *                  standard programming environment, getting this program
 *                  to compile on different compilers might require tweaks.
 *                  One of the biggest sources of incompatibility is the
 *                  GEM interface.  This program was developed using my
 *                  GEMFAST Public Domain GEM bindings and utilities, and
 *                  the GEMFAST.H header file.  Because everyone isn't 
 *                  using GEMFAST (yet), I've tried to isolate the changes
 *                  required into a header file called GEMSYSTM.H.  If you
 *                  use GEMFAST, this code should be ready to go.  If you
 *                  don't, go into GEMSYSTM.H and change the #if statement
 *                  as indicated in the comments, and *hopefully* the
 *                  header file will handle everything automatically.
 *
 *                  You MUST be using GEMFAST release 1.3 or higher for this
 *                  code to compile correctly when GEMFAST.H is included.
 *                  Release 1.3 is available on BBS and major online systems
 *                  (BIX, CIS, GENIE, etc).  If you have an earlier release
 *                  of GEMFAST, you *might* be able to get a clean compile
 *                  by adding "#define GEMFAST_H 1" to the start of your
 *                  current GEMFAST.H file.  You may have to tweak a few
 *                  things, especially names of non-standard utilities.
 *
 *                  The header files work like this:
 *
 *                  - Every SPINWEEL module includes "datadefs.h".
 *                  - datadefs.h includes <osbind.h> and "gemsystm.h".
 *                  - gemsystm.h includes <gemfast.h> if the flag is
 *                    set for GEMFAST usage, or <obdefs.h> and <gemdefs.h>
 *                    if the flag is set for non-gemfast usage.  
 *                  - The 'canned source' modules include <gemfast.h>
 *                    directly.  If you don't use the GEMFAST system, you'll
 *                    have to go into each of the canned source routines 
 *                    and change the gemfast.h include to obdefs and gemdefs.
 *                    Conditional compilation code within the canned source
 *                    modules should handle any other needed changes based
 *                    on whether GEMFAST.H got included or not.
 *                  - "fastplot.h", "aesblit.h", and "picsave.h" are 
 *                    included only by the modules which use these routines.
 *
 *   Maintenance:
 *
 *     ??/??/??  -  v1.0
 *                  Primitive versions of this existed as early as 1987.
 *     06/18/89  -  v1.1
 *                  (Boy, do I know a lot more about GEM programming now.)
 *                  Cleaned up just about everything, converted lotsa
 *                  things to use routines from the 'canned source'
 *                  library (AESBLIT, etc).
 *     07/15/89  -  v1.2
 *                  Added 'smoothness' control, did more general cleanup
 *                  and extensively commented source code.
 *     08/12/89  -  v1.3
 *                  Added features to save/load screen images (at request
 *                  of the beta testers), added help screen.
 *     09/16/89  -  v1.4
 *                  Added option to draw using FastPlot or VDI, to allow
 *                  owners of large-screen systems to use this program.
 *                  Oddly enough, the drawing speed is the same whether
 *                  using FastPlot or VDI...This is basically because it's
 *                  the calculations that are the speed-limiting factor,
 *                  not the screen access.  But, I polished this beast up
 *                  and submitted it to STart as the vehicle to demo my
 *                  FastPlot system, so I'll be d*mned if I'm going to 
 *                  take it out just because it isn't any faster in this
 *                  particular application!
 *     09/25/89  -  v1.5
 *                  Bugfixes, performance tuning.
 *     12/02/89  -  v1.6
 *                  Disable color-related options when running in high rez.
 *                  Final cleanup for publication.
 *************************************************************************/

#include "datadefs.h"
#include "picsave.h"

/**************************************************************************
 *
 * do_spyro - Do spyro calcs, and draw the results.
 *
 *  To keep the drawing routine fairly fast, the most-used floating point
 *  variables are kept in registers while the loop is in progress.  Upon
 *  exiting the loop, the register vars are stored into static vars.  This
 *  allows the user to suspend drawing, change the pen color (or whatever)
 *  then resume drawing from where s/he left off.
 *
 *************************************************************************/

void
do_spyro()
{
    register float  r_angle,            /* the current pen angle.        */
                    r_rad_comb,         /* combined radius of 3 gears.   */
                    r_rol_ratio,        /* fixed:rolling gear size ratio.*/
                    r_pen_pos,          /* pen offset from rolling gear. */
                    r_angincr,          /* angle incr per loop iteration.*/
                    r_y_scale;          /* rez-dependant scaling factor. */
                    
    static   float  s_angle,            /* these variables store the     */
                    s_rad_comb,         /* values from the corresponding */
                    s_rol_ratio,        /* register vars above, when     */
                    s_pen_pos;          /* the user suspends drawing.    */

    int             dmy,                /* dummy var for GEM calls       */
                    access_method,      /* local copy of scrnaccess      */
                    pencolor,           /* local copy of pen color var   */
                    mouseb,             /* mouse button state            */
                    exit_requested,     /* loop control variable         */
                    chk_interval;       /* how often to check the mouse  */

    struct  {                           /* Plot col/row are defined in a */
            int     s_pcol;             /* structure so that if we use   */
            int     s_prow;             /* VDI for plotting it looks like*/
    } s_plot;                           /* a pxyarray to VDI.            */
    
#define pcol s_plot.s_pcol              /* Defines allow us to use simple*/
#define prow s_plot.s_prow              /* names instead of '.' names.   */ 

/*-------------------------------------------------------------------------
 * Set up loop control, force a mouse-check to happen on the first loop,
 * make a local (stack-allocated) copy of the pen color for faster access.
 * Make a register copy of the y-scaling factor for faster access.
 *-----------------------------------------------------------------------*/
 
    exit_requested = FALSE;
    chk_interval   = 1; 
    pencolor       = pen_color;
    r_y_scale      = y_scale;
    access_method  = scrnaccess;
    
/*-------------------------------------------------------------------------
 * If the 'new_shape' flag is set, calculate new starting values for the
 * register calc variables based on the new radius, pen position, etc.
 *
 * If the 'new_shape' flag is not set, reload the register calc variables
 * from the static copy of the variables.
 *
 * The angle increment var is always refreshed (via calc) from the 
 * smoothness variable, since that can be changed from the OPTIONS menu
 * without invoking 'new shape' from the COMMANDS menu.
 *
 * If the screen access method is VDI, set the polymarker color to the
 * current pen color.
 *-----------------------------------------------------------------------*/
 
    if (new_shape) {
        r_angle     = 0.0;
        r_rad_comb  = (float)(fix_irad + rol_irad);
        r_pen_pos   = (float)pen_pos;
        r_rol_ratio = r_rad_comb / (float)rol_irad;
        new_shape   = FALSE;
    } 
    else {
        r_angle     = s_angle;
        r_pen_pos   = s_pen_pos;
        r_rad_comb  = s_rad_comb;
        r_rol_ratio = s_rol_ratio;
    }

    r_angincr = smoothness / r_rad_comb; 
    
    if (access_method == VDIPLOT) {
        vsm_color(vdi_handle, pencolor);
    }

/*-------------------------------------------------------------------------
 * - Loop to calculate the pen positions based on the rolling gear moving
 *   around the fixed gear.  (This is voodoo; math confuses me - Ian).
 * - Call FastPlot to plot each new position in the current pen color.  
 * - If a slowfactor has been set, do an evnt_timer to slow things down.
 * - Every five iterations of the loop, we check the mouse status.  If the
 *   user is holding down the left button, we pop up the speed control. If
 *   the user is holding down the right button, we exit the loop. (New in
 *   v1.2: set the mouse check interval proportional to the current drawing
 *   speed to allow precision starts and stops at low speed).
 *-----------------------------------------------------------------------*/
 
    do  {
        
        /* 
         * calc the next point to be plotted... 
         */
        
        r_angle += r_angincr;
        pcol = fix_col + ( r_rad_comb * cos(r_angle) + 
                r_pen_pos * cos(r_angle * r_rol_ratio) );
        prow = fix_row + (r_y_scale * ( r_rad_comb * sin(r_angle) + 
                r_pen_pos * sin(r_angle * r_rol_ratio) ));
        
        /* 
         * plot the point... 
         */

        if (access_method == FASTPLOT) {
            fplot(pcol, prow, pencolor);
        } else {
            v_pmarker(vdi_handle, 1, &pcol);
        }
        
        /* 
         * slow down, if need be... 
         */

        if (slowfactor)
            evnt_timer(slowfactor,0);

        /*
         * check the mouse if the interval is up...
         */

        if (0 >= (--chk_interval)) {
            chk_interval = 5 - (slowfactor / 50);
            graf_mkstate(&dmy, &dmy, &mouseb, &dmy);
            if (mouseb & 0x0001)
                slowfactor = get_speed();
            if (mouseb & 0x0002) 
                exit_requested = TRUE;
        }
        
    } while (!exit_requested);

/*-------------------------------------------------------------------------
 * Before exiting, copy the register calc variables to the static 
 * variables, so we can resume drawing where we left off.
 *-----------------------------------------------------------------------*/
 
    s_angle     = r_angle;
    s_pen_pos   = r_pen_pos;
    s_rad_comb  = r_rad_comb;
    s_rol_ratio = r_rol_ratio;
    
} 

/**************************************************************************
 *
 * do_dialog - A generic dialog driver routine.
 *
 *************************************************************************/

static int
do_dialog(ptree)
    register OBJECT *ptree;
{
    GRECT dialrect;
    int   exitobj;
    
    form_center(ptree, &dialrect.g_x, &dialrect.g_y,
                       &dialrect.g_w, &dialrect.g_h);
                       
    form_dial(FMD_START, 0,0,0,0, dialrect);

    objc_draw(ptree, R_TREE, MAX_DEPTH, dialrect);

    exitobj = form_do(ptree, 0);

    ptree[exitobj].ob_state &= ~SELECTED;

    form_dial(FMD_FINISH, 0,0,0,0, dialrect);

    return exitobj;
}

/**************************************************************************
 *
 * do_cmdmenu - Dispatch routines to process items from the COMMANDS menu.
 *
 *  Some of the commands trash out the entire screen rather than confining
 *  themselves to the visible portion of our window.  If any accessories
 *  had open windows, we'll have erased them visually from the screen, but
 *  GEM will still belive they are visible.  As a workaround for all of
 *  this, we send a redraw message to the world (via FMD_FINISH) to insure
 *  that the entire desktop area gets redrawn, including ACC windows.
 *
 *************************************************************************/

static void
do_cmdmenu(menuitem)
    int menuitem;
{
    int dmy;
    int status;
    int screen_has_been_trashed;
    
    screen_has_been_trashed = FALSE;

    switch (menuitem) {
    
        case MCMDQUIT:  /* quit program */

            prg_exit();
            break;
            
        case MCMDHELP:  /* show help */
        
            do_dialog(helptree);
            break;

        case MCMDNEW:   /* new shape */

            menu_off();
            wind_update(BEG_MCTRL);
            get_shapes();
            scrn_blit(BLIT_RSTRSCRN, &scrnrect);
            wind_update(END_MCTRL);
            menu_on();
            screen_has_been_trashed = TRUE;
            break;

        case MCMDDRAW:  /* draw */

            menu_off();
            wind_update(BEG_MCTRL);
            graf_mouse(M_OFF,0L);
            do_spyro();
            graf_mouse(M_ON,0L);
            evnt_button(1,2,0, &dmy, &dmy, &dmy, &dmy);
            wind_update(END_MCTRL);
            menu_on();
            screen_has_been_trashed = TRUE;
            break;

        case MCMDCLRS:  /* clear screen */

            menu_off();
            clr_scrn();
            menu_on();
            screen_has_been_trashed = TRUE;
            break;

        case MCMDSAVE:  /* save image */

            status = pic_save(scrnbuffer);
            if (status < 0) {
                form_alert(1,savefail_alert);
            }
            else {
                if (status == 0) {
                    form_alert(1,savegood_alert);
                }
            }
            break;
    
        case MCMDLOAD:  /* load image */
            
            if (pic_load(scrnbuffer, PIC_USEPALLETE) < 0) {
                form_alert(1,loadfail_alert);
            }
            scrn_blit(BLIT_RSTRSCRN, &deskrect);
            screen_has_been_trashed = TRUE;
            break;

    }

    if (screen_has_been_trashed == TRUE) {
        form_dial(FMD_FINISH, 0,0,0,0, deskrect);
    }
    
}

/**************************************************************************
 *
 * do_optmenu - Dispatch routines to process items from the OPTIONS menu.
 *
 *************************************************************************/

static void
do_optmenu(menuitem)
    int menuitem;
{
    int  selection,
         work;

    switch (menuitem) {

        case MOPTSPEN:      /* set pen color */
     
            selection = simu_menu(colrtree, OUTLINED);
            if (selection >= 0)
                pen_color = ((int)(colrtree[selection].ob_spec)) & 0x000F;
            break;

        case MOPTRBGC:      /* reverse background color */

            work = Setcolor(0, -1);
            work = Setcolor(idx_bgcolor, work);
            Setcolor(0, work);
            break;

        case MOPTPALT:      /* set color pallete */

            mini_pallete();
            break;
    
        case MOPTSMTH:      /* set smoothness (dot spacing) */

            get_smoothness();
            break;
            
        case MOPTPFMT:      /* set picture format preference (NEO|DEGAS) */

            pic_fmtset(PIC_USERSELECT);
            break;
            
        case MOPTSSAM:      /* set screen access method */
            
            do_dialog(ssamtree);
            if (ssamtree[SSAMBRFP].ob_state & SELECTED) {
                    scrnaccess = FASTPLOT;
            } else {
                    scrnaccess = VDIPLOT;
            }
            break; 
    }
    
}

/**************************************************************************
 *
 * key2menu - Translate a keystroke to its corresponding dropdown menu item.
 *
 *  (This is one of my standard algorithms for doing key<->menu processing,
 *  but for as few keys as we define it's almost overkill).
 *************************************************************************/

static void
key2menu(keyascii, menutitle, menuitem)
    register int  keyascii;
    register int  *menutitle;
    register int  *menuitem;
{

    *menuitem  = -1;    /* assume no item found */
    
/*-------------------------------------------------------------------------
 * Force the keyascii to uppercase, lockout C and P keys in high rez.
 *-----------------------------------------------------------------------*/
 
    if (keyascii >= 'a') {
        keyascii -= 32;
    }
    
    if ((keyascii == 'C' || keyascii == 'P') && resolution == 2) {
        return;
    }
    
/*-------------------------------------------------------------------------
 * Assume it will be a COMMANDS menu item, then check those keys...
 *-----------------------------------------------------------------------*/
 
    *menutitle = MENUCMDS;
    
    switch (keyascii) {
        case 'D':
            *menuitem = MCMDDRAW;
            break;
        case 'N':
            *menuitem = MCMDNEW;
            break;
    }

/*-------------------------------------------------------------------------
 * If we found a menuitem, we can return now, else we assume it will  be
 * an OPTIONS menu item, then check those keys...
 *-----------------------------------------------------------------------*/
 
    if (*menuitem != -1)
        return;
        
    *menutitle = MENUOPTS;
    
    switch (keyascii) {
        case 'C':
            *menuitem = MOPTSPEN;
            break;
        case 'B':
            *menuitem = MOPTRBGC;
            break;
        case 'P':
            *menuitem = MOPTPALT;
            break;
    }       
  
/*-------------------------------------------------------------------------
 * If we found a menu item we can return, else we set menutitle to -1
 * to indicate that the keystroke didn't translate at all.
 *-----------------------------------------------------------------------*/
   
    if (*menuitem != -1)
        return;
        
    *menutitle = -1;
}  

/**************************************************************************
 *
 * main - Call init routine, then do evnt_multi loop to handle menu.
 *
 *************************************************************************/

void
main()
{
    int  event, 
         keycode, 
         dmy, 
         top_window,
         menutitle,
         menuitem,
         msgbuff[8];

    prg_init();

    while (1) {
    
/*-------------------------------------------------------------------------
 * check to see if our window is the top window (an ACC may be topped), and
 * if it is, we outline the window with the current pen color.
 *-----------------------------------------------------------------------*/

        wind_get(0, WF_TOP, &top_window, &dmy, &dmy, &dmy);
        if (wi_handle == top_window)
            wind_outline();

/*-------------------------------------------------------------------------
 * main even loop, wait for messages or keystrokes.
 *-----------------------------------------------------------------------*/

        event  =  evnt_multi(MU_MESAG | MU_KEYBD,
                    1,1,1,
                    0,0,0,0,0,
                    0,0,0,0,0,
                    msgbuff,
                    0,0,
                    &dmy,&dmy,
                    &dmy,&dmy,
                    &keycode,
                    &dmy);

        wind_update(BEG_UPDATE);

/*-------------------------------------------------------------------------
 * do keystroke<->menu translation.  if the key translates to a menu item, 
 * the menutitle/menuitem vars will be set, and will be processed later
 * in the loop just as if a menu message event had occurred.
 *-----------------------------------------------------------------------*/
         
        menutitle = -1;
        
        if (event & MU_KEYBD) {
            key2menu( (keycode & 0x00FF), &menutitle, &menuitem );
        }
        
/*-------------------------------------------------------------------------
 * do message event processing.  if the message is a menu-selected, just  
 * set the menutitle/menuitem vars so that it will be picked up later in 
 * the loop by the combined key/menu processor. other AES messages are 
 * handled in the standard manner.
 *-----------------------------------------------------------------------*/
 
        if (event & MU_MESAG) {
            switch (msgbuff[0]) {

               case MN_SELECTED:

                    menutitle = msgbuff[3];
                    menuitem  = msgbuff[4];
                    break; 
                    
                case WM_REDRAW:

                    do_redraw(&msgbuff[4]);
                    break;

                case WM_NEWTOP:
                case WM_TOPPED:

                    wind_set(wi_handle,WF_TOP,0,0,0,0);
                    break;

            } /* END switch (msgbuff[0]) */

        } /* END if (event & MU_MSG) */
        
/*-------------------------------------------------------------------------
 * do menu processing.  if the menutitle var is not -1, highlight the menu
 * title.  (if the user hit a key that we translated to a menu item, the 
 * title needs highlighting to show that we are processing a menu item.  
 * if the user selected the menu item via mouse, the title is already 
 * highlighted, but it doesn't hurt  to highlight it again.)  call the menu
 * dispatching routines, then de-select the menu title upon completion of 
 * menu processing.
 *-----------------------------------------------------------------------*/
 
         
        if (menutitle != -1) {
            menu_tnormal(menutree, menutitle, FALSE);
            switch (menutitle) {

                case MENUCMDS:

                    do_cmdmenu(menuitem);
                    break;

                case MENUOPTS:

                    do_optmenu(menuitem);
                    break;

                case MENUDESK:

                    do_dialog(infotree);
                    break;

            } /* END switch (menutitle) */

            menu_tnormal(menutree, menutitle, TRUE);

        } /* END if (menutitle != -1) */
        
        wind_update(END_UPDATE);
     
    } /* END while(1) */

}

/* end of main.c  */

