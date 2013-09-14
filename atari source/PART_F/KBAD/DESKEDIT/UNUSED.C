/* unused.c - unused GEMSKEL routines for desk accessory editor
 * using gemskel.c application skeleton, with textwind.c window manager.
 * Copyright 1990, Atari Corporation
 * ================================================================
 * 900125 kbad Created from DESKEDIT.C
 */

#include <sys\gemskel.h>

/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par


/* GEMSKEL functions
 * ================================================================
 */


BOOLEAN
rsrc_init( void )
{
	return TRUE;
}


BOOLEAN
evnt_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
	return FALSE;
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
do_menu( const int *msg, int *event )
{
}


void acc_open( const int *msg )
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


BOOLEAN
wind_in( int *msg, WINFO *w )
{
	return FALSE;
}


void
rsrc_exit( void )
{
}
