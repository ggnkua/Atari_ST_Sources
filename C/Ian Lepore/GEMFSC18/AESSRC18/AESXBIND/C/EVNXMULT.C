/**************************************************************************
 * EVNXMULT.C -  Extended event_multi() routine...
 *************************************************************************/

#include "gemfast.h"

int evnx_multi(xm)
    register XMULTI *xm;
{
    return xm->mwhich = evnt_multi(xm->mflags,
                         xm->mbclicks,
                         xm->mbmask,
                         xm->mbstate,
                         xm->mm1flags,
                         xm->mm1rect,
                         xm->mm2flags,
                         xm->mm2rect,
                         xm->msgbuf,
                         xm->mtlocount,
                         xm->mthicount,
                         &xm->mmox,
                         &xm->mmoy,
                         &xm->mmobutton,
                         &xm->mmokstate,
                         &xm->mkreturn,
                         &xm->mbreturn);
}

