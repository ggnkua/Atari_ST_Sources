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
#include <mintbind.h>
#include <fcntl.h>
#include <signal.h>
#include <minimal.h>
#include <string.h>
#include <unistd.h>
#include "toswin_w.h"
#include "twdefs.h"
#include "twproto.h"
#include <linea.h>

extern void free();
void *heapbase = 0;
long heapsize = 96*1024L;
long _stksiz = 6 * 1024L;
long termfunc;

WINDOW *focuswin;

#ifndef TIOCSWINSZ
#define TIOCGWINSZ	(('T'<< 8) | 11)
#define TIOCSWINSZ	(('T'<< 8) | 12)
#endif

/* set if we're running MultiTOS */
int MultiTOS = 0;

/* set if we're an accessory under old TOS */
int oldACC = 0;
int global_flag = 0;	/* set to O_GLOBAL if necessary */

/* file descriptor of TOSRUN */
int trun_fd;
extern long fd_mask;

/* is the "tools" window open? */
int showtools = 1;
int toolx, tooly;	/* location of tools window */

/* do we automatically close any windows that have exited? */
int autoclose;

/* try to scroll nicely? */
int smoothscroll;

/* 1 for "point to type", 0 for "click to type" */
int point_to_type;
WINDOW *toolwindow;

MENU *sysbar;		/* the system menu bar */
MENU *globalmenu;
MENU *windowmenu;
MENU *filemenu, *editmenu;
ENTRY *closeentry;
ENTRY *copyentry, *pasteentry;
MENU *gadgmenu;

int appl_menus = 1;	/* OK to load/show application menus */
int sys_menu = 1;	/* set if the system menu is being displayed */

OBJECT *deskobj;
OBJECT *cutdialog, *fontdial;
OBJECT *menudef_dialog;
OBJECT *winsize_dialog;

#define ALLGADGETS 0xfff	/* everything including the INFO line */
#define MINGADGETS 0x01f	/* NAME, CLOSER, FULLER, MOVER, INFO */
#define NOGADGETS  0x000

int default_kind = ALLGADGETS;

extern char progpath[128];
static char fname[256];
int altrow, altcol;
int stdrow, stdcol;
int altscroll, stdscroll;

char stdconfig[128] = "TOSWIN.CNF";
char nullstr[2] = "";

int lineAset = 0;
int lineArow, lineAcol;

#ifdef OLD_WAY
/*
 * signal handler for dead children
 * all we do is collect (and discard :-( ) the exit code
 * it's up to fd_input() and friends to figure out when no
 * more data exists for a window
 */

#define WNOHANG 1

void
dead_kid()
{
	long r;

	r = Pwait3(WNOHANG, (void *)0);

}

#endif

/*
 * signal handler for SIGINT and SIGQUIT: these get passed along to the
 * process group in the focus window
 */

void
send_sig(sig)
	long sig;
{
	TEXTWIN *t;

	if (focuswin && focuswin->wtype == TEXT_WIN) {
		t = focuswin->extra;
		if (t->pgrp) {
			(void)Pkill(-t->pgrp, (short)sig);
		}
	}
}

void
ignore()
{
}

char argstr[128];

void
newstdwin()
{
	TEXTWIN *t;

	if ((getprogname(fname) == OK) &&
	    (getargs(fname, argstr) == OK) ) {
		t = newproc(fname, argstr, progpath, 0, 0, stdcol, stdrow, stdscroll,
			default_kind, default_font, default_height);
		if (t)
			open_window(t->win);
	}
}

void
newaltwin()
{
	TEXTWIN *t;

	if ((getprogname(fname) == OK) &&
	    (getargs(fname, argstr) == OK) ) {
		t = newproc(fname, argstr, progpath, 0, 0, altcol, altrow, altscroll,
			default_kind, default_font, default_height);
		if (t)
			open_window(t->win);
	}
}

void
get_winsize(colptr, rowptr, sptr)
	int *colptr, *rowptr, *sptr;
{
	int x, y, w, h, i;
	TEDINFO *ted;
	char *rowstr, *colstr, *scrstr;
	int row, col, scroll;

	row = *rowptr;
	col = *colptr;
	scroll = *sptr;

	ted = (TEDINFO *)winsize_dialog[ROWBOX].ob_spec;
	rowstr = (char *)ted->te_ptext;
	strcpy(rowstr, valdec(row));
	ted = (TEDINFO *)winsize_dialog[COLBOX].ob_spec;
	colstr = (char *)ted->te_ptext;
	strcpy(colstr, valdec(col));
	ted = (TEDINFO *)winsize_dialog[SCRBOX].ob_spec;
	scrstr = (char *)ted->te_ptext;
	strcpy(scrstr, valdec(scroll));

	form_center(winsize_dialog, &x, &y, &w, &h);

	wind_update(1);
	form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
	if (win_flourishes)
		form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);

	objc_draw(winsize_dialog, 0, 2, x, y, w, h);

	i = form_do(winsize_dialog, COLBOX);

	if (win_flourishes)
		form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);

	form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);
	objc_change(winsize_dialog, i, 0, x, y, w, h, NORMAL, 0);
	wind_update(0);
	if (i != WINSIZOK) return;

	col = decval(colstr);
	if (col < MINCOLS) col = MINCOLS; else if (col > MAXCOLS) col = MAXCOLS;
	row = decval(rowstr);
	if (row < MINROWS) row = MINROWS; else if (row > MAXROWS) row = MAXROWS;
	scroll = decval(scrstr);
	if (scroll < 0) scroll = 0;

	*colptr = col;
	*rowptr = row;
	*sptr = scroll;
}

void
set_altsiz()
{
	get_winsize(&altcol, &altrow, &altscroll);
}

/*
 * set the line A variables and stdcol and
 * stdrow.
 */
void
set_linea(ncol, nrow)
	int ncol, nrow;
{
	lineAset = 1;
	stdrow = nrow;
	stdcol = ncol;
	V_CEL_MX = stdcol - 1;
	V_CEL_MY = stdrow - 1;
}

void
set_stdsiz()
{
	int ncol, nrow;

	ncol = stdcol;
	nrow = stdrow;
	get_winsize(&ncol, &nrow, &stdscroll);
	set_linea(ncol, nrow);
}

void
set_winsiz()
{
	TEXTWIN *t;
	int row, col, scroll;
	struct winsize tw;

	if (gl_topwin && gl_topwin->wtype == TEXT_WIN) {
		t = gl_topwin->extra;
		row = NROWS(t);
		col = NCOLS(t);
		scroll = SCROLLBACK(t);
		get_winsize(&col, &row, &scroll);
		if (col != NCOLS(t) || row != NROWS(t) ||
		    scroll != SCROLLBACK(t)) {
			curs_off(t);
			resize_textwin(t, col, row, scroll);
			curs_on(t);
			tw.ws_row = row;
			tw.ws_col = col;
			tw.ws_xpixel = tw.ws_ypixel = 0;
			(void)Fcntl(t->fd, &tw, TIOCSWINSZ);
			(void)Pkill(-t->pgrp, SIGWINCH);
		}
	}
}

void
set_wintitle()
{
	WINDOW *v;
	OBJECT *titledial;
	TEDINFO *ted;
	char *titlestr;
	int x, y, w, h, ret;

	v = gl_topwin;
	if (v && v->wtype == TEXT_WIN) {
		rsrc_gaddr(0, TITLDIAL, &titledial);
		ted = (TEDINFO *)titledial[TITLSTR].ob_spec;
		titlestr = (char *)ted->te_ptext;
		strncpy(titlestr, v->wi_title, 32);

		form_center(titledial, &x, &y, &w, &h);
		wind_update(1);
		form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
		if (win_flourishes)
			form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);
		objc_draw(titledial, 0, 2, x, y, w, h);
		ret = form_do(titledial, TITLSTR);
		if (win_flourishes)
			form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);
		form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);

		objc_change(titledial, ret, 0, x, y, w, h, NORMAL, 0);
		wind_update(0);
		if (ret != TITLOK) return;
		title_window(v, titlestr);
	}
}

/* shut down all windows */
void
shutdown()
{
	WINDOW *w;

	for (w = gl_winlist; w; w = w->next)
		(*w->closed)(w);
}

void
quit()
{
	if (_app) {
		gl_done = 1;
		shutdown();
	}
}

void
do_cut()
{
	extern void cut(), paste_to_desk();
	extern char *cliptext;
	int x, y;

	if (gl_topwin) {
		cut(gl_topwin);
		objc_offset(deskobj, CLIPICN, &x, &y);
		if (cliptext)
			paste_to_desk(x+1, y+1);
	}
}

void
do_paste()
{
	extern char *read_scrap();
	extern void paste();
	extern char *cliptext;

	if (!gl_topwin) return;

	if (cliptext)
		free(cliptext);

	cliptext = read_scrap("SCRAP.TXT");
	if (!cliptext) {
		form_alert(1, AlertStrng(SCRAPDAT));
		return;
	}
	paste(gl_topwin);
}

void
set_wfont()
{
	int font, point;
	int i;
	TEXTWIN *t;

	if (gl_topwin && gl_topwin->wtype == TEXT_WIN) {
		t = gl_topwin->extra;
		font = t->cfont;
		point = t->cpoints;
		i = get_font(&font, &point);
		if (i == OK)
			textwin_setfont(t, font, point);
	}
}

void
set_dfont()
{
	int font, point;

	font = default_font;
	point = default_height;

	if (get_font(&font, &point) == OK) {
		default_font = font;
		default_height = point;
	}
}

/*
 * functions for setting window gadgets
 * if "info_ok" is nonzero, we allow the
 * user to select the INFO line, otherwise
 * not. "kindptr" points to the current
 * settings on input, and is set to the
 * new settings on output.
 */

void
get_gadgets(kindptr, info_ok)
	int *kindptr;
	int info_ok;
{
	OBJECT *gadgdial;
	int kind = *kindptr;
	int ret;
	int x, y, w, h;
	int doubleclick = 0;

	rsrc_gaddr(0, GADGDIAL, &gadgdial);
	form_center(gadgdial, &x, &y, &w, &h);

/* make info_ok a mask */
	if (info_ok)
		info_ok = ~0;
	else
		info_ok = ~INFO;

	wind_update(1);

	form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
	if (win_flourishes)
		form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);

redisplay:
	gadgdial[GCLOSER].ob_state = (kind & CLOSER) ? SELECTED : NORMAL;
	gadgdial[GTITLE].ob_state = (kind & MOVER) ? SELECTED : NORMAL;
	if (info_ok & INFO) {
		gadgdial[GMENU].ob_state = (kind & INFO) ? SELECTED : NORMAL;
	} else {
		gadgdial[GMENU].ob_state = DISABLED;
	}
	gadgdial[GFULLER].ob_state = (kind & FULLER) ? SELECTED : NORMAL;
	gadgdial[GVSLIDE].ob_state = (kind & VSLIDE) ? SELECTED : NORMAL;
	gadgdial[GHSLIDE].ob_state = (kind & HSLIDE) ? SELECTED : NORMAL;
	gadgdial[GSIZER].ob_state = (kind & SIZER) ? SELECTED : NORMAL;
	objc_draw(gadgdial, 0, 2, x, y, w, h);
	ret = form_do(gadgdial, 0);
	if (ret & 0x8000) {
		doubleclick = 1;
		ret &= 0x7fff;
	}
	if (ret == GALLGAD) {
		kind = ALLGADGETS & info_ok; if (!doubleclick) goto redisplay;
	} else if (ret == GTOPGAD) {
		kind = MINGADGETS & info_ok; if (!doubleclick) goto redisplay;
	} else if (ret == GNOGAD) {
		kind = NOGADGETS; if (!doubleclick) goto redisplay;
	} else if (ret == GADGOK) {
		kind = 0;
		if (gadgdial[GCLOSER].ob_state == SELECTED)
			kind |= CLOSER;
		if (gadgdial[GFULLER].ob_state == SELECTED)
			kind |= FULLER;
		if (gadgdial[GSIZER].ob_state == SELECTED)
			kind |= SIZER;
		if (gadgdial[GTITLE].ob_state == SELECTED)
			kind |= (NAME|MOVER);
		if (gadgdial[GMENU].ob_state == SELECTED)
			kind |= INFO;
		if (gadgdial[GVSLIDE].ob_state == SELECTED)
			kind |= (UPARROW|DNARROW|VSLIDE);
		if (gadgdial[GHSLIDE].ob_state == SELECTED)
			kind |= (LFARROW|RTARROW|HSLIDE);
	} else if (ret == GADGCAN) {
		kind = *kindptr;
	}

	if (win_flourishes)
		form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);
	form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);
	wind_update(0);

	gadgdial[ret].ob_state = NORMAL;

	*kindptr = kind;
}

void
set_wkind()
{
	int kind;

	if (gl_topwin && gl_topwin->wtype == TEXT_WIN) {
		kind = gl_topwin->wi_kind;
		get_gadgets(&kind, gl_topwin->menu ? 1 : 0);
		change_window_gadgets(gl_topwin, kind);
	}
}

void
set_dkind()
{
	get_gadgets(&default_kind, 1);
}

/*
 * function that toggles an (integer) on/off switch in the global menu
 */

void
toggle(var)
	int *var;
{
	ENTRY *e;
	MENU *m = globalmenu;
	WINDOW *v;
	int x, y, w, h;

	*var = !*var;
	for (e = m->contents; e; e = e->next) {
		if (e->arg == var)
			break;
	}

	if (e) {
		if (*var) {
			check_entry(m, e);
		} else {
			uncheck_entry(m, e);
		}
	}

	if (var == &align_windows && *var) {
		for(v = gl_winlist; v; v = v->next) {
			if (v->wtype == TEXT_WIN && v->wi_handle >= 0) {
				wind_get(v->wi_handle, WF_CURRXYWH, &x,
					&y, &w, &h);
				(*v->moved)(v, x, y, w, h);
			}
		}
	}
}

/* bury the topmost window */

void
bury()
{
	new_topwin(0);
}

/* redraw the whole screen */

void
doredraw()
{
	sys_menu = 1;
#ifdef GLOBAL_APPL_MENUS
	if (gl_topwin && gl_topwin->wtype == TEXT_WIN) {
		if (gl_topwin->menu && appl_menus) {
			sys_menu = 0;
			show_menu(gl_topwin->menu);
		}
	}
#endif
	if (sys_menu)
		show_menu(sysbar);

	redraw_screen(xdesk, ydesk, wdesk, hdesk);
}

void
dieloop()
{
	int msgbuff[8];

	for(;;) {
		(void)evnt_mesag(msgbuff);
	}
}

static void (*oldttop)();

static void
tooltop(v)
	WINDOW *v;
{
	extern void top_menu();

	top_menu(v, oldttop);
}

void
toolclose(v)
	WINDOW *v;
{
	if (!_app)
		ac_close();
	else {
		showtools = 0;
		close_window(v);
	}
}

void
toolopen()
{
	if (showtools) {
		(*toolwindow->topped)(toolwindow);
	} else {
		showtools = 1;
		open_window(toolwindow);
	}
}

char *Strng(index)
	int index;
{
	char *addr;

	addr = 0;
	rsrc_gaddr(5, index, &addr);
	return addr;
}

int __mint;

/*
 * get MiNT version number
 */

static void
getMiNT()
{
	long *cookie;

/* get the system time in 200HZ ticks from the BIOS _hz_200 variable */

	cookie = *((long **) 0x5a0L);
	if (!cookie)
		__mint = 0;
	else {
		while (*cookie) {
			if (*cookie == 0x4d694e54L) {	/* MiNT */
				__mint = (int) cookie[1];
				return;
			}
			cookie += 2;
		}
	}
	__mint = 0;
}

int
main()
{
	extern short _global[];		/* AES global array */
	int i;

#ifdef WWA_RUN_TOSWIN
/* Before ANYTHING, open up the TOSRUN pipe, so that RUNTOS can use it */
	trun_fd = Fcreate("U:\\PIPE\\TOSRUN", global_flag);
#endif

	(void)Supexec(getMiNT);
	init_gem();
	if (_global[1] == -1) {		/* multitasking AES? */
		MultiTOS = 1;
	} else {
		if (_app)
			(void)Cursconf(0, 0);	/* hide cursor */
		else {
			oldACC = 1;
			global_flag = 0x1000;
			termfunc = (long)Setexc(0x102, -1L);
			heapbase = (void *)Malloc(heapsize);
			if (__mint == 0 ||
			   (heapbase = (void *)Malloc(heapsize)) == 0)
			{
				close_vwork();
				while(1) evnt_loop();
			}
		}
	}

	linea0();
	toolx = xdesk;
	tooly = ydesk;
	graf_mouse(BEE, 0L);
	i = rsrc_load("TOSWIN_W.RSC");
	if (i == 0) {
		form_alert(1, "[3][TOSWIN_W.RSC not found][Cancel]");
		if (oldACC)
			dieloop();
		else {
			exit_gem(1);
		}
	}
	graf_mouse(ARROW, 0L);

	if (
	    rsrc_gaddr(0, DESKTOP, &deskobj) == 0 ||
	    rsrc_gaddr(0, MENUDEF, &menudef_dialog) == 0 ||
	    rsrc_gaddr(0, WINSIZE, &winsize_dialog) == 0 ||
	    rsrc_gaddr(0, FNTDIAL, &fontdial) == 0 ||
	    rsrc_gaddr(0, CUTOPTS, &cutdialog) == 0) {
		form_alert(1, "[3][TOSWIN.RSC corrupted??][Cancel]");
		if (oldACC)
			dieloop();
		else
			exit_gem(1);
	}

	if (MultiTOS || oldACC) {
		menu_register(gl_apid, Strng(TOSPROGS));
	}
	init_fontdesc();
	gl_timer = MultiTOS ? LONGWAIT : NOMULTIWAIT;
	fn_timeout = oldACC ? acc_input : fd_input;
	fn_message = iconify_message;
	fn_mouse = desk_mouse;

	about_string = Strng(ABOUTTW);
	about_func = toolopen;

	sysbar = filemenu = create_menu(Strng(SFILE));
	(void)add_entry(filemenu, Strng(SOPNSTD), newstdwin, NULL, 0, NORMAL);
	(void)add_entry(filemenu, Strng(SOPNALT), newaltwin, NULL, 0, NORMAL);
	closeentry = add_entry(filemenu, Strng(SCLOSE), g_close, NULL,
			 0, DISABLED);
	(void)add_entry(filemenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(filemenu, Strng(SLOADCFG), load_config, NULL, 0, NORMAL);
	(void)add_entry(filemenu, Strng(SSAVECFG), save_config, NULL, 0, NORMAL);
	(void)add_entry(filemenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(filemenu, Strng(SSETMENU), config_menu, sysbar,
			 0, NORMAL);
	(void)add_entry(filemenu, "---", quit, NULL, 0, DISABLED);
	(void)add_entry(filemenu, Strng(SQUIT), quit, NULL, 0, oldACC ? DISABLED : NORMAL);

	editmenu = create_menu(Strng(SEDIT));
	copyentry = add_entry(editmenu, Strng(SCOPY), do_cut, NULL, 0, NORMAL);
	pasteentry = add_entry(editmenu, Strng(SPASTE), do_paste, NULL, 0, NORMAL);
	(void)add_entry(editmenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(editmenu, Strng(SPASTEOP), setcutoptions, NULL, 0, NORMAL);
	filemenu->next = editmenu;

	globalmenu = create_menu(Strng(SGLOBAL));
	(void)add_entry(globalmenu, Strng(SALIGNW), toggle, &align_windows,
			 0, NORMAL);
#ifdef GLOBAL_APPL_MENUS
	(void)add_entry(globalmenu, Strng(SAPPMENU), togglemenu, &appl_menus,
			 0, CHECKED);
#else
	(void)add_entry(globalmenu, Strng(SAPPMENU), toggle, &appl_menus,
			 0, CHECKED);
#endif
	(void)add_entry(globalmenu, Strng(SAUTOCL), toggle, &autoclose, 0, NORMAL);
	(void)add_entry(globalmenu, Strng(SFLOURIS), toggle, &win_flourishes,
			 0, CHECKED);
	(void)add_entry(globalmenu, Strng(SPTTYPE), toggle, &point_to_type,
			 0, NORMAL);
	(void)add_entry(globalmenu, Strng(SSMOOTH), toggle, &smoothscroll,
			 0, NORMAL);
#ifdef WWA_AUTO_RAISE
	(void)add_entry(globalmenu, Strng(AUTORAIS), toggle, &auto_raise,
			 0, NORMAL);
#endif
	(void)add_entry(globalmenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(globalmenu, Strng(SSETSTD), set_stdsiz, NULL,
			 0, NORMAL);
	(void)add_entry(globalmenu, Strng(SSETALT), set_altsiz, NULL,
			 0, NORMAL);
	(void)add_entry(globalmenu, Strng(SSETDFNT), set_dfont, NULL,
			 0, NORMAL);
	(void)add_entry(globalmenu, Strng(SSETDGAD), set_dkind, NULL,
			 0, NORMAL);
	(void)add_entry(globalmenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(globalmenu, Strng(SENVIRON), setenvoptions, NULL,
			 0, NORMAL);
	(void)add_entry(globalmenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(globalmenu, Strng(SREDRAW), doredraw, NULL,
			 0, NORMAL);
	editmenu->next = globalmenu;

	windowmenu = create_menu(Strng(SWINDOW));
	(void)add_entry(windowmenu, Strng(SBURY), bury, NULL, 0, DISABLED);
	(void)add_entry(windowmenu, Strng(SICONIFY), iconify_topwin,
			 NULL, 0, DISABLED);
	(void)add_entry(windowmenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(windowmenu, Strng(SLITERAL), send_char,
			NULL, 0, DISABLED);
	(void)add_entry(windowmenu, "---", about_func, NULL, 0, DISABLED);
	(void)add_entry(windowmenu, Strng(SSETWSIZ), set_winsiz, NULL,
			 0, DISABLED);
	(void)add_entry(windowmenu, Strng(SSETWFNT), set_wfont, NULL,
			 0, DISABLED);
	(void)add_entry(windowmenu, Strng(SSETWGAD), set_wkind, NULL,
			 0, DISABLED);
	(void)add_entry(windowmenu, Strng(SSETWTIT), set_wintitle, NULL,
			 0, DISABLED);
	globalmenu->next = windowmenu;

	gadgmenu = create_menu(Strng(SGADGETS));
	(void)add_entry(gadgmenu, Strng(STOGFULL), g_full, NULL, 0, DISABLED);
	(void)add_entry(gadgmenu, Strng(SMOVE), g_move, NULL, 0, DISABLED);
	(void)add_entry(gadgmenu, Strng(SSCRUP), g_scroll, (void *)(long)WA_UPLINE,
			0, DISABLED);
	(void)add_entry(gadgmenu, Strng(SSCRDOWN), g_scroll, (void *)(long)WA_DNLINE,
			0, DISABLED);
	(void)add_entry(gadgmenu, Strng(SSCRLEFT), g_scroll, (void *)(long)WA_LFLINE,
			0, DISABLED);
	(void)add_entry(gadgmenu, Strng(SSCRRIGH), g_scroll, (void *)(long)WA_RTLINE,
			0, DISABLED);
	windowmenu->next = gadgmenu;

	if (!oldACC) {
#ifdef OLD_WAY
		(void)Psignal(SIGCHLD, dead_kid);
#endif
		(void)Psignal(SIGINT, send_sig);
		(void)Psignal(SIGQUIT, send_sig);
		(void)Psignal(SIGHUP, send_sig);
		(void)Psignal(SIGTSTP, send_sig);
		(void)Psignal(SIGTTIN, ignore);
		(void)Psignal(SIGTTOU, ignore);
	}

#ifndef WWA_RUN_TOSWIN
/* open up the TOSRUN pipe, so that the desktop can tell us to run stuff */
	trun_fd = Fcreate("U:\\PIPE\\TOSRUN", global_flag);
#endif

	if (trun_fd <= 0)
		trun_fd = 0;
	else {
		if (!oldACC)
			fd_mask |= (1L << trun_fd);
		(void)Fcntl(trun_fd, (long)O_NDELAY, F_SETFL);
	}

/* set up window sizes */
/* the standard size always matches the line A size; the alt size is
 * settable by the user
 */

	stdrow = lineArow = V_CEL_MY+1; stdcol = lineAcol = V_CEL_MX+1;
	altrow = (stdrow == 50) ? 25 : 50; altcol = 80;

	vsf_perimeter(vdi_handle, 0);	/* no bars around perimeter */

	show_menu(sysbar);	/* show_menu checks _app */

/* try to load a standard config file */
	i = shel_find(stdconfig);
	if (i != 0) {
		load_config(stdconfig);
	}

	if (!_app)
		showtools = 1;

	i = CLOSER|MOVER|NAME;
	if (!_app) i |= INFO;

	toolwindow = create_objwin(deskobj, "TOSWIN", i,
			 toolx, tooly, deskobj[0].ob_width, deskobj[0].ob_height);
	if (!_app) {
		toolwindow->menu = filemenu;
		toolwindow->infostr = strdup(menustr(filemenu));
	}
	oldttop = toolwindow->topped;
	toolwindow->topped = tooltop;
	toolwindow->closed = toolclose;

	if (_app && showtools)
		open_window(toolwindow);

	if (oldACC)
		close_vwork();

#ifdef WWA_INITIAL_REDRAW
/*
 *  Warwick Allison - Initial Redraw extension:
 *
 *          Redraw at startup if not MultiTOS.
 */
	if (!MultiTOS) doredraw();
#endif

	evnt_loop();

	if (lineAset) {
		V_CEL_MX = lineAcol - 1;
		V_CEL_MY = lineArow - 1;
	}
	exit_gem(0);
	return 0;
}

/*
 * functions for when we are accessories
 */

int opened = 0;

void
ac_open()
{
	WINDOW *w;

	if (!opened) {
		open_vwork();
		vsf_perimeter(vdi_handle, 0);
		for (w = gl_winlist; w; w = w->next) {
			if (open_window(w))
				opened = 1;
		}
		if (opened) return;
		if (gl_winlist) {	/* bad error */
			form_alert(1, AlertStrng(NOOPEN));
			close_vwork();
			return;
		}
	}
	toolopen();
	if (!gl_winlist) {
		close_vwork();
		opened = 0;
	}
	if (lineAset) {
		set_linea(stdcol, stdrow);
	}
}

void
ac_close()
{
	WINDOW *w;

	if (!opened) return;

	for (w = gl_winlist; w; w = w->next)
		close_window(w);
	close_vwork();
	opened = 0;
	if (lineAset) {
		V_CEL_MX = lineAcol - 1;
		V_CEL_MY = lineArow - 1;
	}
}

/* called when we get an AC_CLOSE message; this tells us that our
 * windows have been forcibly deleted on us
 */

void
force_ac_close()
{
	WINDOW *w;

	if (opened) {
		for (w = gl_winlist; w; w = w->next) {
			w->wi_handle = -1;
		}
		close_vwork();
		opened = 0;
	}
}


/*
 * special sbrk() stuff; note that this requires the MiNT
 * library
 */

void *
_sbrk(sz)
	long sz;
{
	void *foo;

	sz = (sz + 7) & ~((unsigned long)7L);

	if (heapbase) {
		if (sz >= heapsize) return 0;
		foo = heapbase;
		heapbase = (void *)((char *)heapbase + sz);
		heapsize -= sz;
	} else {
		foo = (void *)Malloc(sz);
	}
	return foo;
}

void *
sbrk(sz)
	size_t sz;
{
	return _sbrk((long)sz);
}
