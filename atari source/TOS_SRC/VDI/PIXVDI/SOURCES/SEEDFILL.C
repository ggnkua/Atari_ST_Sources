/*
********************************  seedfill.c  *********************************
*
* $Revision: 3.4 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/seedfill.c,v $
* =============================================================================
* $Author: lozben $	$Date: 91/08/06 20:38:12 $     $Locker:  $
* =============================================================================
*
* $Log:	seedfill.c,v $
* Revision 3.4  91/08/06  20:38:12  lozben
* We now look at entry 255 of REV_MAP_COL to get a pen value of one.
* 
* Revision 3.3  91/01/22  13:34:15  lozben
* Changed label start to START because there was a name conflict.
* 
* Revision 3.2  91/01/14  15:46:01  lozben
* Made changes so the file can work with the latest gsxextrn.h and
* the new vardefs.h files.
* 
* Revision 3.1  91/01/08  17:06:05  lozben
* Change declaration WORD *Qptr to EXTERN WORD *Qptr.
* 
* Revision 3.0  91/01/03  15:19:00  lozben
* New generation VDI
* 
* Revision 2.4  90/02/14  16:15:30  lozben
* Optimized the code.
* 
* Revision 2.3  89/07/13  17:51:29  lozben
* Enlarged the buffer size to accomodate new rez (1280x960).
* 
* Revision 2.2  89/05/16  12:59:45  lozben
* Seedfill used to initialize FG_BP_[1,2,3,4], now initializes
* FG_B_PLANES instead. FG_B_PLANES is set to the current color
* index.
* 
* Revision 2.1  89/02/21  17:28:09  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************
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

#define EMPTY   	0xffff
#define DOWN_FLAG 	0x8000
#define NOFLAG(v) 	(v & 0x7FFF)
#define QSIZE 		3*1281
#define QMAX		QSIZE-3


extern  BOOLEAN retfalse();         /* routine for continuing fill  */

VOID
d_contourfill( VOID )
{
    quitfill = &retfalse;
    seedfill();
}

VOID
seedfill( VOID )
{ 
    REG WORD        *q;
    REG BOOLEAN     gotseed, leftseed;
    REG WORD        leftoldy;       /* the previous scan line tmp   */
    REG WORD        leftdirection;  /* is next scan line up or down */
    REG WORD        oldy;           /* the previous scan line       */
    WORD            direction;      /* is next scan line up or down */
    WORD            qPtr;
    WORD            oldxleft;       /* left end of line at oldy     */
    WORD            oldxright;      /* right end                    */
    WORD            newxleft;       /* ends of line at oldy +       */
    WORD            newxright;      /*     the current direction    */
    WORD            xleft;          /* temporary endpoints          */
    WORD            xright;         /*                              */
    BOOLEAN         collision, leftcollision;

    q = Q;
    
    Qptr = &qPtr;
    xleft = PTSIN[0];
    oldy = PTSIN[1];

    if ( xleft < XMN_CLIP || xleft > XMX_CLIP || oldy < YMN_CLIP || oldy > YMX_CLIP)
	return;

    search_color = (LONG) INTIN[0];

    /* Range check the color and convert the index to a pixel value */

    if (search_color >= DEV_TAB[13])
	return;

    else if (search_color < 0) {
	search_color = get_pix();
	seed_type = 1;
    }
    else {
	/* We mandate that white is all bits on.  Since this yields 15     */
	/* in rom, we must limit it to how many planes there really are.   */
	/* Anding with the mask is only necessary when the driver supports */
	/* move than one resolution.					   */

	search_color = (LONG) (MAP_COL[search_color] & plane_mask[v_planes]);
	search_color = pal_map[search_color];
	seed_type = 0;
    }

    /* Initialize the line drawing parameters */
    FG_B_PLANES = cur_work->fill_color;

    LSTLIN  = FALSE;

    gotseed = end_pts(xleft, oldy, &oldxleft, &oldxright);

    qPtr = Qbottom = 0;
    Qtop = 3;                   /* one above highest seed point */
    q[0] = (oldy | DOWN_FLAG);
    q[1] = oldxleft;
    q[2] = oldxright;           /* stuff a point going down into the Q */

    done  = FALSE;
    if (gotseed)
        goto START;             /* can't get point out of Q or draw it */
    else
        return;

    do {
        while (q[qPtr] == EMPTY)
        {
            qPtr += 3;
            if (qPtr == Qtop)
                qPtr = Qbottom;
        }

        oldy = q[qPtr];
        q[qPtr++] = EMPTY;
        oldxleft = q[qPtr++];
        oldxright = q[qPtr++];
        if (qPtr == Qtop)
            crunch_Q();
	if (done)		/* if queue is full, just quit. */
	    return;
                                
        fill_line(oldxleft,oldxright,NOFLAG(oldy));    
    
START:  
        direction = (oldy & DOWN_FLAG) ? 1 : -1;
        gotseed = get_seed(oldxleft, (oldy + direction),
                           &newxleft, &newxright, &collision);

	leftdirection = direction;
	leftseed = gotseed;
	leftcollision = collision;
	leftoldy = oldy;
        while ((newxleft < (oldxleft - 1)) && (leftseed || leftcollision))
        {
            xleft = oldxleft;
            while (xleft > newxleft)
		leftseed = get_seed(--xleft, leftoldy ^ DOWN_FLAG,
				    &xleft, &xright, &leftcollision);
	    oldxleft = newxleft;
	    if ((xleft < (newxleft - 1)) && (leftseed || leftcollision))
	    {
		newxleft = xleft;
		leftoldy += leftdirection;
		leftdirection = -leftdirection;
		leftoldy ^= DOWN_FLAG;
	    }
        }
        while (newxright < oldxright)
            gotseed = get_seed(++newxright, oldy + direction,
			       &xleft, &newxright, &collision);
        while ((newxright > (oldxright + 1)) && (gotseed || collision))
        {
            xright = oldxright;
            while (xright < newxright)
                gotseed = get_seed(++xright, oldy ^ DOWN_FLAG,
				   &xleft, &xright, &collision);
	    oldxright = newxright;
	    if ((xright > (newxright + 1)) && (gotseed || collision))
	    {
		newxright = xright;
		oldy += direction;
		direction = -direction;
		oldy ^= DOWN_FLAG;
	    }
        }
    } while (Qtop != Qbottom);

} /* end of fill() */


/*
 * move Qtop down to remove unused seeds
 */   
VOID
crunch_Q( VOID )
{
    REG WORD    *q = Q;
    REG WORD    qTop = Qtop;

    while ((q[qTop - 3] == EMPTY) && (qTop > Qbottom))
        qTop -= 3;

    if (*Qptr >= qTop) {
        *Qptr = Qbottom;
	done = (*quitfill)();		/* quitfill is set via LINE "A"  */
    }

    Qtop = qTop;
}

WORD get_seed(xin, yin, xleftout, xrightout, collide)
REG WORD    xin, yin;
REG WORD    *xleftout, *xrightout;
BOOLEAN     *collide;
{               
    REG WORD    qTmp;
    REG WORD    qHole;                  /* an empty space in the Q      */
    REG WORD    *q = Q;

    *collide = FALSE;
    if (done)
	return(FALSE);

    /*
     * false if of search_color
     */
    if (end_pts(xin, NOFLAG(yin), xleftout, xrightout)) {
        for (qTmp = Qbottom, qHole = EMPTY; qTmp < Qtop; qTmp += 3) {

            /* we ran into another seed so remove it and fill the line */
            if ((q[qTmp + 1] == *xleftout) && (q[qTmp] != EMPTY) &&
                ((q[qTmp] ^ DOWN_FLAG) == yin)) {

                fill_line(*xleftout, *xrightout, NOFLAG(yin));
                q[qTmp] = EMPTY;
                if ((qTmp + 3) == Qtop)
                    crunch_Q();

		*collide = TRUE;
                return(FALSE);
            }

            if ((q[qTmp] == EMPTY) && (qHole == EMPTY))
                qHole = qTmp;
        }
    
        if (qHole == EMPTY) {
	    if ((Qtop += 3) > QMAX) {
		done = TRUE;
		*collide = FALSE;
		return(FALSE);
	    }
	
	}
        else
            qTmp = qHole;

        q[qTmp++] = yin;               /* put the y and endpoints in the Q */
        q[qTmp++] = *xleftout;
        q[qTmp] = *xrightout;
        return(TRUE);                  /* we put a seed in the Q */

    } /* if endpts() */
    else
        return(FALSE);                 /* we didnt put a seed in the Q */

} /* get_seed */

VOID
v_get_pixel( VOID )
{
    REG LONG pel, *tmpPtr;
    REG WORD *int_out;

    /* Get the requested pixel */

    pel = get_pix();

    tmpPtr = int_out = INTOUT;


    if (form_id == PIXPACKED && v_planes > 8) {
	*tmpPtr = pel;
    }
    else {
	*int_out++ = pel;

	/*
	 * Correct the pel value for the # of planes so it is a standard value
	 */
	if ((INQ_TAB[4] == 1 && pel ==  1) ||
	    (INQ_TAB[4] == 2 && pel ==  3) ||
	    (INQ_TAB[4] == 4 && pel == 15))
	    pel = 255;

	*int_out = REV_MAP_COL[pel];
	CONTRL[4] = 2;
    }
}

