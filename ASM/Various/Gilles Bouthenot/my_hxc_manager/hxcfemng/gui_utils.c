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

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <mint/osbind.h>
#include <mint/linea.h>
#include "libc/snprintf/snprintf.h"

#include <time.h>
#include <stdarg.h>

#include "graphx/data_bmp_hxc2001logo_bmp.h"
#include "graphx/data_bmp_font8x8_bmp.h"
#include "graphx/data_bmp_sdhxcfelogo_bmp.h"

#include "atari_hw.h"
#include "assembly.h"
#include "conf.h"
#include "screen.h"
#include "screen_layout.h"


static UWORD  _business = 0;

unsigned char _scrBackupIsUsed;




void _display_sprite(unsigned char * membuffer, bmaptype * sprite,unsigned short x, unsigned short y)
{
	unsigned short i,j,k;
	unsigned short *ptr_src;
	unsigned short *ptr_dst;
	ULONG          base_offset, l;

	ptr_dst=(unsigned short*)membuffer;
	ptr_src=(unsigned short*)&sprite->data[0];

	k=0;

	base_offset=( ((ULONG) y*SCR_LINEBYTES) + ((x>>4)<<SCR_PLANESALIGNDEC) )/2;
	for(j=0;j<(sprite->Ysize);j++)
	{
		l = base_offset;
		for (i=0; i<(sprite->Xsize>>4); i++)
		{
			ptr_dst[l]=ptr_src[k];
			l += SCR_NBPLANES;
			k++;
		}
		base_offset += SCR_LINEWORDS;
	}
}


void gui_print_char8x8(unsigned short x, unsigned short y,unsigned char c)
{
	bmaptype * font;
	unsigned short j,k;
	unsigned char *ptr_src;
	unsigned char *ptr_dst;
	ULONG base_offset;

	font = bitmap_font8x8_bmp;

	ptr_dst = scr_addr;
	ptr_src=(unsigned char*)&font->data[0];

	k=((c>>4)*(8*8*2))+(c&0xF);

	base_offset=((ULONG) y*SCR_LINEBYTES) + ((x>>4)<<SCR_PLANESALIGNDEC) + ((x&8)==8);
	// in a 16-pixel chunk, there are 2 8-pixel chars, hence the x&8==8

	for(j=0;j<8;j++)
	{
		ptr_dst[base_offset] = ptr_src[k];
		k=k+(16);
		base_offset += SCR_LINEBYTES;
	}
}


/**
 * print a string. Handle \n. The next line start at the same x_pos
 * @return UWORD last y_pos
 */
unsigned short gui_print_str(char * buf,unsigned short x_pos,unsigned short y_pos, char fHandleCR)
{
	unsigned short x;
	char c;

	x = x_pos;
	while( (c=*(buf++)) && x<=(SCR_XRESOL-8) )
	{
		if ('\n'==c && fHandleCR) {
			x = x_pos;
			y_pos += 8;
		} else {
			gui_print_char8x8(x, y_pos, c);
			x += 8;
		}
	}

	return y_pos;
}

/**
 * printf a string.
 * @param int    mode  0:normal(use x,y)  1:align=center (use y)  2:align=right (use y)
 * @param int    x_pos  (in pixel)
 * @param int    y_pos  (in pixel) of the top of the char
 * @param string chaine
 * @param ...
 */
void gui_printf(unsigned char mode,unsigned short x_pos,unsigned short y_pos,char * chaine, ...)
{
	char temp_buffer[1024];

	va_list marker;
	va_start( marker, chaine );

	vsnprintf(temp_buffer,1024,chaine,marker);
	switch(mode)
	{
		case 0:
			gui_print_str(temp_buffer,x_pos,y_pos, 0);
		break;
		case 1:
			gui_print_str(temp_buffer,(SCR_XRESOL-(strlen(temp_buffer)*8))/2,y_pos, 0);
		break;
		case 2:
			gui_print_str(temp_buffer,(SCR_XRESOL-(strlen(temp_buffer)*8)),y_pos, 0);
		break;
	}

	va_end( marker );
}


/**
 * Draw / remove a horizontal line
 * (only the first bitplane)
 */
void gui_h_line(unsigned short y_pos, unsigned short val)
{
	UWORD * ptr_dst;
	UWORD i;

	ptr_dst=(UWORD *) scr_addr;
	ptr_dst += (ULONG) SCR_LINEWORDS * y_pos;

	for(i=0; i<SCR_LINEWORDS; i+=SCR_NBPLANES)
	{
		*(ptr_dst) = val;
		ptr_dst += SCR_NBPLANES;
	}

}

#if(0)
void gui_box(unsigned short x_p1,unsigned short y_p1,unsigned short x_p2,unsigned short y_p2,unsigned short fillval,unsigned char fill)
{
	unsigned short *ptr_dst;
	unsigned short i,j,ptroffset,x_size;


	ptr_dst=(unsigned short*)scr_addr;

	if(highresmode)
	{
		x_size=((x_p2-x_p1)/16);

		for(j=0;j<(y_p2-y_p1);j++)
		{
			for(i=0;i<x_size;i++)
			{
				ptr_dst[ptroffset+i]=fillval;
			}
			ptroffset=SCR_LINEWORDS* (y_p1+j);
		}

	}
	else
	{
		x_size=((x_p2-x_p1)/16)*2;

		for(j=0;j<(y_p2-y_p1);j++)
		{
			for(i=0;i<x_size;i++)
			{
				ptr_dst[ptroffset+i]=fillval;
			}
			ptroffset=SCR_LINEWORDS* (y_p1+j);
		}
	}
}
#endif




/**
 * Clear the screen (all bitplanes)
 * @param integer add number of additional lines to clear. Allow to clear the status bar
 */
void gui_clear_list(unsigned char add)
{
	unsigned char * ptr_dst;

	ptr_dst =  (UBYTE *)scr_addr;
	ptr_dst += (ULONG) SCR_LINEBYTES * SLA_FILELIST_Y_POS;
	//memset(ptr_dst, 0, (ULONG) ((UWORD)(SCR_LINEBYTES)*(UWORD)((SLA_FILES_PER_PAGE+add)<<3)));
	memsetword(ptr_dst, 0, (ULONG) (UWORD)(SCR_LINEBYTES)*(UWORD)((SLA_FILES_PER_PAGE+add)<<2));

}



/**
 * invert all planes on a line of text of the file selector
 * @param integer linenumber number of the line of text to invert
 */
void gui_invert_line(unsigned short linenumber)
{
	unsigned short i;
	unsigned char j;
	unsigned char  *ptr_dst;
	unsigned short *ptr_dst2;

	ptr_dst   = scr_addr;
	ptr_dst  += (ULONG) SCR_LINEBYTES * (SLA_FILELIST_Y_POS + (linenumber<<3));

	ptr_dst2 = (unsigned short *)ptr_dst;

	for(j=0;j<8;j++)
	{
		for(i=0; i<SCR_LINEWORDS; i+=1)
		{
			//*ptr_dst = (*ptr_dst ^ 0xFFFF);
			*ptr_dst2 = (*ptr_dst2 ^ 0xFFFF);
			ptr_dst2++;
		}
	}
}

void gui_restore_box()
{
	if (_scrBackupIsUsed) {
		if (1 == _scrBackupIsUsed) {
			memcpy(&scr_addr[(unsigned long) SCR_LINEBYTES*SLA_BOX_Y_POS], scr_buffer_backup, 3*8*SCR_LINEBYTES);
		}
		_scrBackupIsUsed--;
	}
}

/**
 * Print a line of text in the center of the screen, save the background to screen_backup_buffer
 */
void gui_printf_box(char * chaine, ...)
{
	char temp_buffer[1024];
	int str_size;
	unsigned short i, xpos, xpos_ori;

	if (!_scrBackupIsUsed) {
		memcpy(scr_buffer_backup,&scr_addr[(unsigned long) SCR_LINEBYTES*SLA_BOX_Y_POS], 3*8*SCR_LINEBYTES);
	}
	_scrBackupIsUsed++;

	va_list marker;
	va_start( marker, chaine );

	vsnprintf(temp_buffer,1024,chaine,marker);

	// compute box width
	str_size=strlen(temp_buffer) + 4;

	xpos_ori = (SCR_XRESOL-(str_size*8))/2;
	xpos = xpos_ori;

	gui_print_char8x8(xpos, SLA_BOX_Y_POS,    2);				// top left
	gui_print_char8x8(xpos, SLA_BOX_Y_POS+8,  6);				// left
	gui_print_char8x8(xpos, SLA_BOX_Y_POS+16, 4);				// bottom left
	xpos += 8;

	for(i=1;i< str_size-1;i++)
	{
		gui_print_char8x8(xpos,     SLA_BOX_Y_POS,    8);		// top line
		gui_print_char8x8(xpos,     SLA_BOX_Y_POS+8,  ' ');		// clear the main line
		gui_print_char8x8(xpos,     SLA_BOX_Y_POS+16, 9);		// bottom line
		xpos += 8;
	}

	gui_print_char8x8(xpos, SLA_BOX_Y_POS,    3);				// top right
	gui_print_char8x8(xpos, SLA_BOX_Y_POS+8,  7);				// right
	gui_print_char8x8(xpos, SLA_BOX_Y_POS+16, 5);				// bottom right

	gui_print_str(temp_buffer, xpos_ori + 2*8, SLA_BOX_Y_POS+8, 0);	// text

	va_end( marker );
}




void gui_display_statusl(unsigned char mode, unsigned char clear, char * text, ...)
{
	char temp_buffer[256];

	va_list marker;
	va_start( marker, text );

	if (clear) {
		memsetword(scr_addr + SLA_STATUSL_Y_POS*(SCR_LINEWORDS<<1), 0, SCR_LINEWORDS<<3);
	}

	vsnprintf(temp_buffer,256,text,marker);
	gui_printf(mode, 0, SLA_STATUSL_Y_POS, temp_buffer);
	va_end(marker);
}

void gui_redraw_statusl()
{
	// line just above the statusbar
	gui_h_line(SCR_YRESOL-48-24-2,0xFFFF) ;

	// line just under the statusbar
	gui_h_line(SCR_YRESOL-48+2,0xFFFF) ;

	gui_display_statusl(1, 0, ">>>Press HELP key for the function key list<<<");
}


void gui_more_busy()
{
	_business++;
	gui_printf(0,8*(SLA_LINE_CHARS-1),0,"%c",23);
}
void gui_less_busy()
{
	if (_business) {
		_business--;
		if (!_business) {
			gui_printf(0,8*(SLA_LINE_CHARS-1),0," ",23);
		}
	}
}


int gui_display_credits(int i)
{
	int j;
	char *strings[] = {
		"SDCard HxC Floppy Emulator file selector for Atari ST",
		"(c) 2006-2012 Jean-Francois DEL NERO (HxC2001) / Gilles Bouthenot",
		"Official website: http://www.hxc2001.com/",
		"Email: hxc2001@hxc2001.com"
	};

	for (j=0; j<4; i++, j++) {
		gui_printf(1,0,SLA_HELP_Y_POS+(i*8), strings[j]);
	}

	gui_printf(1,0,SLA_HELP_Y_POS+(i*8), "V%s - %s",VERSIONCODE,DATECODE);
	i++;

	return i;
}




void gui_display_welcome()
{
	int i;

	gui_printf(1,0,0,"SDCard HxC Floppy Emulator Manager for Atari ST");
	gui_h_line(8,0xFFFF) ;

	i=0;
	i = gui_display_credits(i);

	gui_redraw_statusl();

	// line just above the logos
	gui_h_line(SCR_YRESOL-34,0xFFFF) ;

	gui_printf(0,0,SCR_YRESOL-(8*1),"Ver %s",VERSIONCODE);
	_display_sprite(scr_addr, bitmap_sdhxcfelogo_bmp,(SCR_XRESOL-bitmap_sdhxcfelogo_bmp->Xsize)/2, (SCR_YRESOL-bitmap_sdhxcfelogo_bmp->Ysize));
	_display_sprite(scr_addr, bitmap_hxc2001logo_bmp,(SCR_XRESOL-bitmap_hxc2001logo_bmp->Xsize), (SCR_YRESOL-bitmap_hxc2001logo_bmp->Ysize));
}



void gui_enterModule()
{
	_scrBackupIsUsed = 0;
}
