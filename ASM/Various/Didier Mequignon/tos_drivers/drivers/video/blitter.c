/* VDI Blitter operations
 * Didier Mequignon 2009, e-mail: aniplay@wanadoo.fr
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */
 
#include "config.h"
#include "../../include/vars.h"

#define HALFTONE (volatile short *)0x$FFFF8A00 // Halftone-RAM, Words 0 - 15
#define SRC_XINC *(volatile short *)0xFFFF8A20 // Source X Increment
#define SRC_YINC *(volatile short *)0xFFFF8A22 // Source Y Increment
#define SCR_ADDR *(volatile long *)0xFFFF8A24 // Source Address Register
#define END_MASK1 *(volatile short *)0xFFFF8A28 // Endmask 1 (First write of a line)
#define END_MASK2 *(volatile short *)0xFFFF8A2A // Endmask 2 (All other line writes)
#define END_MASK3 *(volatile short *)0xFFFF8A2C // Endmask 3 (Last write of a line)
#define DST_XINC *(volatile short *)0xFFFF8A2E // Destination X Increment
#define DST_YINC *(volatile short *)0xFFFF8A30 // Destination Y Increment
#define DST_ADDR *(volatile long *)0xFFFF8A32 // Destination Address Register
#define X_COUNT *(volatile short *)0xFFFF8A36 // Words per Line in Bit-Block
#define Y_COUNT *(volatile short *)0xFFFF8A38 // Lines per Bit-Block
#define HOP *(volatile char *)0xFFFF8A3A // Halftone Operation Register
#define OP *(volatile char *)0xFFFF8A3B // Logical Operation Register
#define LINE_NUM *(volatile char *)0xFFFF8A3C // Line Number Register
#define SKEW *(volatile char *)0xFFFF8A3D // SKEW Register

#if defined(COLDFIRE) && defined(MCF547X) /* FIREBEE */

void blitter_copy(unsigned char *src_addr, int src_line_add, unsigned char *dst_addr, int dst_line_add, int w, int h, int bpp, int op, int backward)
{
	int horizontal_incr = bpp >> 3;
	int words_by_line = (w * horizontal_incr) >> 1;
	src_line_add *= horizontal_incr;
	dst_line_add *= horizontal_incr;
	if(backward)
		horizontal_incr = -horizontal_incr;
	if(((long)src_addr >= 0x01000000) && ((long)src_addr < *(long *)ramtop))
#if (__GNUC__ > 3)
		asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5485\n\t");
#else
		asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5200\n\t");
#endif
	SRC_XINC = (short)horizontal_incr;
	SRC_YINC = (short)src_line_add;
	SCR_ADDR = (long)src_addr;
	END_MASK1 = -1;
	END_MASK2 = -1;
	END_MASK3 = -1;
	DST_XINC = (short)horizontal_incr;
	DST_YINC = (short)src_line_add;
	DST_ADDR = (long)dst_addr;
	X_COUNT = (short)words_by_line + 1;
	Y_COUNT	= (short)h;
	HOP = 2; // source
	OP = (char)op;
	LINE_NUM = 0;
	SKEW = 0;
	if((words_by_line > 1) && backward)
		SKEW |= 0xC0;
	LINE_NUM |= 0x80; // start transfer
	while(LINE_NUM < 0) // wait end of transfer
	{
		asm volatile (" nop\n\t");
	}
	if(((long)dst_addr >= 0x01000000) && ((long)dst_addr < *(long *)ramtop))
	{
#if (__GNUC__ > 3)
		asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5485\n\t"); /* from CF68KLIB */
#else
		asm volatile (" .chip 68060\n\t cpusha DC\n\t .chip 5200\n\t"); /* from CF68KLIB */
#endif
	}
}

#endif /* defined(COLDFIRE) && defined(MCF547X) */

