/*
 * DataPage.c
 *
 * Purpose:
 * -------- 
 * DatPage = "Fichier" virtuel ds ramdisque virtuel!
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 08.08.94: fplanque: removed set_datastate(): obsolete
 * 09.08.94: removed update_datastate(): obsolete
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DATAPAGE.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>				/* header standard */
	#include	<stdlib.h>				/* header librairie de fnct std */
	#include <string.h>				/* Strlen... */
	#include	<ext.h>					/* MAXPATH... */
	#include <assert.h>   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"DESK_PU.H"			/* Pour connaitre offset des icones de datas */
	#include	"STUT_ONE.RSC\STUT_3.H"
	#include "AESDEF.H"
	#include	"DEBUG_PU.H"	
	#include "DATPG_PU.H"
	#include "DTDIR_PU.H"
	#include "DATAGRPS.H"
	#include "ARBPG_PU.H"
	#include "ARPAR_PU.H"
	#include "LISTS_PU.H"
	#include "FILES_PU.H"
	#include "OBJCT_PU.H"
	#include "WIN_PU.H"	
	#include "ATREE_PU.H"
	#include	"ARBKEYPU.H"

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * EXTernal prototypes:
 */
	/* 
	 * Extended form_do: 
	 */
	extern	int	ext_form_do( OBJECT *tree, int *startfield );
	/* 
	 * G‚n‚ral: 
	 */
	extern	void	no_selection( void );
	extern	void erreur_rsrc( void );
	/*
	 * dossiers:
	 */
	extern	SSTATE dataDir_getSavState(		/* Out: Satut sauvegarde */
							DATADIR	*	pDataDir );	/* In:  Datadir concern‚ */
	extern	void dataDir_setSavState(
							DATADIR *	pDataDir,			/* In: DATADIR concern‚ */
							SSTATE 		sstate,				/* In: Etat */
							BOOL			b_GrafUpdate );	/* In: S'il faut faut r‚afficher les ic“ne correspondantes... */

   
/*
 * ------------------------ VARIABLES -------------------------
 */
 
    
/*
 * External variables: 
 */
	/* 
	 * Ic“nes: 
	 */
	extern	OBJECT		*G_desktop_adr;		/* Ptr sur arbre bureau */
	extern	WIPARAMS		*G_desk_params_adr;	/* ParamŠtres de la "fenˆtre bureau" */
	/* 
	 * Fenˆtres
	 */
	extern	WIPARAMS		*G_wi_list_adr;	/* Adresse de l'arbre de paramŠtres */
	/* 
	 * Fichiers: 
	 */
	extern	char	G_filename[ 13 ];			/* Nom du fichier … charger ex:TEST.TXT */
	extern	char	G_filepath[ MAXPATH ];	/* Chemin du fichier … charger ex:D\EXEMPLE */
	/* 
	 * Desktop: 
	 */
	extern	DATAGROUP	*	G_datagroups;		/* Pointeur sur tableau de G_datagroups */
	extern	WIPARAMS		*	G_selection_adr;	/* S‚lection courante */

/*
 * Private variables: 
 */
	static OBJECT	*M_pForm_Rename;			/* Ptr sur boite "renommer" */
	static OBJECT	*M_edit_comment;			/* Boite d'‚dition du commentaire */
	static void		init_vars_datagroup( DATAGROUP *datagroup );
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_datas(-)
 *
 * Purpose:
 * --------
 * Initialise le pr‚sent module
 *
 * Notes:
 * ------
 * Procedure a appeller depuis le programme principal
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 20.09.94: fplanque: Ajout‚ form RENAME; corrig‚ bug pour COMMENT
 */
void	init_datas( void )
{
	if (rsrc_gaddr( R_TREE, NAMES,	&M_pForm_Rename ) == 0)
		erreur_rsrc();
		rsrc_color( M_pForm_Rename );		/* Fixe couleurs */

	if (rsrc_gaddr( R_TREE, COMMENT,	&M_edit_comment ) == 0)
		erreur_rsrc();
		rsrc_color( M_edit_comment );		/* Fixe couleurs */

}
                      


/*
 * create_stdDataBlock(-)
 *
 * Purpose:
 * --------
 * Cr‚e une nouveau datablock vide
 *
 * History:
 * --------
 * 19.06.94: Created base on create_std_datapage()
 */
DATABLOCK *	create_stdDataBlock( void )	/* Out: Nouveau Databloc */
{
	/* 
	 * Cr‚e une zone de stockage: 
	 */
	DATABLOCK *	pDataBlock = (DATABLOCK *) MALLOC( sizeof(DATABLOCK) );

	/* 
	 * Initialisation: 
	 */
	pDataBlock -> p_block = NULL;
	pDataBlock -> ul_length = 0;

	return	pDataBlock;	

}
                      
/*
 * free_DataBlock(-)
 *
 * Purpose:
 * --------
 * D‚truit un datablock 
 * et libŠre la m‚moire qu'il occupait
 *
 * History:
 * --------
 * 15.07.94: fplanque: Created 
 */
void	free_DataBlock( 
			DATABLOCK	*	pDataBlock )	/* In: Ptr sur Databloc … d‚truire */
{
	/* 
	 * D‚truit les donn‚es contenues ds datablock: 
	 */
	if( pDataBlock -> p_block != NULL )
	{
		FREE( pDataBlock -> p_block );
	}

	/*
	 * D‚truit le datablock lui-mˆme:
	 */
	FREE( pDataBlock );	

}


                      
/*
 * create_std_datapage(-)
 *
 * Purpose:
 * --------
 * Cr‚e une nlle datapage (Vide!) 
 * avec zone d'info standard (vide)
 * Cette page n'est PAS rattach‚e … un DataDir
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 11.07.94: Initialisation du nouveau membre: DATATYPE
 * 11.07.94: La datapage cr‚e est retourn‚e sous forme de ptr en r‚sultat de la fonction
 * 15.12.94: init des pts se rapportant au DATADIR
 */
DATAPAGE *	create_std_datapage( 			/* Out: Adresse de la nlle DATAPAGE */
					DATATYPE			DataType,   /* In:  Type de donn‚es que contiendra la datapage */
					const char 	*	filename )	/* In:  Nom de la nlle DATAPAGE */
{
	/* 
	 * Cr‚e une zone de stockage: 
	 */
	DATAPAGE *	pDataPage = (DATAPAGE *) MALLOC( sizeof(DATAPAGE) );
	DATASTATE	DataState;

	/*
	 * Pas int‚gr‚e … un DATADIR pour l'instant:
	 */
	pDataPage -> next			= NULL; 
	pDataPage -> prev			= NULL; 
	pDataPage -> pDataDir	= NULL; 

	/*
	 * Fixe type de donn‚es contenues dans la datapage:
	 */
	pDataPage -> DataType = DataType;

	/* 
	 * Fixe nom (Copie le nom du fichier): 
	 */
	strcpy( pDataPage -> nom, filename );

	/* 
	 * pas de donn‚es associ‚es: 
	 */
	pDataPage -> data.x = NULL;

   /* 
    * Fixe commentaire: 
	 * NULL: les appellants font cette assomption!
    */
	pDataPage -> comment = NULL;

   /* 
	 * Statut:
	 */
	DataState .b_open = FALSE0;
	DataState .sstate = SSTATE_EMPTY;
	pDataPage -> DataState = DataState;


	return	pDataPage;
}



/*
 * dataPage_IsOpen(-)
 *
 * Purpose:
 * --------
 * Dit si une fenˆtre est ouverte sur la DATAPAGE en question
 *
 * History:
 * --------
 * 06.08.94: fplanque: Created
 */
BOOL dataPage_IsOpen( 				/* Out: !=0 si fen ouverte */
			DATAPAGE	*	pDataPage)	/* In: Datapage concern‚e */
{
	return	pDataPage -> DataState .b_open;
}



/*
 * dataPage_setOpenBit(-)
 *
 * Purpose:
 * --------
 * M‚morise le fait qu'il y ait une fenˆtre ouverte ou non
 * sur cette DATAPAGE
 *
 * History:
 * --------
 * 06.08.94: fplanque: Created
 */
void dataPage_setOpenBit( 
			DATAPAGE	*	pDataPage,	/* In: Datapage concern‚e */
			BOOL 			b_open )		/* In: !=0 si fen ouverte */
{
	pDataPage -> DataState .b_open = b_open;
}



/*
 * dataPage_getSavState(-)
 *
 * Purpose:
 * --------
 * Indique si la page ait ‚t‚ sauv‚e ou non
 *
 * History:
 * --------
 * 06.08.94: fplanque: Created
 */
SSTATE dataPage_getSavState(			/* Out: Satut sauvegarde */
				DATAPAGE	*	pDataPage )	/* In:  Datapage concern‚e */
{
	return	pDataPage -> DataState .sstate;
}



/*
 * dataPage_setSavState(-)
 *
 * Purpose:
 * --------
 * M‚morise le fait que la page ait ‚t‚ sauv‚e ou non
 * Pas d'update graphique ni de recursion, pour ‡a, il faut appeller dataPage_setSavState()
 *
 * History:
 * --------
 * 06.08.94: fplanque: Created
 * 11.08.94: simplified and moved complex stuff to dataPage_setSavState()
 */
void dataPage_setSavState(
			DATAPAGE	*	pDataPage,		/* In: Datapage concern‚e */
			SSTATE 		sstate )			/* In: Etat */
{
	/*
	 * Modifie ‚tat de la page:
	 */
	pDataPage -> DataState .sstate = sstate;
}



/*
 * dataPage_chgSavState(-)
 *
 * Purpose:
 * --------
 * Change l'‚tat de sauvegarde d'une page. 
 * R‚percute les changement sur la hierachie de dossiers.
 * Peut ‚galement donner lieu … un redraw des ic“nes concern‚es/
 *
 * History:
 * --------
 * 11.08.94: fplanque: Transfered from dataPage_setSavState()
 * 15.12.94: utilise le pDataDir interne de la Datapage
 */
void dataPage_chgSavState(
			DATAPAGE	*	pDataPage,		/* In: Datapage concern‚e */
			SSTATE 		sstate,			/* In: Etat */
			BOOL			b_GrafUpdateP,	/* In: S'il faut faut r‚afficher les ic“nes correspondantes... */
			BOOL			b_GrafUpdateD) /* In: S'il faut faut r‚afficher les ic“ne des DATADIRS contenant la DATAPAGE */
{
	/*
	 * datadir pour les updates d'icones 
	 */	
	DATADIR	*	pDataDir = pDataPage -> pDataDir;
	assert( pDataDir != NULL );

	if( dataPage_getSavState( pDataPage ) == sstate )
	{	/*
		 * Il n'y a rien … changer!
		 */
		return;			/* On ne fera bien sur pas d'Update graphique.. (Time is Money :) */
	}
	
	/*
	 * Modifie ‚tat de la page:
	 */
	dataPage_setSavState( pDataPage, sstate );

	/*
	 * Update graphique:
	 */
	if( b_GrafUpdateP )
	{
		dataDir_UpdatePageIcon( pDataDir, pDataPage );
	}

	/*
	 * Set State des datadirs...
	 */
	if( sstate == SSTATE_MODIFIED && pDataDir != NULL)
	{	/*
		 * Si on a modifi‚ une page:
	 	 * C'est tout le DATAGROUP qui a ‚t‚ modifi‚
		 * Pour commencer, Transmet la n‚cessit‚ de mise … jour au DATADIR:
		 * qui communiquera r‚cursivement … ses parents jusqu'au datagroup
		 */
		dataDir_setSavState( pDataDir, sstate, b_GrafUpdateD );
	}
}



 
/*
 * query_newname(-)
 *
 * Purpose:
 * --------
 * Demande nom d'une nouvelle "page" 
 * par un formulaire AES
 * lorsqu'on la crée
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 22.11.94: complŠtement refait avec form de renommage
 * 14.01.95: gŠre commentaire
 * 19.01.95: retorune NULL si pas de commentaire
 */
char * query_newname(  		       			/* Out: Nom entr‚ par l'utilisateur, NULL si annulé */
			GRECT 		*	pGRect_start,		/* In:  D‚but de l'effet graphique d'ouverture */
			const char	*	cpsz_Title, 		/* In:  Titre de la boite de demande */
			const char	*	cpsz_OldName,		/* In:  Ancien nom */
			const char	*	cpsz_OldComment,	/* In:  Ancien Commentaire */
			char			**	ppsz_NewComment,	/* Out: Nouveau commentaire */
			int 				take_ctrl ) 		/* In:  TAKE_CTRL s'il faut passer en modal */
{
	GRECT		GRect_Form;				/* Boite formulaire */
	int		n_EditObj = NAME_NEW;
	int		n_ExitObj;
	char	*	psz_NewName;			/* Nom du new object: */

	/*
	 * Pour l'instant, on a pas de commentaire … renvoyer:
	 */
	*ppsz_NewComment = NULL;	

	/* 
	 * Initialisations: 
	 */
	dlink_teptext( &M_pForm_Rename[ RENTITLE ], cpsz_Title );

	if( cpsz_OldName == NULL )
	{
		cpsz_OldName = "";
	}
	M_pForm_Rename[ NAME_OLD ] .ob_spec.free_string = (char *) cpsz_OldName;

	if( cpsz_OldComment == NULL )
	{
		cpsz_OldComment = "";
	}
	M_pForm_Rename[ RNOLDCMT ] .ob_spec.free_string = (char *) cpsz_OldComment;

	fix_fmtFtext( M_pForm_Rename, NAME_NEW, cpsz_OldName );

	fix_ftext( M_pForm_Rename, RNNEWCMT, cpsz_OldComment );

	/* 
	 * Ouvre boŒte: 
	 */
	if ( take_ctrl == TAKE_CTRL )
	{	/*
		 * App prend en charge souris 
		 */
		WIND_UPDATE_BEG_MCTRL
	}
		
	open_dialog( M_pForm_Rename, pGRect_start, &GRect_Form );

	/*
	 * Gestion de la boŒte:
	 */
	do
	{
		n_ExitObj = ext_form_do( M_pForm_Rename, &n_EditObj );	

		if( n_ExitObj == NAMEVAL )
		{	/*
			 * On a valid‚:
			 * Extrait nom du fichier:
			 */
			psz_NewName = extract_fmtFtext( M_pForm_Rename, NAME_NEW );
			*ppsz_NewComment = extract_ftext( M_pForm_Rename, RNNEWCMT);	
			
			if( psz_NewName[0] == '\0' )
			{	/*
				 * On ne peut confirmer un nom vide! 
				 */
				form_alert(1,"[1][|Vous n'avez pas|"
										"indiqu‚ de nom!]"
										"[Recommencer]");
				objc_dsel( M_pForm_Rename, NAMEVAL );	/* D‚s‚lectionne bouton */
				free_String( psz_NewName );
				free_String( *ppsz_NewComment );
				n_ExitObj = NIL;
			}
			else if( strcmp( psz_NewName, cpsz_OldName ) == 0 
					&& strcmp( *ppsz_NewComment, cpsz_OldComment ) == 0 )
			{	/*
				 * Noms identiques:
				 */
				form_alert(1,"[1][|Ancien et nouveau|"
										"noms sont identiques!]"
										"[Recommencer]");
				objc_dsel( M_pForm_Rename, NAMEVAL );	/* D‚s‚lectionne bouton */
				free_String( psz_NewName );
				free_String( *ppsz_NewComment );
				n_ExitObj = NIL;
			}
			
		}
	} while ( n_ExitObj != NAMEVAL && n_ExitObj != NAMEANN );


	/* 
	 * Referme boite:
	 */
	close_dialog( M_pForm_Rename, n_ExitObj, pGRect_start, &GRect_Form );

	if ( take_ctrl == TAKE_CTRL )
	{
		/* App prend en charge souris */
		WIND_UPDATE_END_MCTRL
	}
	
	if ( n_ExitObj == NAMEVAL )
	{	/*
		 * On a valid‚:
		 */ 
		if( strlen( *ppsz_NewComment ) == 0 )
		{	/*
			 * Pas de commentaire:
			 */
			FREE( *ppsz_NewComment );
			*ppsz_NewComment = NULL;
		}

		return	psz_NewName;		/* Retourne adr du nouveau nom */
	}

	/*
	 * On a annul‚ 
	 */
	free_String( *ppsz_NewComment );
	*ppsz_NewComment = NULL;

	return	NULL;		

}



/*
 * renommer_selection(-)
 *
 * Purpose:
 * --------
 * Renommer le fichier s‚lectionn‚ 
 *
 * History:
 * --------
 * 20.09.94: fplanque: cr‚‚ dialog
 * 21.09.94: impl‚ment‚ actions
 * 22.11.94: appelle Query_newname
 * 14.01.95: gŠre commentaire
 */
void	renommer_selection(
				GRECT		*	pGRect_start )		/* In: d‚but effet graphique d'ouverture */
{
	char		*	psz_DataName;
	char		*	psz_NewName;
	char		*	psz_NewComment;
	DATADIR	*	pDataDir;
	DATAPAGE	*	pDataPage;

	/*
	 * V‚rifie que la s‚lection est ok:
	 */
	if( G_selection_adr == NULL 
		|| ( G_selection_adr -> type != TYP_TREE && G_selection_adr -> type != TYP_DIR ) )
	{
		return;
	}

	/*
	 * Cherche ptr sur page s‚lectionn‚e:
	 * d'aprŠs nom de l'ic“ne s‚lectionn‚e
	 */
	pDataDir 		= G_selection_adr -> datadir;
	psz_DataName	= ((G_selection_adr -> draw_ptr.tree)[G_selection_adr -> selected_icon] .ob_spec.iconblk) -> ib_ptext;
	pDataPage		= page_adr_byname( pDataDir, psz_DataName ); 

	if( pDataPage == NULL )
	{
		ping();
		return;
	}


	/*
	 * Demande le nouveau nom:
	 */
	psz_NewName = query_newname( pGRect_start, "RENOMMER UN OBJET", pDataPage -> nom, pDataPage -> comment, &psz_NewComment, TAKE_CTRL );


	/*
	 * Changement du nom:
	 */
	if( psz_NewName != NULL )
	{
		/*
		 * Change nom dans la page:
		 */
		strcpy( pDataPage -> nom, psz_NewName );
		FREE( psz_NewName );

		/*
		 * Change commentaire de la page:
		 */
		free_String( pDataPage -> comment );
		pDataPage -> comment = psz_NewComment;

		/*
		 * Mise … jour status sauvegarde: 
		 */
		dataPage_chgSavState( pDataPage, SSTATE_MODIFIED, FALSE0, TRUE_1 );

		/*
		 * Le texte des ic“nes d'une fenˆtre … l'‚cran 
		 * pointe directement dans les DATAPAGES.
		 * Un simple REDRAW suffit donc … actualiser les ic“nes impliqu‚es
		 */
		dataDir_UpdatePageIcon( pDataDir, pDataPage );
		
	}
}




/*
 * create_newDataPage(-)
 *
 * Purpose:
 * --------
 * Cr‚er une nouvelle DATAPAGE dans le DATAGROUP sp‚cifi‚
 * en demandant le nom … l'utilisateur
 *
 * History:
 * --------
 * 18.06.94: fplanque: Created based on creer_rubrique()
 * 06.07.94: utilise maintenant dataGrp_CreatEmptyDataPg();
 * 09.08.94: appel … update_datagroup_info() remplac‚ par dataPage_setSavState()
 * 11.08.94: chgt des updates SSTATE
 * 22.11.94: efface newname obtenu par query_newname()
 * 14.01.95: gŠre commentaires
 */
DATAPAGE	*	create_newDataPage( 
					char			*	pS_title,		/* In: Titre de la demande */
					DATAGROUP	*	datagroup,		/* In: Datagroup ds lequel on veut cr‚er */
					GRECT	 		*	start_box )		/* In: d‚but effet graphique d'ouverture */
{
	/* 
	 * Demande nouveau nom: 
	 */
	char * pMsz_NewComment;
	char * newname = query_newname( start_box, pS_title, NULL, NULL, &pMsz_NewComment, TAKE_CTRL );

	if( newname == NULL )
	{
		return	NULL;
	}
	else
	{	/* 
		 * Si on a donn‚ un nom valide: 
		 * Variables: 
		 */
		DATADIR *	datadir = datagroup -> root_dir;

		/* 
		 * Cr‚e zone d'info DATAPAGE standard VIDE:INVALIDE
		 * … remplir dŠs le retour de la fonction
		 */
		DATAPAGE *	datapage = dataDir_InsertStdDataPg( newname, datadir );
		FREE( newname );

		datapage -> comment = pMsz_NewComment;

		/*
		 * Mise … jour des fenˆtres et des infos de la zone de donn‚es: 
		 */
		dataPage_chgSavState( datapage, SSTATE_MODIFIED, FALSE0, TRUE_1 );
		remplace_dir( datadir );

		return	datapage;
	}
	
}



/*
 * sauve_DataPage(-)
 *
 * Purpose:
 * --------
 * Front end … appeller pour
 * sauver une DataPage dans un fichier ind‚pendant sur disque 
 *
 * Notes:
 * ------
 * La sauvegarde des pages arbo n'est pas encore impl‚ment‚e
 *
 * History:
 * --------
 * 29.07.94: fplanque: Created
 */
void	sauve_DataPage(
			DATADIR	*	pDataDir,		/* In: Directory dans lequel se trouve la page */
			DATAPAGE	*	pDataPage )		/* In: Page ‚cran … sauver */ 
{
	int	save_ok;				/* Sauvegarde OK ? */
	FTA	fta;					/* File Transfer Area */

	/*
	 *	Fixe FTA sur DATAPAGE … sauver: 
	 */
	fta .pDataPage = pDataPage;

	/*
	 * Fixe le chemin de s‚lection du prochain fichier sur disque: 
	 */
	set_DtPgFilePathToFS( pDataPage );

	/*
	 * Sauvegarde des donn‚es: 
	 */
	switch( pDataPage -> DataType )
	{
		case	DTYP_ARBO:
 			/* 
 			 * Sauver une page Arbo: 
 			 */
			save_ok = save_file( "Sauver une page Arbo *.ARB", FS_ARB, &fta );
			break;

		case	DTYP_PAGES:
			/*
			 * Sauver une page Ecran: 
			 */
			save_ok = save_file( "Sauver une page Ecran *.VDT", F_VDT, &fta );
			break;

		case	DTYP_DATAS:
			/*
			 * Sauver une base de donn‚es: 
			 */
			save_ok = save_file( "Sauver une base de donn‚es *.DXF", FS_DXF, &fta );
			break;
		
		case	DTYP_TEXTS:
			/*
			 * Sauver un Texte: 
			 */
			save_ok = save_file( "Sauver un Texte *.TXT", F_TEXTE, &fta );
			break;

		case	DTYP_PICS:
			/*
			 * Sauver une Image: 
			 */
			save_ok = save_file( "Sauver une Image *.PI3", F_IMAGE, &fta );
			break;
		
		default:
			signale("Sauvegarde impossible!");
	}

	FAKE_USE( pDataDir );
	FAKE_USE( save_ok );
	
}





/*
 * dataPg_resetdata(-)
 *
 * Purpose:
 * --------
 * Initialise les donn‚es contenues dans une datapage
 *
 * Suggest:
 * --------
 * Mettre ‡a ds les m‚thodes s'appliquant … DATAPAGE
 * traiter l'init d'un DTYP_DATAS
 *
 * History:
 * --------
 * 06.07.94: fplanque: Created based on efface_page()
 * 06.07.94: aprŠs effacement, le reset laisse la page ds un etat r‚utilisable (si on y met de nouvelles donn‚es)
 * 17.07.94: paramŠtre type r‚cup‚r‚ directement DANS la datapage
 */
void	dataPg_resetdata( 
			DATAPAGE * datapage )  /* In: DATAPAGE a effacer */
{
	/*	printf( "Datapage: %lu  type:%d\n", datapage, datapage -> DataType ); */

	/* 
	 * Selon type de page: 
	 */
	switch( datapage -> DataType ) 
	{
		case	DTYP_ARBO:
		{	/*
			 * EFFACE Page arbo: 
			 */
			PAGEARBO *pagearbo = datapage -> data.pagearbo;
		
			/*
			 * LibŠre chemin d'accŠs: 
			 */
			FREE( pagearbo -> chemin );
	
			/*
			 * LibŠre pages-‚cran: 
			 */
			Delete_TextParList( pagearbo -> pages_ecran );
	
			/*
			 * LibŠre les champ de sortie: 
			 */
			Delete_SingleLinkList( pagearbo -> output_fields );
			
			/*
			 * LibŠre les params de liste: 
			 */
			if( pagearbo -> pArboListPars != NULL )
			{
				FREE( pagearbo -> pArboListPars );
			}		
		
			/*
			 * LibŠre les champ de saisie: 
			 */
			Delete_SingleLinkList( pagearbo -> input_fields );
	
			/*
			 * LibŠre liens-arbo: 
			 */
			free_KeyWordList( pagearbo -> p_Events );
	
			/*
			 * LibŠre les paramŠtres sp‚ciaux: 
			 */
			free_specialpar( pagearbo -> fnct_no, &(pagearbo -> special_par) );
	
			/*
			 * LibŠre paramŠtres de la page arbo: 
			 */
			FREE( pagearbo );

			break;
		}

		case	DTYP_PAGES:
		{	/*
			 * Efface donn‚es page ‚cran:
			 */
			free_DataBlock( datapage -> data.dataBlock );
			break;
		}
		
		/* case	DTYP_DATAS: */
		/* … faire */

		case	DTYP_TEXTS:
		{	/*
			 * Efface un texte (compact):
			 */
			free_DataBlock( datapage -> data.dataBlock );
			break;
		}

		case	DTYP_PICS:
			/*
			 * EFFACE une image: 
			 */
			if ( datapage -> data.degaspix != NULL )	/* Si page a des donn‚es */
			{
				FREE( datapage -> data.degaspix );		/* Efface donn‚es page */
			}
			break;
			
		default:
			signale( "Ne peut effectuer reset-datapage()" );
	}
	
	/* 
	 * Proc‚dures communes aux deux types: 
	 * Initialisation: 
	 */
	datapage -> data.x = NULL;		/* Pas de donn‚es pour l'instant */

	/*
	 * Reset commentaire:
    */
	if ( datapage -> comment != NULL )	/* S'il y a un commentaire */
		FREE( datapage -> comment );			/* Efface commentaire */
	datapage -> comment = NULL;

}


/*
 * efface_page(-)
 *
 * Purpose:
 * --------
 * Efface une page arbo, ‚cran, image, texte...
 *
 * Suggest:
 * --------
 * Mettre ‡a ds les m‚thodes s'appliquant … DATAPAGE
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 10.05.94: fplanque: Ajout‚ ttmt ParamŠtres Sp‚cifiques Page Arbo
 * 06.07.94: extraction de dataPg_resetdata();
 * 15.07.94: ne prend plus de paramŠtre 'type'
 */
void	efface_page( 
			DATAPAGE *datapage ) /* In: DATAPAGE a effacer */
{
	/*
	 * Efface donn‚es contenues dans la page:
	 */
	dataPg_resetdata( datapage );

	/*
	 * efface la page elle-mˆme
	 */
	FREE( datapage );				   		/* Efface infos/r‚f page */

}



   
   

/*
 * edit_datapage_comment(-)
 *
 * Purpose:
 * --------
 * Edition du commentaire associé à une 'page'
 *
 * Algorythm:
 * ----------  
 * Dialogue
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	edit_datapage_comment( 		/* Out: TRUE si modifié, FALSE sinon */
			DATAPAGE *	datapage, 	/* In/Out: Page dont on veut éditer le commentaire */
			GRECT		*	start_box )	/* In: Début effet graphique */
{
	/*
	 * Variables: 
	 */
	GRECT				form_box;
	int				edit = CMTETEXT;
	int				exit_obj;

	/*
	 * Fixe nom de la page: 
	 */
	dlink_teptext ( &M_edit_comment[ CMTPAGE ], datapage -> nom );
	/*
	 * Fixe texte d'‚dition: 
	 */
	fix_ftext( M_edit_comment, CMTETEXT, datapage -> comment );
		
	/*vvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	/***  Entr‚e dans un MODE:  ***/

		open_dialog( M_edit_comment, start_box, &form_box );
		
		exit_obj = ext_form_do( M_edit_comment, &edit);	/* Gestion de la boŒte */
		
		close_dialog( M_edit_comment, exit_obj, start_box, &form_box );

	/***  Sortie du MODE:  ***/
	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL
	/*^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	/*
	 * Sauvegarde des modifs: 
	 */
	if ( exit_obj == CMTVALID )
	{	/*
		 * Si on a valid‚: 
		 */
		char	*new_comment = M_edit_comment[ CMTETEXT ] .ob_spec.tedinfo -> te_ptext;

		if ( datapage -> comment != NULL )
		{	/*
			 * S'il existait d‚j… un commentaire: 
			 */
			FREE ( datapage -> comment );		/* Efface ce commentaire */
		}

		/*
		 * M‚morise nouveau commentaire: 
		 */
		if ( new_comment[ 0 ] != '\0' )
		{	/*
			 * Si le commentaire n'est pas vide: 
			 */
			datapage -> comment = STRDUP( new_comment );
		}
		else
		{
			datapage -> comment = NULL;
		}

		return	TRUE_1;
	}

	return	FALSE0;
}
