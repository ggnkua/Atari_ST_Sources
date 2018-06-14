#ifndef __SCREEN_H__
#define __SCREEN_H__
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



extern unsigned short SCR_YRESOL;
unsigned char * scr_addr;
unsigned char * scr_buffer_backup;

unsigned short SCR_YRESOL;              /* screen X resolution (pixels) */
unsigned short SCR_XRESOL;              /* screen Y resolution (pixels) */
unsigned short SCR_LINEBYTES;           /* number of bytes per line     */
unsigned short SCR_LINEWORDS;           /* number of words per line     */
unsigned short SCR_NBPLANES;            /* number of planes (1:2 colors */
                                        /*  4:16 colors, 8: 256 colors) */
unsigned short SCR_CHUNKWORDS;          /* number of words for a 16-    */
                                        /* pixel chunk =2*SCR_NBPLANES  */
unsigned short SCR_PLANESALIGNDEC;      /* number of left shifts to     */
                                        /* transform nbChucks to Bytes  */



void scr_enterModule();
void scr_leaveModule();
unsigned char scr_setColorScheme(unsigned char color);

#endif
