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
#include <gemfast.h>
#include <aesbind.h>
#include <vdibind.h>

#ifndef TRUE
#define TRUE 1
#define FALSE 0
#endif

#ifndef UCHAR
#define UCHAR unsigned char
#endif

/* types definitions for the object library */

/* type for holding various menus */

typedef struct menu_entry {
	struct menu_entry *next;
	char	*entry;		/* string for this entry */
	void	(*func)();	/* function to call when selection made */
	void	*arg;		/* argument for above function */
	int	keycode;	/* keyboard equivalent, if any */
	int	state;		/* initial menu state (e.g. DISABLED) */
	int	index;		/* menu index in object tree */
} ENTRY;

typedef struct menu {
	struct menu *next;
	char 	*title;
	ENTRY 	*contents;	/* pointer to menu contents */
	int 	width;		/* max. width of any entry in the menu */
	int 	index;		/* index into object tree */
} MENU;


/* Generic window type */

typedef struct win WINDOW;

struct win {
	int	wi_handle;	/* AES window handle */
	int	wi_kind;	/* window gadgets */
	int	wi_x, wi_y,
		wi_w, wi_h;	/* size of window working area */

	int	wi_fullx, wi_fully,
		wi_fullw, wi_fullh;

	char 	*wi_title;
	struct win *next;	/* next window in list */

	int	wtype;		/* type of window */
#define GENERIC_WIN	0
#define TEXT_WIN	1
#define GRAPH_WIN	2
#define OBJ_WIN		3

	int	flags;		/* various window flags */
#define WFULLED	1
#define WICONIFIED 2		/* window is in iconified format */

	int	icon_slot;	/* icon manager slot */
	int	old_wkind;	/* old window gadgets before iconification */

/* Pointer to extra data for subclasses */
	void	*extra;

/* functions to call when something happens to the window */
	void	(*draw) __PROTO((WINDOW *, int x, int y, int w, int h));
	void	(*topped) __PROTO((WINDOW *));
	void	(*closed) __PROTO((WINDOW *));
	void	(*fulled) __PROTO((WINDOW *));
	void	(*sized) __PROTO((WINDOW *, int x, int y, int w, int h));
	void	(*moved) __PROTO((WINDOW *, int x, int y, int w, int h));
	void	(*arrowed) __PROTO((WINDOW *, int msg));
	void	(*hslid) __PROTO((WINDOW *, int hpos));
	void	(*vslid) __PROTO((WINDOW *, int vpos));
	int	(*keyinp) __PROTO((WINDOW *, int keycode, int shft ));
	int	(*mouseinp) __PROTO((WINDOW *, int clicks, int x, int y, 
				int shft, int mbuttons));
	void	(*iconify) __PROTO((WINDOW *, int, int, int, int, int));
	void	(*oldfulled) __PROTO((WINDOW *));
	int	(*oldmouse) __PROTO((WINDOW *, int, int, int, int, int));
	int	prevx, prevy, prevw, prevh;
	MENU	*menu;		/* menu that goes with this window */
	char	*infostr;	/* string to put in the INFO line */
};

/* Text window */
typedef struct textwin {
	WINDOW	*win;		/* underlying WINDOW struct */
	int	offx, offy;	/* offset of window (0, 0) position */
	short	maxx;		/* number of characters across */
	short	miny;		/* first 'real' line (previous lines are scrollback */
	short	maxy;		/* number of characters down */
#define SCROLLBACK(t) ((t)->miny)
#define NROWS(t) ((t)->maxy - (t)->miny)
#define NCOLS(t) ((t)->maxx)

	short	cx, cy;		/* current cursor position (character coord.) */
	short	cmaxwidth;	/* max. character width */
	short	cheight;	/* character height */
	short	cbase;		/* distance from character baseline to top */
	short	cfont;		/* font for characters */
	short	cpoints;	/* size of characters in points */
	short	savex, savey;	/* saved cursor position */
	short	term_flags;	/* e.g. cursor on/off */
#define FINSERT	0x1000	/* insert characters */
#define FFLASH	0x2000	/* cursor is currently showing */
#define FCURS	0x4000	/* cursor enabled */
#define FWRAP	0x8000	/* wrap at end of line */
	short	term_cattr;	/* current character attributes */
				/* also foreground and background colors */

	short	escy1;		/* first char. for ESC Y */
	void	(*output)();	/* output function */
	UCHAR	**data;		/* terminal data */
	short	**cflag;	/* flags for individual characters */
#define CBGCOL		0x000f	/* background color mask */
#define CFGCOL		0x00f0	/* foreground color mask */
#define COLORS(fg, bg)	(((fg) << 4) | (bg))
#define CEFFECTS	0x0f00	/* VDI output style mask */
#define 	CE_BOLD		0x0100
#define		CE_LIGHT	0x0200
#define		CE_ITALIC	0x0400
#define		CE_UNDERLINE	0x0800
#define CINVERSE	0x1000	/* character is in inverse video */
#define CSELECTED	0x2000	/* character has been selected by mouse */
#define CTOUCHED	0x4000	/* character attributes have changed */
#define CDIRTY		0x8000	/* the character itself has changed */

	char	*dirty;		/* marks whether lines need redrawing */
#define SOMEDIRTY	0x01		/* some of the line needs redrawing */
#define ALLDIRTY	0x02		/* whole line is dirty */
	int	fd;		/* file descriptor for pseudo-tty */
	int	pgrp;		/* process group for terminal */
	int	scrolled;	/* number of lines to scroll before re-draw */
	int	nbytes;		/* number of bytes written to window since
				   last refresh */
	int	draw_time;	/* set to indicate how long it's been since
				   the last refresh */
	char	*prog;		/* program name */
	char	*cmdlin;	/* program command line */
	char	*progdir;	/* program current directory */
	void	(*callback)();	/* call this when the capture buffer is full */
#define CAPTURESIZE 79
	char	captbuf[CAPTURESIZE+1];
	int	captsiz;
	int	minADE, maxADE;	/* min. and max. character the font can
				   display */
	short	*cwidths;	/* table of font widths */
	short	flashtimer;	/* counter for flashing cursor */
	short	flashperiod;	/* timer for flashing */
} TEXTWIN;

/* global variables */
extern int phys_handle, vdi_handle, gl_apid;
extern int gl_hchar, gl_wchar, gl_wbox, gl_hbox;
extern int xdesk, ydesk, wdesk, hdesk;
extern int gl_numfonts;
extern int gl_rx, gl_ry, gl_rw, gl_rh, gl_rstate;
extern int gl_screenplanes;

extern int gl_done;		/* set to 1 when the user wants to exit */
extern WINDOW *gl_winlist, *gl_topwin;

extern char *about_string;	/* string for the "About..." dialog box */
extern void (*about_func)();	/* function called when above is selected */

extern long gl_timer;		/* if evnt_loop should time out */
extern void (*fn_timeout)();	/* called on a time out */
extern void (*fn_message)();
extern int (*fn_key)();		/* called for key presses */
extern void (*fn_mouse)();	/* called for mouse clicks */
extern void (*fn_rect)();	/* called for rectangle events */

/*
 * misc. gem utility functions
 */

__EXTERN void open_vwork	__PROTO((void));
__EXTERN void close_vwork	__PROTO((void));
__EXTERN void init_gem		__PROTO((void));
__EXTERN void exit_gem		__PROTO((int));
__EXTERN void evnt_loop		__PROTO((void));
__EXTERN void hide_mouse	__PROTO((void));
__EXTERN void show_mouse	__PROTO((void));
__EXTERN void set_clip		__PROTO((int, int, int, int));
__EXTERN void reset_clip	__PROTO((void));
__EXTERN int ALT		__PROTO((int));
__EXTERN char *UNALT		__PROTO((int));
__EXTERN void set_fillcolor	__PROTO((int));
__EXTERN void set_textcolor	__PROTO((int));
__EXTERN void set_texteffects	__PROTO((int));
__EXTERN void set_wrmode	__PROTO((int));
__EXTERN void set_font		__PROTO((int, int));
__EXTERN void set_fillstyle	__PROTO((int, int));

/*
 * functions for dealing with menus
 */

__EXTERN MENU *create_menu	__PROTO(( const char *title ));
__EXTERN void destroy_menu	__PROTO(( MENU * ));

__EXTERN ENTRY *add_entry	__PROTO(( MENU *, char *, void (*)(), void *,
					  int, int ));
__EXTERN void show_menu		__PROTO(( MENU * ));
__EXTERN void hide_menu		__PROTO(( void ));
__EXTERN int menu_key		__PROTO(( int, int ));
__EXTERN void check_entry	__PROTO(( MENU *, ENTRY * ));
__EXTERN void uncheck_entry	__PROTO(( MENU *, ENTRY * ));
__EXTERN void enable_entry	__PROTO(( MENU *, ENTRY * ));
__EXTERN void disable_entry	__PROTO(( MENU *, ENTRY * ));
__EXTERN void popup_menu	__PROTO(( MENU *, int, int ));
__EXTERN void dropdown_menu	__PROTO(( MENU *, int, int ));
__EXTERN char *menustr		__PROTO(( MENU * ));

/*
 * functions for dealing with windows
 */

__EXTERN WINDOW *create_window
	__PROTO(( const char *title, int kind, int x, int y, int w, int h ));
__EXTERN WINDOW *open_window	__PROTO(( WINDOW * ));
__EXTERN void close_window	__PROTO(( WINDOW *));
__EXTERN void destroy_window	__PROTO(( WINDOW * ));
__EXTERN void handle_window	__PROTO(( int *msgbuff ));
__EXTERN int window_key		__PROTO(( int keycode, int shift ));
__EXTERN void end_windows	__PROTO(( void ));
__EXTERN WINDOW *find_window	__PROTO(( int, int ));
__EXTERN void change_window_gadgets __PROTO(( WINDOW *, int ));
__EXTERN void new_topwin	__PROTO(( int ));
__EXTERN void title_window	__PROTO(( WINDOW *, char * ));
__EXTERN void redraw_window	__PROTO(( WINDOW *, int, int, int, int ));

/*
 * text window functions
 */

__EXTERN TEXTWIN *create_textwin __PROTO((char *, int, int, int, int, int, int));
__EXTERN void destroy_textwin __PROTO(( TEXTWIN * ));
__EXTERN void textwin_setfont __PROTO(( TEXTWIN *, int, int));
__EXTERN void resize_textwin __PROTO(( TEXTWIN *, int, int, int));
__EXTERN void refresh_textwin __PROTO(( TEXTWIN * ));
__EXTERN void pixel2char __PROTO(( TEXTWIN *, int, int, int *, int *));
__EXTERN void char2pixel __PROTO(( TEXTWIN *, int, int, int *, int *));
__EXTERN void mark_clean __PROTO(( TEXTWIN * ));

__EXTERN void set_curs __PROTO(( TEXTWIN *, int ));

#define curs_on(v) set_curs(v, 1)
#define curs_off(v) set_curs(v, 0)

__EXTERN void curs_flash __PROTO(( TEXTWIN * ));

/*
 * object window functions
 */

__EXTERN WINDOW *create_objwin __PROTO((OBJECT *, char *, int, int, int, int, int));
