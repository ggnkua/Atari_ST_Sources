/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		pinball.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */
#include <macros.h>
#include <osbind.h>
#include <gemfast.h>
#include <stdio.h>
#include "chkalloc.h"
#include "errexit.h"
#include "strtup.h"
#include "scratt.h"
#include "degas.h"
#include "getsprit.h"
#include "sprites.h"
#include "flip.h"

/*	SCREEN CONSTANTS	*/

#define SCREENSIZE	(32000)

#define LOGDIMX 32000
#define LOGDIMY 32000

/*	GLOBAL DATA	 */

char *ball, *mask;			/* Pointers to bit images	*/

/*	LOCAL DATA	*/

static int v_hnd;			/* VDI handle */

static struct flipdef_s *curlog;

static int spritedimx;		/* Dimension of sprite in Pixels */
static int spritedimy;

static int hotx[5], hoty[5];	/* hotspots for collisions */
static int background;		/* background colour	   */
static int divx;
static int divy;		/* Scaling for logical to phys. coordinates */
static int posx = 10000;	/* Ball position in logical coordinates     */
static int posy = 10000;
static int speedx = 100;	/* Speed (in logical coordinates per flip)  */
static int speedy = -100;
static int fgravity = 3;	/* Gravity (in log. coords per fip per flip)*/
static int bottomy = LOGDIMY-LOGDIMY/10; 
				/* Stop when ball gets this low	            */
static int debug;

void Prepare()
{
    static char fname[] = "pinball.pc?";
    int dummy;

    spritedimx = scrdimx()/40;	/* Sprite size is a proportion of screen */
    spritedimy = scrdimy()/25;
    divx = LOGDIMX/scrdimx();
    divy = LOGDIMY/scrdimy();

    /* Calculate "hot" spots for sprite */

    hotx[0] = hoty[0] = 0;
    hotx[4] = spritedimx-1;
    hotx[2] = spritedimx/2;
    hotx[1] = hotx[2]/3;
    hotx[3] = hotx[4]-hotx[1];
    hoty[4] = spritedimy-1;
    hoty[2] = spritedimy/2;
    hoty[1] = hoty[2]/3;
    hoty[3] = hoty[4]-hoty[1];
    curlog = PrepScreens();
    fname[sizeof(fname)-2] = Getrez() + '1';
    DegasGet(curlog->mempos, fname);
    GetSprite(v_hnd, curlog->mempos, spritedimx, spritedimy);
    curlog->scrsprite= OpenSprite(v_hnd, spritedimx, spritedimy);
    curlog->nextflip->scrsprite = OpenSprite(v_hnd, spritedimx, spritedimy);
    memmove(curlog->nextflip->mempos, 
	    curlog->mempos, 
	    SCREENSIZE); /* same pic on each screen  */
    curlog = Flip(curlog);
    v_get_pixel(v_hnd, scrdimx()-1, scrdimy()-1, &background, &dummy);
}

static int collided(x, y)
int x,y;
{
    int pel, index;

    v_get_pixel(v_hnd, x, y, &pel, &index);
    return (pel!=background);
}

static int bouncy(speed)
int speed;
{
    speed = (speed*10)/16;
    return speed;
}

static void advance()	/* Move ball onward checking for collisions */
{
    int newposx;	/* New ball position in logical coordinates */
    int newposy;
    int physx;		/* Ball position in physical coordinates    */
    int physy;
    int inc;
    int temp;

    for (inc=0; inc<4; inc++) { /* chop up time into small portions */
	speedy = speedy + fgravity;	/* apply effect of gravity    */
	newposx = posx + speedx;
	newposy = posy + speedy;
	physx = newposx/divx;
	physy = newposy/divy;
	if (collided(physx+hotx[1], physy+hoty[1])) { /* top left */
	    temp = bouncy(abs(speedx)) + 6;
	    speedx = bouncy(abs(speedy)) + 12 + ((rand()-16000)/2000);
	    speedy = temp;
	    break;
	}		
	if (collided(physx+hotx[3], physy+hoty[3])) { /* bottom right */
	    temp = - (bouncy(abs(speedx)) + 6);
	    speedx = - (bouncy(abs(speedy)) + 12) + ((rand()-16000)/2000);
	    speedy = temp;
	    break;
	}
	if (collided(physx+hotx[1], physy+hoty[3])) { /* bottom left */
	    temp = - (bouncy(abs(speedx)) + 6);
	    speedx = bouncy(abs(speedy)) + 12 + ((rand()-16000)/2000);
	    speedy = temp;
	    break;
	}
	if (collided(physx+hotx[3], physy+hoty[1])) { /* top right */
	    temp = bouncy(abs(speedx)) + 6;
	    speedx = - (bouncy(abs(speedy)) + 12) + ((rand()-16000)/2000);
	    speedy = temp;
	    break;
	}
	if (collided(physx+hotx[2], physy)) {	/* top */
	    speedx = bouncy(speedx) + ((rand()-16000)/2000);
	    speedy = bouncy(abs(speedy)) + 6;
	    break;
	}		
	if (collided(physx+hotx[2], physy+hoty[4])) { /* bottom */
	    temp = ((rand()-16000)/2000);
	    speedx = bouncy(speedx) + abs(temp);
	    speedy = - (bouncy(abs(speedy)) + 6);
	    break;
	}		
	if (collided(physx, physy+hoty[2])) { /* left side */
	    speedx = bouncy(abs(speedx)) + 12 + ((rand()-16000)/2000);
	    speedy = bouncy(speedy);
	    break;
	}		
	if (collided(physx+hotx[4], physy+hoty[2])) { /* right side */
	    speedx = - (bouncy(abs(speedx)) + 12) + ((rand()-16000)/2000);
	    speedy = bouncy(speedy);
	    break;
	}
	posx = newposx;
	posy = newposy;
    }
}

int main(argc, argv)
int argc;
char *argv[];
{
    debug = (argc>1);

    v_hnd = AppStart();

    Prepare();

    /* Get into initial state where only physical screen shows sprite */

    DrawSprite(curlog->scrsprite, posx/divx, posy/divy, ball, mask);
    curlog = Flip(curlog);

    /* Main program loop */

    while (posy < bottomy) { /* while ball still in play */
	advance();	/* advance ball */
	DrawSprite(curlog->scrsprite, posx/divx, posy/divy, ball, mask);
	curlog = Flip(curlog);
	UndrawSprite(curlog->scrsprite);
    }
    curlog = Flip(curlog);
    UndrawSprite(curlog->scrsprite);

    DeFlip();

    AppEnd(v_hnd);

    return (0);
}
