
overlay "menu"

#include "..\\include\\lists.h"
#include "..\\include\\cursor.h"
#include "..\\include\\script.h"
#include "..\\include\\acts.h"
#include "..\\include\\color.h"
#include "..\\include\\poly.h"
#include "..\\include\\menu.h"
#include "..\\include\\control.h"
#include "..\\include\\format.h"
#include "..\\include\\io.h"
#include "..\\include\\digitgau.h"

#define CM_DY		8
#define CM_DX		12

#define CMENU_WIDTH	 (17*CM_DX)
#define CMENU_HEIGHT	(12*CM_DY)


extern struct cursor box_cursor, question_cursor, camera_cursor;
extern struct cursor undo_cursor, tick_cursor, diamond_cursor;
extern crude_help(), cin_color(), solid_block();
extern just_text();
extern snap_shot(), swap_undo();
extern hide_menu(), move_menu();
extern int color_bars(), change_color();
extern int do_slider(), see_slider();
extern int cin_ccolor();
extern struct slider hue_sl; 
extern struct slider light_sl; 
extern struct slider sat_sl; 
extern struct cursor color_cursor;


struct slider hue_sl = 
	{
	"hue",255,0,
	};

struct slider light_sl = 
	{
	"light",255,0,
	};

struct slider sat_sl = 
	{
	"sat",255,0,
	};


WORD glow_on = 0;
struct one_of glow_on_one_of =
	{
	&glow_on,
	1,
	"glow on",
	};

#ifdef SUN
struct digit_gauge red_gauge =
{
3,   /*digits*/
0,   /*min */
0,   /*value */
255,   /*max */
};

struct digit_gauge green_gauge =
{
3,   /*digits*/
0,   /*min */
0,   /*value */
255,   /*max */
};

struct digit_gauge blue_gauge =
{
3,   /*digits*/
0,   /*min */
0,   /*value */
255,   /*max */
};
#endif SUN

#ifdef AMIGA
struct digit_gauge red_gauge =
{
2,   /*digits*/
0,   /*min */
0,   /*value */
15,   /*max */
};

struct digit_gauge green_gauge =
{
2,   /*digits*/
0,   /*min */
0,   /*value */
15,   /*max */
};

struct digit_gauge blue_gauge =
{
2,   /*digits*/
0,   /*min */
0,   /*value */
15,   /*max */
};
#endif AMIGA

#ifdef ATARI
struct digit_gauge red_gauge =
{
1,   /*digits*/
0,   /*min */
0,   /*value */
7,   /*max */
};

struct digit_gauge green_gauge =
{
1,   /*digits*/
0,   /*min */
0,   /*value */
7,   /*max */
};

struct digit_gauge blue_gauge =
{
1,   /*digits*/
0,   /*min */
0,   /*value */
7,   /*max */
};
#endif ATARI

struct color_seg
	{
	WORD start;
	WORD stop;
	};

struct color_seg cm_range =
	{
	2, 8,
	};

toggle_glow_on(m, sel, vis)
struct menu *m;
struct selection *sel;
struct virtual_input *vis;
{
/*a way Dale showed me to do logical negation*/
sel->is_selected = glow_on = 1-glow_on;
put_cmap(usr_cmap, 0, MAXCOL);
}

see_color_seg(m, sel, color)
register struct menu *m;
register struct selection *sel;
int color;
{
register WORD ceny, xoff, dx;
WORD startx, stopx;
extern struct cursor segment_cursor, lsegment_cursor;

ceny = m_sel_ceny(m, sel);
xoff = m_sel_xoff(m, sel);
dx = sel_width(sel);
startx = xoff + dx*cm_range.start/MAXCOL;
stopx = xoff + dx*(cm_range.stop+1)/MAXCOL;

whipe_sel(m, sel);
hline(ceny, startx, stopx, color);
show_cursor(&lsegment_cursor, startx, ceny, color);
show_cursor(&segment_cursor, stopx, ceny, color);
}

do_color_seg(m, sel, vis)
struct menu *m;
struct selection *sel;
register struct virtual_input *vis;
{
register WORD ceny, xoff, dx;
WORD startx, stopx;
register WORD *which;
WORD boff;

ceny = m_sel_ceny(m, sel);
xoff = m_sel_xoff(m, sel);
dx = sel_width(sel);
boff = ((dx/MAXCOL)>>1);
startx = xoff + dx*cm_range.start/MAXCOL + boff;
stopx = xoff + dx*cm_range.stop/MAXCOL + boff;

if ( abs(vis->curx - startx) < abs(vis->curx - stopx) )
	which = &cm_range.start;
else
	which = &cm_range.stop;

while (vis->result & JUST_DN)
	{
	see_color_seg(m, sel, fore_color);
	vis = await_input(USE_CURSOR);
	*which = (vis->curx - xoff)*MAXCOL/dx;
	WORD_clip(0, which, MAXCOL);
	}
}

mod_color()
{
int r,g,b;

hls_to_rgb(&r,&g,&b,(int)hue_sl.value,(int)light_sl.value,(int)sat_sl.value);
usr_cmap[ccolor].red = r;
usr_cmap[ccolor].green = g;
usr_cmap[ccolor].blue = b;
put_color(ccolor, r, g, b);
}

wipe_background(m, sel, vis)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
code(cur_sequence, REMOVE_BACKGROUND, -2, 0, 0, 0);
free_background();
retween_poly_list(cur_sequence);
make_cur_frame(m);
}

cycle_segment(m, sel, vis)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
WORD direction;

if (cm_range.start != cm_range.stop)
	{
	save_undo();
	if (cm_range.start > cm_range.stop)
	{
	direction = -1;
	code(cur_sequence, CYCLE_COLORS, -1, cm_range.stop, 
		cm_range.start - cm_range.stop + 1, &direction);
	}
	else
	{
	direction = 1;
	code(cur_sequence, CYCLE_COLORS, -1, cm_range.start, 
		cm_range.stop - cm_range.start + 1, &direction);
	}
	make_cur_frame(m);
	retween_poly_list(cur_sequence);
	}
}

make_range(m, sel, vis)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
WORD start, stop;
register WORD dc, dr, dg, db;
register struct color_def *start_col;
struct color_def *stop_col;
register struct color_def *col;
WORD i;

if (cm_range.start != cm_range.stop)
	{
	save_undo();
	if (cm_range.start > cm_range.stop)
	{
	start = cm_range.stop;
	stop = cm_range.start;
	}
	else
	{
	start = cm_range.start;
	stop = cm_range.stop;
	}
	dc = stop - start;
	col = start_col = usr_cmap + start;
	stop_col = usr_cmap + stop;
	dr = stop_col->red - start_col->red;
	dg = stop_col->green - start_col->green;
	db = stop_col->blue - start_col->blue;
	for (i=0; i<= dc; i++)
	{
	col->red = start_col->red + dr*i/dc;
	col->green = start_col->green + dg*i/dc;
	col->blue = start_col->blue + db*i/dc;
	col++;
	}
	code(cur_sequence,INIT_COLORS, -1, start, dc+1, usr_cmap + start);
	retween_poly_list(cur_sequence);
	make_cur_frame(m);
	}
}

make_spectrum(m, sel, vis)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
WORD inc, first_ix;
int dc, dh, dl, ds;
int inith, initl, inits;
register struct color_def *start_col, *col, *stop_col;
int r,g,b;
register int h,l,s;
register WORD i;

if (cm_range.start != cm_range.stop)
	{
	save_undo();
	col = start_col = usr_cmap + cm_range.start;
	stop_col = usr_cmap + cm_range.stop;
	if (cm_range.start > cm_range.stop)
	{
	inc = -1;
	first_ix = cm_range.stop;
	}
	else
	{
	inc = 1;
	first_ix = cm_range.start;
	}
	dc = abs(cm_range.stop - cm_range.start);
	r = stop_col->red;
	g = stop_col->green;
	b = stop_col->blue;
	rgb_to_hls(r,g,b,&dh,&dl,&ds);
	r = start_col->red;
	g = start_col->green;
	b = start_col->blue;
	rgb_to_hls(r,g,b,&inith,&initl,&inits);
	dh -= inith;
	dl -= initl;
	ds -= inits;
	while (dh <= 0)
	dh += 255;

	for (i=0; i<= dc; i++)
	{
	h = inith + dh*i/dc;
	l = initl + dl*i/dc;
	s = inits + ds*i/dc;
	hls_to_rgb(&r,&g,&b,h,l,s);
	col->red = r;
	col->green = g;
	col->blue = b;
	col += (long)inc;
	}

	code(cur_sequence,INIT_COLORS, -1, first_ix, 
	dc+1, first_ix + usr_cmap);
	retween_poly_list(cur_sequence);
	make_cur_frame(m);
	}
}

do_fade(m, sel, vis)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
register WORD start;
register WORD length;

if ( (length = cm_range.stop - cm_range.start) < 0)
	{
	length = -length;
	start = cm_range.stop;
	}
else
	start = cm_range.start;

save_undo();
code(cur_sequence,TWEEN_TO_COLORS, -1, start, 
	length+1, ccolor + usr_cmap);
retween_poly_list(cur_sequence);
make_cur_frame(m);
}


change_hls(m,sel,vis)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct color_def delta_c;
register WORD ccol = ccolor;

save_undo();
delta_c.red =  usr_cmap[ccol].red;
delta_c.green =  usr_cmap[ccol].green;
delta_c.blue = usr_cmap[ccol].blue;

d_slider(m, sel, vis, mod_color);

delta_c.red =  usr_cmap[ccol].red - delta_c.red;
delta_c.green =  usr_cmap[ccol].green - delta_c.green;
delta_c.blue = usr_cmap[ccol].blue - delta_c.blue;

code(cur_sequence,
	TWEEN_COLOR, -1, ccol, 0, &delta_c);
set_hls_slides(ccol);
retween_poly_list(cur_sequence);
}

change_rgb(m, sel, vis)
struct menu *m;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct color_def delta_c;
register WORD ccol = ccolor;

save_undo();
delta_c.red =  usr_cmap[ccol].red;
delta_c.green =  usr_cmap[ccol].green;
delta_c.blue = usr_cmap[ccol].blue;

do_digit_gauge(m, sel, vis);

#ifdef SUN
usr_cmap[ccol].red = red_gauge.value;
usr_cmap[ccol].green = green_gauge.value;
usr_cmap[ccol].blue = blue_gauge.value;
#endif SUN
#ifdef AMIGA
usr_cmap[ccol].red = red_gauge.value<<4;
usr_cmap[ccol].green = green_gauge.value<<4;
usr_cmap[ccol].blue = blue_gauge.value<<4;
#endif AMIGA
#ifdef ATARI
usr_cmap[ccol].red = red_gauge.value<<5;
usr_cmap[ccol].green = green_gauge.value<<5;
usr_cmap[ccol].blue = blue_gauge.value<<5;
#endif ATARI
delta_c.red =  usr_cmap[ccol].red - delta_c.red;
delta_c.green =  usr_cmap[ccol].green - delta_c.green;
delta_c.blue = usr_cmap[ccol].blue - delta_c.blue;
code(cur_sequence,
	TWEEN_COLOR, -1, ccol, 0, &delta_c);
retween_poly_list(cur_sequence);
make_cur_frame(m);
set_hls_slides(ccol);
}

set_hls_slides(color)
register int color;
{
register int r,g,b;
int h,l,s;

r = usr_cmap[color].red;
g = usr_cmap[color].green;
b = usr_cmap[color].blue;

#ifdef SUN
red_gauge.value = r;
green_gauge.value = g;
blue_gauge.value = b;
#endif SUN
#ifdef AMIGA
red_gauge.value = r>>4;
green_gauge.value = g>>4;
blue_gauge.value = b>>4;
#endif AMIGA
#ifdef ATARI
red_gauge.value = r>>5;
green_gauge.value = g>>5;
blue_gauge.value = b>>5;
#endif ATARI

rgb_to_hls(r,g,b,&h,&l,&s);
hue_sl.value = h;
light_sl.value = l;
sat_sl.value = s;

}

cswap_undo()
{
swap_undo();
set_hls_slides(ccolor);
}

change_color(m,sel,vis)
struct menu *m;
struct selection *sel;
register VIRTUAL_INPUT *vis;
{
ccolor = getdot(vis->curx,vis->cury);
set_hls_slides(ccolor);
#ifdef AMIGA
color_hilight(ccolor);
#endif AMIGA
}

Tween *
ma_insert_colors(tween,cmap, start, count)
register Tween *tween;
struct color_def *cmap;
register WORD start, count;
{
WORD **acts;
register WORD *act;

acts = (WORD **)alloc( (tween->act_count+1) * sizeof(WORD *) );
copy_structure( tween->act_list, acts+1, tween->act_count * sizeof(WORD *) );
acts[0] = act = (WORD *)alloc( (count * 3 + 5) * sizeof(WORD) );
act[0] = count*3 + 5;
act[1] = INIT_COLORS;
act[2] = -1;  /*  dummy "poly" number  */
act[3] = start;
act[4] = count;
copy_structure( cmap, act+5, count*3 * sizeof(WORD));

mfree(tween->act_list, tween->act_count * sizeof(WORD *) );
tween->act_list = acts;
tween->act_count++;

return(tween);
}

Tween *
m_insert_colors(tween,cmap)
Tween *tween;
struct color_def *cmap;
{
return(ma_insert_colors(tween,  cmap, 0, MAXCOL));
}


struct selection color_mtable[] =
{

	{
	MARGIN, MARGIN,
	MARGIN + CHAR_HEIGHT, CHAR_HEIGHT,

	0,

	(char *) &box_cursor,FIRST_TIME,
	cin_color,

	NULL, RETURN_SOMETHING,
	hide_menu,

	NULL,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	MARGIN + CHAR_HEIGHT + 1, MARGIN,
	CMENU_WIDTH - MARGIN, CHAR_HEIGHT,

	0,

	(char *) 0,FIRST_TIME,
	solid_block,

	NULL, GO_SUB_REMENU,
	move_menu,

	NULL,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	0*CM_DX,	1*CM_DY+3,
	1*CM_DX,	4*CM_DY+1,

	0,

	"r", FIRST_TIME,
	just_text,

	NULL, DISPLAY_ONLY,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	1*CM_DX,	1*CM_DY+5,
	3*CM_DX,	4*CM_DY+1,

	0,

	(char *)&red_gauge, FIRST_TIME,
	see_digit_gauge,

	(char *)&red_gauge, GO_SUBBER,
	change_rgb,

	NO_DOUBLE,NO_DOUBLE,

	"digitally adjust red component", crude_help,
	},

	{
	3*CM_DX,	1*CM_DY+5,
	4*CM_DX,	4*CM_DY+1,

	0,

	"g", FIRST_TIME,
	just_text,

	NULL, DISPLAY_ONLY,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	4*CM_DX,	1*CM_DY+5,
	6*CM_DX,	4*CM_DY+1,

	0,

	(char *)&green_gauge, FIRST_TIME,
	see_digit_gauge,

	(char *)&green_gauge, GO_SUBBER,
	change_rgb,

	NO_DOUBLE,NO_DOUBLE,

	"digitally adjust green component", crude_help,
	},

	{
	6*CM_DX,	1*CM_DY+5,
	7*CM_DX,	4*CM_DY+1,

	0,

	"b", FIRST_TIME,
	just_text,

	NULL, DISPLAY_ONLY,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	NULL, NO_HELP,
	},

	{
	7*CM_DX,	1*CM_DY+5,
	9*CM_DX,	4*CM_DY+1,

	0,

	(char *)&blue_gauge, FIRST_TIME,
	see_digit_gauge,

	(char *)&blue_gauge, GO_SUBBER,
	change_rgb,

	NO_DOUBLE,NO_DOUBLE,

	"digitally adjust blue component", crude_help,
	},

	{
	1*CM_DX,	4*CM_DY+2,
	12*CM_DX,	6*CM_DY,

	0,

	(char *) &hue_sl,FIRST_TIME,
	see_slider,

	(char *)&hue_sl,GO_SUB_REMENU,
	change_hls,

	NO_DOUBLE,NO_DOUBLE,

	"position in rainbow", crude_help,
	},
	
	{
	1*CM_DX,	6*CM_DY+2,
	12*CM_DX,	8*CM_DY,

	0,

	(char *) &light_sl, FIRST_TIME,
	see_slider,

	(char *)&light_sl,GO_SUB_REMENU,
	change_hls,

	NO_DOUBLE,NO_DOUBLE,

	"black and white component", crude_help,
	},
	
	{
	1*CM_DX,	8*CM_DY+2,
	12*CM_DX,	10*CM_DY,

	0,

	(char *)&sat_sl, FIRST_TIME,
	see_slider,

	(char *)&sat_sl,GO_SUB_REMENU,
	change_hls,

	NO_DOUBLE,NO_DOUBLE,

	"vibrancy of color", crude_help,
	},

	{
	10*CM_DX,	2*CM_DY,
	11*CM_DX,	4*CM_DY,

	0,

	(char *) &question_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,HELP,
	NULL,

	NO_DOUBLE,NO_DOUBLE,

	"explain icon", crude_help,
	},

	{
	12*CM_DX,	2*CM_DY,
	14*CM_DX,	4*CM_DY,

	0,

	(char *) &undo_cursor, FIRST_TIME,
	cin_color,

	NO_DATA,GO_SUB_REDRAW,
	cswap_undo,

	NO_DOUBLE,NO_DOUBLE,

	"forget last action", crude_help,
	},
	
	{
	14*CM_DX,	2*CM_DY,
	16*CM_DX,	4*CM_DY,

	0,

	(char *) &camera_cursor,FIRST_TIME,
	cin_color,

	NULL, GO_SUBBER,
	snap_shot,

	NULL, NO_DOUBLE,

	"advance to next tween", crude_help,
	},

	{
	12*CM_DX,	4*CM_DY,
	17*CM_DX,	5*CM_DY,

	0,

	"cycle", FIRST_TIME,
	just_text,

	NULL, GO_SUBBER,
	cycle_segment,

	NULL, NO_DOUBLE,

	"cycle color segment", crude_help,
	},

	{
	12*CM_DX,	5*CM_DY,
	17*CM_DX,	6*CM_DY,

	0,

	"fade", FIRST_TIME,
	just_text,

	NULL, GO_SUBBER,
	do_fade,

	NULL, NO_DOUBLE,

	"fade segment to current color", crude_help,
	},

	{
	12*CM_DX,	6*CM_DY,
	17*CM_DX,	7*CM_DY,

	0,

	"wipe", FIRST_TIME,
	just_text,

	NULL, GO_SUBBER,
	wipe_background,

	NULL, NO_DOUBLE,

	"wipe background", crude_help,
	},


	{
	12*CM_DX,	7*CM_DY,
	17*CM_DX,	8*CM_DY,

	0,

	"range", FIRST_TIME,
	just_text,

	NULL, GO_SUBBER,
	make_range,

	NULL, NO_DOUBLE,

	"blend segment between endpoints", crude_help,
	},

	{
	12*CM_DX,	8*CM_DY,
	17*CM_DX,	9*CM_DY,

	0,

	"spectrum", FIRST_TIME,
	just_text,

	NULL, GO_SUBBER,
	make_spectrum,

	NULL, NO_DOUBLE,

	"make spectrum between endpoints", crude_help,
	},

	{
	12*CM_DX,	9*CM_DY,
	17*CM_DX,	10*CM_DY,

	0,

	&glow_on_one_of, ONE_OF,
	just_text,

	NULL, GO_SUB_REMENU,
	toggle_glow_on,

	NULL, NO_DOUBLE,

	"cycle last (hilite) color", crude_help,
	},

#ifdef ATARI
	{
	MARGIN,
	CMENU_HEIGHT - ((CMENU_WIDTH-2*MARGIN)*COL_YDIV/COL_XDIV)/2 - MARGIN - 7,
	CMENU_WIDTH - MARGIN, 
	CMENU_HEIGHT - ((CMENU_WIDTH-2*MARGIN)*COL_YDIV/COL_XDIV)/2 - MARGIN,

	0,

	NULL, FIRST_TIME,
	see_color_seg,

	NO_DATA, GO_SUB_REMENU,
	do_color_seg,

	NO_DOUBLE,NO_DOUBLE,

	"set up color segment", crude_help,
	},
	
	{
	MARGIN,
	CMENU_HEIGHT - ((CMENU_WIDTH-2*MARGIN)*COL_YDIV/COL_XDIV)/2 - MARGIN,
	/*this rather horrific expression makes the individual color swatches
	  square and right on the bottom of the menu -jk or er over 2 for ST*/
	CMENU_WIDTH - MARGIN, CMENU_HEIGHT-MARGIN,

	0,

	NULL, FIRST_TIME,
	color_bars,

	NO_DATA, GO_SUB_REMENU,
	change_color,

	NO_DOUBLE,NO_DOUBLE,

	"pick color", crude_help,
	},
#endif ATARI

};

struct virtual_input *
touch_color(m, vis)
register struct menu *m;
register struct virtual_input *vis;
{
vis = await_input();
if (!in_menu(m, vis) )
	{
	if (pjstdn(vis))
	{
	ccolor = getdot(vis->curx, vis->cury);
	set_hls_slides(ccolor);
#ifdef AMIGA
	color_hilight(ccolor);
#endif AMIGA
	draw_menu(m);
	}
	}
return(vis);
}


struct menu color_m =
	{
	1,
	1,
	XMAX - CMENU_WIDTH - 1, YMAX - CMENU_HEIGHT - CHAR_HEIGHT - 1,
	CMENU_WIDTH, CMENU_HEIGHT,
	sizeof(color_mtable) / sizeof(struct selection),
	sizeof(color_mtable) / sizeof(struct selection),
	color_mtable,
	touch_color,
	0,
	0,
	};


edit_color(menu, sel,vis)
register struct menu *menu;
register struct selection *sel;
VIRTUAL_INPUT *vis;
{
change_color(menu,sel,vis);
color_menu(menu,sel,vis);
}


color_menu(menu,sel,vis)
register struct menu *menu;
struct selection *sel;
VIRTUAL_INPUT *vis;
{
struct control local_control;
register struct menu *cm = &color_m;

#ifdef DEBUG
lprintf("color_menu()\n");
#endif DEBUG

show_help("color menu");
set_hls_slides(ccolor);

local_control.m = cm;
local_control.sel = NULL;
local_control.vis = vis;

#ifdef SUN
#endif SUN
copy_menu_offsets(menu, cm);

color_m.visible = 1;
draw_menu(cm);
main_menu_driver(&local_control, NOSWAP_CONT);
clear_menu(cm);

copy_menu_offsets(cm, menu);
}



