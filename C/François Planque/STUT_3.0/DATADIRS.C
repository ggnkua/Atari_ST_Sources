/*
 * datadirs.c
 *
 * Purpose:
 * --------
 *	Gestion des "dossiers" virtuels du ramdisque virtuel!
 *
 * History:
 * --------
 * fplanque: Created
 * 09.05.94: fplanque: les fichiers .h pour ressources avaient disparu
 *					lors de l'ajout de commentaires - remis en place.
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"DATADIRS.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>				/* header standard */
	#include <string.h>				/* strcopy */
	#include	<ext.h>					/* MAXPATH... */
	#include <assert.h>
	
	
/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "AESDEF.H" 
	#include	"DEBUG_PU.H"	
	#include "DATPG_PU.H"
	#include "DTDIR_PU.H"
	#include "DATAGRPS.H"
	#include "OBJCT_PU.H"

   
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
 * Public variables: 
 */
	
/*
 * Private variables: 
 */
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * create_emptyDataDir(-)
 *
 * Purpose:
 * --------
 * Cr‚e un DATADIR vide
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 15.07.94: Init des ptrs sur DATAGOUP et DATADIR parent
 */
DATADIR	*	create_EmptyDataDir(						/* Out: Ptr sur directory cr‚‚ */
					DATAGROUP	*	pDataGroup,			/* In:  Groupe dans lequel on cr‚e ce dossier */
					DATADIR		*	pDataDir_parent )	/* In:  Directory parent de celui-ci */
{
	/* 
	 * Cr‚e un emplacement m‚moire pour ce dossier: 
	 */
	DATADIR	*	new_dir = (DATADIR *) MALLOC( sizeof( DATADIR ) );
	DATASTATE	DataState;

	/*
	 * V‚rifie coh‚rence des paramŠtres:
	 */
	if( pDataDir_parent != NULL && pDataDir_parent -> pDataGroup != pDataGroup )
	{
		signale( "Incoh‚rence DATAGROUP lors de la cr‚ation d'un DATADIR" );
	}
	
	/*
	 * Initialise pointeurs et variables du dossier: 
	 */
	new_dir -> pDataGroup	= pDataGroup;	
	new_dir -> pDataDir_parent = pDataDir_parent;

	new_dir -> iconblks		= NULL;		/* Pas d'ic“nes! */

	new_dir -> nb_elts		= 0;			/* Vide */
	new_dir -> data_start	= NULL;		/* Vide */
	new_dir -> data_end		= NULL;		/* Vide */

	/*
	 * Pas d'infos compl‚mentaires:
	 * Ces infos compl‚mentaires ne sont utilis‚es que par les dossiers ARBO
	 */
	new_dir -> dir_spec		= NULL;		

	DataState .b_open			= FALSE0;	/* INUTILISE! */
	DataState .sstate			= SSTATE_EMPTY;	/* tat: VIDE */
	new_dir -> DataState		= DataState;			
	new_dir -> nb_dirs		= 0;			/* Aucune fen DIR ouverte sur ces donn‚es */
	new_dir -> nb_edits		= 0;			/* Aucune fen d'‚dition ouverte sur ces donn‚es */

	/*
	 * Renvoie adresse du dossier vide: 
	 */
	return	new_dir;
}


/*
 * DataDir_Destruct(-)
 *
 * Destruction d'un dtagroup VIDE
 *
 * 16.12.94: fplanque: Created
 * 14.02.95: verified mallocs
 */
void	DataDir_Destruct(
			DATADIR	*	pDataDir )	/* In: Datadir … d‚truire */
{
	assert( pDataDir -> iconblks == NULL );
	assert( pDataDir -> dir_spec == NULL );
	assert( pDataDir -> nb_elts == 0 );
	
	/*
	 * Efface le datagroup:
	 */
	FREE( pDataDir );
}


/*
 * dataDir_getSavState(-)
 *
 * Purpose:
 * --------
 * Indique si le DATADIR a ‚t‚ sauv‚e ou non
 *
 * History:
 * --------
 * 06.08.94: fplanque: Created
 * 08.08.94: gŠre les ptrs NULLs comme des dirs vierges
 */
SSTATE dataDir_getSavState(			/* Out: Satut sauvegarde */
				DATADIR	*	pDataDir )	/* In:  Datadir concern‚ */
{
	if( pDataDir == NULL )
	{	/*
		 * Dans le cas d'un dossier arbo vierge:
		 */
		return	SSTATE_EMPTY;
	}
	else
	{
		return	pDataDir -> DataState .sstate;
	}
}



/*
 * dataDir_setSavState(-)
 *
 * Purpose:
 * --------
 * M‚morise le fait que le DATADIR ait ‚t‚ sauv‚e ou non
 *
 * Suggest:
 * --------
 * Implement recursivity:
 *
 * History:
 * --------
 * 07.08.94: fplanque: Created
 * 02.10.94: en cas de SAVED: applique aux enfants du dir courant
 */
void dataDir_setSavState(
			DATADIR *	pDataDir,		/* In: DATADIR concern‚ */
			SSTATE 		sstate,			/* In: Etat */
			BOOL			b_GrafUpdate )	/* In: S'il faut faut r‚afficher les ic“ne correspondantes... */
{
	if( pDataDir -> DataState .sstate == sstate )
	{	/*
		 * S'Il n'y a rien … changer!
		 */
		return;			/* On ne fera bien sur pas d'Update graphique.. (Time is Money :) */
	}
	
	/*
	 * Modifie ‚tat de la page:
	 */
	pDataDir -> DataState .sstate = sstate;

	/*
	 * Update graphique:
	 */
	if( b_GrafUpdate )
	{
		if( pDataDir -> pDataDir_parent != NULL )
		{
			signale( "Recursive DATADIRs not yet supported" );
		}
		else
		{	/*
			 * Update de l'icone du DATAGROUP:
			 */
			int		n_icone = pDataDir -> pDataGroup -> icon_no;

			/*
			 * Modifie le caractŠre de l'ic“ne:
			 */	
			update_iconChar( &(G_desktop_adr[ n_icone ]), sstate );

			/*
			 * R‚affiche l'ic“ne:
			 */
			redraw_icon( G_desk_params_adr, n_icone, n_icone, TAKE_CTRL );
		}
	}

	/*
	 * Transmissions r‚cursives:
	 */	
	switch( sstate )
	{
		case	SSTATE_MODIFIED:
			/*
			 * A FAIRE: Transmettre recursivement au parent si SSTATE_MODIFIED...
			 */
			break;
			
		case 	SSTATE_SAVED:
		{	/*
			 * On doit transmettre le statut saved … tous les descendants:
			 */
			DATAPAGE * pDataPage;
			
			for(	pDataPage = pDataDir -> data_start;
					pDataPage != NULL;
					pDataPage = pDataPage -> next )
			{	/*
			 	 * Update de la page mais pas de son dir (c'est d‚j… fait ci-dessus)
			 	 */			
				dataPage_chgSavState( pDataPage,	SSTATE_SAVED, TRUE_1, FALSE0 );
			}
		}	
			break;	
	}


}



/*
 * dataDir_UpdatePageIcon(-)
 *
 * Purpose:
 * --------
 * - update du char de l'ic“ne d'aprŠs SSTATE de la page
 * - r‚affiche une Icone de DataPage dans tous les datagroups o— elle
 *   apparait.
 *
 * Suggest:
 * --------
 * Il faut repositionner le formulaire pour chaque fenetre
 * ARBO TREE … redessiner, en effet ces fenetres partagent un seul formulaire
 *
 * History:
 * --------
 * 11.08.94: fplanque: Transfered from dataPage_setSavState()
 */ 
void	dataDir_UpdatePageIcon(
			DATADIR	*	pDataDir,		/* In: Dossier concern‚ */
			DATAPAGE	*	pDataPage )		/* In: DataPage concern‚e */
{
	if ( pDataDir -> nb_dirs > 0 )
	{	/*
		 * Si il y a une/des fenˆtres ouvertes sur ce dossier: 
		 * On va faire une update dans ces fenˆtres: 
		 */
		OBJECT * pObj_Tree;
		int		n_icone;
		
		/*
		 * Trouve 1Šre fenˆtre ou apparait le dossier:
		 */
		WIPARAMS * pWiParams = find_datawindow2( (unsigned long) pDataDir, G_wi_list_adr );
		if( pWiParams == NULL )
		{
			signale( "Impossible de trouver une fenˆtre correspondante" );
			return;
		}		

		/*
		 * Pointeur sur l'arbre d'objets repr‚sentant le directory:
		 */
		pObj_Tree = (pWiParams -> draw_ptr.tree); 

		/*
		 * Cherche la position de l'ic“ne concern‚e:
		 */
		n_icone = find_iconByNamePtr( pObj_Tree, pDataPage -> nom );
		if( n_icone == NIL_1 )
		{
			signale( "Impossible de trouver l'ic“ne correspondante" );
			return;
		}

		/*
		 * Modifie le caractŠre de l'ic“ne:
		 */	
		update_iconChar( &(pObj_Tree[ n_icone ]), dataPage_getSavState( pDataPage ) );

		/*
		 * R‚affiche l'ic“ne dans la fenˆtre courante:
		 */
		redraw_icon( pWiParams, n_icone, n_icone,	TAKE_CTRL );

		/*
		 * On s'occupe maintenant des autres fenˆtres:
		 */
		/* printf( "Nb dirs = %d\n" , pDataDir -> nb_dirs  ); */
		if ( pDataDir -> nb_dirs > 1 )
		{	/*
			 * S'il y a d'autres fenetres ouvertes sur le DATADIR,
			 * nous allons actualiser leur contenu maintenant!
			 * nous allons juste faire un redraw des ic“nes!
			 * En effet la structure des fenˆtres DATADIRS est telle
			 * qu'elles partages toutes les mˆmes ICONBLKS: donc le
			 * caractŠre est d‚j… mis … jour.
			 */
			while( (pWiParams = find_datawindow2( (unsigned long) pDataDir, pWiParams -> next )) != NULL )
			{	/*
				 * Tant qu'on a trouv‚ une fenˆtre ouverte sur ce dir:
				 * Pointeur sur l'arbre d'objets repr‚sentant le directory:
				 */
				pObj_Tree = (pWiParams -> draw_ptr.tree); 
			
				/*
				 * Cherche la position de l'ic“ne concern‚e:
				 */
				n_icone = find_iconByNamePtr( pObj_Tree, pDataPage -> nom );
				if( n_icone == NIL_1 )
				{
					signale( "Impossible de trouver l'ic“ne correspondante" );
					return;
				}

				/*
				 * R‚affiche l'ic“ne dans la fenˆtre courante:
				 */
				redraw_icon( pWiParams, n_icone, n_icone,	TAKE_CTRL );
			
			}
		}
	}
}



/*
 * dataDir_InsertStdDataPg(-)
 *
 * Purpose:
 * --------
 * Cr‚er une nouvelle DATAPAGE
 * portant le nom sp‚cifi‚
 * dans le DATADIR sp‚cifi‚
 * en effa‡ant la page actuelle si elle existe d‚j…!
 *
 * Algorythm:
 * ----------  
 *
 * Suggest:
 * ------
 * Update status modif
 * Demande confirmation de l'‚crasement
 *
 * History:
 * --------
 * 06.07.94: fplanque: Created based on create_newDataPage()
 * 02.09.94: ne prend plus de ptr sur datagroup, slt sur datadir
 */
DATAPAGE	*	dataDir_InsertStdDataPg( 
					const char	*	pS_name,		/* In: Nom de la page … cr‚er */
					DATADIR		*	pDataDir )	/* In: Datadir ds lequel on veut cr‚er */
{
	DATAGROUP *	pDataGroup = pDataDir -> pDataGroup;	/* Datagroup ds lequel on veut cr‚er */
	DATAPAGE	 *	pDataPage;			/* "Page" en cours de cr‚ation */

	/*
	 * Type des donn‚es … stocker ds DATAGROUP/DATAPAGE:
	 */
	DATATYPE DataType = pDataGroup -> DataType;

	/*
	 * V‚rifie que le nom est valide
	 */
	if ( pS_name == NULL )
	{	/*
		 * Nom invalide:
		 */
		ping();
		return NULL;
	 }
	
	/*
	 * Si on a donn‚ un nom valide: 
	 * Teste si la page existe d‚j…:
	 */
	pDataPage = page_adr_bynamecmp( pDataDir, pS_name );
	
	if( pDataPage == NULL )
	{	/*
		 * Page n'existe pas encore:
		 * Cr‚e zone d'info DATAPAGE standard VIDE:INVALIDE
		 * … remplir dŠs le retour de la fonction
		 */
		pDataPage = create_std_datapage( DataType, pS_name );
	
		/* 
		 * Relie la nlle "page" aux autres: 
		 */
		attach_new_data( pDataDir, pDataPage );

	}
	else
	{	/*
	 	 * Page existe d‚j…:
	 	 * On efface son contenu:
	 	 */
		dataPg_resetdata( pDataPage );
	
	}

	return	pDataPage;
}



/*
 * attach_new_data(-)
 *
 * Purpose:
 * --------
 * Relie une nouvelle DATAPAGE aux autres d'un DATADIR
 *
 * Algorythm:
 * ----------  
 * Recherche position … partir de la fin 
 * pour optimiser temps de recherche lors du chargement d'un 
 * fichier o— les pages sont d‚j… dans l'ordre alphab‚tique
 *
 * Suggest:
 * ------
 * Mettre ‡a ds un fichier de m‚thodes
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 15.12.94: ptr de la page vers son datadir
 * 09.04.95: insertion l… o— il faut (gestion alphab‚tique)
 */
void	attach_new_data( 
			DATADIR	*	datadir, 		/* In: DATADIR dans lequel on ajoute une DATAPAGE */
			DATAPAGE *	new_data )   	/* In: DATAPAGE a ajouter */
{
	DATAPAGE * 	pDataPg_Curr = datadir -> data_end;
	DATAPAGE	*	pDataPg_Next = NULL;
	int			n_comp;

	while( pDataPg_Curr != NULL )
	{	/*
		 * Tant qu'on est pas en 1Šre position:
		 */
		n_comp = strcmp( pDataPg_Curr -> nom, new_data -> nom );
	
		if( n_comp == 0 )
		{
			signale( "Nom identiques!");
			break;
		}
		else if( n_comp < 0 )
		{
			break;
		}

		/*
		 * On se d‚place sur la page pr‚c‚dente:
		 */
		pDataPg_Next = pDataPg_Curr;
		pDataPg_Curr = pDataPg_Curr -> prev;
	}	

	/*
	 * Ceci est la derniŠre page: 
	 */

	/*
	 * On fait pointer la page sur son datadir:
	 */
	new_data -> pDataDir = datadir;
			
	/*
	 * Liaison bidirectionnelle entre pageq: 
	 */
	if( pDataPg_Next == NULL )
	{	/*
		 * Si on ajoute … la fin:
		 * (cas fr‚quent lors du chargement) 
		 */
		if( pDataPg_Curr == NULL ) 
		{
			new_data			-> prev = NULL;
			datadir -> data_start  = new_data;
		}
		else
		{
			new_data 		-> prev = pDataPg_Curr;
			pDataPg_Curr	-> next = new_data;
		}
		
		new_data 		-> next = NULL;
		datadir -> data_end	  = new_data;
	}
	else if( pDataPg_Curr == NULL )
	{	/*
		 * Si on ajoute au d‚but du groupe: 
		 */
		new_data			-> prev = NULL;
		datadir -> data_start  = new_data;

		new_data			-> next = pDataPg_Next;
		pDataPg_Next	-> prev = new_data;
	}
	else
	{	/*
		 * Si on ajoute en milieu de groupe:
		 */
		new_data -> prev = pDataPg_Curr;
		pDataPg_Curr -> next = new_data;

		new_data -> next = pDataPg_Next;
		pDataPg_Next -> prev = new_data;
	}

	/*
	 * 1 page en PLUS de celles qui existaient d‚j…: 
	 */
	(datadir -> nb_elts) ++;	

}
 


/*
 * clearout_datadir(-)
 *
 * Purpose:
 * --------
 * Supprime le contenu d'un DATADIR
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 15.07.94: ne prend plus de param 'data_type'
 * 26.12.94: update icone
 */
void	clearout_datadir( 
			DATADIR	*	datadir )	/* In: DATADIR … vider */
{			
	int			i					= 0;
	DATAPAGE		*curr_datapage = datadir -> data_start;	/* Adr 1Šre page en m‚moire */
	DATAPAGE		*next_datapage;
	WIPARAMS		*wi_adr;			/* Fen d'‚dition associ‚ … la page qu'on efface en ce moment */

	/*
	 * Efface les pages: 
	 */
	while ( curr_datapage != NULL )
	{	/*
		 * Tant qu'il y a des pages 
		 */
		next_datapage = curr_datapage -> next;
		i++;
		
		if( dataPage_IsOpen( curr_datapage ) )
		{	/*
		 	 * S'il y a une fenˆtre d'‚dition ouverte: 
		 	 *
			 * Trouve la fenˆtre d'‚dition concern‚e 
			 */
			wi_adr = find_datawindow2( (unsigned long) curr_datapage, G_wi_list_adr );
			if ( wi_adr == NULL )
			{
				ping();				/* ANORMAL! */
			}
			else
			{
				ferme_fenetre( wi_adr, TRUE_1 );	/* Ferme la fenˆtre */
			}
		}

		/*
		 * Efface page: 
		 */
		efface_page( curr_datapage );

		curr_datapage = next_datapage;
	}

	/*
	 * Plus de page: 
	 */
	datadir -> nb_elts		= 0;
	datadir -> data_start	= NULL;
	datadir -> data_end		= NULL;

	/*
	 * Signale que le datadir est vide:
	 */
	dataDir_setSavState( datadir, SSTATE_EMPTY, TRUE_1 );
}


/*
 * efface_1data(-)
 *
 * Purpose:
 * --------
 * Efface 1 DATAPAGE d'un groupe de donn‚es:
 * maj statut sauvegarde datadirs
 *
 * Notes:
 * ------
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 09.08.94: fplanque: chang‚ valeur de retour
 * 06.10.94: fplanque: r‚cup le datagrp directement ds le datadir
 */
BOOL	efface_1data( 						/* Out: FALSE0 si pas modifi‚e */ 
			DATADIR	 *	datadir, 		/* In: DATADIR ds lequel est situé la page */
			DATAPAGE	 *	rm_datapage )	/* In: DATAPAGE à effacer */
{
	DATAGROUP *	datagroup = datadir -> pDataGroup;  /* DATAGROUP ds lequel on travaille */

	static	char	*conf1 ="[2][|EFFACER la base de|donn‚es: 123456789012|de la m‚moire?][Confirmer|Annuler]";
	static	char	*conf2 ="[3][La base de donn‚es: 123456789012|est en cours d'DITION.|Voulez-vous l'FFACER|quand mˆme?][Confirmer|Voir|Annuler]";

	char		*	replace;			/* Remplacement de texte */
	int			pos_nom;				/* Position du nom de la page */
	DATATYPE		type	= datagroup -> DataType;	/* Type de page a effacer */
	int			resultat;			/* Destruction ou pas? */

	DATAPAGE	*	prev_datapage = rm_datapage -> prev;	/* Adr page pr‚c‚dente */
	DATAPAGE	*	next_datapage = rm_datapage -> next;	/* Adr page suivante */
	
	/*
	 * V‚rifie que la page n'est pas en cours d'‚dition: 
	 */
	if ( dataPage_IsOpen( rm_datapage ) )
	{	/* 
	 	 * S'il y a d‚j… une fenˆtre ouverte dessus: 
		 * Demande conf:	
		 * Fixe type: 
		 */
		switch( type )
		{
			case	DTYP_ARBO:
				replace = "La page arbo:                   ";
				pos_nom = 18;
				break;

			case	DTYP_PAGES:
				replace = "La page-‚cran:                  ";
				pos_nom = 19;
				break;

			case	DTYP_DATAS:
				replace = "La base de donn‚es:             ";
				pos_nom = 24;
				break;
				
			case	DTYP_TEXTS:
				replace = "Le texte:                       ";
				pos_nom = 14;
				break;

			case	DTYP_PICS:
				replace = "L'image:                        ";
				pos_nom = 13;
				break;

		}
		memcpy( conf2 + 4, replace , 32);

		/*
		 * Fixe nom: 
		 */
		memcpy( conf2 + pos_nom, rm_datapage -> nom, strlen( rm_datapage -> nom ));	/* Copie nom */

		/*
		 * Affiche alerte: 
		 */
		resultat=form_alert( 2, conf2 );				/* Alerte */

		/*
		 * Selon le r‚sultat: 
		 */
		if( resultat != 3 )		/* Si on a pas annul‚: */
		{	/*
			 * Trouve la fenˆtre d'‚dition concern‚e 
			 */
			WIPARAMS	* wi_adr = find_datawindow2( (unsigned long) rm_datapage, G_wi_list_adr );

			if ( wi_adr == NULL )
				ping();				/* ANORMAL! */
			else
			{
				if ( resultat == 1)
				{	/*
					 * Si on choisi d'effacer le doc: 
					 * On va commencer par fermer la fenˆtre d'‚dition 
					 */
					ferme_fenetre( wi_adr, TRUE_1 );
				}
				else	
				{	/*
					 * Si on veut voir le doc en question: 
					 * On va le monter au 1er Plan: 
					 */
					put_wi_on_top( wi_adr );
				}
			}	
		}
	}
	else		
	{	/*
		 * Si l'elt n'est pas en cours d'‚dition 
		 * Demande conf:	
		 * Fixe type: 
		 */
		switch( type )
		{
			case	DTYP_ARBO:
				replace = "a page   |arbo:                ";
				pos_nom = 30;
				break;

			case	DTYP_PAGES:
				replace = "a page   |‚cran:               ";
				pos_nom = 31;
				break;

			case	DTYP_DATAS:
				replace = "a base de|donn‚es:             ";
				pos_nom = 33;
				break;
				
			case	DTYP_TEXTS:
				replace = "e texte: |                     ";
				pos_nom = 24;
				break;

			case	DTYP_PICS:
				replace = "'image:  |                     ";
				pos_nom = 24;
				break;

		}
		memcpy( conf1 + 14, replace , 31);

		/*
		 * Fixe nom: 
		 */
		memcpy( conf1 + pos_nom, rm_datapage -> nom, strlen( rm_datapage -> nom ));	/* Copie nom */

		/*
		 * Affiche alerte: 
		 */
		resultat=form_alert( 2, conf1 );				/* Alerte */
	}

	if ( resultat != 1 )		
	{	/*
		 * Si on a annul‚ l'effacement 
		 */
		return	FALSE0;				/* Pas de modif (pas d'effacement) */	
	}
	
	
	/* TRACE2( "Gonna erase DataPage: %lu %s", rm_datapage, rm_datapage-> nom ); */
	
	/*
	 * Efface page: 
	 */
	efface_page( rm_datapage );

	/*
	 * Une page de moins: 
	 */
	(datadir -> nb_elts)--;

	/*
	 * Liens: 
	 */
	/* Pr‚c -> Suiv: */
	if ( prev_datapage != NULL )	/* Si on a pas ‚ffac‚ la premiŠre page */
	{
		prev_datapage -> next = next_datapage;
	}
	else	/* Si on a effac‚ la 1Šre page: */
	{
		datadir -> data_start = next_datapage;
	}

	/* Pr‚c <- Suiv: */
	if ( next_datapage != NULL )	/* Si on a pas ‚ffac‚ la derniŠre page */
	{
		next_datapage -> prev = prev_datapage;
	}
	else	/* Si on a effac‚ la derniŠre page: */
	{
		datadir -> data_end = prev_datapage;
	}

	/*
	 * Mise … jour des fenˆtres: 
	 */
	if ( type != DTYP_ARBO )
	{ /*
	 	* Si on est pas sur une page arbo: 
		* On va metre … jour la fenˆtre: 
		* On considŠre qu'il y a au moins 1 fenˆtre ouverte, 
		* Sinon on aurait pas pu effacer...
		*/
		remplace_dir( datadir );
	}

	/*
	 * Status mise … jour: 
	 */
	dataDir_setSavState( datadir, SSTATE_MODIFIED, TRUE_1 );
				
	return	TRUE_1;			/* Modif effectu‚e */

}






/*
 * close_datawindows(-)
 *
 * Purpose:
 * --------
 * Ferme toutes les fenˆtres d'un DATADIR
 *
 * Algorythm:
 * ----------  
 * Parcourt la liste des fenetres a la recherche de celles qui
 * affiche le DATAGROUP en question.
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	close_datawindows( 
			DATADIR *datadir )	/* In: DATADIR dont on veut fermer les fenêtres */
{
	/* PremiŠre fen concern‚e: */
	WIPARAMS	*curr_wi_adr;

	/* printf("Datadir:%lu nb_dirs=%d \n", datadir, datadir -> nb_dirs ); */

	/* Fermeture: */
	while
		(	/* Cherche 1Šre fen concern‚e dans la liste: */
		/* (On cherche toujous la 1ERE car dŠs qu'on en ferme une, elle d‚gage de la liste, la suivante devient alors PREMIERE!) */
		curr_wi_adr = find_datawindow2( (unsigned long) datadir, G_wi_list_adr ),
		curr_wi_adr != NULL
	)
	{	/* Tant qu'on a trouv‚ une fenˆtre … fermer: */
		/*	printf("Adr Fen concern‚e: %lX\n",curr_wi_adr); */

		/* Ferme la fenˆtre: */
		ferme_fenetre( curr_wi_adr, TRUE_1 );

	}
}





/*
 * page_adr_byicno(-)
 *
 * Purpose:
 * --------
 * Trouve l'adresse d'une page en fonction de son no
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 21.09.94: tests d'erreur
 */
DATAPAGE	* page_adr_byicno( 		/* Out: Ptr sur la page trouvée */
				DATADIR* datadir, 	/* In: DATADIR ds lequel se trouve la page */
				int page_no )			/* In: No d'ordre de la page ds le groupe */
{
	DATAPAGE	*page_ptr = datadir -> data_start;	/* Adr 1Šre page */
	int		i;						/* Compteur */
	
	if( page_no < 1 )
	{
		return	NULL;
	}

	for
	(
		i = 1;										/* D‚but en 1 */
		i < page_no;								/* Tant que pas au bon no */
		i++, page_ptr = page_ptr -> next		/* -> Passe … page suivante */
	)
	{
		if( page_ptr == NULL )
		{
			return	NULL;
		}	
	}
	return	page_ptr;

}



/*
 * count_pages(-)
 *
 * Purpose:
 * --------
 * Compte le nombre de pages d'un DATADIR
 *
 * History:
 * --------
 * fplanque: Created
 */
int count_pages( 
		DATADIR *datadir )    /* In: DATADIR dont on veut compter les pages */
{
	DATAPAGE	*page_ptr = datadir -> data_start;	/* Adr 1Šre page */
	int		nb_pages  = 0;			/* Compteur */
	
	while ( page_ptr != NULL )
	{
		nb_pages ++;						/* 1 page de plus */
		page_ptr = page_ptr -> next;	/* Passe sur la page suivante */
	};

	return	nb_pages;

}



/*
 * page_adr_byname(-)
 *
 * Purpose:
 * --------
 * Trouve l'adresse d'une page d'aprŠs son nom
 *
 * Algorythm:
 * ----------  
 * Cette routine compare juste les pointeurs! 
 * (utilis‚e dans l'‚dition arbo) 
 *
 * Notes:
 * ------
 * Ceci est rapide mais dangereux! On peut mal utiliser cette fonction.
 * Une autre ci-dessous, fait une comparaison r‚elle
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
DATAPAGE	* page_adr_byname( 
				DATADIR *datadir, 
				char *name )
{
	DATAPAGE	*page_ptr = datadir -> data_start;	/* Adr 1Šre page */

	/* TRACE2( "Datadir=%lu Page=%s", datadir, name); */

	while ( page_ptr != NULL )
	{
		/* TRACE1( "Found=%s", page_ptr -> nom ); */

	  	if( page_ptr -> nom == name )
	  	{
	  		break;
	  	}

		page_ptr = page_ptr -> next;
	}

	/* TRACE0( "End search" ); */
	if( page_ptr == NULL )
	{
		ping();
		TRACE1( "Page %s non trouv‚e", name );
	}

	return	page_ptr;
}



/*
 * page_adr_bynamecmp(-)
 *
 * Purpose:
 * --------
 * Cette routine, plus lente, 
 * trouvera la page mˆme si on lui fourni
 * une copie du nom, (adr m‚moire diff‚rente)
 *
 * Algorythm:
 * ----------  
 * Cette routine compare donc r‚ellement les 2 chaines nom
 *
 * Notes:
 * ------
 * Voir aussi la fonction qui compare les pointeurs
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
DATAPAGE	* page_adr_bynamecmp( 		/* Out: Ptr sur DATAPAGE, NULL si pas trouv‚ */
					DATADIR		*	datadir, /* In:  DATADIR ds lequel on doit chercher la page */
					const char	*	name )	/* In:  Nom de la page qu'on recherche */
{
	DATAPAGE	*page_ptr = datadir -> data_start;	/* Adr 1Šre page */

	while ( page_ptr != NULL  && strcmp( (page_ptr -> nom), name ) != 0 )
	{
		page_ptr = page_ptr -> next;
	}

	return	page_ptr;
}


/*
 * page_fullpath(-)
 *
 * Purpose:
 * --------
 * Cr‚e le chemin d'accŠs complet … une page
 *
 * Algorythm:
 * ----------  
 * Operations sur chaines de caractŠres:
 *
 * Notes:
 * ------
 *	Cette fonction suppose que la page est dans le root
 *
 * History:
 * --------
 * 1994: fplanque: Created
 * 14.12.94: prend DATADIR en param
 */
char	*	page_fullpath( 
		DATADIR	*	pDataDir,	/* In: DATADIR ds lequel doit se trouver la page */
		char 		*	name )		/* In: Nom de la page */
{
	DATAGROUP	*	pDataGrp = pDataDir -> pDataGroup;
	size_t	length = strlen( pDataGrp -> data_device ) +1 /* le '\' */ 
							+ strlen( name ) + 1; /* Longueur */
	char		*fullpath = (char *) MALLOC( length );

	/* 
	 * Cr‚ation path: 
	 */
	strcpy( fullpath, pDataGrp -> data_device );	/* Copie ROOT */
	strcat( fullpath, "\\" );							/* Ajoute backslash */
	strcat( fullpath, name );							/* Ajoute NOM */

	return	fullpath;
}

char	*	page_fullpath_old( 
		DATAGROUP	*	pDataGrp,	/* In: DATAGROUP ds lequel doit se trouver la page */
		char 		*	name )		/* In: Nom de la page */
{
	size_t	length = strlen( pDataGrp -> data_device ) +1 /* le '\' */ 
							+ strlen( name ) + 1; /* Longueur */
	char		*fullpath = (char *) MALLOC( length );

	/* 
	 * Cr‚ation path: 
	 */
	strcpy( fullpath, pDataGrp -> data_device );	/* Copie ROOT */
	strcat( fullpath, "\\" );							/* Ajoute backslash */
	strcat( fullpath, name );							/* Ajoute NOM */

	return	fullpath;
}

