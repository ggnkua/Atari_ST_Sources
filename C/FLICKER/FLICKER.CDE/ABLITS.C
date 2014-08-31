
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
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = 3;  /*replace */

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
	b->d_xmin = 0;
	}
if (b->d_ymin < 0)
	{
	b->b_ht -= (0 - b->d_ymin);
	b->s_ymin += (0 - b->d_ymin);
	b->d_ymin = 0;
	}
if (x2 > XMAX)
	b->b_wd -= x2-XMAX;
if (y2 > YMAX)
	b->b_ht -= y2-YMAX;
return(1);
}

copy_celblit(x, y, cel)
WORD x, y;
register Cel *cel;
{
struct bbblock b;

b.b_wd = cel->width;
b.b_ht = cel->height;
b.plane_ct = 4;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = 3;  /*replace */

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

