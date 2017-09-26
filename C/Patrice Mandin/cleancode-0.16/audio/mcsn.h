/*
	MCSN control structure

	Copyright (C) 2002	Patrice Mandin

	This library is free software; you can redistribute it and/or
	modify it under the terms of the GNU Lesser General Public
	License as published by the Free Software Foundation; either
	version 2.1 of the License, or (at your option) any later version.

	This library is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
	Lesser General Public License for more details.

	You should have received a copy of the GNU Lesser General Public
	License along with this library; if not, write to the Free Software
	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307  USA
*/

#ifndef _MCSN_H
#define _MCSN_H

typedef struct {
	unsigned short version;	/* Version */
	unsigned short size;	/* Size of structure */

	unsigned short play;	/* Replay capability */
	unsigned short record;	/* Record capability */
	unsigned short dsp;		/* DSP56K present */
	unsigned short pint;	/* Interrupt at end of replay */
	unsigned short rint;	/* Interrupt at end of record */

	unsigned long res1;		/* Frequency of external clock */
	unsigned long res2;
	unsigned long res3;
	unsigned long res4;
} cookie_mcsn_t __attribute__((packed));

enum {
	MCSN_ST=0,
	MCSN_TT,
	MCSN_FALCON
};

#define SETSMPFREQ	7	/* Set sample frequency */

#endif /* _MCSN_H */
