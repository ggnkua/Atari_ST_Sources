/*****************************************************************************
 * EXTERROR.C - Extended error message handling.
 ****************************************************************************/

#include "exterror.h"

#ifndef NULL
  #define NULL 0L
#endif

#define MAX_EXT_TABLES  8

static _Err_tab *extmsg_tables[MAX_EXT_TABLES] = {NULL};
static char     nullstr[] = "";

/*----------------------------------------------------------------------------
 * exterrset - Install or remove an application-specific error msg table.
 *--------------------------------------------------------------------------*/

int exterrset(ptab, install)
    _Err_tab    *ptab;
    int         install;
{
    register int      tabidx;
    register _Err_tab **pptab = extmsg_tables;

    for (tabidx = 0; tabidx < MAX_EXT_TABLES; ++tabidx, ++pptab) {
        if (install) {
            if (*pptab == NULL) {
                *pptab = ptab;
                return E_OK;
            }
        } else {
            if (*pptab == ptab) {
                *pptab = NULL;
                return E_OK;
            }
        }
    }

    return ERROR;
}

/*----------------------------------------------------------------------------
 * exterror - like strerror(), but looks for application-specific msg first.
 *--------------------------------------------------------------------------*/

char *exterror(err)
    register int err;
{
    register int      tabidx;
    register _Err_tab *ptab;
    register char     *themsg;
    extern   char     *strerror();

    for (tabidx = 0; tabidx < MAX_EXT_TABLES; ++tabidx) {
        for (ptab = extmsg_tables[tabidx]; ptab && ptab->code; ++ptab) {
            if (ptab->code == err) {
                themsg = ptab->msg;
                goto RETURN_IT;
            }
        }
    }

    if (err == 0) {
        themsg = nullstr;
    } else {
        themsg = strerror(err);
    }
    
RETURN_IT:

    if (themsg == NULL) {
        themsg = nullstr;
    }
    
    return themsg;
}
