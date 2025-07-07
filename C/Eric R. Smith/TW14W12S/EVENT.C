/*
 * Copyright 1992 Eric R. Smith. All rights reserved.
 * Redistribution is permitted only if the distribution
 * is not for profit, and only if all documentation
 * (including, in particular, the file "copying")
 * is included in the distribution in unmodified form.
 * THIS PROGRAM COMES WITH ABSOLUTELY NO WARRANTY, NOT
 * EVEN THE IMPLIED WARRANTIES OF MERCHANTIBILITY OR
 * FITNESS FOR A PARTICULAR PURPOSE. USE AT YOUR OWN
 * RISK.
 */
#include "xgem.h"
#include <osbind.h>
#include <ctype.h>
#include <stdlib.h>
#include "twdefs.h"
#include "twproto.h"

/*
 * global variables for any GEM/AES application
 */

/* VDI physical and virtual workstation handles */
int phys_handle, vdi_handle = -1;

/* AES application ID */
int gl_apid;

/* system character size */
int gl_hchar, gl_wchar, gl_wbox, gl_hbox;

/* size of the desktop area */
int xdesk, ydesk, hdesk, wdesk;

/* number of fonts available */
int gl_numfonts = 1;

/* rectangle we're watching for events */
int gl_rx, gl_ry, gl_rw, gl_rh, gl_rstate;

/* number of planes on screen */
int gl_screenplanes;

/*
 * global variables used by the xgem library
 */

int gl_button;		/* button state */
int gl_done;		/* set when the user wants to quit */
long gl_timer;		/* how many milliseconds before evnt_loop
			   times out */
void (*fn_timeout)();	/* what to do when a time out occurs */
void (*fn_message)();	/* function for handling non-standard messages */
void (*fn_mouse)();	/* mouse handler */
int (*fn_key)();	/* default keyboard handler */
void (*fn_rect)();	/* handler for rectangle events */

/* variable that tells us about GDOS
 * 0:  no GDOS
 * 1:  old GDOS, or a clone
 * 2:  FontGDOS
 * 3:  FSMGDOS
 */

#define GDOS 1
#define FontGDOS 2
#define FSMGDOS 3
int gdos_active;

#ifdef WWA_AUTO_RAISE
/*
 * flag enabling auto-raise-on-focus of windows.
 */
int auto_raise;
#endif

/*
 * local variables
 */

static int msgbuff[8];	/* AES message buffer */
static int hidden;	/* mouse hidden? */


/*
 * some misc. utilities
 */

void
hide_mouse()
{
	if (!hidden) {
		graf_mouse(M_OFF, 0x0L);
		hidden = TRUE;
	}
}

void
show_mouse()
{
	if (hidden) {
		graf_mouse(M_ON, 0x0L);
		hidden = FALSE;
	}
}

/* set clipping rectangle */

static int clip[4];

void set_clip(x,y,w,h)
int x,y,w,h;
{
	clip[0] = x;
	clip[1] = y;
	clip[2] = clip[0]+w-1;
	clip[3] = clip[1]+h-1;
	vs_clip(vdi_handle, 1, clip);
}

/*
 * Call this function to turn clipping off.
 */

void
reset_clip()
{
	vs_clip(vdi_handle, 0, clip);
	clip[0] = clip[1] = clip[2] = clip[3] = -1;
}

static void
handle_key(code, shift)
	int code, shift;
{
	if (menu_key(code, shift)) {
		return;
	}
	if (window_key(code, shift)) {
		return;
	}
	if (fn_key && (*fn_key)(code))
		return;
}

static void
handle_click(mclicks, mx, my, mshift, mbutton)
	int mclicks, mx, my, mshift, mbutton;
{
	extern int window_click();

	if (window_click(mclicks, mx, my, mshift, mbutton))
		return;
	if (fn_mouse)
		(*fn_mouse)(mclicks, mx, my, mshift, mbutton);
}

/*
 * main event loop for most applications
 */

void
evnt_loop()
{
	int event;
	int msx, msy, mbutton, mshift, mbreturn;
	int keycode;
	int evnt_type;
	extern void handle_menu();
	int gx, gy, gw, gh;
	int checkmenu = 0;

	gl_done = FALSE;
	do {
		evnt_type = MU_MESAG | MU_BUTTON | MU_KEYBD;
		if (fn_timeout) evnt_type |= MU_TIMER;
		if (fn_rect) evnt_type |= MU_M1;
		if (checkmenu && gl_topwin && gl_topwin->menu &&
		    (gl_topwin->wi_handle > 0) &&
		    (gl_topwin->wi_kind & INFO)) {
			evnt_type |= MU_M2;
			gx = gl_topwin->wi_x;
			gy = gl_topwin->wi_y - gl_hbox;
			gw = strlen(gl_topwin->infostr)*gl_wchar;
			if (gw > gl_topwin->wi_w)
				gw = gl_topwin->wi_w;
			gh = gl_hbox;
		} else {
			gx = gy = gw = gh = 0;
		}
		event = evnt_multi(evnt_type,
#if WWA_X_SELECT
			0x0102,
#else
			0x0101,
#endif
			0x0003, 0x0000,
			gl_rstate,gl_rx,gl_ry,gl_rw,gl_rh,
			0,gx,gy,gw,gh,
			msgbuff,
			gl_timer,
			&msx, &msy, &mbutton, &mshift,
			&keycode,
			&mbreturn);

		if (event & MU_MESAG) {
			switch (msgbuff[0]) {
			case MN_SELECTED:
				handle_menu(msgbuff[3], msgbuff[4]);
				break;
			case WM_REDRAW:
			case WM_TOPPED:
			case WM_CLOSED:
			case WM_FULLED:
			case WM_ARROWED:
			case WM_HSLID:
			case WM_VSLID:
			case WM_SIZED:
			case WM_MOVED:
				handle_window(msgbuff);
				break;
			default:
				if (fn_message)
					(*fn_message)(msgbuff);
				break;
			}
		}

	/* if we got a message, the top window may have been changed,
	 * so ignore drop down menu events
	 */
		else if (event & MU_M2) {
			if (msx >= gx && msx < gx+gw &&
			    msy >= gy && msy < gy+gh) {
				dropdown_menu(gl_topwin->menu, gx, gy);
			}
			checkmenu = 0;
		} else {
			checkmenu = 1;
		}

/* if we are "pointing to type", then set the focus window appropriately */
		if (point_to_type) {
			WINDOW *newfocus;
			TEXTWIN *oldt, *newt;

			oldt = newt = 0;
			newfocus = find_window(msx, msy);
			if (!newfocus) newfocus = gl_topwin;
			if (newfocus != focuswin) {

#ifdef WWA_AUTO_RAISE
/*
 *  Warwick Allison Auto-raise extension:
 *
 *        Window topped when receiving focus.
 */
				if (auto_raise && newfocus) {
					/* Send fake "WM_TOPPED" message */
					int fakemsgbuff[8];	/* AES message buffer */
					fakemsgbuff[0]=WM_TOPPED;
					fakemsgbuff[3]=newfocus->wi_handle;
					handle_window(fakemsgbuff);
				}
#endif

				if (focuswin && focuswin->wtype == TEXT_WIN) {
					oldt = focuswin->extra;
					curs_off(oldt);
				}
				if (newfocus && newfocus->wtype == TEXT_WIN) {
					newt = newfocus->extra;
					curs_off(newt);
				}
				focuswin = newfocus;
				if (oldt) { 
					curs_on(oldt);
					refresh_textwin(oldt);
				}
				if (newt) {
					curs_on(newt);
					refresh_textwin(newt);
				}
			}
		}
		else
			focuswin = gl_topwin;

		if (event & MU_BUTTON) {
			handle_click(mbreturn, msx, msy, mshift, mbutton);
		}

		if (event & MU_KEYBD) {
			handle_key(keycode, mshift);
		}

		if (event & MU_M1) {
			gl_rstate = !gl_rstate;
			(*fn_rect)(msx, msy);
		}

		if (event & MU_TIMER) {
			(*fn_timeout)();
		}
	} while (!gl_done);
}

static int lasttextcolor, lastfillcolor, lastwrmode, lastheight, lastfont;
static int laststyle, lastindex;
static int lasteffects;

void
open_vwork()
{
	int work_in[11];
	int work_out[57];
	int i;

/* open a virtual workstation */
	if (vdi_handle > 0)		/* workstation already open */
		return;
	for (i = 1; i < 10; i++)
		work_in[i] = 1;
	work_in[0] = Getrez()+2;
	work_in[10] = 2;
	vdi_handle = phys_handle;
	v_opnvwk(work_in, &vdi_handle, work_out);
	lastheight = lasttextcolor = lastfillcolor = lastwrmode = -1;
	lasteffects = 0;
	lastindex = laststyle = lastfont = 1;
	gl_numfonts = work_out[10];
	if (gdos_active)
		gl_numfonts += vst_load_fonts(vdi_handle, 0);
	vq_extnd(vdi_handle, 1, work_out);
	gl_screenplanes = work_out[4];
}

void
close_vwork()
{
	if (vdi_handle > 0) {
		if (gdos_active)
			vst_unload_fonts(vdi_handle, 0);
		v_clsvwk(vdi_handle);
	}
	vdi_handle = -1;
}

void
init_gem()
{
	extern int vq_gdos();
	extern short _app;
	long gdosvers;

	gl_apid = appl_init();
	phys_handle = graf_handle(&gl_wchar, &gl_hchar, &gl_wbox, &gl_hbox);
	wind_get(0, WF_WORKXYWH, &xdesk, &ydesk, &wdesk, &hdesk);
	gdos_active = vq_gdos();
	if (gdos_active) {
		gdosvers = vq_vgdos();
		if (gdosvers == GDOS_NONE) {
			gdos_active = 0;
		} else if (gdosvers == GDOS_FSM) {
			gdos_active = FSMGDOS;
		} else if (gdosvers == GDOS_FNT) {
			gdos_active = FontGDOS;
		} else {
			gdos_active = GDOS;
		}
	}

	open_vwork();
	if (_app) {
		graf_mouse(ARROW, 0L);
	}
}

/*
 * exit a gem application
 */

void
exit_gem(status)
	int status;
{
#ifdef JUST_IN_CASE
	wind_update(0);	/* just in case */
#endif
	end_windows();
	close_vwork();
	appl_exit();
	exit(status);
}

/*
 * some more miscellaneous utility routines
 */

void
set_fillcolor(col)
	int col;
{
	if (col == lastfillcolor) return;
	vsf_color(vdi_handle, col);
	lastfillcolor = col;
}

void
set_textcolor(col)
	int col;
{
	if (col == lasttextcolor) return;
	vst_color(vdi_handle, col);
	lasttextcolor = col;
}

void
set_texteffects(effects)
	int effects;
{
	if (effects == lasteffects) return;
	lasteffects = vst_effects(vdi_handle, effects);
}

void
set_wrmode(mode)
	int mode;
{
	if (mode == lastwrmode) return;
	vswr_mode(vdi_handle, mode);
	lastwrmode = mode;
}

static int
is_fsm_font(font)
	int font;
{
	int i;

	for (i = 0; i < gl_numfonts; i++) {
		if (fontdesc[i].fontidx == font)
			return fontdesc[i].isfsm;
	}
	return 0;
}

/* This function sets both the font and the size (in points).
 */

void
set_font(font, height)
	int font, height;
{
	int cw, ch, bw, bh;

	if (font != lastfont) {
		vst_font(vdi_handle, font);
		lastfont = font;
		lastheight = height-1;
	}
	if (height != lastheight) {
		if (gdos_active == FSMGDOS && is_fsm_font(font)) {
			lastheight = vst_arbpt(vdi_handle, height,
				&cw, &ch, &bw, &bh);
		} else {
			lastheight = vst_point(vdi_handle, height, &cw, &ch,
				 &bw, &bh);
		}
	}
}

void
set_fillstyle(style, index)
	int style, index;
{
	if (laststyle != style)
		laststyle = vsf_interior(vdi_handle, style);

	if (index != lastindex)
		lastindex = vsf_style(vdi_handle, index);
}
