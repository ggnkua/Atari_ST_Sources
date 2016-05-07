
#include "flicker.h"
#include "flicmenu.h"

extern struct flicmenu cefx_menu, rcefx_menu, cxselmode_sel,
	cxframe_sel, cxframes_sel;

extern struct flicmenu cxtsegment_sel, cxtleft_time_sel, cxtright_time_sel;

extern struct flicmenu cxcbars_sel, cxsubmenu_sel, cxfade_sub_sel;

extern struct flicmenu cxnormal_sel, cxtint_sel, cxfpc_sel;
extern struct flicmenu cxpercent_sel;

extern WORD cx_sub_group, cfx_group, cxfade_mode, cxcyc_mode;
extern struct range csegment;

extern struct flicmenu cxcyc_sel, cxfra_sel;
extern struct slidepot cxcyc_sl, cxfra_sl, cxtinting_sl;



struct flicmenu *cxsubs[] = 
	{
	&cxfpc_sel, &cxtint_sel, &cxnormal_sel,
	};

change_cxsub(m)
Flicmenu *m;
{
change_mode(m);
cxsubmenu_sel.children = cxsubs[cx_sub_group];
draw_sub_menu(&cxsubmenu_sel);
}

cx_grab_color()
{
hide_mouse();
ccolor = getdot(mouse_x, mouse_y);
draw_sel(&cxcbars_sel);
show_mouse();
}

/* little routines for time segment adjuster */
cxstuff_tv(m)
Flicmenu *m;
{
astuff_tv(m, &cxtsegment_sel);
}

cxdecl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, -1, &cxtleft_time_sel);
}

cxincl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, 1, &cxtleft_time_sel);
}

cxdecr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, -1, &cxtright_time_sel);
}

cxincr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, 1, &cxtright_time_sel);
}


/******* Little Routines for Color Efx time shuttle bar... ******/

extern WORD save_cmap[COLORS];

cx_newframe()
{
copy_structure(sys_cmap, save_cmap, sizeof(save_cmap) );
}

cxsee_times(m)
struct Flicmenu *m;
{
if (m != NULL)
	draw_sel(m);
mmsee_slider(&cxframe_sel);
draw_sel(&cxframes_sel);
show_mouse();
}

cxplay_backwards(m)
Flicmenu *m;
{
aplay_backwards(m, &cxframe_sel);
cx_newframe();
}

cxplay_forwards(m)
Flicmenu *m;
{
aplay_forwards(m, &cxframe_sel);
cx_newframe();
}

cxrewind(m)
Flicmenu *m;
{
arewind(m, &cxframe_sel);
cx_newframe();
}

cxfast_forward(m)
Flicmenu *m;
{
afast_forward(m, &cxframe_sel);
cx_newframe();
}


cxgo_first(m)
struct Flicmenu *m;
{
ago_first(m, &cxframe_sel);
cx_newframe();
}

cxgo_last(m)
Flicmenu *m;
{
ago_last(m, &cxframe_sel);
cx_newframe();
}

cxlast_frame(m)
struct Flicmenu *m;
{
amlast_frame(m, &cxframe_sel);
cx_newframe();
}

cxnext_frame(m)
Flicmenu *m;
{
amnext_frame(m, &cxframe_sel);
cx_newframe();
}


cxinsert(m)
Flicmenu *m;
{
ainsert(m);
cxsee_times(m);
see_cxtsegment();
}

cxappend(m)
struct Flicmenu *m;
{
aappend(m);
cxsee_times(m);
see_cxtsegment();
}


cxfeel_slider(m)
Flicmenu *m;
{
mmfeel_slider(m);
cx_newframe();
}

see_cxtsegment()
{
hide_mouse();
draw_sel(&cxtsegment_sel);
show_mouse();
}

cxadd_ten(m)
Flicmenu *m;
{
aadd_ten(m, &cxframes_sel, &cxframe_sel);
see_cxtsegment();
}

/* The only two functions that do anything ... cxpreview and cxrender */
static unsigned WORD dv, v1, v2, render_time;
static WORD cycs, ccolor_abs;


cycle_words(pt, count)
register WORD *pt;
register WORD count;
{
WORD last;

last = pt[0];
while (--count > 0)
	{
	pt[0] = pt[1];
	pt++;
	}
pt[0] = last;
}

greyval(col)
register WORD col;
{

return( ((col&0x700)>>8)+((col&0x070)>>3)+((col&0x007)));
}

blend_percent(p, q, c1, c2)
WORD p, q;
WORD c1, c2;
{
register WORD r1,g1,b1,r2,g2,b2;
WORD i;

r1 = c2>>8;
g1 = (c2&0x070)>>4;
b1 = c2 & 0x7;
r2 = c1>>8;
g2 = (c1&0x070)>>4;
b2 = c1 & 0x7;
return( ((((r2*(q-p) + (r1*p))/q)<<8)&0x700) +
	((((g2*(q-p) + (g1*p))/q)<<4)&0x070) +
	(((b2*(q-p) + (b1*p))/q)&0x007));
}

static WORD *cmap1, *cmap2;

invert_c()
{
register WORD i;
register WORD *cm;

cm = sys_cmap+v1;
i = dv;
while (--i >= 0)
	*cm++ ^= 0x777;
}

mask_c(mask)
WORD mask;
{
register WORD i;
register WORD *cm;

cm = sys_cmap+v1;
i = dv;
while (--i >= 0)
	*cm++ &= mask;
}


mcx_func(i, ds)
WORD i, ds;
{
WORD grey;
WORD j;
WORD tween_i;

switch (cx_sub_group)
	{
	case 0:	/* cycle */
		{
		switch (cxcyc_mode)
			{
			case 0:	/* FPS */
				if (tween_mode)
					cycs = i/(cxfra_sl.value+1);
				else
					cycs = cxfra_sl.value+1;
				break;
			case 1:	/* CYC */
				if (tween_mode)
					cycs = (i*(cxcyc_sl.value+1)+ds/2)/ds;
				else
					cycs = cxcyc_sl.value+1;
				break;
			}
		cycs %= dv;
		if (csegment.v2 > csegment.v1)
			cycs = dv - cycs;
		while (cycs < 0)
			cycs = dv + cycs;
		while (--cycs >= 0)
			{
			cycle_words(sys_cmap+v1, dv);
			}
		}
		break;
	case 1: /* fade */
		switch (cxfade_mode)
			{
			case 0:	/* tint */
				tween_i = (tween_mode ? i : ds);
				tint_percent(tween_i*(cxtinting_sl.value+1), 
					ds*100, ccolor_abs);
				break;
			case 1:	/* blend */
				for (j=v1; j<=v2; j++)
					{
					sys_cmap[j] = blend_percent(i, ds, cmap1[j], cmap2[j]);
					}
				break;
			}
		break;
	case 2:	/* f/x */
		switch (cfx_group)
			{
			case 0: /* normal */
				copy_words(init_cmap+v1, sys_cmap+v1, dv);
				break;
			case 1: /* inverse */
				invert_c();
				break;
			case 2:	/* mono */
				for (j=v1; j<=v2; j++)
					{
					grey = greyval(sys_cmap[j]);
					sys_cmap[j] = 0x111*((grey*7+14)/28);
					}
				break;
			case 3: /* xerox */
				for (j=v1; j<=v2; j++)
					{
					grey = greyval(sys_cmap[j]);
					if (grey > 16)
						sys_cmap[j] = 0x777;
					else
						sys_cmap[j] = 0x000;
					}
				break;
			case 4:	/* chrome */
				for (j=v1; j<=v2; j++)
					{
					grey = greyval(sys_cmap[j])/4;
					grey &= 1;
					grey *= 0x777;
					sys_cmap[j] = grey;
					}
				break;
			case 5: /* metal */
				for (j=v1; j<=v2; j++)
					{
					grey = greyval(sys_cmap[j])/8;
					grey &= 1;
					grey *= 0x777;
					sys_cmap[j] = grey;
					}
				break;
			case 6:
				mask_c(0x700);	/* red */
				break;
			case 7:
				mask_c(0x070);	/* green */
				break;
			case 8:
				mask_c(0x007);	/* blue */
				break;
			}
		break;
	}
qput_cmap(sys_cmap);
return(1);
}

cefx_many()
{
extern struct slidepot speed_sl;

WORD start, end, count;
register WORD ds;
WORD direction;
WORD i;
WORD oscreen_ix;
WORD x, y;
register long desttime;

hide_mouse();
clean_ram_deltas(cscreen);
if (select_mode == 1)	/* over segment */
	{
	clip_trange();
	start = trange.v1-1;
	end = trange.v2-1;
	direction = ( start < end ? 1 : -1 );
	count  = ds = (end - start)*direction;
	count += 1;
	}
else
	{
	start = 0;
	count = ds = end = screen_ct;
	end -= 1;
	direction = 1;
	ds -= 1;
	}
cmap1 = ram_screens[start];
cmap2 = ram_screens[end];
oscreen_ix = screen_ix;
tseek(start, cscreen);
if (render_time)
	dirty_file = 1;
else
	desttime = get60hz() + speed_sl.value+1;
for (i=0; i<count; i++)
	{
	if (ds == 0)
		mcx_func(1, 1);
	else
		mcx_func( i , ds);
	if (render_time)
		copy_words(sys_cmap, ram_screens[screen_ix], COLORS);
	screen_ix += direction;
	if (screen_ix < 0 || screen_ix >= screen_ct)
		{
		screen_ix -= direction;
		break;
		}
	if (direction > 0)
		advance_next_prev(cscreen);
	else
		retreat_next_prev(cscreen);
	if (!render_time)
		{
		for (;;)
			{
			check_input();
			if (RJSTDN || key_hit)
				goto OUTTA_HERE;
			if (get60hz() >= desttime)
				break;
			}
		desttime += speed_sl.value+1;
		}
	ncsee_frame(cscreen, direction);
	copy_words(ram_screens[screen_ix], sys_cmap, COLORS);
	refresh_zoom();
	}
OUTTA_HERE:
abs_tseek(oscreen_ix, cscreen);
#ifdef LATER
cx_newframe();
#endif LATER
copy_screen(cscreen, uscreen);
refresh_zoom();
show_mouse();
}


cxprerender(m, render)
Flicmenu *m;
WORD render;
{
WORD cmap[COLORS];

hide_mouse();
hilight(m);
render_time = render;
ccolor_abs = sys_cmap[ccolor];
if (csegment.v1 <= csegment.v2)
	{
	v1 = csegment.v1;
	v2 = csegment.v2;
	}
else
	{
	v1 = csegment.v2;
	v2 = csegment.v1;
	}
dv = v2 - v1 + 1;
copy_screen(bscreen, pscreen);
nohblanks();
if (select_mode == 0)
	{
	copy_words(sys_cmap, cmap, COLORS);
	cmap1 = cmap2 = cmap;
	mcx_func(1, 1);
	wait_penup();
	if (!render)
		put_cmap(cmap);
	else
		dirtys();
	}
else
	{
	cefx_many();
	}
redraw_menu_frame();
sput_cmap();
draw_sel(m);
show_mouse();
}

cxpreview(m)
Flicmenu *m;
{
cxprerender(m,0);
}

cxrender(m)
Flicmenu *m;
{
if (really_render())
	cxprerender(m,1);
}

cxrestore(m)
Flicmenu *m;
{
put_cmap(save_cmap);
}

jump_palette(m)
Flicmenu *m;
{
return_dummy_key(m, '@');
}

go_cefx()
{
restore_dummy();
draw_a_menu(&cefx_menu);
do_menu(&cefx_menu);
}

