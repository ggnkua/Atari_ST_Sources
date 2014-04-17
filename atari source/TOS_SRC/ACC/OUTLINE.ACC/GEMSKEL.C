/* ================================================================
 * FILE: GEMSKEL.C
 * ================================================================
 * DATE: November 20, 1992
 *	 June 21, 1993	cjg	Removed wind_updat() fro GEM_EXIT()
 * DESCRIPTION: GEM Application Skeleton
 */


/* INCLUDES 
 * ================================================================
 */
#include <sys\gemskel.h>
#include <stdlib.h>
#include <tos.h>

#include "country.h"
#include "text.h"

/* DEFINES
 * ================================================================
 */
#define AP_TERM		50	/* NEW AES Call! */



/* EXTERNS
 * ================================================================
 */
int open_vwork( void );	/* From FSM.C */
void close_vwork( void );



/* GLOBALS
 * ================================================================
 */

/* VDI arrays */
int	contrl[12], intin[128], intout[128], ptsin[128], ptsout[128],
	work_in[12], work_out[57];
int	phys_handle, vhandle, xres, yres;


/* AES variables */
int	AES_Version; 
int     gl_ncolors;
int	gl_apid, gl_hchar, gl_wchar, gl_hbox, gl_wbox;
GRECT	desk;
OBJECT	*menu;


/* null structures */
GRECT	grect0 = { 0, 0, 0, 0 };
MOBLK	moblk0 = { 0, 0, 0, 0, 0 };
MFDB	mfdb0 = { NULL, 0, 0, 0, 0, 0, 0, 0, 0 };


/* Locals used for evnt_multi input, can be set via set_events()
 * ================================================================
 */
static	int	ev_mask=0, ev_clicks=0, ev_bmask=0, ev_bstate=0;
static	MOBLK	ev_m1 = { 0, 0, 0, 0, 0 };
static	MOBLK	ev_m2 = { 0, 0, 0, 0, 0 };
static	long	ev_time=0L;


/* FUNCTIONS
 * ================================================================
 */


/*
 * main()
 * ================================================================
 */
void
main( void )
{
	int	event, msg[8], key, nclicks;
	MRETS	mrets;


/*
 * See if we were run from the AUTO folder...
 */
        gl_apid = appl_init();

	/* Get the AES version #.  TOS 3.0 is TT TOS */
	AES_Version = _GemParBlk.global[0];
/*
 * Set up work_in to initialize VDI functions to useful values,
 * Get the physical workstation handle from the AES, then
 * open a virtual workstation and get our AES work area's extent.
 */
	phys_handle = graf_handle(&gl_wchar,&gl_hchar,&gl_wbox,&gl_hbox );

	Wind_get( 0, WF_WORKXYWH, ( WARGS *)&desk );
	
	/* Call initialization hooks */
	rsrc_init();


	if( !open_vwork() )
        {
	   /* Unable to open workstation - exit application */
           form_alert( 1, alert18 );
	   gem_exit( 0 );
        }
	close_vwork();
	gl_ncolors = work_out[13];
	xres       = work_out[0];
	yres	   = work_out[1];
	vhandle = 0;

	
	wind_init();
	evnt_init();
	
	/* Main event loop */
	do
	{

		event = Evnt_multi( ev_mask, ev_clicks, ev_bmask, ev_bstate,
				    &ev_m1, &ev_m2, ( WORD *)msg, ev_time,
				    &mrets,(WORD *)&key,(WORD *)&nclicks );
		wind_update( BEG_UPDATE );
		

	/* Dispatch events.
	 * It is possible to get more than one event at a time, so if the
	 * order of event handling is important to you, change the order
	 * in which they're handled here.
	 */
		if( event & MU_MESAG )
			switch( msg[0] ) {

				case MN_SELECTED:
				break;

				case WM_REDRAW:
				case WM_TOPPED:
				case WM_CLOSED:
				case WM_FULLED:
				case WM_ARROWED:
				case WM_HSLID:
				case WM_VSLID:
				case WM_SIZED:
				case WM_MOVED:
				case WM_NEWTOP:
					do_windows( msg, &event );
				break;

				case AC_OPEN:
					acc_open( msg );
				break;
				
				case AP_TERM:
				case AC_CLOSE:
					acc_close( msg );
				break;

				default:
					break;
			} /* switch */
		/* MU_MESAG */

		wind_update( END_UPDATE );

	/*
	 * Event handling routines zero out the event variable
	 * to exit the application.
	 */
	} while( event );

	gem_exit( 0 );
}


/* gem_exit()
 * ================================================================
 * Clean exit.
 */
void
gem_exit( int code )
{
	int ignore[8];

/*
 * Go into an endless loop if we're a desk accessory...
 */
	if( !_app ) for(;;) evnt_mesag( ignore );

/*
 * Otherwise, clean up and call the exit hooks
 */
/*	wind_update( END_UPDATE ); cjg 06/18/93 */
	close_vwork();
	wind_exit();   
	appl_exit();
	exit( code );
}


/*
 * evnt_set()
 * ================================================================
 * Set parameters for main evnt_multi.
 */
void
evnt_set( int mask, int clicks, int bmask, int bstate,
	  MOBLK *m1, MOBLK *m2, long time )
{
	if( !mask ) gem_exit( -1 );

	if( mask != -1 )	ev_mask = mask;
	if( clicks != -1 )	ev_clicks = clicks;
	if( bmask != -1 )	ev_bmask = bmask;
	if( bstate != -1 )	ev_bstate = bstate;
	if( m1 != NULL )	ev_m1 = *m1;
	if( m2 != NULL )	ev_m2 = *m2;
	if( time != -1L )	ev_time = time;
}





