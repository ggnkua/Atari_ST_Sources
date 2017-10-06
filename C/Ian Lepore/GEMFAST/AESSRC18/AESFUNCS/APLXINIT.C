/**************************************************************************
 * APLXINIT.C - aplx_init(), apl_xexit() functions; new global data items.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

#undef appl_init  /* undo the remapping macros that gemfast.h sets up to */
#undef appl_exit  /* get applications into here; we need The Real Thing. */

void    (*_AesVCleanup)() = NULL; /* Internal var shared with APLVWORK.C */

/*-------------------------------------------------------------------------
 * new global data items (for use in gemfast utils and by application)...
 *-----------------------------------------------------------------------*/

int     gl_grfhandle=0; /* global physical VDI handle                    */
int     gl_wchar=0;     /* width of a character                          */
int     gl_hchar=0;     /* height of a character                         */
int     gl_wbox=0;      /* width of a boxchar                            */
int     gl_hbox=0;      /* height of a boxchar                           */
GRECT   gl_rwdesk={0};  /* coordinates of work area of the desktop       */
GRECT   gl_rfscrn={0};  /* coordinates of the full screen                */

/*-------------------------------------------------------------------------
 * apl_cleanup() - Clean up transient resources we've aquired.
 *
 *   For now, that means close the shared VDI workstation.  We do this
 *   by calling through the vdi cleanup vector if it is non-NULL.  if 
 *   the shared workstation was ever opened, the vector is set by the
 *   apl_vopen() routine to point to the closer routine.  Since the 
 *   actual vector variable lives in this module, and starts out as NULL,
 *   we avoid making a direct call to the vdi cleanup, and thus we avoid
 *   linking all the vdi groodah into a program that doesn't need it.
 *
 *   Right now, we don't use the options value.  Someday we are going to 
 *   have transient and permenant resources, and the flag will indicate
 *   whether the permenant resources are also to be cleaned up.
 *-----------------------------------------------------------------------*/

void apl_cleanup(options)
    int options;
{
    if (_AesVCleanup != NULL) {
        (*_AesVCleanup)();
    }
}

/*-------------------------------------------------------------------------
 * _ApXinit() - internal routine to init new global data items.
 *
 *   this is called from apl_xinit(), below, and also from apl_vopen().
 *   the latter is a just-in-case call, on the off chance that the caller
 *   never came through the extended init in the first place.
 *-----------------------------------------------------------------------*/

void _ApXinit()
{
    gl_grfhandle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
    winx_get(0, WF_WORKXYWH, &gl_rwdesk);
    
    /* gl_rfscrn x and y are already zero */
    gl_rfscrn.g_w = gl_rwdesk.g_x + gl_rwdesk.g_w;
    gl_rfscrn.g_h = gl_rwdesk.g_y + gl_rwdesk.g_h;
}

/*-------------------------------------------------------------------------
 * apl_xinit() - Extended init.  Does appl_init() plus fills in new global
 *               data items.  A GEMFAST.H macro makes this routine get
 *               invoked when the application calls appl_init().
 *-----------------------------------------------------------------------*/

int apl_xinit()
{
    if (0 <= appl_init()) {
        _ApXinit();
    }
    return gl_apid;
}

/*-------------------------------------------------------------------------
 * apl_xexit() - extended exit. call the cleanup routine, then appl_exit().
 *-----------------------------------------------------------------------*/

void apl_xexit()
{
    apl_cleanup(APL_RTRANSIENT|APL_RPERMENANT);
    appl_exit();
}
