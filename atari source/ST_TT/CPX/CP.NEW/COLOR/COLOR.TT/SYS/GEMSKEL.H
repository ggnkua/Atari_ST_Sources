/* gemskel.h - header file for GEM application skeleton
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900129 kbad reviewed
 * 890716 kbad Modified to use *event as a quit flag.
 * 890708 kbad Created
 */

#ifndef __AESALT__
#include <alt\aesalt.h> /* alternate aes bindings, gets aes, stddef */
#endif

#ifndef __VDI__
#include <vdi.h>		/* MFDB definition */
#endif

/* Application specific global functions
 * ================================================================
 */

BOOLEAN	rsrc_init( void );

/* Resource init hook, responsible for loading and initializing
 * resource, setting the address of the menu object (see below), and
 * performing menu_register() if needed for DA.
 * If an error occurs during resource initialization, return FALSE,
 * and the application will exit with an alert. Otherwise return TRUE.
 */

void wind_init( void );

/* Window init hook, called before first evnt_multi.
 */

void evnt_init( void );

/* Hook to initialize evnt_multi parameters.  This is the last thing called
 * before the application goes into the main evnt_multi loop, and it should
 * set the parameters for evnt_multi via evnt_set (see below).
 */

BOOLEAN	evnt_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks );
/* Hook called immediately after evnt_multi, before the event is handled.
 * Return TRUE to override default event handling, or
 * FALSE to continue with default event handling.
 */

/* Event handling functions
 * =================================================================
 *
 * Mask `*event' as necessary to disable further event processing.
 * The handlers are listed here in the order they are used
 * in the default gemskel.
 * Setting *event to 0 will quit the application.
 */

void do_timer( int *event );
void do_key( int kstate, int key, int *event );
void do_button( MRETS *mrets, int nclicks, int *event );
void do_m1( MRETS *mrets, int *event );
void do_m2( MRETS *mrets, int *event );


/* Message handling functions
 * Mask *event as necessary to disable further event processing
 * (in the default gemskel, message processing is last, though).
 * Setting *event to 0 will quit the application.
 * `msg_hook' is called to handle non-standard AES pipeline messages.
 */
void	do_menu( const int *msg, int *event );
void	do_windows( int *msg, int *event );
void	acc_open( const int *msg );
void	acc_close( const int *msg );
void	msg_hook( const int *msg, int *event );


/* Window drawing functions
 */
void	redraw( const WINFO *w, GRECT *clip );
/* App-specific redraw procedure, called to redraw all or
 * parts of windows.
 */
BOOLEAN	wind_in( int *msg, WINFO *w );
/* Window hook, called before a window message is handled.
 * Return TRUE to override the default message handling,
 * and have do_windows() do_nothing.
 */
void	wind_adjust( const WINFO *w, GRECT *rect );
/* Adjust the coordinates of the window for scrolling redraws.
 * Useful for text windows, which need about a half character
 * width on the left to look nice.
 */
BOOLEAN wind_out( const int *msg, WINFO *w );
/* Window hook called after window message is handled.
 * Its return value is also returned by do_windows() -
 * TRUE to quit the application, FALSE to continue.
 */

/* Termination hooks.
 */
void	wind_exit( void );
/* Window termination hook, responsible for shutting down and deallocating
 * all windows owned by the application.
 */
void	rsrc_exit( void );
/* Resource termination hook, responsible for turning off the menu
 * and deallocating the resource.
 */

/* Global functions defined in gemskel.c
 * ================================================================
 */
void	evnt_set( int mask, int clicks, int bmask, int bstate,
					MOBLK *m1, MOBLK *m2, long time );
/* Sets event parameters for the next iteration of the main evnt_multi.
 * Set unused integral parameters to -1, unused MOBLK pointers to NULL.
 * This function should be called by evnt_init() (see above).
 * WARNING: setting mask to 0 will terminate an application, or send
 *			an accessory into a permanent infinite loop.
 */
void	gem_exit( int code );
/* Exits the application, returning `code' to the parent.
 */

/* Global functions defined in textwind.c
 * ================================================================
 */
int		make_window( WINFO **pwind, GRECT *full, GRECT *open,
					int kind, char *name, char *info,
					int wchar, int hchar, int vw, int vh, void *wx );
/* Take a WINFO struct, create a window and link it in.
 * If either GRECT is NULL, attempt to come up with a
 * reasonable size.
 * Returns AE_OK, AENHNDL(no more windows), or AENSMEM(not enuf mem).
 */
void	byte_align( WINFO *w, BOOLEAN toright );
/* Ensure that the drawing coordinates of the window are byte-aligned.
 * Call with toright = TRUE if moving window to right.
 * This makes v_gtext significantly faster.
 */
void	wind_extent( WINFO *w );
/* Calculate the physical extent of the window and fill in the
 * w->phy GRECT.
 */
void	wind_sliders( BOOLEAN v, BOOLEAN h, WINFO *w );
/* Set vertical and/or horizontal window slider positions and
 * sizes, based on physical and virtual coordinates in `w'.
 */
void	wind_arrowed( int how, WINFO *w );
/* Handle a WM_ARROWED message
 */
WINFO	*id_2winfo( int id );
/* return the WINFO with id `id'.
 */
BOOLEAN	wind_unlink( WINFO *w );
/* unlink `w', and return TRUE if it was the last window open
 */
void	screenblit( GRECT *clip, GRECT *rs, GRECT *rd );
/* Splat part of the screen somewhere.  Used for "fast" scrolling.
 */
void	erase_right( WINFO *w );
/* Erase partial characters at the right of the window.
 */


/* Global variables (defined in gemskel.c unless noted)
 * ================================================================
 */

extern	int _app;
/* application flag defined in startup code. if(!_app) we are a DA
 */

/* Arguments to main()
 */
extern	int		nargs;			/* global copy of argc */
extern	char	**args,			/* global copy of argv */
				**env;			/* global copy of envp */

/* VDI stuff
 */
extern int		contrl[12],		/* VDI parameter block arrays */
				intin[128],
				intout[128],
				ptsin[128],
				ptsout[128],
				work_in[12],	/* open workstation arrays */
				work_out[57];
extern int		vhandle,		/* virtual screen workstation handle */
				xres, yres;		/* screen resolution */

/* AES stuff
 */
extern int		gl_apid,		/* AES application id */
				gl_hchar,		/* bounds of a character cell */
				gl_wchar,
				gl_hbox,		/* square character bounding box */
				gl_wbox;
extern GRECT	desk;			/* desktop work rectangle */
extern OBJECT	*menu;			/* address of menu object tree */
extern WINFO	*window1;		/* start of linked window list,
								 * declared in textwind.c
								 */

/* null structures
 */
extern GRECT	grect0;
extern MOBLK	moblk0;
extern MFDB		mfdb0;
