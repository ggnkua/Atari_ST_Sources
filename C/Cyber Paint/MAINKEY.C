
#include "flicker.h"
#include "flicmenu.h"
#include <ctype.h>

extern WORD *ram_dlt;
extern Flicmenu menu_save,  menutime, rcolor_menu, text_menu;



do_key()
{
register unsigned char c, d;

c = key_in;
if (isalpha(c))
	c = _tolower(c);
d = key_in>>8;
switch(c)
	{
	case 0:
		switch (d)
			{
			case 0x3b:	/* F1 */
				jump_start_frame();
				break;
			case 0x3c:	/* F2 */
				play_fast_backwards();
				break;
			case 0x3d:	/* F3 */
				play_backwards();
				break;
			case 0x3e:	/* F4 */
				mlast_frame();
				break;
			case 0x3f:	/* F5 */
				last_frame();
				break;
			case 0x40:	/* F6 */
				next_frame();
				break;
			case 0x41:	/* F7 */
				mnext_frame();
				break;
			case 0x42:	/* F8 */
				play_forwards();
				break;
			case 0x43:	/* F9 */
				play_fast();
				break;
			case 0x44:	/* F10 */
				end_frame();
				break;
			case 0x4b:	/* left arrow */
				last_frame();
				break;
			case 0x4d:	/* right arrow */
				next_frame();
				break;
			case 0x48:	/* up arrow */
				play_backwards();
				break;
			case 0x50: /* down arrow */
				play_forwards();
				break;
			case 0x61: /* undo */
				swap_undo();
				break;
			case 0x52: /* insert */
				mlast_frame();
				break;
			case 0x47: /* clr/home */
				clear_pic();
				break;
			}
		break;
	case '1':	/* escape */
		sel_pen_tool(0);
		break;
	case '2':
		sel_pen_tool(1);
		break;
	case '3':
		sel_pen_tool(2);
		break;
	case '4':
		sel_pen_tool(3);
		break;
	case '5':
		sel_pen_tool(4);
		break;
	case '6':
		sel_pen_tool(5);
		break;
	case '7':
		sel_pen_tool(6);
		break;
	case '8':
		sel_pen_tool(7);
		break;
	case '9':
		sel_pen_tool(8);
		break;
	case '0':
		sel_pen_tool(9);
		break;
	case '-':
		color_separate();
		break;
	case '_':
		separate_many();
		break;
	case 'c':
		hide_mouse();
		if (cycle_draw)
			go_cycle();
		ccolor = getdot(mouse_x, mouse_y);
		show_mouse();
		break;
	case 0x1b:	/* escape */
		cut_clip();
		break;
	case 'p':
		paste_clip();
		break;
	case 'b':
		paste_under();
		break;
	case 'm':
		position_clip();
		break;
	case '\t':
		clip_clip();
		break;
	case 'r':
		rotate_clip();
		break;
	case 's':
		stretch_clip();
		break;
	case 'i':
		flip_clip();
		break;
	case 'n':
		cfit_clip();
		break;
	case 'v':
		mask_clip();
		break;
#ifdef LATER
	case 'j':
		mask_clip();
		break;
#endif LATER
	case '\b':
		restore_pic();
		break;
	case '*':
		get_changes();
		break;
	case '/':
		madvance_blue();
		break;
	case '+':
		madvance_changes();
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
	case '!':
		go_cycle();
		break;
	case '@':
		unzoom();
		mpalette();
		rezoom();
		break;
	case '~':
		unzoom();
		mpixelfx();
		rezoom();
		break;
	case '%':
		unzoom();
		mcefx();
		rezoom();
		break;
	case 'x':
		xor_zero_flag();
		break;
	case 'w':
		xor_ping_pong();
		break;
	case 'z':
		dozoom();
		break;
	case 'f':
		xor_filled_flag();
		break;
	case 'k':
		clear_seq();
		break;
	case 'q':
		mgo_byebye();
		break;
	case 'a':
		unzoom();
		msupermove();
		rezoom();
		break;
	case '?':
		mshow_status(NULL);
		break;
	case '=':
		unzoom();
		mtext();
		rezoom();
		break;
	case '#':
		unzoom();
		mair();
		rezoom();
		break;
	case '$':
		unzoom();
		mmatte();
		rezoom();
		break;
	case 'l':
		unzoom();
		msave();
		rezoom();
		break;
	case 't':
		unzoom();
		mtime();
		rezoom();
		break;
	case '\\':
		scratch();
		break;
	case ' ':
		do_pull();
		break;
	case '\r':
	case '\n':
		add_ten();
		break;
	case 'u':
		make_clip_brush();
		break;
	case 'g':
		unzoom();
		get_brush();
		rezoom();
		break;
	case '.':
		tog_sel_mode();
		break;
	}
}

extra_keys()
{
register unsigned char c, d;

c = key_in;
if (isalpha(c))
	c = _tolower(c);
d = key_in>>8;
switch(c)
	{
	case 0:
		switch (d)
			{
			case 0x4b:	/* left arrow */
				mmlast_frame(NULL);
				break;
			case 0x4d:	/* right arrow */
				mmnext_frame(NULL);
				break;
			case 0x48:	/* up arrow */
				mplay_backwards();
				break;
			case 0x50: /* down arrow */
				mplay_forwards();
				break;
			case 0x61: /* undo */
				mswap_undo();
				break;
			case 0x52: /* insert */
				minsert(NULL);
				break;
			case 0x47: /* clr/home */
				mclear_pic(NULL);
				break;
			}
		break;
	case '1':	/* escape */
		sel_pen_tool(0);
		break;
	case '2':
		sel_pen_tool(1);
		break;
	case '3':
		sel_pen_tool(2);
		break;
	case '4':
		sel_pen_tool(3);
		break;
	case '5':
		sel_pen_tool(4);
		break;
	case '6':
		sel_pen_tool(5);
		break;
	case '7':
		sel_pen_tool(6);
		break;
	case '8':
		sel_pen_tool(7);
		break;
	case '9':
		sel_pen_tool(8);
		break;
	case '0':
		sel_pen_tool(9);
		break;
	case '-':
		mcolor_separate();
		break;
	case '_':
		mseparate_many();
		break;
	case 'c':
		hide_mouse();
		if (cycle_draw)
			go_cycle();
		ccolor = getdot(mouse_x, mouse_y);
		show_mouse();
		break;
	case 0x1b:	/* escape */
		mcut();
		break;
	case 'b':
		mpaste_under();
		break;
	case 'p':
		mpaste();
		break;
	case 'm':
		mmove();
		break;
	case '\t':
		mclip();
		break;
	case 'r':
		mrotate();
		break;
	case 's':
		mstretch();
		break;
	case 'i':
		mflip();
		break;
	case 'n':
		mcfit();
		break;
	case 'v':
		mmask_clip();
		break;
#ifdef LATER
	case 'j':
		mmask_clip();
		break;
#endif LATER
	case 0x7f:	/* delete */
		mkill(NULL);
		break;
	case '!':
		go_cycle();
		break;
	case '~':
		mpixelfx();
		break;
	case '@':
		mpalette();
		break;
	case '%':
		mcefx();
		break;
	case 'k':
		mclear_seq();
		break;
	case 'q':
		mgo_byebye();
		break;
	case '?':
		mshow_status(NULL);
		break;
	case '=':
		mtext();
		break;
	case '#':
		mair();
		break;
	case '$':
		mmatte();
		break;
	case 'a':
		msupermove();
		break;
	case 'l':
		msave();
		break;
	case 't':
		mtime();
		break;
	case '\b':
		mrestore_pic();
		break;
	case '*':
		mget_changes();
		break;
	case '+':
		madvance_changes();
		break;
	case '/':
		madvance_blue();
		break;
	case '(':
		mblue_pic();
		break;
	case ')':
		munblue_pic();
		break;
	case 'x':
		xor_zero_flag();
		break;
	case 'w':
		xor_ping_pong();
		break;
	case 'f':
		xor_filled_flag();
		break;
	case '\\':
		mscratch();
		break;
	case 'z':
		mdozoom();
		break;
	case 'u':
		make_clip_brush();
		break;
	case 'g':
		get_brush();
		break;
	}
}


