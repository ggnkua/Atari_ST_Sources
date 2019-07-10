/*                        Copyright (c) 1987 Bellcore
 *                            All Rights Reserved
 *       Permission is granted to copy or use this program, EXCEPT that it
 *       may not be sold for profit, the copyright notice must be reproduced
 *       on copies, and credit should be given to Bellcore where it is due.
 *       BELLCORE MAKES NO WARRANTY AND ACCEPTS NO LIABILITY FOR THIS PROGRAM.
 */
/*	$Header: blit.c,v 4.1 88/06/21 13:07:59 bianchi Exp $
	$Source: /tmp/mgrsrc/src/oblit/RCS/blit.c,v $
*/
static char	RCSid_[] = "$Source: /tmp/mgrsrc/src/oblit/RCS/blit.c,v $$Revision: 4.1 $";

/*  stub bitblit code */

#include "bitmap.h"
#include <linea.h>

extern char *_scrnbase;
extern int _scrwidth, _scrheight, _scrplanes;

/* the atari hardware expects SRC==0x3, DST==0x05, so we have to convert
   the MGR standards here
 */

static char __atari[16] = {
	0, 0x8, 4, 0xc,
	2, 0xa, 6, 0xe,
	1,   9, 5, 0xd,
        3, 0xb, 7, 0xf
};

static char nsrc[16] = {		/* fold no source cases */
	0,0,0,0,
	0xf&~DST, 0xf&~DST, 0xf&~DST, 0xf&~DST,
	0xf&DST, 0xf&DST, 0xf&DST, 0xf&DST, 
	0xf, 0xf, 0xf, 0xf
	};

/*
 *  General memory-to-memory rasterop
 */

mem_rop(dest, dx, dy, width, height, func, source, sx, sy)
int sx, sy, dx, dy;		/* properly clipped source and dest */
int width, height;		/* rectangle to be transferred */
BITMAP *source, *dest;		/* bit map pointers */
int func;			/* rasterop function */
{

	BBPB b;
	int mindx, mindy, i;
	int srcnxln, dstnxln;
	int srcnxwd, dstnxwd;

	bzero(&b, sizeof(b));
#ifndef NOCLIP
	if (width < 0) {
		dx += width;
		width = -width;
	}
	if (height < 0) {
		dy += height;
		height = -height;
	}
	if (dx < 0) {
		sx -= dx;
		width += dx;
		dx = 0;
	}
	if (dy < 0) {
		sy -= dy;
		height += dy;
		dy = 0;
	}
	if (source) {
		if (sx < 0) {
			dx -= sx;
			width += sx;
			sx = 0;
		}
		if (sy < 0) {
			dy -= sy;
			height += sy;
			sy = 0;
		}
		if ((i = sx + width - source->wide) > 0)
			width -= i;
		if ((i = sy + height - source->high) > 0)
			height -= i;
	}

	if ((i = dx + width - dest->wide) > 0)
		width -= i;
	if ((i = dy + height - dest->high) > 0)
		height -= i;
	if (width < 1 || height < 1)
		return -1;
#endif

	if (source) {
		if (IS_SCREEN(source)) {
			srcnxwd = __aline->_VPLANES + __aline->_VPLANES;
			srcnxln = __aline->_VWRAP;
		}
		else {
			srcnxwd = HI_NXWD;
			srcnxln = BIT_LINE(source) << 2;
		}
	}

	if (IS_SCREEN(dest)) {
		dstnxwd = __aline->_VPLANES + __aline->_VPLANES;
		dstnxln = __aline->_VWRAP;
	}
	else {
		dstnxwd = HI_NXWD;
		dstnxln = BIT_LINE(dest) << 2;
	}

	b.bb_b_wd = width;
	b.bb_b_ht = height;
	b.bb_plane_ct = IS_SCREEN(dest) ? _scrplanes : 1;
	b.bb_fg_col = 0xf;
	b.bb_bg_col = 0;
	func = OPCODE(func);
	if (source) {
		b.bb_op_tab.fg0bg0 =
		b.bb_op_tab.fg0bg1 =
		b.bb_op_tab.fg1bg0 =
		b.bb_op_tab.fg1bg1 = __atari[func];
		b.bb_s.bl_xmin = source->x0 + sx;
		b.bb_s.bl_ymin = source->y0 + sy;
		b.bb_s.bl_nxwd = srcnxwd;
		b.bb_s.bl_nxpl = 
	(IS_SCREEN(source) && IS_SCREEN(dest)) ? 2 : 0;
		b.bb_s.bl_nxln = srcnxln;
		b.bb_s.bl_form = (char *)source->data;
	}
	else {
		b.bb_op_tab.fg0bg0 =
		b.bb_op_tab.fg0bg1 =
		b.bb_op_tab.fg1bg0 =
		b.bb_op_tab.fg1bg1 = __atari[nsrc[func]];
		b.bb_s.bl_form = (char *)0xabcdef00;
	}
	b.bb_d.bl_xmin = mindx = dest->x0 + dx;
	b.bb_d.bl_ymin = mindy = dest->y0 + dy;
	b.bb_d.bl_form = (char *)dest->data;
	b.bb_d.bl_nxwd = dstnxwd;
	b.bb_d.bl_nxln = dstnxln;
	b.bb_d.bl_nxpl = 2;
	b.bb_p_addr = 0;
	linea7(&b);
}

#if 0
/*
 * function to copy the (one plane) screen image to the physical screen
 */

void
_update_screen(source, minx, maxx, miny, maxy)
	BITMAP *source;
	int minx, maxx, miny, maxy;
{
	BBPB b;

	if (_need_updates == 0)
		return;

	if (!IS_SCREEN(source))
		return;

	if (minx >= maxx || miny >= maxy)
		return;
	bzero(&b, sizeof(b));
	b.bb_b_wd = (maxx - minx);
	b.bb_b_ht = (maxy - miny);
	b.bb_plane_ct = 1;
	b.bb_fg_col = 3;
	b.bb_bg_col = 0;
	b.bb_op_tab.fg0bg0 =
	b.bb_op_tab.fg0bg1 =
	b.bb_op_tab.fg1bg0 =
	b.bb_op_tab.fg1bg1 = S_ONLY;
	b.bb_s.bl_xmin = minx;
	b.bb_s.bl_ymin = miny;
	b.bb_s.bl_nxwd = HI_NXWD;
	b.bb_s.bl_nxpl = 2;
	b.bb_s.bl_nxln = BIT_Size(source->wide, 1, 1);
	b.bb_s.bl_form = (char *)source->data;
	b.bb_d.bl_xmin = minx;
	b.bb_d.bl_ymin = miny;
	b.bb_d.bl_nxwd = __aline->_VPLANES * 2;
	b.bb_d.bl_nxln = __aline->_VWRAP;
	b.bb_d.bl_nxpl = 2;
	b.bb_d.bl_form = _scrnbase;
	b.bb_p_addr = 0;
	linea7(&b);
}
#endif
