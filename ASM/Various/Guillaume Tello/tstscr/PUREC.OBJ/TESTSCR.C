/* TSTSCR.O library simple usage */
/* for Pure C                    */
/* Guillaume Tello 2020          */
/* guillaume.tello@orange.fr     */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <limits.h>
#include <ctype.h>
#include <vdi.h>
#include <aes.h>
#include <tstscr.h>

int main()
{
	long code, bpp, type;

	if (appl_init() < 0)
		return(0);

	code=ScreenEncoding(_GemParBlk.global, 0);

/* High word of code contains the number of bits/pixels and
   a flag in the high bit if an error occuerd */
   
	bpp=(code>>16) & 0xFFFF;		/* high word */
	
	if(bpp & errorbit)
		{bpp = bpp & errorclear;
		if (bpp==0)
			printf("Can't open VDI workstation...");
		else
			printf("Unknown screen encoding, %ld bits/pixel.\n",bpp);
		 }
	else
		{
		type=code & 0xFFFF;	/* low word */
		if(type & errorbit)
			{printf("VDI error, direct access was required\n");
			 type = type & errorclear;
			 }
		else
			printf("VDI Ok\n");

		printf(" Bits/pixel %ld Sub type %ld\n",bpp,type);
	
		code = code & errorclear;
		
		if(code == B1_mono) printf("Monochrome\n");
		if(code == B2_inter) printf("4 colors, interlaced planes\n");
		if(code == B2_ninter) printf("4 colors, planes\n");
		if(code == B4_inter) printf("16 colors, interlaced planes\n");
		if(code == B4_ninter) printf("16 colors, planes\n");
		if(code == B4_packed) printf("16 colors, packed pixels\n");
		if(code == B8_inter) printf("256 colors, interlaced planes\n");
		if(code == B8_ninter) printf("256 colors, planes\n");
		if(code == B8_packed) printf("256 colors, one byte per pixel\n");
		if(code == B8_packedM) printf("256 colors, one byte per pixel (Matrix)\n");
		if(code == B16_motor) printf("High Color rrrrrggg gggbbbbb\n");
		if(code == B16_intel) printf("High Color gggbbbbb rrrrrggg\n");
		if(code == B15_motor) printf("High Color xrrrrrgg gggbbbbb\n");
		if(code == B15_intel) printf("High Color gggbbbbb xrrrrrgg\n");
		if(code == B24_rgb) printf("True Color RGB\n");
		if(code == B24_bgr) printf("True Color BGR\n");
		if(code == B32_xrgb) printf("True Color xRGB\n");
		if(code == B32_xbgr) printf("True Color xBGR\n");
		if(code == B32_bgrx) printf("True Color BGRx\n");
		if(code == B32_rgbx) printf("True Color RGBx\n");
		}
	getchar();
	appl_exit();
	return(0);
}