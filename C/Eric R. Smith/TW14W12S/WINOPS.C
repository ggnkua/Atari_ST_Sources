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
#include <string.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <time.h>
#include "toswin_w.h"
#include "twdefs.h"
#include "twproto.h"

#define FLASHTIME 30

/* external flag: set to indicate the flag for opening a
 * "global" file (if we need to) when we're starting up
 */
extern int global_flag;

/* file descriptors that have kids attached to them */
long fd_mask = 0L;

/* file descriptor of TOSRUN */
extern int trun_fd;

static void write_win __PROTO((TEXTWIN *, char *, int));

/*
 * get a file name using the file selector.
 * "title" is the file selector box title
 * "path" is where to look for the file;
 * "default_name" is a default name for the file;
 * the final name selected is returned in "name"
 */

int
getfilename(title, name, path, default_name)
	char *title;
	char *name;
	char *path, *default_name;
{
	extern char *rindex();
	char *s;
	int fresult, fbutton;
	extern int gl_ap_version;

	if (path[0] == 0) {
		path[0] = Dgetdrv() + 'A';
		path[1] = ':';
		(void)Dgetpath(&path[2], 0);
		strcat(path, "\\");
	}
	for (s = path; *s; s++) {
		if (*s == '*') goto nowildcard;
	}
	strcpy(s, "*.*");

nowildcard:
	if (gl_ap_version >= 0x140)
		fresult = fsel_exinput(path, default_name, &fbutton, title);
	else
		fresult = fsel_input(path, default_name, &fbutton);
	if (fresult <= 0 || fbutton != 1 || !default_name[0])
		return FAIL;
	s = rindex(path, '\\');
	if (!s)
		s = &path[2];
	else
		s++;
	*s = 0;
	strcpy(name, path);
	strcat(name, default_name);
	return OK;
}

/*
 * if the program named by "fname" is a .TTP one, prompt the
 * user for arguments and copy them into "argstr"; otherwise
 * copy in a null command line. Return FAIL if the user
 * cancelled the request.
 */

int
getargs(fname, argstr)
	char *fname, *argstr;
{
	char *lastdot = 0;
	int i, x, y, w, h;
	TEDINFO *ted;
	OBJECT *argdial;
	char *inp;

	*argstr = 0;
	while (*fname) {
		if (*fname == '.')
			lastdot = fname;
		else if (*fname == '\\')
			lastdot = 0;
		fname++;
	}
	if (lastdot && !strcmp(lastdot, ".TTP")) {
		rsrc_gaddr(0, ARGDIAL, &argdial);
		ted = (TEDINFO *)argdial[ARGSTR].ob_spec;
		inp = (char *)ted->te_ptext;
		*inp = 0;
		form_center(argdial, &x, &y, &w, &h);
		wind_update(1);
		form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
		if (win_flourishes)
			form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);

		objc_draw(argdial, 0, 2, x, y, w, h);

		i = form_do(argdial, ARGSTR);

		if (win_flourishes)
			form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);

		form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);
		objc_change(argdial, i, 0, x, y, w, h, NORMAL, 0);
		wind_update(0);
		if (i == ARGCAN) return FAIL;
		strcpy(argstr, inp);
	}
	return OK;
}

char progpath[128];
char dfltprog[128];

int
getprogname(name)
	char *name;
{
	return getfilename(Strng(EXECPRG), name, progpath, dfltprog);
}

/*
 * typeit: type the user's input into a window. Note that this routine is
 * called when doing a 'paste' operation, so we must watch out for possible
 * deadlock conditions
 */

#define READBUFSIZ 256
static char buf[READBUFSIZ];

int
typeit(w, code, shift)
	WINDOW *w;
	int code, shift;
{
	TEXTWIN *t = w->extra;
	long offset, height;
	long c = (code & 0x00ff) | (((long)code & 0x0000ff00) << 8L) |
		 ((long)shift << 24L);
	long r;
	if (t->miny) {
		offset = t->miny * t->cheight;
		if (offset > t->offy) {
	/* we were looking at scroll back */
	/* now move so the cursor is visible */
			height = t->cheight * t->maxy - w->wi_h;
			if (height <= 0)
				offset = 0;
			else {
				offset = 1000L * t->cy * t->cheight/height;
				if (offset > 1000L) offset = 1000L;
			}
			(*w->vslid)(w, offset);
		}
	}

	if (t->fd) {
		r = Foutstat(t->fd);
		if (r <= 0) {
			r = Fread(t->fd, (long)READBUFSIZ, buf);
			if (r > 0) {
				write_win(t, buf, (int)r);
			}
			(void)Fselect(500,0L,0L,0L);
			r = Foutstat(t->fd);
		}
		if (r > 0) {
			(void)Fputchar(t->fd, c, 0);
			return 1;
		}
	}
	return 0;
}

void (*oldtopped)(), (*oldclosed)();

extern MENU *sysbar;
extern int appl_menus, sys_menu;

void
top_menu(v, f)
	WINDOW *v;
	void (*f)();
{
	ENTRY *e;
	TEXTWIN *t = v->extra;
	TEXTWIN *oldt;
	int enable = (v->wtype == TEXT_WIN);

	if (gl_topwin && gl_topwin->wtype == TEXT_WIN &&
	    gl_topwin->extra != t)
		oldt = gl_topwin->extra;
	else
		oldt = 0;

	for (e = windowmenu->contents; e; e = e->next) {
		if (e->entry[0] != '-')
			if (enable)
				enable_entry(windowmenu, e);
			else
				disable_entry(windowmenu, e);
	}
	for (e = gadgmenu->contents; e; e = e->next) {
		if (e->entry[0] != '-')
			if (enable)
				enable_entry(gadgmenu, e);
			else
				disable_entry(gadgmenu, e);
	}

	enable_entry(filemenu, closeentry);

#ifdef GLOBL_APPL_MENUS
	if (v->menu && appl_menus) {
		show_menu(v->menu);
		sys_menu = 0;
	} else if (!sys_menu) {
		show_menu(sysbar);
		sys_menu = 1;
	}
#endif
	if (enable)
		curs_off(t);
	if (oldt) {
	/* change the cursor states, maybe */
		curs_off(oldt);
	}
	(*f)(v);
	focuswin = gl_topwin;
	if (enable) {
		curs_on(t);
		refresh_textwin(t);
	}
	if (oldt) {
		curs_on(oldt);
		refresh_textwin(oldt);
	}
}

static void
top_text(v)
	WINDOW *v;
{
	top_menu(v, oldtopped);
}

static void
desk_menu(v)
	WINDOW *v;
{
	ENTRY *e;

	(*oldclosed)(v);
	if (v->menu)
		unloadmenu(v->menu);
	if (!gl_topwin) {
		for (e = windowmenu->contents; e; e = e->next) {
			if (e->entry[0] != '-')
				disable_entry(windowmenu, e);
		}
		for (e = gadgmenu->contents; e; e = e->next) {
			if (e->entry[0] != '-')
				disable_entry(gadgmenu, e);
		}
		disable_entry(filemenu, closeentry);
#ifdef GLOBAL_APPL_MENUS
		if (!sys_menu) {
			show_menu(sysbar);
			sys_menu = 1;
		}
#endif
	}
}

/*
 * set up a new text window with a process running in it
 * "progname" is the program's name;
 * "progargs" are the arguments for it;
 * "progdir" is the directory to change to;
 * "x" and "y" give where the window is to be opened
 * "rows" and "cols" are the number of rows and columns for it,
 * respectively;
 * "scroll" are the number of lines of scrollback to be
 * alloted for the window
 *
 * NOTE: the window is *not* actually opened here; it's the
 * caller's responsibility to do that.
 */

TEXTWIN *
newproc(progname, progargs, progdir, x, y, cols, rows, scroll, kind,
 font, points)
	char *progname, *progargs, *progdir;
	int x, y, cols, rows, kind, scroll, font, points;
{
	extern void vt52_putch();
	extern long termfunc;	/* set in main.c */
	TEXTWIN *t;
	int i, ourfd, kidfd;
#ifdef OLD_WAY
	long oldblock;
#else
	long r;
#endif
	static char termname[64];
	static char argbuf[128];
	struct winsize tw;
	char *p, *arg, c;
	char *newenv = 0;
	int oldfont, oldheight;

	/* copy over the args */
	p = argbuf+1;
	arg = progargs;
	for (i = 0; i < 125; i++) {
		c = *arg++;
		if (!c || c == '\r' || c == '\n') break;
		*p++ = c;
	}
	*p = 0;
	argbuf[0] = i;

	oldfont = default_font;
	oldheight = default_height;
	default_font = font;
	default_height = points;
	t = create_textwin(progname, x, y, cols, rows, scroll, kind);
	default_font = oldfont;
	default_height = oldheight;

	if (!t) {
		form_alert(1, AlertStrng(NOWINS));
		return 0;
	}
	t->output = vt52_putch;
	t->prog = strdup(progname);
	t->cmdlin = strdup(progargs);
	t->progdir = strdup(progdir);
	t->win->menu = loadmenu(progname);
	if (t->win->menu) {
		t->win->infostr = strdup(menustr(t->win->menu));
	} else {
		change_window_gadgets(t->win, t->win->wi_kind & ~INFO);
	}

	newenv = envstr(progname, progargs, progdir, cols, rows);

	if (newenv && (env_options & E_ARGV)) {
		if (!*argbuf)
			argbuf[1] = 0;
		argbuf[0] = 127;	/* mark ARGV arg. passing */
	}

	strcpy(termname, "U:\\pipe\\pty.A");
	for (i = 0; i < 20; i++) {
		termname[12] = 'A' + i;
		ourfd = Fcreate(termname, FA_SYSTEM|FA_HIDDEN|global_flag);
		if (ourfd > 0) {
		/* set to non-delay mode, so Fread() won't block */
			(void)Fcntl(ourfd, (long)O_NDELAY, F_SETFL);
			break;
		}
	}
	if (ourfd < 0) {
		form_alert(1, AlertStrng(NOPTY));
abort_open:
		destroy_textwin(t);
		return 0;
	}
	t->fd = ourfd;
	tw.ws_xpixel = tw.ws_ypixel = 0;
	tw.ws_row = rows;
	tw.ws_col = cols;

	(void)Fcntl(ourfd, &tw, TIOCSWINSZ);
	t->win->keyinp = typeit;
	t->win->mouseinp = win_click;
	oldtopped = t->win->topped;
	t->win->topped = top_text;
	oldclosed = t->win->closed;
	t->win->closed = desk_menu;

#ifdef OLD_WAY
	oldblock = Psigblock(1L << SIGCHLD);
#endif

	i = Pvfork();
	if (i < 0) {
		(void)Fclose(ourfd);
#ifdef OLD_WAY
		(void)Psigsetmask(oldblock);
#endif
		form_alert(1, AlertStrng(NOPROC));
		goto abort_open;
	} else if (i == 0) {
		if (oldACC)
			(void)Setexc(0x102, termfunc);
#ifndef OLD_WAY
		i = Pvfork();
		if (i != 0)
			Pterm(i);
#endif
		(void)Psetpgrp(0, 0);
		kidfd = Fopen(termname, 2);
		if (kidfd < 0) _exit(998);
		(void)Fforce(-1, kidfd);
		(void)Fforce(0, kidfd);
		(void)Fforce(1, kidfd);
		(void)Fforce(2, kidfd);
		(void)Fclose(kidfd);
		(void)chdir(progdir);
		i = Pexec(200, progname, argbuf, newenv);
		_exit(i);
	}

#ifndef OLD_WAY
#define WNOHANG 1
/* reap the exit code of the just terminated process */
	do {
		r = Pwait3(WNOHANG, (void *)0);
	} while (((r & 0xffff0000L) >> 16L) != i);
	i = r & 0x0000ffff;
#endif
	t->pgrp = i;
	if (!global_flag)
		fd_mask |= (1L << ourfd);
/* turn on the cursor in the window */
	(*t->output)(t, '\033');
	(*t->output)(t, 'e');

/* and make it flash */
	(*t->output)(t, '\033');
	(*t->output)(t, 't');
	(*t->output)(t, ' '+FLASHTIME);

/* align the window, if necessary */
	if (align_windows)
		t->win->wi_x &= ~7;

#ifdef OLD_WAY
	(void)Psigsetmask(oldblock);
#endif

	if (newenv) free(newenv);

	return t;
}

/* After this many bytes have been written to a window, it's time to
 * update it. Note that we must also keep a timer and update all windows
 * when the timer expires, or else small writes will never be shown!
 */
#define THRESHOLD 400

static void
write_win(t, b, cnt)
	TEXTWIN *t;
	char *b;
	int cnt;
{
	unsigned char *buf = (unsigned char *)b, c;
	int limit = smoothscroll ? 1 : NROWS(t) - 1;

	while (cnt-- > 0) {
		c = *buf++;
		(*t->output)(t, c);
		t->nbytes++;
		if (t->nbytes >= THRESHOLD || t->scrolled >= limit) {
			refresh_textwin(t);
		}
	}
}

#define EIHNDL -37

static char exit_msg[] = "\r\n<EXITED>\r\n";

static void
rebuild_fdmask(which)
	long which;
{
	int i;
	WINDOW *w, *wnext;
	TEXTWIN *t;

	for (i = 0; i < 32; i++) {
		if ((which & (1L << i)) && (Finstat(i) < 0)) {
		/* window has died now */
			fd_mask &= ~(1L << i);
			for (w = gl_winlist; w; w = wnext) {
				wnext = w->next;
				if (w->wtype != TEXT_WIN) continue;
				t = w->extra;
				if (t && t->fd == i) {
					if (autoclose)
						(*w->closed)(w);
					else {
						write_win(t, exit_msg,
							(int)strlen(exit_msg));
						refresh_textwin(t);
						(void)Fclose(i);
						t->fd = 0;
					}
				}
			}
		}
	}
}

void
exec_tos(buf)
	char *buf;
{
	TEXTWIN *t;
	char *dir, *name, *args;

	dir = buf;
	while (*buf && *buf != ' ') buf++;
	if (*buf) *buf++ = 0;
	name = buf;
	while (*buf && *buf != ' ') buf++;
	if (*buf) *buf++ = 0;
	args = buf;
	t = newproc(name, args, dir, 0, 0, stdcol, stdrow, stdscroll, default_kind,
		 default_font, default_height);
	if (_app || opened)
		open_window(t->win);
}

#ifdef WWA_GEM_RUN
void
exec_tos_ext(buf,x,y,w,h,scroll,fontnumber,fontsize)
	char *buf;
	int x,y,w,h,scroll;
	int fontnumber;
	int fontsize;
{
	TEXTWIN *t;
	char *dir, *name, *args;

	dir = buf;
	while (*buf && *buf != ' ') buf++;
	if (*buf) *buf++ = 0;
	name = buf;
	while (*buf && *buf != ' ') buf++;
	if (*buf) *buf++ = 0;
	args = buf;


	t = newproc(name, args, dir, x, y, w, h, stdscroll, default_kind,
		 fontnumber, fontsize);
	if (_app || opened)
		open_window(t->win);
}

void
runprog(progname, progargs, progdir)
	char *progname, *progargs, *progdir;
{
	int i;
	int child;
	long wait;
	static char argbuf[128];
	char *p, *arg, c;
	char *newenv = 0;

	/* copy over the args */
	p = argbuf+1;
	arg = progargs;
	for (i = 0; i < 125; i++) {
		c = *arg++;
		if (!c || c == '\r' || c == '\n') break;
		*p++ = c;
	}
	*p = 0;
	argbuf[0] = i;

	newenv = envstr(progname, progargs, progdir, stdcol, stdrow);

	if (newenv && (env_options & E_ARGV)) {
		if (!*argbuf)
			argbuf[1] = 0;
		argbuf[0] = 127;	/* mark ARGV arg. passing */
	}

	child=Pexec(100, progname, argbuf, newenv);
	do {
		wait=Pwait3(0,0);
	} while (wait!=ENOENT && wait>>16 != child);

	if (newenv) free(newenv);
}

void
exec_gem(buf)
	char *buf;
{
	char *dir, *name, *args;
	char olddir[256];
	extern int opened;

	dir = buf;
	while (*buf && *buf != ' ') buf++;
	if (*buf) *buf++ = 0;
	name = buf;
	while (*buf && *buf != ' ') buf++;
	if (*buf) *buf++ = 0;
	args = buf;

	olddir[0]=Dgetdrv() + 'A';
	olddir[1]=':';
	Dgetpath(olddir+2,0);
	if (!olddir[2]) {
		olddir[2]='\\';
		olddir[3]=0;
	}

	/* Hack to shutdown&restart by using acc code! */
	opened=1;

	desk_menu_show(0);
	ac_close();

	(void)chdir(dir);

	runprog(name, args, dir);

	(void)chdir(olddir);

	ac_open();
	desk_menu_show(1);
}

int scanint(buf)
	char** buf;
{
	int n=0;
	while (**buf >= '0' && **buf <= '9') {
		n=n*10+**buf-'0';
		(*buf)++;
	}
	(*buf)++; /* skip space */

	return n;
}
#endif

static long lasthz;

void
fd_input()
{
#define MAX_DELAY 3		/* max no. of 50Hz ticks before a refresh */
	long readfds, r, checkdead;
	int read;
	int workdone = 0;
	WINDOW *w;
	TEXTWIN *t;
	int updtime;
	long newhz;

	r  = 0;
	checkdead = 0;

	newhz = clock();
	updtime = (newhz - lasthz) >> 2;
	lasthz = newhz;

	if (fd_mask) {
		readfds = fd_mask;
		if ((r = Fselect(1, &readfds, 0L, 0L)) > 0) {
			if (trun_fd && (readfds & (1L << trun_fd))) {
				read = Finstat(trun_fd);
				if (read > 0)
					read = Fread(trun_fd, (long)READBUFSIZ,
							 buf);
				if (read > 0) {
#ifdef WWA_EXT_TOSRUN
					char* prg_and_args=buf;
					int gem_not_tos=0;
					int x=0,y=0,w=0,h=0; /* Only valid if w!=0 */
					char* fontname=0;
					int fontnumber;
					int fontsize=0;
					int scroll=-1;

					int special=1;
					while (special) {
						switch (prg_and_args[0]) {
						 default:
							special=0;
						break; case '\01':
							prg_and_args++;
							gem_not_tos=1;
						break; case '\02':
							prg_and_args++;
							x=scanint(&prg_and_args);
							y=scanint(&prg_and_args);
							w=scanint(&prg_and_args);
							h=scanint(&prg_and_args);
						break; case '\03':
							prg_and_args++;
							fontname=prg_and_args;
							while (*prg_and_args != '@')
								prg_and_args++;
							*prg_and_args='\0';
							prg_and_args++;
							fontsize=scanint(&prg_and_args);
						}
					}

					if (!w) {
						x=0;
						y=0;
						w=stdcol;
						h=stdrow;
					}

					if (!fontname) {
						fontnumber=default_font;
						fontsize=default_height;
					} else {
						fontnumber=find_font_named(fontname);
						if (fontnumber<0) { /* not found */
							fontname=0;
						}
					}

					if (!fontname) {
						fontnumber=default_font;
						fontsize=default_height;
					}

					if (scroll>=0) {
						scroll=stdscroll;
					}

					if (gem_not_tos) {
						exec_gem(prg_and_args);
					} else {
						exec_tos_ext(prg_and_args,x,y,w,h,scroll,fontnumber,fontsize);
					}
#else
					exec_tos(prg_and_args);
#endif
				}
			}
			for (w = gl_winlist; w; w = w->next) {
				if (w->wtype != TEXT_WIN) continue;
				t = w->extra;
				if (!t || !t->fd) continue;
				if (readfds & (1L << t->fd)) {
					read = Fread(t->fd, (long)READBUFSIZ,
							 buf);
					if (read > 0) {
						write_win(t, buf, read);
					} else {
						checkdead |= (1L << t->fd);
					}
				}
			}
			workdone = 1;
		}
		if (checkdead)
			rebuild_fdmask(checkdead);
	}
	if (r == EIHNDL) {	/* invalid handle?? */
		rebuild_fdmask(fd_mask);
	}

	if (workdone) {
		gl_timer = MultiTOS ? SHORTWAIT : NOMULTIWAIT;
	} else {
		gl_timer = MultiTOS ? LONGWAIT : NOMULTIWAIT;
	}

/* for all windows on screen, see if it's time to refresh them */
	for (w = gl_winlist; w; w = w->next) {
		if (w->wtype != TEXT_WIN) continue;
		t = w->extra;
	/* should we flash the cursor in this window? */
		if (t->flashperiod) {
			t->flashtimer -= updtime;
			if (t->flashtimer <= 0) {
				t->flashtimer = t->flashperiod;
				curs_flash(t);
				t->nbytes++;
			}
		}
		if (!t || !t->fd || !t->nbytes) continue;
		t->draw_time += updtime;
		if (t->draw_time < MAX_DELAY) continue;
		refresh_textwin(t);
	}
}

/*
 * similar to fd_input, but used only when we're an ACC;
 * this loop doesn't use Fselect, so it's less efficient
 */

void
acc_input()
{
	long r, checkdead;
	int read;
	int workdone = 0;
	WINDOW *w;
	TEXTWIN *t;
	int updtime;
	long newhz;

	r  = 0;
	checkdead = 0;

	newhz = clock();
	updtime = (newhz - lasthz) >> 2;
	lasthz = newhz;

	read = Finstat(trun_fd);
	if (read > 0) {
		read = Fread(trun_fd, (long)READBUFSIZ, buf);
		if (read > 0)
			exec_tos(buf);
	}
	for (w = gl_winlist; w; w = w->next) {
		if (w->wtype != TEXT_WIN) continue;
		t = w->extra;
		if (!t || !t->fd) continue;
		if ((r = Finstat(t->fd)) != 0) {
			read = Fread(t->fd, (long)READBUFSIZ, buf);
			if (read > 0) {
				write_win(t, buf, read);
			} else if (r < 0) {
				if (autoclose) {
					(*w->closed)(w);
				} else {
					write_win(t, exit_msg,
					     (int)strlen(exit_msg));
					refresh_textwin(t);
					(void)Fclose(t->fd);
					t->fd = 0;
				}
			}
			workdone = 1;
		}
	}

	if (workdone) {
		gl_timer = MultiTOS ? SHORTWAIT : NOMULTIWAIT;
	} else {
		gl_timer = MultiTOS ? LONGWAIT : NOMULTIWAIT;
	}

/* for all windows on screen, see if it's time to refresh them */
	for (w = gl_winlist; w; w = w->next) {
		if (w->wtype != TEXT_WIN) continue;
		if (w->wi_handle < 0) continue;
		t = w->extra;
	/* should we flash the cursor in this window? */
		if (t->flashperiod) {
			t->flashtimer -= updtime;
			if (t->flashtimer <= 0) {
				t->flashtimer = t->flashperiod;
				curs_flash(t);
				t->nbytes++;
			}
		}
		if (!t || !t->fd || !t->nbytes) continue;
		t->draw_time += updtime;
		if (t->draw_time < MAX_DELAY) continue;
		refresh_textwin(t);
	}
}

/*
 * send an untranslated character to the top window
 */

void
send_char()
{
	WINDOW *v;
	OBJECT *quote_dial;
	int event, mshift, keycode, dummy;
	int x, y, w, h;

	v = gl_topwin;
	if (v && v->wtype == TEXT_WIN) {
		event = evnt_multi(MU_KEYBD|MU_TIMER,
			0, 0, 0,
			0, 0, 0, 0, 0,
			0, 0, 0, 0, 0,
			NULL,
			1200L,		/* wait 1.2 seconds */
			&dummy, &dummy, &dummy, &mshift,
			&keycode, &dummy);
		if (event & MU_KEYBD) {
			(*v->keyinp)(v, keycode, mshift);
		} else {
			rsrc_gaddr(0, QUOTEIT, &quote_dial);
			form_center(quote_dial, &x, &y, &w, &h);
			wind_update(BEG_MCTRL);
			form_dial(FMD_START, 0, 0, 32, 32, x, y, w, h);
			if (win_flourishes)
				form_dial(FMD_GROW, 0, 0, 32, 32, x, y, w, h);

			objc_draw(quote_dial, 0, 2, x, y, w, h);
			event = evnt_multi(MU_KEYBD|MU_BUTTON,
				0x0101, 0x0003, 0,
				0, 0, 0, 0, 0,
				0, 0, 0, 0, 0,
				NULL,
				0L,
				&dummy, &dummy, &dummy, &mshift,
				&keycode, &dummy);

			if (win_flourishes)
				form_dial(FMD_SHRINK, 0, 0, 32, 32, x, y, w, h);
			form_dial(FMD_FINISH, 0, 0, 32, 32, x, y, w, h);
			wind_update(END_MCTRL);
			if (event & MU_KEYBD) {
				(*v->keyinp)(v, keycode, mshift);
			}
		}
	}

}
