/* windows.h	window handler definitions
 *=======================================================================
 * 920607 kbad
 */

#ifndef _WINDOWS_H
#define _WINDOWS_H	/* window handler definitions */

#ifndef _PORTAB_H
#include <portab.h>
#endif
#ifndef _AES_H
#include <aes.h>
#endif

#undef wind_update /* for MultiTOS debugging */

/* Useful variables used by window library */
extern GRECT	w_rmax;		/* max window rect (desktop size) */
extern WORD		w_wchar, w_hchar, w_wbox, w_hbox;

/*-----------------------------------------------------------------------
 * Generic window data types.
 */
#define N_WINDFP	20	/* # of message handler functions */
#define W_HEAD		-1	/* window id to return the head of a window list */

typedef struct wind *WIND;

/* Window message handler function pointer */
typedef WORD (*WINDFP) __PROTO((WIND w, WORD *msg));
#define w_ignore ((WINDFP)NULL)

typedef struct wind {
	WIND	next;

	WORD	id;				/* AES window handle */
	WORD	wsid;			/* VDI workstation to use for drawing */
	WORD	kind;			/* AES window bits */
	WORD	wchar, hchar;	/* "character" extent: pixels per virtual unit
							 * (used for scrolling & slider calculations)
							 */
	WORD	vx, vy;			/* virtual coordinates of window origin */
	WORD	vw, vh;			/* virtual width & height of window contents */
	GRECT	rwind;			/* current window rect */
	GRECT	rwork;			/* cached work rect */
	GRECT	rdraw;			/* screen rectangle in which drawing occurs
							 * (used for scrolling & slider calculations)
							 */
	GRECT	rsave;			/* window rect before window was fulled */
	char	name[81];		/* window title */
	char	info[81];		/* window info line */

	void	(*draw) __PROTO((WIND w, GRECT *rclip));
	/* Draw window contents, clipped to `rclip'.
	 * The default function (w_erase) sets clipping to `rclip' and
	 * erases the rectangle.
	 */

	void	(*free) __PROTO((WIND w));
	/* Close, delete & free window.  May be overridden by window sub-types
	 * to free auxiliary data structures.
	 */

	WORD	(*sizecalc) __PROTO((WIND w, GRECT *rnew));
	/* Calculate new window, work & draw rects for a change in window size or
	 * position.  Returns nonzero if the window rect changed, else 0.
	 * The default function (w_sizecalc) calculates the work rect
	 * based on w->kind and sets the draw rect equal to the work rect.
	 */

/* Window event handlers */

	WORD	(*do_button) __PROTO((WIND w, int mx, int my, int mb,
								  int kstate, int nclicks));
	/* Handle a button click on window w.
	 * Return value is application specific.
	 */

	WORD	(*do_key) __PROTO((WIND w, int kstate, int key));
	/* Handle a key in window w.
	 * Return 0 if key is not handled by window,
	 * other values are application specific.
	 */

	WINDFP do_message[N_WINDFP];
	/* Array of window message handlers.
	 * Handlers return 0 on error, other values are application specific.
	 * Set unused handlers to w_ignore.
	 */
};

/*-----------------------------------------------------------------------
 * Generic window functions.
 */
#define w_isopen(w)		( ((WIND)(w))->rwork.g_w )
#define w_isfull(w)		( ((WIND)(w))->rsave.g_w )
#define w_windfp(w,n)	( ((WIND)(w))->do_message[(n)-WM_REDRAW] )
#define w_msg(w,n,msg)	\
		( ((WIND)(w))->do_message[(n)-WM_REDRAW](((WIND)(w)),(msg)) )

GLOBAL	void	w_init __PROTO((void));
GLOBAL	WORD	w_new __PROTO((int kind, const GRECT *rfull,
							   int wsid, int wchar, int hchar, int vw, int vh,
							   WORD (*sizecalc)(WIND w, const GRECT *rnew),
							   long alloc));
GLOBAL	void	w_free __PROTO((WIND w));
GLOBAL	WORD	w_open __PROTO((WIND w, const GRECT *ropen));
GLOBAL	WIND	w_lookup __PROTO((int id));
GLOBAL	WIND	*w_plink __PROTO((WIND w));

/* Generic window utility functions */
GLOBAL	void	w_nameinfo __PROTO((WIND w, char *name, char *info));
GLOBAL	void	w_scroll __PROTO((WIND w, int dx, int dy, GRECT *rdraw));
GLOBAL	WORD	w_sliders __PROTO((WIND w, int dovert, int dohorz));
GLOBAL	WORD	wsl_size __PROTO((int visrange, int range));
GLOBAL  WORD	wsl_position __PROTO((WORD *pval, int visrange, int range));

/* Default window handlers */
GLOBAL	void	w_erase __PROTO((WIND w, GRECT *rclip));
GLOBAL	WORD	w_sizecalc __PROTO((WIND w, const GRECT *rnew));

/* Default window message handlers */
GLOBAL	WORD	w_redraw __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_topped __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_closed __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_fulled __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_arrowed __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_slid __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_sized __PROTO((WIND w, WORD *msg));
GLOBAL	WORD	w_ontop __PROTO((WIND w, WORD *msg));

#endif /* !defined(_WINDOWS_H) */
