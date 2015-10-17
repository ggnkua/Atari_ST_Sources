/*
	Big/Little endianness functions

	Copyright (C) 2002	Patrice Mandin

	This program is free software; you can redistribute it and/or modify
	it under the terms of the GNU General Public License as published by
	the Free Software Foundation; either version 2 of the License, or
	(at your option) any later version.

	This program is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with this program; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

#ifndef _ENDIAN_H
#define _ENDIAN_H

/*--- Defines ---*/

#define GET_BE_WORD(structure,field) \
	((structure->field[0]<<8) | \
	(structure->field[1]))

#define GET_BE_LONG(structure,field) \
	((structure->field[0]<<24) | \
	(structure->field[1]<<16) | \
	(structure->field[2]<<8) | \
	(structure->field[3]))

#define GET_LE_WORD_S(structure,field) \
	((structure.field[1]<<8) | \
	(structure.field[0]))

#define GET_LE_LONG_S(structure,field) \
	((structure.field[3]<<24) | \
	(structure.field[2]<<16) | \
	(structure.field[1]<<8) | \
	(structure.field[0]))

#define GET_BE_WORD_S(structure,field) \
	((structure.field[0]<<8) | \
	(structure.field[1]))

#define GET_BE_LONG_S(structure,field) \
	((structure.field[0]<<24) | \
	(structure.field[1]<<16) | \
	(structure.field[2]<<8) | \
	(structure.field[3]))

#define LE_LONG(value) \
	((((value) & 0x000000ff)<<24) |\
	(((value)<<8) &  0x00ff0000) |\
	(((value)>>8) &  0x0000ff00) |\
	(((value)>>24) & 0x000000ff))

#define LE_WORD(value) \
	((((value) & 0xff)<<8)|(((value)>>8) & 0xff))

#endif /* _ENDIAN_H */
