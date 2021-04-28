
/**************************************************************************
 *
 * mini_pallete - A little bitty control-panel-like color pallete acc.
 *
 *  Public Domain example program by Ian Lepore.
 *
 *  This is distributed as an example of how to write an accessory using
 *  my AESFAST public domain GEM bindings.  This example uses a few of
 *  the nifty utilities from AESFAST, but it's pretty much straightforward
 *  window-handling code.
 *
 *  I built this beast because I have some graphics programs (Mandelbrot
 *  fractal generators, a spyrograph program, etc), in which one would
 *  naturally want to change the screen colors on the fly, but the %^$%#*&
 *  system control panel covers the whole screen in low rez.  This acc
 *  gives a nice itty-bitty moveable window with all the necessary color
 *  controls in it.
 *
 *  This acc does not behave like the system control panel, in that it
 *  will not reset the colors the application has set when you call it up.
 *  On the other hand, the color changes you do with this accessory will 
 *  not be saved if you use 'Save Desktop'. (Hint:  You would need to code
 *  the shel_read() and shel_write() AES functions to make that work.  
 *  Actually doing it is left as an excerise for the reader <grin>).
 *
 *  Also, the order of the colored boxes on the screen corresponds to the
 *  TOS order of colors, not the VDI order.  (EG:  The foreground and
 *  background colors are the first and last boxes, not the first two).
 *
 *  This code is pretty heavily commented.  Please excuse me if some of 
 *  the comments seem obvious, but I figure the audience for this will 
 *  include both beginning C programmers, and old-timers who just need to
 *  see how my bindings work as opposed to other bindings.
 *
 *************************************************************************/

#include <gemfast.h>
#include <osbind.h>

#ifndef TRUE
#define TRUE  1
#define FALSE 0
#endif

#define Getcolor(a) ((int)(Setcolor((a), -1)))

#define graf_mkstate    graq_mstate    /* use Line-A mouse state call */

/**************************************************************************
 *
 * global vars (gee, there's not many of these for a change...)
 *
 *************************************************************************/

extern int _accflag;    /* from minstart.o, non-zero if running as ACC */

struct rgb_settings {
        char red, grn, blu, filler;
        } cur_setting;

int     coloridx = 0;                   /* default color index is # 0    */

#define WI_KIND         (MOVER|CLOSER|NAME)
#define NO_WINDOW       -1

extern int gl_apid;                     /* defined in bindings library   */

int     menu_id ;                       /* our menu id                   */
int     wi_handle;                      /* window handle                 */
GRECT   treerect;                       /* object tree (in window) rect  */

char    menu_title[] = "  Mini Pallete  ";
char    wind_title[] = " Mini Pallete ";

/**************************************************************************
 *
 * palttree - The color pallete dialog tree.
 *
 *  This is NOT the output from a resource editor (it was a long time ago,
 *  but it's been pretty much re-done by hand).
 *
 *  The two objects flagged as HIDETREE are no longer used, and I don't
 *  want to rebuild the whole tree to remove them (and I've lost the
 *  .RSC file that this source comes from).
 *************************************************************************/

OBJECT  palttree[] = {

/*          type       flags   state   ob_spec     x       y       w        h   */

-1,  1, 35, G_BOX,     NONE,     0, 0x00000000L, 0x0000, 0x0000, 0x0212, 0x0506,

 2, -1, -1, G_BOXCHAR, HIDETREE, 0, 0x05FF1100L, 0x0000, 0x0000, 0x0000, 0x0000,
 3, -1, -1, G_BOX,     HIDETREE, 0, 0x00FF1121L, 0x0000, 0x0000, 0x0000, 0x0000,

 7,  4,  6, G_IBOX,    NONE,     0, 0x00001101L, 0x0100, 0x0100, 0x0401, 0x0703,
 5, -1, -1, G_BOXCHAR, NONE,     0, 0x52001100L, 0x0200, 0x0100, 0x0001, 0x0001,
 6, -1, -1, G_BOXCHAR, NONE,     0, 0x47001100L, 0x0200, 0x0401, 0x0001, 0x0001,
 3, -1, -1, G_BOXCHAR, NONE,     0, 0x42001100L, 0x0200, 0x0702, 0x0001, 0x0001,

35,  8, 26, G_IBOX,    NONE,     0, 0x00001100L, 0x0501, 0x0200, 0x0210, 0x0603,

17,  9, 16, G_IBOX,    NONE,     0, 0x00001100L, 0x0100, 0x0000, 0x0010, 0x0001,
10, -1, -1, G_BOXCHAR, NONE,     0, 0x30FF1100L,  0, 0, 2, 1,
11, -1, -1, G_BOXCHAR, NONE,     0, 0x31FF1100L,  2, 0, 2, 1,
12, -1, -1, G_BOXCHAR, NONE,     0, 0x32FF1100L,  4, 0, 2, 1,
13, -1, -1, G_BOXCHAR, NONE,     0, 0x33FF1100L,  6, 0, 2, 1,
14, -1, -1, G_BOXCHAR, NONE,     0, 0x34FF1100L,  8, 0, 2, 1,
15, -1, -1, G_BOXCHAR, NONE,     0, 0x35FF1100L, 10, 0, 2, 1,
16, -1, -1, G_BOXCHAR, NONE,     0, 0x36FF1100L, 12, 0, 2, 1,
 8, -1, -1, G_BOXCHAR, NONE,     0, 0x37FF1100L, 14, 0, 2, 1,

26, 18, 25, G_IBOX,    NONE,     0, 0x00001100L, 0x0100, 0x0301, 0x0010, 0x0001,
19, -1, -1, G_BOXCHAR, NONE,     0, 0x30FF1100L,  0, 0, 2, 1,
20, -1, -1, G_BOXCHAR, NONE,     0, 0x31FF1100L,  2, 0, 2, 1,
21, -1, -1, G_BOXCHAR, NONE,     0, 0x32FF1100L,  4, 0, 2, 1,
22, -1, -1, G_BOXCHAR, NONE,     0, 0x33FF1100L,  6, 0, 2, 1,
23, -1, -1, G_BOXCHAR, NONE,     0, 0x34FF1100L,  8, 0, 2, 1,
24, -1, -1, G_BOXCHAR, NONE,     0, 0x35FF1100L, 10, 0, 2, 1,
25, -1, -1, G_BOXCHAR, NONE,     0, 0x36FF1100L, 12, 0, 2, 1,
17, -1, -1, G_BOXCHAR, NONE,     0, 0x37FF1100L, 14, 0, 2, 1,

 7, 27, 34, G_IBOX,    NONE,     0, 0x00001100L, 0x0100, 0x0602, 0x0010, 0x0001,
28, -1, -1, G_BOXCHAR, NONE,     0, 0x30FF1100L,  0, 0, 2, 1,
29, -1, -1, G_BOXCHAR, NONE,     0, 0x31FF1100L,  2, 0, 2, 1,
30, -1, -1, G_BOXCHAR, NONE,     0, 0x32FF1100L,  4, 0, 2, 1,
31, -1, -1, G_BOXCHAR, NONE,     0, 0x33FF1100L,  6, 0, 2, 1,
32, -1, -1, G_BOXCHAR, NONE,     0, 0x34FF1100L,  8, 0, 2, 1,
33, -1, -1, G_BOXCHAR, NONE,     0, 0x35FF1100L, 10, 0, 2, 1,
34, -1, -1, G_BOXCHAR, NONE,     0, 0x36FF1100L, 12, 0, 2, 1,
26, -1, -1, G_BOXCHAR, NONE,     0, 0x37FF1100L, 14, 0, 2, 1,

 0, 36, 51, G_IBOX,    NONE,     0, 0x00001100L, 0x0000, 0x0104, 0x0212, 0x0302,
37, -1, -1, 0x0014,    NONE,     0, 0x00011170L, 512,    512,    2,      1,
38, -1, -1, 0x0814,    NONE,     0, 0x00000179L, 512,    769,    2,      1,
39, -1, -1, 0x0114,    NONE,     0, 0x00001172L, 1026,   512,    2,      1,
40, -1, -1, 0x0214,    NONE,     0, 0x00002173L, 1540,   512,    2,      1,
41, -1, -1, 0x0314,    NONE,     0, 0x00003176L, 7,      512,    2,      1,
42, -1, -1, 0x0414,    NONE,     0, 0x00000174L, 521,    512,    2,      1,
43, -1, -1, 0x0514,    NONE,     0, 0x00001177L, 1035,   512,    2,      1,
44, -1, -1, 0x0614,    NONE,     0, 0x00002175L, 1549,   512,    2,      1,
45, -1, -1, 0x0A14,    NONE,     0, 0x0000217BL, 1540,   769,    2,      1,
46, -1, -1, 0x0B14,    NONE,     0, 0x0000317EL, 7,      769,    2,      1,
47, -1, -1, 0x0C14,    NONE,     0, 0x0000017CL, 521,    769,    2,      1,
48, -1, -1, 0x0D14,    NONE,     0, 0x0000117FL, 1035,   769,    2,      1,
49, -1, -1, 0x0E14,    NONE,     0, 0x0000217DL, 1549,   769,    2,      1,
50, -1, -1, 0x0714,    NONE,     0, 0x00003178L, 16,     512,    2,      1,
51, -1, -1, 0x0914,    NONE,     0, 0x0000117AL, 1026,   769,    2,      1,
35, -1, -1, 0x0F14,    LASTOB,   0, 0x00003171L, 16,     769,    2,      1
}; /* END of palttree[] */

/* resource set indicies (names) for objects in palttree */

#define PALTTREE 0  /* root */
#define PALTPNUM 7  /* Parent box for all the intensity parents */
#define PALTPRED 8  /* Parent box for the RED intensity numbers */
#define PALTPGRN 17 /* Parent box for the GRN intensity numbers */
#define PALTPBLU 26 /* Parent box for the BLU intensity numbers */
#define PALTPCOL 35 /* Parent box for the color-selection boxes */

/**************************************************************************
 *
 * find_boxchar - Return the object index of a child boxchar with a given
 *  letter in its box, or -1 if no matching object can be found.
 *
 *  Say what?  Well, this routine cruises through all the children of a 
 *  given parent object, and for every boxchar type object found the char
 *  in the box is compared to the char passed to this routine.  On the 
 *  first match found, the object index of the matching object is returned.
 *  (Note that the object type is masked with 0x00FF to strip out any
 *  extended object type info, so that the object type compare will work).
 *  
 *  Why do this, you wonder?  Well, boxchar objects make great radio
 *  buttons, especially for things like selecting a device, or in this 
 *  case, a color intensity from 0-7.  In the case of device selection, 
 *  you need to have buttons for A-P, but on most systems, there won't
 *  be this many devices, and you'll need to set some of the buttons
 *  (boxchars) to DISABLED.  Since you'll be doing this at runtime, you
 *  need a way to find the corresponding button for each device.  It is
 *  AN ABSOLUTE NO-NO to hard-code object indicies (names) or treat the 
 *  objects as an array, because as soon as you do some user will come  
 *  along with a resouce editor & re-sort your objects.  Then the user will
 *  complain when s/he clicks on the drive A button, and drive B gets
 *  formatted instead.
 *
 *************************************************************************/

int
find_boxchar(tree, parent, boxchar)
        register OBJECT *tree;
        register int    parent;
        register char   boxchar;
{
        register int kid;

        kid = tree[parent].ob_head;

        while ( (kid != parent) && (kid >= R_TREE) ) {
                if ((0x00FF & tree[kid].ob_type) == G_BOXCHAR) {
                        if (boxchar == (char)(tree[kid].ob_spec >> 24)) {
                                return(kid);
                        }
                }
                kid = tree[kid].ob_next;
        }
        return(-1);
}

/**************************************************************************
 *
 * rgb2color - convert cur_settings structure to a TOS color value.
 *  This routine combines the separate ASCII RGB values into a single
 *  integer RGB value in TOS format.  That is, if the cur_settings struct
 *  contains '2', '6', and '3', this routine will return 0x0263.
 *  
 *************************************************************************/

int
rgb2color()
{
        return ( ((cur_setting.red & 0x000F) << 8) | 
                 ((cur_setting.grn & 0x000F) << 4) | 
                  (cur_setting.blu & 0x000F) );
}

/**************************************************************************
 *
 * color2rgb - convert a TOS color to characters in cur_settings.
 *  This routine separates an integer TOS-format RGB value into 3 ASCII
 *  characters in cur_settings.  If the TOS color is 0x0746, the structure
 *  will contain '7', '4', and '6'.
 *
 *************************************************************************/

void
color2rgb(color)
        register int color;
{
        cur_setting.red = '0' + ( 0x000F & (color >> 8) );
        cur_setting.grn = '0' + ( 0x000F & (color >> 4) );
        cur_setting.blu = '0' + ( 0x000F &  color );
} 

/**************************************************************************
 *
 * new_color - Change the current selected color box on the screen (like
 *  a radio button), and set the new intensity settings (numbered boxes) 
 *  to match the new active color box.
 *
 *  To show which color box is current, we set the ob_state to CROSSED
 *  instead of SELECTED.  SELECTED will invert the color of the object,
 *  which sorta defeats our purpose.  We don't have as much room on the
 *  screen as the regular control panel, so we can't just make the box
 *  a little bigger like it does.
 *
 *  If 'drawflag' is TRUE, the screen is updated with the state changes
 *  (this is the normal state of affairs).  If the flag is FALSE, the
 *  object states are set, but no screen work is done (this is for
 *  initializing the dialog before it is displayed).
 *************************************************************************/

void 
new_color(newobject, drawflag)
        register int newobject, drawflag;
{
        register OBJECT *ptree;
        register int    wrkobject;
        register int    curobject;
        int             dmy;

        ptree = palttree;               /* quick register tree pointer */

/*
 * figure out which is the currently-selected color box object. 
 * if the current object is the same as the new object, the user is
 * leaning on the mouse button; to avoid nasty object flashing on
 * the screen in this case, just return.
 */
 
        curobject = obj_rbfind(ptree, PALTPCOL, CROSSED);
        if (curobject == newobject) {
                return;
        }
        
/*
 * de-select the numbered radio buttons that show the intensity
 * settings for the current color.  the 'if (-1 != ...)' logic prevents
 * us from croaking the first time thru, since no buttons will be selected.
 */

        if (-1 != (wrkobject = objrb_which(ptree, PALTPRED)))
                objst_change(ptree, wrkobject, ~SELECTED, drawflag);
        if (-1 != (wrkobject = objrb_which(ptree, PALTPGRN)))
                objst_change(ptree, wrkobject, ~SELECTED, drawflag);
        if (-1 != (wrkobject = objrb_which(ptree, PALTPBLU)))
                objst_change(ptree, wrkobject, ~SELECTED, drawflag);

/*
 * de-select the current color box, select the new color box.  
 * again the '-1' check is for the first time thru case.
 */

        if (-1 != curobject) 
                objst_change(ptree, curobject, ~CROSSED, drawflag);
        objst_change(ptree, newobject,  CROSSED, drawflag);

/*
 * change our picture of what's current.  the TOS color index is encoded
 * as the 'extended object type' of the color-box objects (see discussion 
 * on this above, where palttree is defined).  the 'color2rgb' call will
 * fill in the 'cur_settings' structure to represent the current intensity
 * of the color just selected.  
 */
 
        coloridx = 0x000F & (ptree[newobject].ob_type >> 8);
        color2rgb( Getcolor(coloridx) );

/*
 * select the appropriate numbered boxes to represent the color intensity
 * settings for the newly-selected color. the 'cur_settings' array holds
 * the ASCII representation of the RGB instensities.  this is done so that
 * we can find the corresponding radio buttons (which are BOXCHAR objects)
 * via the find_boxchar() function.
 */
 
        wrkobject = find_boxchar(ptree, PALTPRED, cur_setting.red);
        objst_change(ptree, wrkobject,  SELECTED, drawflag);
        
        wrkobject = find_boxchar(ptree, PALTPGRN, cur_setting.grn);    
        objst_change(ptree, wrkobject,  SELECTED, drawflag);
        
        wrkobject = find_boxchar(ptree, PALTPBLU, cur_setting.blu);
        objst_change(ptree, wrkobject,  SELECTED, drawflag);

/* all done */

}
     
/**************************************************************************
 *
 * new_settings - Process a click in a numbered box of the dialog, and
 *  change the color intensity in the TOS color pallete correspondingly.
 *
 *************************************************************************/

void
new_settings(newobject)
{
        char boxchar;
        int  curparent,
             curobject;

/*
 * figure out what's being changed.  the 'curparent' value will tell us
 * whether it's the R, G, or B value.  the 'curobject' is used to detect
 * whether the user is leaning on the mouse (curobject == newobject);
 * in this case we exit without taking any action, to avoid nasty graphic
 * flashing on the screen.
 *
 */
 
        curparent = obj_parent(palttree, newobject);
        curobject = objrb_which(palttree, curparent);
        
        if (curobject == newobject) {
                return;
        }
        
/*
 * the displayed intensity buttons are G_BOXCHAR objects, with the chars
 * ranging from '0' - '7' for each color.  we pluck the displayed char 
 * out of the ob_spec value in the tree (ob_spec for boxchars looks like
 * 0xCCnnnnnn), and we plug the char right into the 'cur_settings' array,
 * still in its ASCII form. 
 */
 
        boxchar = (char)(palttree[newobject].ob_spec >> 24);

        switch (curparent) {
                case PALTPRED:
                        cur_setting.red = boxchar;
                        break;
                case PALTPGRN:
                        cur_setting.grn = boxchar;
                        break;
                case PALTPBLU:
                        cur_setting.blu = boxchar;
                        break;
        }  
        
/* 
 * now that the 'cur_settings' array contains the new intensity setting,
 * call 'rgb2color' to convert the ASCII values to a single binary TOS
 * color value, then call the TOS 'Setcolor' function to make the change.
 */
 
        Setcolor( coloridx, rgb2color() );

/*
 * de-select the old intensity setting, select the new one...
 */
        objst_change(palttree, curobject, ~SELECTED, TRUE);
        objst_change(palttree, newobject,  SELECTED, TRUE); 

/* all done */

}

/**************************************************************************
 *
 * prg_init - Mundane program init stuff.
 *  The only item of note here is a call to 'rsc_treefix'.  This is a
 *  routine from the AESFAST library that will do an rsrc_obfix() call for
 *  each object in a tree.  It's used only for resource trees buried in 
 *  source code, if the resource file is loaded, the rsrc_load() call
 *  handles the object x/y/w/h fixup internally.
 *
 *  Oh yeah -- I discovered an interesting problem coding this:  If the
 *  'menu_register' call is not the first AES call following the appl_init
 *  the accessory sometimes doesn't show up on the DESK menu until
 *  after you've run some other GEM program.  This is consistant with the
 *  rules of AES multitasking:  your program can be swapped out on ANY
 *  AES call, not just when you do an evnt_???? call.  It just isn't 
 *  mentioned in any of the docs I have.
 *************************************************************************/

prg_init()
{
        appl_init();

        if (_accflag)
            menu_id = menu_register(gl_apid, menu_title);
        
        rsc_treefix(palttree);

        form_center(palttree, &treerect.g_x, &treerect.g_y, 
                              &treerect.g_w, &treerect.g_h);

        new_color(0, FALSE);

        wi_handle = NO_WINDOW;
}

prg_exit()          /* called for WM_CLOSE when running as .PRG */
{
    appl_exit();
    Pterm(0);
}

/**************************************************************************
 *
 * open_window 
 *   Create and open the window, if it's not open already.
 *
 *   If the window is already open, it may be hidden from the user by an
 *   overlapping window, and the only way to get us back may be to
 *   click on us again in the DESK menu.  In this case, we just ask
 *   the AES to bring our window back to the top.
 *
 *   Before opening the window, we calculate its size and location (total 
 *   size, including its borders & controls) based upon the current size 
 *   and location of the pallete object tree.  The first time the window
 *   opens, this will be the center of the screen, because we do a 
 *   form_center on the pallete tree.  For subsequent calls, we show up
 *   wherever we were last on the screen.
 *
 *   We also set the window title bar here, before opening the window.   
 *************************************************************************/

open_window()
{
        GRECT windrect;
        
        if (wi_handle == NO_WINDOW) {
        
                wind_calc(WC_BORDER, WI_KIND, treerect, 
                           &windrect.g_x, &windrect.g_y,
                           &windrect.g_w, &windrect.g_h);
                           
                wi_handle = wind_create(WI_KIND, windrect);
                
                wind_set(wi_handle, WF_NAME, wind_title, 0L);
                
                wind_open(wi_handle, windrect);
        } 
        else {
                wind_set(wi_handle, WF_TOP, 0L, 0L);
        }
}

/**************************************************************************
 *
 * close_window
 *  Close and delete the window, if it's open.
 *************************************************************************/

close_window()
{
        if (wi_handle != NO_WINDOW) {       
                wind_close(wi_handle);
                wind_delete(wi_handle);
                wi_handle = NO_WINDOW;
        }
}

/**************************************************************************
 *
 * do_redraw - Process redraw list.
 *  Ok, let's see if I can explain this better than the DRI books do...
 *
 *  After somebody has munged up the screen (say with a dialog box), they
 *  send a redraw request to the whole world.  The redraw request comes
 *  from one of two sources:  1) Somebody does a form_dial(FMD_FINISH...)
 *  call, or 2) Somebody does a wind_close() call.  (Ummm, ok, so there's
 *  other sources, now that I think of it, like windows being moved or
 *  sized).  Anyway, when AES sends out a redraw request, it sends it to
 *  everybody who owns a window, and what it sends is the full x/y/w/h
 *  values of the area of the screen to restore.
 *
 *  The area to be restored may or may not overlap any of the windows you
 *  have open on the screen.  The AES can provide you with a list of the
 *  visible rectangles that comprise your window(s).  (Remember that not
 *  all of a window you have open may be visible).  So, to process a 
 *  redraw, you have to ask AES for each of the visible rectangles, and
 *  for each one returned, see if it overlaps the screen area to be redrawn.
 *
 *  There is a library routine in AESFAST called 'rc_intersect' that will
 *  compute the intersecting portion of 2 rectangular screen areas. If 
 *  the rectangles don't overlap at all, it will return FALSE.  Thus, we
 *  have a loop in which we ask the AES for each rectangle, and we check
 *  it against the redraw rectangle, and if there is some overlap, we call
 *  the routine which actually draws the window contents, passing that
 *  routine the boundries of the intersecting rectangle.  The looping 
 *  continues until the AES returns us a rectangle from the list that has
 *  zero height and width.
 *
 *************************************************************************/

do_redraw(updtrect)
        GRECT updtrect;         /* the full area that needs updating */
{
        GRECT listrect;         /* one of our visible areas */

        wind_get(wi_handle, WF_FIRSTXYWH,
                  &listrect.g_x, &listrect.g_y, 
                  &listrect.g_w, &listrect.g_h);
                  
        while ( listrect.g_w && listrect.g_h ) {
                if ( rc_intersect(&updtrect, &listrect) ) {
                        draw_window(listrect);
                }
                wind_get(wi_handle, WF_NEXTXYWH, 
                          &listrect.g_x, &listrect.g_y,
                          &listrect.g_w, &listrect.g_h);
        }
}


/**************************************************************************
 *
 * draw_window - Draw the contents of the window, with clipping.
 *  In this case, we just do an objc_draw call on our tree, passing the
 *  clipping rectangle we receive along to the objc_draw.
 *
 *************************************************************************/


draw_window(cliprect)
GRECT cliprect;
{ 
        objc_draw(palttree, R_TREE, MAX_DEPTH, cliprect);
}


/**************************************************************************
 *
 * do_msg - Handle a message returned by evnt_multi().
 *  This is pretty standard message handling for an accessory.  One item of
 *  interest I discovered when building this is that you should *not* 
 *  attempt to close any open windows when you get an AC_CLOSED message.
 *  This message apparently tells you that your windows have already been
 *  closed and deleted, and you should just mark your window handle(s) as
 *  no longer valid.
 *
 *  The only piece of weirdness here is the WM_MOVED case.  The window
 *  provides a frame for our object tree, so when it gets moved, we have
 *  to update the ob_x and ob_y values in the pallete tree to match (so
 *  that objc_draw commands will draw inside the window's work area).
 *  The values in msgbuf reflect the new x/y/w/h of the window's total 
 *  size (borders and controls included).  We have the option of changing
 *  these values (like snapping to a character grid or whatever) or even
 *  of ignoring them, but in this instance we don't care about any of that
 *  so we just tell AES to use the values directly.  After doing the 
 *  wind_set call to set the new location of the window, we call wind_get
 *  to find out the new x/y/w/h of the work area of the window, so that
 *  we can reposition the object tree.  We don't have to redraw the
 *  window contents during WM_MOVED processing, because the AES will blit
 *  the window contents for us if it can.  If not all of the window can
 *  be blitted, the AES will send redraw messages to us, and we'll get
 *  them on the next iteration of the evnt_multi loop.
 *************************************************************************/

do_msg(msgbuf)
register int msgbuf[];
{

        switch (msgbuf[0]) {

                case AC_OPEN:
                        if (msgbuf[4] == menu_id) 
                                open_window();
                        break;

                case AC_CLOSE:
                        wi_handle = NO_WINDOW;
                        break;

                case WM_REDRAW:
                        if (msgbuf[3] == wi_handle)
                                do_redraw(msgbuf[4], msgbuf[5],
                                          msgbuf[6], msgbuf[7]);
                        break;

                case WM_NEWTOP:
                case WM_TOPPED:
                        if (msgbuf[3] == wi_handle) 
                                wind_set(wi_handle, WF_TOP, 0L, 0L);
                        break;

                case WM_CLOSED:
                        close_window();
                        if (!_accflag)
                            prg_exit();
                        break;

                case WM_MOVED:
                        if(msgbuf[3] == wi_handle) {
                                wind_set(wi_handle, WF_CURRXYWH, 
                                          msgbuf[4], msgbuf[5],
                                          msgbuf[6], msgbuf[7]);
                                wind_get(wi_handle, WF_WORKXYWH,
                                          &treerect.g_x, &treerect.g_y, 
                                          &treerect.g_w, &treerect.g_h);
                                palttree->ob_x = treerect.g_x;
                                palttree->ob_y = treerect.g_y;                 
                        }
                        break;

                } /* END switch (msgbuf[0]) */
}

/**************************************************************************
 *
 * do_btn - Handle a button click within our window.
 *  Do a graf_mkstate() call to get the most-current location of the
 *  mouse.  Call objc_find() to see if the mouse is located over an object
 *  in our tree.  If so, we determine the parent of the tree.  If the
 *  parent is one of the boxes which holds our various radio buttons, we
 *  go process the button, as appropriate.  If it is over an object of
 *  ours, but not within a parent box, we just ignore the click.
 *
 *************************************************************************/

do_btn()
{
        int mouse_x;
        int mouse_y;
        int selobject;
        int dmy;
        
        graf_mkstate(&mouse_x, &mouse_y, &dmy, &dmy);

        selobject = objc_find(palttree, R_TREE, MAX_DEPTH, mouse_x, mouse_y);

        if (selobject != -1) {
                switch (obj_parent(palttree, selobject)) {
                        case PALTPCOL: 
                                new_color(selobject, TRUE);
                                break;
                        case PALTPRED: 
                        case PALTPGRN:
                        case PALTPBLU:
                                new_settings(selobject);
                                break;
                } /* END switch (obj_parent(selobject)) */
        } /* END if (selobject != -1) */
}

/**************************************************************************
 *
 * main routine
 *  Call the init routine, then fall into a do-forever evnt_multi() loop.
 *
 *************************************************************************/

main()
{
        int dmy;
        int event;
        int msgbuf[8];
        
        prg_init();
        
        if (!_accflag) {
            graf_mouse(ARROW, 0L);
            open_window();
        }

        while (TRUE) {
                event = evnt_multi(
                         MU_MESAG | MU_BUTTON,
                         1,1,1,               /* mbclicks, mbmask, mbstate*/
                         0,0,0,0,0,           /* Mouse event rectangle 1  */
                         0,0,0,0,0,           /* Mouse event rectangle 2  */
                         msgbuf,              /* Message buffer           */
                         0,0,                 /* timer event, time = 0,0  */
                         &dmy, &dmy,          /* Mouse x & y at event     */
                         &dmy,                /* Mouse button at event    */
                         &dmy,                /* Keystate at event        */           
                         &dmy,                /* Keypress at event        */
                         &dmy);               /* Mouse click count        */

                wind_update(BEG_UPDATE);

                if (event & MU_MESAG)
                        do_msg(msgbuf);
                
                if (event & MU_BUTTON) 
                        do_btn();
                
                wind_update(END_UPDATE);
        
        } /* END while (TRUE) */
}

