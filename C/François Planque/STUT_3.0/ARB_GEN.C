/*
 * Arb_Gen.c
 *
 * Fonction g‚n‚rales de traitement d'arho
 *
 * 25.03.95: Created
 */
	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"ARB_GEN.C v1.00 - 03.95"
          
/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<string.h>					/* Memcpy etc... */
	
/*
 * Custom headers:
 */
	#include	"DEF_ARBO.H"

	#include	"SPEC_PU.H"
	#include	"DEBUG_PU.H"	



/*
 * ------------------
 */




/*
 * fnct_spec(-)
 *
 * Purpose:
 * --------
 * Trouve adr des sp‚cification associ‚es … une fonction
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
FNCTSPEC	*fnct_spec( 
				FNCTSPEC *fnctspec, 
				int fnct )
{
	int	i;

	for ( i=0; i<1000; i++ )			/* 1000= anti bug Stupide! */
	{
		if ( fnctspec[ i ] .fnct_no == fnct )
			break;
	};
	if ( i == 1000 )
	{	/* Si pas trouv‚ */
		signale("Fonction iconnue/n");
		return	fnctspec;		/* Renvoie adr 1ere fonction */
	}
	else
	{
		return	&fnctspec[ i ];
	}
}