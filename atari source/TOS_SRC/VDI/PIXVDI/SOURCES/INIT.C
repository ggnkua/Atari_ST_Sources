/*
********************************  init.c  *************************************
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

#define	P_COOKIE    *(LONG **) 0x5a0
#define _VDO	    0x5f56444fL

#define STCOOKIE    0L
#define STECOOKIE   1L
#define TTCOOKIE    2L
#define SPCOOKIE    3L
#define SPSHIFTMODE	    (* ((WORD *) 0xff8266))	/* sparrow shift mode */
#define PIXMASK		    0x200			/* pix control in XGA */
#define	SSHIFT		    * ((BYTE *) 0x44cL)

#define	_320x200    0                           /* 320x200x4 video mode       */
#define	_640x200    1                           /* 640x200x2 video mode       */
#define	_640x400    2                           /* 640x400x1 video mode       */
#define	_640x480    4                           /* 640x480x4 video mode       */
#define	_1280x960   6                           /* 1280x960x1 monochrome mode */
#define	_320x480    7                           /* 320x480x8 video mode       */

extern	WORD	    trap14();
extern	WORD	    tt_vq_color(), tt_vs_color();
extern	WORD	    sp_vq_color(), sp_vs_color();

#define GetRez()	trap14(4)
#define	ESetBank(a)	trap14(82, a)
#define	ESetGray(a)	trap14(86, a)
#define	SETRGB(a, b, c)	trap14(93, a, b, c)

/*----------------------------------------------------------------------------*/
VOID
init_st_tt_sp( VOID )
{
    REG LONG	*cookiePtr, cookieVal, *palMapPtr, i;

    palMapPtr = pal_map;
    for (i = 0; i < 256; i++)
	*palMapPtr++ = i;		    /* mapping is one to one for pens */

    cookiePtr = P_COOKIE;

    if (cookiePtr == NULL)		    /* no cookie jar (i.e> it's an ST */
	InitST();

    else {
	for (; *cookiePtr != 0L; cookiePtr += 2)
	    if (*cookiePtr == _VDO)
		break;

	if (*cookiePtr == _VDO) {
	    /*
	     * store in the lower wrd the val
	     */
	    cookieVal = cookiePtr[1] >> 16;

	    if (cookieVal == TTCOOKIE) {
		V_ROUTINES[V_VQCOLOR] = tt_vq_color;
		V_ROUTINES[V_VSCOLOR] = tt_vs_color;
		InitTT();
	    }
	    else if (cookieVal > TTCOOKIE && CUR_DEV->palSize != 2) {
		    V_ROUTINES[V_VQCOLOR] = sp_vq_color;
		    V_ROUTINES[V_VSCOLOR] = sp_vs_color;
		    InitSTSpLut();
		    InitColReqArray();
	    }
	    else
    		InitST();
	}
	else
	    InitST();
    }
}
/*----------------------------------------------------------------------------*/
VOID 
InitST( VOID )
{
    REG WORD	*sp, *dp, i;
    WORD	*old_intin, *old_intout, *old_contrl;
    WORD	new_contrl[7], new_intin[2], new_intout[4];

    InitSTSpLut();				/* initialize color lut	      */

    if (GetRez() == _640x400) {
	DEV_TAB[35] = 0;			/* color capability           */
	DEV_TAB[39] = 2;			/* palette size               */
	INQ_TAB[1]  = 1;			/* number of background clrs  */
	INQ_TAB[5]  = 0;			/* video lookup table         */
    }

    /* set up the REQ_COL array */
    old_intin = INTIN;
    old_intout = INTOUT;
    old_contrl = CONTRL;

    CONTRL = new_contrl;
    INTIN = new_intin;
    INTOUT = new_intout;

    new_intin[1] = 1;
    dp = REQ_COL;
    sp = new_intout + 1;

    for (i = 0; i < DEV_TAB[13]; i++) {
	new_intin[0] = i;
	vq_color();
	*dp++ = *sp;
	*dp++ = *(sp+1);
	*dp++ = *(sp+2);
    }

    CONTRL = old_contrl;
    INTIN = old_intin;
    INTOUT = old_intout;
}
/*----------------------------------------------------------------------------*/
VOID
InitTT( VOID )
{
    REG WORD	*sp, *dp, i, j, temp;
    WORD	*old_intin, *old_intout, *old_contrl;
    WORD	new_contrl[7], new_intin[2], new_intout[4];


    ESetGray(0);				/* init to color mode	      */
    ESetBank(0);				/* init to bank zero	      */
    InitTTLut();				/* initialize color lut	      */

    old_intin = INTIN;
    old_intout = INTOUT;
    old_contrl = CONTRL;

    CONTRL = new_contrl;
    INTIN = new_intin;
    INTOUT = new_intout;
    temp = DEV_TAB[13];				/* temp <- #  pens available  */

    new_intin[1] = 1;
    dp = REQ_COL;
    sp = new_intout + 1;

    /*
     * Initialize the request color array, and the request extended
     * color array. Do it for all banks if there are banks in the
     * current video mode.
     */
    switch (GetRez()) {

	case _320x200: /* initialize the 2 color arrays to the */
	case _640x200: /* values which are stored in the color */
	case _640x480: /* lookup table for all 16 banks        */

	    for (i = 0; i < 16; i++) {
		new_intin[0] = i;
		vq_color();
		*dp++ = sp[0];
		*dp++ = sp[1];
		*dp++ = sp[2];
	    }

	    dp = REQ_X_COL;
	    for (i = 1; i < 16; i++) {
		ESetBank(i);
		for (j = 0; j < 16; j++) {
		    new_intin[0] = j;
		    vq_color();
		    *dp++ = sp[0];
		    *dp++ = sp[1];
		    *dp++ = sp[2];
		}
	    }
	    ESetBank(0);			/* restore to bank 0	    */
	    break;

	case _640x400:
	case _1280x960:
	    for (i = 0; i < temp; i++) {
		new_intin[0] = i;
		vq_color();
		*dp++ = sp[0];
		*dp++ = sp[1];
		*dp++ = sp[2];
	    }
	    break;

	case _320x480:
	    for (i = 0; i < 16; i++) {
		new_intin[0] = i;
		vq_color();
		*dp++ = sp[0];
		*dp++ = sp[1];
		*dp++ = sp[2];
	    }

	    /*
	     * we have > 16 cols so fill the extended color array
	     */
	    dp = REQ_X_COL;
	    for (; i < temp; i++) {
		new_intin[0] = i;
		vq_color();
		*dp++ = sp[0];
		*dp++ = sp[1];
		*dp++ = sp[2];
	    }
 
	    break;
    }
	
    CONTRL = old_contrl;
    INTIN = old_intin;
    INTOUT = old_intout;
}
/*----------------------------------------------------------------------------*/
VOID
InitSTSpLut( VOID )
{
    REG WORD	count;
    
    count = (CUR_DEV->maxPen > 16) ? 256 : 16;
    SETRGB(0, count, colors);    

    if (CUR_DEV->planes == 1)
	SETRGB(1, 1, colors + 15);
    else if (CUR_DEV->planes == 2)
	SETRGB(3, 1, colors + 15);
}
/*----------------------------------------------------------------------------*/
/*
 * Initialize the virtual pen values for the gsx mode.
 */
VOID
Init16Pal( VOID )
{
    REG LONG	R, G, B;
    REG	WORD	i, temp, *palMapPtr, *lutPtr;
    
    palMapPtr = pal_map;
    for (i = 0; i < 256; i++) {
	R = G = B = colors[i];

	/*
	 * calculate the red component
	 */
	temp = R >> 16; R = (temp * 31) / 255; R <<= 11;

	/*
	 * calculate the green component
	 */
	temp = (G >> 8) & 0xff;

	if (SPSHIFTMODE & PIXMASK) {
	    G = (temp * 63) / 255;		    /* green gun has 6 bits   */
	    G <<= 5;
	}
	else {
	    G = (temp * 31) / 255;		    /* green gun has 5 bits   */
	    G <<= 6;
	}

	/*
	 * calculate the blue component
	 */
	temp = B & 0xff; B = (temp * 31) / 255;

	*palMapPtr++ = (WORD) (R | G | B);
	*palMapPtr++ = (WORD) (R | G | B);
    }
    InitColReqArray();
    lutPtr = (WORD *) 0xff9800;			    /* point to color LUT     */

    /*
     * make border white
     */
    *lutPtr++ = 0xffff;
    *lutPtr = 0xffff;
}
/*----------------------------------------------------------------------------*/
VOID
Init32Pal( VOID )
{
    REG LONG	R, G, B, *palMapPtr;
    REG WORD	i, temp;

    palMapPtr = pal_map;
    for (i = 0; i < 256; i++)
	*palMapPtr++ = R | G | B;

    InitColReqArray();
}
/*----------------------------------------------------------------------------*/
VOID
InitColReqArray( VOID )
{
    REG WORD	*sp, *dp, i, temp;
    WORD	*old_intin, *old_intout, *old_contrl;
    WORD	new_contrl[7], new_intin[2], new_intout[4];

    /* set up the REQ_COL array */
    old_intin = INTIN;
    old_intout = INTOUT;
    old_contrl = CONTRL;

    CONTRL = new_contrl;
    INTIN = new_intin;
    INTOUT = new_intout;

    new_intin[1] = 1;
    dp = REQ_COL;
    sp = new_intout + 1;

    for (i = 0; i < 16; i++) {
	new_intin[0] = i;
	vq_color();
	*dp++ = sp[0];
	*dp++ = sp[1];
	*dp++ = sp[2];
    }

    dp = REQ_X_COL;
    temp = DEV_TAB[13];				/* temp <- #  pens available  */
    for (; i < temp; i++) {
        new_intin[0] = i;
	vq_color();
	*dp++ = sp[0];
	*dp++ = sp[1];
	*dp++ = sp[2];
    }

    CONTRL = old_contrl;
    INTIN = old_intin;
    INTOUT = old_intout;
}
/*----------------------------------------------------------------------------*/
VOID
InitTTLut( VOID )
{
    REG	WORD	i, *lutPtr;

    lutPtr = (WORD *) 0xff8400;			/* point to ste col lut	    */

    for (i = 0; i < 256; i++)
	*lutPtr++ = colors[i];

    if (_640x200 == GetRez()) {
	lutPtr = (WORD *) 0xff8400;		/* point to ste col lut	    */
	lutPtr[3] = colors[15];			/* set foreground color	    */
    }
}
/*----------------------------------------------------------------------------*/
