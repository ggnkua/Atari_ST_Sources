/*
//
// Copyright (C) 2009, 2010, 2011 Jean-Francois DEL NERO
//
// This file is part of the HxCFloppyEmulator file selector.
//
// HxCFloppyEmulator file selector may be used and distributed without restriction
// provided that this copyright statement is not removed from the file and that any
// derivative work contains the original copyright notice and the associated
// disclaimer.
//
// HxCFloppyEmulator file selector is free software; you can redistribute it
// and/or modify  it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// HxCFloppyEmulator file selector is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
//   See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with HxCFloppyEmulator file selector; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//
*/

#include <stdlib.h>

#include <mint/osbind.h>
#include <mint/linea.h>

#include "atari_hw.h"
#include "assembly.h"


//
// public variables:
//

unsigned char * scr_addr;
unsigned char * scr_buffer_backup;

unsigned short SCR_YRESOL;				/* screen X resolution (pixels) */
unsigned short SCR_XRESOL;				/* screen Y resolution (pixels) */
unsigned short SCR_LINEBYTES;			/* number of bytes per line     */
unsigned short SCR_LINEWORDS;			/* number of words per line     */
unsigned short SCR_NBPLANES;			/* number of planes (1:2 colors */
										/*  4:16 colors, 8: 256 colors) */
unsigned short SCR_CHUNKWORDS;			/* number of words for a 16-    */
										/* pixel chunk =2*SCR_NBPLANES  */
unsigned short SCR_PLANESALIGNDEC;		/* number of left shifts to     */
										/* transform nbChucks to Bytes  */


//
// private variables:
//

unsigned char _colorscheme;
static short  _oldrez = 0xffff;

__LINEA *__aline;
__FONT  **__fonts;
short  (**__funcs) (void);


static unsigned short _colortable[] = {
								0x300, 0xEEE, 0x00f, 0xee4, // b ok blanc sur rouge foncé (nice)
								0x777, 0x300, 0x00f, 0x5f5, // w noir sur blanc, select vert (nice)
								0x002, 0xeee, 0x226, 0x567, // b ok blanc sur bleu nuit (nice)
								0xFFF, 0x343, 0x00f, 0x0f0, // w ok vert sombre sur blanc, select vert
								0x000, 0x00F, 0x222, 0xdd1, // b ok bleu sur noir
								0x000, 0xFFF, 0x00f, 0x3f3, // b ok blanc sur noir, select vert
								0x303, 0xFFF, 0x00f, 0xee4, // w ok blanc sur mauve
								0x030, 0xFFF, 0x00f, 0x0f0, // b ok vert
								0x999, 0x000, 0x999, 0x333, // w ok gris sombre
								0x330, 0xFFF, 0x77f, 0xcc0, // b ok caca d'oie
								0xF33, 0xFFF, 0x777, 0xe11, // w ok blanc sur rose et rouge
								0x000, 0xF00, 0x003, 0xd00, // b ok rouge sur noir
								0xF0F, 0xFFF, 0x000, 0x44f, // w ok violet vif
								0x000, 0x0E0, 0x00f, 0x0f0, // b ok vert sur noir
								0xFFF, 0x0F0, 0x4c4, 0x0f0, // w ok vert sur blanc
								0x004, 0xFFF, 0x00e, 0x5f5, // b ok blanc sur bleu marine

								0x036, 0xFFF, 0x00f, 0x0f0, // b
								0x444, 0x037, 0x00f, 0x0f0, // b
								0x000, 0xFF0, 0x00f, 0x0f0, // b
								0x404, 0x743, 0x00f, 0x0f0, // b
								0xFFF, 0x700, 0x00f, 0x0f0, // w
								0x000, 0x222, 0x00f, 0x0c0, // b
								0x000, 0x333, 0x00f, 0x0d0, // b
								0x000, 0x444, 0x00f, 0x0e0, // b
								0x000, 0x555, 0x00f, 0x0f0, // b
								0x000, 0x666, 0x00f, 0x0f0, // b
								0x000, 0x777, 0x00f, 0x0f0, // b
								0x222, 0x000, 0x00f, 0x0c0, // b
								0x333, 0x000, 0x00f, 0x0d0, // w
								0x444, 0x000, 0x00f, 0x0e0, // b
								0x555, 0x000, 0x00f, 0x0f0, // w
								0x666, 0x000, 0x00f, 0x0f0, // b

};



/**
 * Set the palette
 * @param int colorm the number of the palette, -1 to cycle, -2 to restore
 * @return int the new palette number
 */
unsigned char scr_setColorScheme(unsigned char colorm)
{
	unsigned short * palette;
	short tmpcolor;
	int i,j;
	int nbcols;
	static UWORD initialpalette[4] = {0xffff, 0xffff, 0xffff, 0xffff};

	if (0xff == colorm) {
		// cycle
		colorm = _colorscheme+1;
		if ( colorm >= (sizeof(_colortable))>>3 ) {
			// reset to first
			colorm = 0;
		}
	}
	if (0xfe == colorm) {
		// restore
		palette = initialpalette;
	} else {
		_colorscheme = colorm;
		palette = &_colortable[_colorscheme<<2];
	}
	nbcols = 2<<(SCR_NBPLANES-1);

	for (i=0; i<4 && i<nbcols; i++) {
		j = i;
		if (i>=2) {
			// the first two colors are always pal[0] and pal[1]
			// the last two colors may be pal[2] and pal[3] in 2 planes, or pal[14] and pal[15] in 4 planes
			j = nbcols - 4 + i;
		}
		tmpcolor = setColor(j, palette[i]);
		if (0xffff == initialpalette[i]) {
			initialpalette[i] = tmpcolor;
		}
	}

	return _colorscheme;
}




void scr_leaveModule()
{
	scr_setColorScheme(0xfe);

	// Line-A : Showmouse
	linea9();

	if (0xffff != _oldrez) {
		Setscreen((unsigned char *) -1, (unsigned char *) -1, _oldrez );
	}

	free(scr_buffer_backup);
}




void scr_enterModule()
{
	unsigned short k,i;

	linea0();

	// Line-A : Hidemouse
	// do not do : __asm__("dc.w 0xa00a"); (it clobbers registry)
	lineaa();

	if (V_X_MAX < 640) {
		/*Blitmode(1) */;
		_oldrez = Getrez();
		Setscreen((unsigned char *) -1, (unsigned char *) -1, 1 );
	}

	SCR_XRESOL = V_X_MAX;
	SCR_YRESOL = V_Y_MAX;
	SCR_LINEBYTES    = V_BYTES_LIN;
	SCR_LINEWORDS    = V_BYTES_LIN/2;
	SCR_NBPLANES     = __aline->_VPLANES;
	SCR_CHUNKWORDS   = SCR_NBPLANES<<1;

	for (i=SCR_NBPLANES, k=0; i!=0; i>>=1, k++);
	SCR_PLANESALIGNDEC = k;

	// get screen address
	// malloc a temp buffer used for saving screen data under printf_box
	scr_addr = (unsigned char *) Physbase();
	scr_buffer_backup=(unsigned char*)malloc(3*8*SCR_LINEBYTES);

	// clear the screen
	memsetword(scr_addr, 0, (ULONG) SCR_YRESOL * SCR_LINEWORDS);

	scr_setColorScheme(0);
}

