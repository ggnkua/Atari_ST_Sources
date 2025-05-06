/* xwin.c -- X Window Terminal Interface */

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

#ifdef USE_X11

#include "header.h"
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xresource.h>

static Display	       *display;	/* display */
static Window		rootwin;	/* root window */
static int		screen_num;	/* screen number */
static XrmDatabase	db;		/* resource database */
static XFontStruct     *text_font;	/* font */
static GC		textGC,		/* text graphic context */
			invertGC;	/* graphic context for inverts */
static ylong		whitepix,	/* white pixel */
			blackpix;	/* black pixel */
static int		font_width,	/* font width */
			font_height,	/* font height */
			font_ascent;	/* font ascent */

#define YPOS(p) ((p) * font_height)
#define XPOS(p) ((p) * font_width)

/* ----- local functions ----- */

static XTextProperty *
strToTP(s)
  char *s;
{
    XTextProperty *tp = (XTextProperty *)get_mem(sizeof(XTextProperty));
    XStringListToTextProperty(&s, 1, tp);
    return tp;
}

static char *
getOption(o)
  char *o;
{
    XrmValue value;
    char *type;

    if(XrmGetResource(db, o, o, &type, &value))
    {
	if(value.addr == NULL)
	    return NULL;
	if(strcmp(value.addr, "false") == 0)
	    return NULL;
	if(strcmp(value.addr, "False") == 0)
	    return NULL;
	return value.addr;
    }
    else
	return (char *)NULL;
}

static void
load_font(name, font)
  char *name;
  XFontStruct **font;
{
    if((*font = XLoadQueryFont(display, name)) == NULL)
    {
	sprintf(errstr, "Cannot load font %s", name);
	show_error(errstr);
	bail(YTE_ERROR);
    }
}

static void
make_GC(gc, font, fgpixel, bgpixel, l_width, l_style, l_cap, l_join, gcfunc)
  GC *gc;
  XFontStruct *font;
  ylong fgpixel, bgpixel;
  int l_width, l_style, l_cap, l_join, gcfunc;
{
    ylong mask = 0;
    XGCValues values;

    if(font != NULL)
    {
	values.font = font->fid;
	mask |= GCFont;
    }
    values.foreground = fgpixel;
    values.background = bgpixel;
    values.line_width = l_width;
    values.line_style = l_style;
    values.cap_style = l_cap;
    values.join_style = l_join;
    mask |= GCForeground | GCBackground | GCLineWidth | GCLineStyle | 
	    GCCapStyle | GCJoinStyle;
    if(gcfunc != -1)
    {
	values.function = gcfunc;
	mask |= GCFunction;
    }
    *gc = XCreateGC(display, rootwin, mask, &values);
}

/* Find the user who owns a given Window.
 */
static yuser *
win_user(win)
  Window win;
{
    register yuser *u;

    for(u = user_list; u; u = u->unext)
	if(u->win == win)
	    break;
    return u;
}

#define TWIN	report.xany.window

static void
process_event()
{
    register int n;
    register yuser *user;
    static XEvent report;
    static char buf[512];

    while(XPending(display))
    {
	XNextEvent(display, &report);
	switch(report.type)
	{
	    case Expose:
		if(report.xexpose.count)
		    break;
		if((user = win_user(TWIN)) != NULL)
		    redraw_term(user, 0);
		break;
	    case ConfigureNotify: /* RESIZED (or moved) */
		if((user = win_user(TWIN)) != NULL)
		{
		    int rows, cols;
		    rows = report.xconfigure.height / font_height;
		    cols = report.xconfigure.width / font_width;
		    resize_win(user, rows, cols);
		}
		break;
	    case KeyPress:
		n = XLookupString((XKeyEvent *) &report, buf, 512, NULL, NULL);
		my_input(win_user(report.xkeymap.window), buf, n);
		break;
	}
    }
}

static void
place_cursor(win, y, x)
  Window win;
  int y, x;
{
    XFillRectangle(display, win, invertGC,
	XPOS(x), YPOS(y),
	font_width, font_height);
}

/* ----- global functions ----- */

/* Initialize X Windows.
 */
void
init_xwin()
{
    char	*xrmstr;
    char	*displayName;
    char	*rfn, str[256];
    int		xfd;
    XGCValues   values;

    /* get and open the display */

    displayName = getOption("YTalk.display");
    if((display = XOpenDisplay(displayName)) == NULL)
    {
	show_error("Cannot open X display");
	bail(YTE_ERROR);
    }
    rootwin = DefaultRootWindow(display);
    screen_num = DefaultScreen(display);

    /* read all options */

    db = NULL;
    XrmInitialize();
    if((xrmstr = XResourceManagerString(display)) != NULL)
	db = XrmGetStringDatabase(xrmstr);
    else if((rfn = (char *)getenv("XENVIRONMENT")) != NULL
        && access(rfn, 0) == 0)
	db = XrmGetFileDatabase(rfn);
    else if((rfn = (char *)getenv("HOME")) != NULL)
    {
	sprintf(str, "%s/.Xdefaults", rfn);
	if(access(str, 0) == 0)
	    db = XrmGetFileDatabase(str);
    }
    if(db == NULL)
	db = XrmGetStringDatabase("");
    if(getOption("YTalk.reverse"))
    {
	whitepix = BlackPixel(display, screen_num);
	blackpix = WhitePixel(display, screen_num);
    }
    else
    {
	blackpix = BlackPixel(display, screen_num);
	whitepix = WhitePixel(display, screen_num);
    }

    /* load font and graphic context */

    if((rfn = getOption("YTalk.font")) == NULL)
	rfn = "9x15";
    load_font(rfn, &text_font);
    font_width = text_font->max_bounds.rbearing;
    font_height = text_font->max_bounds.ascent + text_font->max_bounds.descent;
    font_ascent = text_font->max_bounds.ascent;
    make_GC(&textGC, text_font, blackpix, whitepix,
	    2, LineSolid, CapRound, JoinRound, -1);
    make_GC(&invertGC, text_font, blackpix, whitepix,
	    2, LineSolid, CapRound, JoinRound, GXinvert);
    values.plane_mask = blackpix ^ whitepix;
    XChangeGC(display, invertGC, GCPlaneMask, &values);

    /* set up event processing */

    xfd = ConnectionNumber(display);
    add_fd(xfd, process_event);
}

/* End X Windows.
 */
void
end_xwin()
{
    XCloseDisplay(display);
}

/* Open a new window.
 */
int
open_xwin(user, title)
  yuser *user;
  char *title;
{
    XWMHints	WMhints;
    XClassHint	ClassHints;
    XSizeHints	size;
    XTextProperty *name;
    Window	win;
    int		rows, cols;

    size.x = 0;
    size.y = 0;
    size.width = 80;
    size.height = 24;
    size.min_width = 20;
    size.min_height = 2;
    size.width_inc = font_width;
    size.height_inc = font_height;
    size.flags = PSize | PMinSize | PResizeInc;
    if(getOption("YTalk.geometry"))
    {
	XParseGeometry(getOption("YTalk.geometry"),
	    &size.x, &size.y, (u_int *)&size.width, (u_int *)&size.height);

	/* don't set USPosition -- it confuses tvtwm */
    }
    rows = size.height;
    cols = size.width;
    size.width *= font_width;
    size.height *= font_height;
    size.min_width *= font_width;
    size.min_height *= font_height;
    win = XCreateSimpleWindow(display, rootwin, size.x, size.y,
	size.width, size.height, 4, blackpix, whitepix);
    if(win == (Window)0)
	return -1;

    WMhints.flags = InputHint;
    WMhints.input = 1;
    ClassHints.res_name = "ytalk";
    ClassHints.res_class = "YTalk";
    name = strToTP(title);
    XSetWMProperties(display, win, name, name,
	0, 0, &size, &WMhints, &ClassHints);

    XSelectInput(display, win, ExposureMask | KeyPressMask
	| StructureNotifyMask);
    XMapRaised(display, win);

    user->win = win;
    user->ty = user->tx = 0;
    place_cursor(win, 0, 0);
    resize_win(user, rows, cols);
    return 0;
}

void
close_xwin(user)
  yuser *user;
{
    XDestroyWindow(display, user->win);
    user->win = (Window)0;
}

void
addch_xwin(user, ch)
  yuser *user;
  ychar ch;
{
    XClearArea(display, user->win,
	XPOS(user->tx), YPOS(user->ty),
	font_width, font_height,
	False);
    XDrawString(display, user->win, textGC,
	XPOS(user->tx), YPOS(user->ty) + font_ascent,
	&ch, 1);
    user->tx++;
    if(user->tx >= user->t_cols)
	user->tx--;
    place_cursor(user->win, user->ty, user->tx);
}

void
move_xwin(user, y, x)
  yuser *user;
  int y, x;
{
    place_cursor(user->win, user->ty, user->tx);
    user->ty = y;
    user->tx = x;
    place_cursor(user->win, user->ty, user->tx);
}

void
clreol_xwin(user)
  yuser *user;
{
    XClearArea(display, user->win,
	XPOS(user->tx), YPOS(user->ty),
	0, font_height,
	False);
    place_cursor(user->win, user->ty, user->tx);
}

void
clreos_xwin(user)
  yuser *user;
{
    XClearArea(display, user->win,
	XPOS(user->tx), YPOS(user->ty),
	0, font_height,
	False);
    XClearArea(display, user->win,
	0, YPOS(user->ty + 1),
	0, 0,
	False);
    place_cursor(user->win, user->ty, user->tx);
}

void
scroll_xwin(user)
  yuser *user;
{
    place_cursor(user->win, user->ty, user->tx);
    XCopyArea(display, user->win, user->win, textGC,
	XPOS(0), YPOS(1),
	XPOS(user->t_cols), YPOS(user->t_rows - 1),
	XPOS(0), YPOS(0));
    XClearArea(display, user->win,
	0, YPOS(user->t_rows - 1),
	0, font_height,
	False);
    place_cursor(user->win, user->ty, user->tx);
}

void
rev_scroll_xwin(user)
  yuser *user;
{
    place_cursor(user->win, user->ty, user->tx);
    XCopyArea(display, user->win, user->win, textGC,
	XPOS(0), YPOS(0),
	XPOS(user->t_cols), YPOS(user->t_rows - 1),
	XPOS(0), YPOS(1));
    XClearArea(display, user->win,
	XPOS(0), YPOS(0),
	0, font_height,
	False);
    place_cursor(user->win, user->ty, user->tx);
}

void
flush_xwin(user)
  yuser *user;
{
    /* "user" is unused -- sorry, lint  :-) */
    XFlush(display);
}

#endif
