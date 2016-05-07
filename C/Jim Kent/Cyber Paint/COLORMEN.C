
#include "flicker.h"
#include "flicmenu.h"
#include <osbind.h>

extern Flicmenu color_menu, r_sel, g_sel, b_sel, hls_sel, rgb_sel,
	cmcbars_sel, cframe_sel, cframes_sel;
extern struct slidepot r_sl, g_sl, b_sl;
extern struct range csegment;
extern WORD hls_mode;
extern struct grid cb_grid;
extern see_n1_slider(), see_islidepot();

extern WORD sys_cmap[];

WORD save_cmap[COLORS];

#ifdef SLUFFED
WORD seg_cmap[COLORS];
#endif SLUFFED

WORD multi_cmap[COLORS];
WORD color_clip_buf[COLORS];
WORD ccb_v1, ccb_v2;

#ifdef SLUFFED
static WORD mcm_v1, mcm_v2;
#endif SLUFFED

char cmulti_tracker[COLORS];	/* keeps track of colors changed */
char any_cmulti;

zero_cmulti_tracker()
{
word_zero(cmulti_tracker, COLORS/2);
any_cmulti = 0;
}

char *render_cmulti_lines[] =
	{
	"Propagate color changes",
	"so far over all frames?",
	"      (no undo)",
	NULL,
	};

really_cmulti()
{
if (select_mode == 1)	/* over segment */
	return(really_segment("Propagate color changes?", "    (no undo)"));
else if (select_mode == 2) /* over all */
	return(yes_no_from(render_cmulti_lines) );
return(1);
}


flush_cmulti_tracker()
{
WORD result;

result = 1;
if (any_cmulti)
	{
	if (result = really_cmulti())
		{
		hide_mouse();
		clear_top_lines();
		see_buffer();
		show_mouse();
		update_from_cmulti();
		zero_cmulti_tracker();
		redraw_menu_frame();
		set_top_lines();
		}
	else
		{
		if (yes_no_line("Ignore changes to palette?"))
			{
			put_cmap(save_cmap);	/* restore color map before this op */
			zero_cmulti_tracker();
			result = 1;
			}
		}
	}
return(result);
}


/* mcm_func - function called by doit_many_times to propogate changes
   in the color map... */
mcm_func(i, ds)
WORD i, ds;
{
register WORD c;
register WORD *s, *d;
register char *mask;

mask = cmulti_tracker;
s = multi_cmap;
d = sys_cmap;
c = COLORS;
while (--c >= 0)
	{
	if (*mask++)
		{
		*d++ = *s++;
		}
	else
		{
		s += 1;
		d += 1;
		}
	}
qput_cmap(sys_cmap);
}


cmult_range(v1, v2)
WORD v1, v2;
{
WORD i;

if (v1 > v2)
	{
	i = v1;
	v1 = v2;
	v2 = i;
	}
for (i = v1; i <= v2; i++)
	{
	cmulti_tracker[i] = 1;
	}
any_cmulti = 1;
}

confirm_c_many(v1, v2)
WORD v1, v2;	/* endpoints of color range to do... */
{
nohblanks();
if (over_many())
	{
	zero_cmulti_tracker();
	cmult_range(v1, v2);
	update_from_cmulti();
	}
else
	put_cmap(save_cmap);	/* restore color map before this op */
}


update_from_cmulti()
{
WORD user_ok;

if (select_mode == 0)
	return;	/* nothing much to do in to frames mode */
nohblanks();
copy_words(sys_cmap, multi_cmap, COLORS);	/* get a copy ... */
put_cmap(save_cmap);	/* restore color map before this op */
hide_mouse();
copy_screen(bscreen, pscreen);
do_many_times(mcm_func, 0, 1);
copy_structure(sys_cmap, save_cmap, sizeof(save_cmap) );
}


restore_colors()
{
put_cmap(save_cmap);
init_cslider_values();
draw_a_menu(&color_menu);
}

#ifdef SLUFFED
/* little subroutine to save some space */
redraw_cm1()
{
put_cmap(sys_cmap);
draw_a_menu(&color_menu);
}
#endif SLUFFED

#ifdef SLUFFED
/* another little subroutine to save some space */
redraw_cm()
{
set_top_lines();	/* to get back hblank interrupt */
init_cslider_values();
redraw_cm1();
}
#endif SLUFFED

hls_for_ccolor()
{
register WORD abs;
WORD r, g, b;

abs = sys_cmap[ccolor];
r = abs>>8;
g = (abs&0x0f0)>>4;
b = abs & 0xf;
rgb_to_hls(r, g, b, 
	&r_sl.value, &g_sl.value, &b_sl.value);
}

rgb_for_ccolor()
{
register WORD abs;

abs = sys_cmap[ccolor];
r_sl.value = abs>>8;
g_sl.value = (abs&0x0f0)>>4;
b_sl.value = abs & 0xf;
}

init_cslider_values()
{
if (hls_mode)
	hls_for_ccolor();
else
	rgb_for_ccolor();
}

update_hls(val, comp)
register WORD val;
WORD comp;
{
WORD r,g,b;
WORD abs;

switch (comp)
	{
	case 0:	/* h */
		r_sl.value = val;
		break;
	case 1:
		g_sl.value = val;
		break;
	case 2:
		b_sl.value = val;
		break;
	}
hls_to_rgb(&r,&g,&b, r_sl.value, g_sl.value, b_sl.value);
sys_cmap[ccolor] = abs = (r<<8) + (g<<4) + b;
put_cmap(sys_cmap);
}


update_rgb(val, comp)
register WORD val;
WORD comp;
{
WORD r, g, b;
register WORD abs;

abs = sys_cmap[ccolor];
r = abs>>8;
g = (abs&0x0f0)>>4;
b = abs & 0xf;
switch (comp)
	{
	case 0:
		r = val;
		break;
	case 1:
		g = val;
		break;
	case 2:
		b = val;
		break;
	}
sys_cmap[ccolor] = abs = (r<<8) + (g<<4) + b;
put_cmap(sys_cmap);
}

update_cslider_values(val, comp)
WORD val, comp;
{
if (hls_mode)
	update_hls(val, comp);
else
	update_rgb(val, comp);
}

static Flicmenu *asl;
static WORD comp;

inc_rgb_sl()
{
struct slidepot *sl;

sl = (struct slidepot *)asl->text;
if (sl->value < sl->max)
	{
	sl->value++;
	update_cslider_values((WORD)sl->value, comp);
	draw_sel(asl);
	}
}

dec_rgb_sl()
{
struct slidepot *sl;

sl = (struct slidepot *)asl->text;
if (sl->value > sl->min)
	{
	--sl->value;
	update_cslider_values((WORD)sl->value, comp);
	draw_sel(asl);
	}
}


inc_rgb(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
comp = m->identity;
asl = (Flicmenu *)m->text;
repeat_on_pdn(inc_rgb_sl);
cmult_range(ccolor, ccolor);
draw_sel(m);
show_mouse();
}

dec_rgb(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
comp = m->identity;
asl = (Flicmenu *)m->text;
repeat_on_pdn(dec_rgb_sl);
cmult_range(ccolor, ccolor);
draw_sel(m);
show_mouse();
}

use_clip_col(m)
Flicmenu *m;
{
if (clipping != NULL)
	{
	hide_mouse();
	hilight(m);
	copy_words(clipping->cmap, sys_cmap, COLORS);
	put_cmap(sys_cmap);
	cmult_range(0, COLORS-1);
	wait_penup();
	dirtys();
	draw_sel(m);
	show_mouse();
	}
}

change_rgb(m, comp)
struct flicmenu *m;
WORD comp;	/* 0 = r, 1 = g, 2 = b */
{
register struct slidepot *s;
#ifdef NOINT
WORD oblack, owhite;

oblack = black;
owhite = white;
#endif NOINT
s = (struct slidepot *)m->text;
update_number_slider(m);
update_cslider_values(s->value, comp);
for (;;)
	{
	check_input();
	if (!PDN)
		break;
	if (mouse_moved)
		{
		update_number_slider(m);
		update_cslider_values(s->value, comp);
		}
	}
find_colors();
dirtys();
cmult_range(ccolor, ccolor);
}

copy_ccolor(m)
Flicmenu *m;
{
WORD color;

hide_mouse();
hilight(m);
show_mouse();
wait_penup();
wait_ednkey();
if (PDN)
	{
	/* save copy of current cmap for multi-seg restore */
	hide_mouse();
	color = getdot(mouse_x, mouse_y);
	show_mouse();
	sys_cmap[color] = sys_cmap[ccolor];
	resee_csliders();
	put_cmap(sys_cmap);
	dirtys();
	cmult_range(color, color);
	}
hide_mouse();
draw_sel(m);
show_mouse();
}

change_r(m)
struct flicmenu *m;
{
change_rgb(m, 0);
}

change_g(m)
struct flicmenu *m;
{
change_rgb(m, 1);
}

change_b(m)
struct flicmenu *m;
{
change_rgb(m, 2);
}

static WORD start, stop;

find_csegstart()
{
if (csegment.v1 < csegment.v2)
	{
	start = csegment.v1;
	stop = csegment.v2;
	}
else
	{
	start = csegment.v2;
	stop = csegment.v1;
	}
}

#ifdef SLUFFED
do_tint()
{
tint_percent(30,100, sys_cmap[ccolor]);
dirtys();
put_cmap(sys_cmap);
resee_csliders();
cmult_range(start, stop);
}
#endif SLUFFED

tint_percent(p, q, abs)	/* merge color segment with 1/3 of ccolor */
WORD p, q;
register WORD abs;
{
register WORD r1,g1,b1,r2,g2,b2;
WORD i;

find_csegstart();
r1 = abs>>8;
g1 = (abs&0x070)>>4;
b1 = abs & 0x7;
for (i=start; i<=stop; i++)
	{
	abs = sys_cmap[i];
	r2 = abs>>8;
	g2 = (abs&0x070)>>4;
	b2 = abs & 0x7;
	sys_cmap[i] =
		((((r2*(q-p) + (r1*p))/q)<<8)&0x700) +
		((((g2*(q-p) + (g1*p))/q)<<4)&0x070) +
		(((b2*(q-p) + (b1*p))/q)&0x007);
	}
}

make_range()
{
if (hls_mode)
	hls_range();
else
	rgb_range();
dirtys();
cmult_range(csegment.v1, csegment.v2);
}

#ifdef SLUFFED
inverse_seg()
{
invert_cseg();
dirtys();
cmult_range(csegment.v1, csegment.v2);
put_cmap(sys_cmap);
resee_csliders();
}

invert_cseg()
{
register WORD i;

find_csegstart();
for (i=start; i<=stop; i++)
	sys_cmap[i] ^= 0x777;	/* invert the components */
}
#endif SLUFFED


rgb_range()
{
WORD dc;
register WORD start, stop;
WORD r1,g1,b1,r2,g2,b2;
register WORD abs;
WORD i;

if (csegment.v1 < csegment.v2)
	{
	start = csegment.v1;
	stop = csegment.v2;
	}
else
	{
	start = csegment.v2;
	stop = csegment.v1;
	}
abs = sys_cmap[start];
r1 = abs>>8;
g1 = (abs&0x0f0)>>4;
b1 = abs & 0xf;
abs = sys_cmap[stop];
r2 = abs>>8;
g2 = (abs&0x0f0)>>4;
b2 = abs & 0xf;
dc = stop-start;
for (i=start+1; i<stop; i++)
	{
	sys_cmap[i] =
		((((r1*(stop-i) + r2*(i-start))/dc)<<8)&0xf00) +
		((((g1*(stop-i) + g2*(i-start))/dc)<<4)&0x0f0) +
		(((b1*(stop-i) + b2*(i-start))/dc)&0x00f);
	}
put_cmap(sys_cmap);
resee_csliders();
}

#ifdef SLUFFED
cycle_seg()
{
WORD first;
register WORD *cm;
register WORD dir;
register WORD i;

i = csegment.v1 - csegment.v2;
dir = 1;
if (i < 0)
	{
	dir = -1;
	i = -i;
	}
cm = sys_cmap + csegment.v2;
first = cm[0];
while (--i >= 0)
	{
	cm[0] = cm[dir];
	cm += dir;
	}
cm[0] = first;
put_cmap(sys_cmap);
resee_csliders();
dirtys();
cmult_range(csegment.v1, csegment.v2);
}
#endif SLUFFED

color_clip(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
copy_words(sys_cmap, color_clip_buf, COLORS);
ccb_v1 = csegment.v1;
ccb_v2 = csegment.v2;
wait_a_jiffy(2);
draw_sel(m);
show_mouse();
}

color_paste(m)
Flicmenu *m;
{
WORD sdir, ddir, scount, dcount, i, six, dix;

hide_mouse();
hilight(m);
scount = ccb_v2 - ccb_v1;
if (scount < 0)
	{
	scount = -scount;
	sdir= -1;
	}
else
	sdir= 1;

dcount = csegment.v2 - csegment.v1;
if (dcount < 0)
	{
	dcount = -dcount;
	ddir = -1;
	}
else
	ddir = 1;

dcount += 1;
scount += 1;
if (dcount < scount)
	scount = dcount;
i = scount;
dix = csegment.v1;
six = ccb_v1;
while (--i >= 0)
	{
	sys_cmap[dix] = color_clip_buf[six];
	dix += ddir;
	six += sdir;
	}
dirtys();
put_cmap(sys_cmap);
cmult_range(csegment.v1, csegment.v2);
wait_a_jiffy(2);
draw_sel(m);
show_mouse();
}





hls_range()
{
register WORD col;
register WORD i;
register WORD abs;
register WORD inc;
WORD dc, dh, dl, ds;
WORD inith, initl, inits;
WORD start_col, stop_col;
WORD r,g,b;
WORD h,l,s;

if (csegment.v1 != csegment.v2)
	{
	col = start_col = csegment.v1;
	stop_col = csegment.v2;
	if (csegment.v1 > csegment.v2)
		{
		inc = -1;
		}
	else
		{
		inc = 1;
		}
	dc = absval(csegment.v2 - csegment.v1);
	abs = sys_cmap[stop_col];
	r = abs>>8;
	g = (abs&0x0f0)>>4;
	b = abs & 0xf;
	rgb_to_hls(r,g,b,&dh,&dl,&ds);
	abs = sys_cmap[start_col];
	r = abs>>8;
	g = (abs&0x0f0)>>4;
	b = abs & 0xf;
	rgb_to_hls(r,g,b,&inith,&initl,&inits);
	dh -= inith;
	dl -= initl;
	ds -= inits;
	while (dh <= 0)
		dh += 255;
	col += inc;

	for (i=1; i< dc; i++)
		{
		h = inith + dh*i/dc;
		l = initl + dl*i/dc;
		s = inits + ds*i/dc;
		hls_to_rgb(&r,&g,&b,h,l,s);
		sys_cmap[col] = (r<<8) + (g<<4) + b;
		col += inc;
		}
	put_cmap(sys_cmap);
	resee_csliders();
	}
}


change_csegment(m)
struct flicmenu *m;
{
move_range(m);
init_cycle();
}

draw_csliders()
{
draw_sel(&r_sel);
draw_sel(&g_sel);
draw_sel(&b_sel);
}


cg_color(col)
register WORD col;
{
WORD where[4];

center_grid(&cmcbars_sel, ccolor, where, cb_grid.divx, cb_grid.divy);
center_grid(&cmcbars_sel, col, where+2, cb_grid.divx, cb_grid.divy);
hide_mouse();
putdot(where[0], where[1], ccolor);
putdot(where[2], where[3], oppositec[col] );
ccolor = col;
resee_csliders();
}

change_color(m)
struct flicmenu *m;
{
register WORD col;

col = find_grid(m);
if (col >= 0)
	{
	cg_color(col);
	}
}

cm_grab_color()
{
hide_mouse();
ccolor = getdot(mouse_x, mouse_y);
resee_csliders();
draw_sel(&cmcbars_sel);
}

xhls_mode(m)
struct flicmenu *m;
{
hide_mouse();
hls_mode = m->identity;
if (hls_mode)
	{
	r_sel.seeme = g_sel.seeme = b_sel.seeme = see_islidepot;
	r_sl.max = g_sl.max = b_sl.max = 255;
	}
else
	{
	r_sel.seeme = g_sel.seeme = b_sel.seeme = see_n1_slider;
	r_sl.max = g_sl.max = b_sl.max = 7;
	}
(*(hls_sel.seeme))(&hls_sel);
(*(rgb_sel.seeme))(&rgb_sel);
resee_csliders();
}

resee_csliders()
{
init_cslider_values();
draw_csliders();
show_mouse();
}


WORD cycle_dir;
WORD cycle_stop;
WORD cycle_start;

init_cycle()
{
if (csegment.v1 > csegment.v2)
	{
	cycle_dir = -1;
	cycle_stop = csegment.v1;
	cycle_start = csegment.v2;
	}
else
	{
	cycle_dir = 1;
	cycle_stop = csegment.v2;
	cycle_start = csegment.v1;
	}
}

cycle_ccolor()
{
if (cycle_draw)
	{
	ccolor += cycle_dir;
	if (ccolor > cycle_stop)
		ccolor = cycle_start;
	if (ccolor < cycle_start)
		ccolor = cycle_stop;
	}
}

uncycle_ccolor()
{
cycle_dir = -cycle_dir;
cycle_ccolor();
cycle_dir = -cycle_dir;
}

cm_newframe()
{
hide_mouse();
resee_csliders();
copy_structure(sys_cmap, save_cmap, sizeof(save_cmap) );
}

cplay_backwards(m)
Flicmenu *m;
{
if (flush_cmulti_tracker())
	{
	aplay_backwards(m, &cframe_sel);
	cm_newframe();
	}
}

cplay_forwards(m)
Flicmenu *m;
{
if (flush_cmulti_tracker())
	{
	aplay_forwards(m, &cframe_sel);
	cm_newframe();
	}
}

crewind(m)
Flicmenu *m;
{
if (flush_cmulti_tracker())
	{
	arewind(m, &cframe_sel);
	cm_newframe();
	}
}

cfast_forward(m)
Flicmenu *m;
{
if ( flush_cmulti_tracker())
	{
	afast_forward(m, &cframe_sel);
	cm_newframe();
	}
}


cgo_first(m)
struct Flicmenu *m;
{
if (flush_cmulti_tracker())
	{
	ago_first(m, &cframe_sel);
	cm_newframe();
	}
}

cgo_last(m)
Flicmenu *m;
{
if ( flush_cmulti_tracker())
	{
	ago_last(m, &cframe_sel);
	cm_newframe();
	}
}

cmlast_frame(m)
struct Flicmenu *m;
{
if ( flush_cmulti_tracker())
	{
	amlast_frame(m, &cframe_sel);
	cm_newframe();
	}
}

cmnext_frame(m)
Flicmenu *m;
{
if ( flush_cmulti_tracker())
	{
	amnext_frame(m, &cframe_sel);
	cm_newframe();
	}
}

cmsee_times(m)
struct Flicmenu *m;
{
if (m != NULL)
	draw_sel(m);
mmsee_slider(&cframe_sel);
draw_sel(&cframes_sel);
show_mouse();
}


ccinsert(m)
Flicmenu *m;
{
if ( flush_cmulti_tracker())
	{
	ainsert(m);
	cmsee_times(m);
	}
}

ccappend(m)
struct Flicmenu *m;
{
if (flush_cmulti_tracker())
	{
	aappend(m);
	cmsee_times(m);
	}
}


cmfeel_slider(m)
Flicmenu *m;
{
if (flush_cmulti_tracker())
	{
	mmfeel_slider(m);
	cm_newframe();
	}
}


cadd_ten(m)
Flicmenu *m;
{
if (flush_cmulti_tracker())
	{
	aadd_ten(m, &cframes_sel, &cframe_sel);
	}
}

jump_cefx(m)
Flicmenu *m;
{
if (flush_cmulti_tracker())
	return_dummy_key(m, '%');
}

restore_dummy()
{
extern char dummied_cefx;

/* a little noise so cefx and color can use same restore */
if (dummied_cefx)
	dummied_cefx = 0;
else
	copy_structure(sys_cmap, save_cmap, sizeof(save_cmap) );
}

go_colors()
{
restore_dummy();
zero_cmulti_tracker();
hide_mouse();
init_cslider_values();
AGAIN:
draw_a_menu(&color_menu);
do_menu(&color_menu);
nohblanks();
if (!flush_cmulti_tracker())
	goto AGAIN;
set_top_lines();
}

