/* cwin.c -- curses interface */

/*			   NOTICE
 *
 * Copyright (c) 1990,1992,1993 Britt Yenne.  All rights reserved.
 * 
 * This software is provided AS-IS.  The author gives no warranty,
 * real or assumed, and takes no responsibility whatsoever for any 
 * use or misuse of this software, or any damage created by its use
 * or misuse.
 * 
 * This software may be freely copied and distributed provided that
 * no part of this NOTICE is deleted or edited in any manner.
 * 
 */

/* Mail comments or questions to ytalk@austin.eds.com */

#include "header.h"
#include <curses.h>
#include <sys/signal.h>
#include "cwin.h"

typedef struct _ywin {
    struct _ywin *next;		/* next ywin in linked list */
    yuser *user;		/* user pointer */
    WINDOW *win;		/* window pointer */
    int height, width;		/* height and width in characters */
    int row, col;		/* row and column position on screen */
    char *title;		/* window title string */
} ywin;

static ywin *head;		/* head of linked list */

/* ---- local functions ---- */

/* Take input from the user.
 */
static void
curses_input(fd)
  int fd;
{
    register int rc;
    static ychar buf[MAXBUF];

    if((rc = read(fd, buf, MAXBUF)) <= 0)
    {
	if(rc == 0)
	    bail(YTE_SUCCESS);
	bail(YTE_ERROR);
    }
    my_input(me, buf, rc);
}

static ywin *
new_ywin(user, title)
  yuser *user;
  char *title;
{
    register ywin *out;
    register int len;

    len = strlen(title);
    out = (ywin *)get_mem(sizeof(ywin) + len + 1);
    (void)memset(out, 0, sizeof(ywin));
    out->user = user;
    out->title = ((char *)out) + sizeof(ywin);
    strcpy(out->title, title);
    return out;
}

static void
make_win(w, height, width, row, col)
  ywin *w;
  int height, width, row, col;
{
    if((w->win = newwin(height, width, row, col)) == NULL)
    {
	register ywin *w;
	w = (ywin *)(me->term);
	if(w->win != NULL)
	    show_error("make_win: newwin() failed");
	bail(YTE_ERROR);
    }
    w->height = height;
    w->width = width;
    w->row = row;
    w->col = col;
    scrollok(w->win, FALSE);
    wmove(w->win, 0, 0);
}

static void
draw_title(w)
  ywin *w;
{
    register int pad, x;
    register char *t;

    pad = (w->width - strlen(w->title)) / 2;
    move(w->row - 1, w->col);
    x = 0;
    for(; x < pad - 2; x++)
	addch('-');
    if(pad >= 2)
    {
	addch('=');
	addch(' ');
	x += 2;
    }
    for(t = w->title; *t && x < w->width; x++, t++)
	addch(*t);
    if(pad >= 2)
    {
	addch(' ');
	addch('=');
	x += 2;
    }
    for(; x < w->width; x++)
	addch('-');
}

/* Return number of lines per window, given "wins" windows.
 */
static int
win_size(wins)
  int wins;
{
    return (LINES - 1) / wins;
}

/* Break down and redraw all user windows.
 */
static void
curses_redraw()
{
    register ywin *w;
    register int row, wins, wsize;

    /* kill old windows */

    wins = 0;
    for(w = head; w; w = w->next)
    {
	if(w->win)
	{
	    delwin(w->win);
	    w->win = NULL;
	}
	wins++;
    }
    if((wsize = win_size(wins)) < 3)
    {
	end_term();
	errno = 0;
	show_error("curses_redraw: window size too small");
	bail(YTE_ERROR);
    }

    /* make new windows */

    clear();
    refresh();
    row = 0;
    for(w = head; w; w = w->next)
    {
	if(w->next)
	{
	    make_win(w, wsize-1, COLS, row+1, 0);
	    resize_win(w->user, wsize-1, COLS);
	}
	else
	{
	    make_win(w, LINES-row-2, COLS, row+1, 0);
	    resize_win(w->user, LINES-row-2, COLS);
	}
	draw_title(w);
	row += wsize;
	refresh();
	wrefresh(w->win);
    }
}

/* Start curses and set all options.
 */
static void
curses_start()
{
    LINES = COLS = 0;	/* so resizes will work */
    initscr();
    noraw();
    crmode();
    noecho();
    clear();
}

/* Restart curses... window size has changed.
 */
static void
curses_restart()
{
    register ywin *w;

    /* kill old windows */

    for(w = head; w; w = w->next)
	if(w->win)
	{
	    delwin(w->win);
	    w->win = NULL;
	}

    /* restart curses */

    endwin();
    curses_start();
    curses_redraw();
    refresh();

    /* some systems require we do this again */

#ifdef SIGWINCH
    signal(SIGWINCH, curses_restart);
#endif
}

/* ---- global functions ---- */

void
init_curses()
{
    curses_start();
    refresh();
    head = NULL;
    add_fd(0, curses_input);	/* set up user's input function */

    /* set up SIGWINCH signal handler */

#ifdef SIGWINCH
    signal(SIGWINCH, curses_restart);
#endif
}

void
end_curses()
{
    move(LINES-1, 0);
    clrtoeol();
    refresh();
    endwin();
}

/* Open a new window.
 */
int
open_curses(user, title)
  yuser *user;
  char *title;
{
    register ywin *w;
    register int wins;

    /* count the open windows.  We want to ensure at least
     * three lines per window.
     */
    wins = 0;
    for(w = head; w; w = w->next)
	wins++;
    if(win_size(wins+1) < 3)
	return -1;
    
    /* add the new user */

    if(head == NULL)
	w = head = new_ywin(user, title);
    else
	for(w = head; w; w = w->next)
	    if(w->next == NULL)
	    {
		w->next = new_ywin(user, title);
		w = w->next;
		break;
	    }
    user->term = w;

    /* redraw */

    curses_redraw();
    return 0;
}

/* Close a window.
 */
void
close_curses(user)
  yuser *user;
{
    register ywin *w, *p;

    /* zap the old user */

    w = (ywin *)(user->term);
    if(w == head)
	head = w->next;
    else
    {
	for(p = head; p; p = p->next)
	    if(w == p->next)
	    {
		p->next = w->next;
		break;
	    }
	if(p == NULL)
	{
	    show_error("close_curses: user not found");
	    return;
	}
    }
    delwin(w->win);
    free(w);
    curses_redraw();
}

void
addch_curses(user, c)
  yuser *user;
  register ychar c;
{
    register ywin *w;
    register int x, y;

    w = (ywin *)(user->term);
    getyx(w->win, y, x);
    waddch(w->win, c);
    if(x >= COLS-1)
	wmove(w->win, y, x);
}

void
move_curses(user, y, x)
  yuser *user;
  register int y, x;
{
    register ywin *w;

    w = (ywin *)(user->term);
    wmove(w->win, y, x);
}

void
clreol_curses(user)
  register yuser *user;
{
    register ywin *w;

    w = (ywin *)(user->term);
    wclrtoeol(w->win);
}

void
clreos_curses(user)
  register yuser *user;
{
    register ywin *w;

    w = (ywin *)(user->term);
    wclrtobot(w->win);
}

void
scroll_curses(user)
  register yuser *user;
{
    register ywin *w;

    /* Curses has uses busted scrolling.  In order to call scroll()
     * effectively, scrollok() must be TRUE.  However, if scrollok()
     * is TRUE, then placing a character in the lower right corner
     * will cause an auto-scroll.  *sigh*
     */
    w = (ywin *)(user->term);
    scrollok(w->win, TRUE);
    scroll(w->win);
    scrollok(w->win, FALSE);

    /* Some curses won't leave the cursor in the same place, and some
     * curses programs won't erase the bottom line properly.
     */
    wmove(w->win, user->t_rows - 1, 0);
    wclrtoeol(w->win);
    wmove(w->win, user->y, user->x);
}

void
flush_curses(user)
  register yuser *user;
{
    register ywin *w;

    w = (ywin *)(user->term);
    wrefresh(w->win);
}

/* Clear and redisplay.
 */
void
redisplay_curses()
{
    register ywin *w;

    clear();
    refresh();
    for(w = head; w; w = w->next)
    {
	redraw_term(w->user, 0);
	draw_title(w);
	refresh();
	wrefresh(w->win);
    }
}

/* Set raw mode.
 */
void
set_raw_curses()
{
    raw();
}

/* Set cooked mode.
 */
void
set_cooked_curses()
{
    noraw();
    crmode();
    noecho();
}
