/*
 * rterrors_pu.h
 *
 * Purpose:
 * --------
 * Interface publique pour rterrors
 *
 * History:
 * --------
 * 26.09.94: fplanque: Created
 */


/*
 * Internal Alert message-type definitions: 
 */
enum
	{
		/* Pour ne pas ˆtre en conflit avec les erreurs systŠme */
		FIRST_CUSTOM_ERROR	=	10000,
		
		/*
		 * Questions/Dialogues:
		 */
		DLG_QUIT,			/* Quitter? */
		DLG_SAVE_QUIT,		/* Sauver avant de Quitter? */
	
		/*
		 * Confirmation des actions utilisateur:
		 */
		DLG_SAVEBEFORECLOSE,	/* Sauver avant de fermer? */
	
		/* 
		 * L'utilisateur s'est plant‚!
		 */
		PERR_IMPOSSIBLE_OP,		/* Op‚ration impossible */
		PERR_NO_FILENAME,			/* Pas de nom de fichier sp‚cifi‚ */
		PERR_INCORRECT_PATH,		/* Chemin incorrect */
	
		/*
		 * ProblŠme de ressources systŠme (m‚moire)
		 */
		NOMEM_OPENDOC,			/* Pas assez de Ram pour ouvrir doc */
		NOMEM_OPENFILE,		/* Pas assez de Ram pour ouvrir doc */
		NOMEM_SAVEDOC,			/* Pas assez de Ram pour sauver doc */
		NOMEM_OPENWIN,			/* Pas assez de mem pour ouvrir fenˆtre*/
		NOMORE_WIN,				/* Plus de fen dispo */
		NOMEM_NEWBUF,			/* Pas assez de Ram pour nouveau buffer */
	
		/*
		 * Format de fichier incorrect
		 */
		QUERY_FILEFORMAT,		/* Fmt de fichier incorrect: tenter autre chose? */
		QUERY_VDTFORMAT,		/* Fmt vdt?*/
	
		BAD_FILEFMT,			/* Format de fichier non reconnu */
		BAD_HEADFMT,			/* Format de header non reconnu */
		BAD_FILEOWN,			/* Fichier n'appartient pas … STUT ONE */
		BAD_CONTENT,			/* Contenu du fichier incorrect */
		UNEXPECTED_FFMT,		/* Fichier probablement alt‚r‚ */
		BAD_VERSION,			/* Mauvais no de version dans champ compatib */

		DISK_CANTCREATEDIR,	/* Ne peux pas cr‚er le dossier */
		DISK_CANTENTERDIR		/* Ne peux pas cr‚er le dossier */
	};

/*
 * ------------------------- MEMBRES PUBLICS ----------------------------
 */

/*
 * ------------------------------ INLINES -------------------------------
 */

/*
 * ----------------------- OPERATIONS PUBLIQUES -------------------------
 */

	/*
	 * Pr‚paration du log d'erreurs pour son affichage en fenetre
	 */
	int	errors_CreateWinText( 						/* Out: OK1 si ouverture OK */
				TEXT_DRAWPAR * *	ppTextDrawPar );	/* In: Ptr sur conteneur des params d'affichage nlle fenetre */

	/*
	 * Param‚trage d'une fenˆtre texte en vue de son ouverture
	 */
	void	errors_OpenLogWin( 
				WIPARAMS 	 *	pWiParams, 			/* In: fenetre concern‚e */
				TEXT_DRAWPAR *	pTextDrawPar );		/* In: Parals d'aff texte */

	/*
	 * Fermeture du log d'erreurs ds fenetre
	 */
	void errors_CloseLogWin(
				WIPARAMS	*	pWiParams_Closed );


	/*
	 *	Enregistrement d'un message d'erreur dans fenetre log
	 */
	void	errorLog_AddLine(
				const char	* cpsz_ErrorMsg );




	void erreur( const char *texte_erreur );
	void erreur_rsrc( void );
	int alert( int type, ... );
