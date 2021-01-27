/**************************************************************************
 * MNUTBAR.C - The mnu_tbar() and mnu_erase() functions.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0
#endif

#ifndef TRUE
  #define TRUE  1
  #define FALSE 0
#endif

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

static char nullstr[] = " ";

static TEDINFO mtted = {
    nullstr, NULL, NULL, 3, 0, 2, 0x1180, 0, 0, 0, 0
};

static OBJECT mtbartree[] = {
 { -1, -1, -1, G_BOXTEXT,  LASTOB, NORMAL, (long)&mtted, 0, 0, 0, 0},
};

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void mnu_tbar(titlestr)
    char *titlestr;
{
    if (mtbartree[0].ob_width == 0) {
        mtbartree[0].ob_width  = gl_rwdesk.g_w;
        mtbartree[0].ob_height = gl_hchar + 2;
    }

    if (titlestr == NULL) {
        titlestr = nullstr;
    }
    mtted.te_ptext = titlestr;
    
    menu_bar(NULL, FALSE); // if any menu now on, turn it off first
    objc_draw(mtbartree, ROOT, MAX_DEPTH, gl_rfscrn);
}

/*-------------------------------------------------------------------------
 *
 *-----------------------------------------------------------------------*/

void mnu_erase()
{
    mnu_tbar(nullstr);
}

