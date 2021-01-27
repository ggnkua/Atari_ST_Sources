/****************************************************************
 * various variations on appl handlinf                          *
 ****************************************************************/

/**************************************************************************
 * APLXINIT.C - aplx_init(), apl_xexit() functions; new global data items.
 *************************************************************************/

#include <stdlib.h>
#include <tos.h>
#include "gemf.h"

#ifndef NULL
  #define NULL 0L
#endif

#undef appl_init  /* undo the remapping macros that gemfast.h sets up to */
#undef appl_exit  /* get applications into here; we need The Real Thing. */

void    (*_AesVCleanup)(void) = NULL; /* Internal var shared with APLVWORK.C */

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

void apl_cleanup(int options)
{
	if (_AesVCleanup != NULL)
	    (*_AesVCleanup)();
}

/*-------------------------------------------------------------------------
 * _ApXinit() - internal routine to init new global data items.
 *
 *   this is called from apl_xinit(), below, and also from apl_vopen().
 *   the latter is a just-in-case call, on the off chance that the caller
 *   never came through the extended init in the first place.
 *-----------------------------------------------------------------------*/

void _ApXinit(void)
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

int apl_xinit(void)
{
	if (0 <= appl_init())
	    _ApXinit();
	return gl_apid;
}

/*-------------------------------------------------------------------------
 * apl_xexit() - extended exit. call the cleanup routine, then appl_exit().
 *-----------------------------------------------------------------------*/

void apl_xexit(void)
{
	apl_cleanup(APL_RTRANSIENT|APL_RPERMENANT);
	appl_exit();
}

/**************************************************************************
 * APLVWORK.C - apl_vopen() and apl_vclose() functions.
 *************************************************************************/

#include <tos.h>

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

void apl_vclose(int vdi_handle)
{
	if (vdi_handle == shared_handle)
	    return;
	else if (vdi_handle != 0)
	    v_clsvwk(vdi_handle);
}

/*-------------------------------------------------------------------------
 * cleanup_shared_workstation() - Really close the shared workstation.
 *  this is called from apl_cleanup() via the _AesVCleanup vector.
 *-----------------------------------------------------------------------*/

static void cleanup_shared_workstation(void)
{
	if (shared_handle != 0)
	{
	    v_clsvwk(shared_handle);
	    shared_handle = 0;
	}
}

int apl_vopen(void)
{
	int vdi_handle;

	if (gl_grfhandle == 0)
		_ApXinit();

	if (work_in[0] == -1)
		work_in[0] = 2 + Getrez();  /* GDOS voodoo */

	vdi_handle = gl_grfhandle;
	v_opnvwk(work_in, &vdi_handle, gl_vwout);

	if (gl_vxout[4] == 0 && vdi_handle != 0)
		vq_extnd(vdi_handle, 1, gl_vxout);

    return vdi_handle;
}

int apl_vshared(void)
{
	if (shared_handle == 0)
	{
		_AesVCleanup  = cleanup_shared_workstation;
		shared_handle = apl_vopen();
	}
	return shared_handle;
}

/**************************************************************************
 * APLMALLO.C - Internal service routines apl_malloc(), apl_free().
 *
 *  These are the default allocate/free routines, used by gemfast
 *  utilities that need memory for something.  They just call through
 *  to GEMDOS.  You can change the calls below to your library malloc()
 *  and free() instead of Malloc/Mfree if you want.  Or, you can do it
 *  on a per-application basis by coding apl_malloc() and apl_free() in
 *  your application so that they'll get used and the library default
 *  routines below will be ignored by the linker.
 *************************************************************************/

static void *default_allocator(size_t size)
{
	return (void *)Malloc(size);
}

static void default_releaser(void *block)
{
	Mfree(block);
}

static VPFUNC *allocator = default_allocator;
static VFUNC  *releaser  = default_releaser;

void *apl_malloc(size_t size)
{
	return (*allocator)(size);
}

void apl_free(void *block)
{
	if (block)
		(*releaser)(block);
}

void apl_mmvectors(VPFUNC *newalloc, VFUNC  *newrelease)
{
	if (newalloc && newrelease)
	{
		allocator = newalloc;
		releaser  = newrelease;
	}
}

void *lalloc(size_t size)
{
	return malloc(size);
}
