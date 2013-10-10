

#include "flicker.h"
#include "flicmenu.h"

extern Flicmenu menutime, tframe_sel, speed_sel, tframes_sel,
	tsegment_sel, tleft_time_sel, tright_time_sel;
extern Flicmenu supermove_menu, spsegment_sel, cxtsegment_sel, cefx_menu,
	px_menu, pxtsegment_sel;


extern struct slidepot speed_sl;
extern struct range trange;

extern draw_tleft(), draw_tright();

astuff_tv(m, seesel)
Flicmenu *m, *seesel;
{
hide_mouse();
hilight(m);
*((WORD *)m->text) = screen_ix + 1;
draw_sel(seesel);
draw_sel(m);
show_mouse();
}


stuff_tv(m)
Flicmenu *m;
{
astuff_tv(m, &tsegment_sel);
}

decl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, -1, &tleft_time_sel);
}

incl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, 1, &tleft_time_sel);
}

decr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, -1, &tright_time_sel);
}

incr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, 1, &tright_time_sel);
}

static Flicmenu *ssl;
static WORD *pval, aj;


ajtrange()
{
WORD val;

val = *pval;
val += aj;
if (val < trange.min)
	val = trange.min;
if (val > trange.max)
	val = trange.max;
*pval = val;
if (cur_menu == &supermove_menu)
	draw_sel(&spsegment_sel);
else if (cur_menu == &cefx_menu)
	draw_sel(&cxtsegment_sel);
else if (cur_menu == &px_menu)
	draw_sel(&pxtsegment_sel);
else
	draw_sel(&tsegment_sel);
draw_sel(ssl);
}

adj_trange(m, ptval, adj, seesel)
Flicmenu *m;
WORD *ptval;
WORD adj;
Flicmenu *seesel;
{
ssl = seesel;
pval = ptval;
aj = adj;
hide_mouse();
hilight(m);
repeat_on_pdn(ajtrange);
draw_sel(m);
show_mouse();
}

see_trange(m)
Flicmenu *m;
{
clip_trange();
see_range(m);
}

change_trange(m)
Flicmenu *m;
{
struct range orange;

orange = trange;
mv_range(m, draw_tleft, draw_tright);
if (orange.v1 != trange.v1)
	{
	hide_mouse();
	draw_tleft();
	}
if (orange.v2 != trange.v2)
	{
	hide_mouse();
	draw_tright();
	}
show_mouse();
}

static Flicmenu *asl;

inc_sl()
{
struct slidepot *sl;

sl = (struct slidepot *)asl->text;
if (sl->value < sl->max)
	{
	sl->value++;
	draw_sel(asl);
	}
}

inc_slider(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
asl = (Flicmenu *)m->text;
repeat_on_pdn(inc_sl);
draw_sel(m);
show_mouse();
}

dec_sl()
{
struct slidepot *sl;

sl = (struct slidepot *)asl->text;
if (sl->value > sl->min)
	{
	--sl->value;
	draw_sel(asl);
	}
}


dec_slider(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
asl = (Flicmenu *)m->text;
repeat_on_pdn(dec_sl);
draw_sel(m);
show_mouse();
}


tplay_backwards(m)
Flicmenu *m;
{
aplay_backwards(m, &tframe_sel);
}

tplay_forwards(m)
Flicmenu *m;
{
aplay_forwards(m, &tframe_sel);
}

arewind(m, slide)
Flicmenu *m;
Flicmenu *slide;
{
hide_mouse();
if (m != NULL)
	hilight(m);
mplayit(0, -1, slide);
if (m != NULL)
	draw_sel(m);
show_mouse();
}

trewind(m)
Flicmenu *m;
{
arewind(m, &tframe_sel);
}

tfast_forward(m)
Flicmenu *m;
{
afast_forward(m, &tframe_sel);
}

afast_forward(m, slide)
Flicmenu *m;
Flicmenu *slide;
{
hide_mouse();
if (m != NULL)
	hilight(m);
mplayit(0, 1, slide);
if (m != NULL)
	draw_sel(m);
show_mouse();
}



tgo_last(m)
Flicmenu *m;
{
ago_last(m, &tframe_sel);
}

tgo_first(m)
struct Flicmenu *m;
{
ago_first(m, &tframe_sel);
}

tmsee_times(m)
struct Flicmenu *m;
{
draw_sel(m);
trange.max = screen_ct;
mmsee_slider(&tframe_sel);
draw_sel(&tframes_sel);
draw_sel(&tsegment_sel);
show_mouse();
}

tmlast_frame(m)
struct Flicmenu *m;
{
amlast_frame(m, &tframe_sel);
}

tmnext_frame(m)
struct Flicmenu *m;
{
amnext_frame(m, &tframe_sel);
}

tinsert(m)
Flicmenu *m;
{
ainsert(m);
tmsee_times(m);
}

tappend(m)
struct Flicmenu *m;
{
aappend(m);
tmsee_times(m);
}

make_10(m)
struct Flicmenu *m;
{
hide_mouse();
hilight(m);
clean_ram_deltas(bscreen);
add_empties_at_end(10);
update_next_prev(bscreen);
tmsee_times(m);
}


time_mode(m)
Flicmenu *m;
{
unhi_group(&menutime, m->group);
*(m->group) = m->identity;
hi_group(&menutime, m->group);
}

go_time()
{
hide_mouse();
draw_a_menu(&menutime);
do_menu(&menutime);
}
