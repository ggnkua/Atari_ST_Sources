/**************************************************************************
 * GRFBLIT.C - grf_memblit() function.
 *************************************************************************/

#include "gemfast.h"

#ifndef NULL
  #define NULL 0L
#endif

static long dmyfdb; /* dummy "fdb" (0L) describes the physical screen */

/**************************************************************************
 * grf_blit - blit a rectangle between screen and buffer.
 *************************************************************************/

long grf_blit(options, buffer, prect)
    int              options;
    void            *buffer;
    void            *prect;
{
    GRECT           scrnrect;     /* rectangle on the screen               */
    GRECT           memrect;      /* rectangle in memory (x/y always zero) */
    FDB             memfdb;       /* FDB describing memory buffer          */
    register long   wdwidth;      /* width of memory buffer in words       */
    register long   mem_needed;   /* memory needed to do the blit          */
    register FDB    *srcefdb;     /* source FDB pointer                    */
    register FDB    *destfdb;     /* destination FDB pointer               */
    register int    vdi_handle;   /* Handle for temp VDI workstation       */
    struct  {                     /* This is the 'pxy array' used in the   */
            VRECT   srce;         /* VDI blit command; actually two VRECT- */
            VRECT   dest;         /* type rectangles stuck back-to-back    */
            } blitcoords;         /* so it looks like an array.            */

/*----------------------------------------------------------------------*
 * validate parms, open a vdi workstation...
 *----------------------------------------------------------------------*/

    mem_needed = 0;             /* assume failure */
    
    wind_update(BEG_UPDATE);

    if (!(options & (GRF_BFROMSCREEN|GRF_BTOSCREEN|GRF_BMEMCALC))) {
        goto BYPASS_BLIT;
    }

    if (prect == NULL || (buffer == NULL && !(options & GRF_BMEMCALC))) {
        goto BYPASS_BLIT;
    }

    if (0 == (vdi_handle = apl_vshared())) {
        goto BYPASS_BLIT;
    }

/*----------------------------------------------------------------------*
 * get the screen rectangle, clip it to the physical screen...
 *----------------------------------------------------------------------*/

    if (options & GRF_BOBJTREE) {
        frm_sizes((OBJECT *)prect, &scrnrect);
    } else{
        rc_copy(prect, &scrnrect);
    }
    
    if (!rc_intersect(&gl_rfscrn, &scrnrect)) {
        goto BYPASS_BLIT;
    }

/*----------------------------------------------------------------------*
 * set up the buffer rectangle...
 *----------------------------------------------------------------------*/

    memrect.g_x = 0;
    memrect.g_y = 0;
    memrect.g_w = scrnrect.g_w;
    memrect.g_h = scrnrect.g_h;
    
/*----------------------------------------------------------------------*
 * set up the fdb describing the buffer.
 *----------------------------------------------------------------------*/

    wdwidth = (scrnrect.g_w + 15) / 16;

    memfdb.fd_nplanes = gl_vxout[4];  
    memfdb.fd_stand   = 0;
    memfdb.fd_w       = scrnrect.g_w;
    memfdb.fd_h       = scrnrect.g_h;
    memfdb.fd_wdwidth = wdwidth;
    memfdb.fd_addr    = buffer;
    
    mem_needed = (2 * (wdwidth * (scrnrect.g_h * memfdb.fd_nplanes)));
    
    if ((options & GRF_BMEMCALC) || mem_needed == 0) {
        goto BYPASS_BLIT;
    }
    
/*----------------------------------------------------------------------*
 * do the blit.
 *----------------------------------------------------------------------*/

    if (options & GRF_BFROMSCREEN) {
        rc_gtov(&scrnrect, &blitcoords.srce);
        rc_gtov(&memrect,  &blitcoords.dest);
        srcefdb = (FDB *)&dmyfdb;
        destfdb = &memfdb;
    } else {
        rc_gtov(&memrect,  &blitcoords.srce);
        rc_gtov(&scrnrect, &blitcoords.dest);
        srcefdb = &memfdb;
        destfdb = (FDB *)&dmyfdb;
    }

    graf_mouse(M_OFF, 0L);
    vro_cpyfm(vdi_handle, S_ONLY, &blitcoords, srcefdb, destfdb);
    graf_mouse(M_ON, 0L);

/*----------------------------------------------------------------------*
 * all done, return.
 *----------------------------------------------------------------------*/

BYPASS_BLIT:
   
    wind_update(END_UPDATE);
    return mem_needed;
}


