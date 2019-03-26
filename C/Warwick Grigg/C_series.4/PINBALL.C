/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		pinball.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include <osbind.h>
#include <gemfast.h>
#include <stdio.h>
#include "chkalloc.h"
#include "errexit.h"
#include "scratt.h"
#include "degas.h"
#include "getsprit.h"
#include "sprites.h"

/*	SCREEN CONSTANTS	*/

#define SCREENSIZE	(32000)
#define SCREENALLOC	(32256)

#define LOGDIMX 32000
#define LOGDIMY 32000

/*	GLOBAL DATA	 */

char *ball, *mask;			/* Pointers to bit images	*/

/*	LOCAL DATA	*/

static int v_hnd;			/* VDI handle */

struct flipdef_s{
    struct flipdef_s	*nextflip;	/* Next link in the chain   */
    char		*mempos;	/* Pointer to screen memory */
    struct sprite_s	*scrsprite;	/* Sprite handle	    */
};

static struct flipdef_s loc, phys, *curlog;
static char myscreen[SCREENALLOC];	/* Alternate screen for flipping */

static int pallette[16];/* Place to store pallette so we can restore at end   */

void AppStart()				/* Initialise GEM etc.		*/
{
    extern int gl_apid;			/* the AES application id	*/
    int work_in[12], work_out[57];	/* arrays for openvwk		*/
    int i;				/* loop index			*/
    int dummy;				/* dummy return variable	*/

    appl_init();			/* initialise GEM's AES		*/
    if(gl_apid == -1)
	errexit("Sorry, the GEM AES won't initialise\n");
    v_hnd = graf_handle(&dummy, &dummy, &dummy, &dummy);
    for(i = 0; i < 10; i++)
    	work_in[i] = 1;
    work_in[10] = 2;			/* raster co-ordinates		*/
    v_opnvwk(work_in, &v_hnd, work_out);/* open GEM virtual workstation */
    if (!v_hnd)
	errexit("Sorry, I can't open a GEM VDI virtual workstation\n");
    Cursconf(0, 0);			/* configure cursor off		*/
    for (i=0; i<16; i++) {		/* get initial pallette setting	*/
	pallette[i] = Setcolor(i, -1);
    }
}

void AppEnd()
{
    v_clsvwk(v_hnd);			/* close GEM virtual workstation*/
    appl_exit();			/* closedown AES session	*/
    Setpallete(&pallette[0]);		/* restore pallete		*/
}

void Flip()	/* Animate by switching over screen buffers	*/
{
    Setscreen(curlog->nextflip->mempos, curlog->mempos, -1);
    Vsync();			/* wait til done on next vertical blank	*/
    curlog = curlog->nextflip;	/* cycle onto next screen buffer	*/
}

void PrepScreens()	/* Get the screen buffers	*/ 
{
    curlog = &loc;
    loc.nextflip = &phys;
    phys.nextflip = &loc;	/* now buffers are in a cyclic structure      */
    phys.mempos = (char *)Physbase();
    {
	register long temp = (long)myscreen;
	
	temp = (temp+255) & 0xffffff00;
	loc.mempos = (char *)temp;	/* now buffer is at 256 byte boundary */
    }
}

void Prepare()
{
    static char fname[] = "pinball.pc?";
    int spritedimx;	/* Dimension of sprite in Pixels */
    int spritedimy;

    spritedimx = scrdimx()/40;	/* Sprite size is a proportion of screen */
    spritedimy = scrdimy()/25;
    PrepScreens();
    fname[sizeof(fname)-2] = Getrez() + '1';
    DegasGet(loc.mempos, fname);
    GetSprite(v_hnd, loc.mempos, spritedimx, spritedimy);
    loc.scrsprite = OpenSprite(v_hnd, spritedimx, spritedimy);
    phys.scrsprite = OpenSprite(v_hnd, spritedimx, spritedimy);
    memmove(phys.mempos, loc.mempos, SCREENSIZE); /* same pic on each screen  */
    Flip();
}

int main()
{   
    int divx = LOGDIMX/scrdimx();
    int divy = LOGDIMX/scrdimy(); /* Scaling for logical to phys. coordinates */
    register int posx = 100;	  /* Ball position in logical coordinates     */
    register int posy = 100;
    register int speedx = 800;    /* Speed (in logical coordinates per flip)  */
    register int speedy = 800;
    int fgravity = 5;		  /* Gravity (in log. coords per fip per flip)*/
    int borderx = 29000;	  /* Screen border			      */
    int bordery = 29000;
    int speedlimx = 50;		  /* Stop when it gets this slow	      */
    
    AppStart();
    Prepare();

    /* Get into initial state where only physical screen shows sprite */

    DrawSprite(curlog->scrsprite, posx/divx, posy/divy, ball, mask);
    Flip();

    /* Main program loop */

    while (speedx<-speedlimx || speedx>speedlimx) { /* while ball fast enough */
	speedy = speedy + fgravity;	/* apply effect of gravity    */
	posx = posx + speedx;		/* ball moves to new position */
	posy = posy + speedy;
	if (posx<=0 || posx>=borderx) {/* if hitting wall */
		posx = posx - speedx;
		speedx = -speedx/2;	/* bounce and reduce speed */
	}
	if (posy<=0 || posy>=bordery) {/* if hitting floor/roof */ 
		posy = posy - speedy;
		speedy = -speedy/2;	/* bounce and reduce speed */
	}
	DrawSprite(curlog->scrsprite, posx/divx, posy/divy, ball, mask);
	Flip();
	UndrawSprite(curlog->scrsprite);
    }

    Flip();
    UndrawSprite(curlog->scrsprite);

    Setscreen(phys.mempos, phys.mempos, -1);
    Vsync();

    AppEnd();
    return (0);
}
