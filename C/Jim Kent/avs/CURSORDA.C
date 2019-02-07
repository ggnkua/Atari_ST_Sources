/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */

#include "flicker.h"



static UWORD ileft[] = 
	{
	0x0,	0x0,	0x200,	0x400,	0xc00,	0x1800,	0x3fc0,	0x1800,
	0xc00,	0x400,	0x200,	0x0,
	};
struct cursor cleft = 	{ 0, ileft, 11, 12, 5, 6};


static UWORD iright[] = 
	{
	0x0,	0x0,	0x400,	0x200,	0x300,	0x180,	0x3fc0,	0x180,
	0x300,	0x200,	0x400,	0x0,
	};
struct cursor cright = 	{ 0, iright, 11, 12, 5, 6};


#ifdef SLUFFED
static UWORD	icross_cursor_image[] = {
		0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0xFFFE,
		0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0100, 0x0000,
		};
struct cursor cross_cursor =
    {
    0,
    icross_cursor_image,
    16, 16, 7, 7,
    };
#endif SLUFFED
