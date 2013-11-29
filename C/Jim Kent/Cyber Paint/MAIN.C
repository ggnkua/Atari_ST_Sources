/* :ts=3 */
#include <osbind.h>
#include <gemdefs.h>
#include "flicker.h"
#include "flicmenu.h"

extern Cel *clipping;
extern Pull root_pull;
extern Pull vdraw_pull, nozero_pull, filled_pull, degas_pull, 
	distinct_pull, connected_pull, concentric_pull, compress_pull, 
	zoom_pull, toall_pull, cycle_pull, clip_brush_pull;
extern struct flicmenu main_menu, color_menu;
extern drizzle(), draw(), draw_box(), draw_line(), flood(), pen_text(),
	scratch(),
	scribble(), draw_circle(), spray(), draw_polygon(), color_separate();

extern Flicmenu main_menu;
extern WORD pen_tool_group;

extern WORD ccolor;

Flicmenu *cur_menu;
Pull *cur_pull;
WORD live_top = 0, live_lines = 200;

WORD nozero_flag = 1;
WORD filled_flag = 1;
WORD connect_mode = 0;
WORD cycle_draw = 0;
WORD degas = 0;
WORD use_brush_cursor = 1;
WORD text_cursor;
WORD fill_cursor;
WORD zoom_flag = 0;	/* are we in zoom mode? */
WORD zoomx, zoomy;	/* offset of zoom area into full screen */
WORD zscale_cursor;
WORD clip_brush;
WORD pen_tool_group;
WORD ccolor = 2;

Vector pen_tool = draw;


main(argc, argv)
int argc;
char *argv[];
{
int i;

if ((i = init_sys())<0)
	{
	uninit_sys();
	exit(i);
	}
hide_mouse();
clear_screen();
show_mouse();
for (;;)
	{
	check_input();
	update_zoom();
	/* in text mode return is like pendown */
	if (PDN || text_cursor && key_hit && ((key_in&0xff) == '\r') )
		{
		dirtys();
		(*pen_tool)();
		}
	else if (RDN)
		{
		use_brush_cursor = 0;
		pick_cursor();	/* based on use_brush_cursor */
		do_pull();
		use_brush_cursor = 1;
		pick_cursor();	/* based on use_brush_cursor */
		update_zoom();
		}
	else if (key_hit)
		{
		use_brush_cursor = 0;
		pick_cursor();	/* based on use_brush_cursor */
		do_key();
		use_brush_cursor = 1;
		pick_cursor();	/* based on use_brush_cursor */
		}
	}
}


do_pull()
{
unzoom();
cur_pull = &root_pull;
cur_menu = &main_menu;
set_top_lines();
pull();
cur_menu = NULL;
cur_pull = NULL;
set_top_lines();
rezoom();
}

sel_pen_tool(selix)
WORD selix;
{
pen_tool_group = selix;
unxmenu(&vdraw_pull);
xone(&vdraw_pull, selix);
text_cursor = 0;
fill_cursor = 0;
use_brush_cursor = 1;
switch (selix)
	{
	case 0:
		pen_tool = draw;
		break;
	case 1:
		pen_tool = scribble;
		break;
	case 2:
		pen_tool = drizzle;
		break;
	case 3:
		pen_tool = spray;
		break;
	case 4:
		pen_tool = flood;
		fill_cursor = 1;
		break;
	case 5:
		pen_tool = draw_line;
		break;
	case 6:
		pen_tool = draw_polygon;
		break;
	case 7:
		pen_tool = draw_circle;
		break;
	case 8:
		pen_tool = draw_box;
		break;
	case 9:
		pen_tool = pen_text;
		text_cursor = 1;
		break;
	}
}

#ifdef SLUFFED
oshow_status()
{
char buf[48];

sprintf(buf, "%d of %d | %ld free of %ld", screen_ix+1, screen_ct,
	mem_free, cel_mem_alloc);
top_line(buf);
}
#endif SLUFFED

save_undo()
{
hide_mouse();
copy_screen( cscreen, uscreen);
show_mouse();
}

swap_undo()
{
hide_mouse();
exchange_screen(cscreen, uscreen);
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

unundo()
{
copy_screen( uscreen, cscreen);
}

see_screen_ix()
{
hide_mouse();
unundo();
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

extern b_pic(), ub_pic(), clear_screen();

simple_multi_screen(v)
Vector v;
{
save_undo();
undo_to_buf();
hide_mouse();
if (select_mode == 0)
	{
	(*v)();
	dirtys();
	show_mouse();
	if (zoom_flag)
		zbuf_to_screen();
	}
else
	qdo_many(v, 0);
}

blue_pic()
{
simple_multi_screen(b_pic);
}

mblue_pic()
{
msetup();
blue_pic();
mrecover();
}

munblue_pic()
{
msetup();
unblue_pic();
mrecover();
}

unblue_pic()
{
simple_multi_screen(ub_pic);
}

mclear_pic()
{
msetup();
clear_pic();
mrecover();
}

clear_pic()
{
simple_multi_screen(clear_screen);
}

mclear_seq()
{
clear_seq();
}

_clear_seq()
{
empty_ram_dlt();
zero_screens();
zero_screen(bscreen);
see_top_lines();
rd_frames = 1;
screen_ct = 1;
screen_ix = 0;
}

clear_seq()
{
int i;

if (ok_clear_seq())
	{
	hide_mouse();
	_clear_seq();
	rd_name[0] = 0;
	dirty_file = 0;
	redraw_menu_frame();
	show_mouse();
	}
}

madvance_blue()
{
madv_changes(1);
}

madvance_changes()
{
madv_changes(0);
}

madv_changes(blue)
WORD blue;
{
WORD *mask;
Cel adv_cel;

zero_structure(&adv_cel, sizeof(adv_cel) );
hide_mouse();
if (cur_menu != NULL || zoom_flag)
	copy_screen(bscreen,pscreen);
if (blue)
	{
	if ((mask = (WORD *)begmem(Mask_block(320, 200)) ) == NULL)
		return;
	blue_mask(pscreen, mask);
	copy_screen(prev_screen, bscreen);
	do_deltas(ram_screens[screen_ix], bscreen);
	mask_copy_screen(bscreen, mask, pscreen);
	freemem(mask);
	}
adv_cel.image_size = Raster_block((long)320, (long)200);
adv_cel.image = bscreen;
adv_cel.width = 320;
adv_cel.height = 200;
adv_cel.mask = NULL;
adv_cel.xoff = adv_cel.yoff = 0;
if (!changes_to_cel(pscreen, &adv_cel))
	{
	outta_memory();
	redraw_menu_frame();
	show_mouse();
	return;
	}
if (sub_ram_deltas(pscreen))
	{
	if (screen_ix < screen_ct-1 )
		{
		screen_ix++;
		advance_next_prev(pscreen);
		do_deltas(ram_screens[screen_ix], pscreen);
		qput_cmap(ram_screens[screen_ix]);
		copy_screen(pscreen, uscreen);
		if (blue)
			stencil1(adv_cel.mask, pscreen);
		else
			mask_copy_screen(adv_cel.image, adv_cel.mask, pscreen);
		}
	}
freemem(adv_cel.mask);
copy_screen(pscreen, bscreen);
redraw_menu_frame();
dirtys();
show_mouse();
}



get_changes()
{
hide_mouse();
if (!do_get_changes(cscreen))
	outta_memory();
show_mouse();
}

mrestore_pic()
{
msetup();
restore_pic();
mrecover();
}

restore_pic()
{
save_undo();
hide_mouse();
restore_changes(cscreen);
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

restore_changes(screen)
WORD *screen;
{
copy_screen(prev_screen, screen);
do_deltas(ram_screens[screen_ix], screen);
put_cmap(ram_screens[screen_ix]);
}

mget_changes()
{
hide_mouse();
if (!do_get_changes(bscreen))
	outta_memory();
show_mouse();
}

changes_to_cel(screen, cel)
WORD *screen;
Cel *cel;
{
WORD *image;

image = cel->image;
copy_screen(prev_screen, image);
do_deltas(ram_screens[screen_ix], image);
xor_screen(screen, image);
if (!mask_cel(cel))
	{
	return(0);
	}
zero_screen(image);
mask_copy_screen(screen, cel->mask, image);
return(1);
}

do_get_changes(screen)
WORD *screen;
{
free_cel(clipping);
if ((clipping = alloc_cel(320, 200)) == NULL)
	{
	return(0);
	}
if (!changes_to_cel(screen, clipping))
	{
	free_cel(clipping);
	clipping = NULL;
	return(0);
	}
return(1);
}


go_byebye()
{
hide_mouse();
draw_on_screen();
uninit_sys();
exit(0);
}



rub_zoom()
{
draw_frame(white, zoomx, zoomy, 
	zoomx+XMAX/4-1, zoomy+YMAX/4-1);
}

clip_zoom()
{
if (zoomx > XMAX - XMAX/4)
	zoomx = XMAX - XMAX/4;		/* don't let zoom go off screen */
if (zoomx < 0)
	zoomx = 0;
if (zoomy > YMAX - YMAX/4)
	zoomy = YMAX - YMAX/4;		/* don't let zoom go off screen */
if (zoomy < 0)
	zoomy = 0;
}

clip_zoomxy(x, y)
WORD x, y;
{
zoomx = x-XMAX/8+8;	/* mouse in middle of zoom buffer */
zoomx &= 0xfff0;	/* zoomx must be on a word boundary */
zoomy = y-YMAX/8;	/* mouse in middle of zoom buffer */
clip_zoom();
}

make_clip_brush()
{
clip_brush = !clip_brush;
xonflag(&clip_brush_pull, clip_brush);
}

get_brush()
{
WORD brush_buf[16];
WORD xoff, yoff;
extern WORD preshift1[];
extern WORD last_brush_ix;

if (brush_ix == 0)
	{
	not_brush_0();
	return;
	}
msetup();
save_undo();
hide_mouse();
draw_on_buffer();
for (;;)
	{
	check_input();
	xoff = mouse_x-8;
	yoff = mouse_y-8;
	if (xoff < 0)
		xoff = 0;
	if (yoff < 0)
		yoff = 0;
	if (xoff > XMAX-16)
		xoff = XMAX-16;
	if (yoff > YMAX-16)
		yoff = YMAX-16;
	unundo();
	draw_frame(white, xoff-1, yoff-1, 
		xoff+16, yoff+16);
	see_buffer();
	check_input();
	if (RJSTDN)
		{
		unundo();
		break;
		}
	if (PJSTDN)
		{
		unundo();
		aget_brush(xoff, yoff, brush_buf );
		if (!sixteen_zeros(brush_buf) )	/* avoid empty brushes */
			{
			copy_words(brush_buf, brushes[brush_ix], 16);
			last_brush_ix = -1;
			}
		break;
		}
	}
see_buffer();
draw_on_screen();
if (zoom_flag)
	zscale_cursor = 0;
mrecover();
pick_cursor();
wait_penup();
}

dozoom()	/* toggle zoom state, rub around the zoom box if turning on*/
{
if (!zoom_flag)
	{
	hide_mouse();
	copy_screen(cscreen, bscreen);
	clip_zoomxy(mouse_x, mouse_y);
	rub_zoom();
	show_mouse();
	for (;;)
		{
		check_input();
		if (mouse_moved)
			{
			clip_zoomxy(mouse_x, mouse_y);
			hide_mouse();
			copy_screen(bscreen, cscreen);
			rub_zoom();
			show_mouse();
			}
		if (PDN)
			break;
		}
	hide_mouse();
	draw_on_buffer();
	zscale_cursor = zoom_flag = 1;
	pick_cursor();
	zbuf_to_screen();
	wait_penup();
	}
else
	{
	hide_mouse();
	draw_on_screen();
	buf_to_screen();
	zscale_cursor = zoom_flag = 0;
	pick_cursor();
	}
xonflag(&zoom_pull, zoom_flag);
}


mdozoom()
{
msetup();
dozoom();
mrecover();
}

go_cycle()
{
cycle_draw = !cycle_draw;
xonflag(&cycle_pull, cycle_draw);
if (cycle_draw)
	{
	init_cycle();
	}
}

