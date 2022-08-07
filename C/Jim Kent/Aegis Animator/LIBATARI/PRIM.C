
overlay "player"

#define EDITOR

#include <stdio.h>
#include <aline.h>
#include <osbind.h>
#include "..\\include\\lists.h"
#include "..\\include\\format.h"
#include "..\\include\\cursor.h"
#include "..\\include\\font.h"
#include "..\\include\\clip.h"
#include "..\\include\\script.h"
#include "..\\include\\raster.h"
#include "..\\include\\color.h"

#define REPLACE 1
#define XOR	2

extern FILE *fopen();
extern WORD *bbm;

#ifdef EDITOR
extern struct rast_font sail_font;
extern struct spacing_data sail_offsets[];
extern WORD sail_data[];
#endif EDITOR

extern struct cube safety_cube;
extern WORD fore_color, back_color, hi_color, grey_color;
extern WORD *s1, *s2, *cscreen;

struct aline *aline;
struct cursor *cursor = NULL;

plop_front_to_back()
{
copy_structure(s1, s2, 32000);
}

#ifdef SLUFFED
plop_back_to_front()
{
copy_structure(s2, s1, 32000);
}
#endif SLUFFED

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

win2msk_blit(width, height, sx, sy, spt, srow_bytes, dx, dy, dpt, drow_bytes)
WORD width, height, sx, sy, srow_bytes, dx, dy, drow_bytes;
WORD *spt, *dpt;
{
struct bbblock b;

b.b_wd = width;
b.b_ht = height;
b.plane_ct = 4;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = 7;  /*replace */

b.s_xmin = sx;
b.d_xmin = dx;
b.s_ymin = sy;
b.d_ymin = dy;
b.s_form = spt;
b.d_form = dpt;

b.d_nxwd = 2;
b.s_nxwd = BITPLANES*2;
b.s_nxln = srow_bytes;
b.d_nxln = drow_bytes;
b.d_nxpl = 0;
b.s_nxpl = 2;
b.p_addr = NULL;
ablit(&b);
}

restore_from_back(sq)
register Square *sq;
{
struct bbblock b;

if (!clip_square(sq))
	return;
b.b_wd = sq->X - sq->x;
b.b_ht = sq->Y - sq->y;
b.plane_ct = 4;
b.op_tab[0] = b.op_tab[1] = b.op_tab[2] = b.op_tab[3] = 3;  /*replace */
b.s_xmin = b.d_xmin = sq->x;
b.s_ymin = b.d_ymin = sq->y;
b.s_form = s2;
b.d_form = s1;
b.s_nxwd = b.d_nxwd = BITPLANES*2;
b.s_nxln = b.d_nxln = 160;
b.s_nxpl = b.d_nxpl = 2;
b.p_addr = NULL;
ablit(&b);
}

char gemctable[16] = 
	{
	0, 2, 3, 6, 4, 7, 5, 8, 9, 0xa, 0xb, 0xe, 0xc, 0xf, 0xd, 1,
	};


static WORD cucolor = 15;

set_cursor_color(col)
{
register WORD *data;

cucolor = col;
new_cursor(cursor);
}

new_cursor(c)
register struct cursor *c;
{
register WORD *data;

cursor = c;
data = *( (WORD **)(((char *)aline)+8) );
data[4] = data[2] = gemctable[cucolor];
if (c == NULL)
	{
	block_stuff(data+5, 0, 32*sizeof(WORD) );
	}
else
	{
	data[0] = c->xhot;
	data[1] = c->yhot;
	block_stuff(data+5, 0, 16*sizeof(WORD) );
	copy_structure(c->image, data+21, 16*sizeof(WORD) );
	}
atmouse();
}


redraw_through_box(c)
Cube *c;
{
restore_from_back(c);
}

#ifdef DEBUG
dump(start, count)
char *start;
int count;
{
count>>=1;
while (--count >= 0)
	{
	printf("%x ", *start++);
	if ( !(count&3) )
		putchar('\n');
	}
}

dump_aline()
{
printf("dump_aline:\n");
dump(aline, sizeof(struct aline) );
printf("control -");
dump(aline->contrl, 6);
}
#endif DEBUG

WORD solid[] = {0xffff, 0xffff, 0xffff, 0xffff,
		 0xffff, 0xffff, 0xffff, 0xffff};

struct bbblock sd_bbb;
struct bbblock ftos_bbb;



draw_frame(color, x0, y0, x1, y1)
register int color, x0, y0, x1, y1;
{
hline(y0, x0, x1, color);
hline(y1, x0, x1, color);
vline(x0, y0, y1, color);
vline(x1, y0, y1, color);
}

rub_frame(x0, y0, x1, y1)
int x0, y0, x1, y1;
{
if (!swap_clip(&x0))
	return;
xline(x0, y0, x0, y1);
xline(x1, y0, x1, y1);
xline(x0, y0, x1, y0);
xline(x0, y1, x1, y1);
}

init_aline()
{
register struct aline *a;
#ifdef DEBUG
printf("init_aline()\n");
#endif DEBUG

a = aline = ainit();
#ifdef DEBUG
printf("init_aline() after ainit()\n");
#endif DEBUG

a->lnmask = 0xffff;
a->lstlin = -1;
a->wmode = REPLACE;
a->patptr = solid;
a->xmincl = aline->ymincl = 0;
a->xmaxcl = XMAX;
a->ymaxcl = YMAX;

ftos_bbb.d_form = sd_bbb.d_form = (WORD *)Logbase();
ftos_bbb.d_nxwd = sd_bbb.d_nxwd = BITPLANES*2;
ftos_bbb.d_nxln = sd_bbb.d_nxln = 160;
ftos_bbb.d_nxpl = sd_bbb.d_nxpl = 2;

#ifdef EDITOR
ftos_bbb.s_form = sail_data;
ftos_bbb.s_nxwd = 2;
ftos_bbb.s_nxln = sail_font.words_in_line * 2;
ftos_bbb.s_nxpl = 0;
#endif EDITOR
}

set_acolor(color)
register WORD color;
{
register struct aline *a = aline;

if (color & (1<<3) )
	a->colbit3 = 1;
else
	a->colbit3 = 0;
if (color & (1<<2) )
	a->colbit2 = 1;
else
	a->colbit2 = 0;
if (color & (1<<1) )
	a->colbit1 = 1;
else
	a->colbit1 = 0;
if (color & 1)
	a->colbit0 = 1;
else
	a->colbit0 = 0;
}

#ifdef SLUFFED
get_acolor()
{
register struct aline *a = aline;
register WORD color;

if (a->colbit0)
	color = 1;
else
	color = 0;
if (a->colbit1)
	color |= 2;
if (a->colbit2)
	color |= 4;
if (a->colbit3)
	color |= 8;
return((int)color);
}
#endif SLUFFED

getdot(x, y)
int x, y;
{
aline->ptsin = &x;	/*hope x and y on stack in correct order... */
return(aget());
}

#ifdef UNUSED
dot(x , y, color)
WORD x, y, color;
{
register struct aline *a = aline;
WORD damn_kludge[2];

damn_kludge[0] = x;
damn_kludge[1] = y;

a->wmode = REPLACE;
a->ptsin = damn_kludge;
a->intin = &color;
aput();
}
#endif UNUSED

hline(y, x1, x2, color)
WORD color, y, x1, x2;
{
colblock(color, x1, y, x2, y);
}

vline(x, y1, y2, color)
int color, x, y1, y2;
{
colblock(color, x, y1, x, y2);
}

#ifdef C_CODE
line(color, x1, y1, x2, y2)
WORD color;
WORD x1, y1, x2, y2;
{
register struct aline *a = aline;

set_acolor(color);
a->wmode = REPLACE;  
a->x1 = x1;
a->y1 = y1;
a->x2 = x2;
a->y2 = y2;
aaline();
}
#endif C_CODE

xline(x1, y1, x2, y2)
WORD x1, y1, x2, y2;
{
register struct aline *a = aline;

set_acolor(15);
a->wmode = XOR;  /*xor*/
a->x1 = x1;
a->y1 = y1;
a->x2 = x2;
a->y2 = y2;
aaline();
}


#ifdef EDITOR
sh_char(c, x, y, color)
register WORD c;
int x, y, color;
{
register struct bbblock *b = &ftos_bbb;

c -= ' ';
b->b_wd = sail_offsets[c].new_width;
b->b_ht = sail_font.lines;
b->s_xmin = sail_offsets[c].xoff + sail_font.norm_char_width * c;
b->plane_ct = BITPLANES;
b->fg_col = color;
b->op_tab[0] = 4;
b->op_tab[1] = 4;
b->op_tab[2] = 7;
b->op_tab[3] = 7;
b->d_xmin = x;
b->d_ymin = y+1;   /*plus one ... 2 pixel spacing between lines */
if (dest_clip_block(b))
	ablit(b);
return(x + sail_offsets[c].new_width + 1);
}

string_width(s)
register char *s;
{
register int c, acc;

if (s == NULL)
	return(0);
acc = 0;
for (;;)
	{
	c = *s++;
	if (c == 0)
		break;
	c -= ' ';
		acc += sail_offsets[c].new_width + 1;
	}
return(acc);
}

b_line(string)
char *string;
{
colrop(back_color, 0, YMAX - (CHAR_HEIGHT-1), XMAX-1, CHAR_HEIGHT-1);
gtext(string, 1, YMAX - (CHAR_HEIGHT-1), fore_color);
}

bottom_line(string)
char *string;
{
set_d2_back();
b_line(string);
set_d2_front();
b_line(string);
}

show_char(font, c, x, y, color)
struct rast_font *font;
char c;
int x, y, color;
{
return(sh_char(c, x, y, color));
}


clip_text(string, x, xend, y, color)
register char *string;
register int x, xend, y, color;
{
if (string == NULL)
	return;
while (*string)
	{
	x = sh_char(*string++, x, y, color);
	}
}

gtext(string, x, y, color)
char *string;
int x, y, color;
{
clip_text(string, x, clipping_cube.X, y, color);
}

#endif EDITOR

#define R_NOP 5
#define R_CLR 0
#define R_SET 15
#define R_XOR 6
#define R_CPY 3
#define R_OR  7
#define R_SCOOP 4

xor_cursor(c, xoff, yoff, color)
register struct cursor *c;
int xoff, yoff, color;
{
register struct bbblock *b = &sd_bbb;

b->b_wd = c->width;
b->b_ht = c->height;
b->plane_ct = BITPLANES;
b->fg_col = color;
b->op_tab[0] = R_NOP;  /* fg = 0	bg = 0*/
b->op_tab[1] = R_NOP;  /* fg = 0	bg = 1*/
b->op_tab[2] = R_XOR;  /* fg = 1	bg = 0*/
b->op_tab[3] = R_XOR;  /* fg = 1	bg = 1*/
b->s_xmin = b->s_ymin = 0;
b->s_form = c->image;
b->d_form = cscreen;
b->s_nxwd = 2;
b->s_nxln = ((c->width + 15)>>4)<<1;
b->s_nxpl = 0;
b->d_xmin = xoff - c->xhot;
b->d_ymin = yoff - c->yhot;
if (dest_clip_block(b))
	ablit(b);
}


show_cel(c, xoff, yoff)
register struct atari_cel *c;
int xoff, yoff;
{
register struct bbblock *b = &sd_bbb;


copy_structure(c, b, sizeof(*c) );
b->op_tab[0] = b->op_tab[1] = b->op_tab[2] = b->op_tab[3] = 1; /*and*/
b->d_form = cscreen;
b->d_xmin = xoff;
b->d_ymin = yoff;
b->s_xmin = b->s_ymin = 0;
b->s_form = c->mask;
b->s_nxpl = 0;
b->s_nxwd = 2;
b->s_nxln = c->nxln>>2;
if (dest_clip_block(b))
	ablit(b);

b->b_wd = c->width;
b->b_ht = c->height;
b->plane_ct = BITPLANES;
b->op_tab[0] = b->op_tab[1] = b->op_tab[2] = b->op_tab[3] = R_XOR; /*replace*/
b->d_xmin = xoff;
b->d_ymin = yoff;
b->s_xmin = b->s_ymin = 0;
b->s_form = c->form;
b->s_nxpl = 2;
b->s_nxwd = 8;
b->s_nxln = c->nxln;
if (dest_clip_block(b))
	ablit(b);
}

draw_bitplane(bp, xoff, yoff,color)
register struct bit_plane *bp;
int xoff, yoff, color;
{
register struct bbblock *b = &sd_bbb;

b->b_wd = bp->width;
b->b_ht = bp->height;
b->plane_ct = BITPLANES;
b->fg_col = color;
b->op_tab[0] = 4;
b->op_tab[1] = 4;
b->op_tab[2] = 7;
b->op_tab[3] = 7;
b->s_xmin = b->s_ymin = 0;
b->s_form = bp->plane;
b->d_form = cscreen;
b->s_nxwd = 2;
b->s_nxln = ((bp->width + 15)>>4)<<1;
b->s_nxpl = 0;
b->d_xmin = xoff;
b->d_ymin = yoff;
if (dest_clip_block(b))
	ablit(b);
}

show_c_nohot(c, xoff, yoff, color)
register struct cursor *c;
int xoff, yoff, color;
{
register struct bbblock *b = &sd_bbb;

b->b_wd = c->width;
b->b_ht = c->height;
b->plane_ct = BITPLANES;
b->fg_col = color;
b->op_tab[0] = 4;
b->op_tab[1] = 4;
b->op_tab[2] = 7;
b->op_tab[3] = 7;
b->s_xmin = b->s_ymin = 0;
b->s_form = c->image;
b->d_form = cscreen;
b->s_nxwd = 2;
b->s_nxln = ((c->width + 15)>>4)<<1;
b->s_nxpl = 0;
b->d_xmin = xoff;
b->d_ymin = yoff;
if (dest_clip_block(b))
	ablit(b);
}

dest_clip_block(b)
register struct bbblock *b;
{
register WORD x2, y2;

if ((x2 = b->d_xmin) >= clipping_cube.X || 
	(y2 = b->d_ymin) >= clipping_cube.Y)
	return(0);
if ( (x2+=b->b_wd) <= clipping_cube.x || (y2+=b->b_ht) <= clipping_cube.y)
	return(0);
if (b->d_xmin < clipping_cube.x)
	{
	b->b_wd -= (clipping_cube.x - b->d_xmin);
	b->s_xmin += (clipping_cube.x - b->d_xmin);
	b->d_xmin = clipping_cube.x;
	}
if (b->d_ymin < clipping_cube.y)
	{
	b->b_ht -= (clipping_cube.y - b->d_ymin);
	b->s_ymin += (clipping_cube.y - b->d_ymin);
	b->d_ymin = clipping_cube.y;
	}
if (x2 > clipping_cube.X)
	b->b_wd -= x2-clipping_cube.X;
if (y2 > clipping_cube.Y)
	b->b_ht -= y2-clipping_cube.Y;
return(1);
}

show_cursor(c, x, y, color)
register struct cursor *c;
WORD x, y, color;
{
show_c_nohot(c, x - c->xhot, y - c->yhot, color);
}

clip_square(sq)
register Square *sq;
{
if (sq->x >= clipping_cube.X)
	return(0);
if (sq->y >= clipping_cube.Y)
	return(0);
if (sq->X <= clipping_cube.x)
	return(0);
if (sq->Y <= clipping_cube.y)
	return(0);
if (sq->x < clipping_cube.x)
	sq->x = clipping_cube.x;
if (sq->y < clipping_cube.y)
	sq->y = clipping_cube.y;
if (sq->X > clipping_cube.X)
	sq->X = clipping_cube.X;
if (sq->Y > clipping_cube.Y)
	sq->Y = clipping_cube.Y;
return(1);
}

swap_clip(pt)
register WORD *pt;
{
register WORD swap;


if (pt[0] > pt[2])
	{
	swap = pt[0];
	pt[0] = pt[2];
	pt[2] = swap;
	}
if (pt[1] > pt[3])
	{
	swap = pt[1];
	pt[1] = pt[3];
	pt[3] = swap;
	}
if (pt[0] >= clipping_cube.X)
	return(0);
if (pt[1] >= clipping_cube.Y)
	return(0);
if (pt[2] <= clipping_cube.x)
	return(0);
if (pt[3] <= clipping_cube.y)
	return(0);
if (pt[0] < clipping_cube.x)
	pt[0] = clipping_cube.x;
if (pt[1] < clipping_cube.y)
	pt[1] = clipping_cube.y;
if (pt[2] >= clipping_cube.X)
	pt[2] = clipping_cube.X-1;
if (pt[3] >= clipping_cube.Y)
	pt[3] = clipping_cube.Y-1;
return(1);
}

colblock(color, x1, y1, x2, y2)
WORD color;
WORD x1, y1, x2, y2;
{
register struct aline *a = aline;

if (!swap_clip(&x1))
	return;

set_acolor(color);
a->wmode = REPLACE;  
a->patptr = solid;
a->x1 = x1;
a->y1 = y1;
a->x2 = x2;
a->y2 = y2;
a->xmincl = a->ymincl = 0;
a->xmaxcl = XMAX;
a->ymaxcl = YMAX;
acblock();
}


colrop(color, x, y, width, height)
int color, x, y, width, height;
{
colblock(color, x, y, x+width, y+height);
}

#ifdef C_CODE
set_screen_to(v)
register long v;
{
extern WORD *cscreen;
register long *p;
register WORD i;

p = (long *)cscreen;
i = 32000/(2*sizeof(long));
while (--i >= 0)
	{
	*p++ = v;
	*p++ = v;
	}
}
#endif C_CODE

set_screen_to(v)
long v;
{
#ifndef SLUFF
asm	{
	move.l	cscreen(A4),A0	; get the screen location

	movem.l D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7) ; save the world

	move.l	v(A6),D1
	move.l  D1,D2
	move.l  D1,D3
	move.l  D1,D4
	move.l  D1,D5
	move.l  D1,D6
	move.l  D1,D7
	move.l  D1,A2
	move.l  D1,A3
	move.l  D1,A4	; stuff registers with value

	move.w #800-1,D0
cl_lp:	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,(A0)
	adda #40,A0
	dbf.w	D0,cl_lp

	movem.l (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4 ;restore the world
	}
#endif SLUFF
}

copy_screen(s, d)
long *s, *d;
{
#ifndef SLUFF
asm 	{
	movem.l D2/D3/D4/D5/D6/D7/A2/A3/A4,-(A7) ; save the world

	move.w #800-1,D0
	move.l s(A6),A0
	move.l d(A6),A1
cp_lp:  movem.l (A0)+,D1/D2/D3/D4/D5/D6/D7/A2/A3/A4
	movem.l D1/D2/D3/D4/D5/D6/D7/A2/A3/A4,(A1)
	adda	#40,A1
	dbf.w	D0,cp_lp

	movem.l (A7)+,D2/D3/D4/D5/D6/D7/A2/A3/A4
	}
#endif SLUFF
}

#ifdef LATER
while (--count >= 0)
	{
	*d++ = *s++;
	*d++ = *s++;
	*d++ = *s++;
	*d++ = *s++;
	*d++ = *s++;
	*d++ = *s++;
	*d++ = *s++;
	*d++ = *s++;
	}
}
#endif LATER

clear_screen()
{
extern WORD *cscreen;

#ifdef LATER
FCLEARSC(cscreen);
#endif LATER

if ( clipping_cube.x != safety_cube.x
	|| clipping_cube.y != safety_cube.y
	|| clipping_cube.X != safety_cube.X
	|| clipping_cube.Y != safety_cube.Y )
	{
	if (bbm != NULL)
	{
	copy_blit(clipping_cube.X - clipping_cube.x,
		clipping_cube.Y - clipping_cube.y,
		clipping_cube.x, clipping_cube.y,
		bbm, 160,
		clipping_cube.x, clipping_cube.y,
		cscreen, 160); 
	}
	else
	colblock(0, clipping_cube.x, clipping_cube.y,
		clipping_cube.X, clipping_cube.Y);
	}
else
	{
	if (bbm != NULL)
	copy_screen(bbm, cscreen);
	else
	set_screen_to((long)0);
	}
}


