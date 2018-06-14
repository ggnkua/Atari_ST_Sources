#ifndef __SCREEN_LAYOUT_H__
#define __SCREEN_LAYOUT_H__

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


extern unsigned short SLA_SLOT_Y_POS;				/* SCR_YRESOL-(48+(3*8)) */
extern unsigned char  SLA_FILES_PER_PAGE;			/* 19-5 //19 -240 */
extern unsigned short SLA_LINE_CHARS;				/* number of 8x8 chars per line */
extern unsigned short SLA_BOX_Y_POS;				/* box y position               */
extern unsigned short SLA_STATUSL_Y_POS;			/* status line y position       */

#define SLA_FILELIST_Y_POS 12
#define SLA_HELP_Y_POS 12
#define SLA_VIEWER_Y_POS 12
#define SLA_CURDIR_X_POS  30*8
#define SLA_CURDIR_Y_POS  SLA_SLOT_Y_POS
#define SLA_PAGE_X_POS    640-17*8
#define SLA_PAGE_Y_POS    SLA_CURDIR_Y_POS
#define SLA_FILTER_X_POS  30*8
#define SLA_FILTER_Y_POS  SLA_CURDIR_Y_POS+16

void sla_enterModule();

#endif
