
#include "flicker.h"
#include "flicmenu.h"

extern Pull vdraw_pull, nozero_pull, filled_pull, degas_pull, 
	distinct_pull, connected_pull, concentric_pull, compress_pull, 
	zoom_pull, toall_pull, cycle_pull, pingpong_pull, clip_brush_pull;

extern Flicmenu main_menu, menutime, rcolor_menu, menu_save, text_menu;
extern Flicmenu supermove_menu;

extern WORD clip_brush;
extern WORD nozero_flag;
extern WORD filled_flag;
extern WORD connect_mode;
extern WORD ping_pong;
extern WORD degas;
extern WORD compress_flag;	/* save it compressed? */
extern WORD toall_flag;	/* "tween" rotations etc" */

erase_top_menu(m)
Flicmenu *m;
{
hide_mouse();
erase_seg(m->y-1, main_menu.y - m->y+1);
show_mouse();
}

xor_zero_flag()
{
nozero_flag = !nozero_flag;
xonflag(&nozero_pull, nozero_flag);
}

xor_filled_flag()
{
filled_flag = !filled_flag;
xonflag(&filled_pull, filled_flag);
}

xor_ping_pong()
{
ping_pong = !ping_pong;
xonflag(&pingpong_pull, ping_pong);
}

sel_main_pull(menuval)
int menuval;
{
int i;
unsigned char menuix, selix;


menuix = menuval>>8;
selix = menuval&0xff;
switch (menuix)
	{
	case 0:	/* file menu */
		switch (selix)
			{
			case 0:
				copyright();
				break;
			case 1:
				break;
			case 2:
				mtime();
				break;
			case 3:
				msave();
				break;
			case 4:
				mmatte();
				break;
			case 5:
				mtext();
				break;
			case 6:
				mair();
				break;
			case 7:
				mshow_status(NULL);
				break;
			case 8:
				mpixelfx();
				break;
			case 9:
				msupermove();
				break;
			case 10:
				mclear_seq();
				break;
			case 11:
				mgo_byebye();
				break;
			}
		break;
	case 1:	/* Edit Menu */
		switch (selix)
			{
			case 0:
				mcut();
				break;
			case 1:
				mpaste();
				break;
			case 2:
				mpaste_under();
				break;
			case 3:
				mmove();
				break;
			case 4:
				mclip();
				break;
			case 5:
				mrotate();
				break;
			case 6:
				mstretch();
				break;
			case 7:
				mflip();
				break;
			case 8:
				mcfit();
				break;
			case 9:
				mmask_clip();
				break;
			}
		break;
	case 2:		/* Draw Menu */
		sel_pen_tool(selix);
		break;
	case 3:
		switch (selix)
			{
			case 0:
				mdozoom();
				break;
			case 1:
				xor_ping_pong();
				break;
			case 2:
				xor_zero_flag();
				break;
			case 3:
				xor_filled_flag();
				break;
			case 5:
			case 6:
			case 7:
				connect_mode = selix-5;
				xonflag(&distinct_pull, 0);
				xonflag(&connected_pull, 0);
				xonflag(&concentric_pull, 0);
				xone(&distinct_pull, connect_mode);
				break;
			}
		break;
	case 4:	/* Frames menu */
		switch (selix)
			{
			case 0:
				mswap_undo();
				break;
			case 1:
				mrestore_pic();
				break;
			case 2:
				mcolor_separate();
				break;
			case 3:
				mseparate_many();
				break;
			case 4:
				mblue_pic();
				break;
			case 5:
				munblue_pic();
				break;
			case 6:
				madvance_blue();
				break;
			case 7:
				mget_changes();
				break;
			case 8:
				madvance_changes();
				break;
			case 9:
				mclear_pic();
				break;
			case 10:
				mkill(NULL);
				break;
			case 11:
				mscratch();
				break;
			}
		break;
	case 5:
		if (selix == 16)
			{
			get_brush();
			selix = brush_ix;
			clip_brush = 0;
			xonflag(&clip_brush_pull, 0);
			}
		else if (selix == 17)
			{
			make_clip_brush();
			selix = brush_ix;
			}
		else
			{
			clip_brush = 0;
			xonflag(&clip_brush_pull, 0);
			}
		set_brush(selix);	/* set brush for system */
		break;
	case 6:
		if (selix < 16)
			{
			ccolor = selix;
			if (cycle_draw)
				go_cycle();
			}
		else
			{
			switch (selix)
				{
				case 16:
					go_cycle();
					break;
				case 17:
					mpalette();
					break;
				case 18:
					mcefx();
					break;
				}
			}
		break;
	}
}

