#ifndef __GUI_UTILS_H__
#define __GUI_UTILS_H__
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

void gui_printf(unsigned char mode,unsigned short x_pos,unsigned short y_pos,char * chaine, ...);
void gui_printf_box(char * chaine, ...);
void gui_print_char8x8(unsigned short x, unsigned short y,unsigned char c);
unsigned short gui_print_str(char * buf,unsigned short x_pos,unsigned short y_pos, char fHandleCR);
void gui_restore_box();
void gui_more_busy();
void gui_less_busy();

void gui_h_line(unsigned short y_pos, unsigned short val);
void gui_invert_line(unsigned short y_pos);
void gui_clear_list(unsigned char add);
void gui_box(unsigned short x_p1,unsigned short y_p1,unsigned short x_p2,unsigned short y_p2,unsigned short fillval,unsigned char fill);
void gui_display_statusl(unsigned char mode, unsigned char clear, char * text, ...);
void gui_redraw_statusl();
void gui_display_welcome();
int  gui_display_credits();
void gui_enterModule();

#endif
