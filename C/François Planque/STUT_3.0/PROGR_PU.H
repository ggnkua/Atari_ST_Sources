/* 
 * ProgressIndocator_Public.h 
 */

	void	init_progress( void );
	extern	long	start_progress( 
							const char *	title, 
							const char *	info, 
							long 				prog_length,
							long				l_MinBlockSize,	/* In: Taille de bloc minimale qu'on accepte */
							BOOL				b_DontManageEnv );	/* In: True si il ne faut pas g‚rer l'environnent, par ex si on a d‚j… un dialogue ouvert … l'‚cran */
	extern	long	update_progress( long prog_done );
	void	end_progress(
			OBJECT	*	pObj_BackgrdForm );	/* In: Arbe … afficher en fond */
