/*
//
// Copyright (C) 2009, 2010, 2011, 2012 Jean-Francois DEL NERO
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

#include <string.h>

#include "filelist.h"
//#include "atari_hw.h"
#include "fat_opts.h"
#include "fat_access.h"
#include "conf.h"
#include "fectrl.h"
#include "fat32/fat_filelib.h"
#include "gui_utils.h"			// used by gui_more_busy
#include "screen.h"
#include "screen_layout.h"

static struct fs_dir_list_status _file_list_status;
static UWORD _FilelistPages_tab[512];
static struct fs_dir_ent _dir_entry;
static char * _filter=0;
static UWORD _nbPages = 0xffff;

extern UWORD gfl_cachedPage[];
extern unsigned char *currentPath[4*256];


int dir_filter(struct fs_dir_ent *dir_entry)
{
	char tmp[FATFS_MAX_LONG_FILENAME];
	if (0 != _filter[0] && !(dir_entry->is_dir)) {
		// only filter when filter is set. Don't filter dirs
		strcpy(tmp, dir_entry->filename);
		strlwr(tmp);

		if(!strstr(tmp, _filter))
		{
			return FALSE;
		}
	}
	return TRUE;
}




UWORD dir_getFirstFileForPage(UWORD page)
{
	return _FilelistPages_tab[page];
}

/**
 * Find the asked entry
 * @returns page number
 */
#if(0)
 UWORD dir_getPageForEntry(UWORD askedEntry)
{
	UWORD runPage;
	UWORD entry;

	for (runPage=_nbPages-1; runPage; runPage--) {
		entry = _FilelistPages_tab[runPage];
		if (entry <= askedEntry) {
			break;
		}
	}
	return runPage;
}
#endif

#if(0)
int dir_getFilesForPage(UWORD page, UWORD *FilelistCurrentPage_tab)
{
	UWORD i, currentFile;

	gui_more_busy();
	currentFile = _FilelistPages_tab[page & 0x1ff];
	if (0xffff == currentFile) {
		gui_less_busy();
		return FALSE;
	}

	// clear the page
	for(i=0; i<32; i++) {
		FilelistCurrentPage_tab[i] = 0xffff;
	}


	// beginning with currentFile, get the filename, and apply the filter
	for(i=0; i<SLA_FILES_PER_PAGE; currentFile++) {
		if ( TRUE != fli_getDirEntryMSB(currentFile, &_dir_entry) ) {
			break;
		}
		if (dir_filter(&_dir_entry)) {
			// file will be shown
			FilelistCurrentPage_tab[i] = currentFile;
			i++;
		}
	}

	gui_less_busy();
	return TRUE;
}
#endif


/**
 * @returns integer number of pages
 */
UWORD dir_getNbPages()
{
	return _nbPages;
}


/**
 * Filter the files and fill an array with the first file index
 * for each page. Also precache the first page
 */
void dir_paginateAndPrefillCurrentPage()
{
	UWORD currentPage;
	UWORD currentFile;
	UBYTE currentFileInPage;

	gui_more_busy();

	// sort the directory
	fli_sort();

	// erase all pages
	memset(_FilelistPages_tab, 0xff, 2*512);

	// erase current page
	memset(&gfl_cachedPage[0], 0xff, 2*MAXFILESPERPAGE);

	currentPage       = 0xffff;
	currentFile       = 0;
	currentFileInPage = SLA_FILES_PER_PAGE;

	//unsigned long time = get_hz200();

	while(fli_getDirEntryMSB(currentFile, &_dir_entry)) {
		if (dir_filter(&_dir_entry)) {
			// file will be shown
			if (currentFileInPage >= SLA_FILES_PER_PAGE) {
				// add a page
				currentPage++;
				currentFileInPage = 0;
				// store the first file of the page
				_FilelistPages_tab[currentPage] = currentFile;
			}
			if (0 == currentPage) {
				gfl_cachedPage[currentFileInPage] = currentFile;
			}
			currentFileInPage++;
		}

		currentFile++;
	}

	//time = get_hz200() - time;
	//time = time / 2;
	//gui_printf(2,0,0, "dir_paginate(): %ld seconds/100", time);

	_nbPages = currentPage+1;
	gui_less_busy();
}


char * dir_getFilter()
{
	return _filter;
}

void dir_setFilter(char *filter)
{
	_filter = filter;
}



int dir_scan()
{
	UWORD nbFiles;

	gui_more_busy();

	// reset the file list
	fli_clear();

	// get all the files in the dir
	nbFiles = 0;
	fl_list_opendir((char *)currentPath, &_file_list_status);

	while( fl_list_readdir(&_file_list_status, &_dir_entry) ) {
		fli_push(&_dir_entry);
		nbFiles++;
	}

	if (0 == nbFiles) {
		fatal("Cannot read directory");
	}

	gui_less_busy();
	return nbFiles;
}



