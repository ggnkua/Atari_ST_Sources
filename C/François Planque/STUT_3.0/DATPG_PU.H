/*
 * DataPage_Public.h
 */

	#include "DFSTRUCT.H"

	void	init_datas( void );

	void	sauve_DataPage(
			DATADIR	*	pDataDir,		/* In: Directory dans lequel se trouve la page */
			DATAPAGE	*	pDataPage );		/* In: Page ‚cran … sauver */ 

	extern	void	free_DataBlock( 
							DATABLOCK	*	pDataBlock );	/* In: Ptr sur Databloc … d‚truire */

	DATABLOCK *	create_stdDataBlock( void );	/* Out: Nouveau Databloc */

	extern	DATAPAGE *	create_std_datapage( 			/* Out: Adresse de la nlle DATAPAGE */
									DATATYPE			DataType,   /* In:  Type de donn‚es que contiendra la datapage */
									const char 	*	filename );	/* In:  Nom de la nlle DATAPAGE */
	extern	BOOL dataPage_IsOpen( 				/* Out: !=0 si fen ouverte */
							DATAPAGE	*	pDataPage);	/* In: Datapage concern‚e */
	extern	void dataPage_setOpenBit( 
							DATAPAGE	*	pDataPage,	/* In: Datapage concern‚e */
							BOOL 			b_open );	/* In: !=0 si fen ouverte */
	extern	SSTATE dataPage_getSavState(			/* Out: Satut sauvegarde */
							DATAPAGE	*	pDataPage );	/* In:  Datapage concern‚e */
	extern	void dataPage_setSavState(
							DATAPAGE	*	pDataPage,		/* In: Datapage concern‚e */
							SSTATE 		sstate );		/* In: Etat */
	extern	void dataPage_chgSavState(
							DATAPAGE	*	pDataPage,		/* In: Datapage concern‚e */
							SSTATE 		sstate,			/* In: Etat */
							BOOL			b_GrafUpdateP,	/* In: S'il faut faut r‚afficher les ic“nes de la DATAPAGE */
							BOOL			b_GrafUpdateD);/* In: S'il faut faut r‚afficher les ic“ne des DATADIRS contenant la DATAPAGE */
	extern	DATAPAGE	*	create_newDataPage( 
									char			*	pS_title,		/* In: Titre de la demande */
									DATAGROUP	*	datagroup,		/* In: Datagroup ds lequel on veut cr‚er */
									GRECT	 		*	start_box );	/* In: d‚but effet graphique d'ouverture */
	extern	char * query_newname(  		       			/* Out: Nom entr‚ par l'utilisateur, NULL si annulé */
			GRECT 		*	pGRect_start,		/* In:  D‚but de l'effet graphique d'ouverture */
			const char	*	cpsz_Title, 		/* In:  Titre de la boite de demande */
			const char	*	cpsz_OldName,		/* In:  Ancien nom */
			const char	*	cpsz_OldComment,	/* In:  Ancien Commentaire */
			char			**	ppsz_NewComment,	/* Out: Nouveau commentaire */
			int 				take_ctrl );	 	/* In: TAKE_CTRL s'il faut passer en modal */

	extern	void	dataPg_resetdata( 
							DATAPAGE * datapage );  /* In: DATAPAGE a effacer */
	extern	void	efface_page( 
							DATAPAGE *datapage );
	extern	edit_datapage_comment( 			/* Out: TRUE si modifi‚, FALSE sinon */
			DATAPAGE *	datapage, 				/* In/Out: Page dont on veut ‚diter le commentaire */
			GRECT		*	start_box );			/* In: D‚but effet graphique */
