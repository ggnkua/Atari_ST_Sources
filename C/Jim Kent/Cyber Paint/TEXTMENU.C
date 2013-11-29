
#include "flicker.h"
#include "flicmenu.h"
#include "gemfont.h"

extern Flicmenu text_menu, sample_sel, points_sel;
extern char fold_buf[], title_buf[];

extern WORD bold_mode, light_mode, italic_mode, outline_mode, 
	underline_mode;
extern WORD got_cf;
extern char *title;
extern struct slidepot points_sl;
extern WORD cfont_prop;

WORD properly;	/* proportional? What a wooly */

WORD ch_width = CH_WIDTH;
WORD ch_height = 7;
WORD cl_width = CH_WIDTH;
WORD cl_height = CH_HEIGHT;

static WORD icdir;

ic_points()
{
points_sl.value += icdir;
clip_slider(&points_sl);
draw_sel(&points_sel);
draw_sel(&sample_sel);
}

id_points(m)
Flicmenu *m;
{
hide_mouse();
hilight(m);
repeat_on_pdn(ic_points);
draw_sel(m);
show_mouse();
}

inc_points(m)
Flicmenu *m;
{
icdir = 1;
id_points(m);
}

dec_points(m)
Flicmenu *m;
{
icdir = -1;
id_points(m);
}

calc_text_mode()
{
return( (bold_mode << 0) | (light_mode << 1) | (italic_mode << 2) |
	(underline_mode << 3) | (outline_mode << 4) ); 
}

text_toggle_group(m)
Flicmenu *m;
{
toggle_group(m);
hs_see_sample();
}

get_cfont(m)
Flicmenu *m;
{
char lfold_buf[70];
char ltitle_buf[16];
char *title;


if (got_cf)
	{
	free_cfont();
	}
else
	{
	strcpy(lfold_buf, fold_buf);	/* save context for file requestor */
	strcpy(ltitle_buf, title_buf);
	jimints_off();
	set_for_gem();
	gmessage("Load FNT or FED font");
	title = get_fname("F??");
	set_for_jim();
	if (title != NULL)
		{
		if (!suffix_in(title, ".FNT") && !suffix_in(title, ".FED") )
			{
			continu_line("Not a .FNT or .FED");
			}
		else
			if (load_cfont(title))
				{
				points_sl.value = cfont.top_dist-1;
				}
		}
	jimints_on();
	redraw_menu_frame();
	strcpy(fold_buf, lfold_buf);	/* restore context for file requestor */
	strcpy(title_buf, ltitle_buf);
	}
hide_mouse();
see_sample_text();
draw_sel(&points_sel);
draw_sel(m);
show_mouse();
}

setup_text()
{
vst_font(handle, (got_cf ? CYP_CUSTOM_FONT : 1) );
vst_effects(handle, calc_text_mode());
vst_height(handle, points_sl.value+1,
	&ch_width, &ch_height, &cl_width, &cl_height);
cl_height += 1;
if (outline_mode)
	{
	ch_width += 2;
	cl_width += 2;
	ch_height += 2;
	cl_height += 3;
	}
if (underline_mode)
	{
	ch_height += 2;
	cl_height += 2;
	}
if (bold_mode)
	{
	ch_width += 1;
	cl_width += 1;
	}
}


unset_text()
{
vst_font(handle, 1);
vst_height(handle, 6, &ch_width, &ch_height, &cl_width, &cl_height);
vst_effects(handle, 0);
}

pen_text_line(c, x, y)
register char *c;
register WORD x, y;
{
static char ubc[2];

properly = (cfont_prop || italic_mode); /* backspace == line redraw?? */
if (!properly)
	{
	while (ubc[0] = *c++)
		{
		v_gtext(handle, x, y, ubc);
		x += cl_width;
		}
	}
else
	v_gtext(handle, x, y, c);
}


see_sample_text()
{
char *name = "Abc";
Flicmenu *m = &sample_sel;
WORD x, y;
WORD bounds[4];

setup_text();
bounds[0] = m->x;
bounds[1] = m->y;
bounds[2] = m->x + m->width;
bounds[3] = m->y + m->height;
vs_clip(handle, 1, bounds);
vst_color(handle, gemctable[white]);
vswr_mode(handle, 2);
x = m->x;
if (!cfont_prop)
	x += (m->width - strlen(name)*cl_width)/2;
else
	x += 2;
y = m->y + (m->height - cl_height)/2 + ch_height;
see_menu_back(m);
pen_text_line(name, x, y);
unset_text();
vs_clip(handle, 0, bounds);
}

hs_see_sample()
{
hide_mouse();
see_sample_text();
show_mouse();
}

change_point_size(m)
Flicmenu *m;
{
feel_number_slider(m);
hs_see_sample();
}


go_text()
{
hide_mouse();
draw_a_menu(&text_menu);
do_menu(&text_menu);
}
