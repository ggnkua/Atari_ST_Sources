/*
 * debug_public.h
 *
 * Purpose:
 * --------
 * Interface publique pour debug
 *
 * History:
 * --------
 * 25.09.94: fplanque: Created
 */

#include "WIN_PU.H"

/*
 * ------------------------- MEMBRES PUBLICS ----------------------------
 */
	/*
	 * Fenˆtre de d‚bugging (texte) 
	 */
	extern WIPARAMS	*	G_debug_window;
	/*
	 * Tampon de g‚n‚ration des messages de debug:
	 */
	extern char Tsz_DebugMsg[];

/*
 * ------------------------------ INLINES -------------------------------
 */

#define	WATCHINT( arg_int )	\
				sprintf( Tsz_DebugMsg, #arg_int "=%d", arg_int );	\
				debug_AddLine( Tsz_DebugMsg )

#define	TRACE0( arg_psz )		\
				strcpy( Tsz_DebugMsg, arg_psz ); 	\
				debug_AddLine( Tsz_DebugMsg )
#define	TRACE1( arg_psz, arg1 )		\
				sprintf( Tsz_DebugMsg, arg_psz, arg1 ); 	\
				debug_AddLine( Tsz_DebugMsg )
#define	TRACE2( arg_psz, arg1, arg2 )		\
				sprintf( Tsz_DebugMsg, arg_psz, arg1, arg2 ); 	\
				debug_AddLine( Tsz_DebugMsg )
#define	TRACE3( arg_psz, arg1, arg2, arg3 )		\
				sprintf( Tsz_DebugMsg, arg_psz, arg1, arg2, arg3 ); 	\
				debug_AddLine( Tsz_DebugMsg )


/*
 * ----------------------- OPERATIONS PUBLIQUES -------------------------
 */

	/*
	 * Constructeur/Initialisation:
	 */
	void	debug_Construct( void );
	
	/*
	 * Cr‚ation des params n‚cessaires… l'aff du log ds une fenetre:
	 */
	int	debug_CreateWinText( 
				TEXT_DRAWPAR * *	ppTextDrawPar );
	
	/*
	 * Aff une ligne ds log avec PING
	 */
	void	signale( 
				const char * inf );		/* In: texte … dupliker et ins‚rer ds Log */

	/*
	 * Aff une ligne ds log
	 */
	void	debug_AddLine( 
				const char * inf );		/* In: texte … dupliker et ins‚rer ds Log */
