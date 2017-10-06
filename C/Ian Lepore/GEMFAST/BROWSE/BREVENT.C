/**************************************************************************
 * BREVENT - Handle GEM events for browser windows.  Create/del browsers.
 *
 *  This is where all the cool stuff is if you're looking for window
 *  handling examples.  
 *************************************************************************/

#undef DEBUG

#include <gemfast.h>
#include <osbind.h>

#define BROWSER_INTERNALS
#include "browser.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

/*---------------------------------------------------------------------
 * static persistant variables (and one global var).
 *-------------------------------------------------------------------*/

short         br_errno = 0;

static DlList browser_list = {NULL, NULL};
static short  vdi_handle   = 0;
static short  min_window_width;
static short  min_window_height;

/*---------------------------------------------------------------------
 * constants for windowing.
 *-------------------------------------------------------------------*/

#define WI_KIND             (0x0FFF&~INFO) /* all controls except info */
#define NO_WINDOW           -1

#define MAX_SCROLL_DELAY    300         /* in millisecs */

#define MIN_WINDOW_WIDTH_IN_CHARS   21
#define MIN_WINDOW_HEIGHT_IN_CHARS  10

/*---------------------------------------------------------------------
 * Private Functions...
 *-------------------------------------------------------------------*/

/**************************************************************************
 * gem_init - open our own local vdi workstation, get some static values.
 *************************************************************************/

static short gem_init()
{
    short   dmy;
    XMULTI  xm;

    /*------------------------------------------------------------------------
     * get some system sizes, store them in the static vars.
     *----------------------------------------------------------------------*/

    min_window_width  = gl_wchar * MIN_WINDOW_WIDTH_IN_CHARS;
    min_window_height = gl_hchar * MIN_WINDOW_HEIGHT_IN_CHARS;

    /*------------------------------------------------------------------------
     * fix TOS 1.x double-scroll bug, by waiting momentarily for a d-click.
     *   by doing this, we eliminate the bug in TOS that causes two scroll
     *   events to be delivered on a single click in a scroll arrow/bar.
     *   since we aren't likely to really get a d-click right now, we also
     *   wait for a timer event of 1ms, so we get control back right away.
     *   just the mere fact that we waited once for a double-click seems
     *   to completely eliminate the double-scroll bug.
     *----------------------------------------------------------------------*/

        xm.mflags    = MU_TIMER|MU_BUTTON;
        xm.mbclicks  = 2;
        xm.mbmask    = 1;
        xm.mbstate   = 1;
        xm.mtlocount = 1;
        xm.mthicount = 0;
        evnx_multi(&xm);

    /*------------------------------------------------------------------------
     * open a vdi workstation, store the handle in the static var.
     *----------------------------------------------------------------------*/

    if (0 == (vdi_handle = apl_vopen())) {
        br_errno = -35;     /* no more handles */
    } else {
        vsf_interior(vdi_handle, IS_HOLLOW);
        vsf_perimeter(vdi_handle, FALSE);
    }
    return vdi_handle;
}

/**************************************************************************
 * gem_cleanup - close our local vdi workstation.
 *************************************************************************/

static void gem_cleanup()
{
    apl_vclose(vdi_handle);
    vdi_handle = 0;
}

/**************************************************************************
 * draw_text_window - paint text in window.
 *************************************************************************/

static void draw_text_window(browser, redraw_rect)
    register Browser    *browser;
    GRECT               *redraw_rect;
{
    register
      BrowseLine *curline;
    VRECT        redraw_area;
    short        xcur      = browser->workrect.g_x;
    short        ycur      = browser->workrect.g_y;
    short        hchar     = browser->hchar;
    short        linesleft = browser->rows_in_window;
    short        leftcol   = browser->leftcol_num;
    short        num_cols  = browser->cols_in_window;
    short        terminate;
    char         savechar;
    char         *pwrk;

    graf_mouse(M_OFF, 0L);

    rc_gtov(redraw_rect, &redraw_area);

    vs_clip(vdi_handle, TRUE, &redraw_area);
    vr_recfl(vdi_handle, &redraw_area);

    if (NULL == (curline = browser->linelist.cur))
        goto NO_TEXT;

    while (curline && linesleft) {
        ycur += hchar;
        if (leftcol < curline->length) {
            pwrk = &curline->string[leftcol];
            terminate = curline->length - leftcol;
            if (terminate <= num_cols) {
                savechar = 0x00;
            } else {
                savechar = pwrk[num_cols];
                pwrk[num_cols] = 0x00;
            }
            v_gtext(vdi_handle, xcur, ycur, pwrk);
            if (savechar)
                pwrk[num_cols] = savechar;
        }
        --linesleft;
        curline = curline->hdr.next;
    }

NO_TEXT:

    graf_mouse(M_ON, 0L);

}

/**************************************************************************
 * snap_window - snap work area to character boundary.
 *
 *   also handles clipping to desktop sizes and minimum sizing of window.
 *   updates the windrect passed to the function, and browser fields
 *   'workrect', 'rows_in_window', & 'cols_in_window'.
 *
 *   this is called for move/size/full events, and also to snap & clip the
 *   initial sizes just before opening the window.  (ie, it must not
 *   do anything to the window itself; browser->whandle may == NO_WINDOW).
 *************************************************************************/

static void snap_window(browser, windrect)
    register Browser  *browser;
    register GRECT    *windrect;
{
    if (windrect->g_w < min_window_width)
        windrect->g_w = min_window_width;
    else if (windrect->g_w > gl_rwdesk.g_w)
        windrect->g_w = gl_rwdesk.g_w;

    if (windrect->g_h < min_window_height)
        windrect->g_h = min_window_height;
    else if (windrect->g_h > gl_rwdesk.g_h)
        windrect->g_h = gl_rwdesk.g_h;

    wind_calc(WC_WORK, WI_KIND, *windrect,
                &browser->workrect.g_x, &browser->workrect.g_y,
                &browser->workrect.g_w, &browser->workrect.g_h);

    browser->workrect.g_x = browser->wchar *
        ((browser->workrect.g_x + browser->wchar/2) / browser->wchar);

    wind_calc(WC_BORDER, WI_KIND, browser->workrect,
                &windrect->g_x, &windrect->g_y,
                &windrect->g_w, &windrect->g_h);

    browser->cols_in_window =
        (browser->workrect.g_w + browser->wchar - 1) / browser->wchar;

    browser->rows_in_window =
        (browser->workrect.g_h + browser->hchar - 1) / browser->hchar;
}

static void scroll_calc(curline, datalines, windowlines, pslidesize, pslidepos)
    long  curline;
    long  datalines;
    long  windowlines;
    short *pslidesize;
    short *pslidepos;
/**************************************************************************
 * calc the size and position of a slider (eg, a window scroll slider).
 *************************************************************************/
{
    short slsize = 1000;
    short slpos  = 1;

    if (windowlines >= datalines) {
        goto ERROR_EXIT;
    }
    
    slsize = (short)((1000L * windowlines) / datalines);
    slpos  = (short)((1000L * curline) / (datalines-windowlines));

    if (slsize < gl_hchar) {
        slsize = -1;
    } else if (slsize > 1000) {
        slsize = 1000;
    }

    if (slpos < 1) {
        slpos = 1;
    } else if (slpos > 1000) {
        slpos = 1000;
    }

ERROR_EXIT:

    *pslidesize = slsize;
    *pslidepos  = slpos;
}


/**************************************************************************
 * vscroll_recalc - recalc vscroll bar, call wind_set() to update window.
 *************************************************************************/

static void vscroll_recalc(browser)
    register Browser *browser;
{
    short vslsize;
    short vslpos;
    
    scroll_calc((long)browser->curline_num,   
        (long)browser->num_lines, (long)browser->rows_in_window,    
        &vslsize, &vslpos);

    wind_set(browser->whandle, WF_VSLSIZE, (short)vslsize, 0, 0L);
    wind_set(browser->whandle, WF_VSLIDE,  (short)vslpos,  0, 0L);

}

/**************************************************************************
 * hscroll_recalc - recalc hscroll bar, call wind_set() to update window.
 *************************************************************************/

static void hscroll_recalc(browser)
    register Browser *browser;
{
    short hslsize;
    short hslpos;

    scroll_calc((long)browser->leftcol_num,
        (long)browser->longest_line, (long)browser->cols_in_window,
        &hslsize, &hslpos);

    wind_set(browser->whandle, WF_HSLSIZE, (short)hslsize, 0, 0L);
    wind_set(browser->whandle, WF_HSLIDE,  (short)hslpos,  0, 0L);
}

/**************************************************************************
 * redraw_window - Standard redraw message handler.
 *************************************************************************/

static void redraw_window(browser, redraw_rect)
    Browser         *browser;
    register GRECT *redraw_rect;
{
    short          whandle = browser->whandle;
    register int   calltype;
    GRECT          t1;

    calltype = WF_FIRSTXYWH;

    wind_update(BEG_UPDATE);
    for (;;) {
        wind_get(whandle, calltype, &t1.g_x, &t1.g_y, &t1.g_w, &t1.g_h);
        if (t1.g_w == 0 && t1.g_h == 0)
            break;
        if (rc_intersect(redraw_rect, &t1)) {
            draw_text_window(browser, &t1);
        }
        calltype = WF_NEXTXYWH;
    }
    wind_update(END_UPDATE);
}

/**************************************************************************
 * vscroll_window - handle vertical scrolling of window
 *************************************************************************/

static void vscroll_window(browser, scroll_msg, is_slider)
    register Browser  *browser;
    short             scroll_msg;
    short             is_slider;
{
    long nlines;
    long scroll_lines;
    int  seek_type;

    if (NULL == browser->linelist.cur)
        return;

    if ( 0 > (nlines = browser->num_lines - browser->rows_in_window)) {
        nlines = 0;
    }

    if (is_slider) {
        seek_type = SEEK_SET;
        scroll_lines = (nlines * scroll_msg) / 1000;
        browser->curline_num = scroll_lines;
    } else {
        seek_type = SEEK_CUR;
        switch (scroll_msg) {
          case 0: scroll_lines = -browser->rows_in_window; break;
          case 1: scroll_lines =  browser->rows_in_window; break;
          case 2: scroll_lines = -1;                        break;
          case 3: scroll_lines =  1;                        break;
        }
        browser->curline_num += scroll_lines;
    }

    if (browser->curline_num <= 0) {
        seek_type = SEEK_SET;
        scroll_lines = 0;
        browser->curline_num = 0;
    } else if (browser->curline_num > nlines) {
        seek_type = SEEK_SET;
        scroll_lines = nlines;
        browser->curline_num = nlines;
    }

    dl_seek(&browser->linelist, (long)scroll_lines, seek_type);
    vscroll_recalc(browser);
    redraw_window(browser, &browser->workrect);
}

/**************************************************************************
 * hscroll_window - handle horizontal scrolling of window
 *************************************************************************/

static void hscroll_window(browser, scroll_msg, is_slider)
    register Browser  *browser;
    short             scroll_msg;
    short             is_slider;
{
    long ncols;
    long scroll_cols;

    if (NULL == browser->linelist.cur)
        return;

    if ( 0 > (ncols = browser->longest_line - browser->cols_in_window)) {
        ncols = 0;
    }

    if (is_slider) {
        scroll_cols = (ncols * scroll_msg) / 1000;
        browser->leftcol_num = scroll_cols;
    } else {
        switch (scroll_msg) {
          case 4: scroll_cols = -browser->cols_in_window; break;
          case 5: scroll_cols =  browser->cols_in_window; break;
          case 6: scroll_cols = -1;                       break;
          case 7: scroll_cols =  1;                       break;
        }
        browser->leftcol_num += scroll_cols;
    }

    if (browser->leftcol_num < 0) {
        browser->leftcol_num = 0;
    } else if (browser->leftcol_num > ncols) {
        browser->leftcol_num = ncols;
    }

    hscroll_recalc(browser);
    redraw_window(browser, &browser->workrect);
}

/**************************************************************************
 * move_window - snap work area to character boundary and move window.
 *************************************************************************/

static void move_window(browser, moverect)
    Browser *browser;
    GRECT   *moverect;
{
    snap_window(browser, moverect);
    wind_set(browser->whandle, WF_CURRXYWH, *moverect);
}

/**************************************************************************
 * size_window - resize a window
 *  snap_window() is called to update control data in browser structure.
 *************************************************************************/

static void size_window(browser, sizerect)
    register Browser *browser;
    GRECT            *sizerect;
{
    snap_window(browser, sizerect);
    wind_set(browser->whandle, WF_CURRXYWH, *sizerect);
    vscroll_recalc(browser);
    hscroll_recalc(browser);

}

/**************************************************************************
 * full_window: toggle a window between its previous and full sizes.
 *************************************************************************/

static void full_window(browser)
    register Browser    *browser;
{
    GRECT   newrect,
            currect;

    /* get the current outside browser rectangle     */

    winx_get(browser->whandle, WF_CURRXYWH, &currect);

    /* is the current size the same as the full size? */

    if ((gl_rwdesk.g_w != currect.g_w) || (gl_rwdesk.g_h != currect.g_h)) {
        /* no, so use full size */
        newrect = gl_rwdesk;
    } else {
        /* yes, is the previous size also the same as the full size? */
        winx_get(browser->whandle, WF_PREVXYWH, &newrect);
        if ((newrect.g_w == currect.g_w) && (newrect.g_h == currect.g_h)) {
            /* yes, use the minimum size */
            newrect.g_w = min_window_width;
            newrect.g_h = min_window_height;
            newrect.g_x = currect.g_x;
            newrect.g_y = currect.g_y;
        }
        /* otherwise, use the WF_PREVXWYH rect */
    }

    snap_window(browser, &newrect);
    wind_set(browser->whandle, WF_CURRXYWH, newrect);
    vscroll_recalc(browser);
    hscroll_recalc(browser);
}

/**************************************************************************
 * arrow_window - handle scroll arrow events with a local modal loop.
 *************************************************************************/

static void arrow_window(browser, scrollmsg)
    register Browser *browser;
    register short   scrollmsg;
{
    short            dmy;
    short            mbuttons;
    register short   scroll_delay = MAX_SCROLL_DELAY;

    wind_update(BEG_MCTRL);
    for (;;) {
        if (scrollmsg < 4) {
            vscroll_window(browser, scrollmsg, FALSE);
        } else {
            hscroll_window(browser, scrollmsg, FALSE);
        }
        graf_mkstate(&dmy, &dmy, &mbuttons, &dmy);
        if (!(mbuttons & 0x0001))
                    break;
        evnt_timer(scroll_delay, 0);
        scroll_delay /= 2;
    }
    wind_update(END_MCTRL);
}

/*****************************************************************************
 * do_delete_browser - delete a browser and free its resources.
 ****************************************************************************/

static void do_delete_browser(list, browser)
    DlList           *list;
    register Browser *browser;
{

    br_action(browser, BR_PREDELETE, 0L);

    if (NO_WINDOW != browser->whandle) {
        wind_close(browser->whandle);
        wind_delete(browser->whandle);
    }

    if (NULL != browser->title)
        br_free(browser->title);

    br_ldelete(browser, NULL);

    dl_remove(list, browser);
    br_free(browser);

    if (NULL == browser_list.head) /* if we just closed the last browser, we */
        gem_cleanup();             /* can also close the vdi workstation now.*/

}

/*---------------------------------------------------------------------
 * Public Functions...
 *-------------------------------------------------------------------*/

/**************************************************************************
 * br_handle - Find the Browser object for a given window handle.
 *************************************************************************/

Browser *br_handle(whandle)
     register int  whandle;
{
    register Browser *pcur;

    for (pcur = browser_list.head; pcur != NULL; pcur = pcur->hdr.next) {
        if (whandle == pcur->whandle)
            break;
    }
    return pcur;
}

/**************************************************************************
 * br_title - change the title of a browser window.
 *************************************************************************/

char *br_title(browser, newtitle)
    Browser     *browser;
    char        *newtitle;
{
    char        *oldtitle;
    char        *title;
    int         newlen;
    char        *strcpy();
    GRECT       windrect;

    if (browser == NULL) {
        return NULL;
    }

    if (newtitle == NULL) {
        goto UPDATE_WINDOW;
    }

    oldtitle = browser->title;
    newlen = strlen(newtitle);

    if (oldtitle != NULL && newlen <= strlen(oldtitle)) {
        strcpy(oldtitle, newtitle);
    } else {
        if (NULL == (title = br_malloc(newlen+1))) {
            br_errno = -39;
            return NULL;
        }
        browser->title = strcpy(title,newtitle);
        if (oldtitle != NULL) {
            br_free(oldtitle);
        }
    }

UPDATE_WINDOW:

    wind_set(browser->whandle, WF_NAME, browser->title, NULL);

    return title;
}

/*****************************************************************************
 * br_update - update window scroll bars, and optionally repaint workarea.
 ****************************************************************************/

void br_update(browser, repaint)
    register Browser *browser;
    int              repaint;
{
    if (NULL == browser || NO_WINDOW == browser->whandle)
        return;

    br_recount(browser);

    vscroll_recalc(browser);
    hscroll_recalc(browser);

    if (repaint)
        redraw_window(browser, &browser->workrect);
}

/**************************************************************************
 * br_shutdown - delete all browser objects.
 *************************************************************************/

void br_shutdown()
{
    dl_freelist(&browser_list, do_delete_browser);
}

/**************************************************************************
 * br_action - request action from the browser
 *************************************************************************/

void br_action(browser, action, lparm)
    Browser *browser;
    int     action;
    long    lparm;
{
    if (browser == NULL) {
        return;
    }

    if (browser->useraction != NULL) {
        if ((*browser->useraction)(browser, action, lparm)) {
            return;
        }
    }

    switch (action) {
    }
}

/**************************************************************************
 * br_delete - delete a browser object.
 *************************************************************************/

void br_delete(browser)
    Browser *browser;
{
    if (browser != NULL) {
        do_delete_browser(&browser_list, browser);
    }

}

/**************************************************************************
 * br_event - handle events pertaining to browser windows.
 *************************************************************************/

void br_event(xm)
    register XMULTI  *xm;
{
    register Browser *browser;
    register short   *msgbody;
    short            *msgbuff;
    register short   msgwindow;
    register long    thekey;

    if (NULL == browser_list.head)
        return;

    if (!(xm->mwhich & (MU_MESAG|MU_KEYBD)))
        return;

    msgbuff   = (short *)xm->msgbuf;
    msgwindow = msgbuff[3];
    msgbody   = &msgbuff[4];

    if (NULL == (browser = br_handle(msgwindow)))
        return;

    if (xm->mwhich & MU_KEYBD) {
        thekey = ((long)xm->mmokstate << 16) | xm->mkreturn;
        br_action(browser, BR_KEYSTROKE, thekey);
    }

    if (xm->mwhich & MU_MESAG) {

        switch(msgbuff[0]) {

          case WM_CLOSED:

            br_delete(browser);
            break;

          case WM_TOPPED:

            wind_set(msgwindow, WF_TOP, 0L, 0L);
            break;

          case WM_REDRAW:

            redraw_window(browser, msgbody);
            goto CLEAR_MESSAGE;

          case WM_MOVED:

            move_window(browser, msgbody);
            goto CLEAR_MESSAGE;

          case WM_SIZED:

            size_window(browser, msgbody);
            goto CLEAR_MESSAGE;

          case WM_FULLED:

            full_window(browser);
            goto CLEAR_MESSAGE;

          case WM_ARROWED:

            arrow_window(browser, *msgbody);
            goto CLEAR_MESSAGE;

          case WM_VSLID:

            vscroll_window(browser, *msgbody, TRUE);
            goto CLEAR_MESSAGE;

          case WM_HSLID:

            hscroll_window(browser, *msgbody, TRUE);
CLEAR_MESSAGE:
            xm->mwhich &= ~MU_MESAG; /* hide this message, we handled it */
            break;

        } /* END switch (msgbuff[0]) */

    } /* END if (message event) */

}

/**************************************************************************
 * br_create - create a new browser object, open window for it.
 *  if a pre-built linelist is passed in, attach it to browser.
 *************************************************************************/

Browser *br_create(ptitle, linelist, openrect)
    char        *ptitle;
    DlList      *linelist;
    GRECT       *openrect;
{
    register Browser *pnew;
    char            *tstring;
    short           whandle;
    GRECT           windrect;

    br_errno = 0;   /* assume success */

    /*---------------------------------------------------------------------
     * if there are no browsers open yet, we'll need a vdi workstation.
     *-------------------------------------------------------------------*/

    if (NULL == browser_list.head) {
        if (0 == gem_init()) {
            br_errno = -35;
            goto ERROR_EXIT;
        }
    }

    /*---------------------------------------------------------------------
     * allocate a new Browser struct.
     * link the new browser into the list of active browsers.
     * init things we need valid to clean up after it if an error happens.
     * (basically, all fields referenced by the br_delete process have
     * to be initialized here, because we could call br_delete at any
     * point after this block).
     *-------------------------------------------------------------------*/

    if (NULL == (pnew = br_malloc(sizeof(Browser)))) {
        br_errno = -39;
        goto ERROR_EXIT;
    }

    memset(pnew, 0, sizeof(*pnew));

    pnew->whandle = NO_WINDOW;
    pnew->wchar   = gl_wchar;
    pnew->hchar   = gl_hchar;

    if (NULL != linelist) {
        pnew->linelist = *linelist;
        br_recount(pnew);
    }

    dl_addhead(&browser_list, pnew);

    /*---------------------------------------------------------------------
     * create the window for the browser.
     *-------------------------------------------------------------------*/

    if (0 > (whandle = wind_create(WI_KIND, gl_rwdesk))) {
        br_errno = -35;
        goto ERROR_EXIT;
    }

    pnew->whandle = whandle;

    if (NULL == br_title(pnew, ptitle)) {
        goto ERROR_EXIT;
    }

    /*---------------------------------------------------------------------
     * figure out where to put the window, and how big to make it.
     *-------------------------------------------------------------------*/

    if (NULL != openrect) {
        pnew->workrect = *openrect;
    } else {
        if (0 == pnew->num_lines) {
            pnew->workrect.g_x = gl_rwdesk.g_x + gl_wchar;
            pnew->workrect.g_y = gl_rwdesk.g_y + gl_hchar;
            pnew->workrect.g_w = (gl_rwdesk.g_w / 4) - gl_wchar;
            pnew->workrect.g_h = (gl_rwdesk.g_h / 4) - gl_hchar;
        } else {
            pnew->workrect.g_x = gl_rwdesk.g_x;
            pnew->workrect.g_y = gl_rwdesk.g_y;
            pnew->workrect.g_w = 1 + (gl_wchar * pnew->longest_line);
            pnew->workrect.g_h = 1 + (gl_hchar * pnew->num_lines);
        }
    }

    rc_intersect(&gl_rwdesk, &pnew->workrect);
    winx_calc(WC_BORDER, WI_KIND, pnew->workrect, &windrect);
    rc_intersect(&gl_rwdesk, &windrect);
    snap_window(pnew, &windrect);

    if (0 == wind_open(whandle, windrect)) {
        br_errno = -37;
        goto ERROR_EXIT;
    }

    vscroll_recalc(pnew);
    hscroll_recalc(pnew);

    /*---------------------------------------------------------------------
     * return pointer for Success, or cleanup and return NULL for failure.
     *-------------------------------------------------------------------*/

    return pnew;

ERROR_EXIT:

    if (NULL != pnew)
        br_delete(pnew);

    return NULL;
}

