/*
 * Copyright 1982 by Digital Research Inc.  All rights reserved.
 * Copyright 1999 by Caldera, Inc. and Authors:
 * Copyright 2002 by The EmuTOS development team
 * Copyright 2008 modified for fVDI by Didier Mequignon
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See LICENSE for details.
 */



#include "fvdi.h"
#include "utility.h"
#include "function.h"
#include "globals.h"
#include <mint/osbind.h>

#define EMPTY   ((short)0xffff)
#define DOWN_FLAG ((short)0x8000)
#define QSIZE 200
#define QMAX QSIZE-1


#undef ABS
#define ABS(v) (v & 0x7FFF)

extern long get_color(long index);
extern long pixelread(long x, long y);
extern long end_pts(Virtual *vwk, long x, long y, short *xleftout, short *xrightout, int seed_type, long search_color);


/* Global variables */
static long search_color;       /* the color of the border      */


/* some kind of stack for the segments to fill */
static short queue[QSIZE];       /* storage for the seed points  */
static short qbottom;            /* the bottom of the queue (zero)   */
static short qtop;               /* points top seed +3           */
static short qptr;               /* points to the active point   */
static short qtmp;
static short qhole;              /* an empty space in the queue */

/*
 * crunch_queue - move qtop down to remove unused seeds
 */
void crunch_queue(void)
{
    while ((queue[qtop - 3] == EMPTY) && (qtop > qbottom))
        qtop -= 3;
    if (qptr >= qtop)
        qptr = qbottom;
}

/*
 * get_seed - put seeds into Q, if (xin,yin) is not of search_color
 */
short get_seed(Virtual *vwk, short xin, short yin, short *xleftout, short *xrightout, int seed_type)
{
    if (end_pts(vwk, (long)xin, (long)ABS(yin), xleftout, xrightout, seed_type, search_color)) {
        /* false if of search_color */
        for (qtmp = qbottom, qhole = EMPTY; qtmp < qtop; qtmp += 3) {
            /* see, if we ran into another seed */
            if ( ((queue[qtmp] ^ DOWN_FLAG) == yin) && (queue[qtmp] != EMPTY) &&
                (queue[qtmp + 1] == *xleftout) )

            {
                /* we ran into another seed so remove it and fill the line */
                RECT16 rect;

                rect.x1 = *xleftout;
                rect.y1 = ABS(yin);
                rect.x2 = *xrightout;
                rect.y2 = ABS(yin);

                /* Fix corners and invoke rectangle fill routine */
#if 0
                arb_corner(&rect);
#endif
                fill_area(vwk, (long)rect.x1, (long)rect.y1, (long)rect.x2, (long)rect.y2, vwk->fill.colour.foreground);

                queue[qtmp] = EMPTY;
                if ((qtmp + 3) == qtop)
                    crunch_queue();
                return 0;
            }
            if ((queue[qtmp] == EMPTY) && (qhole == EMPTY))
                qhole = qtmp;
        }

        if (qhole == EMPTY) {
            if ((qtop += 3) > QMAX) {
                qtmp = qbottom;
                qtop -= 3;
            }
        } else
            qtmp = qhole;

        queue[qtmp++] = yin;    /* put the y and endpoints in the Q */
        queue[qtmp++] = *xleftout;
        queue[qtmp] = *xrightout;
        return 1;             /* we put a seed in the Q */
    }

    return 0;           /* we didnt put a seed in the Q */
}

void contourfill(Virtual *vwk, long color, short *coords)
{  
    short newxleft;              /* ends of line at oldy +       */
    short newxright;             /* the current direction        */
    short oldxleft;              /* left end of line at oldy     */
    short oldxright;             /* right end                    */
    short oldy;                  /* the previous scan line       */
    short xleft;                 /* temporary endpoints          */
    short xright;                /* */
    short direction;             /* is next scan line up or down */
    int notdone;                 /* does seedpoint==search_color */
    int gotseed;                 /* a seed was put in the Q      */
    int seed_type;               /* indicates the type of fill   */
    Workstation *wk = vwk->real_address;

    xleft = coords[0];
    oldy = coords[1];

    if (xleft < vwk->clip.rectangle.x1 || xleft > vwk->clip.rectangle.x2 ||
        oldy < vwk->clip.rectangle.y1  || oldy > vwk->clip.rectangle.y2)
        return;

    search_color = pixelread((long)xleft,(long)oldy);
    
    if (color < 0) {
        seed_type = 1;
    } else {
				/* Range check the color and convert the index to a pixel value */
				if (color >= (unsigned long)wk->screen.palette.size)
						return;
				search_color = get_color(color);
        seed_type = 0;
    }

    notdone = end_pts(vwk, (long)xleft, (long)oldy, &oldxleft, &oldxright, seed_type, search_color);

    qptr = qbottom = 0;
    qtop = 3;                   /* one above highest seed point */
    queue[0] = (oldy | DOWN_FLAG);
    queue[1] = oldxleft;
    queue[2] = oldxright;           /* stuff a point going down into the Q */

    if (notdone) {
        /* couldn't get point out of Q or draw it */
        while (1) {
            RECT16 rect;

            direction = (oldy & DOWN_FLAG) ? 1 : -1;
            gotseed = get_seed(vwk, oldxleft, (oldy + direction), &newxleft, &newxright, seed_type);

            if ((newxleft < (oldxleft - 1)) && gotseed) {
                xleft = oldxleft;
                while (xleft > newxleft) {
                    --xleft;
                    get_seed(vwk, xleft, oldy ^ DOWN_FLAG, &xleft, &xright, seed_type);
                }
            }
            while (newxright < oldxright) {
                ++newxright;
                gotseed = get_seed(vwk, newxright, oldy + direction, &xleft, &newxright, seed_type);
            }
            if ((newxright > (oldxright + 1)) && gotseed) {
                xright = oldxright;
                while (xright < newxright) {
                    ++xright;
                    get_seed(vwk, xright, oldy ^ DOWN_FLAG, &xleft, &xright, seed_type);
                }
            }

            /* Eventually jump out here */
            if (qtop == qbottom)
                break;

            while (queue[qptr] == EMPTY) {
                qptr += 3;
                if (qptr == qtop)
                    qptr = qbottom;
            }

            oldy = queue[qptr];
            queue[qptr++] = EMPTY;
            oldxleft = queue[qptr++];
            oldxright = queue[qptr++];
            if (qptr == qtop)
                crunch_queue();

            rect.x1 = oldxleft;
            rect.y1 = ABS(oldy);
            rect.x2 = oldxright;
            rect.y2 = ABS(oldy);

            /* Fix corners and invoke rectangle fill routine */
#if 0
            arb_corner(&rect);
#endif
            fill_area(vwk, (long)rect.x1, (long)rect.y1, (long)rect.x2, (long)rect.y2, vwk->fill.colour.foreground);
        }
    }
}                               /* end of fill() */

