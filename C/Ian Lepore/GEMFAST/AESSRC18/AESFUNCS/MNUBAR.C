/**************************************************************************
 * MNUBAR.C - The mnu_bar(), mnu_enable(), and mnu_disable() functions. 
 *************************************************************************/

#include "gemfast.h"
#undef menu_bar

#ifndef NULL
  #define NULL 0L
#endif

static void *lastmenu;
static int  hidecount;

int mnu_bar(menutree, flag, reserved)
    void *menutree;
    int  flag;
    long reserved;
{
    lastmenu  = (flag) ? menutree : NULL;
    hidecount = 0;
    return menu_bar(menutree, flag);
}

void mnu_disable()
{
    if (lastmenu != NULL) {
        if (++hidecount == 1) {
            menu_bar(lastmenu, 0);
        }
    }
}

void mnu_enable()
{
    if (lastmenu != NULL) {
        if (--hidecount <= 0) {
            hidecount = 0;
            menu_bar(lastmenu, 1);
        }
    }
}

