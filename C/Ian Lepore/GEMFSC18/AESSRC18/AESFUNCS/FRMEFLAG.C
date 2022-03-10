/*****************************************************************************
 *
 ****************************************************************************/

#include <osbind.h>
#include <stdarg.h>
#include "gemfast.h"
#include "frmtypes.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define  TRUE       1
  #define  FALSE      0
#endif

static char cant_flagit_alert[] = "[3]"
    "[An error has occured with an"
    "|item you selected or modified."
    "|There are not enough system"
    "|resources to flag the object"
    "|and display the error message."
    "][ Continue ]"
    ;

static OBJECT msgtree[] = {
    -1,  1,  1, G_BOX,  NONE,   SHADOWED, 0x00FF2100L, 0, 0, 0, 0,
     0,  2, 21, G_BOX,  NONE,   NORMAL,   0x00000000L, 1, 0, 0, 0,
     3, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 0, 0, 1,
     4, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 1, 0, 1,
     5, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 2, 0, 1,
     6, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 3, 0, 1,
     7, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 4, 0, 1,
     8, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 5, 0, 1,
     9, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 6, 0, 1,
    10, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 7, 0, 1,
    11, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 8, 0, 1,
    12, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0, 9, 0, 1,
    13, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,10, 0, 1,
    14, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,11, 0, 1,
    15, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,12, 0, 1,
    16, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,13, 0, 1,
    17, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,14, 0, 1,
    18, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,15, 0, 1,
    19, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,16, 0, 1,
    20, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,17, 0, 1,
    21, -1, -1, G_TEXT, NONE,   NORMAL,   0L,          0,18, 0, 1,
     1, -1, -1, G_TEXT, LASTOB, NORMAL,   0L,          0,19, 0, 1,
};

#define TEXT_BOX        1
#define FIRST_TEXT_LINE 2

/**************************************************************************
 * treeplace - Figure out a good place to hang the text box on the screen.
 *************************************************************************/

static void treeplace(ptree, vdirect)
    register OBJECT *ptree;
    register VRECT  *vdirect;
{
    register int    wrkint1, wrkint2, wrkint3;

    wrkint1 = vdirect->v_y1;
    wrkint2 = gl_vwout[1] - vdirect->v_y2;
    wrkint3 = ptree->ob_height + gl_hchar + 1;

    if (wrkint1 > wrkint2) {
        ptree->ob_y = wrkint1 - wrkint3;        /* place above object */
    } else {
        ptree->ob_y = vdirect->v_y2 + gl_hchar; /* place below object */
    }
    
    wrkint1 = vdirect->v_x1;
    wrkint2 = gl_vwout[0] - vdirect->v_x2;
    wrkint3 = ptree->ob_width + gl_wchar + 1;

    if (wrkint1 > wrkint2) {
        ptree->ob_x = wrkint1 - wrkint3;
    } else {
        ptree->ob_x = vdirect->v_x2 + gl_wchar;
    }
    
    frm_confine(ptree, &gl_rwdesk);
}

/**************************************************************************
 *
 * frm_eflag - Flag an erronious object.
 *
 *************************************************************************/

int frm_eflag(ptree, obj, fmt)
    OBJECT *ptree;
    int     obj;
    char    *fmt;
{
    va_list     args;
    int         dmy;
    int         vdi_handle;
    int         maxwidth = 0;
    int         numlines;
    int         msglen;
    void        *blitbuffer;
    char        *pmsgtext;
    char        *msglines[FRM_DSMAXSTRINGS+1];
    GRECT       flagrect;
    GRECT       msgrect;
    GRECT       saverect;
    VRECT       flagbox;
    XMULTI      xm;
    static int  initdone = FALSE;

    /*----------------------------------------------------------------------
     * Start by ringing the user's bell <snicker>.  Believe it or not,
     * doing this first helps hide the fact that it takes about 1/4 second
     * to get the error display up on the screen.   (Don't ask me why, do
     * I look like a psychologist or something?)
     *--------------------------------------------------------------------*/

    Bconout(2,'\007');                                   /* ding...       */

    if (!initdone) {
        initdone = TRUE;
        rsc_treefix(msgtree);
        msgtree[TEXT_BOX].ob_y = gl_hchar / 2;
    }
    
    if (0 == (vdi_handle = apl_vshared())) {
        goto ERROR_EXIT;
    }

    /*----------------------------------------------------------------------
     * Calc the rectangles involved with the object to be flagged.
     *--------------------------------------------------------------------*/

    obj_clcalc(ptree, obj, &flagrect, NULL);
    rc_gadjust(&flagrect, 5, 3);
    rc_gtov(&flagrect, &flagbox);

    /*----------------------------------------------------------------------
     * Fix up the error message text tree.  The fixup will change the
     * size of the tree. Upon return, calc the location of the tree, (note
     * that this process can fail, if we can't fit the text on the screen).
     * Calc rectangles involved with the final placement of the text tree.
     *--------------------------------------------------------------------*/

    va_start(args, fmt);
    pmsgtext = _FrmVFormat(fmt, args, &msglen);
    va_end(args);
    
    if (msglen == -1) {
        goto ERROR_EXIT;
    }

    _FrmNL2DS(pmsgtext, msglines, NULL, FRM_DSMAXSTRINGS);
    numlines = _FrmDS2Obj(msglines, &msgtree[FIRST_TEXT_LINE], NULL, 
                            &maxwidth, FRM_DSMAXSTRINGS);
                            
    _FrmTrWidths(msgtree, TEXT_BOX, gl_wchar * maxwidth);
    msgtree[TEXT_BOX].ob_height = gl_hchar * numlines;

    msgtree[ROOT].ob_width  = gl_wchar * (maxwidth + 2);
    msgtree[ROOT].ob_height = gl_hchar * (numlines + 1);

    treeplace(msgtree, &flagbox);

    obj_clcalc(msgtree, ROOT, &msgrect, NULL);
    rc_copy(&msgrect,  &saverect);
    rc_union(&flagrect, &saverect);
    rc_gadjst(&saverect, 3, 2);

    /*----------------------------------------------------------------------
     * Save the screen area, display the text message and flag the
     * object.  Wait for a button or key, upon event restore the screen.
     *--------------------------------------------------------------------*/

    wind_update(BEG_MCTRL);
    wind_update(BEG_UPDATE);
    
    if (NULL == (blitbuffer = grf_memblit(GRF_NORMAL, NULL, &saverect)))
        goto ERROR_EXIT;
        
    graf_mouse(M_OFF, 0L);
    vsl_width(vdi_handle, 3);
    vsl_color(vdi_handle, 2);                           /* red */
    vs_clip(vdi_handle, TRUE, &gl_rfscrn);
    v_rbox(vdi_handle, &flagbox);                      /* flag object */
    vs_clip(vdi_handle, FALSE, &gl_rfscrn);
    vsl_color(vdi_handle, 1);
    vsl_width(vdi_handle, 1);
    graf_mouse(M_ON, 0L);
    
    objc_draw(msgtree, R_TREE, MAX_DEPTH, msgrect); /* show text  */
    
    xm.mflags   = MU_BUTTON | MU_KEYBD;
    xm.mbclicks = 1;
    xm.mbmask   = 1;
    xm.mbstate  = 1;
    
    evnx_multi(&xm);

    grf_memblit(GRF_NORMAL, blitbuffer, &saverect);

    if (xm.mwhich & MU_BUTTON) {
        xm.mbstate = 0;              /* wait for button-up */
        xm.mflags  = MU_BUTTON;
        evnx_multi(&xm);
    }

    wind_update(END_UPDATE);
    wind_update(END_MCTRL);

    _FrmVFree(pmsgtext);

    /*----------------------------------------------------------------------
     * return success.
     *--------------------------------------------------------------------*/

    return 0;
    
ERROR_EXIT:
            
    form_alert(1,cant_flagit_alert);
    return -1;
}

