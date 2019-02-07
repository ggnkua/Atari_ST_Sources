
#include <osbind.h>
#include <aline.h>
#include "kamikaze.h"

#define REPLACE 1
#define XOR	2


char gemctable[16] = 
	{
	0, 2, 3, 6, 4, 7, 5, 8, 9, 0xa, 0xb, 0xe, 0xc, 0xf, 0xd, 1,
	};


WORD solid[] = {0xffff, 0xffff, 0xffff, 0xffff,
		 0xffff, 0xffff, 0xffff, 0xffff};

get_cmap(cmap)
register WORD *cmap;
{
register int i;

for (i=0; i<16; i++)
	*cmap++ = Setcolor(i, -1);
}

flash_color(color)
int color;
{
int ocolor;

ocolor =  Setcolor(0, -1);
Setcolor(0, color);
wait_a_jiffy(8);
Setcolor(0, ocolor);
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

gblock(color, mode, x, y, width, height)
WORD color, mode;
WORD x, y, width, height;
{
register struct aline *a = aline;

set_acolor(color);
a->wmode = mode;  
a->patptr = solid;
a->x1 = x;
a->y1 = y;
a->x2 = x+width-1;
a->y2 = y+height-1;
a->xmincl = a->ymincl = 0;
a->xmaxcl = XMAX;
a->ymaxcl = YMAX;
acblock();
}

colored_block(color, x, y, width, height)
WORD color;
WORD x, y, width, height;
{
gblock(color, REPLACE, x, y, width, height);
}


xor_block(color, x, y, width, height)
WORD color;
WORD x, y, width, height;
{
gblock(color, XOR, x, y, width, height);
}

clear_screen()
{
stuff_words(cscreen, 0, 16000);
}

show_piece(p, xoff, yoff, color)
register unsigned WORD *p;
int xoff, yoff, color;
{
struct bbblock b;

b.b_wd = 27;
b.b_ht = 23;
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
b.s_form = (WORD *)p;
b.s_nxwd = 2;
b.s_nxln = 4;
b.s_nxpl = 0;
b.d_nxpl = 2;
b.d_nxwd = BITPLANES*2;
b.d_nxln = 160;
b.p_addr = NULL;
ablit(&b);
}

gtext(s, x, y, color)
char *s;
WORD x, y;
WORD color;
{
vst_color(handle, gemctable[color]);
vswr_mode(handle, 0);
v_gtext(handle, x, y+7, s);
}

italic_font()
{
vst_effects(handle, 4);
}

unitalic_font()
{
vst_effects(handle, 0);
}

small_font()
{
WORD ch_width, ch_height, cl_width, cl_height;

vst_height(handle, 4, &ch_width, &ch_height, &cl_width, &cl_height);
}


big_font()
{
WORD ch_width, ch_height, cl_width, cl_height;


vst_height(handle, 12, &ch_width, &ch_height, &cl_width, &cl_height);
}

normal_font()
{
WORD ch_width, ch_height, cl_width, cl_height;

vst_height(handle, 6, &ch_width, &ch_height, &cl_width, &cl_height);
}

