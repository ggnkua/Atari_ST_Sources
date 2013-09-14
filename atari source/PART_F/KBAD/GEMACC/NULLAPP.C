/* nullapp.c
** null application for gemskel.c application skeleton.
** Copyright 1990, Atari Corporation
**
** 900129 kbad updated for textwind
** 890708 kbad Created
*/

#include <sys\gemskel.h>
extern int gl_apid;
int ctrl_id;

/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par

/*#define TEXTWIND*/	/* use textwind.c window handling */


/* GEMSKEL functions
 * ================================================================
 */



void
wind_init( void )
{
   ctrl_id = menu_register( gl_apid, "  Gemacc");
}


void
evnt_init( void )
{
/* this example only looks for message events */
	evnt_set( MU_MESAG,	0, 0, 0, NULL, NULL, 0L );
}


BOOLEAN
evnt_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
	return FALSE; /* don't override event handling */
}


#ifndef TEXTWIND
void
do_windows( int *msg, int *event )
{
}
#endif


void
acc_open( const int *msg )
{
}


void
acc_close( const int *msg )
{
}


void
msg_hook( const int *msg, int *event )
{
}


void
do_timer( int *event )
{
}


void
do_key( int kstate, int key, int *event )
{
}


void
do_button( MRETS *mrets, int nclicks, int *event )
{
}


void
do_m1( MRETS *mrets, int *event )
{
}


void
do_m2( MRETS *mrets, int *event )
{
}


void
redraw( const WINFO *w, GRECT *clip )
{
}


BOOLEAN
wind_in( int *msg, WINFO *w )
{
	return FALSE; /* let do_windows() do its thing */
}

void
wind_adjust( const WINFO *w, GRECT *rect )
{
}

BOOLEAN
wind_out( const int *msg, WINFO *w )
{
	return FALSE; /* don't quit the application */
}


void
wind_exit( void )
{
}


void
rsrc_exit( void )
{
}
