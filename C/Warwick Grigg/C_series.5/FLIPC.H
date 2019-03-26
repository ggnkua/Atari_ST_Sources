/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		flipc.h

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

struct flipdef_s {
    struct flipdef_s	*nextflip;	/* Next link in the chain   */
    char		*mempos;	/* Pointer to screen memory */
    struct sprite_s	*scrsprite;	/* Sprite handle	    */
};

