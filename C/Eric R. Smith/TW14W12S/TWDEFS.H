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
#define BOXLEN 33
#define SHORTWAIT 20
#define LONGWAIT 40
#define NOMULTIWAIT (oldACC ? 20 : 0)

#define MINROWS 1
#define MINCOLS 10
#define MAXROWS 128
#define MAXCOLS 220

typedef struct fontdesc {
	char name[BOXLEN+1];
	int  isfsm;
	int  fontidx;
	int  num_points;		/* number of point sizes available */
	long points;			/* vector of point sizes available */
} FONTDESC;

extern FONTDESC *fontdesc;

extern WINDOW *toolwindow;
extern WINDOW *focuswin;
extern OBJECT *cutdialog, *menudef_dialog, *fontdial;
extern OBJECT *deskobj;

extern MENU *sysbar, *globalmenu, *windowmenu, *filemenu, *editmenu, *gadgmenu;
extern ENTRY *closeentry, *copyentry, *pasteentry;

extern int default_font, default_height;
extern int default_kind;	/* gadgets for windows */
extern int smoothscroll, autoclose;
extern int cut_options, paste_options;
extern int altrow, altcol, win_flourishes;
extern int stdrow, stdcol;
extern int stdscroll, altscroll;
extern int appl_menus, sys_menu;
extern int align_windows;
extern int env_options;
#ifdef WWA_AUTO_RAISE
extern int auto_raise;
#endif
#define E_ARGV	0x0001
#define E_POSIX 0x0002
#define E_TERM	0x0004
#define E_TERMCAP	0x0008

extern int showtools;
extern int toolx, tooly;

extern int point_to_type;

extern char progpath[], dfltprog[];
extern int lineAset;
extern int MultiTOS;
extern int oldACC;
extern int opened;
extern short _app;	/* nonzero if application */

#define OK 0
#define FAIL -1

#ifndef TIOCSWINSZ
#define TIOCGWINSZ	(('T'<< 8) | 11)
#define TIOCSWINSZ	(('T'<< 8) | 12)

struct winsize {
	short ws_row, ws_col, ws_xpixel, ws_ypixel;
};

#endif
