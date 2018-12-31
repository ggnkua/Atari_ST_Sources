/*
 *  textdemo.c -- Demonstrates ways of using GEM's text features.
 *      by Corey S. Cole
 *      Copyright 1986 ANTIC Publishing
 *      Thanks to Digital Research Inc. for their "DOODLE.C" application;
 *      Save buffer and dialogue handling based on doodle, with permission.
 */

#include "portab.h"                     /* portable program conventions */
#include "machine.h"                    /* machine dependencies         */
#include "gembind.h"                    /* gem binding structs          */
#include "obdefs.h"                     /* gem object definitions       */
#include "taddr.h"                      /* tree-parsing definitions     */
#include "textdemo.h"                   /* Definitions for this appl    */
#include "txdemo.h"                     /* Resource defs for this appl  */

#if I8086
extern  long            dos_alloc();
#define malloc(x)       dos_alloc(x)
#define free(x)         dos_free(x)
#endif

#if ALCYON
extern  long            gemdos();
#define malloc(x)       gemdos(0x48, x)
#define free(x)         gemdos(0x49, x)
#endif

#ifdef MEGAMAX
extern  long    malloc();
#endif

extern  char    *xprintf();

int     gl_apid, gem_handle, vdi_handle, winHandle;
int     work_in[] = { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 2 };
int     contrl[11];             /* control inputs               */
int     intin[80];              /* max string length            */
int     ptsin[256];             /* polygon fill points          */
int     intout[45];             /* open workstation output      */
int     ptsout[12];
int     work_out[57];           /* open virt workstation values */
int     xfull, yfull, wfull, hfull;
long    gl_menu, save_buf, save_size;
MFDB    save_mfdb;                      /*  Save buffer form defn blk   */
MFDB    scrn_mfdb;                      /*  screen memory form defn blk */
GRECT   scrn_area;                      /*  whole screen area           */
GRECT   win_area;                       /*  Interior of text window     */
GRECT   save_area;                      /*  area for saving screen img  */

char    justCodes[]  = "NCWB";          /*  Justification codes         */
char    horizCodes[] = "LCR";           /*  Horizontal alignment codes  */
char    vertCodes[]  = "BHAFDT";        /*  Vertical alignment codes    */
char    pixelCodes[] = "NY";            /*  Absolute height (no/yes)    */
char    text[40]     = "Here is your line of text";
char    nullString[] = "";
struct textBlock  textLine = { text, 8, 100, 300, 20, CHARJUST, LEFT,
        BASELINE, 0, SYSFONT, 10, TRUE, EFF_NONE, BLACK, WHITE };


#if I8086
GEMAIN()
#else
main(argc, argv)
        int     argc;           /*  Number of command line arguments    */
        char    *argv[];        /*  Command line arguments              */
#endif
{
        int     termType;

        termType = gemInit();           /*  Initialize application      */
        if (! termType)
                mainLoop();             /*  Handle messages             */
        terminate(termType);
}

terminate(termType)                     /*  Exit application cleanly    */
        int     termType;
{
        switch (termType) {

                case  0 :
                default :
                        wind_close(winHandle);
                        wind_delete(winHandle);

                case  5 :
#if I8086
                        vst_unload_fonts(vdi_handle, 0);
#endif
                        menu_bar(0x0L, FALSE);

                case  4 :
                        free(save_buf);

                case  3 :
                        v_clsvwk(vdi_handle);

                case  2 :
                        wind_update(END_UPDATE);
                        appl_exit();

                case  1 :
                        break;
        }
}

gemInit()                       /*  Initialize GEM & window     */
{
        int     scrn_width, scrn_height, scrn_planes;
        int     tempw, temph;

#if I8086
        gl_apid =
#endif
                appl_init();            /*  Start up application        */
        if (gl_apid == -1)              /*  Startup failed (bankrupt?)  */
                return (1);
        gem_handle = graf_handle(&tempw, &temph, &tempw, &temph);
        vdi_handle = gem_handle;
        v_opnvwk(work_in, &vdi_handle, work_out);

        if (vdi_handle == 0)            /*  Open virt. wkstn failed     */
                return (2);

        scrn_width    = work_out[0] + 1;
        scrn_height   = work_out[1] + 1;
        vqt_attributes(vdi_handle, work_out);   /*  Get dft text attrs  */
        textLine.pointSize = work_out[7];       /*  Default text height */
        textLine.pixelFlag = TRUE;

        vq_extnd(vdi_handle, 1, work_out);
        scrn_planes   = work_out[4];
        save_mfdb.fwp = scrn_width;
        save_mfdb.fww = scrn_width >> 4;
        save_mfdb.fh  = scrn_height;
        save_mfdb.np  = scrn_planes;
        save_mfdb.ff  = 0;

        save_size = (long) (save_mfdb.fwp >> 3) *
                (long) save_mfdb.fh * (long) save_mfdb.np;
        save_buf  = save_mfdb.mp = malloc(save_size);
        if (save_buf == 0L)
                return(3);

        scrn_area.g_x = 0;
        scrn_area.g_y = 0;
        scrn_area.g_w = scrn_width;
        scrn_area.g_h = scrn_height;
        scrn_mfdb.mp  = 0x0L;

        wind_update(BEG_UPDATE);        /*  Lock the screen for a bit   */
        graf_mouse(HOUR_GLASS, 0x0L);   /*  Display the busy bee        */
        if ( ! rsrc_load( "TXDEMO.RSC" ) )
        {
                graf_mouse(ARROW, 0x0L);
                form_alert(1, (long)
                    "[3][Fatal Error !|TXDEMO.RSC|File Not Found][ Abort ]");
                wind_update(END_UPDATE);
                return(4);
        }

#if I8086
        vst_load_fonts(vdi_handle, 0);          /*  Will crash 520ST    */
#endif

        /*
         *  Now we find out the full size of the desktop, and create a
         *      window to display our text.  The window will have a title
         *      and a close box (to allow the user a way to terminate
         *      this program).  For simplicity, we will not allow the
         *      window to be moved or resized.  However, note that all
         *      position calculations are made relative to the window
         *      offset, so that the code would still work if the window
         *      were moved.
         */
        wind_get(DESK, WF_WXYWH, &xfull, &yfull, &wfull, &hfull);
        /*  Find and display menu       */
        rsrc_gaddr(R_TREE, TEXTMENU, &gl_menu);
        menu_bar(gl_menu, TRUE);        

        /*  Create display window, using full desktop   */
        winHandle = wind_create(0, xfull, yfull, wfull, hfull);
        if (winHandle == -1) {          /*  Couldn't create window      */
                wind_update(END_UPDATE);
                return (5);
        }

        wind_open(winHandle, xfull, yfull, wfull, hfull);
        wind_get(winHandle, WF_WXYWH, &win_area.g_x, &win_area.g_y,
                &win_area.g_w, &win_area.g_h);
        textLine.vertPos   = win_area.g_h / 2;
        textLine.lineWidth = win_area.g_w - 16; /*  Fill most of window */

        LWCOPY(&save_area, &win_area, sizeof(GRECT) / 2);
        rast_op(0, &save_area, &scrn_mfdb, &save_area, &save_mfdb);
        graf_mouse(ARROW, 0x0L);
        wind_update(END_UPDATE);
        return (0);             /*  Completed initialization o.k.       */
}

mainLoop()              /*  Handle messages to display text and exit    */
{
        unsigned int    msgType, evType, temp, kstate, kreturn;
        int             msgPipe[8];

        for ( ; ; )             /*  Repeat until user closes window     */
        {
                evType = evnt_multi( MU_MESAG | MU_KEYBD,
                        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                        &msgPipe, 0, 0, &temp, &temp, &temp,
                        &kstate, &kreturn, &temp);

                wind_update(BEG_UPDATE);

                if (evType & MU_KEYBD) {        /*  Key pressed         */
                        hndlMenu(0, DISPLINE);
                        if (! (evType & MU_MESAG) ) {
                                wind_update(END_UPDATE);
                                continue;
                        }
                }


                msgType = msgPipe[0];           /*  Message type        */
                switch (msgType) {              /*  Handle incoming message  */

                        case MN_SELECTED:
                                if (hndlMenu(msgPipe[3], msgPipe[4])) {
                                        return; /*  "Quit" menu item    */
                                }
                                break;

                        case  WM_REDRAW :       /*  Redraw the window   */
                                restWork();
                                break;
                }
                wind_update(END_UPDATE);
        }
}

/*
 *  hndlMenu deals with a menu selection by the user.  It returns TRUE
 *      if the selection happens to be "Quit", otherwise FALSE.
 */
hndlMenu(title, item)
        int     title, item;
{
        long    tree, stringAddr();
        GRECT   box;
        int     exitobj;

        rsrc_gaddr(R_TREE, TEXTMENU, &tree);

        switch (item) {                 /*  Which menu item     */
                case  TEXTDEMO :        /*  Display TextDemo info       */
                        objc_xywh(gl_menu, TEXTDEMO, &box);
                        rsrc_gaddr(R_TREE, ABOUTDMO, &tree);
                        exitobj = hndlDial(tree, -1, box.g_x, box.g_y,
                                box.g_w, box.g_h);
                        deselObj(tree, exitobj);
                        break;

                case  TEXTQUIT :                /*  Quit program        */
                        menu_tnormal(gl_menu, title, TRUE);
                        return (TRUE);

                case  ERASEWIN :        /*  Erase text window   */
                        eraseWin();
                        break;

                case  DISPLINE :        /*  Set line attrs and display  */
                        lineDial();
                        break;

                case  DISPCHAR :        /*  Set char attributes         */
                        charDial();
                        break;
        }

        if (title)  menu_tnormal(gl_menu, title, TRUE);
        return (FALSE);
}

/*
 *  eraseWin -- Clears the text window.  This is done (as in doodle) by
 *      zeroing the save buffer, then doing a "restore window" from
 *      the save buffer.
 */
eraseWin()                      /*  Erase the text window       */
{
        rast_op(0, &win_area, &scrn_mfdb, &win_area, &save_mfdb);
        restWork();
}

lineDial()              /*  Bring up line attrs dialogue, then display line  */
{
        GRECT   box;
        long    tree;
        int     exitobj;

        objc_xywh(gl_menu, DISPLINE, &box);
        rsrc_gaddr(R_TREE, LINEATTR, &tree);

        initLnDial(tree, &textLine);
        exitobj = hndlDial(tree, TEXTLINE, box.g_x, box.g_y, box.g_w, box.g_h);
        deselObj(tree, exitobj);
        if (exitobj != LINEOK)
                return;                         /*  Cancelled dialogue  */
        saveLnDial(tree, &textLine);            /*  Get new line values */

        restWork();                             /*  Restore screen image  */
        wind_get(winHandle, WF_WXYWH, &win_area.g_x, &win_area.g_y,
                &win_area.g_w, &win_area.g_h);
        graf_mouse(M_OFF, 0x0L);
        drawLine(&textLine, &win_area);         /*  Draw new line       */
        graf_mouse(M_ON, 0x0L);
        saveWork();                             /*  Save screen image   */
}

charDial()                      /*  Bring up char attribute dialogue    */
{
        GRECT   box;
        long    tree;
        int     exitobj;

        objc_xywh(gl_menu, DISPCHAR, &box);
        rsrc_gaddr(R_TREE, CHARATTR, &tree);

        initChDial(tree, &textLine);
        exitobj = hndlDial(tree, POINTSIZ, box.g_x, box.g_y, box.g_w, box.g_h);
        deselObj(tree, exitobj);

        if (exitobj != CHAROK)
                return;                         /*  Cancelled dialogue  */
        saveChDial(tree, &textLine);            /*  Get new line values */
}

initLnDial(tree, lp)            /*  Initialize line attribute dialogue  */
        register  long  tree;
        register  struct textBlock  *lp;
{
        char    codeChar[2];

        setName(tree, TEXTLINE, lp->textString, 0);
        setNum(tree,  DISPXPOS, lp->horPos,     3);
        setNum(tree,  DISPYPOS, lp->vertPos,    3);
        setNum(tree,  LINWIDTH, lp->lineWidth,  3);
        setNum(tree,  LINELEAD, lp->lineHeight, 3);

        codeChar[1] = '\0';
        *codeChar   = justCodes[lp->justFlag];
        setName(tree, JUSTFLAG, codeChar, 1);
        *codeChar   = horizCodes[lp->horAlign];
        setName(tree, HORALIGN, codeChar, 1);
        *codeChar   = vertCodes[lp->vertAlign];
        setName(tree, VRTALIGN, codeChar, 1);
        setNum(tree,  ROTATION, lp->rotation,   4);
}

initChDial(tree, lp)            /*  Initialize char attribute dialogue  */
        register  long  tree;
        register  struct textBlock  *lp;
{
        char    codeChar[2];

        setNum(tree,  FONTID,   lp->fontId,     2);
        setNum(tree,  POINTSIZ, lp->pointSize,  2);
        codeChar[1] = '\0';
        *codeChar   = pixelCodes[lp->pixelFlag];
        setName(tree, PIXFLAG, codeChar, 1);

        setNum(tree,  EFFECTS,  lp->effects,    2);
        setNum(tree,  COLOR,    lp->color,      2);
        setNum(tree,  BACKCOLR, lp->backColor,  2);
}

saveLnDial(tree, lp)            /*  Set textBlock from line attrs dialogue  */
        register  long  tree;
        register  struct textBlock  *lp;
{
        char    codeChar[2];

        getName(tree, TEXTLINE, lp->textString, 0);
        lp->horPos     = getNum(tree, DISPXPOS, 3);
        lp->vertPos    = getNum(tree, DISPYPOS, 3);
        lp->lineWidth  = getNum(tree, LINWIDTH, 3);
        lp->lineHeight = getNum(tree, LINELEAD, 3);

        getName(tree, JUSTFLAG, codeChar, 1);
        lp->justFlag  = decode(*codeChar, justCodes,  NOJUST);
        getName(tree, HORALIGN, codeChar, 1);
        lp->horAlign  = decode(*codeChar, horizCodes, LEFT);
        getName(tree, VRTALIGN, codeChar, 1);
        lp->vertAlign = decode(*codeChar, vertCodes,  BASELINE);
        lp->rotation   = getNum(tree, ROTATION, 4);
}

saveChDial(tree, lp)            /*  Set textBlock from char attrs dialogue  */
        register  long  tree;
        register  struct textBlock  *lp;
{
        char    codeChar[2];

        lp->fontId    = getNum(tree, FONTID,   2);
        lp->pointSize = getNum(tree, POINTSIZ, 2);
        getName(tree, PIXFLAG, codeChar, 1);
        lp->pixelFlag = decode(*codeChar, pixelCodes, YES);

        lp->effects   = getNum(tree, EFFECTS,  2);
        lp->color     = getNum(tree, COLOR,    2);
        lp->backColor = getNum(tree, BACKCOLR, 2);
}

/*
 *  decode -- Compares a character against codes in a string, ignoring
 *      case of the character (code string must be all upper case).
 *      Returns position in string, or specified default if no match.
 */
decode(code, string, defValue)          /*  Decode a character value    */
        char    code;                   /*  Character to decode         */
        register  char  *string;        /*  Allowed codes in num. order */
        int     defValue;               /*  Default code if no match    */
{
        int     value;

        code &= 0x5f;                   /*  Convert lower case to upper */
        for (value = 0; *string; ++value) {
                if (code == *string++)
                        return (value);
        }
        return (defValue);              /*  Didn't match any letter     */
}

setName(tree, obj, name, len)   /*  Change value of text field in rsrc  */
        long    tree;           /*  Tree in which to look               */
        int     obj;            /*  Object to change within tree        */
        char    *name;          /*  Name to place in field              */
        int     len;            /*  Length of field (characters)        */
{
        char    *nameptr;
        int     actlen;

        nameptr = (char *) LLGET(TE_PTEXT(LLGET(OB_SPEC(obj))));
        actlen = LSTRLEN(name);
        LBCOPY(nameptr, name, actlen);
        for (nameptr += actlen; actlen < len; ++actlen)
                *nameptr++ = ' ';
        *nameptr = '\0';
}

getName(tree, obj, name, len)   /*  Get value of text field in rsrc     */
        long    tree;           /*  Tree in which to look               */
        int     obj;            /*  Object to change within tree        */
        char    *name;          /*  Place to put name from field        */
        int     len;            /*  Length of field (characters)        */
{
        char    *nameptr;
        int     actlen;

        nameptr = (char *) LLGET(TE_PTEXT(LLGET(OB_SPEC(obj))));
        actlen = LSTRLEN(nameptr);
        if (actlen)
                LBCOPY(name, nameptr, actlen);
        for (nameptr = &name[actlen]; actlen < len; ++actlen)
                *nameptr++ = ' ';
        *nameptr = '\0';
}

setNum(tree, obj, num, len)     /*  Change value of numeric rsrc field  */
        long    tree;           /*  Tree in which to look               */
        int     obj;            /*  Object to change within tree        */
        int     num;            /*  Number to place in field            */
        int     len;            /*  Length of field (digits)            */
{
        char    *numptr, *xprintf();
        int     actlen, j;

        numptr = xprintf("%d", num);
        actlen = LSTRLEN(numptr);
        if (actlen < len) {
            LBCOPY(&numptr[len - actlen], numptr, actlen + 1);
            for (j = len - actlen - 1; j >= 0; --j)
                    numptr[j] = ' ';
        }
        else  if (actlen > len)
                numptr += (actlen - len);       /*  Cut off left part of num */
        setName(tree, obj, numptr, len);
}

getNum(tree, obj, len)          /*  Get value of numeric rsrc field     */
        long    tree;           /*  Tree in which to look               */
        int     obj;            /*  Object to change within tree        */
        int     len;            /*  Length of field (digits)            */
{
        char    numptr[8], *digit;
        int     numlen, num, tens, haveNum;

        getName(tree, obj, numptr, len);
        num    = 0;
        tens   = 1;
        numlen = LSTRLEN(numptr);

        haveNum = FALSE;
        for (digit = &numptr[numlen - 1]; digit >= numptr; --digit) {
            *digit -= '0';
            if ((*digit >= 0) && (*digit <= 9)) {
                num    += (*digit * tens);
                haveNum = TRUE;
            }
            else  if (! haveNum)
                    continue;
            tens *= 10;
        }
        return (num);
}

hndlDial(tree, def, x, y, w, h)
        long    tree;
        int     def;
        int     x, y, w, h;
{
        int     xdial, ydial, wdial, hdial, exitobj;

        form_center(tree, &xdial, &ydial, &wdial, &hdial);
        form_dial(0, x, y, w, h, xdial, ydial, wdial, hdial);
        form_dial(1, x, y, w, h, xdial, ydial, wdial, hdial);
        objc_draw(tree, ROOT, MAX_DEPTH, xdial, ydial, wdial, hdial);

        exitobj = form_do(tree, def) & 0x7FFF;

        /*
         *  Close dialogue box, and cause redraw of that area to be sent.
         */
        form_dial(2, x, y, w, h, xdial, ydial, wdial, hdial);
        form_dial(3, x, y, w, h, xdial, ydial, wdial, hdial);
        return (exitobj);
}

drawLine(lp, clip)                      /*  Display a line, if in cliprect  */
        struct textBlock  *lp;          /*  Description of line             */
        GRECT             *clip;        /*  Clipping rectangle              */
{
        GRECT   textBox;
        int     baseLine, cellHt, center, horiz, vert, wordJust, charJust;
        int     clipCorners[4], baseBox[4], corners[4], perim[10];

        boxCorners(clip, clipCorners);
        vs_clip(vdi_handle, TRUE, clipCorners);
        horiz       = win_area.g_x + lp->horPos;
        vert        = win_area.g_y + lp->vertPos;
        baseLine    = textStyle(lp, &cellHt);
        center      = baseLine + ((lp->lineHeight - cellHt) / 2);

        textBox.g_x = horiz;
        textBox.g_y = vert - center;
        textBox.g_w = lp->lineWidth;
        textBox.g_h = lp->lineHeight;
        baseBox[0]  = textBox.g_x;      /*  Where baseline will end up  */
        baseBox[2]  = textBox.g_x + textBox.g_w - 1;
        baseBox[1]  = baseBox[3] = vert;

        if (lp->horAlign == RIGHT)      /*  Right-aligned text  */
                horiz += lp->lineWidth;
        else  if (lp->horAlign == CENTER)       /*   Centered   */
                horiz += lp->lineWidth / 2;

        /*
         *  If any significant rotation is in effect, the "line box" will
         *      obviously have to change position.  Fortunately, GEM only
         *      rotates at 90 degree angles, so a modest amount of kludgery
         *      should give us approximately the right orientation.
         */
        if (lp->rotation >= 450) {      /*  Rotating the text   */
                if ((lp->rotation < 1350) || (lp->rotation >= 2250)) {
                        if (lp->horAlign == RIGHT) {
                                horiz -= lp->lineWidth;
                                vert  += lp->lineWidth;
                        }
                        else  if (lp->horAlign == CENTER) {
                                horiz -= lp->lineWidth / 2;
                                vert  += lp->lineWidth / 2;
                        }

                        baseBox[0]  = baseBox[2] = horiz;
                        textBox.g_w = lp->lineHeight;
                        textBox.g_h = lp->lineWidth;

                        if (lp->rotation >= 2250) {     /*  Heading down  */
                                textBox.g_x -= (lp->lineHeight - center);
                                textBox.g_y  = baseBox[1];
                                baseBox[3]  += lp->lineHeight - 1;
                        }
                        else {                  /*  Heading up  */
                                if (lp->horAlign == RIGHT)
                                        vert  -= (lp->lineWidth * 2);
                                else  if (lp->horAlign == CENTER)
                                        vert  -= lp->lineWidth;

                                textBox.g_x -= center;
                                baseBox[3]  -= (lp->lineWidth - 1);
                                textBox.g_y  = baseBox[3];
                        }
                }
                else {                  /*  Heading to the left   */
                        if (lp->horAlign == RIGHT)
                                horiz -= (lp->lineWidth + lp->lineWidth);
                        else  if (lp->horAlign == CENTER)
                                horiz -= lp->lineWidth;
                        textBox.g_x -= textBox.g_w;
                        textBox.g_y += (center + center - lp->lineHeight);
                        --baseBox[0];           /*  Reverse baseline    */
                        baseBox[2]   = textBox.g_x;
                }
        }

        /*
         *  Now prepare to display the background color.
         */
        intersect(clip, &textBox);              /*  Don't go off edge   */
        boxCorners(&textBox, corners);
        perim[0] = perim[6] = perim[8] = corners[0];
        perim[1] = perim[3] = perim[9] = corners[1];
        perim[2] = perim[4] = corners[2];
        perim[5] = perim[7] = corners[3];

        vsf_perimeter(vdi_handle, 0);           /*  No perimeter        */
        vsf_color(vdi_handle, lp->backColor);   /*  Clean up area       */
        vsf_interior(vdi_handle, 1);            /*  Interior is solid   */
        vswr_mode(vdi_handle, REPLACE);
        v_bar(vdi_handle, corners);             /*  Turn on background  */

        vswr_mode(vdi_handle, TRANSPARENT);
        if (lp->justFlag) {     /*  Actually time to display the text!  */
                wordJust = lp->justFlag & WORDJUST;
                charJust = lp->justFlag & CHARJUST;
                v_justified(vdi_handle, horiz, vert, lp->textString,
                        lp->lineWidth, wordJust, charJust);
        }
        else    v_gtext(vdi_handle, horiz, vert, lp->textString);

        /*
         *  Just for visual comparison, we draw a border around the
         *      theoretical line box, and also draw the baseline.  These
         *      will be incorrect if rotation is in effect (since the
         *      application can't, as far as I know, tell what rotation
         *      angle will actually be used).
         */
        vsl_width(vdi_handle, 2);               /*  One pixel thick     */
        vsl_ends( vdi_handle, 0, 0 );

        vsl_type( vdi_handle, 3);               /*  Dotted line         */
        vsl_color(vdi_handle, GREEN);           /*  Baseline is green   */
        if ((vert >= clip->g_y) && (vert < clip->g_y + clip->g_h))
                v_pline(vdi_handle, 2, baseBox);        /*  Draw baseline  */

        vsl_type( vdi_handle, 1);               /*  Solid border lines  */
        vsl_color(vdi_handle, RED);             /*  Border is red       */
        v_pline(vdi_handle, 5, perim);          /*  Solid box around text  */

        vs_clip(vdi_handle, FALSE, clipCorners);
        vswr_mode(vdi_handle, REPLACE);         /*  The normal default     */
}

textStyle(lp, cellHt)                   /*  Set attributes into GEM     */
        register struct textBlock  *lp;         /*  Line descriptor     */
        int     *cellHt;                /*  We return cell height here  */
{
        int     temp, baseLine;

        vst_rotation  (vdi_handle, lp->rotation);
        vst_alignment (vdi_handle, lp->horAlign, lp->vertAlign, &temp, &temp);
        vst_font      (vdi_handle, lp->fontId);
        vst_effects   (vdi_handle, lp->effects);
        vst_color     (vdi_handle, lp->color);
        vsf_color     (vdi_handle, lp->backColor);

        if (lp->pixelFlag) {            /*  Character size is in pixels */
                /*
                 *  Important:  Note that the character height (lp->pointSize)
                 *      is the number of pixels in the character above the
                 *      baseline, *not* the cell height of the character.
                 *      You may want to do a vqt_attributes call just after
                 *      opening the virtual workstation, in order to find
                 *      out the correct height value for the default system
                 *      font -- the value will not be at all obvious (it
                 *      turns out to be 13 in high-res mode, and 6 pixels
                 *      in either medium or low-resolution).
                 */
                vst_height(vdi_handle, lp->pointSize, &temp, &baseLine,
                        &temp, cellHt);
        }
        else  vst_point (vdi_handle, lp->pointSize, &temp, &baseLine,
                        &temp, cellHt);         /*  Char size in Points */
        return (baseLine);
}

intersect(srcbox, destbox)              /*  Find intersection of two boxes  */
        GRECT   *srcbox, *destbox;      /*  WARNING:  Changes *destbox  */
{
        int     left, top, right, bot;
        int     srcRight, srcBot, destRight, destBot;

        srcRight  = srcbox->g_x  + srcbox->g_w;
        srcBot    = srcbox->g_y  + srcbox->g_h;
        destRight = destbox->g_x + destbox->g_w;
        destBot   = destbox->g_y + destbox->g_h;

        left  = MAX(srcbox->g_x, destbox->g_x);
        top   = MAX(srcbox->g_y, destbox->g_y);
        right = MIN(srcRight, destRight);
        bot   = MIN(srcBot,   destBot);

        destbox->g_x = left;            /*  Set dest to intersection    */
        destbox->g_y = top;
        destbox->g_w = right - left;
        destbox->g_h = bot   - top;

        return ((right > left) && (bot > top));
}

boxCorners(grect, array)                /*  Convert GRECT to int array  */
        GRECT   *grect;
        int     *array;
{
        array[0] = grect->g_x;
        array[1] = grect->g_y;
        array[2] = grect->g_x + grect->g_w - 1;
        array[3] = grect->g_y + grect->g_h - 1;
}

byteAlign(x)            /*  Finds nearest eight-pixel boundary to "x"   */
        int     x;
{
        return((x & 0xfff8) + ((x & 0x0004) ? 0x0008 : 0));
}

long
stringAddr(which)               /* returns a tedinfo string addr        */
        int     which;
{
        long    where;

        rsrc_gaddr(R_STRING, which, &where);
        return (where);
} 

saveWork()                      /*  Copy work_area to save buffer       */
{
        GRECT   tmp_area;

        LWCOPY(&tmp_area, &win_area, sizeof(GRECT) / 2);
        graf_mouse(M_OFF, 0x0L);
        rast_op(3, &tmp_area, &scrn_mfdb, &tmp_area, &save_mfdb);
        graf_mouse(M_ON, 0x0L);
}

restWork()                      /*  restore work_area from save buffer  */
{
        GRECT   tmp_area;

        LWCOPY(&tmp_area, &win_area, sizeof(GRECT) / 2);
        graf_mouse(M_OFF, 0x0L);
        rast_op(3, &tmp_area, &save_mfdb, &tmp_area, &scrn_mfdb);
        graf_mouse(M_ON, 0x0L);
}

rast_op(mode, s_area, s_mfdb, d_area, d_mfdb)   /* bit block level trns */
        int     mode;
        GRECT   *s_area, *d_area;
        MFDB    *s_mfdb, *d_mfdb;
{
        int     pxy[8];

        grect_to_array(s_area, pxy);
        grect_to_array(d_area, &pxy[4]);
        vro_cpyfm(vdi_handle, mode, pxy, s_mfdb, d_mfdb);
}

grect_to_array(area, array)     /* convert x,y,w,h to upr lt x,y and    */
        GRECT   *area;                  /*            lwr rt x,y        */
        int     *array;
{
        *array++ = area->g_x;
        *array++ = area->g_y;
        *array++ = area->g_x + area->g_w - 1;
        *array   = area->g_y + area->g_h - 1;
}

objc_xywh(tree, obj, p)         /* get x,y,w,h for specified object     */
        long    tree;
        int     obj;
        GRECT   *p;
{
        objc_offset(tree, obj, &p->g_x, &p->g_y);
        p->g_w = LWGET(OB_WIDTH(obj));
        p->g_h = LWGET(OB_HEIGHT(obj));
}

deselObj(tree, which)           /* turn off selected bit of spcfd object*/
        long    tree;
        int     which;
{
        int     state;

        state = LWGET(OB_STATE(which));
        LWSET(OB_STATE(which), state & ~SELECTED);
}

