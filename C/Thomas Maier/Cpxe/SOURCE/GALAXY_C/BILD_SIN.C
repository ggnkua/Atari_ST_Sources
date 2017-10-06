
#include <tm_start.h>
#include <tmstdlib.h>
#include <aes.h>
#include <math.h>

#include "bild.h"
#include "rsh.h"
#include "rsh.c"
#include "galaxy.h"



void main(void)
{
	WORD i;
	WORD w,h,k,bw,bh;
	BITBLK *bit;
	BYTE *p;
	
	Printf("\r\n/* Koordinaten der Sterne und Sinustabelle und Objektbaum */\r\n\r\n");
	
	Printf("#include <aes.h>\r\n\r\n");
	
	Printf("WORD stars[] = {\r\n");
	
	bit = rs_frimg[BILD];
	p = (BYTE*)bit->bi_pdata;
	k = 0;
	bw = bit->bi_wb;
	bh = bit->bi_hl;
	for ( h = 0; h < bh; h++ )
	{	for ( w = 0; w < bw; w++ )
		{	for ( i = 0; i < 8; i++ )
			{	if ( *p & ((UBYTE)0x80 >> i) )
				{	if ( k ) Printf(",\r\n");
					Printf("%hd,%hd",(w*8)+i-(bw*8/2),h-(bh/2));
					k++;
				}
			}
			p++;
		}
	}
	Printf("\r\n};\r\n\r\nWORD num_stars = %hd;\r\n",k);
	Printf("WORD bild_w = %hd, bild_h = %hd;\r\n",bw*8,bh/2);
	
	Printf("\r\n\r\nWORD sintab[] = {\r\n");

#define topi(_a) (M_PI * (double)(_a) / 180.0)

	for ( i = 0; i < 360; i += SINSTEP )
	{	if ( i ) Printf(",\r\n");
		Printf("%hd,%hd",(WORD)(sin(topi(i)) * MATHOFFSET),
						(WORD)(cos(topi(i)) * MATHOFFSET));
	}
	Printf("\r\n};\r\n\r\n");
	

	Printf("UWORD image[%hd];\r\n",(bw/2)*bh/2);
	Printf("BITBLK bitblk = { image, %hd, %hd, 0, 0, WHITE };\r\n",bw,bh/2);
	Printf("OBJECT tree[] = { \r\n"
		   "{ -1, 1, 1, G_BOX, 0, 0, {(void*)0x71L}, 0, 0, %hd, %hd },\r\n"
		   "{ 0, -1, -1, G_IMAGE, LASTOB, 0, {(void*)&bitblk}, 0, 0, %hd, %hd } };\r\n\r\n",
			bw*8,bh/2,bw*8,bh/2);

	
	exit(0);
}