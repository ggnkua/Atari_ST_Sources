/*************************************************************************
 * FRMDSMEN.C - The frm_dsmenu() routine.
 *************************************************************************/

#include "gemfast.h"
#include "frmtypes.h"

#ifndef NULL
  #define NULL 0L
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

static TEDINFO title_tedinfo = {
  NULL, NULL, NULL, 3, 6, 2, 0x11F0, 0, -1,   1,   1
};

static OBJECT menutree[] = {
 { -1,  1,  2, G_BOX,      NONE,       NORMAL,   (long)(0x00FF1100L),       0x0000, 0x0000, 0x0001, 0x0016},
 {  2, -1, -1, G_BOXTEXT,  NONE,       NORMAL,   (long)(&title_tedinfo),    0x0000, 0x0000, 0x0001, 0x0101},
 {  0,  3, 22, G_IBOX,     NONE,       NORMAL,   (long)(0x00001100L),       0x0001, 0x0002, 0x0001, 0x0014},
 {  4, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0000, 0x0001, 0x0001},
 {  5, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0001, 0x0001, 0x0001},
 {  6, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0002, 0x0001, 0x0001},
 {  7, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0003, 0x0001, 0x0001},
 {  8, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0004, 0x0001, 0x0001},
 {  9, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0005, 0x0001, 0x0001},
 { 10, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0006, 0x0001, 0x0001},
 { 11, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0007, 0x0001, 0x0001},
 { 12, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0008, 0x0001, 0x0001},
 { 13, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0009, 0x0001, 0x0001},
 { 14, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000A, 0x0001, 0x0001},
 { 15, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000B, 0x0001, 0x0001},
 { 16, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000C, 0x0001, 0x0001},
 { 17, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000D, 0x0001, 0x0001},
 { 18, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000E, 0x0001, 0x0001},
 { 19, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x000F, 0x0001, 0x0001},
 { 20, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0010, 0x0001, 0x0001},
 { 21, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0011, 0x0001, 0x0001},
 { 22, -1, -1, G_BOXTEXT,  SELECTABLE, NORMAL,   (long)(0L),                0x0000, 0x0012, 0x0001, 0x0001},
 {  2, -1, -1, G_BOXTEXT,  0x0021,     NORMAL,   (long)(0L),                0x0000, 0x0013, 0x0001, 0x0001}
};

#define TITLE_BOX           1
#define TEXT_BOX            2
#define FIRST_TEXT_LINE     3
#define LAST_TEXT_LINE     22

int frm_dsmenu(options, title, strings)
    long options;
    char *title;
    char **strings;
{
    int             maxwidth;
    int             numlines;
    int             selection;
    int             hhalf    = gl_hchar / 2;
    register OBJECT *ptree   = menutree;
    static int      initdone = FALSE;

    if (!(options & FRM_NODEFAULTS)) {
        options |= (_FrmDefaults & FRM_DOPTIONBITS) | FRM_DEFAULT_DYNOPT;
    }
    options |= FRM_MANDATORY_DYNOPT;

    if (!initdone) {
        initdone = TRUE;
        rsc_treefix(ptree);
    }

    if (title != NULL) {
        ptree->ob_flags           = NORMAL;
        ptree[TITLE_BOX].ob_flags = FRM_MOVER|TOUCHEXIT;
        ptree[TEXT_BOX].ob_y      = ptree[TITLE_BOX].ob_height + hhalf;
        title_tedinfo.te_ptext    = title;
        maxwidth                  = strlen(title);
    } else {
        ptree->ob_flags           = FRM_MOVER|TOUCHEXIT;
        ptree[TITLE_BOX].ob_flags = HIDETREE;
        ptree[TEXT_BOX].ob_y      = hhalf;
        maxwidth                  = 1;
    }

    ptree->ob_state = (options & FRM_DSHADOWED) ? SHADOWED : NORMAL;

    numlines = _FrmDS2Obj(strings, &ptree[FIRST_TEXT_LINE], NULL, 
                            &maxwidth, FRM_DSMAXSTRINGS);

    _FrmTrWidths(ptree, ROOT,     (maxwidth+2)*gl_wchar);
    _FrmTrWidths(ptree, TEXT_BOX, maxwidth*gl_wchar);

    ptree[TEXT_BOX].ob_height = numlines * gl_hchar;
    ptree->ob_height = ptree[TEXT_BOX].ob_height + ptree[TEXT_BOX].ob_y + hhalf;

    selection = frm_menu(options, ptree, SELECTED);

    if (selection > NO_OBJECT) {
        ptree[selection].ob_state &= ~SELECTED;
        selection -= FIRST_TEXT_LINE-1; // adjust to 1-based index.
        if (selection == numlines) {    // last selection is returned as
            selection = 0;              // zero; it s/b Cancel, Exit, etc.
        }
    }

    return selection;
}

