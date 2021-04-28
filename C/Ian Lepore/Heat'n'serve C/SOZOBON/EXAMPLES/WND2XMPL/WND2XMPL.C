/* tab expansion/compression should be set to 4 in your editor */
/**************************************************************************
 *
 * WINDXMPL.C - Demo of handling an object tree in a window, with some
 *              emulation of form_do processing. 
 *
 *              This file demos many of the alternate AES bindings 
 *              routines such as frmx_center and evnx_multi.
 *************************************************************************/

#include <osbind.h>
#include <gemfast.h> 
#include "wnd2xmpl.h"

#define WI_KIND     (CLOSER+NAME)
#define NO_WINDOW   -1

#define TRUE  1
#define FALSE 0

extern int  thmo_redraw();
extern int  thmo_attr();
extern int  thmo_incr();
extern int  thmo_start();

OBJECT  *menutree;
OBJECT  *windtree;

GRECT   windrect;

int     wchar;
int     hchar;
int     wi_handle = NO_WINDOW;
char    wi_name[] = " Window Demo 2 ";

extern int  gl_apid;

/**************************************************************************
 *
 * prg_init - Standard GEM startup.
 *
 *************************************************************************/

prg_init()
{
    int  dmy;
    
    appl_init();
    
    if (!rsrc_load("WND2XMPL.RSC")) {
        form_alert(1,"[1][ | Can't load RSC! | ][ Fatal ]");
        appl_exit();
        Pterm(1);
    }

    graf_handle(&wchar, &hchar, &dmy, &dmy);    /* For window min sizes */

    rsrc_gaddr(R_TREE, MENUTREE, &menutree);
    rsrc_gaddr(R_TREE, WINDTREE, &windtree);

    *(char *)&windtree[WINDBXSP].ob_type |= 'S';     /* Stop     */
    *(char *)&windtree[WINDBXGO].ob_type |= 'G';     /* Go       */
    *(char *)&windtree[WINDBXPA].ob_type |= 'P';     /* Pause    */

    menu_bar(menutree, TRUE);

    graf_mouse(ARROW, 0L);    
}

/**************************************************************************
 *
 * prg_exit - Standard GEM exit.
 *
 *************************************************************************/

prg_exit()
{
    w_close();
    menu_bar(menutree, FALSE);
    rsrc_free();
    appl_exit();
    Pterm(0);
}

/**************************************************************************
 *
 * w_open - Create and open a window.
 *  The display tree is centered, then the window is sized to hold it.
 *
 *************************************************************************/

w_open()
{
    GRECT   wrect;
    GRECT   treerect;
    GRECT   thmorect;
    
    if (wi_handle != NO_WINDOW) {       /* if window is already open,     */
        return wi_handle;               /* just return the handle.        */
    }

    frmx_center(windtree, &treerect);   /* center tree, sizes in treerect */

    winx_calc(WC_BORDER, WI_KIND, treerect, &wrect); /* calc window fullsize */
 
    wi_handle = wind_create(WI_KIND, wrect);         /* create window     */

    if (wi_handle < 0) {
        form_error(4);                      /* can't open another window  */
        wi_handle = NO_WINDOW;
    } else {
        wind_set(wi_handle, WF_NAME, wi_name, 0L);  /* set window title   */
        wind_open(wi_handle, wrect);                /* open window        */
    }
    
    winx_get(wi_handle, WF_WORKXYWH, &windrect);
        
    obj_offxywh(windtree, WINDPBTH, &thmorect);
    thmo_attr(0,5);
    thmo_start(100, &thmorect, FALSE);

    return wi_handle;

}

/**************************************************************************
 *
 * w_close - Close and delete a window.
 *
 *************************************************************************/

w_close()
{
    if (wi_handle != NO_WINDOW) {   /* only do close processing */
        wind_close(wi_handle);      /* if the window is open!   */
        wind_delete(wi_handle);
        wi_handle = NO_WINDOW;
    }
}

/**************************************************************************
 *
 * do_redraw - Standard AES redraw handler for trees in windows.
 *
 *************************************************************************/

do_redraw(window, ptree, predrawrect)
    register int      window;
    register OBJECT   *ptree;
    register GRECT    *predrawrect;
{
    register int      calltype;
    register int      doneflag;
    GRECT             t1;
    GRECT             t2;

/*
 * process the rectangle list for the window.  for each intersection of
 * the area to be redrawn with a visible window rectangle, call objc_draw
 * to draw that portion of the menu.
 */

    wind_update(BEG_UPDATE);
    
    calltype = WF_FIRSTXYWH;
    doneflag = FALSE;

    do  {
        winx_get(window, calltype, &t1);
        if (t1.g_w && t1.g_h) {
            if (rc_intersect(predrawrect, &t1) && t1.g_w && t1.g_h) {
                objc_draw(ptree, R_TREE, MAX_DEPTH, t1);
                thmo_redraw(&t1);
            }
        } else {
            doneflag = TRUE;
        }
        calltype = WF_NEXTXYWH;
    } while (doneflag == FALSE);

    wind_update(END_UPDATE);
}

/**************************************************************************
 *
 * hndl_message - Standard message handling code.
 *
 *************************************************************************/

hndl_message(msgbuf)
    register int    *msgbuf;
{
    int             dmy;
    int             top_window;
    register OBJECT *ptree = windtree;
    GRECT           t1, t2;

    switch (msgbuf[0]) {
            
    case MN_SELECTED:

        switch (msgbuf[4]) {
        case MENUQUIT:
            prg_exit();
            break;
        }
        menu_tnormal(menutree, msgbuf[3], TRUE);
        break;
        
    case WM_CLOSED:

        prg_exit();
        break;

    case WM_TOPPED:
    case WM_NEWTOP:

        wind_set(msgbuf[3], WF_TOP, 0L, 0L);
        break;
        
    case WM_REDRAW:

        do_redraw(msgbuf[3], ptree, &msgbuf[4]);
        break;

    case WM_MOVED:
    case WM_SIZED:

        t1 = *(GRECT *)(&msgbuf[4]);
        winx_calc(WC_WORK, WI_KIND, t1, &t2);

        ptree->ob_x = t2.g_x;
        ptree->ob_y = t2.g_y;

        rc_intersect(&ptree->ob_x, &t2);
        if (t2.g_w < wchar)
            t2.g_w = wchar;
        if (t2.g_h < hchar)
            t2.g_h = hchar;
 
        winx_calc(WC_BORDER, WI_KIND, t2, &t1);
        wind_set(msgbuf[3], WF_CURRXYWH, t1);

        break;
                
    } /* END switch (msgbuf[0]) */

}


/**************************************************************************
 *
 * rbselect - Visually select indicated radio button, de-sel old button.
 *
 *************************************************************************/

rbselect(ptree, selobj)
    register OBJECT *ptree;
    register int    selobj;
{
    register int    oldobj;

    oldobj = obj_rbselect(ptree, selobj, SELECTED);
    objc_draw(ptree, selobj, MAX_DEPTH, windrect);
    if (oldobj > R_TREE && oldobj != selobj) {
        objc_draw(ptree, oldobj, MAX_DEPTH, windrect);
    }
}

/**************************************************************************
 *
 * hndl_button - Handle a button click in our window.
 *
 *  This routine handles radio button clicks, and clicks on SELECTABLE
 *  objects that are not DISABLED.  It basically mimics the actions of
 *  the form_do() click handler...radio button clicks are processed
 *  immediately, then the mouse is ignored until the button is released.
 *  Clicks on non-radio objects will track the mouse, and will handle
 *  the object based on where the mouse is when the button is released.
 *
 *************************************************************************/

hndl_button(mx, my, mb)
    int mx, my, mb;
{
    int             dmy;
    register int    oldobj;
    register int    selobj;
    register int    in_obj;
    register OBJECT *ptree = windtree;
    register OBJECT *pobj;
    
    selobj = objc_find(ptree, R_TREE, MAX_DEPTH, mx, my);
    pobj   = &ptree[selobj];
    
    if (selobj <= R_TREE || (pobj->ob_state & DISABLED) ) {
        return NO_OBJECT;
    }

    wind_update(BEG_UPDATE);
    
    if (pobj->ob_flags & RBUTTON) { /* handle radio buttons */

        rbselect(ptree, selobj);
        
        if ((pobj->ob_flags & TOUCHEXIT) == FALSE) {
            evnt_button(1,1,0, &dmy, &dmy, &dmy, &dmy);
        }
        in_obj = TRUE;

    } else {                        /* handle non-radio buttons */

        if (pobj->ob_flags & TOUCHEXIT) {
            if (pobj->ob_flags & SELECTABLE) {
                pobj->ob_state ^= SELECTED;
                objc_draw(ptree, selobj, MAX_DEPTH, windrect);
            }
            in_obj = TRUE;
            
        } else {                    /* not a touchexit object... */
        
            if (pobj->ob_flags & SELECTABLE) {
                in_obj = graf_watchbox(ptree, selobj, 
                                (pobj->ob_state ^ SELECTED),
                                 pobj->ob_state);
            }
        } 
    }
    
    wind_update(END_UPDATE);

    if (in_obj == FALSE) {
        selobj = NO_OBJECT;             /* Nothing changed          */
    } else {
        if ( (pobj->ob_flags & (TOUCHEXIT|EXIT)) == FALSE ) {
            selobj = 0;                 /* Click on non-EXIT object */
        }
    }

    return selobj;
}

/**************************************************************************
 *
 * hndl_object - Handle clicks on objects in the window tree.
 *
 *************************************************************************/

hndl_object(selobj, xm)
    int     selobj;
    XMULTI  *xm;
{
    int     endx;
    int     endy;
    OBJECT  *pobj;
    GRECT   iconrect;

    pobj = &windtree[selobj];

    if ((pobj->ob_type & 0x00FF) == G_ICON) {

        obj_offxywh(windtree, selobj, &iconrect);

        if (xm->mbreturn == 1) {    /* single click */

            graf_dragbox(iconrect.g_w, iconrect.g_h,
                         iconrect.g_x, iconrect.g_y,
                         *(GRECT *)&windtree->ob_x,
                         &endx, &endy);
            
            pobj->ob_x = endx - windtree->ob_x;
            pobj->ob_y = endy - windtree->ob_y;

            form_dial(FMD_FINISH, 0L, 0L, endx, endy, 
                        iconrect.g_w, iconrect.g_h);

        } else {                    /* double click */
            form_alert(1,"[1][ | D-Click on ICON | ][ OK ]");
        }
        
        pobj->ob_state ^= SELECTED;
        form_dial(FMD_FINISH, 0L, 0L, iconrect);

        return;
        
    } else {

        switch (selobj) {
        
          case WINDBXSP:                                  /* STOP button */

            obj_stchange(windtree, WINDBXPA, DISABLED, TRUE);
            /* fall thru */

          case WINDBXPA:                                  /* PAUSE button */

            xm->mflags &= ~MU_TIMER;
            xm->mwhich  &= ~MU_TIMER;
            
            wind_update(END_UPDATE);    /* When stopped or paused, we re- */
            wind_update(END_MCTRL);     /* enable menus & window controls */
            break;

          case WINDBXGO:                                  /* START button */

            wind_update(BEG_UPDATE);    /* While running, we shut off */
            wind_update(BEG_MCTRL);     /* menus and window controls. */
            
            obj_stchange(windtree, WINDBXPA, ~DISABLED, TRUE);
            xm->mflags |= MU_TIMER;
            xm->mwhich  |= MU_TIMER;
            break;

          default:
            break;
        }
    }
}

/**************************************************************************
 *
 * key_to_obj - Attempt to translate a keystroke into an object.
 *
 *   This routine scans every object in a tree, comparing each extended
 *   object type value to the key value passed to the routine.  If a match
 *   is found, the object number is returned, else NO_OBJECT is returned.
 *
 *   To scan all child objects of a given parent instead of the whole
 *   tree, the GemFast obj_xtfind() routine instead of key_to_obj...
 *          selobj = obj_xtfind(tree, parent, key);
 *
 *************************************************************************/

key_to_obj(ptree, key)
    register OBJECT *ptree;
    register char   key;
{
    register int    curobj;

    key = toupper(key);

    curobj = -1;
    do  {
        curobj++;
        if (key == *(char *)(&(ptree->ob_type))) { 
            return curobj;
        }
    } while (((ptree++)->ob_flags & LASTOB) == FALSE);

    return NO_OBJECT;
}

/**************************************************************************
 *
 * run - Do one iteration of 'something' then return.
 *
 *  The 'something' in this case consists of waiting a few milliseconds
 *  and then incrementing the thermometer display.
 *
 *************************************************************************/

run()
{
    int         speed;
    static int  count = 0;
    GRECT       thmorect;
    
    switch (obj_rbfind(windtree, WINDPBRB, SELECTED)) {

    case WINDBRSL: speed = 250; break;
    case WINDBRME: speed = 125; break;
    case WINDBRFA: speed = 67; break;
        
    }
    
    evnt_timer(speed, 0);
    if (count++ > 99) {
        count = 0;
        obj_offxywh(windtree, WINDPBTH, &thmorect);
        thmo_start(100, &thmorect, TRUE);
    }
    
    thmo_incr();
}

/**************************************************************************
 *
 * main driver.
 *
 *************************************************************************/

main()
{
    int     selobj;
    XMULTI  xm;

    prg_init();
    
    if (NO_WINDOW == w_open()) {
        prg_exit();
    }

    xm.mflags    = MU_MESAG | MU_BUTTON | MU_KEYBD;
    xm.mbmask    = 1;
    xm.mbclicks  = 2;
    xm.mbstate   = 1;
    xm.mtlocount = 1;
    xm.mthicount = 0;

    while (1) {
        evnx_multi(&xm);

        selobj = NO_OBJECT;

        if (xm.mwhich & MU_MESAG) {
            hndl_message(xm.msgbuf);
        }
        
        if (xm.mwhich & MU_KEYBD) {
            selobj = key_to_obj(windtree, (xm.mkreturn & 0x00FF));
            if (selobj != NO_OBJECT && 
                (windtree[selobj].ob_state & DISABLED) == FALSE) {
                if ((windtree[selobj].ob_flags & RBUTTON)) {
                    rbselect(windtree, selobj);
                } else {
                    if (windtree[selobj].ob_flags & SELECTABLE) {
                        windtree[selobj].ob_state ^= SELECTED;
                        objc_draw(windtree, selobj, MAX_DEPTH, windrect);
                    }
                }
            }
        }

        if (xm.mwhich & MU_BUTTON) {
            selobj = hndl_button(xm.mmox, xm.mmoy, xm.mmobutton);
        }
        
        if (selobj != NO_OBJECT) {
            hndl_object(selobj, &xm);
        }
        
        if (xm.mwhich & MU_TIMER) {
            run();
        }
    }
}

