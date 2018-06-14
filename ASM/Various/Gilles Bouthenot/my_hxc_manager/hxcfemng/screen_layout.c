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


#include "screen.h"
#include "screen_layout.h" // because we need some defines

//
// public variables:
//

unsigned short SLA_SLOT_Y_POS;
unsigned char  SLA_FILES_PER_PAGE;			/* 19-5 //19 -240 */
unsigned short SLA_LINE_CHARS;				/* number of 8x8 chars per line */
unsigned short SLA_BOX_Y_POS;				/* box y position               */
unsigned short SLA_STATUSL_Y_POS;			/* status line y position       */


//
// private variables:
//

// (none)


void sla_enterModule()
{
	SLA_SLOT_Y_POS     = SCR_YRESOL-(48+(3*8));
	SLA_FILES_PER_PAGE = ((SCR_YRESOL-48-24-2) - (SLA_FILELIST_Y_POS+2)) / 8;
	SLA_STATUSL_Y_POS  = SCR_YRESOL-(48+20)+24;
	SLA_BOX_Y_POS      = SCR_YRESOL/2-40;
	SLA_LINE_CHARS     = SCR_XRESOL/8;
}

