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


//#define TV_DEBUG



#include <string.h>

#include "atari_hw.h"
#include "conf.h"
#include "hxcfeda.h"
#include "gui_utils.h"
#include "screen.h"
#include "screen_layout.h"
#include "fat32/fat_filelib.h"
#include "libc/snprintf/snprintf.h"

#ifdef TV_DEBUG
	static int debug_line=0;
#endif





//
// Externs
//
extern unsigned char fExit;
extern DirectoryEntry * gfl_dirEntLSB_ptr;
extern unsigned char currentPath[4*256];


FL_FILE *_file;



/**
 * @return 1 at EOF
 */
int _hexviewer(unsigned long offsetIn, unsigned long *offsetOut)
{
	UWORD curX=0, curY=0, i;
	int bytesRead;
	char buffer[96];
	char *lineStart = buffer + 16;
	char *lineHex   = buffer + 16 + 11;
	char *lineAscii = buffer + 16 + 63;
	unsigned char curChar;
	unsigned char c;

	fl_fseek(_file, offsetIn, SEEK_SET);

	*offsetOut = offsetIn;
	memset(lineHex, ' ', 79-11);

	do { // fill the buffer
		bytesRead = fl_fread(buffer, 1, 16 , _file);

		if (bytesRead<=0) {
			return 1;
		}

		plp_snprintf(lineStart, 80, "%08lx : ", (unsigned long)*offsetOut);
// "12345678 : 00 11 22 33 44 55 66 77 88 99 aa bb cc dd ee ff     0123456789abcdef"

		for (curX=0,i=0; curX<16 && curX<bytesRead; curX++, i++) {
			curChar = buffer[curX];
			lineAscii[curX] = (curChar) ? (curChar) : (' ');
			c = curChar>>4;
			c += (c<10) ? ('0') : ('a'-10);
			lineHex[i++] = c;

			c = curChar&0xf;
			c += (c<10) ? ('0') : ('a'-10);
			lineHex[i++] = c;
		}
		lineAscii[curX] = '\0';

		gui_print_str(lineStart , 0, curY + SLA_VIEWER_Y_POS, 0);
		*offsetOut += 16;
		curY += 8;
	} while ( curY < ((SLA_FILES_PER_PAGE+4)<<3) );
	return 0;
}



/**
 * @return 1 at EOF
 */
int _textviewer(unsigned long offsetIn, unsigned long *offsetOut)
{
	UWORD curX=0, curY=0;
	int bytesRead;
	int bufUsed   = 0;
	int bufOffset = 0;
	char buffer[512];
	unsigned char curChar;

	fl_fseek(_file, offsetIn, SEEK_SET);

	*offsetOut = offsetIn;

	do { // fill the buffer
		// discard the already shown bytes
		memcpy(buffer, buffer + bufOffset, bufUsed - bufOffset);
		bufUsed -= bufOffset;
		bufOffset = 0;

		// fill the buffer
		bytesRead = fl_fread(buffer + bufUsed, 1, 512 - bufUsed , _file);

		if (bytesRead>=0) {
			bufUsed += bytesRead;
		}

		do {
			curChar = buffer[bufOffset];

			if (10 == curChar) {
				curX = 0xffff;
				if (13 == buffer[bufOffset+1]) {
					// LFCR
					bufOffset++;
					(*offsetOut)++;
				}
			} else if (13 == curChar) {
				curX = 0xffff;
				if (10 == buffer[bufOffset+1]) {
					// CRLF
					bufOffset++;
					(*offsetOut)++;
				}
			} else {
				gui_print_char8x8(curX, SLA_VIEWER_Y_POS + curY, curChar);
				curX +=8;
			}

			bufOffset++;
			(*offsetOut)++;

			if (curX >= SCR_XRESOL) {
				curX = 0;
				curY += 8;
				if ( curY >= ((SLA_FILES_PER_PAGE+4)<<3) ) {
					return 0; // not at eof
				}
			}
		} while ( (    ( (bytesRead>=0) && (bufOffset<(bufUsed-2)) ) // reserve 2 chars for CRLF handling
		            || ( (bytesRead <0) && (bufOffset<(bufUsed)) )   // last chunk, still some chars to be done
		          )
		        );	// -1 for CRLF handling
	} while (bytesRead>=0);	// fill the buffer

	// eof
	return 1;
}


/**
 * View the selected file
 */
void vie_viewer()
{
	char filename[5*LFN_MAX_SIZE+2];
	unsigned short anykey=0;
	unsigned long offset = 0;
	unsigned long offsetEnd = 0;
	unsigned long offsetLast = 1;
	unsigned long pageOffset = 0;
	unsigned long filelen;
	unsigned char fHex;
	unsigned char fHexLast = 2;
	char tmpBuf[512];			// used to check wethever the hex/text viewer should be fired first
	unsigned short i;

	filelen = read_long_lsb(&gfl_dirEntLSB_ptr->size_b1);

	if (!filelen) {
		gui_display_statusl(0, 1, "File has 0 length !");
		get_char();
		return;
	} else {
		gui_display_statusl(0, 1, "Opening file length = %ld bytes ($%lx)", (unsigned long)filelen, (unsigned long)filelen);
	}

	strcpy(filename, (char *)currentPath);
	filename[strlen(filename)+1] = '\0';
	filename[strlen(filename)]   = '/';
	strcat(filename, (const char *)gfl_dirEntLSB_ptr->longName);

	_file = fl_fopen(filename, "r");
	if (!_file) {
		get_char();
		return;
	}

	// guess if file is text or hex
	int bytesRead = fl_fread(tmpBuf, 1, sizeof(tmpBuf), _file);
	fHex = 0;
	for (i=0; i<bytesRead; i++) {
		if (tmpBuf[i]<9) {
			fHex = 1;	// any char whose ascii code <9 (TAB) will trigger the hex viewer
		}
	}

	int isEof = 0;

	do {
		if (offsetLast != offset || fHexLast != fHex) {
			// redraw
			offsetLast = offset;
			fHexLast = fHex;

			// clear the screen
			gui_clear_list(4);
			if (fHex) {
				isEof = _hexviewer(offset, &offsetEnd);
			} else {
				isEof = _textviewer(offset, &offsetEnd);
			}

			if (offsetEnd - offset > pageOffset) {
				// the larger page offset
				pageOffset = offsetEnd - offset;
			}

			// ensure that this line is shown (even if the first chunk is the last one)
			gui_display_statusl(0, 0, "space/[ctrl/shift]Up/Down:navigate   F2:Text/Hex display   Esc/F3:Quit");
			if (isEof) {
				gui_display_statusl(0, 0, "End of file                       ");
			}
		}

		anykey = get_char()>>16;
		if (0x3c == anykey) { // F2: toggle hex/ascii
			fHex = fHex^1;
			pageOffset = 0;
		} else if (!isEof && (0x50==anykey || 0x39==anykey)) { // down,space: next page
			offset = offsetEnd;
		} else if (0x48==anykey) { // up: "previous" page
			if (pageOffset > offset) {offset = 0;}
			else {offset -= pageOffset; }
		} else if (0x448==anykey) { // ctrl+up: go to start
			offset = 0;
		} else if (0x450==anykey) { // ctrl+down: go to end
			offset = filelen-(pageOffset>>2);
		} else if (0x148==anykey || 0x248==anykey) { // shift+up: up 8 pages
			if ((pageOffset<<3) > offset) {offset = 0;}
			else {offset -= (pageOffset<<3); }
		} else if (0x150==anykey || 0x250==anykey) { // shift+down: down 8 pages
			if (offset + (pageOffset<<3) >= filelen) {offset = filelen-(pageOffset>>2);}
			else {offset += (pageOffset<<3); }
		}
		//gui_printf(0,0,0,"key:%08lx ", anykey);
	} while (anykey!=1 && anykey!=0x3d && !fExit);

	fl_fclose(_file);
}


