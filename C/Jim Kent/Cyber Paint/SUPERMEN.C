
#include "flicker.h"
#include "flicmenu.h"

extern Flicmenu supermove_menu, color_menu, px_menu, cefx_menu,
	cxtleft_time_sel, cxtright_time_sel,
	pxtleft_time_sel, pxtright_time_sel,
	spframe_sel, spframes_sel, spleft_time_sel, spright_time_sel,
	spsegment_sel, spp_nothing;

extern Flicmenu tleft_time_sel, tright_time_sel;
extern Flicmenu spra_x_sel, spra_y_sel, spra_z_sel;
extern Flicmenu sprc_x_sel, sprc_y_sel, sprc_z_sel;

extern struct slidepot multiplier_sl, divisor_sl;
extern struct slidepot spra_x_sl, spra_y_sl, spra_z_sl;
extern struct slidepot sprc_x_sl, sprc_y_sl, sprc_z_sl;
extern struct slidepot spm_x_sl, spm_y_sl, spm_z_sl;
extern struct slidepot turns_sl, angle_sl;

extern WORD spfirst_mode, screen_mode;
extern Super_settings first_settings, super_settings;
extern Vertex spoly[];

show_screen_mode(m)
Flicmenu *m;
{
m->text = (screen_mode ? "Seq" : "Clip");
wbtext(m);
}

show_spfirst(m)
Flicmenu *m;
{
m->text = (spfirst_mode ? "First" : "Motion");
wbtext(m);
}

toggle_spfirst(m)
Flicmenu *m;
{
hide_mouse();
if (spfirst_mode)
	{
	settings_from_sliders(&first_settings);
	sliders_from_settings(&super_settings);
	}
else
	{
	settings_from_sliders(&super_settings);
	sliders_from_settings(&first_settings);
	}
spfirst_mode = !spfirst_mode;
draw_sub_menu(m);
show_mouse();
}

show_clip_edge()
{
register Cel *c;

if (!screen_mode)
	{
	if ((c=clipping) != NULL)
		draw_frame(oppositec[0], c->xoff, c->yoff, 
			c->xoff+c->width-1, c->yoff+c->height-1);
	}
}

show_clip_seq()
{
show_clip_edge();
draw_center();
}

mouse_center()
{
calc_center();
mget_one_coor(0, 0, show_clip_seq);
if (!RDN)
	{
	sprc_x_sl.value = mouse_x - XMAX/2 - 1;
	sprc_y_sl.value = mouse_y - YMAX/2 - 1;
	hide_mouse();
	draw_sel(&sprc_x_sel);
	draw_sel(&sprc_y_sel);
	show_mouse();
	}
}

default_center()
{
super_center();
hide_mouse();
draw_sel(&sprc_x_sel);
draw_sel(&sprc_y_sel);
draw_sel(&sprc_z_sel);
show_mouse();
}


clear_super()
{
if (yes_no_line("Clear ADO settings?") )
	{
	spra_x_sl.value = spra_y_sl.value = 
		spm_x_sl.value = spm_y_sl.value = spm_z_sl.value =
		turns_sl.value = angle_sl.value = -1;
	spra_z_sl.value = multiplier_sl.value = divisor_sl.value = 99;
	sprc_x_sl.value = -1;
	sprc_y_sl.value = -1;
	sprc_z_sl.value = -1;
	spfirst_mode = !spfirst_mode;
	save_sets();
	spfirst_mode = !spfirst_mode;
	clear_path();
	draw_sub_menu(supermove_menu.children);
	}
}


WORD *spra_vals[] = {&spra_x_sl.value, &spra_y_sl.value, &spra_z_sl.value};

clr_axis(m, axis)
Flicmenu *m;
{
hide_mouse();
hilight(m);
spra_x_sl.value = spra_y_sl.value = spra_z_sl.value = -1;
*(spra_vals[axis]) = 99;
draw_sel(&spra_x_sel);
draw_sel(&spra_y_sel);
draw_sel(&spra_z_sel);
draw_sel(m);
show_mouse();
}

set_x_axis(m)
Flicmenu *m;
{
clr_axis(m,0);
}

set_y_axis(m)
Flicmenu *m;
{
clr_axis(m,1);
}

set_z_axis(m)
Flicmenu *m;
{
clr_axis(m,2);
}


see_sp_scale(m)
Flicmenu *m;
{
char buf[10];

sprintf(buf, "%d.%2d", (1+multiplier_sl.value)/(1+divisor_sl.value),
	100*(1+multiplier_sl.value)/(1+divisor_sl.value)%100);
tr_string(buf, ' ', '0');
m->text = buf;
wbtext(m);
}

draw_tleft()
{
if (cur_menu == &supermove_menu)
	draw_sel(&spleft_time_sel);
else if (cur_menu == &cefx_menu)
	draw_sel(&cxtleft_time_sel);
else if (cur_menu == &px_menu)
	draw_sel(&pxtleft_time_sel);
else
	draw_sel(&tleft_time_sel);
}

draw_tright()
{
if (cur_menu == &supermove_menu)
	draw_sel(&spright_time_sel);
else if (cur_menu == &cefx_menu)
	draw_sel(&cxtright_time_sel);
else if (cur_menu == &px_menu)
	draw_sel(&pxtright_time_sel);
else
	draw_sel(&tright_time_sel);
}

spplay_backwards(m)
Flicmenu *m;
{
aplay_backwards(m, &spframe_sel);
}

spplay_forwards(m)
Flicmenu *m;
{
aplay_forwards(m, &spframe_sel);
}

sprewind(m)
Flicmenu *m;
{
arewind(m, &spframe_sel);
}

spfast_forward(m)
Flicmenu *m;
{
afast_forward(m, &spframe_sel);
}

spgo_last(m)
Flicmenu *m;
{
ago_last(m, &spframe_sel);
}

spgo_first(m)
struct Flicmenu *m;
{
ago_first(m, &spframe_sel);
}

spmlast_frame(m)
struct Flicmenu *m;
{
amlast_frame(m, &spframe_sel);
}

spmnext_frame(m)
struct Flicmenu *m;
{
amnext_frame(m, &spframe_sel);
}

spappend(m)
struct Flicmenu *m;
{
aappend(m);
trange.max = screen_ct;
draw_sel(m);
draw_sel(&spframe_sel);
draw_sel(&spframes_sel);
draw_sel(&spsegment_sel);
show_mouse();
}

spinsert(m)
struct Flicmenu *m;
{
ainsert(m);
trange.max = screen_ct;
draw_sel(m);
draw_sel(&spframe_sel);
draw_sel(&spframes_sel);
draw_sel(&spsegment_sel);
show_mouse();
}

spadd_10(m)
struct Flicmenu *m;
{
hide_mouse();
hilight(m);
clean_ram_deltas(bscreen);
add_empties_at_end(10);
update_next_prev(bscreen);
trange.max = screen_ct;
draw_sel(m);
draw_sel(&spframe_sel);
draw_sel(&spsegment_sel);
show_mouse();
}

spstuff_tv(m)
Flicmenu *m;
{
astuff_tv(m, &spsegment_sel);
}

spdecl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, -1, &spleft_time_sel);
}

spincl_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v1, 1, &spleft_time_sel);
}

spdecr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, -1, &spright_time_sel);
}

spincr_in_trange(m)
Flicmenu *m;
{
adj_trange(m, &trange.v2, 1, &spright_time_sel);
}

extern struct flicmenu sprc_xf2, spsbs_hundreds;

extern struct flicmenu sps_center_sub_sel;
struct flicmenu *bigsmallce_head[] =
	{
	&sprc_xf2, &spsbs_hundreds,
	};

extern Flicmenu sprt_degrees, spra_xf2, sprc_xf2;
extern struct flicmenu spr_center_sub_sel;

struct flicmenu *axance_head[3] =
	{
	&sprc_xf2,
	&spra_xf2,
	&sprt_degrees,
	};

extern Flicmenu sps_center_sel, spr_center_sel, spm_xf2;
extern struct flicmenu sprot_sub_sel;

struct flicmenu *spmove_head[] =
	{
	&spr_center_sel,
	&sps_center_sel,
	&spm_xf2,
	&spp_nothing,
	};

change_ps_mode(m, sub, table)
Flicmenu *m, *sub;
Flicmenu *table[];
{
unhi_group(&supermove_menu, m->group);
*(m->group) = m->identity;
hide_mouse();
white_block( sub);
sub->children = table[m->identity];
draw_sub_menu(sub);
hi_group(&supermove_menu, m->group);
}

change_axance_mode(m)
Flicmenu *m;
{
change_ps_mode(m, &spr_center_sub_sel, axance_head);
}

change_bigsmallce_mode(m)
Flicmenu *m;
{
change_ps_mode(m, &sps_center_sub_sel, bigsmallce_head);
}

change_spmove_mode(m)
Flicmenu *m;
{
change_ps_mode(m, &sprot_sub_sel, spmove_head);
}

#ifdef SLUFFED
super_mode(m)
Flicmenu *m;
{
unhi_group(&supermove_menu, m->group);
*(m->group) = m->identity;
hi_group(&supermove_menu, m->group);
}
#endif SLUFFED

extern struct flicmenu sps_scale_sel;

draw_sps_scale()
{
hide_mouse();
draw_sel(&sps_scale_sel);
show_mouse();
}

update_psscale_slider(m)
Flicmenu *m;
{
WORD new;
struct slidepot *s;

s = (struct slidepot *)m->text;
new = slide_where(m);
if (new != s->value)
	{
	hide_mouse();
	s->value = new;
	see_number_slider(m);
	draw_sps_scale();
	}
}

ps_slide_scale(m)
Flicmenu *m;
{
feelslide(m, update_psscale_slider);
}

ps_inc_slider(m)
Flicmenu *m;
{
inc_slider(m);
draw_sps_scale();
}

ps_dec_slider(m)
Flicmenu *m;
{
dec_slider(m);
draw_sps_scale();
}

supermove()
{
hide_mouse();
draw_a_menu(&supermove_menu);
do_menu(&supermove_menu);
}
