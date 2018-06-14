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


#include "gui_utils.h"
#include "cfg_file.h"
#include "hxcfeda.h"
#include "fat_access.h"
#include "dir.h"
#include "filelist.h"


#include "atari_hw.h"

#include "conf.h"
#include "screen_layout.h"




//
// Static variables
//
static UWORD _currentPage = 0xffff;	// current shown page
#if (0)
static UWORD _selectorToEntry = 0xffff;
#endif
static signed short _invertedLine;
static UWORD _nbPages;


// exported variables:
UWORD gfl_cachedPageNumber = 0xffff;
UWORD gfl_selectorPos;
UBYTE gfl_isLastPage;
DirectoryEntry   _dirEntLSB;
DirectoryEntry * gfl_dirEntLSB_ptr = &_dirEntLSB;
UWORD gfl_cachedPage[MAXFILESPERPAGE];	// the cache




#if(0)
UWORD gfl_getSelectorPos()
{
	return gfl_selectorPos;
}
#endif

#if(0)
UWORD gfl_getSelectorEntry()
{
	return gfl_cachedPage[gfl_selectorPos];
}
#endif

#if(0)
void gfl_jumpToFile(UWORD askedFile)
{
	_currentPage = dir_getPageForEntry(askedFile);
	_selectorToEntry = askedFile;
}
#endif


void gfl_setCachedPage(UWORD newpage)
{
	UWORD curFile;
	int res;
	UWORD i;
	struct fs_dir_ent dir_entry;

	// when the page was prefilled, isLastPage was not filled
	gfl_isLastPage = ((newpage+1) == _nbPages);

	if (gfl_cachedPageNumber == newpage) {
		return;
	}

	// start at the first file of the directory
	curFile = dir_getFirstFileForPage(newpage);

	// reset the files for this page
	memset(&gfl_cachedPage[0], 0xff, 2*MAXFILESPERPAGE);

	res = fli_getDirEntryMSB(curFile, &dir_entry);

	for (i=0; i<SLA_FILES_PER_PAGE && res; ) {
		// store the file in the cache
		gfl_cachedPage[i] = curFile;
		i++;

		do {
			curFile++;
			res = fli_getDirEntryMSB(curFile, &dir_entry);
		} while (res && !dir_filter(&dir_entry));
	}

	// set the new page
	gfl_cachedPageNumber = newpage;
	_currentPage         = newpage;
}


void gfl_showFilesForPage(UBYTE fRepaginate, UBYTE fForceRedrawAll)
{
	static UWORD _oldPage = 0xffff;		// the page displayed
	UWORD curFile;
	UWORD i;
	UWORD y_pos;
	UBYTE fForceRedraw=0;
	struct fs_dir_ent dir_entry;

	if (fRepaginate) {
		dir_paginateAndPrefillCurrentPage();
		_nbPages = dir_getNbPages();
		gfl_selectorPos = 0;
		_currentPage = 0;
		fForceRedraw = 1;
	}

	if ( (_oldPage != _currentPage) || fForceRedraw || fForceRedrawAll )
	{
		if (fForceRedrawAll) {
			gui_clear_list(5);
		} else {
			gui_clear_list(0);
		}

		_oldPage = _currentPage;
		gfl_setCachedPage(_currentPage);

		_invertedLine = -1;	// the screen has been clear: no need to de-invert the line

		// page number
		gui_printf(0, SLA_PAGE_X_POS, SLA_PAGE_Y_POS, "Page %d of %d      ", _currentPage+1, _nbPages);

		// filter
		gui_printf(0, SLA_FILTER_X_POS, SLA_FILTER_Y_POS,"Filter (F1): [%s]", dir_getFilter());

		y_pos=SLA_FILELIST_Y_POS;

		for (i=0; i<SLA_FILES_PER_PAGE; i++)
		{
			curFile = gfl_cachedPage[i];
			if (!fli_getDirEntryMSB(curFile, &dir_entry)) {
				break;
			}

			gui_printf(0,0,y_pos," %c%s", (dir_entry.is_dir)?(10):(' '), dir_entry.filename);
			y_pos=y_pos+8;
		}

		_invertedLine = -1;
	} // if ( (_oldPage != _currentPage) || fForceRedraw || fForceRedrawAll )


#if (0)
	// a selector has been specified, so select the asked file
	if (0xffff != _selectorToEntry)
	{
		// the page just has been shown, so it is now cached
		for (i=0; i<SLA_FILES_PER_PAGE; i++)
		{
			curFile = gfl_cachedPage[i];
			if (curFile >= _selectorToEntry) {
				// this is the asked entry (or >, to handle filter)
				gfl_selectorPos = i;
				break;
			}
		}
		_selectorToEntry = 0xffff;
	}
#endif


	if (_invertedLine != gfl_selectorPos) {
		// reset the inverted line
		if (_invertedLine>=0) {
			gui_invert_line(_invertedLine);
			gui_printf(0, 0, SLA_FILELIST_Y_POS+(_invertedLine*8), " ");
		}

		// set the inverted line (only if it has changed)
		_invertedLine = gfl_selectorPos;
		gui_printf(0, 0, SLA_FILELIST_Y_POS+(gfl_selectorPos*8), ">");
		gui_invert_line(gfl_selectorPos);
	}

	fli_getDirEntryLSB(gfl_cachedPage[gfl_selectorPos], gfl_dirEntLSB_ptr);
}




long gfl_mainloop()
{
	long key, key_ret;
	key_ret = 0;
	key = get_char();

	switch((UWORD) (key>>16))
	{
		case 0x48: /* UP */
			if (gfl_selectorPos > 0) {
				gfl_selectorPos--;
				break;
			}

			// top line
			if (0==_currentPage) {
				// first page: stuck
				break;
			}

			// top line not on the first page
			gfl_selectorPos=SLA_FILES_PER_PAGE-1;
			_currentPage--;
			break;

		case 0x50: /* Down */
			if ( (gfl_selectorPos+1)==SLA_FILES_PER_PAGE ) {
				// last line of display
				if (!gfl_isLastPage) {
					_currentPage++;
					gfl_selectorPos = 0;
				}
				break;
			} else if (0xffff != gfl_cachedPage[gfl_selectorPos+1]) {
				// next file exist: allow down
				gfl_selectorPos++;
			}
			break;

		case 0x0150: /* Shift Down : go next page */
		case 0x0250:
			/* TODO: better handling */
			if ( (_nbPages > 1) && (!gfl_isLastPage) ) {
				_currentPage++;
				gfl_selectorPos=0;
			}
			break;

		case 0x148: /* Shift Up: go previous page */
		case 0x248:
			if (_currentPage) {
				_currentPage--;
			}
			gfl_selectorPos=0;
			break;

		case 0x448:	/* Ctrl Up : go to first page, first file */
			_currentPage=0;
			gfl_selectorPos=0;
			break;

		case 0x450: /* Ctrl Down: go to last file */
			/* TODO : currently it only go to the first file of the last page ! */
			_currentPage = _nbPages - 1;
			gfl_selectorPos=0;
			break;


		default:
			//key not processed: return it (otherwise, return 0)
			key_ret = key;
	}

	return key_ret;
}
