/*
********************************  opnwk.c   ***********************************
*
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/ttc.c,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 15:52:15 $     $Locker:  $
* =============================================================================
*
* $Log:	ttc.c,v $
*******************************************************************************
*/

#include	"proto.h"
#include	"portab.h"
#include	"fontdef.h"
#include	"attrdef.h"
#include	"scrndev.h"
#include	"vardefs.h"
#include	"lineavar.h"
#include	"gsxdef.h"
#include	"gsxextrn.h"

#define		SETMODEFLAG	    5		/* for sparrow	 	     */
#define		DEFAULTDEV	    0
#define		STAYINDEV	    1
#define		SSHIFT		    * ((BYTE *) 0x44cL)
#define		SETMODE(a)	    trap14b(5, 0L, 0L, 3, a)
#define		SETREZ(a)	    trap14b(5, -1L, -1L, a)

extern  SCREENDEF	*devices[];
	SCREENDEF	*FindDevice();
extern	FONT_HEAD	f8x16, f8x8, f16x32;
	FONT_HEAD	ram8x16, ram8x8, ram16x32;

/* 
 * v_opnwk():	OPEN_WORKSTATION:
 */
VOID v_opnwk( VOID )
{
	REG WORD	i, *sp, *dp, videoMode;

	if (INTIN[0] == SETMODEFLAG) {
	    videoMode = SETMODE(-1);		/* get current video mode    */
	    if (videoMode != PTSOUT[0])		/* see if cur mode != dsred  */
		SETMODE(PTSOUT[0]);		/* set the video to new mode */
	}
	else {
	    if (FindDevice(INTIN[0]) == NULL) {
		CONTRL[6] = 0;			/* unsuccessfull in opening  */
		return;
	    }
	}

	/* Move ROM copy of DEV_TAB to RAM */
	sp = ROM_DEV_TAB;
	dp = DEV_TAB;
	for (i=0;i<45;i++)
		*dp++ = *sp++;


	/* Move ROM copy of DEV_TAB to RAM */
	sp = ROM_INQ_TAB;
	dp = INQ_TAB;
	for (i=0; i < 45; i++)
		*dp++ = *sp++;


	/* Move ROM copy of SIZ_TAB to RAM */
	sp = ROM_SIZ_TAB;
	dp = SIZ_TAB;
	for (i=0; i < 12; i++)
		*dp++ = *sp++;

	/* 
	 * copy the font headers to ram so they can be altered
	 */
	ram8x8 = f8x8;
	ram8x16 = f8x16;
	ram16x32 = f16x32;
	font_ring[1] = &ram8x8;

	/*
	 * init all the device dependant stuff
	 */
	InitDevTabInqTab();

	CUR_DEV->fntPtr->flags |= DEFAULT;

	CONTRL[6] = virt_work.handle = 1;
	cur_work = &virt_work;
	virt_work.next_work = NULLPTR;
	
	line_cw = -1;				/* invalidate curr line width */
	text_init();				/* initialize the SIZ_TAB info*/
	init_wk();

	/* Input must be initialized here and not in init_wk */
	loc_mode = 0;				/* default is request mode    */
	val_mode = 0;				/* default is request mode    */
	chc_mode = 0;				/* default is request mode    */
	str_mode = 0;				/* default is request mode    */

	/*
	 * Install mouse interrupt service routine, vblank draw routine,
	 * and initialize associated variables and structures. Mouse
	 * cursor and alpha cursor are initially hidden. Timing vectors
	 * are also initialized.
	 */
	INIT_G();

	(*V_ROUTINES[V_INIT])();
}
/*----------------------------------------------------------------------------*/
/* 
 * This function is here for soft loaded vdi. We init the workType then find
 * a device out of a set of caned devices. And do a SETREZ (setscreen) call.
 */
SCREENDEF *FindDevice(devId)
WORD	devId;
{
    REG SCREENDEF   *dev;
    REG WORD	    i, curRez;

    curRez = devId - 2;

    if (devId == DEFAULTDEV) {
	dev = devices[DEFAULTDEV];
        CUR_DEV = dev;
	SETREZ(curRez);				/* get into default res	     */
    }
    else if (devId == STAYINDEV)
	dev = CUR_DEV;
    else {
	for (i = 0, dev = devices[0]; ; dev = devices[++i]) {
	    if (dev == NULL) {
		dev = devices[DEFAULTDEV];
		CUR_DEV = dev;
		curRez = dev->devId - 2;	/* set to defaul rez	     */
		SETREZ(curRez);			/* get into default res	     */
		break;
	    }
	    else if (dev->devId == devId) {
		CUR_DEV = dev;

		if (curRez <= 8)		/* test if rez exists	     */
		    SETREZ(curRez);		/* get into desired res	     */
		else
		    esc_init();

		break;				/* found the proper dev      */
	    }
	}
    }
    return (dev);
}
/*----------------------------------------------------------------------------*/
/* 
 * This function is here for soft loaded vdi. We init the CUR_DEV if we can.
 */
VOID
SetCurDevice(curRez)
WORD	curRez;
{
    REG SCREENDEF   *dev;
    REG WORD	    i, devId;

    devId = curRez + 2;
    for (i = 0, dev = devices[0]; ; dev = devices[++i]) {
	if (dev->devId == devId) {
	    CUR_DEV = dev;
	    break;				/* found the proper dev      */
	}
    }
}
/*----------------------------------------------------------------------------*/
VOID
InitFonts( VOID )
{
    /* 
     * copy the font headers to ram so they can be altered
     */
    ram8x8 = f8x8;
    ram8x16 = f8x16;
    ram16x32 = f16x32;
}
/*----------------------------------------------------------------------------*/
VOID 
InitDevTabInqTab( VOID )
{
    REG SCREENDEF	*dev;

    dev = CUR_DEV;			    /* init current dev pointer   */

    DEV_TAB[0]  = dev->xRez - 1;	    /* X max                      */
    DEV_TAB[1]  = dev->yRez - 1;	    /* Y max                      */
    DEV_TAB[3]  = dev->xSize;		    /* width of pixel in microns  */
    DEV_TAB[4]  = dev->ySize;		    /* height of pixel in microns */
    DEV_TAB[13] = dev->maxPen;		    /* # of pens available        */
    DEV_TAB[35] = dev->colFlag;		    /* color capability flag      */
    DEV_TAB[39] = dev->palSize;		    /* palette size               */
    INQ_TAB[1]  = dev->palSize;		    /* number of background clrs  */
    INQ_TAB[4]  = dev->planes;		    /* number of planes           */
    INQ_TAB[5]  = dev->lookupTable;	    /* video lookup table         */
}
/*----------------------------------------------------------------------------*/

