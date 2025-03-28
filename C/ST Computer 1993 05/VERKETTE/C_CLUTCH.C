/***********************************************/
/* C_CLUTCH.C                                  */
/*                                             */
/* Aufbau eines Clutchs:                       */
/* - 4 Bytes fÅr 'prev'-Pointer                */
/* - 4 Bytes fÅr 'next'-Pointer                */
/* - öbrige Datenbytes                         */
/* ('clutchsize' sind nur die Datenbytes!!)    */
/* ZurÅckgegeben wird der Datenbereich!!       */
/***********************************************/

#include <tos.h>

#include "clutch.h"



#define CL_PREV( a )  ( (VOID*)(((LONG*)a)[0]) )
#define CL_NEXT( a )  ( (VOID*)(((LONG*)a)[1]) )
#define CL_HDRSIZE    8L
#define CL_CHAINS     10


typedef struct
{
	VOID  *first,
	      *query;
} CLUTCH;

WORD   _clchains;

CLUTCH _clchain[CL_CHAINS];

MLOCAL VOID *_CLLastClutch( WORD chain );





/***********************************************/
/* Das Clutchmodul initialisieren              */
/***********************************************/

BOOLEAN CLInitClutch( VOID )
{
	_clchains = 0;

	return( TRUE );
}





/***********************************************/
/* Eine Clutchliste initialisieren             */
/* Ergebnis: Eine ID <> -1                     */
/***********************************************/

WORD CLInitChain( VOID )
{
	if( _clchains >= CL_CHAINS )
		return( -1 );

	_clchain[_clchain].first =
	_clchain[_clchain].query = 0L;

	++_clchains;


	return( _clchains - 1 );
}





/***********************************************/
/* Einen Clutch der Grîûe 'clutchsize'         */
/* anhÑngen                                    */
/***********************************************/

VOID *CLAddClutch( WORD chain, LONG clutchsize )
{
	VOID  *prev, *new;



	/* Die Bytes fÅr die Pointer addieren */
	clutchsize += 2 * sizeof( LONG ) + 1L;


	/* Den letzten Clutch bestimmen */
	prev = _CLLastClutch( chain );


	/* Speicher holen */
	new = Malloc( clutchsize );
	if( !new )
		return( 0L );


	/* Auf gerader Adresse anfangen lassen */
	if( (LONG)new % 2L )
		(LONG)new += 1L;


	/* Verketten */
	if( prev )
		CL_NEXT( prev ) = new;

	CL_PREV( new ) = prev;
	CL_NEXT( new ) = 0L;

	if( !prev )
		_clchain[chain].first = new;



	return( (VOID*)((LONG)new + CL_HDRSIZE) );
}





/***********************************************/
/* Einen Clutch lîschen                        */
/***********************************************/

BOOLEAN CLClearClutch( VOID *clutch )
{
	WORD  chain;
	VOID  *c;



	/* Den wirklichen Beginn des Clutchs
	   ermitteln */
	(LONG)clutch -= CL_HDRSIZE;



	for( chain = 0; chain < _clchains; chain++ )
		/* Wenn kein Clutch da ist,
		   dann nÑchste Kette */
		if( (c = _clchain[chain].first) != 0L )
		{
			/* Den Clutch suchen */
			while( CL_NEXT( c ) && ( c != clutch ) )
				c = CL_NEXT( c );

			if( c == clutch )
			{
				/* Jetzt die Verkettung lîsen */
				if( c == _clchain[chain].first )
					_clchain[chain].first = CL_NEXT( c );

				if( CL_NEXT( c ) )
					CL_PREV( CL_NEXT( c ) ) = CL_PREV( c );

				if( CL_PREV( c ) )
					CL_NEXT( CL_PREV( c ) ) = CL_NEXT( c );

				/* Und den Speicher freigeben */
				Mfree( c );

				return( TRUE );
			}
		}


	return( FALSE );
}





/***********************************************/
/* Alle Clutches lîschen                       */
/***********************************************/
VOID CLClearAllClutches( VOID )
{
	WORD  chain;
	VOID  *c, *d;


	for( chain = 0; chain < _clchains; chain++ )
	{
		c = _clchain[chain].first;

		while( c )
		{
			d = CL_NEXT( c );
			Mfree( c );
			c = d;
		}
	}
}





/***********************************************/
/* Den ersten Clutch erfragen                  */
/***********************************************/

VOID *CLGetFirstClutch( WORD chain )
{
	VOID  *query;


	query                 =
	_clchain[chain].query =
	    _clchain[chain].first;

	if( query )
		return((VOID*)((LONG)query+CL_HDRSIZE));
	else
		return( 0L );
}





/***********************************************/
/* Den folgenden Clutch erfragen               */
/***********************************************/

VOID *CLGetNextClutch( WORD chain )
{
	VOID  **query, *c;


	query = &_clchain[chain].query;

	if( !(*query) )
		return( 0L );

	c = CL_NEXT( *query );

	if( c )
		*query = c;


	if( c )
		return( (VOID*)((LONG)c + CL_HDRSIZE) );
	else
		return( 0L );
}





/***********************************************/
/* Lokale Funktion                             */
/***********************************************/

VOID *_CLLastClutch( WORD chain )
{
	VOID *c;


	c = _clchain[chain].first;


	/* Die Liste durchgehen */
	if( c )
		while( CL_NEXT( c ) )
			c = CL_NEXT( c );


	return( c );
}