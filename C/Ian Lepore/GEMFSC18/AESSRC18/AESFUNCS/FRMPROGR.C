
/*************************************************************************
 * FRMDSMEN.C - The frm_dsmenu() routine.
 *************************************************************************/

#include <stdarg.h>
#include "gemfast.h"
#include "frmtypes.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif 

/*-------------------------------------------------------------------------
 * The tedinfos for the dialog body text.  
 *   We have to use our own tedinfos instead of sharing the common array
 *   of them in FRMNLDSU.C, because we're non-modal, and other users of
 *   the common array can be invoked while the progress display is up.
 *-----------------------------------------------------------------------*/

static TEDINFO local_tedinfos[] = {
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1},
  {NULL, NULL, NULL, 3, 6, 0, 0x11F0, 0,  0,   1,   1}
};                                                                    

/*------------------------------------------------------------------------
 * the dialog tree...
 *-----------------------------------------------------------------------*/

#define OUTLINED_BOX_SPEC 0x00021100L
#define SHADOWED_BOX_SPEC 0x00FF1100L

static OBJECT progress_dialog[] = {
 { -1,  1, 13, G_BOX,      NONE,       OUTLINED, 0x00021100L, 0x0000, 0x0000, 0x0001, 0x0000},
 { 12,  2, 11, G_IBOX,     NONE,       NORMAL,   0x00001100L, 0x0001, 0x0000, 0x0001, 0x0000},
 {  3, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0001, 0x0001, 0x0001},
 {  4, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0002, 0x0001, 0x0001},
 {  5, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0003, 0x0001, 0x0001},
 {  6, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0004, 0x0001, 0x0001},
 {  7, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0005, 0x0001, 0x0001},
 {  8, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0006, 0x0001, 0x0001},
 {  9, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0007, 0x0001, 0x0001},
 { 10, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0008, 0x0001, 0x0001},
 { 11, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x0009, 0x0001, 0x0001},
 {  1, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   0L,          0x0000, 0x000A, 0x0001, 0x0001},
 { 13, -1, -1, G_BOX,      NONE,       NORMAL,   0x00FF1131L, 0x0001, 0x0000, 0x0001, 0x0001},
 {  0, -1, -1, G_BUTTON,   0x0027,     NORMAL,   0L,          0x0000, 0x0000, 0x0001, 0x0001}
};                                                                                              

#define TEXT_BOX        1
#define FIRST_TEXT_LINE 2                                                                                             
#define THERMO_BAR      12
#define EXIT_BUTTON     13

#define MAXLINES Array_els(local_tedinfos)

/*------------------------------------------------------------------------
 * misc static data...
 *-----------------------------------------------------------------------*/

static FormControl progress_ctl;
static int         initdone = FALSE;
static char        *formatted_text;
static int         lastline;
static int         oldmouse;

/*------------------------------------------------------------------------
 * dummy_do - The form_do() handler when the dialog isn't abortable.
 *-----------------------------------------------------------------------*/

static int dummy_do(ctl)
    FormControl *ctl;
{
    return NO_OBJECT;
}

/*------------------------------------------------------------------------
 * watchbutton_do - The form_do() handler to watch the abort button.
 *  This is a non-modal handler.  It checks the keyboard and mouse button,
 *  and if neither is active, it returns NO_OBJECT.
 *-----------------------------------------------------------------------*/

static int watchbutton_do(ctl)
    FormControl *ctl;
{
    int    obj;
    int    mouseobj;
    XMULTI xm;
    
    xm.mflags    = MU_BUTTON | MU_KEYBD | MU_TIMER;
    xm.mbstate   = 1;
    xm.mbmask    = 1;
    xm.mbclicks  = 1;
    xm.mtlocount = 1;
    xm.mthicount = 0;
    
    
    obj = NO_OBJECT;
    evnx_multi(&xm);
    
    if ((xm.mwhich & MU_KEYBD)
     && (xm.mkreturn & 0x00FF) == '\r') {
        obj = EXIT_BUTTON;
        obj_stchange(ctl->ptree, obj, SELECTED, OBJ_CLIPDRAW, ctl->pboundrect);
    }
    
    if (xm.mwhich & MU_BUTTON) {
        mouseobj = objc_find(ctl->ptree, ROOT, MAX_DEPTH, xm.mmox, xm.mmoy);
        if (mouseobj == NO_OBJECT) {
            gemdos(2, 7); // ding!
        } else if (mouseobj == EXIT_BUTTON) {
            if (graf_watchbox(ctl->ptree, EXIT_BUTTON, SELECTED, NORMAL)) {
                obj = EXIT_BUTTON;
            }
        } else if (mouseobj == ctl->moverobj) {
            obj = mouseobj;
        }
    }
    
    return obj;
}

/*------------------------------------------------------------------------
 * setup_dialog - Construct the dynamic dialog, paint it.
 *-----------------------------------------------------------------------*/

static int setup_dialog(options, increments, button, fmt, args)
    long        options;
    int         increments;
    char       *button;
    char       *fmt;
    va_list     args;
{
    int              status;
    int              numlines;
    int              numbuttons;
    int              maxwidth;
    int              btnwidth;
    int              cumulative_height;
    int              wchar  = gl_wchar;
    int              hchar2 = gl_hchar * 2;
    char            *strptrs[MAXLINES+1];
    char            *strpatches[MAXLINES+1];
    register OBJECT *ptree = progress_dialog;
 
    /*--------------------------------------------------------------------
     * do one-time init, validate parms, merge in default options.
     *-------------------------------------------------------------------*/

    if (!initdone) {
        initdone = TRUE;
        rsc_treefix(ptree);
        if (0 != (status = obj_mkthermo(ptree, THERMO_BAR, 1))) {
            return status;
        }
    }

    if (progress_ctl.ptree != NULL) {
        return -36;
    }

    if (increments >= gl_rwdesk.g_w) {
        return -64;
    } 
    
    if (!(options & FRM_NODEFAULTS)) {
        options |= _FrmDefaults | (FRM_DEFAULT_DYNOPT & ~FRM_MOUSEARROW);
    }
    options |= FRM_MANDATORY_DYNOPT;

    /*--------------------------------------------------------------------
     * if a button was specified, its string is the initial maxwidth.
     *-------------------------------------------------------------------*/

    if (button == NULL) {   
        maxwidth = btnwidth = 0;
    } else {
        maxwidth = btnwidth = strlen(button) + 2;
    }

    /*--------------------------------------------------------------------
     * format the text and load it into the dialog objects.
     * save a pointer to the string pointer for the last text line.
     * this lets easily change the last line of text during an update.
     *-------------------------------------------------------------------*/

    formatted_text = _FrmVFormat(fmt, args, NULL);
    
    _FrmNL2DS(formatted_text, strptrs, strpatches, MAXLINES);
    numlines = _FrmDS2Obj(strptrs, &ptree[FIRST_TEXT_LINE], local_tedinfos,
                            &maxwidth, MAXLINES);

    lastline = TEXT_BOX + numlines;

    /*--------------------------------------------------------------------
     * from this point on, widths are pixels, not characters.  if the
     * thermo bar is wider than the text, it becomes the maxwidth.
     * at this point, maxwidth is the width of the widest text line or
     * the termo bar, but does not include the whitespace gutters on 
     * either side of the text/thermo.
     *-------------------------------------------------------------------*/

    maxwidth *= wchar;
    btnwidth *= wchar;

    if (maxwidth < increments) {
        maxwidth = increments;
    }

    /*--------------------------------------------------------------------
     * set the widths of the dialog and 1st-level children.  set the
     * height of the text strings part of the dialog.
     *-------------------------------------------------------------------*/
    
    _FrmTrWidths(ptree, TEXT_BOX,   maxwidth);
    cumulative_height           = numlines * gl_hchar;
    ptree[TEXT_BOX].ob_height   = cumulative_height;

    /*--------------------------------------------------------------------
     * if a thermo bar was requested, set it up, else hide it.
     *-------------------------------------------------------------------*/
    
    if (increments > 0) {
        cumulative_height          += hchar2;
        ptree[THERMO_BAR].ob_y      = cumulative_height;
        ptree[THERMO_BAR].ob_width  = maxwidth;
        obj_mkthermo(ptree, THERMO_BAR, increments);
        ptree[THERMO_BAR].ob_flags &= ~HIDETREE;
    } else {
        ptree[THERMO_BAR].ob_flags |= HIDETREE;
    }
    
    /*--------------------------------------------------------------------
     * from this point on, maxwidth includes the 2-char whitespace gutter.
     *-------------------------------------------------------------------*/

    maxwidth += 2 * wchar;

    /*--------------------------------------------------------------------
     * if a button was specified, set it up, else hide it.
     *-------------------------------------------------------------------*/

    if (button != NULL) {
        cumulative_height          += hchar2;
        ptree[EXIT_BUTTON].ob_width = btnwidth;
        ptree[EXIT_BUTTON].ob_y     = cumulative_height;
        ptree[EXIT_BUTTON].ob_x     = (maxwidth - btnwidth) / 2;
        ptree[EXIT_BUTTON].ob_flags &= ~HIDETREE;
        ptree[EXIT_BUTTON].ob_spec = (long)button;
    } else {
        ptree[EXIT_BUTTON].ob_flags |= HIDETREE;
    }

    /*--------------------------------------------------------------------
     * now set the width and height of the overal dialog, and handle the
     * DSHADOWED and DSL1TITLE options.
     *-------------------------------------------------------------------*/
    
    cumulative_height          += hchar2;
    ptree->ob_width             = maxwidth;
    ptree->ob_height            = cumulative_height;;

    if (options & FRM_DSHADOWED) {
        ptree->ob_state = SHADOWED;
        ptree->ob_spec  = SHADOWED_BOX_SPEC;
    } else {
        ptree->ob_state = OUTLINED;
        ptree->ob_spec  = OUTLINED_BOX_SPEC;
    }

    /*--------------------------------------------------------------------
     * grab control of the mouse, then init and paint the dialog.
     * we hold on to the mouse semaphore until the progress dialog is
     * closed, because we (potentially at least) have a screen area 
     * saved via blit and we can't allow redraws; also, since we can't
     * respond to redraws and we may be sitting over a window, we can't
     * allow window controls.
     *-------------------------------------------------------------------*/

    wind_update(BEG_MCTRL);
    if (options & FRM_MOUSEARROW) {
        oldmouse = graf_mouse(ARROW, NULL);
    } else {
        oldmouse = -1;
    }

    {
        register FormControl *ctl = &progress_ctl;
        
        _FrmSetup(ctl, options|FRM_DSTART, ptree, &gl_rwdesk);
        frm_start(ctl);
        frm_draw(ctl, ROOT);
    
        ctl->form_do = (button == NULL) ? dummy_do : watchbutton_do;
    }
    
    return 0;
}

/*------------------------------------------------------------------------
 * update_dialog - Update the thermo bar and/or text in the dialog.
 *-----------------------------------------------------------------------*/

static int update_dialog(new_position, fmt, args)
    int      new_position;
    char    *fmt;
    va_list  args;
{
    register FormControl *ctl = &progress_ctl;
    static char          linebuf[128];
    
    if (ctl->ptree == NULL) {
        return FALSE;
    }

    if (fmt != NULL) {
        vsprintf(linebuf, fmt, args);
        rsc_sstrings(ctl->ptree, lastline, linebuf, -1);
        frm_draw(ctl, lastline);
    }
    
    if (new_position != 0) {
        obj_udthermo(ctl->ptree, THERMO_BAR, new_position, ctl->pboundrect);
    }

    return (EXIT_BUTTON == frm_do(ctl, ROOT));
}

/*------------------------------------------------------------------------
 * cleanup_dialog - Remove dialog from the screen, release resources.
 *-----------------------------------------------------------------------*/

static int cleanup_dialog()
{
    register FormControl *ctl = &progress_ctl;
    
    if (ctl->ptree != NULL) {
        frm_finish(ctl);
        frm_cleanup(ctl);
        if (oldmouse != -1) {        
            graf_mouse(oldmouse, NULL);
        }
        wind_update(END_MCTRL);
        _FrmVFree(formatted_text);
        ctl->ptree = NULL;
    }
    return 0;
}

/*------------------------------------------------------------------------
 * frm_progress - Dispatch the various activities for progress reporting.
 *-----------------------------------------------------------------------*/

int frm_progress(options, increments, buttons, fmt)
    long options;
    int  increments;
    char *buttons;
    char *fmt;
{
    va_list args;
    int     rv;

    va_start(args, fmt);
    switch ((options & FRM_ACTIONBITS) >> 16) {
      case FRM_PSTART >> 16:
        rv = setup_dialog(options, increments, buttons, fmt, args);
        break;      
      case FRM_PUPDATE >> 16:
        rv = update_dialog(increments, fmt, args);
        break;
      case FRM_PFINISH >> 16:
        rv = cleanup_dialog();
        break;
      default:
        rv = -32;
        break;
    }
    va_end(args); 
    
    return rv;
}
