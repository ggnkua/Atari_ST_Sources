/*
******************************** trucolor.c ************************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/ttcolor.c,v $
* ==============================================================================
* $Author: lozben $	$Date: 91/07/30 16:39:20 $     $Locker:  $
* ==============================================================================
*
* $Log:	trucolor.c,v $
********************************************************************************
*/

#include	"proto.h"
#include	"portab.h"
#include	"fontdef.h"
#include	"attrdef.h"
#include	"scrndev.h"
#include	"lineavar.h"
#include	"vardefs.h"
#include	"gsxdef.h"
#include	"gsxextrn.h"

#define GUNMAX32	    255				/* 32 bits per pix    */
#define GUNMAX16	    31				/* 16 bits per pix    */
#define SPSHIFTMODE	    (* ((WORD *) 0xff8266))	/* sparrow shift mode */
#define PIXMASK		    0x200			/* pix control in XGA */

/*----------------------------------------------------------------------------*/
VOID
vs_32_color( VOID )
{
    register WORD	*ptr = INTIN;
    register WORD	*rgb;
    register WORD	pen;
    register WORD	temp;
    register LONG	total, value;


    if ((pen = *ptr++) > 255)               /* is col in range                */
        return;


    /*
     * point to the proper color array
     */
    if (pen > 15)
	rgb = &REQ_X_COL[pen - 16][0];	    /* use extended col array	      */
    else
	rgb = &REQ_COL[pen][0];


    pen = MAP_COL[pen];  		    /* get lut offset                 */

    *rgb++ = *ptr++;		            /* copy RED, GREEN, components    */
    *rgb++ = *ptr++;                        /* into the request col array     */
    *rgb = *ptr;
    ptr = INTIN + 1;                        /* point to red comp              */


    /*
     * load RGB values into LUT
     */
    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
							
    if (temp < 0)                                 
	temp = 0;		 		

    value = SMUL_DIV(temp, GUNMAX32, 1000); /* value gets the gun value       */
    total = value;			    /* total has R	              */
    total <<= 16;			    /* adjust to the proper bits      */

    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
							
    if (temp < 0)                                 
	temp = 0;		 		

    value = SMUL_DIV(temp, GUNMAX32, 1000); /* value gets the gun value       */
    value <<= 8;			    /* adjust the green component     */
    total |= value;			    /* total has RG component         */

    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
							
    if (temp < 0)                                 
	temp = 0;		 		

    value = SMUL_DIV(temp, GUNMAX32, 1000); /* value gets the gun value       */
    total |= value;			    /* value has the blue component   */

    pal_map[pen] = total;		    /* set the virtual RGB            */
}
/*----------------------------------------------------------------------------*/
VOID
vq_32_color( VOID )
{
    register WORD   i;
    register WORD   *ptr = INTIN;			/* col index val      */
    register WORD   *rgb;				
    register WORD   *out = INTOUT;
    register WORD   pen;
    register LONG   temp;


    CONTRL[4] = 4;		   	    /* # of output ints               */

    if ((pen = *ptr++) > 255) {		    /* col ndx in range ?             */
        *out = -1;			    /* invalid index                  */
        return;
    }

    *out++ = pen;

    /*
     * point to the proper color array
     */
    if (pen > 15)
	rgb = &REQ_X_COL[pen - 16][0];			/* use ext col array  */
    else
	rgb = &REQ_COL[pen][0];

    pen = MAP_COL[pen];		

    if (*ptr--) {					/* return col val set */
        temp = pal_map[pen];
	temp = (temp >> 16) & GUNMAX32;
        *out++ = SMUL_DIV((WORD)temp, 1000, GUNMAX32);	/* get red component  */

        temp = pal_map[pen];
	temp = (temp >> 8) & GUNMAX32;
        *out++ = SMUL_DIV((WORD)temp, 1000, GUNMAX32);	/* get green compont  */

        temp = pal_map[pen];
	temp &= GUNMAX32;
        *out++ = SMUL_DIV((WORD)temp, 1000, GUNMAX32);	/* get blue component */
    }
    else {					        /* ret val requested  */
        *out++ = *rgb++;				/* get red component  */
        *out++ = *rgb++;				/* get green compont  */
        *out = *rgb;				        /* get blue component */
    }
}
/*----------------------------------------------------------------------------*/
VOID
vs_16_color( VOID )
{
    register WORD	*ptr = INTIN;
    register WORD	*rgb;
    register WORD	pen;
    register WORD	temp, maxGrVal;
    register LONG	total, value;

    
    if ((pen = *ptr++) > 255)               /* is col in range                */
        return;


    /*
     * point to the proper color array
     */
    if (pen > 15)
	rgb = &REQ_X_COL[pen - 16][0];	    /* use extended col array	      */
    else
	rgb = &REQ_COL[pen][0];


    pen = MAP_COL[pen];  		    /* get lut offset                 */

    *rgb++ = *ptr++;		            /* copy RED, GREEN, components    */
    *rgb++ = *ptr++;                        /* into the request col array     */
    *rgb = *ptr;
    ptr = INTIN + 1;                        /* point to red comp              */


    /*
     * load RGB values into LUT
     */
    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
							
    if (temp < 0)                                 
	temp = 0;		 		

    value = SMUL_DIV(temp, GUNMAX16, 1000); /* value gets the red gun value   */
    total = value;			    /* total has R	              */
    total <<= 11;			    /* adjust to the proper bits      */

    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
							
    if (temp < 0)                                 
	temp = 0;		 		

    maxGrVal = GUNMAX16;
    if (SPSHIFTMODE & PIXMASK)
	maxGrVal += maxGrVal;		    /* green gun has 6 bits	      */

    value = SMUL_DIV(temp, maxGrVal, 1000); /* value gets the green gun value */
    if (maxGrVal == GUNMAX16)
	value <<= 6;			    /* adjust the green component     */
    else
	value <<= 5;			    /* adjust the green component     */

    total |= value;			    /* total has RG component         */

    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
							
    if (temp < 0)                                 
	temp = 0;		 		

    value = SMUL_DIV(temp, GUNMAX16, 1000); /* value gets the gun value       */
    total |= value;			    /* value has the blue component   */

    total |= col_or_mask;		    /* or in a predefined value	      */
    total &= col_and_mask;		    /* and in a predefined value      */

    ptr = pal_map + pen;
    *ptr++ = (WORD) total;		    /* set the virtual RGB            */
    *ptr = (WORD) total;		    /* just in case 1st word is used  */
}
/*----------------------------------------------------------------------------*/
VOID
vq_16_color( VOID )
{
    register WORD   i;
    register WORD   *ptr = INTIN;			/* col index val      */
    register WORD   *rgb;				
    register WORD   *out = INTOUT;
    register WORD   pen, maxGrVal;
    register LONG   temp;


    CONTRL[4] = 4;		   	    /* # of output ints               */

    if ((pen = *ptr++) > 255) {		    /* col ndx in range ?             */
        *out = -1;			    /* invalid index                  */
        return;
    }

    *out++ = pen;

    /*
     * point to the proper color array
     */
    if (pen > 15)
	rgb = &REQ_X_COL[pen - 16][0];			/* use ext col array  */
    else
	rgb = &REQ_COL[pen][0];

    pen = MAP_COL[pen];		

    if (*ptr--) {					/* return col val set */
        temp = pal_map[pen];
	temp = (temp >> 11) & GUNMAX16;			/* adjust for sign    */
        *out++ = SMUL_DIV((WORD)temp, 1000, GUNMAX16);	/* get red component  */

        temp = pal_map[pen];
	maxGrVal = GUNMAX16;
        if (SPSHIFTMODE & PIXMASK) {
	    maxGrVal += maxGrVal;			/* gr gun has 6 bits  */
	    temp = (temp >> 5) & maxGrVal;
	}
	else
	    temp = (temp >> 6) & maxGrVal;

        *out++ = SMUL_DIV((WORD)temp, 1000, maxGrVal);	/* get green compont  */

        temp = pal_map[pen];
	temp &= GUNMAX16;
        *out++ = SMUL_DIV((WORD)temp, 1000, GUNMAX16);	/* get blue component */
    }
    else {					        /* ret val requested  */
        *out++ = *rgb++;				/* get red component  */
        *out++ = *rgb++;				/* get green compont  */
        *out = *rgb;				        /* get blue component */
    }
}
/*----------------------------------------------------------------------------*/
