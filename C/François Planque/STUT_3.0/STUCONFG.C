/*
 * StuConfig.c
 *
 * Purpose:
 * --------
 * Routines de traitement de la configuration globale du programme
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"STUCONFG.C v1.00 - 03.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>
	#include	<stdlib.h>					/* Malloc... */
	#include	<string.h>					/* strcpy() etc.. */
	#include	<aes.h>						/* header AES */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include	"WIN_PU.H"
	#include "STUT_ONE.RSC\STUT_3.H"						/* noms des objets ds le ressource */
	#include	"POPUP_PU.H"					/* Menus pop-up */
	#include "SERV_PU.H"					/* En ce qui concerne les voies */
	#include	"DEBUG_PU.H"	
	#include	"SRIAL_PU.H"	
	#include	"RAMSL_PU.H"	
	#include	"MAIN_PU.H"	
	#include	"FILES_PU.H"	
	#include	"RTERR_PU.H"	





/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * EXTernal prototypes:
 */
	/*
	 * Traitement des objets AES: 
	 */
	extern	void	rsrc_color( OBJECT *tree );
	extern	void	objc_fixsel( 
							OBJECT*	pObj_tree, 	/* In: Arbre dans lequel on agit */
							int 		n_obj,		/* In: Objet sur lequel on agit */
							int		n_state );	/* In: 0=dÇselection, autre selectionne */
	extern	BOOL	objc_testsel( 				/* Out: !=0 si sÇlectionnÇ */
							OBJECT *	pObj_tree, 	/* In: Arbre dans lequel on teste */
							int 		n_obj );		/* In: Objet sur lequel on teste */
	extern	void	objc_setdisable( OBJECT *tree, int obj );
	extern	void	objc_setenable( OBJECT *tree, int obj );
	extern	void	objc_enable( OBJECT *tree, int obj );
	extern	void	objc_disable( OBJECT *tree, int obj );
	extern	void	open_dialog( OBJECT *dialog, const GRECT *little_box, GRECT *big_box );
	extern	void	close_dialog( OBJECT *dialog, int exit_obj, const GRECT *little_box, const GRECT *big_box );
	extern	void	deselect_current( void );
	extern	void	dlink_teptext( OBJECT *objc_adr, const char *texte );
	extern	void	objc_clrsel( OBJECT *tree, int obj );
	extern	GRECT* objc_xywh ( 
								OBJECT *tree, 
								int objc, 
								GRECT *frame );

	/* 
	 * Form_do: 
	 */
	extern	int	ext_form_do( OBJECT *tree, int *startfield );
	/* 
	 * DonnÇes: 
	 */
	extern	void	group_directload( DATAGROUP *curr_datagroup, int file_type, char *file_access );
	extern	SSTATE	get_ServSState( void ); 	/* Out: SSTATE global...*/
	/*
	 * Desktop:
	 */
	extern	DATAGROUP	*	find_datagroup_byType( 		/* Out: Ptr sur datagroup */
										DATATYPE		DataType );	/* In:  Type DTYP_* */

	/* 
	 * Menus Pop-Up:
	 */
	extern	void	fix_popup_title( 
							OBJECT	*popup_title, 	/* In: Objet titre de Menu */
							POPUP_ENTRY *entries, 	/* In: Menu Pop-Up associÇ */
							int current_val );		/* In: Valeur Ö assigner au titre */
	extern	int	popup_inform( 					/* Out: Valeur sÇlectionnÇe */
							OBJECT *call_form, 		/* In:  Formulaire appellant */
							int call_obj, 				/* In:  Objet appellant */
							int title_obj, 			/* In:  No Objet sur lequel le menu va s'aligner (Titre de menu) */
							POPUP_ENTRY *entries, 	/* In:  Menu Pop-Up Ö dÇrouler */
							int current_val );		/* In:  Valeur courante -> recevra checkmark */


/*
 * PRIVate INTernal prototypes:
 */
	static char	*cree_ligne_voie( VOIE *curr_voie );
	static int	affecte_actions( LISTHANDLES *list_handles, int	obj );
	static void	affec_fixstate_act( 					/* Out: Rien */
						LISTHANDLES *list_handles );	/* In: Ptr sur infos sur la liste & le dialogue affichÇs */
	static void	Affecte_ParamsVoie( 
						LISTHANDLES *list_handles, 	/* In: Infos sur liste de voies */
						OBJECT *arbre_fond, 				/* In: Formulaire appellant */
						int call_obj );					/* In: Objet appellant ds ce formulaire */
	static VOIE* find_ParamsVoie_byOrdNo(			/* Out: Ptr sur params voie cherchÇe */
						VOIE *pVoie_Liste, 				/* In:  Ptr sur premiäre voie ds liste */
						int ord );							/* In:  No d'ordre de la voie cherchÇe */
	static void	ajoute_voie( LISTHANDLES *list_handles );
	static void	supprime_voie( 						/* Out: Rien */
			LISTHANDLES *list_handles );				/* In/Out: Paramätres de la liste de sÇlection */



/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * External variables: 
 */
	/* 
	 * GÇnÇral: 
	 */
	extern	char	*G_empty_string;		/* Chaine vide */
	extern	char	*G_tmp_buffer;			/* Peut contenir un texte long de 255 signes + '\0' */
	extern	void	*G_null;					/* Pointeur null */
	extern	char	*G_crlf;					/* Retour Ö la ligne */
	/* 
	 * Vdi: 
	 */
	extern	USERBLK	G_bcroix_ublk;		/* Pour bouton-croix */
	/* 
	 * Datas: 
	 */
	extern	DATAGROUP	*G_datagroups;	/* Pointeur sur tableau de G_datagroups */
	/* 
	 * Icìnes: 
	 */
	extern	WIPARAMS		*G_desk_params_adr;	/* Paramätres de la "fenàtre bureau" */
	/* 
	 * Fichiers: 
	 */
	extern	char	G_stutpath[];	/* Path dans lequel se trouve Stut One */
	extern	char	G_filename[];	/* Nom du fichier Ö charger ex:TEST.TXT */
	extern	char	G_filepath[];	/* Chemin du fichier Ö charger ex:D\EXEMPLE */
	/* 
	 * Serveur: 
	 */
	extern	VOIE	*G_voies;						/* Liste des voies */
	extern	int	G_nb_voies;						/* Nombre de voies */
	extern	char	*G_mode[];						/* Modes de fonctionnement */
	extern	long	G_abrev_mode[];				/* Abreviations modes */
	extern	POPUP_ENTRY	G_Popup_Modes[];		/* Menu Pop-Up sÇlection Mode */
	/* 
	 * Ports sÇrie: 
	 */
	extern	int	G_term_dev;						/* Port utilisÇ par icone terminal ( Sur un STF sans Bconmap: 1,AUX ) */
	extern	POPUP_ENTRY	*G_inst_drv_list;		/* Liste des pÇrifs installÇs pourmenu Popup */
	extern	long	*G_inst_abrev;					/* AbrÇviations pÇrifs installÇs */


/*
 * Public variables: 
 */
	/* 
	 * Type: 
	 */
	int	G_cnf_gest_form_std = FALSE0;	/* Gestion de formulaires Standard */
	int	G_cnf_cope_with_ltf = FALSE0;	/* Contourner les bugs de Let'em Fly */

	
/*
 * Private variables: 
 */
 	/*
 	 * Ptrs sur boåtes de dialogue:
 	 */
	static OBJECT	*M_compatib_adr;		/* Boite de config compatibilitÇ */
	static OBJECT	*M_affect_adr;			/* Boite d'affectation des voies */
	static OBJECT	*M_pForm_ParamsVoie;	/* Formulaire de config d'une voie */
	/* 
	 * Param des voies: 
	 */
	static VOIE				*M_voies_copies;
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * init_config(-)
 *
 * Purpose:
 * --------
 * Init des variables et des boåtes de configuration
 * utilisÇes ds ce module
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_config( void )
{
	/* 
	 * Init RSC: 
	 */
	if ( rsrc_gaddr( R_TREE, COMPATIB, &M_compatib_adr ) == 0 )
		erreur_rsrc();
	rsrc_color( M_compatib_adr );		/* Fixe couleurs */

	if ( rsrc_gaddr( R_TREE, AFFECT, &M_affect_adr ) == 0 )
		erreur_rsrc();
	rsrc_color( M_affect_adr );		/* Fixe couleurs */

	if ( rsrc_gaddr( R_TREE, PARAVOIE, &M_pForm_ParamsVoie ) == 0 )
		erreur_rsrc();
	rsrc_color( M_pForm_ParamsVoie );	/* Fixe couleurs */
}


/*
 * set_compat(-)
 *
 * Purpose:
 * --------
 * RÇglage des paramätres de compatibilitÇ de STUT ONE 
 * avec son environnement:
 * - Gestion des formulaires par le Form_Do std plutìt que Ex_form_do
 * - Coutourner les bugs de Let'Em Fly
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void set_compat( const GRECT *start_box )
{
	int		exit_obj;					/* Objet de sortie */
	GRECT		form_box;					/* Dimensions du formulaire */
	int		edit = 0;					/* Bidon */

	/* 
	 * Fixe flags des boutons: 
	 */
	objc_fixsel( M_compatib_adr, GFORMSTD, G_cnf_gest_form_std );
	objc_fixsel( M_compatib_adr, TESTCOMP, G_cnf_cope_with_ltf );

	/* 
	 * Gestion boåte: 
	 */
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	
	open_dialog( M_compatib_adr, start_box, &form_box );
	
	exit_obj=ext_form_do( M_compatib_adr, &edit);	/* Gestion de la boåte */

	close_dialog( M_compatib_adr, exit_obj, start_box, &form_box );

	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL

	/*
	 * Teste s'il y a eu confirmation: 
	 */
	if ( exit_obj == COMPVALI )
	{	/* 
		 * RÇcupäre Çtat des boutons: 
		 */
		G_cnf_gest_form_std = objc_testsel( M_compatib_adr, GFORMSTD );
		G_cnf_cope_with_ltf = objc_testsel( M_compatib_adr, TESTCOMP );
	}
}



/*
 * ------------------- TRAITEMENT FICHIER .INI --------------------
 */


/*
 * sauver_config_ini(-)
 *
 * Purpose:
 * --------
 * Apräs sÇlection menu:
 * Traite Demande de Sauvegarde configuration dans fichier .INI
 *
 * Algorythm:
 * ----------  
 * Demande conf
 * CrÇe nom du fichier .INI
 * Appele 'sauve()' -> save_inidata
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 03.01.94: fplanque: ChangÇ texte de demande de conf
 */
void	sauver_config_ini( void )
{
	/* 
	 * Demande de confirmation: 
	 */
		int confirm = form_alert(2,
							"[2][Voulez-vous sauver la|"
							    "configuration actuelle de|"
							    "maniäre Ö ce qu'elle soit|"
							    "rechargÇe automatiquement|"
							    "la prochaine fois?]"
							    "[Sauver|Annuler]");

	/* 
	 * Selon rÇponse utilisateur: 
	 */
		if ( confirm == 1 )
		{	/* 
			 * Si on a confirmÇ: 
			 */
			strcpy( G_filepath, G_stutpath );		/* Dans le dossier STUT ONE */
			strcpy( G_filename, "STUT_000.INI" );	/* Nom du Fichier Ö sauver */
			/*	printf("Path=%s  Name=%s \n",  G_filepath, G_filename ); */

			directsave_file( FS_INI, NULL );			/* Sauve la configuration actuelle dans ce fichier */

		}
}


/*
 * save_inidata(-)
 *
 * Purpose:
 * --------
 * Sauvegarde point par point des donnÇes dans les fichier .INI
 *
 * Algorythm:
 * ----------  
 * Sauve:
 * -Conf ports sÇrie
 * -Affectation des voies
 *
 * Notes:
 * ------
 * 
 * Suggest:
 * --------
 * - Faire une fonc indÇpendante pour l'affectation des voies
 * - Inclure les paramätres de compatibilitÇ
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	save_inidata( FILE *fstream )
{
	/* 
	 * Sauve configuration des ports sÇrie:
	 */
	save_serial_ini( fstream );

	/*
	 * Sauve affectation des voies:
	 */
	{
		VOIE	*curr_voie;		/* Voie en cours de traitement */
		int 	dev_offset;		/* Device offset du port affectÇ Ö une voie */

	
		/*
		 * Signale qu'on s'intÇresse ici Ö l'affectation des voies: 
		 */
		fputs( "\r\n[ Affectation des voies: ]\r\n\r\n", fstream );		/* Commentaire */

		/*
		 * Parcourt les ports: 
		 */
		curr_voie = G_voies;
		while( curr_voie != NULL )
		{
			/*
			 * Offset: 
			 */
			/* TRACE2( "Voie %d; device %d", curr_voie -> no_voie, curr_voie -> device ); */
			dev_offset = device_offset( curr_voie -> device );
			
			/*
			 * Sauve no voie: 
			 */
			fprintf( fstream, "VOIE %03d:", curr_voie -> no_voie );
			
			/*
			 * Sauve port affectÇ: 
			 */
			fwrite( &G_inst_abrev[ dev_offset ], sizeof( long ), 1, fstream  );
			fputc( ',', fstream );

			/*
			 * Sauve mode: 
			 */
			fwrite( &G_abrev_mode[ curr_voie -> mode ], sizeof( long ), 1, fstream );

			fprintf( fstream, G_crlf );
							
			/*
			 * Passe Ö la voie suivante: 
			 */
			curr_voie = curr_voie -> next;
		}
	}
}


/*
 * autoload_ini(-)
 *
 * Purpose:
 * --------
 * Chargement automatique de la configuration dans STUT_ver.INI
 * lors du lancement de STUT ONE
 *
 * Algorythm:
 * ----------  
 * -CrÇe path fichier ds dir de lancement 
 * -Appele 'load()' -> load_ini()
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	autoload_ini( void )
{
	/*
	 * Variables: 
	 */
	FTA	fta;		/* File Transfer Area */

	/* 
	 * Fixe le chemin d'accäs et le nom du fichier: 
	 */
	strcpy( G_filepath, G_stutpath );	/* Dans le dossier STUT ONE */
	strcpy( G_filename, "STUT_000.INI" );	/* Nom du Fichier Ö charger */
		
	/*
	 * Charge fichier STUT_ver.INI 
	 */
	directload_file2( FS_INI, &fta, NO0 );		/* Charge slt si le fichier existe */
}


/*
 * load_ini(-)
 *
 * Purpose:
 * --------
 * Chargement des donnÇes pt par pt depuis le fichier .INI:
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	load_ini( FILE *fstream )
{
	char	*	instr;			/* Instruction Ö traiter */
	char	*	object;			/* DonnÇe Ö modifier */
	char	*	data;				/* Contenu Ö charger */
	char	*	separat;			/* SÇparateur de paramätres: */
		/* ATTENTION, ces variables vont en fait pointer dans G_xxx_buffer, ne pas faire de free */

	VOIE	*	voies;			/* (Nouvelle) liste des voies */
	VOIE	**	last_ptr_to_next = &voies;
	VOIE	*	curr_voie;		/* Voie en cours de crÇation: */
	int		device;			/* PÇriph concernÇ */
	long		abrev_mode;		/* Abrev mode de fonctonnement... */
	int		mode;				/* Mode de fonctionnement de la voie courante */
	int		nb_voies = 0;	/* Nbre de voies chargÇes */


	/* 
	 * Contrìle le header:
	 */
	int n_Version = head_control( fstream, FS_INI, "Configuration" );
	
	/*
	 * Contrìle le no de version:
	 */
	switch( n_Version )
	{
		case	0x0000:
			break;
			
		case	ERROR_1:
			/*
			 * Chargement Ö ÇchouÇ dans le header:
			 */
			return;

		default:
			/*
			 * Chargement Ö ÇchouÇ 
			 */
			alert( BAD_VERSION );
			return;
	}

	/*
	 * Si le header est correct: 
	 * Boucle de chargement: 
	 */
	while( !feof( fstream ) )
	{	/*
		 * Tant qu'on est pas Ö la fin du fichier: 
		 * Charge une instruction: 
		 */
		instr = get_config_line( fstream, ':', &object, &data );

		/*
		 * Test de l'instruction Ö traiter: 
		 */
		if ( instr != NULL )
		{	/*
			 * S'il y a une instruction: 
			 */
			if ( strcmp( instr, "PORT" ) == 0 )
			{	/*
			 	 * ---------------------- 
				 * Fixe paramätres sÇrie: 
				 * ---------------------- 
				 */
				serial_ini( object, data );
			}
			else if ( strcmp( instr, "VOIE" ) == 0 )
			{	/*
				 * -----------------------------
				 * Fixe l'affectation des voies:
				 * ----------------------------- 
				 */
				/*	printf("obj=%s dat=%s\n", object, data );	 */

				/*
				 * Recherche virgule: 
				 */
				separat = strchr( data, ',' );

				if ( object == NULL || separat == NULL )
				{
					signale( "Format ligne invalide" );
				}
				else
				{	/* Si on a indiquÇ un numÇro de voie: */
					/* et qu'on a trouvÇ une virgule de sÇparation des paramätres: */
				
					/* PrÇcaution: sÇpare les 2 paramätres: */
					/* On en profite pour faire pointer separat sur le 2äme param */
					*(separat++) = '\0';	
				
					/* Cherche port concernÇ: */
					device = find_device_byabrev( data );
				
					if ( device == NIL )
					{
						signale( "Affectation Voie: Port inconnu" );
					}
					else
					{	/*
						 * Si on a trouvÇ le port concernÇ:
						 * CrÇation de la cnx logique: 
						 */
						curr_voie = Construct_Voie( );
				
						/*
						 * NumÇro de la voie: 
						 */
						curr_voie -> no_voie = atoi( object );

						/*
						 * Port utilisÇ: 
						 */
						curr_voie -> device = device;
						
						/*
						 * CrÇe un Long Int contenant le codename du mode: 
						 */
						abrev_mode =  ( ((unsigned long)separat[0]) <<24) 
										| ( ((unsigned long)separat[1]) <<16)
										| ( ((unsigned long)separat[2]) <<8)
										| ( (unsigned long)separat[3]);

						/*
						 * Cherche mode de fonctionnement: 
						 */
						for ( mode = 0;  mode < NB_VMODES; mode ++ )
						{
							if ( G_abrev_mode[ mode ] == abrev_mode )
							{	/*
								 * Si on a trouvÇ l'abrev correspondante: 
								 */
								curr_voie -> mode = mode;		/* Mode de fonctionnement */
								break;
							}
						}
						if ( mode == NB_VMODES )
						{	/*
							 * Si on a pas trouvÇ: 
							 */
							signale( "On a pas trouvÇ le bon mode" );
							curr_voie -> mode = VMODE_NORMAL;		/* Mode de fonctionnement */
						}
						

						/*
						 * Autres initialisations: 
						 */
						voie_phase_init( curr_voie, TRUE_1 );	/* Met en INIT */

						/*
						 * Lien entre voie prÇcÇdente et celle-ci 
						 */
						*last_ptr_to_next = curr_voie;
						/*
						 * Pour la prochaine voie: 
						 */
						last_ptr_to_next = &(curr_voie -> next);

						/* 
						 * Une voie de + 
						 */
						nb_voies ++;
					}
				}
			}
			else			
			{	
				ping();
				printf("\nInstruction inconnue: %s", instr );
			}
		}
	}

	/*
	 * Il n'y a plus de voie apräs la derniäre chargÇe: 
	 */
	*last_ptr_to_next = NULL;				/* Pas d'autre voie (pour l'instant) */

	/*
	 * Teste si on a chargÇe une liste de voies: 
	 */
	if ( voies != NULL )
	{	/*
		 * Si on a chargÇ une nouvelle liste:
		 * VÇrifie qu'il n'y a pas dÇjÖ une liste de voies en mÇmoire: 
		 */
		if ( G_voies != NULL )
		{
			signale( "Il ne devrait pas encore y avoir de voies en mÇmoire!!!!" );
			/*
			 * Mais c'est sans gravitÇ puisqu'on va les effacer: 
			 * Efface les voies en mÇmoire: 
			 */
			free_voies( G_voies );
		}
		
		/*
		 * Assigne nouvelle liste de voies: 
		 */
		G_voies = voies;				/* Adr liste */
		G_nb_voies = nb_voies;		/* Nbre de voies */

	}

}



/*
 * ------------ TRAITEMENT FICHIER .INF (Params serveur) ---------------
 */


/*
 * autoload_inf(-)
 *
 * Purpose:
 * --------
 * Chargement automatique depuis le fichier STUT_ver.INF
 * des chemins d'accäs d'un serveur et des fichiers 
 * concernÇs lors du lancement de STUT ONE
 *
 * Algorythm:
 * ----------  
 * - Signale qu'il n'y a pas de serv en RAM Ö initialiser au prÇalable
 * - CrÇe path ds dossier de lancement
 * - Appele 'load()'
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	autoload_inf( void )
{
	/* Variables: */
		FTA	fta;								/* File Transfer Area */

	/* 
	 * Signale qu'il faut PAS initialiser un serveur rÇsident 
	 * (puisqu'il n'y en a pas encore eu): 
	 */
		fta .param = NO0;

	/* Fixe le chemin d'accäs et le nom du fichier: */
		strcpy( G_filepath, G_stutpath );	/* Dans le dossier STUT ONE */
		strcpy( G_filename, "STUT_000.INF" );	/* Nom du Fichier Ö charger */
		
	/* Charge fichier STUT_ver.INF */
		directload_file2( FS_INF, &fta, NO0 );		/* Charge slt si le fichier existe */
}


/*
 * charger_param_inf(-)
 *
 * Purpose:
 * --------
 * Suite Ö sÇlection menu:
 * Traite demande de Chargement des chemins d'accäs d'un serveur, 
 * et des fichiers concernÇs ds fichier .INF
 *
 * Algorythm:
 * ----------  
 * - Si nÇcessaire: Dem conf pour INITIALISER le serv actuellement en RAM
 * - Appele 'load()'
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 22.01.95: controle no de version
 */
void	charger_param_inf( void )
{
	/*
	 * VÇrifie si le serveur a ÇtÇ modifiÇ: 
	 */
	int	confirm	  = 0;				/* Confirmation? */

	/*
	 * Selon statut serveur: 
	 */
	switch( get_ServSState( ) )
	{
		case	SSTATE_SAVED:
			confirm = form_alert( 1, 
							"[2][Pour charger un nouveau|"
							 	 "serveur en mÇmoire, vous|"
								 "devez d'abord en supprimer|"
								 "l'ACTUEL. Voulez-vous|"
							    "l'INITIALISER maintenant?]"
								 "[Init.|Annuler]" );
			break;

		case	SSTATE_MODIFIED:
			confirm = form_alert( 2, 
							"[3][ATTENTION: Vous àtes sur le|"
								 "point d'êCRASER le serveur|"
								 "actuellement en mÇmoire alors|"
								 "que certaines MODIFICATIONS|"
								 "n'ont pas ÇtÇ sauvÇes!]"
								 "[êcraser|Annuler]" );
			break;
	}


	/* 
	 * Selon rÇponse utilisateur (si question il y a eu) 
	 */
	if ( confirm < 2 )
	{	/* 
		 * Si on a pas annulÇ: 
		 */
		FTA	fta;		/* File Transfer Area */
	
		/*
		 * Signale s'il faut initialiser un serveur rÇsident ou non: 
		 */
		fta .param = confirm;		/* (Astuce) 0=NON, 1=OUI */

		/*
		 * SÇlection, (Initialise si nÇcessaire) et charge fichier *.INF 
		 */
		load_file( "Charger Paramätres Serveur", FS_INF, &fta );

	}

}


/*
 * load_inf(-)
 *
 * Purpose:
 * --------
 * Chargement des donnÇes pt par pt depuis le fichier .INF
 *
 * Algorythm:
 * ----------  
 * - deselect icìne courante!!!!!
 * - Contrìle header
 * - Charge lignes d'instructions
 * - Si ligne correspond a une association de fichier Ö un groupe:
 *		charge le fichier correspondant pour:
 *			- arbo
 *			- pages vdt
 *			- bases de donnÇes
 *
 * Suggest:
 * --------
 * Sortir la dÇselect icìne courante, ce n'est pas une bonne place
 * du point de vue de l'intÇgritÇ fonctionnelle...
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: chgt des textes
 * 22.01.95: controle no de version
 */
void	load_inf( FILE *fstream )
{
	int n_Version;
	
	/*
	 * DÇsÇlectionne icìne courante: 
	 */
	deselect_current();

	/* 
	 * Contrìle le header:
	 */
	n_Version = head_control( fstream, FS_INF, "Paramätres-Serveur" );
	
	/*
	 * Contrìle le no de version:
	 */
	switch( n_Version )
	{
		case	0x0000:
			break;
			
		case	ERROR_1:
			/*
			 * Chargement Ö ÇchouÇ dans le header:
			 */
			return;

		default:
			/*
			 * Chargement Ö ÇchouÇ 
			 */
			alert( BAD_VERSION );
			return;
	}

	/*
	 * Si le header est correct: 
	 */
	{	/* 
		 * Variables: 
		 */
		char	*instr;		/* Action a effectuer */
		char	*object;		/* DonnÇe Ö modifier */
		char	*data;		/* Contenu Ö charger */
		/* ATTENTION, ces variables vont en fait pointer dans M_buffer, ne pas faire de free */

		/* 
		 * Boucle de chargement: 
		 */
		while ( !feof( fstream ) )
		{	/* Tant qu'on est pas Ö la fin du fichier: */
			instr = get_config_line( fstream, '=', &object, &data );

		/* Test de l'instruction Ö traiter: */
			if ( instr != NULL )
			{	/* S'il y a une instruction: */

				if ( strcmp( instr, "GROUP") == 0 )
				{	/* 
				 	 * Assignement d'un fichier Ö un groupe: 
				 	 */
				
					if ( object != NULL )
					{
						/*
						 * Cherche l'instr concernÇe: 
						 */
						if ( strcmp( object, "ARB:" ) == 0 )
						{	/* 
						    * Chargement des pages arbo 
						    */
							group_directload( find_datagroup_byType( DTYP_ARBO ), FS_ARBO, data );
						}
						else if ( strcmp( object, "ECR:" ) == 0 )
						{	/* 
							 * Chargement des pages Çcran 
							 */
							group_directload( find_datagroup_byType( DTYP_PAGES ), GF_PAGES_ECRAN, data ); 
						}
						else if ( strcmp( object, "DAT:" ) == 0 )
						{	/* 
						 	 * Chargement des bases de donnÇes: 
						 	 */
							group_directload( find_datagroup_byType( DTYP_DATAS ), FS_DATAS, data ); 
						}
						else if ( strcmp( object, "TXT:" ) == 0 )
						{	/* 
						 	 * Chargement des textes: 
						 	 */
							group_directload( find_datagroup_byType( DTYP_TEXTS ), FS_TEXTES, data ); 
						}
					}
					else
					{
						signale("Ligne non valide");
					}
				}
				else
				{
					signale("Instruction inconnue");
				}
			}
		}
	}
}


/*
 * sauver_param_inf(-)
 *
 * Purpose:
 * --------
 * Suite Ö sÇlection menu:
 * Traite demande de Sauvegarde des chemins d'accäs d'un serveur
 * dans fichier .INF
 *
 * Algorythm:
 * ----------  
 * - Demande confirm/type (param dÇfaut ou fichier indÇpendant)
 * - CrÇe nom si dÇfaut
 * - Appele 'sauve()' -> save_infdata()
 *
 * Notes:
 * ------
 *
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	sauver_param_inf( void )
{
	/* 
	 * Demande de confirmation: 
	 */
	int	confirm = form_alert(2,
							"[2][  Voulez-vous sauver les|"
								 "  paramätres-serveur par|"
								 "  dÇfaut ou un fichier de|"
								 "  paramätres indÇpendant?]"
								 "[DÇfaut|IndÇpend|Annuler]");

	/* 
	 * Selon rÇponse utilisateur: 
	 */
	switch ( confirm )
	{
		case	1:				/* Paramätres par dÇfaut: */
			strcpy( G_filepath, G_stutpath );	/* Dans le dossier STUT ONE */
			strcpy( G_filename, "STUT_000.INF" );	/* Nom du Fichier Ö sauver */
			/*	printf("Path=%s  Name=%s \n",  G_filepath, G_filename ); */

			directsave_file( FS_INF, NULL );		/* Sauve les infos du serveur courant dans ce fichier */
			break;
	
		case	2:				/* IndÇpendant */
			save_file( "Sauver Parmätres-Serveur", FS_INF, NULL );
			break;
	}
}


/*
 * save_infdata(-)
 *
 * Purpose:
 * --------
 * Sauvegarde des donnÇes pt par pt dans les fichier .INF
 *
 * Algorythm:
 * ----------  
 * Sauve:
 * -Chemins d'accäs aux fichiers serveur
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	save_infdata( FILE *fstream )
{
	int			i;
	DATAGROUP	*datagroup;		/* Datagroup en cours de traitement */

	/* Commentaire: */
	fputs( "\r\n[ Chemins d'accäs aux fichiers serveur: ]\r\n\r\n", fstream );

	/* Sauve chemins d'accäs serveur: */
	for ( i = 0; i < NB_DATAGROUPS; i++ )
	{
		datagroup = &G_datagroups[ i ];	/* Datagroup Ö traiter */
		if ( datagroup -> filepath != NULL )
		{	/* Si le Datagroup en question Ö un chemin+fichier associÇ: */
			fprintf( fstream, "GROUP %s=%s\\%s\r\n",
							datagroup -> data_device, 	/* Nom du groupe */
							datagroup -> filepath,		/* Path */
							datagroup -> filename );	/* Fichier */
		}
	}
}



/*
 * ------------ AFFECTATION DES VOIES UTILISEES PAR LE SERV ---------------
 */


/*
 * affecte_voies(-)
 *
 * Purpose:
 * --------
 * Affectation des voies utilisÇes par le serveur
 *
 * Algorythm:
 * ----------  
 * - Duplique la liste chaånÇe d'infos sur les voies.
 *   (La copie peut alors àtre modifiÇe, Çtendue, diminuÇe tout
 *		en conservant la possibilitÇ d'annuler ultÇrieurement)
 * - CrÇe une liste textuelle des voies
 *		utilise cree_ligne_voie()
 * - Eteinds fonctions non dispo tant qu'aucune ligne de la liste 
 *	   textuelle n'est sÇlectionnÇ
 * - DIALOGUE avec utilisateur: select_in_list() ~> affecte_actions()
 * - Libäre liste textuelle
 * - Selon rÇsultat dialogue: on garde l'une ou l'autre des 
 *		listes chaånÇes complätes
 *
 * Suggest:
 * --------
 * Le param M_voie_copies devrait etre integre ds list_handles
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.01.94: nouveau format d'appel de select_in_list()
 */
void affecte_voies( const GRECT *start_box )
{
	/* 
	 * Pointeurs: 
	 */
	VOIE		*curr_voie;					/* Voie en cours de traitement */
	char		* *param_array;			/* Tableau de ptr sur chaines */
	
	/* 
	 * Variables: 
	 */
	int		i;								/* Compteur */
	int		nb_lignes = G_nb_voies;	/* Nbre de lignes = Nb voies Ö l'origine */
	
	static int	esc_objs[]={ AFFECAJ, AFFECMOD, AFFECSUP, AFFECVAL, AFFECANN, NIL };
	int		exit_obj;					/* Objet de sortie */
	GRECT		form_box;					/* Dimensions du formulaire */
	
	
	
	/*
	 * Duplique la liste chainÇe des infos complätes sur les 
	 * voies pour l'Çdition (on gardera l'une ou l'autre selon que
	 * l'utilisateur confirme ou annule): 
	 */
	M_voies_copies = dup_voies( G_voies );
	
	
	
	/*
	 * CrÇation liste textuelle des voies:
	 */
	param_array = (char * *) MALLOC( sizeof( char* ) * nb_lignes );
	curr_voie = M_voies_copies;			/* Ptr sur 1ere voie */
	for ( i=0; i<nb_lignes; i++ )
	{
		/* CrÇe une ligne sur la voie et sauve ptr ds tableau: */
		param_array[ i ] = cree_ligne_voie( curr_voie );
	
		/* Voie suivante: */
		curr_voie = curr_voie -> next;
	}
	
	
	/* 
	 * "Eteind" fonctions non (encore) disponibles: 
	 */
	objc_setdisable( M_affect_adr, AFFECMOD );
	objc_setdisable( M_affect_adr, AFFECSUP );
	
	
	/* 
	 * Boåte de Dialogue avec utilisateur: 
	 */
	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL
	
	exit_obj = select_in_list( 
						M_affect_adr, 
						start_box, 
						&form_box,
						&param_array, 
						&nb_lignes,
						esc_objs, 
						affecte_actions, 		/* Ptr sur func de ttmnt des actions */
						affec_fixstate_act,	/* Ptr sur func Ö appeller pour allumer/eteindre boutons d'actions */
						0 );
	
	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL

	
	/*
	 * Libäre liste textuelle: 
	 */
	for ( i=0; i<nb_lignes; i++ )
	{
		FREE(	param_array[ i ] );
	}
	FREE( param_array );
	
		
	/* 
	 * Teste s'il y a eu confirmation -> Prise en compte modifs: 
	 */
	if ( exit_obj == AFFECVAL )
	{	/*
		 * Si on a validÇ: 
		 */
	
		/* 
		 * Efface les anciennes donnÇes: 
		 */
		free_voies( G_voies );
	
		/* 
		 * Valide les nouvelles: 
		 */
		G_voies = M_voies_copies;
	
		/* 
		 * Compte le nbre de voies: 
		 */
		G_nb_voies = 0;
		curr_voie = G_voies;
		while( curr_voie != NULL )
		{
			G_nb_voies ++;
			curr_voie = curr_voie -> next;
		}			
	
	}
	else
	{	/* 
		 * Si on a annulÇ: 
		 */
	
		/* 
		 * Efface simplement la copie des donnÇes:
		 */		
		free_voies( M_voies_copies );
	
	}
	
	/* 
	 * Safety: On ne doit plus utiliser la copie: 
	 */
	M_voies_copies = NULL;

}



/*
 * affecte_actions(-)
 *
 * Purpose:
 * --------
 * Traitement des objets exit du formulaire affichÇ par 
 * affecte_voies()
 *
 * Algorythm:
 * ----------  
 * - Si on a cliquÇ sur un nom: RIEN
 * - Si on a cliquÇ sur un bouton d'action:
 *	   Traite le cas appropriÇ au bouton
 *			- Valider/Annuler: quitter dialogue
 *			- Ajouter une voie
 *
 * Notes:
 * ------
 * On ne fait RIEN lorsque l'on clique sur un elt ds la liste...
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 04.01.94: l'allumage des bout d'actions lors de la sel d'un elt se fait dÇsormais hors-d'ici
 * 05.01.94: ajout de la <suppression d'une voie>
 * 07.01.95: gestion double click
 */
int	affecte_actions( 						/* Out: FALSE0 : Il faut terminer le dialogue 
													 *		  TRUE_1 : Il faut continuer le dialogue normalement
													 *		  CHANGE_2 : Continue, MAIS ATTENTION: La liste a changÇ
													 */
			LISTHANDLES *list_handles,		/* In: Ptr sur infos sur la liste & le dialogue affichÇs */
			int	obj )							/* In: Objet du form sur lequel on a cliquÇ */
{
	if( obj & SEL_LINE )
	{
		if( obj & DBLE_CLICLK )
		{	/*
		    * Si on a double cliquÇ sur un nom:
		 	 * Dialogue de config des voies:
			 */
			Affecte_ParamsVoie( list_handles, M_affect_adr, AFFECMOD );
		}
	}
	else
	{	/*
		 * Si on a cliquÇ sur un bouton d'action:
		 */
		switch( obj )
		{	/* 
			 * Selon le bouton sur lequel on a cliquÇ:
			 */
			case	AFFECVAL:			/* Valider */
			case	AFFECANN:			/* Annuler */
				return	FALSE0;		/* Met fin au dialogue */

			case	AFFECAJ:				/* Ajouter une voie: */
				/*
				 * Ajoute une voie compläte Ö la liste chainÇe
				 */
				ajoute_voie( list_handles );

				/* 
				 * "Allume" nlles ations disponibles: 
				 */
				affec_fixstate_act( list_handles );

				return	CHANGE_2;		/* On a changÇ la liste, il va falloir rÇafficher et initialiser variables */

			case	AFFECMOD:				/* Modifier les params d'une voie: */
				/*
				 * Dialogue de config des voies:
				 */
				Affecte_ParamsVoie( list_handles, M_affect_adr, AFFECMOD );
				 
				return	TRUE_1;

			case	AFFECSUP:				/*	Supprimer une voie: */
				/*
				 * Supprime une voie compläte de la liste chainÇe
				 */
				supprime_voie( list_handles );

				/* 
				 * "Eteinds" ations eventuellement devenues indisponibles: 
				 * (Bouton "Supprimer" uniquement)
				 */
				affec_fixstate_act( list_handles );

				return	CHANGE_2;		/* On a changÇ la liste, il va falloir rÇafficher et initialiser variables */
				
			default:
				ping();
		}

	}
	
	return	TRUE_1;			/* Continue dialogue */
}



/*
 * ParamsVoie(-)
 *
 * Purpose:
 * --------
 * Paramätres d'une voie
 *
 * Algorythm:
 * ----------  
 * Cherche voie concernÇe dans la copie de liste de voies
 * Modifie les valeurs suivantes:
 *		no_voie
 *		device
 *		mode	
 *
 * Notes:
 * ------
 * On ne peut pour l'instant Çditer le no de la voie!
 *
 * History:
 * --------
 * 10.05.94: fplanque: Created based on parapg_parasortie(-)
 */
void	Affecte_ParamsVoie( 
			LISTHANDLES *list_handles, 	/* In: Infos sur liste de voies */
			OBJECT *arbre_fond, 				/* In: Formulaire appellant */
			int call_obj )						/* In: Objet appellant ds ce formulaire */
{
	/* 
	 * Ligne/Champ concernÇ: 
	 */
	int	concerned_line = get_no_selitem( list_handles );

	/* 
	 * Ptrs sur Objets formulaire: 
	 */
	char*		pT_NoVoie = (M_pForm_ParamsVoie[ VOIENUM ] .ob_spec.tedinfo) -> te_ptext;
	OBJECT*	pOb_Port  = &M_pForm_ParamsVoie[ VOIEPORT ];
	OBJECT*	pOb_Mode  = &M_pForm_ParamsVoie[ VOIEMODE ];

	/* 
	 * Trouve les parametres de la voie concernÇe: 
	 */
	VOIE* pVoie_Params = find_ParamsVoie_byOrdNo( M_voies_copies, concerned_line );

	/* 
	 * Variables: 
	 */
	int	n_NoVoie	= pVoie_Params -> no_voie;	
	int	n_Device	= pVoie_Params -> device;	/* Device de la voie ÇditÇe */
	int	n_Mode	= pVoie_Params -> mode;
	int	edit_obj = NIL_1;							/* Objet en cours d'Çdition */
	int	exit_obj;									/* Bouton Exit cliquÇ */
	GRECT	start_box, form_box;

	/* 
	 * Fixe les valeurs dans le formulaire: 
	 */
	/* No de la voie: */
	itoa( n_NoVoie, pT_NoVoie, 10 );			/* Conversion dÇcimale */
	/* Nom du port (Pop-Up): */
	fix_popup_title( pOb_Port, G_inst_drv_list, n_Device );
	/* Mode de fonctionnement: */	
	fix_popup_title( pOb_Mode, G_Popup_Modes, n_Mode );
	

	/* 
	 * Gestion formulaire: 
	 */
	/* Coord de dÇpart du grow_box= */
	objc_xywh( arbre_fond, call_obj, &start_box );
	/*vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv*/
	open_dialog( M_pForm_ParamsVoie, &start_box, &form_box );

	while(1)
	{	/* 
	    * Gestion form jusqu'Ö un clic sur objet exit 
	    */
		exit_obj = ext_form_do( M_pForm_ParamsVoie, &edit_obj);
		/*	exit_obj &= 0x7FFF;		/* Masque bit 15 (Double-clic) */
	
		/*
		 * Teste si on cherche Ö sortir: 
		 */
		if ( exit_obj == VOIEVAL  ||  exit_obj == VOIEANN )
			break;

		/* 
		 * Traitement des autres boutons: 
		 */
		switch( exit_obj )
		{
			case	VOIEPORT:
			case	VOIPORUP:
			{	/* 
				 * SÇlection du port utilisÇ par la voie:
				 */
				int			selected;		/* Ligne sÇlectionnÇe */
				POPUP_ENTRY	*entries;		/* Liste pour menu: */
				
				/* 
				 * Fix Ptr sur liste appropriÇe (Drivers installÇs): 
				 */
				entries = G_inst_drv_list;
					
				/*
				 * Appelle le Pop-Up: 
				 */
				selected = popup_inform( 
									M_pForm_ParamsVoie, exit_obj, VOIEPORT, 
									entries, n_Device );	
				if ( selected != ABORT_2 )
				{
					n_Device = selected;
					fix_popup_title( pOb_Port, entries, n_Device );
					objc_draw( M_pForm_ParamsVoie, VOIEPORT, 1, 
									form_box .g_x, form_box .g_y,
									form_box .g_w, form_box .g_h );
				}
				break;
			}

			case	VOIEMODE:
			case	VOIMODUP:
			{	/* 
				 * SÇlection du mode de fonctionnement de la voie:
				 */
				int			selected;		/* Ligne sÇlectionnÇe */
				POPUP_ENTRY	*entries;		/* Liste pour menu: */
				
				/* 
				 * Fix Ptr sur liste appropriÇe (Drivers installÇs): 
				 */
				entries = G_Popup_Modes;
					
				/*
				 * Appelle le Pop-Up: 
				 */
				selected = popup_inform( 
									M_pForm_ParamsVoie, exit_obj, VOIEMODE, 
									entries, n_Mode );	
				if ( selected != ABORT_2 )
				{
					n_Mode = selected;
					fix_popup_title( pOb_Mode, entries, n_Mode );
					objc_draw( M_pForm_ParamsVoie, VOIEMODE, 1, 
									form_box .g_x, form_box .g_y,
									form_box .g_w, form_box .g_h );
				}
				break;
			}

			default:
				ping();
		}

		
	/* DÇsÇlection du bouton sÇlectionnÇ: */
	/*	objc_dsel( M_pForm_ParamsVoie, exit_obj ); */
	
		graf_mouse( ARROW, 0);					/* souris: Fläche */
	}

	graf_mouse( BUSYBEE, 0);				/* souris: Abeille */
	close_dialog( M_pForm_ParamsVoie, exit_obj, &start_box, &form_box );
	/*^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^*/

	/* 
	 * DÇsÇlectionne bouton de sortie: 
	 */
	objc_clrsel( M_pForm_ParamsVoie, exit_obj );

	/* 
	 * RedÇssinne le fond: 
	 */
	objc_draw( arbre_fond, 0, 5, form_box .g_x, form_box .g_y, form_box .g_w, form_box .g_h );

	/* 
	 * Sauvegarde des valeurs ÇditÇes: 
	 */
	if ( exit_obj == VOIEVAL )
	{	/* 
	 	 * Si on a confirmÇ: 
	 	 */
		/* 
		 * Variables: 
		 */
		char	* *path_array = *(list_handles -> pTpsz_array);
		char	* *resume = &path_array[ concerned_line ];	/* RÇsumÇ des paramätres */

		/* 
		 * Sauvegarde modifs: 
		 */
		pVoie_Params -> device = n_Device;	/* Device de la voie ÇditÇe */
		pVoie_Params -> mode = n_Mode;

		/* 
		 * Modifie la ligne dans le formulaire: 
		 * Efface ancienne ligne: 
		 */
		if ( *resume != G_empty_string )		/* Si pas dÇjÖ vide: */
		{
			FREE( *resume );							/* Libäre ancien contenu */
		}
		/* 
		 * CrÇe nouvelle ligne et place ptr dans tableau: 
		 */
		*resume = cree_ligne_voie( pVoie_Params );
		/* 
		 * Fixe nlle ligne 
		 */
		list_fix1name( M_affect_adr, list_handles -> selected_line, *resume );
		
	}

}



/*
 * find_ParamsVoie_byOrdNo(-)
 *
 * Purpose:
 * --------
 * Trouve les parametres d'une voie en fnct de son numÇro d'ordre
 * dans la liste des voies
 *
 * History:
 * --------
 * 10.05.94: fplanque: CrÇation basÇe sur find_fieldpar_byordno
 */
VOIE*	find_ParamsVoie_byOrdNo(	/* Out: Ptr sur params voie cherchÇe */
			VOIE *pVoie_Liste, 		/* In:  Ptr sur premiäre voie ds liste */
			int ord )					/* In:  No d'ordre de la voie cherchÇe */
{
	int	i=0;		/* Compteur */

	while( i < ord  &&  pVoie_Liste != NULL )
	{	/* 
		 * Tant qu'on est pas arrivÇ au champ qui nous intÇresse
		 * et qu'on est pas Ö la fin de la liste: 
		 */
		/* 
		 * Passe au champ suivant:
		 */
		i ++;
		pVoie_Liste = pVoie_Liste -> next;
	}

	return	pVoie_Liste;		/* Ptr sur params; NULL si pas trouvÇ */
}



/*
 * affec_fixstate_act(-)
 *
 * Purpose:
 * --------
 * Selon qu'une voie est courament selectionnÇe ds la liste textuelle:
 * Allume ou eteind en direct les boutons d'action associÇs.
 *
 * Algorythm:
 * ----------
 * - DÇtermine si une ligne est sÇlectionnÇe...
 * - Allume/Eteind les boutons:
 * 	- MODIFIER
 * 	- SUPPRIMER (Allume Seulement si + d'une voie ds la liste: on ne 
 *						peut supprimer la derniäre)
 *
 * History:
 * --------
 * 03.01.94: fplanque: Created pour allulage seulement
 * 04.01.94: fplanque: Reconnaissance auto allumage/extinction
 */
void	affec_fixstate_act( 					/* Out: Rien */
			LISTHANDLES *list_handles )	/* In: Ptr sur infos sur la liste & le dialogue affichÇs */
{

	if( list_handles -> selected_line != NIL )
	{	/*
		 * S'il y a une ligne sÇlectionnÇe: il faut ALLUMER:
		 */

		/*
		 * Bouton MODIFIER:
		 */
		objc_enable( M_affect_adr, AFFECMOD );
		
		/*
		 * Bouton SUPPRIMER:
		 */
		if ( list_handles -> nb_items > 1 ) 
		{	/*
			 * On ne pourrait effacer la derniäre voie!
			 * S'il y en a donc plus d'une:
			 */
			objc_enable( M_affect_adr, AFFECSUP );
		}
		else
		{	/*
			 * Si 1 seule voie est prÇsente:
			 * On ne peut l'effacer
			 */
			objc_disable( M_affect_adr, AFFECSUP );
		}
	}
	else
	{	/*
		 * S'il n'y a PAS de ligne sÇlectionnÇe: il faut ETEINDRE:
		 */
		objc_disable( M_affect_adr, AFFECMOD );
		objc_disable( M_affect_adr, AFFECSUP );
	}
}






/*
 * cree_ligne_voie(-)
 *
 * Purpose:
 * --------
 * CrÇe une ligne d'infos sur une voie pour l'insÇrer 
 * ds liste d'affectations
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
char	*cree_ligne_voie( VOIE *curr_voie )
{
	int	dev_offset = device_offset( curr_voie -> device );

	/*
	 * CrÇe une chaine rÇsumant les paramätres principaux 
	 */
	sprintf( G_tmp_buffer, "Voie %03d:  Port=%-10sMode=%s",
					 curr_voie -> no_voie,
					 G_inst_drv_list[ dev_offset ] .name +2,
					 G_mode[ curr_voie -> mode ]	);

	/* 
	 * Retourne adresse d'une copie de la chaine crÇÇe: 
	 */
	/*	printf("%s  long=%lu\n", G_tmp_buffer, strlen(G_tmp_buffer) ); */
	return	STRDUP(G_tmp_buffer);
}


/*
 * ajoute_voie(-)
 *
 * Purpose:
 * --------
 * Ajoute 1 voie Ö la liste d'affectations
 *
 * Algorythm:
 * ----------  
 * - Cherche premier no libre Ö attribuer Ö la nouvelle voie
 * - Alloue nouvelle voie complete, l'initialise et l'insäre 
 *    ds liste chainÇe des voie Ö l'endroit correspondant Ö son no.
 * - Ajoute la ligne correspondante dans la liste de sÇlection textuelle associÇe
 * - SÇlectionne cette nouvelle voie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 05.01.93: Modif de la position auto de la partie visible sur nlle voie: on peut maintenant aussi remonter
 */
void	ajoute_voie( LISTHANDLES *list_handles )
{
	/* 
	 * Pointeurs: 
	 */
	VOIE	*curr_voie = M_voies_copies;	/* Voie en cours de traitement */
	VOIE	* *last_ptr_tonext = &M_voies_copies;
	VOIE	*new_voie;
	char	* *param_array;
	
	/* 
	 * Variables: 
	 */
	int	new_no_voie = 1;
	int	nb_items;
	int	selected_line;

	/* 
	 * Cherche no Ö attribuer par dÇfaut Ö la nlle voie: 
	 */
	while ( 	curr_voie != NULL 
			&& curr_voie -> no_voie == new_no_voie )
	{
		new_no_voie ++;		/* Ce no ne convient pas, on passe au suivant */
		last_ptr_tonext = &(curr_voie -> next);
		curr_voie = curr_voie -> next;
	}

	/* 
	 * ------------------------------
	 * Alloue nouvelle voie compläte: 
	 * ------------------------------
	 */
	new_voie = Construct_Voie( );
	/*
	 * Init paramätres: 
	 */
	new_voie -> no_voie = new_no_voie;		/* NumÇro de la voie */
	new_voie -> device = G_term_dev;			/* Port terminal par dÇfaut */
	new_voie -> mode = VMODE_NORMAL;			/* Mode de fonctionnement */
	voie_phase_init( new_voie, TRUE_1 );	/* Met la voie en phase INIT */

	/* 
	 * Liaison avec le reste: 
	 */
	new_voie -> next = curr_voie;
	*last_ptr_tonext = new_voie;

	/* 
	 * -------------------------------------------------------
	 * Une ligne de plus dans la liste de sÇlection textuelle: 
	 * -------------------------------------------------------
	 */
	(list_handles -> nb_items) ++;		/* 1 elt de plus */
	nb_items = list_handles -> nb_items;

	/*
	 * Agrandi la liste: 
	 */
	param_array = (char * *) REALLOC( *(list_handles -> pTpsz_array), nb_items * sizeof( char * ) );
	*(list_handles -> pTpsz_array) = param_array;
	/*
	 * DÇcale la fin de la liste: 
	 */
	if ( new_no_voie < nb_items )
	{	/* 
		 * S'il y a qque chose Ö dÇcaler: 
		 */
		memcpy(	&param_array[ new_no_voie ], &param_array[ new_no_voie - 1 ], (nb_items - new_no_voie) * sizeof( char * ) );
	}
	/*
	 * CrÇe une nouvelle ligne dans la liste: 
	 */
	param_array[ new_no_voie - 1 ] = cree_ligne_voie( new_voie );

	/* 
	 * Nouvelle ligne sÇlectionnÇe: 
	 */
	selected_line = new_no_voie - list_handles -> top_item -1 + list_handles -> first_name;

	/*
	 * VÇrifie qu'on est dans la partie visible: 
	 */
	if ( selected_line > list_handles -> last_name )
	{	/* 
		 * Si on est trop haut: 
		 * On va dÇscendre l'affichage dans la liste: 
		 */
		list_handles -> top_item += selected_line - list_handles -> last_name;
		selected_line = list_handles -> last_name;
	}
	else if( selected_line < list_handles -> first_name ) 
	{	/* 
		 * Si on est trop bas: 
		 * On va monter l'affichage dans la liste: 
		 */
		list_handles -> top_item -= list_handles -> first_name - selected_line;
		selected_line = list_handles -> first_name;
	}

	list_handles -> selected_line = selected_line;

	
}


/*
 * supprime_voie(-)
 *
 * Purpose:
 * --------
 * Supprime 1 voie de la liste d'affectations
 *
 * History:
 * --------
 * 05.01.94: fplanque: Created
 */
void	supprime_voie( 						/* Out: Rien */
			LISTHANDLES *list_handles )	/* In/Out: Paramätres de la liste de sÇlection */
{
	/* 
	 * Pointeurs: 
	 */
	VOIE	*curr_voie = M_voies_copies;	/* Voie en cours de traitement */
	VOIE	* *last_ptr_tonext = &M_voies_copies;
	char	* *select_array = *(list_handles -> pTpsz_array);	/* Tableau de chaines de charactäres */
	
	/* 
	 * Variables: 
	 */
	int	no_selitem = get_no_selitem( list_handles );	/* No de l'elt de liste sÇlectionnÇ */
	int	nb_items = list_handles -> nb_items;
	int	count = 0;								/* Compteur de voies */


	/* 
	 * Cherche la voie Ö supprimer: 
	 * no_selitem=0 => il faut supprimer la 1ere voie
	 */
	/* printf( "\033Y!!No de l'elt sÇlectionnÇ ds liste textuelle: %d\n", no_selitem ); */

	while( count < no_selitem && curr_voie != NULL )
	{
		last_ptr_tonext = &(curr_voie -> next);
		curr_voie = curr_voie -> next;	/* Passe Ö la voie suivante */
		count++;
	}

	if( curr_voie == NULL )
		ping();						/* Erreur interne! */
	else
	{	/*
		 *	Suppression de la voie concernÇe:
		 */
		/* printf( "No de la voie Ö supprimer: %d\n", curr_voie -> no_voie ); */

		*last_ptr_tonext = curr_voie -> next;	/* Lie voie prÇcÇdente Ö voie suivante */
		
		FREE( curr_voie );		/* Cette voie n'est plus ds la liste, on peut l'effacer */
		
		/*
		 * Supression de la ligne correspondante ds liste textuelle:
		 */
		/* printf( "Supprime l'entrÇe [%s] de la liste textuelle\n", select_array[ no_selitem ] ); */

		FREE( select_array[ no_selitem ] );	/* Supprime texte de la ligne */

		nb_items--;							/* 1 elt de moins */
		(list_handles -> nb_items) --;

		/*
		 * DÇcale fin de la liste:
		 */
		if ( no_selitem < nb_items )
		{	/* 
			 * S'il y a qque chose Ö dÇcaler: 
			 */
			memcpy( &select_array[ no_selitem ], &select_array[ no_selitem +1 ],
						(nb_items - no_selitem) * sizeof( char * ) );
		}

		/*
		 * Reduit la mÇmoire oqp par liste: 
		 */
		*(list_handles -> pTpsz_array) = 
			(char * *) REALLOC( *(list_handles -> pTpsz_array), 
										nb_items * sizeof( char * ) );
		
		/* 
		 * Il n'y a plus de ligne sÇlectionnÇe: 
		 */
		list_handles -> selected_line = NIL;


		/*
		 * Contrìle si on a crÇÇ une ligne blanche Ö l'Çcran: 
		 */
		if ( nb_items <= list_handles -> top_item + list_handles -> last_name - list_handles -> first_name)
		{	
			if ( list_handles -> top_item > 0 )
			{	/*
			    * On est pas en haut de la liste:
			    * On va la descendre pour combler la ligne blanche:
			    */
				list_handles -> top_item --;
			}
			else
			{	/*
				 * Il y a - de lignes ds liste que physiquement affichÇes:
				 * On vide la ligne juste apräs la (nouvelle) derniäre
				 * De plus, on la dÇsÇlectionne au cas oó c'Çtait celle qui Çtait sÇlectionnÇe:
				 */
				OBJECT *object_ptr = &(list_handles -> form_tree[ list_handles -> first_name + nb_items ]); 
				 
				dlink_teptext( object_ptr, G_empty_string );		
				objc_clrsel( object_ptr, 0 );				
			}
		}
	}
}
