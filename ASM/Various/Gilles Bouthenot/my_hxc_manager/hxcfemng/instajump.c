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


// #define _IJ_DEBUG



#include <string.h>
#include <ctype.h>		// tolower()

#include "atari_hw.h"
#include "hxcfeda.h"

#ifdef _IJ_DEBUG
	#include "gui_utils.h" // DEBUG ONLY !
	static int debug_line=0;
#endif


//#include "cfg_file.h"

//#include "dir.h"
#include "filelist.h"
#include "gui_filelist.h"


#include "screen_layout.h"



// constants
#define _IJ_TIMEOUT 2000    // maximum time between two keystrokes (in ms)
#define _IJ_MAXLEN  15      // maximum number of chars

//
// Externs
//
extern UWORD gfl_selectorPos;
extern UWORD gfl_cachedPageNumber;
extern UWORD gfl_cachedPage[];
extern UBYTE gfl_isLastPage;


// static variables:
static unsigned long _lastTime = 0;
static char _searchString[_IJ_MAXLEN+1];


void ij_clear()
{
	_lastTime = 0;
}



UBYTE _search(UWORD pagenumber, UWORD selectorpos)
{
	int cmp, len;
	UWORD curFile;
	struct fs_dir_ent dir_entry;

	gfl_setCachedPage(pagenumber);
	len      = strlen(_searchString);

	#ifdef _IJ_DEBUG
		gui_printf(0, 0, 8*(debug_line++), "searching for %s from position pagenumber %d, %d", _searchString, pagenumber, selectorpos);
	#endif

	while(1) {
		curFile = gfl_cachedPage[selectorpos];
		if (!fli_getDirEntryMSB(curFile, &dir_entry)) {
			break;
		}

		strlwr(dir_entry.filename);
		cmp = strncmp(dir_entry.filename, _searchString, len);

		if (0 == cmp) {
			// found
			#ifdef _IJ_DEBUG
				gui_printf(0, 0, 8*(debug_line++), "Found at page %d, %d", pagenumber, selectorpos);
				get_char();
			#endif
			// gfl_setCachedPage(pagenumber); (not needed)
			gfl_selectorPos = selectorpos;

			return 1;
		}

		selectorpos++;
		if (selectorpos >= SLA_FILES_PER_PAGE) {
			if (gfl_isLastPage) {
				break;
			}
			selectorpos = 0;
			pagenumber++;
			gfl_setCachedPage(pagenumber);
		}
	}

	return 0;
}



/**
 * If a key was stroke within a short time, add that key to the current search
 * otherwise, initiate an other instajump.
 */
void ij_keyEvent(signed char key)
{
	unsigned long time;
	int len;
	UWORD oldPageNumber, oldSelectorPos;
	UWORD res;

	len = strlen(_searchString);
	time = get_hz200();
	if ( (time - _lastTime) < (_IJ_TIMEOUT / 5)  ) {

	} else {
		// init a new search
		len = 0;
		#ifdef _IJ_DEBUG
			debug_line = 6;
		#endif
	}

	if ( (len < _IJ_MAXLEN)) {
		_searchString[len++] = tolower(key);	// lower case
		_searchString[len]   = '\000';
	}

	oldPageNumber  = gfl_cachedPageNumber;
	oldSelectorPos = gfl_selectorPos;

	res = _search(oldPageNumber, oldSelectorPos);

	if (!res && len>1) {
		// remove the last character and restart the search at the next file
		_searchString[len-1] = '\000';
		if (oldSelectorPos+1 >= SLA_FILES_PER_PAGE) {
			res = _search(oldPageNumber+1, 0);
		} else {
			res = _search(oldPageNumber, oldSelectorPos+1);
		}
	}
	if (!res) {
		// still not found
		#ifdef _IJ_DEBUG
			gui_printf(0, 0, 8*(debug_line++), "Not found");
			get_char();
		#endif
		gfl_setCachedPage(oldPageNumber);
		// gfl_selectorPos = oldSelectorPos; // not needed: search only update the gfl_selectorpos when found
	}

	// reset the last with the time at the end of the search
	_lastTime = get_hz200();
}

