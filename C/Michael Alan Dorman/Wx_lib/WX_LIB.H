#include <stdarg.h>
#include <gemfast.h>

#ifdef __GNUC__
#include <aesbind.h>
#include <vdibind.h>
#endif

#ifndef WX_LIB

#ifndef FALSE
#define FALSE 0
#define TRUE 1
#endif

#ifndef NULL
#define NULL 0L
#endif

/*
 * This is the structure that holds all our window information.  No doubt
 * it will continue to grow and feed and become larger.  I keep the current
 * inside and outside dimensions because I don't seem to be able to get
 * wind_calc to work correctly.
 */
typedef struct  {
				/*
				 * This is the pointer to the window's "name" string.
				 */
		char	*name,
				/*
				 * This is the pointer to the window's "info" string.
				 */
				*info;
				/*
				 * The window handle for this "Window".
				 */
		int		hand,
				/*
				 * The VDI handle for use by the wx_xxxx() calls.
				 */
				vdih,
				/*
				 * A flag to indicate whether the window is open.
				 */
				open,
				/*
				 * A flag to indicate whether the window has been created.
				 */
				actv,
				/*
				 * What type of gadgets does it have?
				 */
				type,
				/*
				 * What is the current x position of the cursor?
				 */
				xpos,
				/*
				 * What is the current y position of the cursor?
				 */
				ypos,
				/*
				 * What is the first text-writable column?
				 */
				minx,
				/*
				 * What is the first text-writable row?
				 */
				miny,
				/*
				 * What is the final text-writable column?
				 */
				maxx,
				/*
				 * What is the final text-writable row?
				 */
				maxy,
				/*
				 * What is the scroll-rate of the window?
				 */
				scrl,
				/*
				 * What are the current outside dimensions?
				 */
				wchr,
				hchr;
		GRECT	curr,
				/*
				 * What are the full outside dimensions?
				 */
				full,
				/*
				 * What are the workspace dimensions?
				 */
				work,
				/*
				 * What are the previous dimensions?
				 */
				prev;
} Window;

#ifdef __STDC__
extern	void	wx_clear(Window *);
extern	void	wx_close(Window *);
extern	void	wx_free(Window *);
extern	void	wx_fscroll(Window *);
extern	void	wx_full(Window *);
extern	void	wx_get(Window *);
extern	int		wx_info(Window *,char *);
extern	int		wx_init(Window *,int,int,int);
extern	void	wx_move(Window *,int,int);
extern	int		wx_name(Window *,char *);
extern	void	wx_new(Window *);
extern	int		wx_open(Window *);
extern	void	wx_outstr(Window *,char *);
extern	void	wx_printf(Window *,char *,...);
extern	int		wx_puts(Window *,char *);
extern	void	wx_setclip(Window *);
extern	void	wx_settype(Window *,int);
extern	void	wx_size(Window *,int,int);
#else
extern	void	wx_clear();
extern	void	wx_close();
extern	void	wx_free();
extern	void	wx_fscroll();
extern	void	wx_full();
extern	void	wx_get();
extern	int		wx_info();
extern	int		wx_init();
extern	void	wx_move();
extern	int		wx_name();
extern	void	wx_new();
extern	int		wx_open();
extern	void	wx_outstr();
extern	void	wx_printf();
extern	int		wx_puts();
extern	void	wx_setclip();
extern	void	wx_settype();
extern	void	wx_size();
#endif

#define WINX_LIB

#endif
