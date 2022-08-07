/* :ts=3 */
#include "..\\include\\lists.h"
#include "..\\include\\io.h"
#include "..\\include\\pull.h"
#include "..\\include\\menu.h"
#include "..\\include\\vmodes.h"
#include "..\\include\\drawmode.h"
#include "..\\include\\poly.h"

overlay "find"


extern struct menu morph_m;
extern WORD fore_color, back_color, hi_color;
extern WORD *cscreen;
extern WORD bop_mode;
extern WORD draw_mode;
extern WORD v_mode;
extern WORD s_mode;
extern WORD w_mode;
extern WORD ghost_mode;
extern WORD see_beginning;
extern WORD help_on;
extern WORD z_direction;
extern char gemctable[];
extern WORD rotate_axis;
extern WORD exchange_mode;
extern WORD handle;

#include "pulldata.i"

in_pblock(x, y, p)
int x, y;
register Pull *p;
{
if (mouse_x >= x && mouse_y >= y)
	{
	x += p->width;
	y += p->height;
	if (mouse_x <= x && mouse_y <= y)
		return(1);
	}
return(0);
}

pull_color(x, y, p)
int x, y;
register Pull *p;
{
colrop((int )p->data, x, y, p->width-1, p->height-1);
}


pull_block(x, y, p)
int x, y;
register Pull *p;
{
colrop(fore_color, x, y, p->width-1, p->height-2);
hline(y + p->height-1, x, x + p->width-1, back_color);
}

pull_oblock(x, y, p)
int x, y;
register Pull *p;
{
int x1, y1;

colrop(fore_color, x+1, y+1, p->width-3, p->height-3);
x1 = x + p->width - 1;
y1 = y + p->height - 1;
hline(y, x, x1, back_color);
hline(y1, x, x1, back_color);
vline(x, y, y1, back_color);
vline(x1, y, y1, back_color);
}

pull_text(x, y, p)
int x, y;
register Pull *p;
{
extern WORD handle;
v_gtext(handle, x, y+7, p->data);
}

/*buffers for menu-bar, drop-down, and hilit selection */
WORD *abehind, *bbehind, *cbehind;

pull(p)
Pull *p;
{
WORD cline_size;  /* dimensions of hilight box in bytes */
WORD x, y;  /* root offset */
WORD cx, cy; /* offset of "menu" level lettering aka amiga terminology */
WORD ccx, ccy; /* offset of drop downs */
WORD sx, sy;	/* offset of selection */
WORD i, j;
WORD menu_down;
WORD sel_hi;
register Pull *child;
Pull *cchild;
Pull *select;	
register Pull *scratch;
register WORD scx, scy;	/* scratch (selection) offset */
WORD pulled;	/* the result */

find_colors();
vst_color(handle, gemctable[back_color]);
vswr_mode(handle, 2);
cchild = select = NULL;
menu_down = sel_hi = pulled = -1;
x = p->xoff;
y = p->yoff;
draw_pull(x, y, p, abehind);
for (;;)
	{
	sample_input();
	if (keypress(&virtual))
		{
		reuse_input();
		break;
		}
	else if (cancel(&virtual))
		{
		break;
		}
	else
		{
		child = p->children;
		i = 0;
		while (child)
			{
			cx = x + child->xoff;
			cy = y + child->yoff;
			if (in_pblock(cx, cy, child))
				{
				if (menu_down != i)
					{
					if (select)
						{
						undraw_pull(sx, sy, select, cbehind);
						select = NULL;
						sel_hi = -1;
						}
					if (cchild)
						{
						undraw_pull(ccx, ccy,  cchild, bbehind);
						}
					if ((cchild = child->children) != NULL)
						{
						ccx = cx + cchild->xoff;
						ccy = cy + cchild->yoff;
						draw_pull(ccx, ccy, cchild, bbehind);
						}
					menu_down = i;
					}
				break;
				}
next_child:
			child = child->next;
			i++;
			}
		if (cchild  != NULL)
			{
			if (in_pblock(ccx, ccy, cchild))
				{
				scratch = cchild->children;
				j = 0;
				while (scratch)
					{
					scx = ccx + scratch->xoff;
					scy = ccy + scratch->yoff;
					if (in_pblock(scx, scy, scratch))
						{
						if (sel_hi != j)
							{
							if (select)
								{
								undraw_pull(sx, sy, select, cbehind);
								}
							select = scratch;
							sx = scx;
							sy = scy;
							sel_hi = j;
							cline_size = Raster_line(scratch->width);
							hide_mouse();
							copy_blit(scratch->width, scratch->height, scx, scy, 
							   cscreen,  160, 
								0, 0, cbehind, cline_size);
							draw_frame(hi_color, scx, scy, scx+scratch->width-1,
								scy+scratch->height-1);
							show_mouse();
							}
						goto maybe_pulled;
						}
					scratch = scratch->next;
					j++;
					}
				}
			}
		}
maybe_pulled:
	if (pdn(&virtual))
		{
		if (select != NULL)
			{
			if (in_pblock(sx, sy, select))
				{
				pulled = (menu_down<<8)+sel_hi;
				}
			}
		await_penup();
		break;
		}
	}
if (select)
	{
	undraw_pull(sx, sy, select, cbehind);
	}
if (cchild)
	{
	undraw_pull(ccx, ccy, cchild, bbehind);
	}
undraw_pull(x, y, p, abehind);
return(pulled);
}

undraw_pull(x, y, p, behind)
register int x, y;
register Pull *p;
WORD *behind;
{
WORD aline_size;

aline_size = Raster_line(p->width);
hide_mouse();
copy_blit(p->width, p->height, 0, 0, behind, aline_size,
	x, y, cscreen, 160);
show_mouse();
}

draw_pull(x, y, p, behind)
register int x, y;
register Pull *p;
WORD *behind;	/*buffer to put behind into */
{
WORD aline_size;

aline_size = Raster_line(p->width);
hide_mouse();
copy_blit(p->width, p->height, x, y, cscreen,  160, 
	0, 0, behind, aline_size);
(*p->see)(x, y, p);
p = p->children;
while (p)
	{
	(*p->see)(x + p->xoff, y+p->yoff, p);
	p = p->next;
	}
show_mouse();
}

#define xit(p) p.data[0] = 'x'

unx_menu(p)
register Pull *p;
{
while (p)
	{
	p->data[0] = ' ';
	p = p->next;
	}
}

unx_pull()
{
unx_menu(&aboutani1_pull);
unx_menu(&polygon_pull);
unx_menu(&sideways_pull);
unx_menu(&ppoint_pull);
unx_menu(&nexttween_pull);
}

xone_pull(p, one)
register Pull *p;
WORD one;
{
while (--one >= 0)
	p = p->next;
p->data[0] = 'x';
}

#define VZ_IX 13
#define VROT_IX	16

mmenu_hilights()
{
register WORD i;

set_rot_curs(morph_table + VROT_IX);
set_z_curs(morph_table + VZ_IX);
unx_pull();

switch (v_mode)
	{
	case VSPIKE:
	switch (draw_mode)
		{
		case FREE_HAND:
			xit(polygon_pull);
			break;
		case CIRCLE:
			xit(circle_pull);
			break;
		case STAR:
			xit(star_pull);
			break;
		case BLOCK:
			xit(block_pull);
			break;
		}
		break;
	case VLOOP:
		xit(loop_pull);
		break;
	case VHOOK:
		xit(hook_pull);
		break;
	case VMOVE:
		xit(sideways_pull);
		break;
	case VROTATE:
		switch (rotate_axis)
			{
			case 'x':
				xit(xrotate_pull);
				break;
	 		case 'y':
				xit(yrotate_pull);
				break;
			case 'z':
				xit(rotate_pull);
				break;
			}
		break;
	case VSIZE:
		xit(bigsmall_pull);
		break;
	case VCLONE:
		xit(clone_pull);
		break;
	case VKILL:
		xit(destroy_pull);
		break;
	case VCOLOR:
		xit(changecolor_pull);
		break;
	case VBOP:
		switch (bop_mode)
			{
			case FILLED:
				xit(makefilled_pull);
				break;
			case OUT_LINE:
				xit(makeoutline_pull);
				break;
			case JUST_LINE:
				xit(makeline_pull);
				break;
			}
		break;
	case VZ:
		switch (z_direction)
			{
			case 'd':
				xit(intoscreen_pull);
				break;
			case 'u':
				xit(outofscreen_pull);
				break;
			}
		break;
	case VSAMPLE:
		xit(alongpath_pull);
		break;
	}
xone_pull(&ppoint_pull, s_mode);
xone_pull(&filled_pull, bop_mode);
xone_pull(&insert_pull, exchange_mode);
if (help_on)
	xit(helpbar_pull);
if (morph_m.visible)
	xit(fastmenu_pull);
if (ghost_mode)
	xit(ghost_pull);
xone_pull(&atend_pull, see_beginning);
}

amenu_hilights()
{
register int i;

unx_menu(&gointo_pull);
switch (w_mode)
	{
	case WEDIT:
		xit(gointo_pull);
		break;
	case WSPLICE:
		xit(splice_pull);
		break;
	case WSCISSORS:
		xit(cut_pull);
		break;
	case WKILL:
		xit(delete2_pull);
		break;
	case WACTIVATE:
		xit(activate_pull);
		break;
	}
}

init_pulls()
{
mmenu_hilights();
amenu_hilights();
/* allocate abc behinds to be largest in menu structure ... not very
   maintainable, but I'm running short on memory today... */
if ((abehind = alloc(Raster_block(320, 10))) == NULL)
	return(0);
if ((bbehind = alloc(Raster_block( 2+15*CH_WIDTH, 2+14*CH_HEIGHT))) == NULL)
	return(0);
if ((cbehind = alloc(Raster_block(15*CH_WIDTH, CH_HEIGHT))) == NULL)
	return(0);
return(1);
}
