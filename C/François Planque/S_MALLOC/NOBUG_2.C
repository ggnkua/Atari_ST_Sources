/*
 * Programme d‚buggu‚ 
 * 2Šre solution... mais pas parfaite, voir le r‚sultat du printf!
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "S_MALLOC.H"

typedef
	struct
	{
		int	n_len;
		char	Tc_car[];		/* Sans le \0 final */
	}
	CHAINE;

void main( void )
{
	char   * psz  = "ST Mag, c'est pas pour les enfants :-)";
	CHAINE * p_chaine;
	
	/* On ne peut pas faire de sizeof( CHAINE ) ! */
	p_chaine = MALLOC( sizeof(int) + strlen( psz ));
	p_chaine -> n_len = (int) strlen( psz );
	strncpy( p_chaine -> Tc_car, psz, p_chaine -> n_len );	/* Ne copie le pas le \0 final */
	
	printf( "\nJe dis: \"%s\" et voil…!\n", p_chaine -> Tc_car );

	FREE( p_chaine );

}