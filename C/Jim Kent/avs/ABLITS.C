/* Audio-Video Sequencer           */
/* Copyright 1988 Antic Publishing */
/* by Jim Kent                     */


#include <stdio.h>
#include <aline.h>
#include "flicker.h"


#define R_NOP 5
#define R_CLR 0
#define R_SET 15
#define R_XOR 6
#define R_CPY 3
#define R_OR  7
#define R_SCOOP 4


copy_blit(width, height, sx, sy, spt, srow_bytes, dx, dy, dpt, drow_bytes)
WORD width, height, sx, sy, srow_bytes, dx, dy, drow_bytes;
WORD *spt, *dpt;
{
struct bbblock b;

b.b_wd = width;
b.b_ht = height;
b.plane_ct = BITPLANES;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = R_CPY;  /*replace */

b.s_xmin = sx;
b.d_xmin = dx;
b.s_ymin = sy;
b.d_ymin = dy;
b.s_form = spt;
b.d_form = dpt;

b.s_nxwd = b.d_nxwd = BITPLANES*2;
b.s_nxln = srow_bytes;
b.d_nxln = drow_bytes;
b.s_nxpl = b.d_nxpl = 2;
b.p_addr = NULL;
if (dest_clip_block(&b) )
	if (source_clip_block(&b))
		ablit(&b);
}

swap_sd(b)
register struct bbblock *b;
{
register WORD swap;

swap = b->d_xmin;
b->d_xmin = b->s_xmin;
b->s_xmin = swap;

swap = b->d_ymin;
b->d_ymin = b->s_ymin;
b->s_ymin = swap;
}

source_clip_block(b)
register struct bbblock *b;
{
WORD ret;

swap_sd(b);
ret = dest_clip_block(b);
swap_sd(b);
return(ret);
}


dest_clip_block(b)
register struct bbblock *b;
{
register WORD x2, y2;

if ((x2 = b->d_xmin) >= XMAX || 
	(y2 = b->d_ymin) >= YMAX)
	return(0);
if ( (x2+=b->b_wd) <= 0 || (y2+=b->b_ht) <= 0)
	return(0);
if (b->d_xmin < 0)
	{
	b->b_wd -= (0 - b->d_xmin);
	b->s_xmin += (0 - b->d_xmin);
	b->d_xmin += (0 - b->d_xmin);
	}
if (b->d_ymin < 0)
	{
	b->b_ht -= (0 - b->d_ymin);
	b->s_ymin += (0 - b->d_ymin);
	b->d_ymin += (0 - b->d_ymin);
	}
if (x2 > XMAX)
	b->b_wd -= x2-XMAX;
if (y2 > YMAX)
	b->b_ht -= y2-YMAX;
return(1);
}


xor_celblit(x, y, cel)
WORD x, y;
Cel *cel;
{
celblit(x, y, cel, R_XOR);
}

copy_celblit(x, y, cel)
WORD x, y;
Cel *cel;
{
celblit(x, y, cel, R_CPY);
}

celblit(x, y, cel, op)
WORD x, y;
register Cel *cel;
WORD op;
{
struct bbblock b;

b.b_wd = cel->width;
b.b_ht = cel->height;
b.plane_ct = 4;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = op;

b.s_xmin = 0;
b.d_xmin = x+cel->xoff;
b.s_ymin = 0;
b.d_ymin = y+cel->yoff;
b.s_form = cel->image;
b.d_form = cscreen;

b.s_nxwd = b.d_nxwd = 4*2;
b.s_nxln = LRaster_line(cel->width);
b.d_nxln = LRaster_line(320);
b.s_nxpl = b.d_nxpl = 2;
b.p_addr = NULL;
if (dest_clip_block(&b))
	ablit(&b);
}

twist_xor_celblit(x, y, cel)
WORD x, y;
Cel *cel;
{
twist_celblit(x, y, cel, R_XOR);
}

twist_copy_celblit(x, y, cel)
WORD x, y;
Cel *cel;
{
twist_celblit(x, y, cel, 3);
}

twist_celblit(x, y, cel, op)
WORD x, y;
register Cel *cel;
WORD op;
{
struct bbblock b;

b.b_wd = cel->width;
b.b_ht = cel->height;
b.plane_ct = 4;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = op;  /*replace */

b.s_xmin = 0;
b.d_xmin = x+cel->xoff;
b.s_ymin = 0;
b.d_ymin = y+cel->yoff;
b.s_form = cel->image;
b.d_form = cscreen;

b.s_nxwd =  cel->height*2;
b.s_nxln = 2;
b.s_nxpl = Mask_block(cel->width, cel->height);

b.d_nxwd = 4*2;
b.d_nxln = 160;
b.d_nxpl = 2;

b.p_addr = NULL;
if (dest_clip_block(&b))
	ablit(&b);
}

show_c_nohot(c, xoff, yoff, color)
register struct cursor *c;
int xoff, yoff, color;
{
struct bbblock b;

b.b_wd = c->width;
b.b_ht = c->height;
b.plane_ct = BITPLANES;
b.op_tab[0] = 4;
b.op_tab[1] = 4;
b.op_tab[2] = 7;
b.op_tab[3] = 7;
b.fg_col = color;
b.d_xmin = xoff;
b.d_ymin = yoff;
b.d_form = cscreen;
b.s_xmin = b.s_ymin = 0;
b.s_form = (WORD *)c->image;
b.s_nxwd = 2;
b.s_nxln = Mask_line(c->width);
b.s_nxpl = 0;
b.d_nxpl = 2;
b.d_nxwd = BITPLANES*2;
b.d_nxln = Raster_line(XMAX);
b.p_addr = NULL;
if (dest_clip_block(&b))
	{
	ablit(&b);
	}
}

show_cursor(c, x, y, color)
register struct cursor *c;
WORD x, y, color;
{
show_c_nohot(c, x - c->xhot, y - c->yhot, color);
}

