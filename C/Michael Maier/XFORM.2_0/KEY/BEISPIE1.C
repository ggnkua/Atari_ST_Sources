/********************************************

		XFORM_DO.LIBø Version 2.0

		Ω by Michael Maier 1992
			
		  Demoprogramm: BEISPIEL 1

 ------------------------------------------
 
 Dieses Beispiel soll nicht zeigen, was man mit XFORM_DO.LIB so alles
 anstellen kann! Viel mehr soll es Ihnen helfen, XFORM_DO.LIB bei Ihnen
 zum Laufen zu bringen!
 
 Angenommen Sie haben einen anderen Compiler als PureC/TurboC. Dann werden
 Sie schnell feststellen, wenn Sie das Demo hier Åbersetzen lassen, daû
 das Demo nicht lÑuft! Der Grund dafÅr ist die Art der ParameterÅbergabe:
 
 Version	Art der ParameterÅbergabe	Bemerkung
 ---------------------------------------------------------------------
 "PC"		Register und Stack			speziell fÅr Pure C / Turbo C
 "ER"		nur Register				Assembler-Version, EasyRider
 "DR"		nur Stack

 Wer sich nur fÅr die Assembler-Version interessiert, der befindet sich
 zur Zeit in der falschen Datei (ASSDEMO.Q)!
 
 Bevor es aber losgehen kann, muû die GEM-Schnittstelle von XFORM_DO.LIB
 initialisiert werden. Dazu brauchen Sie den Zeiger auf des "global"-Feld
 der GEM-Schnittstelle Ihres Compilers.

 Turbo C/Pure C - Besitzer haben es jetzt leicht, denn die brauchen nichts
 verÑndern!
 
**************************************************************************/
#include <types.h>
#include <stdio.h>
#include <aes.h>
#include <vdi.h>

#include "beispie1.h"

/* nur die wichtigsten Elemente */
typedef struct
{
	MFDB	di_mfdb;
	int		di_flag;
	long	di_length;
} DIAINFO;

int		open_res( char *rscname );
void	clse_res( void );
void	fix_objs( OBJECT *tree );
void	init_xfm( int *global );
void	open_dia( OBJECT *tree, DIAINFO *info, int flag );
void	clse_dia( OBJECT *tree, DIAINFO *info );
int		xform_do( OBJECT *tree, DIAINFO *info, int objekt );

WORD main( VOID )
{
	OBJECT	*tree;
	DIAINFO	info;
	WORD	error;
	WORD	x;

	/* Und hier die GEM-Schnittstelle initialisiert!
	   Andere Compiler, andere Schnittstellen! Deshalb vorher im
	   Handbuch nach schauen, wo sich das "global"-Feld befindet. Wer
	   nichts rechtes findet, probiert doch einmal nur "global" aus:
	   init_xfm( global );
	   oder
	   init_xfm( _global );
	*/

	init_xfm( _GemParBlk.global );

	error = ( ( appl_init() < 0 )? TRUE:FALSE );

	if ( open_res( "BEISPIE1.RSC" ) )
	{
		rsrc_gaddr( R_TREE, DIALOG, &tree );
		form_center( tree, &x, &x, &x, &x );
		fix_objs( tree );

		open_dia( tree, &info, FALSE );
		xform_do( tree, &info, 0 );
		clse_dia( tree, &info );

		clse_res();
	} else error = TRUE;

	appl_exit();

	return( error );
} /* main */