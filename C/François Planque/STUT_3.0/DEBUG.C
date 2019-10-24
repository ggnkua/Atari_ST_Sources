/*
 * debug.c
 *
 * Purpose:
 * --------
 * Routines de debuggage
 * En particulier gestion d'un log ds debug ds une fenetre
 *
 * History:
 * --------
 * 25.09.94: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DEBUG.C v1.00 - 03.95"

/*
 * System headers:
 */
	#include	<stdio.h>
	#include <string.h>   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include	"WIN_PU.H"
	#include	"TEXT_PU.H"
	#include	"DEBUG_PU.H"	




/*
 * ------------------------- MEMBRES PUBLICS ----------------------------
 */
	WIPARAMS	*	G_debug_window = NULL;
	char 			Tsz_DebugMsg[256];

/*
 * ------------------------- MEMBRES PRIVES ----------------------------
 */
	/*
	 * Texte log en ram:
	 */
	TEXTINFO *	M_pTextInfo_Debug;



/*
 * ----------------------- OPERATIONS PRIVEES -------------------------
 */
	/*
	 * Cr‚ation du log texte en RAM
	 * appell‚ par constructeur uniquement
	 */
	void	debug_CreateRamText( void );

 
/*
 * ------------------------ IMPLEMENTATION -------------------------
 */




/*
 * debug_Construct(-)
 *
 * Purpose:
 * --------
 * Construction de "l'Objet" debug
 * init des variables etc..
 *
 * History:
 * --------
 * 25.09.94: fplanque: Created
 */
void	debug_Construct( void )
{
	/*
	 * Cr‚ation du log de debuggage en RAM:
	 * (invisible pour l'instant)
	 */
	debug_CreateRamText();
}



/*
 * create_debugtext(-)
 *
 * Purpose:
 * --------
 * Cr‚ation de l'en-tˆte du texte de debug
 * ainsi que de ses paramŠtres d'affichage
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.09.94: devient fonction ind‚pendante, la mise en fenˆtre s'effectue s‚par‚ment
 */
void	debug_CreateRamText( void )
{
	/*
	 * Cr‚e un texte:
	 */
	M_pTextInfo_Debug = create_TextInfo();

	/*
	 * Cr‚e quelques lignes 
	 */
	text_addLineToEnd( M_pTextInfo_Debug, "Stut One version 3" );
	text_addLineToEnd( M_pTextInfo_Debug, "Copyright (c)1993-94 by Fran‡ois PLANQUE." );
	text_addLineToEnd( M_pTextInfo_Debug, NULL );
	text_addLineToEnd( M_pTextInfo_Debug, "Ready." );

}




/*
 * debug_CreateWinText(-)
 *
 * Purpose:
 * --------
 * Pr‚paration du texte de debug pour son affichage ne fenetre
 * ainsi que de ses paramŠtres d'affichage
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.05.94: fplanque: Le paramŠtre est d‚sormais un TEXT_DRAWPAR
 * 25.09.94: le texte n'est plus cr‚‚ sur place, il a d‚j… ‚t‚ cr‚‚ avant
 */
int	debug_CreateWinText( 
			TEXT_DRAWPAR * *	ppTextDrawPar )
{
	/*
	 * Cr‚e des paramŠtres d'affichages pour ce texte:
	 */
	*ppTextDrawPar = create_TextDrawPar( M_pTextInfo_Debug, 200 );

	if ( *ppTextDrawPar == NULL )
	{
		return	WRONG0;
	}

	return	OK1;
}



/*
 * signale(-)
 *
 * Purpose:
 * --------
 * Signal + Information de debbugging dans la fenˆtre debug
 * ou a d‚faut ds le log invisible
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 25.09.94: fplanque: appelle maintenant debug_AddLine()
 */
void	signale( 
			const char * inf )		/* In: texte … dupliker et ins‚rer ds Log */
{
	ping();
	debug_AddLine( inf );
}



/*
 * debug_AddLine(-)
 *
 * Purpose:
 * --------
 * Information de debbugging dans la fenˆtre debug
 * ou a d‚faut ds le log invisible
 *
 * History:
 * --------
 * 25.09.94: extracted from signale()
 * 25.09.94: ajoute au log invisible si pas de fen ouverte
 */
void	debug_AddLine( 
			const char * inf )		/* In: texte … dupliker et ins‚rer ds Log */
{
	if ( G_debug_window != NULL )
	{	/*
		 * S'il existe une fenˆtre de debug: 
		 */
		add_textinf( G_debug_window, inf );
	}
	else
	{	/*
		 * Pas de fenˆtre debug:
		 * on ajoute qd mˆme au log invisible (pour l'instant)
		 */
		text_addLineToEnd( M_pTextInfo_Debug, inf );
	}
}
