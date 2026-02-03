/***************************************************************************
 *   Copyright (C) 1998-1999 Michael Schwingen                             *
 *   michael@schwingen.org                                                 *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.           *
 ***************************************************************************/

static inline WORD CacheCtrl(WORD mode)
{
  register long retvalue __asm__("d0");
  asm volatile ("move.w %1,-(%%sp)\n\t"
		"move.w #160,-(%%sp)\n\t"
		"trap #14\n\t"
		"addq.l	#4,%%sp"
		: "=r" (retvalue)		/* output register */
		: "adi" (mode)			/* input registers */
		: "cc","d0","d1","d2",
		  "a0","a1","a2"		/* clobbered */ );
  return retvalue;
}

static inline void CacheCtrl2(WORD mode, WORD onoff)
{
  asm volatile ("move.w %1,-(%%sp)\n\t"
		"move.w %0,-(%%sp)\n\t"
		"move.w #160,-(%%sp)\n\t"
		"trap #14\n\t"
		"addq.l	#6,%%sp"
		: 				/* output register */
		: "adi" (mode), "adi" (onoff)	/* input registers */
		: "cc","d0","d1","d2",
		  "a0","a1","a2"		/* clobbered */ );
}


