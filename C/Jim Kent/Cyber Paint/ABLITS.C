
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
b.plane_ct = 4;
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

clip_from_screen(c, screen)
register Cel *c;
WORD *screen;
{
copy_blit(c->width, c->height, c->xoff, c->yoff,  screen, 160, 
	0, 0, c->image, Raster_line(c->width) );
copy_words(sys_cmap, c->cmap, 16);
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

b.s_nxwd = b.d_nxwd = BITPLANES*2;
b.s_nxln = Raster_line(cel->width);
b.d_nxln = 160;
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

untwist_clip_from_screen(cel, screen)
register Cel *cel;
WORD *screen;
{
struct bbblock b;

b.b_wd = cel->width;
b.b_ht = cel->height;
b.plane_ct = 4;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = 3;  /*replace */

b.d_xmin = 0;
b.s_xmin = cel->xoff;
b.d_ymin = 0;
b.s_ymin = cel->yoff;
b.d_form = cel->image;
b.s_form = screen;

b.d_nxwd =  cel->height*2;
b.d_nxln = 2;
b.d_nxpl = Mask_block(cel->width, cel->height);

b.s_nxwd = BITPLANES*2;
b.s_nxln = 160;
b.s_nxpl = 2;

b.p_addr = NULL;
ablit(&b);
copy_words(sys_cmap, cel->cmap, 16);
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

b.d_nxwd = BITPLANES*2;
b.d_nxln = 160;
b.d_nxpl = 2;

b.p_addr = NULL;
if (dest_clip_block(&b))
	ablit(&b);
}

nozero_celblit(x, y, cel)
WORD x, y;
register Cel *cel;
{
struct bbblock b;


x += cel->xoff;
y += cel->yoff;

/* set up the "scoop out" blit */
b.b_wd = cel->width;
b.b_ht = cel->height;
b.plane_ct = BITPLANES;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = 1; /*and*/
b.d_form = cscreen;
b.d_xmin = x;
b.d_ymin = y;
b.s_xmin = b.s_ymin = 0;
b.s_form = cel->mask;
b.s_nxpl = 0;
b.s_nxwd = 2;
b.s_nxln = (((cel->width+15)>>3)&0xfffe);
b.d_nxpl = 2;
b.d_nxwd = BITPLANES*2;
b.d_nxln = 160;
b.p_addr = NULL;
if (dest_clip_block(&b))
	ablit(&b);

/* and xor in the image through the hole */
b.b_wd = cel->width;
b.b_ht = cel->height;
b.plane_ct = BITPLANES;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = R_XOR; /*replace*/
b.d_xmin = x;
b.d_ymin = y;
b.s_xmin = b.s_ymin = 0;
b.s_form = cel->image;
b.s_nxpl = 2;
b.s_nxwd = 8;
b.s_nxln = Raster_line(cel->width);
b.p_addr = NULL;
if (dest_clip_block(&b))
	ablit(&b);
}

mask_clipping()
{
struct bbblock b;
register Cel *c;

if ((c = clipping) == NULL)
	return;
b.b_wd = c->width;
b.b_ht = c->height;
b.plane_ct = BITPLANES;
b.op_tab[0] = 1;
b.op_tab[1] = 1;
b.op_tab[2] = 13;
b.op_tab[3] = 13;
b.fg_col = ccolor;
b.d_form = c->image;
b.d_xmin = b.d_ymin = b.s_xmin = b.s_ymin = 0;
b.s_form = c->mask;
b.s_nxwd = 2;
b.d_nxwd = BITPLANES*2;
b.d_nxln = b.s_nxln = ((c->width + 15)>>4)<<1;
b.d_nxln <<= 2;
b.s_nxpl = 0;
b.d_nxpl = 2;
b.p_addr = NULL;
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
b.s_nxln = ((c->width + 15)>>4)<<1;
b.s_nxpl = 0;
b.d_nxpl = 2;
b.d_nxwd = BITPLANES*2;
b.d_nxln = 160;
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

aget_brush(x, y, buf)
WORD x, y;
register WORD *buf;
{
struct bbblock b;


word_zero(buf, 16);
b.b_wd = 16;
b.b_ht = 16;
b.plane_ct = BITPLANES;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = R_OR; /*and*/
b.s_form = cscreen;
b.s_xmin = x;
b.s_ymin = y;
b.d_xmin = b.d_ymin = 0;
b.d_form = buf;
b.d_nxpl = 0;
b.d_nxwd = 2;
b.d_nxln = 2;
b.s_nxpl = 2;
b.s_nxwd = BITPLANES*2;
b.s_nxln = 160;
b.p_addr = NULL;
ablit(&b);
}

