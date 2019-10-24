/*
 * DataGrps.c
 *
 * Purpose:
 * --------
 *	Gestion des unit‚s de "disque" virtuelles
 *
 * History:
 * --------
 * fplanque: Created
 */

 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DATAGRPS.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>				/* header standard */
	#include	<stdlib.h>				/* header librairie de fnct std */
	#include <string.h>				/* Strlen... */
	#include	<ext.h>					/* MAXPATH... */
   

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
	#include "OBJCT_PU.H"
	#include "FILES_PU.H"

	/*
	 * Treeedit
	 */
	void	efface_arbodir( DATADIR *datadir );


   
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
 * ---------------------------- METHODES ------------------------------
 */

/*
 * DataGrp_Reset(-)
 *
 * Purpose:
 * --------
 * Efface toutes les donn‚es d'un DATAGROUP
 * et le remet en SSTATE_EMPTY
 *
 * History:
 * --------
 * 26.12.94: fplanque: Extracted from mouvement(); nombreuses optimisations
 */
BOOL	DataGrp_Reset(						/* Out: != FALSE si on a effectu‚ le reset */
			DATAGROUP *	pDataGroup )	/* In:  DataGroup */
{
	/* 
	 * Etat du groupe: 
	 */
	SSTATE	sstate_dgrp	= dataGroup_getSavState( pDataGroup );

	static char	*	conf1 ="[2][|  EFFACER toutes les|  PAGES-CRAN de la|  m‚moire?][Confirmer|Annuler]";
	static char	*	conf2 ="[2][ATTENTION: en EFFA€ANT,|toutes les modifications|en cours sur les PAGES-|CRAN en m‚moire vont ˆtre|irr‚m‚diablement perdues!][Confirmer|Annuler]";
	char			*	replace;	/* Chaine de remplacement */
	int				resultat = 0;

	/* 
	 * Selon state: 
	 */	
	switch( sstate_dgrp )
	{
		case SSTATE_MODIFIED:
			/*
			 * Adapte texte au type de donn‚es: 
			 */
			switch( pDataGroup -> DataType )
			{
				case	DTYP_ARBO:
					replace = "'ARBO      |en m‚moire vont ˆtre    ";
					break;
					
				case	DTYP_PAGES:
					replace = "es PAGES-|CRAN en m‚moire vont ˆtre";
					break;
					
				case	DTYP_DATAS:
					replace = "es DONNES |en m‚moire vont ˆtre    ";
					break;

				case	DTYP_TEXTS:
					replace = "es TEXTES  |en m‚moire vont ˆtre    ";
					break;

				case	DTYP_PICS:
					replace = "es IMAGES  |en m‚moire vont ˆtre    ";
					break;
			}
			memcpy( conf2 + 67, replace, 36);

			/*
			 * Demande confirmation: 
			 */
			resultat=form_alert( 2, conf2 );
			break;

		case SSTATE_SAVED:
			/*
			 * Adapte texte au type de donn‚es: 
			 */
			switch( pDataGroup -> DataType )
			{
				case	DTYP_ARBO:
					replace = "te     |  l'ARBO de la     ";
					break;
					
				case	DTYP_PAGES:
					replace = "tes les|  PAGES-CRAN de la";
					break;
					
				case	DTYP_DATAS:
					replace = "tes les|  DONNES de la    ";
					break;
					
				case	DTYP_TEXTS:
					replace = "s les  |  TEXTES de la     ";
					break;
					
				case	DTYP_PICS:
					replace = "tes les|  IMAGES de la     ";
					break;
			}
			memcpy( conf1 + 18, replace , 27);

			/*
			 * Demande confirmation: 
			 */
			resultat=form_alert( 1, conf1 );
			break;
	}
					
	if( resultat == 1 )
	{
		if( efface_datas( pDataGroup ) )
		{	/*
			 * Si on a supprim‚ 
			 */
			return	TRUE_1;
		}
	}
	
	return	FALSE0;
}


/*
 * sauve_DataGroup(-)
 *
 * Purpose:
 * --------
 * Sauve un DATAGROUP dans son
 * fichier de pages-arbo/‚cran/textes/images
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: fplanque: Gestop, textes & images
 * 02.09.94: support des fichiers de pages vid‚otex
 */
int	sauve_DataGroup(  					/* Out: Indique si la sauvegarde s'est correctement effectuée */
			DATAGROUP	*curr_datagroup )	/* In: DATAGROUP … s‚rialiser */
{
	DATADIR	*datadir = curr_datagroup -> root_dir;	/* Dir ppal du datagroup */
	int		save_ok = 0;				 	/* Sauvegarde OK */
	FTA		fta;								/* File Transfer Area */

	/*
	 *	Fixe FTA sur DATADIR … sauver: 
	 */
	fta .datadir = datadir;

	/*
	 * Fixe le chemin de s‚lection du prochain fichier sur disque: 
	 */
	recall_filepath( curr_datagroup );

	/*
	 * Sauvegarde des donn‚es: 
	 */
	switch( curr_datagroup -> DataType )
	{
		case	DTYP_ARBO: 
			save_ok = save_file( "Sauver l'arborescence", FS_ARBO, &fta );
			break;

		case	DTYP_PAGES:
			save_ok = save_file( "Sauver les pages ‚cran", FS_PAGES_ECRAN, &fta );
			break;
		
		case	DTYP_DATAS:
			save_ok = save_file( "Sauver les bases de donn‚es", FS_DATAS, &fta );
			break;
		
		case	DTYP_TEXTS:
			save_ok = save_file( "Sauver les textes", FS_TEXTES, &fta );
			break;

		case	DTYP_PICS:
			save_ok = save_file( "Sauver les images", FS_IMAGES, &fta );
			break;
		
		default:
			signale("Sauvegarde impossible!");
			/* printf("type=%d\n",curr_datagroup -> type); */
	}
			
	/*
	 * Mise … jour des fenˆtres et des infos de la zone de donn‚es: 
	 */
	if ( save_ok )
	{	/*
		 * Si la sauvegarde s'est correctement effectu‚e: 
		 * Status mise … jour: 
		 */
		dataGroup_setSaved( curr_datagroup );

		/*
		 * M‚mo nom du fichier: 
		 */
		if ( save_ok == 2 )
		{
			update_datagroup_filename( curr_datagroup );
		}
	}

	return	save_ok;

}



/*
 * get_serv_state(-)
 *
 * Purpose:
 * --------
 * Retourne info sur le contenu de tous les Datagroups du serveur
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 08.08.94: retourne un SSTATE
 */
SSTATE	get_ServSState( void ) 	/* Out: SSTATE global...*/
{
	/*
	 * Variables: 
	 */
	int			plein   = FALSE0;	/* A priori, aucun groupe plein */
	int			modifie = FALSE0;	/* A priori, aucun groupe modifi‚ */
	int			group_no;			/* Num‚ro du groupe en cours de traitement */

	/*
	 * Examine tous les groupes: 
	 */
	for( group_no = 0; group_no < NB_DATAGROUPS; group_no ++ )
	{
		switch( dataGroup_getSavState( &G_datagroups[ group_no ] ) )
		{	/*
			 * Selon l'‚tat du groupe: 
			 */
			case	SSTATE_MODIFIED:
				modifie = TRUE_1;
				break;
				
			case	SSTATE_SAVED:
				plein = TRUE_1;
				break;
		}
	}

	/*
	 * Retourne ‚tat global du serveur: 
	 */
	if ( modifie )
	{
		return	SSTATE_MODIFIED;		/* Modifi‚ */
	}
	else if ( plein )
	{
		return	SSTATE_SAVED;			/* Plein */
	}
		
	return	SSTATE_EMPTY;				/* Vide */
}



/*
 * dataGroup_getSavState(-)
 *
 * Purpose:
 * --------
 * Retourne Information sur le contenu d'un datagroup
 *
 * History:
 * --------
 * fplanque: Created
 * 08.08.94: renvoie maintenant un SSTATE, chang‚ nom: get_datastate -> dataGroup_getSavState
 */
SSTATE 	dataGroup_getSavState( 		/* Out: SSTATE correspondant */
				DATAGROUP *datagroup )	/* In: DATAGROUP qui nous int‚resse */
{
	return	dataDir_getSavState( datagroup -> root_dir );
}



/*
 * DataGroups_SaveAll(-)
 *
 * Purpose:
 * --------
 * Sauvegarde de tous les fichiers avec dialogue utilisateur
 *
 * History:
 * --------
 * 02.10.94: fplanque: Created
 */   
void	DataGroups_SaveAll( void )
{
	int				no_group;
	DATAGROUP	*	pDataGroup;

	for( no_group = 0; no_group < NB_DATAGROUPS; no_group ++ )
	{
		pDataGroup = &G_datagroups[ no_group ];
		
		if( dataGroup_getSavState( pDataGroup ) == SSTATE_MODIFIED )
		{	/*
			 * Un groupe a ‚t‚ modifi‚ mais pas sauv‚: 
			 */
			sauve_DataGroup( pDataGroup );
		}
	}
}


/*
 * dataGroup_setSaved(-)
 *
 * Purpose:
 * --------
 * M‚morise le fait que tout le DATAGROUP a ‚t‚ sauv‚
 * Redraw des ic“nes...
 *
 * History:
 * --------
 * 08.08.94: fplanque: Created
 * 02.10.94: enfin impl‚m‚nt‚ la modif statut dir ppal
 */
void dataGroup_setSaved(
			DATAGROUP	*	pDataGroup )	/* In: Datagroup qui a ‚t‚ sauv‚ */
{
	/*
	 * Trouve dir ppal:
	 */
	DATADIR *	pDataDir = pDataGroup -> root_dir;

	/* 
	 * Signale qu'il est sauv‚
	 */
	dataDir_setSavState( pDataDir, SSTATE_SAVED,	TRUE_1 );
}





/*
 * DataGrp_MergeFile(-)
 *
 * Purpose:
 * --------
 * Charge un fichier de DATAPAGEs dans un DATAGROUP
 * (Le contenu pr‚c‚dent du DATAGROUP est conserv‚)
 *
 * Algorythm:
 * ----------  
 * - Init FTA
 * - En fonction du type de données:
 *		Appelle load_file() avec paramŠtres appropri‚s.
 * - Si le chargement s'est effectu‚: UPDATE
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 09.08.94: modif valeur de retour
 */
int	DataGrp_MergeFile( 
			DATAGROUP *curr_datagroup )	/* In: DATAGROUP ds lequel on veut charger */
{
	FTA		fta; 
	DATATYPE	type = curr_datagroup -> DataType;	/* Type de donn‚es … charger */
	int		load_ok;								 		/* Chargement r‚ussi */

	/* 
	 * Fixe infos File Transfer Area: 
	 */
	fta .datadir_ptr = &(curr_datagroup -> root_dir);	/* Adr du Ptr sur Dir ppal du datagroup */

	/* 
	 * Chargement des donn‚es: 
	 */
	switch( type )
	{
		case	DTYP_ARBO:
 			/* 
 			 * Charge une arborescence: 
 			 */
			load_ok = load_file( "Charger l'arborescence", FS_ARBO, &fta );
			break;

		case	DTYP_PAGES: 
 			/*
 			 * Charge une ou plusieurs pages ‚cran: 
 			 */
			load_ok = load_file( "Charger page(s) ‚cran", GF_PAGES_ECRAN, &fta );
			break;

		case	DTYP_DATAS: 
 			/*
 			 * Charge un groupe de bases de donn‚es: 
 			 */
			load_ok = load_file( "Charger base(s) de donn‚es", FS_DATAS, &fta );
			break;

		case	DTYP_TEXTS:
			/*
			 * Charge un ou un groupe de texte(s): 
			 */
			load_ok = load_file( "Charger texte(s)", GF_TEXTES, &fta );
			break;
				
		case	DTYP_PICS:
			/*
			 * Charge une image: 
			 */
			load_ok = load_file( "Charger image(s)", F_IMAGE, &fta );
			break;

		default:
			ping();
	}
		
	/*
	 * Mise … jour des fenˆtres et des infos de la zone de donn‚es: 
	 */
	if( load_ok > 0 )
	{ /* 
	   * Si le chargement s'est correctement effectu‚: 
		* Mise … jour des infos, fenˆtres, ic“ne etc... 
		*/
		update_datagroup_info( curr_datagroup, (load_ok==2)? YES1:NO0 );
		
		return	2;		/* Chargement effectu‚ */
	}
	else			
	{	/* 
	 	 * Si Le chargement ne s'est pas effectu‚: 
		 */
		return	1;		/* Pas de modif */
	}

}




/*
 * update_datagroup_info(-)
 *
 * Purpose:
 * --------
 * Mise … jour des infos d'un datagroup 
 * aprŠs un chargement
 *
 * Algorythm:
 * ----------  
 * - M‚morise nom du fichier charg‚
 * - Raffraichit le contenu des fenˆtres
 * - Met a jour les datastates
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 09.08.94: fplanque: appel … dataDir_setSavState() au lieu de update_datastate... mais ce n'est que provisoire: l'appell … dataDir_setSavState n'est pas r‚cursif vers l'int‚rieur mais vers l'ext‚rieur!!
 */
void	update_datagroup_info( 			/* Out: */
			DATAGROUP *curr_datagroup, /* In: Datagroup ds lequel on a chargé */
			int memo )     				/* In: !=0 s'il faut m‚moriser le nom du fichier qui vient d'être chargé pour sauvegarde ultérieure */
{
	DATADIR * pDataDir = curr_datagroup -> root_dir;

	/* 
	 * Teste s'il faut m‚moriser le nom du fichier: 
	 */
	if( memo )
	{	/* 
		 * Il faut m‚moriser:
		 */
		update_datagroup_filename( curr_datagroup );
	}
		
	/* 
	 * Mise … jour des fenˆtres: 
	 */
	if ( pDataDir -> nb_dirs )
	{	/* 
		 * S'il y a d‚j… des fenˆtres ouvertes sur le dossier concern‚: 
		 */
		if ( curr_datagroup -> DataType == DTYP_ARBO )
		{
			signale("Il ne devrait pas y avoir de fenˆtre arbo ouverte!");
		}
		else
		{
			remplace_dir( pDataDir );
		}
	}

	/* 
	 * Status mise … jour: 
	 */
	if( dataDir_getSavState( pDataDir ) == SSTATE_EMPTY )
	{	/*
		 * Si le dir ‚tait vide avant:
		 * On l'a rempli avec un fichier sauv‚ sur disque:
		 */
		dataDir_setSavState( pDataDir, SSTATE_SAVED, TRUE_1 );
	}
	else
	{	/*
		 * Si le dir contenait d‚j… qque chose:
		 * On l'a modifi‚:
		 */
		dataDir_setSavState( pDataDir, SSTATE_MODIFIED, TRUE_1 );
	}
}
         
         

/*
 * update_datagroup_filename(-)
 *
 * Purpose:
 * --------
 * Met a jour le nom du fichier associ‚ … un datagroup
 *
 * Algorythm:
 * ----------  
 * Efface l'ancien nom, replace par nouveau
 *
 * Suggest:
 * ------
 * Mettre ca dans un fichier de méthodes pour DATAGROUP
 *
 * History:
 * --------
 * date: user: Created
 */
void	update_datagroup_filename( 
			DATAGROUP *datagroup )		/* In: Datagroup concerné */
{
	/* 
	 * Chemin d'accŠs: 
	 */
	if ( datagroup -> filepath != NULL )
	{	/* 
		 * S'il y avait d‚j… un chemin m‚moris‚: 
		 */
		FREE( datagroup -> filepath );		/* On l'efface */
	}
	datagroup -> filepath = STRDUP( G_filepath );	/* Fixe nouveau chemin */

	/* 
	 * Nom du fichier: 
	 */
	strcpy( datagroup -> filename, G_filename );	/* Recopie le nom */

}



/*
 * group_directload(-)
 *
 * Purpose:
 * --------
 * Charge un fichier dont on connait d‚j… le chemin d'accŠs 
 * dans un groupe
 * Appell‚ lors du chargement de la config
 *
 * Algorythm:
 * ----------  
 * Appelle directload_file2() avec les bons parametres
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	group_directload( 
			DATAGROUP *curr_datagroup, /* In: DATAGROUP ds lequel on veut charger */
			int file_type,            	/* In: Type de fichier à charger */
			char *file_access )			/* In: Chemin d'accès au fichier */
{
	FTA	fta; 
	int	load_ok;

	/* 
	 * S‚lectionne l'ic“ne: 
	 */
	modif_icon( G_desk_params_adr, ROOT, curr_datagroup -> icon_no, SELECTED, TAKE_CTRL );

	/* 
	 * Fixe les var globales contenant non et path du fichier: 
	 */
	if( file_access_extract( file_access ) )
	{
		/* Fixe File Transfer Area: */
		fta .datadir_ptr = &(curr_datagroup -> root_dir);	/* Adr du Ptr sur Dir ppal du datagroup */
	
		/* Charge le fichier: */
		load_ok = directload_file2( file_type, &fta, YES1 );
	
		/* Mise … jour des fenˆtres et des infos de la zone de donn‚es: */
		if ( load_ok > 0 )
		{	/*
		  	 * Si le chargement s'est correctement effectu‚: 
			 * Mise … jour des infos, fenˆtres, ic“ne etc... 
			 */
			update_datagroup_info( curr_datagroup, (load_ok==2)? YES1:NO0 );
		}
	}
	else
	{
		signale( "Ligne non valide" );		/* PROVISOIRE */
	}

	/* 
	 * D‚s‚lectionne/R‚affiche l'ic“ne: 
	 */
	modif_icon( G_desk_params_adr, ROOT, curr_datagroup -> icon_no, NORMAL, TAKE_CTRL );

}


/*
 * initialiser(-)
 *
 * Purpose:
 * --------
 * initialisation du serveur: RAZ de tous les DATAGROUPS
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	initialiser( void )
{
	/*
	 * V‚rifie si le serveur a ‚t‚ modifi‚: 
	 */
	int	confirm	  = 0;				/* Confirmation? */

	/*
	 * Selon statut serveur: 
	 */
	switch ( get_ServSState() )
	{
		case	SSTATE_SAVED:
			confirm = form_alert( 2, 
							"[2][|Etes-vous s–r de vouloir|"
								  "INITIALISER le serveur|"
								  "maintenant?]"
								  "[Init.|Annuler]" );
			break;

		case	SSTATE_MODIFIED:
			confirm = form_alert( 2, 
							"[3][ATTENTION: Vous ˆtes sur le|"
							 	 "point d'INITIALISER le serveur|"
							 	 "actuellement en m‚moire alors|"
							 	 "que certaines MODIFICATIONS|"
							 	 "n'ont pas ‚t‚ sauv‚es!]"
							 	 "[Init?|Annuler]" );
			break;
	}

	/*
	 * Si on a confirm‚: 
	 */
	if ( confirm == 1 )
	{	
		init_serv();
	}
}
                              
                              

/*
 * init_serv(-)
 *
 * Purpose:
 * --------
 * Initialisation du serveur:
 * RAZ de tous les DATAGROUPS:
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_serv( void )
{
	/* Variables: */
	int			group_no;
	DATAGROUP *	datagroup;		/* Datagroup en cours de traitement */
	DATADIR	 *	datadir;			/* Dossier ppal */
	DATATYPE		data_type;		/* Type de donn‚es … effacer */

	/* D‚s‚lectionne ic“ne courante: */
	deselect_current();

	/* Initialise tous les groupes, 1 par 1: */
	for ( group_no = 0; group_no < NB_DATAGROUPS; group_no++ )
	{
		/*
		 * Variables: 
		 */
		datagroup = &G_datagroups[ group_no ];	/* Datagroup … traiter */

		/*
		 * S‚lectionne l'ic“ne: 
		 */
		modif_icon( G_desk_params_adr, ROOT, datagroup -> icon_no, SELECTED, TAKE_CTRL );

		/*
		 * Teste si le groupe n'est pas d‚j… vierge: 
		 */
		if( dataGroup_getSavState( datagroup ) )
		{	/*
		    * S'il faut initialiser le groupe: 
			 * Variables: 
			 */
			datadir	 = datagroup -> root_dir;		/* Root */
			data_type  = datagroup -> DataType;
		
			/* 
			 * Initialisation du datagroup: 
			 */
			clearout_datadir( datadir );	/* Vide le dossier ppal */

			/*
			 * Fermeture des fenˆtres: 
			 */
			if ( datadir -> nb_dirs )
			{	/* S'il y a des fenˆtres ouvertes: */
				/* On les ferme: */
				close_datawindows( datadir );
			}

			/*
			 * Effacement du root si n‚cessaire: 
			 */
			if ( data_type == DTYP_ARBO )
			{	/*
			 	 * Si on a ‚ffac‚ l'arbo: 
				 * Effacement du dossier: 
				 */
				efface_arbodir( datadir );
				/*
				 * Datagroup n'a plus de root: 
				 */
				datagroup -> root_dir = NULL;
			}

			/*
			 * Init varibales associ‚es: 
			 */
			init_vars_datagroup( datagroup );

		}

		/*
		 * D‚s‚lectionne/R‚affiche l'ic“ne: 
		 */
		modif_icon( G_desk_params_adr, ROOT, datagroup -> icon_no, NORMAL, TAKE_CTRL );

	}
}



/*
 * efface_datas(-)
 *
 * Purpose:
 * --------
 * Efface un datagroup
 *
 * Algorythm:
 * ----------  
 * - Contr“le si certaines pages du DGroup a effacer
 *   ne sont pas en cours d'‚dition 
 *   Auquel cas on demande confirmation
 * - Efface le DATAGROUP
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	efface_datas(   						/* Out Reporte si on a effacé ou pas */
			DATAGROUP	*curr_datagroup )	/* In: DATAGROUP à effacer */
{
	static	char 	*conf1="[3][|FERMER et ABANDONNER|"
										"toutes les bases de|"
										"donn‚es en cours|"
										"d'DITION?]"
										"[Confirmer|Annuler]";
	char		*replace;		/* Texte sp‚cifique en fnct du type de donn‚es */
	int		resultat;		/* R‚sultat de la confirmation? */

	DATADIR	*	datadir 	 = curr_datagroup -> root_dir;	/* Dir ppal du datagroup */
	DATATYPE		data_type = curr_datagroup -> DataType;

	/* 
	 * Contr“le si certaines pages ne sont pas en cours d'‚dition: 
	 */
	if ( datadir -> nb_edits )
	{	/* S'il y a des donn‚es en cours d'‚dition: */
		/* printf("There are %d windows to close!\n", curr_datagroup -> nb_edits); */
		switch( data_type )
		{
			case	DTYP_ARBO:
				replace = "tes les pages arbo|en cours d'DITION?|     ";
				break;

			case	DTYP_PAGES:
				replace = "tes les pages ‚cran|en cours d'DITION?|    ";
				break;

			case	DTYP_DATAS:
				replace = "tes les bases de|donn‚es en cours|d'DITION?";
				break;
					
			case	DTYP_TEXTS:
				replace = "s les textes|en cours d'DITION?|           ";
				break;

			case	DTYP_PICS:
				replace = "tes les images|en cours d'DITION?|         ";
				break;

		}
		memcpy( conf1 + 29, replace , 44);

		/* 
		 * Affiche alerte: 
		 */
		resultat=form_alert( 2, conf1 );				/* Alerte */
	}
	else	
	{	/* 
		 * Si pas de fen d'‚dition ouverte: 
		 */
		resultat = 1;		/* On peut effacer */
	}

	
	if ( resultat == 1 )
	{	/*
		 * Si on est autoris‚ … effacer le DATAGROUP:
		 * Vide le dossier-root: 
		 */
		clearout_datadir( datadir );

		/*
		 * Mise … jour des fenˆtres et des dossiers: 
		 */
		if ( data_type == DTYP_ARBO )
		{	/*
			 * Si on a ‚ffac‚ l'arbo:
			 * Fermeture des fenˆtres: 
			 */
			if ( datadir -> nb_dirs )
			{	/*
				 * S'il y a des fenˆtres ouvertes:
				 * On les ferme: 
				 */
				close_datawindows( datadir );
			}
	
			/*
			 * Effacement du dossier: 
			 */
			efface_arbodir( datadir );
			/*
			 * Datagroup n'a plus de root: 
			 */
			curr_datagroup -> root_dir = NULL;
		}
		else
		{	/*
			 * Si on a effac‚ un datagroup normal: 
			 */
			if ( datadir -> nb_dirs )
			{	/* 
				 * S'il y a d‚j… des fenˆtres ouvertes: 
				 */
				remplace_dir( datadir );
			}
		}

		/*
		 * Init variables associ‚es: 
		 */
		init_vars_datagroup( curr_datagroup );

		return	1;		/* On a effac‚ */
	}

	return	0;		/* on a PAS effac‚ */		
}



/*
 * init_vars_datagroup(-)
 *
 * Purpose:
 * --------
 * Initialise variables datagroup
 *
 * Notes:
 * ------
 * Appell‚ lors de la construction d'un DATAGROUP
 * Egalement appell‚ lorsque l'on efface le contenu complet d'un DATAGROUP
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 08.08.94: fplanque: vir‚ appel a set_datastate() obsolŠte; du coup on ne signale pas le groupe comme vierge. est-ce fait ailleurs?|
 */
void	init_vars_datagroup( 
			DATAGROUP *datagroup )	/* In: DATAGROUP à initialiser */
{

	/* 
	 * Infos sur Mise … jour de la zone de donn‚es: 
	 */
	/* set_datastate( datagroup, EMPTY ); */

	/*
	 * Supprime nom du fichier associ‚: 
	 */
	datagroup -> filename[0]	= '\0';	/* Pas de fichier associ‚ */
	datagroup -> filepath		= NULL;	/* Pas de r‚pertoire */				

}

