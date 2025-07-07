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
#include <ctype.h>
#include <string.h>
#include <osbind.h>
#include <stdlib.h>
#include "xgem.h"
#include "toswin_w.h"
#include "filbuf.h"
#include "twdefs.h"
#include "twproto.h"

#define LASTMENU ((MENU *)0)

#define QUOTE '\"'
#define LINSIZ 256
#define WORDSIZ 128


char *
nextword(ptr)
	char **ptr;
{
	char *s, *start;

	s = *ptr;
	while (*s && isspace(*s))
		s++;
	start = s;
	if (*s == QUOTE) {
		start++; s++;
		while (*s && *s != QUOTE) s++;
	} else {
		while (*s && !isspace(*s))
			s++;
	}
	if (*s)
		*s++ = 0;
	*ptr = s;
	return start;
}

int
hexval(s)
	char *s;
{
	int val = 0;
	int c, i;

	for (i = 12; i >= 0; i -= 4) {
		c = *s++;
		c = toupper(c);
		if (c >= '0' && c <= '9') {
			val |= ((c - '0') << i);
		} else if (c >= 'A' && c <= 'F') {
			val |= ((c - 'A') + 10) << i;
		} else {
			break;
		}
	}
	return val;
}

char *
valhex(i)
	int i;
{
	static char sbuf[5];
	char *s;
	int c;

	for (s = &sbuf[3]; s >= sbuf; --s) {
		c = i & 0x000f;
		i = i >> 4;
		if (c >= 0 && c <= 9) {
			*s = c + '0';
		} else {
			*s = (c - 10) + 'A';
		}
	}
	return sbuf;
}

int
decval(s)
	char *s;
{
	int i = 0;
	int c;

	while ((c = *s++)) {
		if (c < '0' || c > '9') break;
		i = 10 * i + (c - '0');
	}
	return i;
}

char *
valdec(i)
	int i;
{
	static char foo[4];
	char *s;
	int d;

	s = foo;
	if (i >= 0 && i < 1000) {
		d = i / 100;
		i = i % 100;
		*s++ = '0'+d;
		d = i / 10;
		i = i % 10;
		*s++ = '0'+d;
		*s++ = '0'+i;
	}
	*s++ = 0;
	return foo;
}

/*
 * like valdec, put strips leading '0' characters
 */

char *
valdec2(d)
	int d;
{
	char *s;

	s = valdec(d);
	while (*s == '0' && *(s+1) != 0)
		s++;
	return s;
}

struct varstruct {
	char *name;
	int  *addr;
} vars[] = {
	"altcol", &altcol,
	"altrow", &altrow,
	"altscroll", &altscroll,
	"align", &align_windows,
	"appmenus", &appl_menus,
	"autoclose", &autoclose,
	"cut", &cut_options,
	"defaultgadgets", &default_kind,
	"environ", &env_options,
	"flourishes", &win_flourishes,
#ifdef WWA_AUTO_RAISE
	"autoraise", &auto_raise,
#endif
	"paste", &paste_options,
	"point", &point_to_type,
	"showtool", &showtools,
	"smoothscroll", &smoothscroll,
	"stdcol", &stdcol,
	"stdrow", &stdrow,
	"stdscroll", &stdscroll,
	0, 0
};

/* adjust "font" and "height" to match (as closely as possible) a font
 * setting in the global variable "fontdesc"; if a match can't be
 * found, try the default font
 */

static void
adjust_font(font, height)
	int *font, *height;
{
	FONTDESC *f, *dflt;
	int i;

	dflt = 0;
	f = fontdesc;
	for (i = 0; i < gl_numfonts; i++) {
		if (f->fontidx == *font && (f->points & (1L << *height)) )
			return;		/* everything's OK */
		else if (f->fontidx == default_font)
			dflt = f;
		f++;
	}
	*font = default_font;
	if (dflt && (dflt->points & (1L << *height)))
		return;		/* this height is OK */
	*height = default_height;
}

void
set_default_font(s)
	char *s;
{
	int font, size;

	font = hexval(nextword(&s));
	size = hexval(nextword(&s));

	adjust_font(&font, &size);

	default_font = font;
	default_height = size;
}

static void
adjust_xywh(xp, yp, wp, hp)
	int *xp, *yp, *wp, *hp;
{
	int x = *xp;
	int y = *yp;
	int w = *wp;
	int h = *hp;

	if (x + w > xdesk + wdesk) {
		x = xdesk + wdesk - w;
		if (x < xdesk) {
			x = xdesk;
			w = wdesk;
		}
	}
	if (y + h > ydesk + hdesk) {
		y = ydesk + hdesk - h;
		if (y < ydesk) {
			y = ydesk;
			h = hdesk;
		}
	}
	*xp = x; *yp = y;
	*wp = w; *hp = h;
}

void
load_window(s)
	char *s;
{
	int kind, flags, x, y, w, h, cols, rows, font, points;
	int scroll;
	char *title, *progname, *cmdlin, *progdir;
	TEXTWIN *t;
	WINDOW *v;

	flags = hexval(nextword(&s));
	kind = hexval(nextword(&s));
	x = hexval(nextword(&s));
	y = hexval(nextword(&s));
	w = hexval(nextword(&s));
	h = hexval(nextword(&s));
	cols = hexval(nextword(&s));
	rows = hexval(nextword(&s));
	font = hexval(nextword(&s));
	points = hexval(nextword(&s));
	title = nextword(&s);
	progname = nextword(&s);
	cmdlin = nextword(&s);
	progdir = nextword(&s);
	scroll = hexval(nextword(&s));

	adjust_font(&font, &points);
	wind_calc(WC_BORDER, kind, x, y, w, h, &x, &y, &w, &h);
	adjust_xywh(&x, &y, &w, &h);

	t = newproc(progname, cmdlin, progdir, x, y, cols, rows, scroll,
		    kind, font, points);
	if (!t) return;
	v = t->win;
	wind_calc(WC_WORK, kind, x, y, w, h, &v->wi_x, &v->wi_y,
		&v->wi_w, &v->wi_h);
	title_window(v, title);
	if (!oldACC)
		open_window(v);
	if (flags & WICONIFIED) {
		iconify_win(v);
	}
}

extern int getfilename();
static char config_name[128] = "TOSWIN.CNF";
static char config_path[128];

void
load_config(name)
	char *name;
{
	FILBUF *f;
	static char buf[LINSIZ];
	char *s, *word;
	struct varstruct *v;
	ENTRY *e;
	int *var;
	int i;
	int loadwins = 1;
	int changepath = 1;

	if (!name) {			/* ask the user for a name */
		name = buf;
		i = getfilename(Strng(LOADCFG), name, config_path,
				 config_name);
		if (i != OK) return;
		loadwins = 0;
		changepath = 0;
	}

	f = FBopen(name);
	if (!f) return;

	graf_mouse(BEE, 0L);
	while ((s = FBgets(f, buf, LINSIZ))) {
		word = nextword(&s);
		/* variable setting? */
		for (v = vars; v->name; v++) {
			if (!strcmp(v->name, word)) {
				word = nextword(&s);
				*v->addr = hexval(word);
				if (!strncmp(v->name, "std", 3))
					lineAset = 1;
				goto endloop;
			}
		}
		if (!strcmp(word, "font")) {
			set_default_font(s);
		} else if (!strcmp(word, "path")) {
			if (changepath)
				strcpy(progpath, nextword(&s));
		} else if (!strcmp(word, "prog")) {
			if (changepath)
				strcpy(dfltprog, nextword(&s));
		} else if (!strcmp(word, "menu")) {
			load_menu_key(s);
		} else if (!strcmp(word, "win") && loadwins) {
			load_window(s);
		} else if (!strcmp(word, "tool") && loadwins) {
			toolx = hexval(nextword(&s));
			tooly = hexval(nextword(&s));
			if (toolwindow && toolwindow->wi_handle >= 0) {
				close_window(toolwindow);
				toolwindow->wi_x = toolx;
				toolwindow->wi_y = tooly;
				open_window(toolwindow);
			}
		}
endloop: ;
	}

/* reset the global menu */
	for (e = globalmenu->contents; e; e = e->next) {
		if (e->func == toggle
#ifdef GLOBL_APPL_MENUS
		 || e->func == togglemenu
#endif
		) {
			var = e->arg;
			if (*var)
				check_entry(globalmenu, e);
			else
				uncheck_entry(globalmenu, e);
		}
	}

	if (lineAset)
		set_linea(stdcol, stdrow);
	FBclose(f);
	graf_mouse(ARROW, 0L);
}

static int
strwrite(fd, s)
	int fd;
	char *s;
{
	long r = strlen(s);

	return Fwrite(fd, r, s);
}

static void
strwritex(fd, s)
	int fd;
	char *s;
{
	strwrite(fd, s);
	strwrite(fd, " ");
}

static int
quotewrite(fd, s)
	int fd;
	char *s;
{
	int nbytes;
	char buf[WORDSIZ];
	char c;

	buf[0] = QUOTE;
	for (nbytes = 1; nbytes < WORDSIZ-2; nbytes++) {
		c = *s++;
		if (!c) break;
		else if (c == QUOTE)
			c = '\'';
		buf[nbytes] = c;
	}
	buf[nbytes] = QUOTE;
	return Fwrite(fd, (long)nbytes+1, buf);
}

void
save_config(file)
	char *file;
{
	int fd, i;
	struct varstruct *v;
	static char name[128];
	MENU *m;
	ENTRY *e;
	int savewins = 0;
	WINDOW *w;
	TEXTWIN *t;

	if (!file) {
		file = name;
		i = getfilename(Strng(SAVECFG), name, config_path,
			config_name);
		if (i != OK) return;
		if (gl_winlist) {
			i = form_alert(1, AlertStrng(SAVWPOS));
			if (i == 1) savewins = 1;
		}
	}

	fd = Fcreate(file, 0);
	if (fd <= 0) {
		form_alert(1, AlertStrng(UNABLE1));
		return;
	}
	for (v = vars; v->name; v++) {
		if (!strncmp(v->name, "stdrow", 6)
			|| !strncmp(v->name, "stdcol", 6)) continue;
		strwrite(fd, v->name);
		strwrite(fd, " ");
		strwrite(fd, valhex(*v->addr));
		strwrite(fd, "\r\n");
	}
	if (lineAset) {
		strwrite(fd, "stdcol "); strwrite(fd, valhex(stdcol));
		strwrite(fd, "\r\nstdrow ");
		strwrite(fd, valhex(stdrow));
		strwrite(fd, "\r\n");
	}
	strwrite(fd, "font ");
	strwritex(fd, valhex(default_font));
	strwrite(fd, valhex(default_height)); strwrite(fd, "\r\n");

	if (*progpath) {
		strwrite(fd, "path ");
		strwrite(fd, progpath);
		strwrite(fd, "\r\n");
		if (*dfltprog) {
			strwrite(fd, "prog ");
			strwrite(fd, dfltprog);
			strwrite(fd, "\r\n");
		}
	}

	strwrite(fd, "menu ");
	for (m = sysbar; m != LASTMENU; m = m->next) {
		for (e = m->contents; e; e = e->next) {
			if (e->entry[0] != '-') {
				strwritex(fd, valhex(e->keycode));
			}
		}
	}
	strwrite(fd, "\r\n");

	if (savewins) {
		strwrite(fd, "tool ");
		strwritex(fd, valhex(toolx));
		strwrite(fd, valhex(tooly));
		strwrite(fd, "\r\n");

		for (w = gl_winlist; w; w = w->next) {
			if (w->wtype != TEXT_WIN) continue;
			t = w->extra;
			strwrite(fd, "win ");
			strwritex(fd, valhex(w->flags));
			if (w->flags & WICONIFIED) {
				strwritex(fd, valhex(w->old_wkind));
				strwritex(fd, valhex(w->prevx));
				strwritex(fd, valhex(w->prevy));
				strwritex(fd, valhex(w->prevw));
				strwritex(fd, valhex(w->prevh));
			} else {
				strwritex(fd, valhex(w->wi_kind));
				strwritex(fd, valhex(w->wi_x));
				strwritex(fd, valhex(w->wi_y));
				strwritex(fd, valhex(w->wi_w));
				strwritex(fd, valhex(w->wi_h));
			}
			strwritex(fd, valhex(NCOLS(t)));
			strwritex(fd, valhex(NROWS(t)));
			strwritex(fd, valhex(t->cfont));
			strwritex(fd, valhex(t->cpoints));
			quotewrite(fd, w->wi_title); strwrite(fd, " ");
			strwritex(fd, t->prog);
			quotewrite(fd, t->cmdlin); strwrite(fd, " ");
			strwritex(fd, t->progdir);
			strwrite(fd, valhex(SCROLLBACK(t)));
			strwrite(fd, "\r\n");
		}
	}

	(void)Fclose(fd);
}


/*
 * menu configuration routines
 */

void
load_menu_key(s)
	char *s;
{
	MENU *m;
	ENTRY *e;

	m = sysbar;
	e = m->contents;
	for(;;) {
		if (e->entry[0] != '-') {
			e->keycode = hexval(nextword(&s));
		}
		e = e->next;
		if (!e) {
			m = m->next;
			if (m == LASTMENU) break;
			e = m->contents;
		}
	}
	show_menu(sysbar);
}

void
config_menu()
{
	int r;
	int x, y, w, h;
	int dummy, mx, my, keycode;
	int done, event, mbreturn;
	int atstart = 1;
	MENU *m, *lastm;
	ENTRY *e, *laste;
	int change;

	wind_update(BEG_MCTRL);
	form_center(menudef_dialog, &x, &y, &w, &h);
	form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
	if (win_flourishes)
		form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);

	objc_draw(menudef_dialog, 0, 1, x, y, w, h);

	lastm = 0; laste = 0;
	m = sysbar;
	e = m->contents;
	done = 0;
	change = 1;

	do {
		if (change) {
			if (atstart) {
				if (menudef_dialog[MDPREV].ob_state != DISABLED)
					objc_change(menudef_dialog, MDPREV, 0,
						x, y, w, h, DISABLED, 1);
			} else {
				if (menudef_dialog[MDPREV].ob_state != NORMAL)
					objc_change(menudef_dialog, MDPREV, 0,
						x, y, w, h, NORMAL, 1);
			}
			if (e->next == 0 && m->next == LASTMENU) {
				if (menudef_dialog[MDNEXT].ob_state != DISABLED)
					objc_change(menudef_dialog, MDNEXT, 0,
						x, y, w, h, DISABLED, 1);
			} else {
				if (menudef_dialog[MDNEXT].ob_state != NORMAL)
					objc_change(menudef_dialog, MDNEXT, 0,
						x, y, w, h, NORMAL, 1);
			}
			menudef_dialog[MENUSTR].ob_spec = (long)m->title;
			menudef_dialog[ENTRYSTR].ob_spec = (long)e->entry;
			menudef_dialog[ASCIISTR].ob_spec = (long)UNALT(e->keycode);
			menudef_dialog[HEXSTR].ob_spec = (long)valhex(e->keycode);

			objc_draw(menudef_dialog, MENUFRAM, 2, x, y, w, h);
			objc_draw(menudef_dialog, KEYFRAM, 2, x, y, w, h);
		}
		change = 0;

		event = evnt_multi(MU_BUTTON|MU_KEYBD,
			0x0002, 0x0001, 0x0001,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			0L, 0L,
			&mx, &my, &dummy, &dummy,
			&keycode, &mbreturn);

		if (event & MU_KEYBD) {
			change = 1;
			if ((keycode & 0x00ff) == ' ')
				e->keycode = 0;
			else if (keycode == 0x1c0d) {
		/* RETURN key pressed -- exit dialog */
				done = 1;
			} else {
				e->keycode = keycode;
			}
#if 0
			if (!(event & MU_BUTTON))
				goto advance;
#endif
		}
		if (event & MU_BUTTON) {
			r = objc_find(menudef_dialog, 0, 2, mx, my);
			if (r == MDNEXT || r == MDPREV) {
				if (menudef_dialog[r].ob_state == DISABLED) {
					continue;
				}
				evnt_timer(50L);
			}
			switch (r) {
			case MDNEXT:
		advance:
				atstart = 0;
				if (e->next) {
					e = e->next;
				} else if (m->next != LASTMENU) {
					m = m->next;
					e = m->contents;
				} else if (event & MU_KEYBD) {
					done = 1;
				} else {
					(void)Bconout(2, 7);
				}
				if (e->entry[0] == '-')
					goto advance;
				change = 1;
				break;
			case MDPREV:
		retreat:
				if (atstart) {
					(void)Bconout(2, 7);
				} else {
					if (m->contents == e) {
						laste = 0;
						if (sysbar == m)
							lastm = 0;
						else {
							lastm = sysbar;
							while (m != lastm->next)
							    lastm = lastm->next;
						}
					} else {
						lastm = m;
						laste = m->contents;
						while (laste->next != e)
							laste = laste->next;
					}

					m = (lastm) ? lastm : sysbar;
					if (laste)
						e = laste;
					else
						for (e = m->contents; e->next; )
							e = e->next;
				}
				if (m == sysbar && e == m->contents)
					atstart = 1;
				if (e->entry[0] == '-') goto retreat;
				change = 1;
				break;
			case MDDONE:
				done = 1; break;
			default:
				(void)Bconout(2, 7);
			}
		}
	} while (!done);

	if (win_flourishes)
		form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);
	form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);
	wind_update(END_MCTRL);
	show_menu(sysbar);
}

/*
 * loadable menu support:
 * loadmenu(fname): load the .MNU file corresponding to the program 'fname'
 */

void
sendhex(s)
	char *s;
{
	WINDOW *w;
	static char pbuf[5];
	char *t;
	int i, c;

	if (!gl_topwin) return;
	w = gl_topwin;

	i = 0; t = pbuf;

	for(;;) {
		if (!*s) break;
		*t++ = *s++;
		i++;
		if (i == 4) {
			c = hexval(pbuf);
			if (!c) break;
			i = 0;
			t = pbuf;
			(*w->keyinp)(w, c, 0);
		}
	}
}

MENU *
loadmenu(fname)
	char *fname;
{
	static char pname[LINSIZ];
	char *s, *lastdot, c;
	FILBUF *f;
	MENU *bar, *m, **last;
	int keycode;
	char *name, *data;

#ifndef GLOBAL_APPL_MENUS
/* appl_menus now controls whether to load menus at all */
	if (!appl_menus)
		return 0;
#endif
	s = pname;
	while (*s++ = *fname++) ;
	--s;

	lastdot = s;
	while (s >= pname && (c = *s) != '\\') {
		if (c == '.') lastdot = s;
		--s;
	}

	*lastdot++ = '.';
	*lastdot++ = 'M'; *lastdot++ = 'N'; *lastdot++ = 'U';
	*lastdot = 0;

	f = FBopen(pname);
	if (!f) return 0;

	last = &bar;
	bar = m = 0;
	for(;;) {
		if (!FBgets(f, pname, LINSIZ)) break;
		s = pname;
		if (!isspace(*s)) {
			m = create_menu(pname);
			if (!m) break;
			*last = m;
			last = &m->next;
		} else {
			while (*s && isspace(*s)) s++;
			if (!*s) continue;
			name = strdup(nextword(&s));
			data = strdup(nextword(&s));
			keycode = hexval(nextword(&s));
			if (name[0] == '-')
			    add_entry(m, name, sendhex, data, keycode, DISABLED);
			else
			    add_entry(m, name, sendhex, data, keycode, NORMAL);
		}
	}
	FBclose(f);
	return bar;
}

void
unloadmenu(men)
	MENU *men;
{
	ENTRY *e;
	MENU *m;


	for (m = men; m; m = m->next) {
		for (e = m->contents; e; e = e->next) {
			if (e->arg)
				free(e->arg);
		}
	}
	destroy_menu(men);
}
