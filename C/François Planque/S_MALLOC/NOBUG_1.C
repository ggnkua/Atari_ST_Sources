/*
 * Programme d‚buggu‚ 
 * 1Šre solution.
 */
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "S_MALLOC.H"

typedef
	struct
	{
		int	n_len;
		char	Tc_car[];		/* Contient le \0 final */
	}
	CHAINE;

void main( void )
{
	char   * psz  = "ST Mag, c'est pas pour les enfants :-)";
	CHAINE * p_chaine;
	
	/* On ne peut pas faire de sizeof( CHAINE ) ! */
	p_chaine = MALLOC( sizeof(int) + strlen( psz ) + 1); /* ne pas oublier le \0 final! */
	p_chaine -> n_len = (int) strlen( psz );
	strcpy( p_chaine -> Tc_car, psz );
	
	printf( "\nJe dis: \"%s\" et voil…!\n", p_chaine -> Tc_car );

	FREE( p_chaine );

}