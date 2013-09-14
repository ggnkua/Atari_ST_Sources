#include <sys\gemskel.h>

/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par


/*-----------------------------------------------------------------------
 */
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


BOOLEAN
evnt_hook( int event, int *msg, MRETS *mrets, int *key, int *nclicks )
{
	return FALSE; /* don't override event handling */
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


