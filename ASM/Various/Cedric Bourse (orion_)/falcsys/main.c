// FalconSystem v5 Demo Example

#include <tos.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "falcsys.h"


/***************************************/
// This example is a loop in 16bits mode, reading the mouse position and drawing a pixel on screen at this position
// Press right mouse button to exit the loop

int	Example_16bitsmode_and_Mouse(void *screen)
{
	int	x, y;
	u16	*scr = (u16*)screen;
	u16	color;

	IKBD_ReadMouse();

	// Change Pixel color on Left Mouse Click
	if (IKBD_Mouse.b == IKBD_MOUSE_BUTTON_LEFT)
		color = RGB8_TO_FALC16(255, 0, 0);
	else
		color = RGB8_TO_FALC16(0, 0, 255);

	// Show actual mouse position
	scr[(IKBD_Mouse.y * SCREEN_WIDTH) + IKBD_Mouse.x] = color;

	// Exit on Right Mouse Click
	if (IKBD_Mouse.b == IKBD_MOUSE_BUTTON_RIGHT)
		return (FL_EXIT);

	return (FL_COPY);
}


/***************************************/
// This example is a loop in 8bits mode, reading the keyboard up/down key and drawing a screen of gradient palette
// Use space key to exit (EXIT_ON_SPACE_KEY flag in FalconInit function)

u32	WhiteBluePal[256];	// Local Palette passed as a pointer to FalconInit function
int	Ypos;

void	MakeWhiteBluePalette(void)
{
	int	i;

	// Make White/Blue Gradient Palette
	for (i = 0; i < 128; i++)
		WhiteBluePal[i] = RGB8_TO_FALC(i, i, i * 2);
	for (     ; i < 256; i++)
		WhiteBluePal[i] = RGB8_TO_FALC(i, i, 255);
}

int	Example_8bits_Palette_and_Keyboard(void *screen)
{
	int	y;

	// Draw part of screen with color
	for (y = 0; y < Ypos; y++)
		FastHLine320_8(screen, 0, SCREEN_WIDTH - 1, y, y);	// This function draw in 8bits planar mode (no c2p available in Basic Falcon 030 mode)
	// And other part with black
	for (     ; y < SCREEN_HEIGHT; y++)
		FastHLine320_8(screen, 0, SCREEN_WIDTH - 1, y, 0);

	// Press Up and Down on Keyboard to make more or less screen appear
	if (IKBD_IsKeyPressed(IKBD_KEY_UP) && (Ypos > 0))
		Ypos--;
	else if (IKBD_IsKeyPressed(IKBD_KEY_DOWN) && (Ypos < SCREEN_HEIGHT))
		Ypos++;

	return (FL_COPY);
}

/***************************************/
// This example is a loop in 8bits mode, using Chunky To Planar (FL_C2P)
// It only work on CT60 accelerator card (FastRam required)
// This flag will start an automatic conversion of a Chunky screen (one color index per byte) to the Atari Falcon planar screen specific format
// Use space key to exit (EXIT_ON_SPACE_KEY flag in FalconInit function)

int	Example_CT60_8bits_C2P(void *screen)
{
	u8	*scr = (u8*)screen;
	int	x, y;
	static	int	move = 0;

	// Draw a moving XOR pattern on screen :)
	for (y = 0; y < SCREEN_HEIGHT; y++)
		for (x = 0; x < SCREEN_WIDTH; x++)
			*scr++ = move + x ^ y;
	move++;

	return (FL_C2P);	// Activate Chunky to Planar conversion
}


/***************************************/

int		main(void)
{
	char	*err;

	// Test 1: 8bits, Keyboard
	MakeWhiteBluePalette();
	Ypos = 240/2;
	if (err = FalconInit(VM_320x240_8BITS | DOUBLE_BUFFER | FORCE_WAIT_VBL | EXIT_ON_SPACE_KEY, WhiteBluePal))
		goto Error;
	FalconLoop(Example_8bits_Palette_and_Keyboard);
	FalconExit();

	// Test 2: 16 bits, Mouse
	if (err = FalconInit(VM_320x240_16BITS | FORCE_WAIT_VBL, NULL))
		goto Error;
	IKBD_SetMouseOrigin(160, 120, 320, 240);
	FalconLoop(Example_16bitsmode_and_Mouse);
	FalconExit();

	// Test 3: CT60 8bits C2P
	// TRIPLE_BUFFER can be used without the FORCE_WAIT_VBL flag, this save processing time !
	// So you can start writing in the third buffer, while the first is still being shown on screen, and the second one will be shown in the next VBL
	if (err = FalconInit(VM_320x240_8BITS | TRIPLE_BUFFER | CT60_MODE | EXIT_ON_SPACE_KEY, WhiteBluePal))
	{
		printf("\n%s\n", err);
		printf("No CT60 detected, trying Emulator mode...\n");
		// If we got an Error (no CT60 detected) try the Emulator Mode
		// This will force the FastRam Screen allocation (and allow C2P), but it won't enable the 060 Cache & Superscalar mode.
		if (err = FalconInit(VM_320x240_8BITS | TRIPLE_BUFFER | CT60_MODE | EMULATOR_MODE | EXIT_ON_SPACE_KEY, WhiteBluePal))
			goto Error;
	}
	FalconLoop(Example_CT60_8bits_C2P);
	FalconExit();

	goto NoError;

Error:
	printf("\n%s\n", err);
	getchar();

NoError:

	return (0);
}
