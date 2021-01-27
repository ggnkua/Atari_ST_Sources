/* Copyright (c) 1990 - present by H. Robbers.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *  CTYPE.C	Character classification and conversion
 *      			  in which underline is alphanum.
 */

#include "ctype.h"

#undef	toupper
#undef	tolower

static
unsigned char _ctype[256] =
{
	_CTc, _CTc, _CTc, _CTc,					/* 0x00..0x03 */
	_CTc, _CTc, _CTc, _CTc,					/* 0x04..0x07 */
	_CTc, _CTc|_CTs, _CTc|_CTs, _CTc|_CTs,	/* 0x08..0x0B */
	_CTc|_CTs, _CTc|_CTs, _CTc, _CTc,		/* 0x0C..0x0F */

	_CTc, _CTc, _CTc, _CTc,					/* 0x10..0x13 */
	_CTc, _CTc, _CTc, _CTc,					/* 0x14..0x17 */
	_CTc, _CTc, _CTc, _CTc,					/* 0x18..0x1B */
	_CTc, _CTc, _CTc, _CTc,					/* 0x1C..0x1F */

	_CTs, _CTp, _CTp, _CTp,					/* 0x20..0x23 */
	_CTp, _CTp, _CTp, _CTp,					/* 0x24..0x27 */
	_CTp, _CTp, _CTp, _CTp,					/* 0x28..0x2B */
	_CTp, _CTp, _CTp, _CTp,					/* 0x2C..0x2F */

	_CTd|_CTx, _CTd|_CTx, _CTd|_CTx, _CTd|_CTx,	/* 0x30..0x33 */
	_CTd|_CTx, _CTd|_CTx, _CTd|_CTx, _CTd|_CTx,	/* 0x34..0x37 */
	_CTd|_CTx, _CTd|_CTx, _CTp, _CTp,		/* 0x38..0x3B */
	_CTp, _CTp, _CTp, _CTp,					/* 0x3C..0x3F */

	_CTp, _CTu|_CTx, _CTu|_CTx, _CTu|_CTx,	/* 0x40..0x43 */
	_CTu|_CTx, _CTu|_CTx, _CTu|_CTx, _CTu,	/* 0x44..0x47 */
	_CTu, _CTu, _CTu, _CTu,					/* 0x48..0x4B */
	_CTu, _CTu, _CTu, _CTu,					/* 0x4C..0x4F */

	_CTu, _CTu, _CTu, _CTu,					/* 0x50..0x53 */
	_CTu, _CTu, _CTu, _CTu,					/* 0x54..0x57 */
	_CTu, _CTu, _CTu, _CTp,					/* 0x58..0x5B */
	_CTp, _CTp, _CTp, _CTp|_CTu,			/* 0x5C..0x5F underline is alpha uppercase */

	_CTp, _CTl|_CTx, _CTl|_CTx, _CTl|_CTx,	/* 0x60..0x63 */
	_CTl|_CTx, _CTl|_CTx, _CTl|_CTx, _CTl,	/* 0x64..0x67 */
	_CTl, _CTl, _CTl, _CTl,					/* 0x68..0x6B */
	_CTl, _CTl, _CTl, _CTl,					/* 0x6C..0x6F */

	_CTl, _CTl, _CTl, _CTl,					/* 0x70..0x73 */
	_CTl, _CTl, _CTl, _CTl,					/* 0x74..0x77 */
	_CTl, _CTl, _CTl, _CTp,					/* 0x78..0x7B */
	_CTp, _CTp, _CTp, _CTc,					/* 0x7C..0x7F */
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,		/* 0x80..0xff */
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

short toupper(short c)			/* NO side effects !! */
{
	return(islower(c) ? (c ^ 0x20) : (c));
}

short tolower(short c)			/* NO side effects !! */
{
	return(isupper(c) ? (c ^ 0x20) : (c));
}

short is_open(short c)
{
	return c == '(' || c == '{' || c == '[';
}

short is_close(short c)
{
	return c == ')' || c == '}' || c == ']';
}