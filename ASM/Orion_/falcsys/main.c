// FalconSystem Demo Example

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "falcsys.h"

/***************************************/

void	*MyFrame1(void *screen, bool *do_c2p)
{
	int	x, y;
	u16	*scr = (u16*)screen;

	for (y = 0; y < SCREEN_HEIGHT; y++)
		for (x = 0; x < SCREEN_WIDTH; x++)
			*scr++ = RGB8_TO_FALC16(0, x ^ y, 0);

	*do_c2p = false;

	// Quit after 4 seconds
	if (FS_Timer200Hz >= MSEC_TO_TIMER(4000))
		return (NULL);

	return (screen);
}

/***************************************/

u32	WhiteBluePal[256];

void	MakeWhiteBluePalette(void)
{
	int	i;

	// Make White/Blue Gradient Palette
	for (i = 0; i < 128; i++)
		WhiteBluePal[i] = RGB8_TO_FALC(i, i, i * 2);
	for (     ; i < 256; i++)
		WhiteBluePal[i] = RGB8_TO_FALC(i, i, 255);
}

void	*MyFrame2(void *screen, bool *do_c2p)
{
	int	y;

	for (y = 0; y < SCREEN_HEIGHT; y++)
		FastHLine320_8(screen, 0, 319, y, y);

	*do_c2p = false;

	// Quit after 6 seconds
	if (FS_Timer200Hz >= MSEC_TO_TIMER(6000))
		return (NULL);

	return (screen);
}

/***************************************/

int		main(void)
{
	if (!FalconInit(VM_320x240_16BITS | DOUBLE_BUFFER, NULL))
		return (0);
	FalconLoop(MyFrame1);
	FalconExit();

	MakeWhiteBluePalette();
	if (!FalconInit(VM_320x240_8BITS | DOUBLE_BUFFER, WhiteBluePal))
		return (0);
	FalconLoop(MyFrame2);
	FalconExit();

	return (0);
}
