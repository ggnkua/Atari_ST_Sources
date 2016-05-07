
#include "flicker.h"
#include "flicmenu.h"

/* Semi boring part of every menu with a shuttle bar */
extern struct flicmenu pxframes_sel, pxframe_sel, px_menu,
	pxtleft_time_sel, pxtright_time_sel, pxtsegment_sel;

pxadd_ten(m)
Flicmenu *m;
{
aadd_ten(m, &pxframes_sel, &pxframe_sel);
see_pxtsegment();
}

pxsee_times(m)
struct Flicmenu *m;
{
draw_sel(m);
draw_sel(&pxframe_sel);
draw_sel(&pxframes_sel);
show_mouse();
}

pxappend(m)
Flicmenu *m;
{
aappend(m);
pxsee_times(m);
see_pxtsegment();
}

pxinsert(m)
Flicmenu *m;
{
ainsert(m);
pxsee_times(m);
see_pxtsegment();
}

pxplay_forwards(m)
Flicmenu *m;
{
aplay_forwards(m, &pxframe_sel);
}

pxplay_backwards(m)
Flicmenu *m;
{
aplay_backwards(m, &pxframe_sel);
}

pxgo_first(m)
Flicmenu *m;
{
ago_first(m, &pxframe_sel);
}

pxgo_last(m)
Flicmenu *m;
{
ago_last(m, &pxframe_sel);
}


pxrewind(m)
Flicmenu *m;
{
arewind(m, &pxframe_sel);
}

pxfast_forward(m)
Flicmenu *m;
{
afast_forward(m, &pxframe_sel);
}

pxnext_frame(m)
Flicmenu *m;
{
amnext_frame(m, &pxframe_sel);
}

pxlast_frame(m)
Flicmenu *m;
{
amlast_frame(m, &pxframe_sel);
}

/* end of semi boring part of every menu with a shuttle bar */

/* start of boring time range selector part */

pxstuff_tv(m)
Flicmenu *m;
{
astuff_tv(m, &pxtsegment_sel);
}

pxdecl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, -1, &pxtleft_time_sel);
}

pxincl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, 1, &pxtleft_time_sel);
}

pxdecr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, -1, &pxtright_time_sel);
}

pxincr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, 1, &pxtright_time_sel);
}

see_pxtsegment()
{
hide_mouse();
draw_sel(&pxtsegment_sel);
show_mouse();
}

/* end of boring time range selector part */

unrez()
{
extern poster_screen();

simple_multi_screen(poster_screen);
}

munrez(m)
Flicmenu *m;
{
msetup();
unrez();
mrecover();
}

tile_screen()
{
WORD width, height;
WORD i, j;
WORD xoff, yoff, xstart, ystart;

width = x_1 - x_0;
height = y_1 - y_0;
ystart = y_0;
while (ystart > -height)
	ystart -= height;
ystart += height;
xstart = x_0;
while (xstart > -width)
	xstart -= width;
xstart += width;
for (yoff = ystart; yoff < YMAX; yoff += height)
	{
	for (xoff = xstart; xoff < XMAX; xoff += width)
		{
		copy_blit(width, height, x_0, y_0, cscreen, 160,
			xoff, yoff, cscreen, 160);
		}
	}
return(1);
}

tile()
{
if (define_box())
	simple_multi_screen(tile_screen);
}

mtile()
{
msetup();
tile();
mrecover();
}

whipe_one(so_far, in_tween)
WORD so_far, in_tween;
{
WORD count;

count = uscale_by(200, so_far, in_tween);
color_hslice(0, count, 0);
return(1);
}

dissolve_one(so_far, in_tween)
WORD so_far, in_tween;
{
register WORD y, i, count, j;


count = uscale_by(20, so_far, in_tween);
for (i=0; i<count; i++)
	{
	j = 10;
	y = i;
	while (--j >= 0)
		{
		hline(y, 0, XMAX-1, 0);	/* clear one line */
		y += 20;
		}
	}
return(1);
}


static Vector dissolver;

whipe_dis()
{
WORD old_tween_mode;

old_tween_mode = tween_mode;
tween_mode = 1;	/* always tween a dissolve */
msetup();
hide_mouse();
if (select_mode == 0)
	{
	copy_screen(cscreen, uscreen); /* save undo */
	(*dissolver)(1, 2);
	dirtys();
	}
else
	qdo_many(dissolver, 0);
show_mouse();
maybe_see_buffer();
mrecover();
tween_mode = old_tween_mode;
}

mdissolve()
{
dissolver = dissolve_one;
whipe_dis();
}

mwhipe()
{
dissolver = whipe_one;
whipe_dis();
}


go_px()
{
draw_a_menu(&px_menu);
do_menu(&px_menu);
}

