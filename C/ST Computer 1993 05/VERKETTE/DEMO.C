/***********************************************/
/* DEMO.C                                      */
/*                                             */
/* Eine Demo fÅr CLUTCH                        */
/***********************************************/

#include <stdio.h>

#include "clutch.h"




WORD main()
{
	WORD  id;
	VOID  *c[3], *d;


	if( !CLInitClutch() )
		return( 0 );


	if( (id = CLInitChain()) == -1 )
		return( 0 );


	/* Clutches anlegen */
	c[0] = CLAddClutch( id, 100L );
	c[1] = CLAddClutch( id, 100L );
	c[2] = CLAddClutch( id, 100L );


	/* Adresen ausgeben */
	printf( "%ld\n%ld\n%ld\n\n\n",
	        (LONG)c[0], (LONG)c[1], (LONG)c[2] );


	/* Adressen erfragen und ausgeben */
	d = CLGetFirstClutch( id );
	printf( "%ld\n", (LONG)d );

	d = CLGetNextClutch( id );
	printf( "%ld\n", (LONG)d );

	d = CLGetNextClutch( id );
	printf( "%ld\n", (LONG)d );

	d = CLGetNextClutch( id );
	printf( "%ld\n", (LONG)d );

	d = CLGetNextClutch( id );
	printf( "%ld\n", (LONG)d );


	/* Und wieder lîschen
	   (auch mit 'CLClearAllClutches()' mîglich) */
	CLClearClutch( c[1] );
	CLClearClutch( c[2] );
	CLClearClutch( c[0] );



	return( 0 );
}