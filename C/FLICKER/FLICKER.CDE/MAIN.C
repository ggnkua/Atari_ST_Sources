/* :ts=3 */
#include <osbind.h>
#include <gemdefs.h>
#include "flicker.h"

extern Pull root_pull;
extern Pull vdraw_pull, nozero_pull, filled_pull, degas_pull, zoom_pull;
extern drizzle(), draw(), draw_box(), draw_line(), rays(), flood(),
	draw_circle(), spray(), draw_lines(), draw_polygon();

WORD ccolor = 2;
WORD nozero_flag = 1;
WORD filled_flag = 1;
WORD degas = 1;
WORD use_brush_cursor = 1;
WORD zoom_flag = 0;	/* are we in zoom mode? */
WORD zoomx, zoomy;	/* offset of zoom area into full screen */
WORD zscale_cursor;
Vector pen_tool = draw;

char dot_neo[] = "NEO";
char dot_pi1[] = "PI1";
char dot_cel[] = "CEL";
char dot_col[] = "COL";
char dot_seq[] = "SEQ";


main(argc, argv)
int argc;
char *argv[];
{
int i;
unsigned char menuix, selix;


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
	if (key_hit)
		do_key();
	else if (EDN)
		{
		if (PDN)
			(*pen_tool)();
		else if (RDN)
			{
			if ((i = pull(&root_pull)) >= 0)
				{
				menuix = i>>8;
				selix = i&0xff;
				switch (menuix)
					{
					case 0:	/* file menu */
						switch (selix)
							{
							case 0:
								top_line("Flicker 0.2 Copyright 1987 Dancing Flame");
								break;
							case 1:
								break;
							case 2:
								go_lpic();
								break;
							case 3:
								go_spic();
								break;
							case 4:
								go_lcel();
								break;
							case 5:
								go_scel();
								break;
							case 6:
								go_lseq();
								break;
							case 7:
								go_sseq();
								break;
							case 8:
								go_lcol();
								break;
							case 9:
								go_scol();
								break;
							case 10:
								go_byebye();
								break;
							}
						break;
					case 1:	/* Edit Menu */
						switch (selix)
							{
							case 0:
								swap_undo();
								break;
							case 1:
								blue_pic();
								break;
							case 2:
								unblue_pic();
								break;
							case 3:
								clear_pic();
								break;
							case 4:
								clear_seq();
								break;
							case 6:
								cut_clip();
								break;
							case 7:
								clip_clip();
								break;
							case 8:
								paste_clip();
								break;
							case 9:
								cfit_clip();
								break;
							}
						break;
					case 2:		/* Draw Menu */
						unxmenu(&vdraw_pull);
						xone(&vdraw_pull, selix);
						switch (selix)
							{
							case 0:
								pen_tool = draw;
								use_brush_cursor = 1;
								break;
							case 1:
								pen_tool = drizzle;
								use_brush_cursor = 1;
								break;
							case 2:
								pen_tool = spray;
								use_brush_cursor = 1;
								break;
							case 3:
								pen_tool = flood;
								use_brush_cursor = 0;
								break;
							case 4:
								pen_tool = draw_line;
								use_brush_cursor = 0;
								break;
							case 5:
								pen_tool = draw_lines;
								use_brush_cursor = 0;
								break;
							case 6:
								pen_tool = draw_polygon;
								use_brush_cursor = 0;
								break;
							case 7:
								pen_tool = rays;
								use_brush_cursor = 0;
								break;
							case 8:
								pen_tool = draw_circle;
								use_brush_cursor = 1;
								break;
							case 9:
								pen_tool = draw_box;
								use_brush_cursor = 0;
								break;
							}
						pick_cursor();	/* based on use_brush_cursor */
						break;
					case 3:
						switch (selix)
							{
							case 0:
								show_status();
								break;
							case 1:
								nozero_flag = !nozero_flag;
								xonflag(&nozero_pull, nozero_flag);
								break;
							case 2:
								filled_flag = !filled_flag;
								xonflag(&filled_pull, filled_flag);
								break;
							case 3:
								xonflag(&degas_pull, degas);
								degas = !degas;
								break;
							case 4:
								dozoom();
								break;
							}
						break;
					case 4:	/* Frames menu */
						switch (selix)
							{
							case 0:
								next_frame();
								break;
							case 1:
								last_frame();
								break;
							case 2:
								start_frame();
								break;
							case 3:
								end_frame();
								break;
							case 4:
								mnext_frame();
								break;
							case 5:
								mlast_frame();
								break;
							case 6:
								delete_frame();
								break;
							case 8:
								play_forwards();
								break;
							case 9:
								play_backwards();
								break;
							case 10:
								play_slowly();
								break;
							case 11:
								play_fast();
								break;
							}
						break;
					case 5:
						set_brush(selix);	/* set brush for system */
						hide_mouse();		/* and force flicker mouse so immediately*/
						show_mouse();		/* see new brush */
						break;
					case 6:
						ccolor = selix;
						break;
					}
				}
			}
		}
	}
}

char *title;

char *
pic_suffix()
{
return( degas ? dot_pi1 : dot_neo);
}

go_lpic()
{
save_undo();
set_for_gem();
gmessage("Load Picture");
if ((title = get_fname(pic_suffix())) != NULL)
	load_pic(title);
set_for_jim();
see_screen_ix();
}

go_spic()
{
save_undo();
set_for_gem();
gmessage("Save Picture");
if ((title = get_fname(pic_suffix())) != NULL)
	{
	save_pic(title);
	}
set_for_jim();
see_screen_ix();
}

go_lcel()
{
save_undo();
set_for_gem();
gmessage("Load Cel");
if ((title = get_fname(dot_cel)) != NULL)
	load_cel(title);
set_for_jim();
see_screen_ix();
if (clipping != NULL)
	rub_paste(0, 0);	/* flash cel up on screen a second so user knows 
								it's really loaded */
wait_a_jiffy(20);
see_screen_ix();
}

go_scel()
{
if (  clipping == NULL)
	{
	top_line("No Clip to Save!");
	return;
	}
save_undo();
set_for_gem();
gmessage("Save Cel");
if ((title = get_fname(dot_cel)) != NULL)
	{
	save_cel(title);
	}
set_for_jim();
see_screen_ix();
}

go_lcol()
{
save_undo();
set_for_gem();
gmessage("Load Colors");
if ((title = get_fname(dot_col)) != NULL)
	load_col(title);
set_for_jim();
see_screen_ix();
}

go_scol()
{
save_undo();
set_for_gem();
gmessage("Save Colors");
if ((title = get_fname(dot_col)) != NULL)
	save_col(title);
set_for_jim();
see_screen_ix();
}


go_sseq()
{
save_undo();
set_for_gem();
gmessage("Save Sequence");
if ((title = get_fname(dot_seq)) != NULL)
	save_seq(title);
set_for_jim();
see_screen_ix();
}

go_lseq()
{
save_undo();
set_for_gem();
gmessage("Load Sequence");
if ((title = get_fname(dot_seq)) != NULL)
	load_seq(title);
set_for_jim();
see_screen_ix();
}


do_key()
{
register unsigned char c, d;

c = key_in;
d = key_in>>8;
switch(c)
	{
	case 0:
		switch (d)
			{
			case 0x3b:	/* F1 */
				cut_clip();
				break;
			case 0x3c:	/* F2 */
				clip_clip();
				break;
			case 0x3d:	/* F3 */
				paste_clip();
				break;
			case 0x3e:	/* F4 */
				cfit_clip();
				break;
			case 0x41:	/* F7 */
				play_fast();
				break;
			case 0x42:	/* F8 */
				play_slowly();
				break;
			case 0x43:	/* F9 */
				play_backwards();
				break;
			case 0x44:	/* F10 */
				play_forwards();
				break;
			case 0x4b:	/* left arrow */
				last_frame();
				break;
			case 0x4d:	/* right arrow */
				next_frame();
				break;
			case 0x48:	/* up arrow */
				start_frame();
				break;
			case 0x50: /* down arrow */
				end_frame();
				break;
			case 0x61: /* undo */
				swap_undo();
				break;
			case 0x52: /* insert */
				mlast_frame();
				break;
			case 0x47: /* clr/home */
				mnext_frame();
				break;
			}
		break;
	case 'c':
		hide_mouse();
		ccolor = getdot(mouse_x, mouse_y);
		show_mouse();
		break;
	case 'q':
		go_byebye();
		break;
	case ' ':
		show_status();
		break;
	case '\b': /* backspace */
		clear_pic();
		break;
	case '(':
		blue_pic();
		break;
	case ')':
		unblue_pic();
		break;
	case 0x7f:	/* delete */
		delete_frame();
		break;
	case 'z':
		dozoom();
		break;
	}
}

show_status()
{
char buf[48];

sprintf(buf, "%d of %d | %ld free of %ld", screen_ix+1, screen_ct,
	mem_free, cel_mem_alloc);
top_line(buf);
}

save_undo()
{
hide_mouse();
copy_screen( cscreen, screens[screen_ix]);
show_mouse();
}

swap_undo()
{
hide_mouse();
exchange_screen(cscreen, screens[screen_ix]);
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

unundo()
{
copy_screen( screens[screen_ix], cscreen);
}

see_screen_ix()
{
hide_mouse();
unundo();
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

clear_pic()
{
save_undo();
hide_mouse();
clear_screen();
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

clear_seq()
{
int i;

for (i=1; i<screen_ct; i++)
	{
	mfree(screens[i], 32000);
	screens[i] = NULL;
	}
screen_ix = 0;
screen_ct = 1;
hide_mouse();
clear_screen();
show_mouse();
save_undo();
if (zoom_flag)
	zbuf_to_screen();
}

blue_pic()
{
save_undo();
undo_to_buf();
hide_mouse();
b_pic();
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}

unblue_pic()
{
save_undo();
hide_mouse();
ub_pic();
show_mouse();
if (zoom_flag)
	zbuf_to_screen();
}


go_byebye()
{
hide_mouse();
draw_on_screen();
uninit_sys();
exit(0);
}


extern long time_peek();

rub_zoom()
{
draw_frame(white, zoomx, zoomy, 
	zoomx+XMAX/4-1, zoomy+YMAX/4-1);
}

clip_zoomxy(x, y)
WORD x, y;
{
zoomx = x-XMAX/8+8;	/* mouse in middle of zoom buffer */
zoomx &= 0xfff0;	/* zoomx must be on a word boundary */
if (zoomx > XMAX - XMAX/4)
	zoomx = XMAX - XMAX/4;		/* don't let zoom go off screen */
if (zoomx < 0)
	zoomx = 0;
zoomy = y-YMAX/8;	/* mouse in middle of zoom buffer */
if (zoomy > YMAX - YMAX/4)
	zoomy = YMAX - YMAX/4;		/* don't let zoom go off screen */
if (zoomy < 0)
	zoomy = 0;
}


dozoom()	/* toggle zoom state, rub around the zoom box if turning on*/
{
if (!zoom_flag)
	{
	save_undo();
	undo_to_buf();
	hide_mouse();
	draw_on_buffer();
	clip_zoomxy(mouse_x, mouse_y);
	rub_zoom();
	show_mouse();
	see_buffer();
	for (;;)
		{
		check_input();
		if (mouse_moved)
			{
			hide_mouse();
			unundo();
			clip_zoomxy(mouse_x, mouse_y);
			rub_zoom();
			show_mouse();
			see_buffer();
			}
		if (PDN)
			break;
		}
	hide_mouse();
	unundo();
	zscale_cursor = zoom_flag = 1;
	show_mouse();
	zbuf_to_screen();
	wait_penup();
	}
else
	{
	hide_mouse();
	draw_on_screen();
	buf_to_screen();
	zscale_cursor = zoom_flag = 0;
	show_mouse();
	}
xonflag(&zoom_pull, zoom_flag);
}

