/*
******************************** spcolor.c *************************************
*
* $Revision: 3.1 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/ttcolor.c,v $
* ==============================================================================
* $Author: lozben $	$Date: 91/07/30 16:39:20 $     $Locker:  $
* ==============================================================================
*
* $Log:	ttcolor.c,v $
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

#define	SETRGB(a, b, c)	    trap14(93, a, b, c)
#define GETRGB(a, b, c)	    trap14(94, a, b, c)

/*----------------------------------------------------------------------------*/
VOID
sp_vs_color( VOID )
{
    register WORD	*ptr = INTIN;
    register WORD	*rgb;
    register WORD	j, pen;
    register WORD	temp;
    register LONG	total;
	     LONG	RGB;


    if (v_planes > 8)
	j = 255;			    /* 255 is the most pens allowed   */
    else
	j = plane_mask[v_planes];           /* j = max pen allowed            */


    if ((pen = *ptr++) > j)                 /* is col in range                */
        return;

    /*
     * point to the proper color array
     */
    if (pen > 15)
	rgb = &REQ_X_COL[pen - 16][0];	    /* use extended col array	      */
    else
	rgb = &REQ_COL[pen][0];


    pen = (MAP_COL[pen] & j);  		    /* get lut offset                 */

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
    total = SMUL_DIV(temp, 255, 1000);	    /* total gets the gun value       */
    RGB = total << 16;			    /* total has R	              */


    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
    if (temp < 0)                                 
	temp = 0;		 		
    total = SMUL_DIV(temp, 255, 1000);	    /* total gets the gun value       */
    RGB |= total << 8;			    /* set the green component        */


    if ((temp = *ptr++) > 1000)
	temp = 1000;			    /* make sure temp is in range     */
    if (temp < 0)                                 
	temp = 0;		 		
    total = SMUL_DIV(temp, 255, 1000);	    /* total gets the gun value       */
    RGB |= total;			    /* set the blue component         */

    SETRGB(pen, 1, &RGB);		    /* set the RGB	              */
}
/*----------------------------------------------------------------------------*/
VOID
sp_vq_color( VOID )
{
    register WORD   i, j;
    register WORD   *ptr = INTIN;			/* col index val      */
    register WORD   *rgb;				
    register WORD   *out = INTOUT;
    register WORD   pen;
    register WORD   temp;
	     LONG   RGB;

    CONTRL[4] = 4;		   	    /* # of output ints               */

    if (v_planes > 8)
	j = 255;			    /* 255 is the most pens allowed   */
    else
	j = plane_mask[v_planes];           /* j = max pen allowed            */

    if ((pen = *ptr++) > j) {		    /* col ndx in range ?             */
        *out = -1;			    /* invalid index                  */
        return;
    }

    *out++ = pen;

    /*
     * point to the proper color array
     */
    if (pen > 15)
	rgb = &REQ_X_COL[pen - 16][0];	    /* use extended col array	      */
    else
	rgb = &REQ_COL[pen][0];

    pen = (MAP_COL[pen] & j);		

    if (*ptr--) {			    /* return col val set             */
	GETRGB(pen, 1, &RGB);		    /* set the RGB	    */

	temp = (RGB >> 16) & 255;
        *out++ = SMUL_DIV(temp, 1000, 255);		/* get red component  */

	temp = (RGB >> 8) & 255;
        *out++ = SMUL_DIV(temp, 1000, 255);		/* get green compont  */

	temp = RGB & 255;
        *out++ = SMUL_DIV(temp, 1000, 255);		/* get blue component */
    }
    else {					        /* ret val requested  */
        *out++ = *rgb++;				/* get red component  */
        *out++ = *rgb++;				/* get green compont  */
        *out = *rgb;				        /* get blue component */
    }
}
/*----------------------------------------------------------------------------*/
