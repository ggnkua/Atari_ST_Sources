/* :ts=3 */
#include "flicker.h"

extern Pull root_pull;
extern char gemctable[];

WORD *draw_pull(), *save_behind();


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
colrop(black, x, y, p->width-1, p->height-2);
hline(y + p->height-1, x, x + p->width-1, white);
}

pull_oblock(x, y, p)
int x, y;
register Pull *p;
{
int x1, y1;

colrop(black, x+1, y+1, p->width-3, p->height-3);
x1 = x + p->width - 1;
y1 = y + p->height - 1;
hline(y, x, x1, white);
hline(y1, x, x1, white);
vline(x, y, y1, white);
vline(x1, y, y1, white);
}

pull_text(x, y, p)
int x, y;
register Pull *p;
{
extern WORD handle;
v_gtext(handle, x, y+7, p->data);
}

pull_brush(x, y, p)
int x, y;
register Pull *p;
{
draw_brush(brushes[(int)p->data], x+1, y+1, white);
}

WORD *
palloc(amount)
WORD amount;
{
WORD *pt;
amount += 2;
if ((pt = alloc(amount)) == NULL)
	return(NULL);
*pt = amount;
return (pt+1);
}

pfree(pt)
WORD *pt;
{
if (pt)
	{
	pt -= 1;
	mfree(pt, *pt);
	}
}

top_print(s)
char *s;
{
pull_block(root_pull.xoff, root_pull.yoff, &root_pull);
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
v_gtext(handle, 0, 7, s);
}

top_line(s)
char *s;
{
WORD *abehind;

unzoom();
hide_mouse();
if ((abehind = save_behind(root_pull.xoff, root_pull.yoff, &root_pull)) == NULL)
	return;	/* out of memory dudes */
top_print(s);
wait_a_jiffy(20);	/* 1/3 second before mouse move makes it go away */
show_mouse();
for (;;)
	{
	check_input();
	if (mouse_moved)
		break;
	if (key_hit)
		{
		reuse_input();
		break;
		}
	}
undraw_pull(root_pull.xoff, root_pull.yoff, &root_pull, abehind);
rezoom();
}

/* reset things some so can draw on physical screen in spite of zoom */
unzoom()
{
if (zoom_flag)	/* do some re-arranging so pulldowns are in our screen */
	{
	hide_mouse();
	zbuf_to_screen();
	draw_on_screen();
	show_mouse();
	zscale_cursor = 0;
	}
}

rezoom()
{
if (zoom_flag)	/* put things back for zoom maybe */
	{
	zscale_cursor = 1;
	hide_mouse();
	draw_on_buffer();
	show_mouse();
	}
}

init_menu_colors()
{
find_colors();
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
}


pull(p)
Pull *p;
{
WORD *abehind, *bbehind = NULL, *cbehind = NULL; /*buffers for
												menu-bar, drop-down, and
												hilit selection */
WORD cline_size, cbehind_size;  /* dimensions of hilight box in bytes */
WORD x, y;  /* root offset */
WORD cx, cy; /* offset of "menu" level lettering aka amiga terminology */
WORD ccx, ccy; /* offset of drop downs */
WORD sx, sy;	/* offset of selection */
WORD i, j;
WORD menu_down = -1;
WORD sel_hi = -1;
Pull *child;
Pull *cchild = NULL;
Pull *select = NULL;	
Pull *scratch;
WORD scx, scy;	/* scratch (selection) offset */
WORD pulled = -1;	/* the result */

if (!RDN)
	return(-1);
unzoom();
init_menu_colors();
x = p->xoff;
y = p->yoff;
if ((abehind = draw_pull(x, y, p)) == NULL)
	{
	pulled = -1;
	goto outta_pull;	/* out of memory dudes */
	}
for (;;)
	{
	check_input();
	if (key_hit)
		{
		reuse_input();
		break;
		}
	else if (RJSTDN)
		{
		wait_rup();
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
						if ((bbehind =  draw_pull(ccx, ccy, cchild) ) == NULL)
							{
							goto outta_pull;
							}
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
							cline_size = cbehind_size = Raster_line(scratch->width);
							cbehind_size *= scratch->height;
							if ( (cbehind = palloc(cbehind_size) ) == NULL)
								{
								goto outta_pul;
								}
							hide_mouse();
							copy_blit(scratch->width, scratch->height, scx, scy, 
							   cscreen,  160, 
								0, 0, cbehind, cline_size);
							draw_frame(red, scx, scy, scx+scratch->width-1,
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
	if (PDN)
		{
		if (select != NULL)
			{
			if (in_pblock(sx, sy, select))
				{
				pulled = (menu_down<<8)+sel_hi;
				}
			}
		wait_penup();
		break;
		}
	}
if (select)
	{
	undraw_pull(sx, sy, select, cbehind);
	}
outta_pul:
if (cchild)
	{
	undraw_pull(ccx, ccy, cchild, bbehind);
	}
outta_pull:
undraw_pull(x, y, p, abehind);
rezoom();
return(pulled);
}

undraw_pull(x, y, p, abehind)
register int x, y;
register Pull *p;
WORD *abehind;
{
WORD abehind_size;
WORD aline_size;

aline_size = abehind_size = Raster_line(p->width);
abehind_size *= p->height;
hide_mouse();
copy_blit(p->width, p->height, 0, 0, abehind, aline_size,
	x, y, cscreen, 160);
show_mouse();
pfree(abehind);
}

WORD *
save_behind(x, y, p)
register int x, y;
register Pull *p;
{
WORD *abehind;
WORD abehind_size;
WORD aline_size;

aline_size = abehind_size = Raster_line(p->width);
abehind_size *= p->height;
if ( (abehind = palloc(abehind_size) ) == NULL)
	return(NULL);	/* not enough memory */
copy_blit(p->width, p->height, x, y, cscreen,  160, 
	0, 0, abehind, aline_size);
return(abehind);
}


WORD *
draw_pull(x, y, p)
register int x, y;
register Pull *p;
{
WORD *abehind;

hide_mouse();
if ((abehind = save_behind(x, y, p)) == NULL)
	return(NULL);	/* not enough memory */
(*p->see)(x, y, p);
p = p->children;
while (p)
	{
	(*p->see)(x + p->xoff, y+p->yoff, p);
	p = p->next;
	}
show_mouse();
return(abehind);
}

unxmenu(p)
register Pull *p;
{
while (p)
	{
	p->data[0] = ' ';
	p = p->next;
	}
}

xone(p, one)
register Pull *p;
register int one;
{
while (--one >= 0)
	p = p->next;
p->data[0] = 'x';
}

xonflag(p, flag)
register Pull *p;
WORD flag;
{
if (flag)
	p->data[0] = 'x';
else
	p->data[0] = ' ';
}
