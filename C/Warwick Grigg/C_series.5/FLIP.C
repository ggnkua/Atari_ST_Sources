/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		flip.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */
#include <osbind.h>
#include <gemfast.h>
#include <stdio.h>
#include "flipc.h"

/*	SCREEN CONSTANTS	*/

#define SCREENALLOC	(32256)

static struct flipdef_s loc, phys;
static char myscreen[SCREENALLOC];	/* Alternate screen for flipping */

struct flipdef_s *Flip(curlog)	/* Animate by switching over screen buffers	*/
struct flipdef_s *curlog;
{
    Setscreen(curlog->nextflip->mempos, curlog->mempos, -1);
    Vsync();			/* wait til done on next vertical blank	*/
    return curlog->nextflip;	/* cycle onto next screen buffer	*/
}

struct flipdef_s *PrepScreens()	/* Get screen buffers */ 
{
    loc.nextflip = &phys;
    phys.nextflip = &loc;	/* now buffers are in a cyclic structure      */
    phys.mempos = (char *)Physbase();
    {
	register long temp = (long)myscreen;
	
	temp = (temp+255) & 0xffffff00;
	loc.mempos = (char *)temp;	/* now buffer is at 256 byte boundary */
    }
    return &loc;	/* return pointer to control block for new screen */
}

void DeFlip()
{
    Setscreen(phys.mempos, phys.mempos, -1);
    Vsync();
}
