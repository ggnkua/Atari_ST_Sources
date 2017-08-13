/*

	display.cpp


	some general graphics interface,
	currently 8bit palette mode & 32 bit XRGB



	(w)'2003 Defjam/Checkpoint..http://checkpoint.atari.org
*/







#include "display.h"



u32 rgbBuffer[YW][XW];
u8  chunkyBuffer[YW][XW];

u32 colortable[256];



void colorclip(int *color)
{
	if (*color <  0) *color=0;
	if (*color >255) *color=255;
}


int chunky_to_rgb_C()
{
	int x,y;

	for (y=0;y<YW;y++)
	{
		for (x=0;x<XW;x++)
		{
			rgbBuffer[y][x]=colortable[ chunkyBuffer[y][x] ];
		}
	}
	return 0;
}


// A LOT faster than the C version ...   not fully optimized anyway.
int chunky_to_rgb_asm()
{
	int y;
	u32 *outPtr;
	u8	*chunkPtr;

	for (y=0;y<YW;y++)
	{
		outPtr	= &rgbBuffer[y][0];
		chunkPtr= &chunkyBuffer[y][0];
		__asm 
		{
			pushad
			mov		edi,outPtr
			mov		esi,chunkPtr

			xor		eax,eax
			mov		edx,XW
		}

		
		__asm
		{
out_chunky:
			// mit scaliertem offset   Output: XW...0
			mov		al,[esi+edx]				// get chunky
			mov		ebx,[colortable+eax*4]		// RGBA = colortable[chunky]
			mov		[edi+edx*4],ebx				// write RGBA

			/*  
			// normal					Output: 0...XW
			mov		al,[esi]					// get chunky
			mov		ebx,[colortable]			// RGBA = colortable[chunky]
			mov		[edi+edx*4],ebx				// write RGBA
			add		edi,4
			inc		esi
			*/

			dec		dx
			jne		out_chunky
		}


		_asm 
		{
			popad
		}
	}

	return 0;
}





int chunky_to_rgb()
{
	return chunky_to_rgb_C();
	// return chunky_to_rgb_asm();
}



