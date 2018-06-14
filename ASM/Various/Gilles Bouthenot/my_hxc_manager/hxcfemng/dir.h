#ifndef __DIR_H__
#define __DIR_H__

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

#include "atari_hw.h"
#include "fat_access.h"

void dir_paginateAndPrefillCurrentPage();
UWORD dir_getNbPages();
UWORD dir_getFirstFileForPage(UWORD page);
UWORD dir_getPageForEntry(UWORD askedEntry);
int dir_getFilesForPage(UWORD page, UWORD *FilelistCurrentPage_tab);
void dir_setFilter(char *filter);
char * dir_getFilter();
int dir_filter(struct fs_dir_ent *dir_entry);
int dir_scan();

#endif
