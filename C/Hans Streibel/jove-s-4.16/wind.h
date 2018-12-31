/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/* typedef struct window Window in jove.h */

struct window {
	Window
		*w_prev,	/* circular list */
		*w_next;
	Buffer	*w_bufp;	/* buffer associated with this window */
	LinePtr
		w_top,		/* top line */
		w_line;	/* current line */
	int
		w_char,
		w_height,	/* window height (including mode line) */
		w_topnum,	/* buffer line number of the topline */
		w_dotcol,	/* screen column of w_line (set by UpdWindow) */
		w_dotline,	/* screen line number of w_line (set by UpdWindow) */
		w_flags,
#define	W_TOPGONE	01
#define	W_CURGONE	02	/* topline (curline) of window has been deleted
				   since the last time a redisplay was called */
#define W_VISSPACE	04
#define W_NUMLINES	010
		w_LRscroll;	/* amount of LeftRight scrolling in window */
#ifdef MAC
	int	w_topline;	/* row number of top line in window */
	/* Note: "ControlHandle w_control" would require more includes */
	struct ControlRecord **w_control;	/* scroll bar for window */
#endif
};

#define W_NUMWIDTH(w)	(((w)->w_flags & W_NUMLINES)? 8 : 0)
#define SIWIDTH(off)	((off) != 0? 1 : 0)	/* width of shift indicator, if any */

extern Window
	*fwind,		/* first window in list */
	*curwind;	/* current window */

#define one_windp()	(fwind->w_next == fwind)
#define WSIZE(wp)	((wp)->w_height - 1)	/* window lines, without modeline */

extern int
	FLine proto((Window *w)),
	in_window proto((Window *windes,LinePtr line));

extern Window
	*div_wind proto((Window *wp,int n)),
	*windbp proto((Buffer *bp));

extern void
	CalcWind proto((Window *w)),
	CentWind proto((Window *w)),
	SetTop proto((Window *w,LinePtr line)),
	SetWind proto((Window *new)),
	WindSize proto((Window *w,int inc)),
	del_wind proto((Window *wp)),
	pop_wind proto((char *name,bool clobber,int btype)),
	tiewind proto((Window *w,Buffer *bp)),	/* util.c!! */
	winit proto((void));

/* Commands: */

extern void
	DelCurWindow proto((void)),
	GotoWind proto((void)),
	GrowWindowCmd proto((void)),
	NextWindow proto((void)),
	OneWindow proto((void)),
	PageNWind proto((void)),
	PrevWindow proto((void)),
	ScrollLeft proto((void)),
	ScrollRight proto((void)),
	ShrWindow proto((void)),
	SplitWind proto((void)),
	WNumLines proto((void)),
	WVisSpace proto((void)),
	WindFind proto((void));

/* Variables: */

extern int	ScrollStep;		/* VAR: how should we scroll */

#ifdef HIGHLIGHTING
extern bool	ScrollBar;		/* VAR: whether the scrollbar is used */
#endif
