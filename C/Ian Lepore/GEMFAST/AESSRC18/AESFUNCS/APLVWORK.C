/**************************************************************************
 * APLVWORK.C - apl_vopen() and apl_vclose() functions.
 *************************************************************************/

#include <osbind.h>
#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

extern void     (*_AesVCleanup)();                      /* in APLXINIT.C */
extern void     _ApXinit();                             /* in APLXINIT.C */

static int      work_in[11] = {
    -1,                 /* device driver (filled in at runtime) */
    1,                  /* polyline type    (normal)            */
    1,                  /* polyline color   (black)             */
    1,                  /* polymarker type  (dot)               */
    1,                  /* polymarker color (black)             */
    1,                  /* text face        (standard)          */
    1,                  /* text color       (black)             */
    1,                  /* fill interior    (solid)             */
    8,                  /* fill style       (solid)             */
    1,                  /* fill color       (black)             */
    2                   /* use RC coordinate system             */
}; 

static int      shared_handle = 0;    /* shared workstation handle       */

int gl_vwout[57];                     /* global work_out from v_opnvwk() */
int gl_vxout[57];                     /* global work_out from vq_extnd() */

/*-------------------------------------------------------------------------
 * apl_vclose - Close VDI virtual workstation.
 *   if it's the shared workstation, don't really close it.
 *-----------------------------------------------------------------------*/

void apl_vclose(vdi_handle)
    register int vdi_handle;
{
    if (vdi_handle == shared_handle) {
        return;
    } else if (vdi_handle != 0) {
        v_clsvwk(vdi_handle);
    }
}

/*-------------------------------------------------------------------------
 * cleanup_shared_workstation() - Really close the shared workstation.
 *  this is called from apl_cleanup() via the _AesVCleanup vector.
 *-----------------------------------------------------------------------*/

static void cleanup_shared_workstation()
{
    if (shared_handle != 0) {
        v_clsvwk(shared_handle);
        shared_handle = 0;
    }
}

/*-------------------------------------------------------------------------
 * apl_vopen() - Routine to open a virtual workstation.
 *-----------------------------------------------------------------------*/

int apl_vopen()
{
    int vdi_handle;

    if (gl_grfhandle == 0) {
        _ApXinit();
    }

    if (work_in[0] == -1) {
        work_in[0] = 2 + Getrez();  /* GDOS voodoo */
    }
    
    vdi_handle = gl_grfhandle;
    v_opnvwk(work_in, &vdi_handle, gl_vwout);
    
    if (gl_vxout[4] == 0 && vdi_handle != 0) {
        vq_extnd(vdi_handle, 1, gl_vxout);
    }
    
    return vdi_handle;
}

/*-------------------------------------------------------------------------
 * apl_vshared() - Return the handle to the shared workstation; open the
 *                 shared workstation if necessary;
 *-----------------------------------------------------------------------*/

int apl_vshared()
{
    if (shared_handle == 0) {
        _AesVCleanup  = cleanup_shared_workstation;
        shared_handle = apl_vopen();
    }
    return shared_handle;
}

