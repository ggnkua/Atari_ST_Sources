/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		spritesc.h

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

struct sprite_s {
	FDB spriteFDB;		/* FDB for sprite for VDI raster operations  */
        FDB screenFDB;		/* FDB for screen for VDI raster operations  */
	int pxymemscr[8];	/* Source and destination rect - to screen   */
	int pxyscrmem[8];	/* Source and destination rect - from screen */ 
	char *sptemp;		/* Place to save part of picture 
				   overwritten by sprite	*/
	int v_hnd;		/* VDI handle */
};
