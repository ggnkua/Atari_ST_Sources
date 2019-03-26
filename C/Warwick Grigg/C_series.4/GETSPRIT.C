/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		getsprit.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include <osbind.h>
#include <gemfast.h>
#include <stdio.h>
#include "chkalloc.h"
#include "errexit.h"
#include "degas.h"
#include "scratt.h"
#include "sprites.h"

extern char *ball;
extern char *mask;

void GetSprite(v_hnd, screenimg, spritedimx, spritedimy)	
			/* Get sprite from picture		*/
int v_hnd;		/* VDI handle				*/
char *screenimg;	/* Screen image containing sprites	*/ 
int spritedimx;		/* Dimensions of sprite (in pixels)	*/
int spritedimy;
{
    static int pxy[] = {0, 0, 0, 0, 0, 0, 0, 0};
    FDB f, s;
    int swsize;		/* Sprite word size */
    int i;

    swsize = WordPix(spritedimx)*spritedimy*planes();

    /* 
     * Get ball from [0, 0] -> [spritedimx-1, spritedimy-1] rectangle
     */

    ball = chkcalloc(swsize, sizeof(WORD));
    for (i=0; i<swsize*sizeof(WORD); i++)
	ball[i] = 0;
    InitFDB(&f, ball, spritedimx, spritedimy);
    InitFDB(&s, screenimg, scrdimx(), scrdimy());
    pxy[6] = pxy[2] = spritedimx-1;
    pxy[7] = pxy[3] = spritedimy-1;

    vro_cpyform(v_hnd, S_ONLY, &pxy[0], &s, &f);

    /* 
     * Get mask from [spritedimx, 0] -> [2*spritedimx-1, spritedimy-1] rectangle
     */

    mask = chkcalloc(swsize, sizeof(WORD));
    for (i=0; i<swsize*sizeof(WORD); i++)
	mask[i] = 0;
    f.fd_addr = (long)mask;
    pxy[0] = spritedimx;
    pxy[2] = spritedimx+spritedimx-1;

    vro_cpyform(v_hnd, S_ONLY, &pxy[0], &s, &f);
}
