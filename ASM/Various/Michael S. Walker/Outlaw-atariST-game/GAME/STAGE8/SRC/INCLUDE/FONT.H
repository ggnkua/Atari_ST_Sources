/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef FONT_H
#define FONT_H

#include <TYPES.H>
#include </BITMAP/FONT.C>

extern const uint8_t font[];

#define FONT_HEIGHT 8
#define CHAR_BEL 7
#define CHAR_TAB 9
#define CHAR_LF 10
#define CHAR_VT 11
#define CHAR_FF 12
#define CHAR_CR 13
#define CHAR_DEL 127

#define IS_PRINTABLE(i) ((i) >= ' ' && (i) <= '~')
#define GLYPH_START(i) (font + (((i) - ' ') << 3))

#endif