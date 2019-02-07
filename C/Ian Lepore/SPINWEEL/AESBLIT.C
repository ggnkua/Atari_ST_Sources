
/* written by Ian Lepore
** Copyright 1990 by Antic Publishing, Inc.
*/

/* Tab expansion/compression spacing should be set to '4' in your editor. */

/**************************************************************************
 *
 * aes_blit - Do a screen save/restore blit using the AES's alert buffer.
 *
 * Abstract:  This routine allows you to blit small areas of the screen
 *			  (up to 1/4 of the screen, 8000 bytes of storage) with one 
 *			  function call, requiring virtually no setup by the caller.
 *
 *			  There is no init hook to call, or other pre-usage setup
 *			  that the caller must perform before calling aes_blit.
 *
 *			  Since the AES's buffer is used, the caller must be aware
 *			  that certain AES functions may wipe out the contents of 
 *			  the buffer.  Any drop-down-menu processing or form_alert
 *			  calls will certainly do so, but there is no guarantee that
 *			  other AES functions will not touch the buffer.  A good way
 *			  to help insure that nothing else touches the buffer is to
 *			  do a couple wind_update() calls to set the BEG_UPDATE and
 *			  BEG_MCTRL flags.	The UPDATE flag will keep well-behaved
 *			  multitasking aps (such as accessories) from doing anything
 *			  that might require the buffer, and the MCTRL flag will keep
 *			  the AES from doing any drop-down menu processing.  Keep these
 *			  two flags in effect for the duration that you want the buffer
 *			  to be undisturbed.
 *
 * Author:	  Ian Lepore
 * 
 * Usage:	  int status = aes_blit(int dirflag, GRECT *blitrect);
 *
 *			  The caller passes a flag indicating the direction of the 
 *			  blit, and a pointer to a GRECT (x/y/w/h) which describes the
 *			  area to be blitted.  The direction flag is mnemonically 
 *			  defined in AESBLIT.H.
 *			  
 *			  This function returns 0 on success, negative indicates error.
 *|
 *| 08/08/89  Error codes are now differentiated, as follows:
 *| 			-2	=  No VDI handle available.
 *| 		   -39	=  AES buffer too small (eg, Insufficient Memory).
 *|
 *| 		  (Note to self:  This routine should NEVER be coded to return
 *| 		  a -1 error status, as it will confuse many of the higher-level
 *| 		  library routines; they may see the -1 as a NO_OBJECT status.)
 *|
 * Notes:	  This routine opens a local VDI virtual workstation, and keeps
 *			  it open only long enough to do the blit (ie, the workstation
 *			  is closed before returning to the caller).  Unless the 
 *			  application is incredibly time-critical, the ease-of-use this
 *			  imparts to the function easily justifies the extra overhead.
 *			  
 *			  It is remotely possible that there will be no VDI handles
 *			  available at the time this routine is called; the routine 
 *			  will return -2 rather than crashing if this happens.
 *
 *			  This source code contains only one global definition, the
 *			  name of the function; all other names are local/static.
 *
 * Environment:
 *
 *			  Developed with Sozobon C v1.1 PD compiler.
 *			  AESFAST v1.2 PD GEM bindings and utilities.  
 *			  Should be compatible with Alcyon, Sozobon, MegaMax, and Laser.
 *
 * Related Modules:
 *
 *			  AESBLIT.H - Mnemonic defines for direction flag.
 *			  AESFAST.A - AES bindings library (or other binding lib).
 *			  GEMFAST.H - GEM header file (equiv. to standard OBDEFS+GEMDEFS).
 *
 * Maintenance:
 * 
 *	06/22/89  v1.1
 *			  Formalized function as a 'cannned source' library routine.
 *			  Fixed a potential bug in which the VDI handle was not freed
 *			  if we returned an error due to not enough memory.
 *	08/08/89  v1.2
 *			  Added differentiation (is that a word?) of error return codes.
 *			  Added Getrez() call for v_opnvwk(), as described in GDOS doc.
 *	08/23/89  v1.3
 *			  Added compatibility code for non-GEMFAST users.
 *			  Added 'phys_handle' and 'num_planes' vars, and code to only
 *			  init the variables once, eliminating some GEM calls on
 *			  subsequent calls to aes_blit.
 *************************************************************************/

/**************************************************************************
 *
 * 08/23/89 v1.3
 *
 * The following block of code sets up compatibility when this module is
 * compiled and linked by a user who doesn't use the GEMFAST bindings
 * system.	To compile without using GEMFAST, replace 'gemfast.h' in the
 * #include below with the name(s) of your GEM header files.  Everything
 * else is automatic: since your header file(s) will not define the
 * GEMFAST_H constant, the following code will compile and provide the
 * needed data definitions and functions.
 *
 *************************************************************************/

#include <gemfast.h>	/* equivelent to obdefs.h + gemdefs.h */
#include <osbind.h>
#include "aesblit.h"

#ifndef GEMFAST_H		/* if GEMFAST is NOT being used, compile this... */
  
typdef struct {
	int v_x1;
	int v_y1;
	int v_x2;
	int v_y2;
	} VRECT;			/* define the VRECT (VDI rectangle) structure. */

typedef long FDADDR;	/* fd_addr is a 'long' in gemdefs.h */

/**************************************************************************
 *
 * rc_gtov - Convert an AES GRECT into a VDI VRECT. 
 *
 *************************************************************************/

static void
rc_gtov(grect, vrect)
	register GRECT *grect;
	register VRECT *vrect;
{
	vrect->v_x1 = grect->g_x;
	vrect->v_y1 = grect->g_y;
	vrect->v_x2 = grect->g_x + grect->g_w;
	vrect->v_y2 = grect->g_y + grect->g_h;
}

#endif					/* end of compatibility code */

/**************************************************************************
 *
 * aes_blit - The blit routine.
 *
 *************************************************************************/

int
aes_blit(dirflag, blitrect)
	int 			dirflag;	  /* Direction of blit (save/restore)	   */
	register GRECT	*blitrect;	  /* Area to blit (x/y/w/h) 			   */
{
	int 			dmy;		  /* Typical dummy variable 			   */
	long			dmyfdb = 0L;  /* Dummy FDB describing screen for blits */
	unsigned int	i,j,k,l;	  /* Temp vars for wind_get return values  */
	long			aes_len;	  /* Length of the AES blit buffer		   */
	FDB 			aesfdb; 	  /* FDB describing AES blit buffer 	   */
	int 			vdi_handle;   /* Handle for temp VDI workstation	   */
	int 			work_out[57]; /* Return values from VDI open/inquire   */

	struct	{					  /* This is the 'pxy array' used in the   */
			VRECT	srce;		  /* VDI blit command; actually two VRECT- */
			VRECT	dest;		  /* type rectangles stuck back-to-back    */
			} blitcntl; 		  /* so it looks like an array. 		   */

	static int		work_in[11] = {1,1,1,1,1,1,1,1,1,1,2}; /* Typical stuff  */
	static int		phys_handle = -1;
	static int		num_planes	= -1;
	
/*----------------------------------------------------------------------*
 * open a vdi workstation; call vq_extnd to get the number of bit planes.
 *----------------------------------------------------------------------*/

	if (phys_handle < 0) {
		phys_handle = graf_handle(&dmy, &dmy, &dmy, &dmy);
		work_in[0] = Getrez() + 2;
	}
	
	vdi_handle = phys_handle;
	v_opnvwk(work_in, &vdi_handle, work_out);
	if (vdi_handle < 1) {
		return -2;
	}
	
	if (num_planes < 0) {
		vq_extnd(vdi_handle, 1, work_out);
		num_planes = work_out[4];
	}
	
/*----------------------------------------------------------------------* 
 * set up the fdb describing the aes menu/alert buffer.
 *----------------------------------------------------------------------*/
 
	aesfdb.fd_nplanes = num_planes;
	aesfdb.fd_stand   = 0;
	aesfdb.fd_w 	  = blitrect->g_w;
	aesfdb.fd_h 	  = blitrect->g_h;	 
	aesfdb.fd_wdwidth = (blitrect->g_w + 15) / 16;

/*----------------------------------------------------------------------* 
 * Get the address & length of the internal AES menu/alert buffer.	
 * TOS 1.2 apparently returns a 0 for the buffer length; s/b 8000 on 1.2.
 *----------------------------------------------------------------------*/

	wind_get(0, WF_SCREEN, &i,&j, &k,&l);

	aesfdb.fd_addr = (char *)(((unsigned long)i << 16) | (unsigned long)j);
	aes_len 	   = ((unsigned long)k << 16) | (unsigned long)l;
	if (aes_len == 0L) 
		aes_len = 8000L;

/*----------------------------------------------------------------------*
 * if there's not enough buffer for the blit, bail out now, otherwise
 * do the blit, based on the direction flag.
 *----------------------------------------------------------------------*/

	if (aes_len < (long)(aesfdb.fd_wdwidth * 2 * aesfdb.fd_h)) {
		v_clsvwk(vdi_handle);	/* v1.1 - Added this */
		return -39;
	}
	
	graf_mouse(M_OFF, 0L);

	if (dirflag == AESBLIT_SAVESCRN) {
		
		rc_gtov(blitrect, &blitcntl.srce);
			
		blitcntl.dest.v_x1 = 0;
		blitcntl.dest.v_y1 = 0;
		blitcntl.dest.v_x2 = blitrect->g_w;
		blitcntl.dest.v_y2 = blitrect->g_h;

		vro_cpyfm(vdi_handle, S_ONLY, &blitcntl, &dmyfdb, &aesfdb);

	} 
	else {
		
		blitcntl.srce.v_x1 = 0;
		blitcntl.srce.v_y1 = 0;
		blitcntl.srce.v_x2 = blitrect->g_w;
		blitcntl.srce.v_y2 = blitrect->g_h;

		rc_gtov(blitrect, &blitcntl.dest);
			
		vro_cpyfm(vdi_handle, S_ONLY, &blitcntl, &aesfdb, &dmyfdb);
	}

/*----------------------------------------------------------------------*
 * turn the mouse back on, close the VDI workstation, return success.
 *----------------------------------------------------------------------*/

	graf_mouse(M_ON, 0L);
	v_clsvwk(vdi_handle);
	return 0;
}

