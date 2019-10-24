/*
 * DataDir_Public.h
 */

	#include "DFSTRUCT.H"

	DATADIR	*create_EmptyDataDir(					/* Out: Ptr sur directory cr‚‚ */
				DATAGROUP	*	pDataGroup,			/* In:  Groupe dans lequel on cr‚e ce dossier */
				DATADIR		*	pDataDir_parent );	/* In:  Directory parent de celui-ci */

	void	DataDir_Destruct(
			DATADIR	*	pDataDir );	/* In: Datadir … d‚truire */

	SSTATE dataDir_getSavState(			/* Out: Satut sauvegarde */
				DATADIR	*	pDataDir );	/* In:  Datadir concern‚ */

	void dataDir_setSavState(
			DATADIR *	pDataDir,		/* In: DATADIR concern‚ */
			SSTATE 		sstate,			/* In: Etat */
			BOOL			b_GrafUpdate );	/* In: S'il faut faut r‚afficher les ic“ne correspondantes... */

	void	dataDir_UpdatePageIcon(
			DATADIR	*	pDataDir,		/* In: Dossier concern‚ */
			DATAPAGE	*	pDataPage );		/* In: DataPage concern‚e */

	DATAPAGE	*	dataDir_InsertStdDataPg( 
					const char	*	pS_name,		/* In: Nom de la page … cr‚er */
					DATADIR		*	pDataDir );	/* In: Datadir ds lequel on veut cr‚er */


	void	attach_new_data( 
			DATADIR	*	datadir, 		/* In: DATADIR dans lequel on ajoute une DATAPAGE */
			DATAPAGE *	new_data );   	/* In: DATAPAGE a ajouter */


	void	clearout_datadir( 
			DATADIR	*datadir );	/* In: DATADIR à vider */

	BOOL	efface_1data( 						/* Out: FALSE0 si pas modifi‚e */ 
			DATADIR	 *	datadir, 		/* In: DATADIR ds lequel est situé la page */
			DATAPAGE	 *	rm_datapage );	/* In: DATAPAGE à effacer */


	void	close_datawindows( 
			DATADIR *datadir );	/* In: DATADIR dont on veut fermer les fenêtres */



	DATAPAGE	* page_adr_byicno( 		/* Out: Ptr sur la page trouvée */
				DATADIR* datadir, 	/* In: DATADIR ds lequel se trouve la page */
				int page_no );			/* In: No d'ordre de la page ds le groupe */

	int count_pages( 
		DATADIR *datadir );   /* In: DATADIR dont on veut compter les pages */


	DATAPAGE	* page_adr_byname( 
				DATADIR *datadir, 
				char *name );


	DATAPAGE	* page_adr_bynamecmp( 		/* Out: Ptr sur DATAPAGE, NULL si pas trouv‚ */
					DATADIR		*	datadir, /* In:  DATADIR ds lequel on doit chercher la page */
					const char	*	name );	/* In:  Nom de la page qu'on recherche */

	char	*	page_fullpath( 
		DATADIR	*	pDataDir,	/* In: DATADIR ds lequel doit se trouver la page */
		char 		*	name );		/* In: Nom de la page */

	char	*	page_fullpath_old( 
		DATAGROUP	*	pDataGrp,	/* In: DATAGROUP ds lequel doit se trouver la page */
		char 		*	name );		/* In: Nom de la page */
