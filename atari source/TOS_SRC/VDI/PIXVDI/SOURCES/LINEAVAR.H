/*
******************************  lineavar.h  **********************************
* 
* $Revision: 3.2 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/lineavar.h,v $
* ============================================================================
* $Author: lozben $	$Date: 91/09/10 19:55:56 $     $Locker:  $
* ============================================================================
*
* $Log:	lineavar.h,v $
* Revision 3.2  91/09/10  19:55:56  lozben
* Added "WORD qCircle[80]" to the linea structure.
* 
* Revision 3.1  91/07/29  16:52:14  lozben
* Definition of the line1010 variable structure.
* 
******************************************************************************
*/

#ifndef _LINEAVAR_H_
#define _LINEAVAR_H_

typedef struct vdiVars {

    WORD        _angle;
    WORD        begAng;
    FONT_HEAD   *curFont;           /* pointer to current font              */
    WORD        delAng;
    WORD        deltaY;
    WORD        deltaY1;
    WORD        deltaY2;
    WORD        endAng;
    WORD        filIntersect;
    WORD        fillMaxY;
    WORD        fillMinY;
    WORD        nSteps;
    WORD        oDeltaY;
    WORD        sBegstY;
    WORD        sEndstY;
    WORD        sFilCol;
    WORD        sFillPer;
    WORD        sPatMsk;
    WORD        *sPatPtr;
    WORD        _start;
    WORD        xC;
    WORD        xRad;
    WORD        y;
    WORD        yC;
    WORD        yRad;

    WORD        mPosHx;	            /* Mouse hot spot - x coord             */
    WORD        mPosHy;	            /* Mouse hot spot - y coord             */
    WORD        mPlanes;            /* Ms planes (reserved, but we used it) */
    WORD        mCdbBg;             /* Mouse background color as pel value  */
    WORD        mCdbFg;             /* Mouse foreground color as pel value  */
    WORD        maskForm[32];       /* Storage for ms cursor mask and form  */

    WORD        inqTab[45];         /* info returned by vq_extnd VDI call   */
    WORD        devTab[45];         /* info returned by v_opnwk VDI call    */

    WORD        gCurX;              /* current mouse cursor X position      */
    WORD        gCurY;              /* current mouse cursor Y position      */

    WORD        hideCnt;            /* depth at which the ms is hidden      */
    WORD        mouseBt;            /* current mouse button status          */
    WORD        reqCol[16][3];      /* internal data for vq_color           */
    WORD        sizTab[15];         /* size in device coordinates           */
    WORD        termCh;             /* 16 bit character info                */
    WORD        chcMode;            /* the mode of the Choice device        */
    ATTRIBUTE   *curWork;           /* pointer to current works attributes  */
    FONT_HEAD   *defFont;           /* pointer to default font head         */
    FONT_HEAD   *fontRing[4];       /* ptrs to link list of fnt hdrs        */
    WORD        iniFontCount;       /* # of fonts in the FONT_RING lists    */
    WORD        lineCW;             /* current line width                   */
    WORD        locMode;            /* the mode of the Locator device       */
    WORD        numQCLines;         /* # of line in the quarter circle      */

    LONG        trap14Sav;	    /* space to save the return address     */
    LONG        colOrMask;          /* some modes this is ored in VS_COLOR  */
    LONG        colAndMask;         /* some modes this is anded in VS_COLOR */
    LONG	trap14BSav;	    /* space to sav ret adr (for reentrency)*/

    WORD	reserved0[32];	    /* reserved				    */
    WORD        strMode;            /* the mode of the String device        */
    WORD        valMode;            /* the mode of the Valuator device      */
    BYTE        curMsStat;          /* Current mouse status                 */
    BYTE        reserved1;          /* reserved                             */
    WORD        disabCnt;           /* hide depth of alpha cursor           */


    /*
     * the next 5 bytes are used as a communication
     * block to the vblank cursor draw routine.
     * They must be contiguous!!!!!!
     */
    WORD        xyDraw[2];          /* x,y communication block.             */
    BYTE        drawFlag;           /* Non-zero means draw ms frm on vblank */

    BYTE        mouseFlag;          /* Non-zero if mouse ints disabled      */

    LONG        trap1Sav;           /* space to save return address         */
    WORD        savCXY[2];          /* save area for cursor cell coords.    */

    WORD        saveLen;            /* height of saved form                 */
    WORD        *saveAddr;          /* screen addr of 1st word of plane 0   */
    WORD        saveStat;           /* cursor save status                   */
    LONG        saveArea[64];       /* save up to 4 planes. 16 longs/plane  */

    WORD        (*timAddr)();       /* ptr to user installed routine        */
    WORD        (*timChain)();      /* jmps here when done with above       */

    WORD        (*userBut)();       /* user button vector                   */
    WORD        (*userCur)();       /* user cursor vector                   */
    WORD        (*userMot)();       /* user motion vector                   */

    WORD        vCelHt;	            /* height of character cell             */
    WORD        vCelMx;	            /* maximum horizontal cell index        */
    WORD        vCelMy;             /* maximum vertical cell index          */
    WORD        vCelWr;             /* screen width (bytes) * cel_ht        */
    WORD        vColBg;             /* character cell text background color */
    WORD        vColFg;             /* character cell text foreground color */
    WORD        *vCurAd;            /* cursor address                       */
    WORD        vCurOff;            /* byte ofsset to cur from screen base  */
    WORD        vCurCx;             /* cursor cell X position               */
    WORD        vCurCy;             /* cursor cell Y position               */
    BYTE        vCTInit;            /* vCurTim reload value.                */
    BYTE        vCurTim;            /* cursor blink rate (# of vblanks)     */
    WORD        *vFntAd;            /* address of monospaced font data      */
    WORD        vFntNd;             /* last ASCII code in font              */
    WORD        vFntSt;             /* first ASCII code in font             */
    WORD        vFntWr;             /* width of font form in bytes          */
    WORD        vHzRez;             /* horizontal pixel resolution          */
    WORD        *vOffAd;            /* address of font offset table         */

/*
 *              bit 0	cursor flash		0:disabled  1:enabled
 *		bit 1	flash state		0:off       1:on
 *  not used    bit 2   cursor visibility       0:invisible 1:visible
 *		bit 3	end of line		0:overwrite 1:wrap
 *		bit 4	reverse video		0:on        1:off
 *		bit 5	cursor position	saved	0:false	    1:true
 *  not used	bit 6	critical section	0:false	    1:true
 */
    BYTE        vStat0;             /* cursor display mode (look above)     */

    BYTE        vDelay;             /* cursor redisplay period              */
    WORD        vVtRez;             /* vertical resolution of the screen    */
    WORD        bytesLin;	    /* copy of vLinWr for concat            */

    WORD        vPlanes;	    /* number of video planes               */
    WORD        vLinWr;	            /* number of bytes/video line           */

    WORD        *contrl;            /* ptr to the CONTRL array              */
    WORD        *intin;             /* ptr to the INTIN array               */
    WORD        *ptsin;             /* ptr to the PTSIN array               */
    WORD        *intout;            /* ptr to the INTOUT array              */
    WORD        *ptsout;            /* ptr to the PTSOUT array              */

    /*
     * The following 4 variables are accessed by the line-drawing
     * routines as an array (to allow post-increment addressing).
     * THEY MUST BE CONTIGUOUS !!
     */
    WORD        fgBp1;              /* foreground bit plane #1 value        */
    WORD        fgBp2;              /* foreground bit plane #2 value        */
    WORD        fgBp3;              /* foreground bit plane #3 value        */
    WORD        fgBp4;              /* foreground bit plane #4 value        */

    WORD        lstLin;             /* 0 => not last line of polyline       */
    WORD        lnMask;             /* line style mask.                     */
    WORD        wrtMode;	    /* writing mode.                        */


    WORD        x1;                 /* X1 coordinate                        */
    WORD        y1;                 /* Y1 coordinate                        */
    WORD        x2;                 /* X2 coordinate                        */
    WORD        y2;                 /* Y2 coordinate                        */

    WORD        *patPtr;            /* ptr to pattern.                      */
    WORD        patMsk;             /* pattern index. (mask)                */
    WORD        multiFill;          /* multiplane fill flag. (0 => 1 plane) */

    WORD        clip;               /* clipping flag.                       */
    WORD        xMnClip;            /* x minimum clipping value.            */
    WORD        yMnClip;            /* y minimum clipping value.            */
    WORD        xMxClip;            /* x maximum clipping value.            */
    WORD        yMxClip;            /* y maximum clipping value.            */

    WORD        xAccDda;            /* accumulator for x DDA                */
    WORD        ddaInc;             /* the fraction to be added to the DDA  */
    WORD        tSclsts;            /* scale up or down flag.               */
    WORD        monoStatus;         /* non-zero - cur font is monospaced    */
    WORD        sourceX;            /* X coord of character in font         */
    WORD        sourceY;            /* Y coord of character in font         */
    WORD        destX;              /* X coord of character on screen       */
    WORD        destY;              /* X coord of character on screen       */
    WORD        delX;               /* width of character                   */
    WORD        delY;               /* height of character                  */
    WORD        *fBase;             /* pointer to font data                 */
    WORD        fWidth;             /* offset,segment and form with of font */
    WORD        style;              /* special effects                      */
    WORD        liteMask;           /* special effects                      */
    WORD        skewMask;           /* special effects                      */
    WORD        weight;             /* special effects                      */
    WORD        rOff;	            /* Skew offset above baseline           */
    WORD        lOff;	            /* Skew offset below baseline           */
    WORD        scale;              /* replicate pixels                     */
    WORD        chUp;               /* character rotation vector            */
    WORD        textFg;             /* text foreground color                */
    WORD        *scrtchP;           /* pointer to base of scratch buffer    */
    WORD        scrPt2;             /* large buffer base offset             */
    WORD        textBg;             /* text background color                */
    WORD        copyTran;           /* cp rstr frm type flag (opaque/trans) */
    WORD        (*quitFill)();      /* ptr to routine for quitting seedfill */
    WORD	(*UserDevInit)();   /* ptr to user routine before dev_init  */
    WORD	(*UserEscInit)();   /* ptr to user routine before esc_init  */
    LONG	reserved2[8];	    /* reserved				    */

    WORD        (**routines)();     /* ptr to primitives vector list	    */
    SCREENDEF   *curDev;	    /* ptr to a surrent device structure    */
    WORD        bltMode;            /* 0: soft BiT BLiT 1: hard BiT BLiT    */
    /*
     * Stuff for 8 plane VDI
     */
    WORD        reserved3;          /* reserved				    */
    WORD        reqXCol[240][3];    /* extended request color array         */

    WORD        *svBlkPtr;          /* points to the proper save block      */
    LONG        fgBPlanes;          /* fg bit plns flags (bit 0 is plane 0) */

    /*
     * The following 4 variables are accessed by the line-drawing routines
     * as an array (to allow post-increment addressing).
     * THEY MUST BE CONTIGUOUS !!
     */
    WORD        fgBP5;              /* foreground bitPlane #5 value.        */
    WORD        fgBP6;              /* foreground bitPlane #6 value.        */
    WORD        fgBP7;              /* foreground bitPlane #7 value.        */
    WORD        fgBP8;              /* foreground bitPlane #8 value.        */

    /*
     * we don't get rid of the old area for compatibility reasons
     */
    WORD        _saveLen;           /* height of saved form                 */
    WORD        *_saveAddr;         /* screen addr of 1st word of plane 0   */
    WORD        _saveStat;          /* cursor save status                   */
    LONG        _saveArea[256];     /* save up to 8 planes. 16 longs/plane  */

    WORD	qCircle[80];	    /* space to build circle coordinates    */


/*============================== NEW STUFF =================================*/

    WORD	bytPerPix;	    /* number of bytes per pixel (0 if < 1) */
    WORD	formId;		    /* scrn form 2 ST, 1 stndrd, 3 pix      */
    LONG	vlColBg;	    /* escape background color (long value) */
    LONG	vlColFg;	    /* escape foreground color (long value) */
    LONG	palMap[256];	    /* either a maping of reg's or true val */
    WORD	(*primitives[40])();	/* space to copy vectors into	    */
} VDIVARS;

#endif
