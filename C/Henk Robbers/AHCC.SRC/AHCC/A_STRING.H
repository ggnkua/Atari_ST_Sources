/* Copyright (c) 2014 by H. Robbers.
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

/* a_string.h
   Definitions for the embedded descriptor type 'string'. */

#ifndef A_STRING_H
#define A_STRING_H

/* A descriptor is 64 bits of which 32 are the address */
typedef struct descriptor
{
	struct
	{
		ubits els : 2;		/* 0 = byte, 1 = word, 2 = long, 3 = larger */
		ubits str : 1;		/* 0 for string, 1 otherwise */
		ubits lvl : 2;		/* level, 0 for string. Room for 4 levels. */
		ubits mf  : 1;		/* 0 content (*__D.a) are malloced and must
							     be freed when the descriptor is destroyed.
							   1 *__D.a is static or on the stack. */
		ubits reserve : 7;	/* must be zero */
		ubits s       : 19;	/* no of elements of this level, for string bytelength (max 2^19-1 = */
	} d;

	void *a;	/* address of next level or content */
} __D;

/* Note: for a simple 'string' descriptor __D.d is completely zero apart from the s field. */

/*
ICL VME/B descriptor: (from the BFM2 manual T1556 issue 2 (c) International Computers Limited, 1978!!!!!
page 2.11 - 2.13 )

typedef struct va		/* Virtual address */
{
	ubits segment_number : 14;
	ubits displacement   : 18;
}; VA

typedef
struct descriptor
{
	struct
	{
		ubits type : ?;		/* descriptor type (eg vector, string, descriptor or miscellaneous. ? 3 bits */
		ubits size : ?;		/* bit, byte, word, double word or quadruple word ? 5 bits*/
		ubits lenhth : ?;	/* number of items in this level ? 24 bits */
	} d;	/* supposed to be a total of 32 bits. */

	VA a;	/* Virtual address of start of described area */
} __D;

*/

#endif