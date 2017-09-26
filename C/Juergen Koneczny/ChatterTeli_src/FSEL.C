#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDLIB.H>
#include	<STRING.H>
#include	<stdio.h>

#include	"main.h"
#include	"Fsel.h"

BYTE	*Fsel( BYTE *Path, BYTE *Mask, BYTE *Title, WORD Global[15] )
{
	BYTE	F[256], P[256], *p;
	WORD	Button, r;

	F[0] = 0;
	P[0] = 0;
	if(( p = strrchr( Path, ( int ) '\\' )) == NULL )
		strcpy( F, Path );
	else
	{
		strcpy( F, p + 1 );
		strncpy( P, Path, p - Path + 1 );
		P[ p - Path + 1 ] = 0;
	}
	strcat( P, Mask );

	r = MT_wind_update( END_UPDATE, Global );
	if( MT_fsel_exinput( P, F, &Button, Title, Global ) && Button )
	{
		*( strrchr( P, ( int ) '\\' ) + 1 ) = 0;
		strcat( P, F );
		return( strdup( P ));
	}
	if( r == 1 )
		MT_wind_update( BEG_UPDATE, Global );
	return( NULL );
}