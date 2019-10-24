/*
 * serveur.c
 *
 * Purpose:
 * -------- 
 * "Kernel"
 * Routines de gestion du serveur
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"SERVEUR.C v1.01 - 07.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include <string.h>					/* header tt de chaines */
	#include	<stdlib.h>
	#include <time.h>						/* Conversion d'heure */
   

/*
 * Custom headers:
 */

	#include "SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "AESDEF.H"
	#include "DTDIR_PU.H"
	#include "DATPG_PU.H"
	#include	"DESK_PU.H"	
	#include	"DEBUG_PU.H"	
	#include	"MAIN_PU.H"	
	#include "ARBPG_PU.H"
	#include "ATREE_PU.H"
	#include "SRIAL_PU.H"
	#include "DBSYS_PU.H"
	#include "LISTS_PU.H"
	#include	"SERV_PU.H"
	#include	"LINE0_PU.H"
	#include	"IOFLD_PU.H"
	#include	"GETKB_PU.H"
	#include	"DBINT_PU.H"		/* DB Interface */
	#include	"ACOUNTPU.H"
	#include	"ECRIM_PU.H"
	#include	"LECTM_PU.H"
	#include	"GENRC_PU.H"
	#include	"DISPT_PU.H"
	#include	"LISTD_PU.H"
	#include "TERM_PU.H"
	#include "TEXT_PU.H"
	#include "WIN_PU.H"
	#include "WINDR_PU.H"
	#include "GEMEV_PU.H"
	#include "OBJCT_PU.H"
	#include "SERCOMPU.H"
	#include "SVRFSLPU.H"
	#include "GEMDIRPU.H"
	#include "ARBGENPU.H"
	#include "SVRDWLPU.H"
		
/*
 * ------------------------ PROTOTYPES -------------------------
 */


/*
 * PRIVate INTernal prototypes:
 */
	static	void	actions_atEndCnx( 
							VOIE *pVoie );
	static	void	run_server( VOIE *voies );
	static	BOOL	Action_IsLong(				/* Out: TRUE_1 si l'action peut s'effectuer en plusieurs tours de boucle ppale */
							int	n_action );		/* In:  Action demand‚e */
	static	BOOL	handle_ENPG(
								VOIE	*	pVoie_curr );		/* In: Voie concern‚e */
	static	void	actions_atArbopgExit( 
							VOIE *pVoie );				/* In: Voie concern‚e */
#if ACCEPT_REMOTE
	static	void	try_connection( VOIE *pVoie_curr );
#endif
	static	int	enter_dir( VOIE *pVoie_curr, DATADIR *new_arbodir );
	static	int	jmp_page( VOIE *pVoie_curr, char *new_arbo, int obligatoire );
	static	int	affiche_ecran( VOIE *pVoie_curr, int fnct_ecran );
	static	int	Serv_EnterDataPage( 
							VOIE 	*	pVoie_curr,		/* In: Voie concern‚e */
							DATATYPE	DataType,		/* In: Type de donn‚es … charger */
							int		n_fnct );		/* In: Fonction Recherch‚e */

	static	int	sys_events( void );



/*
 * ------------------------ VARIABLES -------------------------
 */
    
/*
 * External variables: 
 */
	/* 
	 * Ressource: 
	 */
	extern	OBJECT	*G_menu_adr;				/* Ptr sur le MENU ! */
	/* 
	 * Donn‚es: 
	 */
	extern	DATAGROUP	*G_datagroups;			/* Groupes de donn‚es */
	/* 
	 * Vdi: 
	 */
	extern	int		G_ws_handle;				/* Handle virtual WorkStation VDI */


/*
 * Public variables: 
 */
	/* 
	 * Voies: 
	 */
	VOIE	*	G_voies;						/* Liste des voies */
	int		G_nb_voies;						/* Nombre de voies */
	/* 
	 * Modes de fonctionnement: 
	 */
	char		*G_mode[]=
					{
						"Normal",
						"Off-Line",
						"Test Loc"
					};
	long		G_abrev_mode[]=
					{
						'NORM',
						'OFFL',
						'TEST'
					};
	POPUP_ENTRY	G_Popup_Modes[]=
					{					/* Popup de choix d'un mode de fonctionnement */
						"  Normal",			VMODE_NORMAL,
						"  Off-Line",		VMODE_OFFLINE,
						"  Test Local",	VMODE_TEST,
						NULL,					0xFFFF
					};

	
/*
 * Private variables: 
 */
	static	DATAGROUP *	M_arbogroup;			/* Datagroup arbo */
	static	DATAGROUP *	M_pecrangroup;			/* Datagroup pages-‚cran */
	static	DATAGROUP *	M_dbasegroup;			/* Datagroup bases de donn‚es */
	static	DATAGROUP *	M_pDataGroup_Texts;	/* Datagroup textes */
	static	char		 *	M_keyname[]=
		{
		/*	KEY_NONE,		*/		"Aucune",			/* Aucune touche */
		/*	KEY_SOMM,		*/		"Sommaire",
		/*	KEY_GUIDE,		*/		"Guide",
		/*	KEY_ANNUL,		*/		"Annulation",
		/*	KEY_CORREC,		*/		"Correction",
		/*	KEY_RETOUR,		*/		"Retour",
		/*	KEY_SUITE,		*/		"Suite",
		/*	KEY_REPET,		*/		"R‚p‚tition",
		/*	KEY_ENVOI,		*/		"Envoi",
		/*	KEY_FIN,			*/		"Connexion/Fin",
		/* ACTIONS,			*/		NULL,
		/* EVT_APPEL,		*/		"  D‚tection d'un appel entrant (Minitel)",
		/*	ACT_DISCONNECT */		"  D‚connexion"
		};
	/*
	 * Noms des actions:
	 */
	char *	M_Tsz_ActionName[] =
	{
		"INIT",				/* La voie doit ˆtre initialis‚e */
		"HALT",				/* Il y a une Kernel-Panic: le serv est stopp‚ */
		"SLEP",				/* La voie n'est pas active */
		"CNCT",				/* Etablissement Connexion en cours */
		"DECO",				/* D‚connexion en cours */
		"WAIT",				/* On est en attente d'action utilisateur */
		"STRT",				/* D‚but d'une connexion */
		"JUMP",				/* On est en phase de changement de page */
		"ENPG",				/* On est en ENTER PAGE: effectue initialisations */	
		"DISP",				/* On est en phase d'affichage … l'‚cran */
		"OPDB",				/* Phase de recherche/ouverture base de donn‚es */
		"OTXT",				/* Phase de recherche/ouverture texte */
		"DDAT",				/* Phase d'affichage de donn‚es */
		"DREC",				/* Phase d'affichage d'un nouveau message */
		"DPAG",				/* Phase d'affichage d'une page de message */
		"DWLD",				/* Download, Protocole USLTP en cours */
		"EFLD",				/* On entre ds un champ */
		"CPOS",				/* Repositionnement curseur pour continuer ‚dition */
		"CLRF",				/* Clear Field (pour nouvelle ‚dition) */
		"?01?",
		"?02?"
	};


/*
 * ------------------------ FUNCTIONS -------------------------
 */



/*
 * init_voies(-)
 *
 * Purpose:
 * --------
 * Init des voies utilis‚es (par d‚faut) lors du boot de stut one
 * si aucune voie n'a ‚t‚ affect‚e en utilisant les fichiers .INI
 *
 * Algorythm:
 * ----------  
 * On ne cr‚‚e ici qu'une seule voie
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_voies( void )
{
	/*
	 * Pointeurs: 
	 */
	VOIE	*pVoie_curr;		/* Voie en cours de cr‚ation: */

	/*
	 * Cr‚ation de la voie en m‚moire: 
	 */
	pVoie_curr = Construct_Voie( );

	/*
	 * Initialisation g‚n‚rale: 
	 */
	pVoie_curr -> no_voie = 1;					/* Num‚ro de la voie */
	pVoie_curr -> device = G_term_dev;		/* Port terminal */
	pVoie_curr -> mode = VMODE_NORMAL;		/* Mode de fonctionnement */
	pVoie_curr -> next = NULL;					/* Pas d'autre voie (pour l'instant) */
	voie_phase_init( pVoie_curr, TRUE_1 );	/* Met en phase INIT */

	/*
	 * Sauve ptr sur d‚but de la liste: 
	 */
	G_voies = pVoie_curr;	

	G_nb_voies = 1;
}


/*
 * Construct_Voie(-)
 *
 * Purpose:
 * --------
 * Constructeur du pseudo objet VOIE
 *
 * History:
 * --------
 * 21.08.94: fplanque: Created
 */
VOIE * Construct_Voie( void )		/* Out: Voie construite */
{
	/*
	 * Alloue m‚moire:
	 */
	VOIE * pVoie_curr = (VOIE *) MALLOC( sizeof( VOIE ) );

	/*
	 * Init variables:
	 */
	pVoie_curr -> state.n_speed = 15;	/* Vitesse courante inconnue */

	pVoie_curr -> pTCompRec_ptrs	= NULL;

	pVoie_curr -> pMsz_Path = NULL;			/* Pas de path courant */
 	pVoie_curr -> TpDirEnt  = NULL;			/* Pas de DIR charg‚ en RAM */
 	pVoie_curr -> nb_TableEnt  = 0;
 	pVoie_curr -> nb_DirEnt  = 0;

	pVoie_curr -> pIOField_ListIn	= NULL;	/* Pas de liste de champs d'entr‚e */

	pVoie_curr -> pIOField_CurrOut = NULL;	/* pas de champ de sortie (anti plantage si serv ne d‚marre pas) */

	pVoie_curr -> pMsz_Login		= NULL;		/* Pas de Pseudo */
	pVoie_curr -> pMsz_FirstName	= NULL;		/* Pas de Pr‚nom */
	pVoie_curr -> pMsz_LastName	= NULL;		/* Nom */

	pVoie_curr -> pMsz_VFile		= NULL;		/* Fichier selectionn‚ */

	return	pVoie_curr;
}



/*
 * voie_phase_init(-)
 *
 * Purpose:
 * --------
 * Init une voie: On la met en mode SLEEP
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.05.94: La fonction en renverra plus rien.
 */
void	voie_phase_init( 
			VOIE *voie, 
			int stable )		/* In: !=0 si on veut que la voie soit stable */
{
	if( stable )
	{	/* Init stable: */
		voie -> action[ 0 ] .no = INIT;		/* La connexion doit ˆte initialis‚e */
		voie -> action_head = 0;				/* index Action en cours sur la voie courante */
		voie -> action_tail = 0;				/* Index de la deniere action a effectuer sur la voie courante */
	}
	else
	{	/* Init instable: la moteur va sauter … l'action suivante qui sera INIT: */
		voie -> action[ 0 ] .no = INIT;		/* Bidon, on le met pour s‚curit‚ */
		voie -> action[ 1 ] .no = INIT;		/* La connexion doit ˆte initialis‚e */
		voie -> action_head = 0;				/* index Action en cours sur la voie courante */
		voie -> action_tail = 1;				/* Index de la deniere action a effectuer sur la voie courante */
	}

	if( voie -> device > 0 )
	{
		FlushRXBuffer( voie -> device );
	}

}



/*
 * init_connexion(-)
 *
 * Purpose:
 * --------
 * Init une voie pour le d‚but d'une connexion
 *
 * History:
 * --------
 * fplanque: Created
 * 17.05.94: fplanque: init des ptrs sur records en lecture / ReadLocks
 * 21.08.94: fplanque: tient compte de pIOField_CurrIn
 * 30.01.95: enlev‚ inits redondantes avec ENPG
 */
void	init_connexion( VOIE *pVoie_curr )
{
	VOIESTATE	state;

	/*
	 * Fixe dossier dans lequel on doit chercher les pages ecran:
	 * Pour l'instant: toujours dans le root: 
	 */
	pVoie_curr -> pecrandir = M_pecrangroup -> root_dir;	/* ROOT */
	/*
	 * Dossier pour les bases de donn‚es: 
	 */
	pVoie_curr -> pDataDir_Datas = M_dbasegroup -> root_dir;	/* ROOT */
	/*
	 * Dossier pour les textes: 
	 */
	pVoie_curr -> pDataDir_Texts = M_pDataGroup_Texts -> root_dir;	/* ROOT */

	/* 
	 * Etats: 
	 */
	state .log_modemcnx	= FALSE0;			/* Modem non connect‚ */
	state .phys_modemcnx = FALSE0;			/* Modem non connect‚ */
	pVoie_curr -> state = state;

	/*
	 * Pas de locks pour l'instant!
	 */
	pVoie_curr -> pCRLstElt_1stRLock	= NULL;	/* Liste des readlocks */
	pVoie_curr -> pCompRec_XLock			= NULL;	/* Enregistrement sur lequel on d‚tient un lock EXCLUSIF! */
	 		
	/* 
	 * Champs de saisie: 
	 * On doit mettre certains pointeurs … NULL pour ne pas
	 * que IsEditing r‚ponde TRUE_1 pendant la phase d'attente 
	 * de connexion!
	 *
    * v‚rifier que pIOField_ListIn == NULL
	 */
	pVoie_curr -> pIOField_CurrIn = NULL;
	pVoie_curr -> curr_textline	 = NULL;

	/*
	 * Entr‚es: 
	 */
	pVoie_curr -> entete_seq		= NIL;		/* Pour l'instant on est pas dans une s‚quence */
	pVoie_curr -> pro_compte		= 0;			/* On n'attend pas de codes de PRO 1, 2 ou 3 */
	pVoie_curr -> csi 				= NIL;		/* Pour l'instant on est pas en s‚quence CSI */
	pVoie_curr -> compose 			= NIL;		/* Pour l'instant on est pas en s‚quence de composition de caractŠre */
	pVoie_curr -> action_progress = APG_NONE;	/* Pas d'action en progress */

	/*
	 * ParamŠtres d'une page … une autre:
	 * Il n'y a pas de page pr‚c‚dente, donc pas de params transmis!:
	 */
	pVoie_curr -> pDataPage_LockedDB_OUT = NULL;
	pVoie_curr -> pCompRec_Locked_OUT = NULL;

}



/*
 * update_voie_enFinCnx(-)
 *
 * Purpose:
 * --------
 * Effectue diverses actions n‚cessaires lors de la d‚connexion d'une voie
 *
 * Algorythm:
 * ----------  
 * Eteind curseur
 * Execute actions necessaires lors de la sortie d'une page arbo.
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 * 13.07.95: fplanque: Remet les ptrs Login & Co sur NULL (corrige un BUG)
 */
void	actions_atEndCnx( 
			VOIE *	pVoie_curr )
{
	/* 
	 * Efface curseur: 
	 */
	csr_off( pVoie_curr -> device );

	/*
	 * effectue actions INDISPENSABLES lors de la sortie d'une page ARBO
	 */
	actions_atArbopgExit( pVoie_curr );
	
	/*
	 * Init Variables sp‚cifiques … la connexion
	 */
	/* TRACE2( "Freeing login:%s  1stName:%s", pVoie_curr -> pMsz_Login, pVoie_curr -> pMsz_FirstName ); */
	free_String( pVoie_curr -> pMsz_Login );
	pVoie_curr -> pMsz_Login = NULL;
	
	free_String( pVoie_curr -> pMsz_FirstName );
	pVoie_curr -> pMsz_FirstName = NULL;
	
	free_String( pVoie_curr -> pMsz_LastName );
	pVoie_curr -> pMsz_LastName = NULL;

	free_String( pVoie_curr -> pMsz_VFile );
	pVoie_curr -> pMsz_VFile = NULL;

	/*
	 * Plus de path courant:
	 */
	free_String( pVoie_curr -> pMsz_Path );
	pVoie_curr -> pMsz_Path = NULL;

}



/*
 * init_attente(-)
 *
 * Purpose:
 * --------
 * Init attente d'une connexion
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	init_attente( VOIE *pVoie_curr )
{
	/*
	 * Port: 
	 */
	int	device = pVoie_curr -> device;
		
	/*
	 * Signale d‚but connexion … l'‚cran: 
	 */
	add_textinf( pVoie_curr -> wi_params, "Attente de connexion" );

	/*
	 * Affiche attente … l'‚cran: 
	 */
	full_cls( device );
		
	sprintf( G_tmp_buffer, 
				"\033FStut One - Voie \033G%03d\033F - "
					"Mode \033G%s\033F\r\n\r\n"
					"Attente de connexion.\r\n",
				pVoie_curr -> no_voie, G_mode[ pVoie_curr -> mode ] );
	str_conout ( device, G_tmp_buffer );

	/*
	 * Passe en attente: 
	 */
	register_action( pVoie_curr, SLEEP, 0, 0, NULL );		/* Demande attente */

}



/*
 * dup_voies(-)
 *
 * Purpose:
 * --------
 * Duplique une liste de voies
 *
 * Notes:
 * ------
 * ATTENTION: ne copie pas les infos POINTEES par la voie
 * Il ne faudra donc garder que l'une ou l'autre des copies!
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
VOIE	*	dup_voies( const VOIE *voie_srce )
{
	/*
	 * Pointeurs: 
	 */
	VOIE	 *first_voie_dest;			/* 1er elt de la liste destination */
	VOIE	 * *lastptr_to_next = &first_voie_dest;	/* Adr du dernier ptr sur le champ suivant */
	VOIE	 *voie_dest;					/* Elt courant de la liste destination */

	/*
	 * Copie tous les champs: 
	 */
	while( voie_srce != NULL )
	{
		/*
		 * Cr‚e nouveau champ 
		 */
		voie_dest = Construct_Voie( );

		/*
		 * Copie les paramŠtres 
		 */
		*voie_dest = *voie_srce;

		/*
		 * Lie ce champ au pr‚c‚dent: 
		 */
		*lastptr_to_next = voie_dest;

		/*
		 * Nouvelle adr du dernier ptr sur champ suivant: 
		 */
		lastptr_to_next = &(voie_dest -> next);
						
		/*
		 * Passe au champ source suivant: 
		 */
		voie_srce = voie_srce -> next;
	}
	/*
	 * Signale fin de la liste: 
	 */
	*lastptr_to_next = NULL;

	/*
	 * Retourne ptr sur nlle liste: 
	 */
	return	first_voie_dest;
}



/*
 * free_voies(-)
 *
 * Purpose:
 * --------
 * Efface 1 liste de params de voies de la m‚moire
 *
 * History:
 * --------
 * fplanque: Created
 */
void	free_voies( 
			VOIE *pVoie_curr )
{
	VOIE *next_voie;
	
	while( pVoie_curr != NULL )
	{
		next_voie = pVoie_curr -> next;		/* Voie suivantz */
		FREE( pVoie_curr );						/* Efface la voie courante */
		pVoie_curr = next_voie;					/* Passe … la voie suivante */
	}
}


/*
 * Voie_LocalSpeed(-)
 *
 * Passe en vitesse locale
 *
 * 08.04.95: Created
 */
void	Voie_LocalSpeed(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	if( pVoie_curr -> state.n_speed != 0 )
	{	/*
	 	 * Passe en 4800 bps
		 */							
		add_textinf( pVoie_curr -> wi_params, " Passage en vitesse locale (4800 bps)" );
		MinitelPort_ChgeSpeed( pVoie_curr -> device, 4800 );
		pVoie_curr -> state.n_speed = 0;
	}
}


/*
 * Voie_LineSpeed(-)
 *
 * Passe en vitesse "ligne"
 *
 * 08.04.95: Created
 */
void	Voie_LineSpeed(
			VOIE *	pVoie_curr )	/* In: Voie concern‚e */
{
	if( pVoie_curr -> state.n_speed != 1 )
	{	/*
	 	 * Passe en 1200 bps
		 */							
		add_textinf( pVoie_curr -> wi_params, " Passage en vitesse ligne (1200 bps)" );
		MinitelPort_ChgeSpeed( pVoie_curr -> device, 1200 );
		pVoie_curr -> state.n_speed = 1;
	}
}


/*
 * lancer_serv(-)
 *
 * Purpose:
 * --------
 * Lancement du serveur
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 26.12.94: le serv ne se lance pas si on a pas pu ouvrir les fenˆtres
 * 08.02.95: curseur souris en croix
 * 10.07.95: corrig‚ bug de lib‚ration de la voie en SMODE_TEST
 */
void	lancer_serv( 
			int mode, 
			int menu_title )
{
	VOIE	*	pVoie_FirstToHandle;	/* Liste des voies … g‚rer */
	VOIE	*	pVoie_curr;				/* Voie en cours de traitement */
	int		dev_offset;				/* Device offset voie courante */
	BOOL		b_Error = FALSE0;		/* Pour l'instant pas d'erreur empˆchant le lancement du serv */

	/*
	 * D‚s‚lectionne entr‚e de menu s‚lectionn‚e: 
	 */
	menu_tnormal(G_menu_adr, menu_title, 1);
	/*
	 * Coupe le menu: 
	 */
	enable_menu( G_menu_adr, FALSE0 );

	/*
	 * Fixe pointeurs: 
	 */
	M_arbogroup 			= find_datagroup_byType( DTYP_ARBO );	/* Datagroup arbo */
	M_pecrangroup			= find_datagroup_byType( DTYP_PAGES );	/* Datagroup pages-‚cran */
	M_dbasegroup			= find_datagroup_byType( DTYP_DATAS );	/* Datagroup bases de donn‚es */
	M_pDataGroup_Texts	= find_datagroup_byType( DTYP_TEXTS );	/* Datagroup textes */


	/*
	 * Init des voies: 
	 */
	switch( mode )
	{
		case	SMODE_TEST:
			/*
			 * Cr‚ation de la cnx logique: 
			 */
			pVoie_FirstToHandle = Construct_Voie( );	
			/*
			 * Initialisation: 
			 */
			pVoie_FirstToHandle -> no_voie = 1;					/* Num‚ro de la voie */
			pVoie_FirstToHandle -> device = G_term_dev;			/* Port terminal */
			pVoie_FirstToHandle -> mode = VMODE_TEST;			/* Mode de fonctionnement */
			pVoie_FirstToHandle -> next = NULL;					/* Pas d'autre voie (pour l'instant) */
			voie_phase_init( pVoie_FirstToHandle, TRUE_1 );	/* Met cette voie en phase d'init */

			/*
			 * Cr‚e le titre: 
			 */
			dev_offset = device_offset( pVoie_FirstToHandle -> device );
			sprintf( G_tmp_buffer, " Test sur Voie locale (%s) ", 
							G_inst_drv_list[ dev_offset ] .name +2 );

			/*
			 * Ouvre la fenˆtre serveur: 
			 */
			pVoie_FirstToHandle -> wi_params = ouvre_fenetre( CLASS_TEXT, TYP_TRACK,
															NULL,NULL,NULL, G_tmp_buffer );
			if( pVoie_FirstToHandle -> wi_params == NULL )
			{
				b_Error = TRUE_1;	/* On ne peut lancer le serv ds ces conditions! */
			}
		
			/*
			 * Init Terminal: 
			 */
			csr_off( pVoie_FirstToHandle -> device );	/* Eteind curseur */

			break;

		case	SMODE_NORMAL:
			/*
			 * On va utiliser les voies allou‚es: 
			 */
			pVoie_FirstToHandle = G_voies;		
		
			/*
			 * Init des voies: 
			 */
			pVoie_curr = pVoie_FirstToHandle;
			while( pVoie_curr != NULL )
			{	/*
				 * Tant qu'il y a une voie: 
				 * Cr‚e le titre: 
				 */
				dev_offset = device_offset( pVoie_curr -> device );
				sprintf( G_tmp_buffer, " Voie %03d (%s, %s) ", 
								pVoie_curr -> no_voie,
								G_inst_drv_list[ dev_offset ] .name +2,
								G_mode[ pVoie_curr -> mode ] );
								

				/*
				 * Ouvre la fenˆtre serveur: 
				 */
				pVoie_curr -> wi_params = ouvre_fenetre( CLASS_TEXT, TYP_TRACK,
																	NULL,NULL,NULL, G_tmp_buffer );
				if( pVoie_curr -> wi_params == NULL )
				{
					b_Error = TRUE_1;	/* On ne peut lancer le serv ds ces conditions! */
					break;
				}

				/*
				 * Init Terminal: 
				 */
				csr_off( pVoie_curr -> device );	/* Eteind curseur */

				/*
				 * Passe … la voie suivante: 
				 */
				pVoie_curr = pVoie_curr -> next;

			}

			break;

		default:
			ping();
	}

	/* ------------------- */
	/* Gestion du serveur: */
	/* ------------------- */
	if( ! b_Error )
	{
		graf_mouse( OUTLN_CROSS, 0 );		/* Change curseur souris */
		run_server( pVoie_FirstToHandle );
		graf_mouse( BUSYBEE, 0 );		/* Change curseur souris */
	}

	/*
	 * Ferme les fenˆtres de tracking: 
	 */
	pVoie_curr = pVoie_FirstToHandle;
	while( pVoie_curr != NULL )
	{	/*
		 * Tant qu'il y a une voie: 
		 */
		if( pVoie_curr -> wi_params != NULL )
		{	/*
			 * Si cette voie … une fenˆtre de tracking: 
			 */
			ferme_fenetre( pVoie_curr -> wi_params, TRUE_1 );
		}
	
		/*
		 * Passe … la voie suivante: 
		 */
		pVoie_curr = pVoie_curr -> next;
	}

	/*
	 * Si mode test: 
	 */		
	if ( mode == SMODE_TEST )
	{	/*
		 * Supprime la voie temporaire: 
		 */
		FREE( pVoie_FirstToHandle );
	}

	/*
	 * R‚-installe menu: 
	 */
	enable_menu( G_menu_adr, TRUE_1 );

}



/*
 * run_server(-)
 *
 * Purpose:
 * --------
 * Gestion du serveur
 * KERNEL
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.05.94: fplanque: demande ReadLock lors de l'ouverture database
 * 17.05.94: Actions … effectuer lors d'un JUMP page ou d'une DECO sorties dans des fonctions independantes
 * 17.05.94: Ex‚cute les actions pr‚c‚dentes sur toutes les voies connect‚s lorsque le serveur est interrompu par le sysop
 * 24.09.94: correction bug lors d'une rub vide
 * 19.12.94: gestion DPAG
 * 26.12.94: gestion HALT
 * 08.02.95: modifi‚ gestion timeslice overload
 * 28.03.95: gestion csr on/off par WAIT
 * 28.03.95: simplifi‚ code JUMP
 * 13.07.95: ‚tendu DWLD
 * 14.10.95: utilisation de Action_IsLong() et verification de la prochaine action a effectuer
 * 14.10.95: une action JUMP provoque un saut obligatoire
 */
void	run_server( 
			VOIE *	voies )
{
	#define	WATCH_CURRACTION	NO0

	/* 
	 * Variables: 
	 */
	BOOL			break_serv	= FALSE0;	/* Le serveur tourne... */
	BOOL			break_cnx	= FALSE0;	/* La cnx tourne... */

#if ACCEPT_REMOTE
	int			ring_detect = FALSE0;	/* Pour l'instant on ne d‚tecte pas de sonnerie */
#endif

	VOIE		*	pVoie_curr = voies;	/* Voie courante */
	clock_t		curr_time;
	clock_t		curr_timeslend;		/* Fin de la tranche de temps actuelle */
	clock_t		curr_timeoverload;	/* Temps … partir duquel on est vraiment en OVERLOAD */
	int			action_head;			/* Tete de la pile FIFO d'actions */
	int			curraction;				/* Action en cours */
	DATADIR	*	curr_datadir;			/* Datadir courant */
	KEYCODE		curr_keypress;			/* Resultat de la saisie sur voie courante */
	WIPARAMS	*	tracking_win;			/* Fenˆtre de tracking de la voie courante */

	/*
	 * Kernel Panic: ProblŠme au d‚marrage => HALT
	 * Pour l'instant le serv d‚marrae normalement:
	 */
	BOOL			b_Halt = FALSE0;

	/* 
	 * Boucle principale de gestion des voies par timeslice: 
	 */	
	do
	{	/*
		 * Teste ‚vŠnements GEM: 
		 */
		break_serv = sys_events();

		/*
		 * D‚termine fin de la tranche de temps 
		 * accord‚e au traitement de la voie courante: 
		 */
		curr_timeslend = clock( ) + TIMESLICE;
		curr_timeoverload = curr_timeslend + TIMESLICE;

		/*
		 * Fenˆtre de tracking de la voie courante: 
		 */
		tracking_win = pVoie_curr -> wi_params;

		/*
		 * D‚termine action en cours sur la voie courante: 
		 */
		action_head = pVoie_curr -> action_head;	/* Tˆte pile FIFO */
		curraction = pVoie_curr -> action[ action_head ] .no;

		#if	WATCH_CURRACTION
			printf( "\x1BY\x20\x5D%s", M_Tsz_ActionName[ curraction ] );
		#endif

		/*
		 * ----------------------------------------------
		 * Boucle de traitement des actions sur UNE voie:
		 * ----------------------------------------------
		 */
		do
		{
			/* 
			 * Selon action … effectuer: 
			 */
			switch( curraction )
			{
				case	INIT:
					/*
					 * ---------------------------------
					 * Phase d'initialisation de voie: 
					 * ---------------------------------
					 * ParamŠtre le terminal: 
					 */
					param_local( pVoie_curr -> device );
	
					/*
					 * Initialisation de la connexion sur la voie: 
					 */
					init_connexion( pVoie_curr );
	
					/*
					 * En fonction du mode de fonctionnement: 
					 */
					switch( pVoie_curr -> mode )
					{
						case	VMODE_NORMAL:
						case	VMODE_OFFLINE:
							/*
							 * Init de l'attente de connexion, passage en SLEEP: 
							 */
							init_attente( pVoie_curr );
							break;
							
						case	VMODE_TEST:
							if( b_Halt )
							{
								add_textinf( tracking_win, "Kernel Panic: Process Halted!" );
								register_action( pVoie_curr, HALT, 0, 0, NULL );
								break;
							}

							/*
							 * Signale d‚but connexion … l'‚cran: 
							 */
							add_textinf( tracking_win, "Connexion Test (Off-Line)" );
							
							/*
							 * D‚but de connexion: 
							 */
							register_action( pVoie_curr, START, 0, 0, NULL );		/* Demande START cnx */
	
							break;
					}
					break;

				case	HALT:
					/*
					 * La voie est arrˆt‚e:
					 */
					break;

				case	SLEEP:
				{	/*------------------------------------*/
					/* Phase d'attente d'appel/connexion: */
					/*------------------------------------*/
					#if ACCEPT_REMOTE
					/* -------------------------------- */
					/* Teste bouton droit de la souris: */
					/* -------------------------------- */
					if( pVoie_curr -> no_voie == VOIE_SOURIS )
					{	/*
						 * Si on est sur la voie no 1: 
						 */
						int	bstate, x, y;
						/*
						 * Teste ‚tat de la souris: 
						 */
						vq_mouse( G_ws_handle, &bstate, &x, &y );
						bstate &= 0x0002;	/* Garde juste le bit du bouton droit */

						if( !ring_detect && bstate )
						{	/*
							 * Si on vient d'appuyer sur "Feu": 
							 */
							ring_detect = TRUE_1;		/* Sonnerie d‚tect‚e */
							
							/*
							 * Signale d‚tection: 
							 */
							add_textinf( tracking_win, "  D‚tection Feu-Joystic 1 / Click droit-Souris" );

							/*
							 * Envoi porteuse...: 
							 */
							try_connection( pVoie_curr );
							
						}
						else if( ring_detect && !bstate )
						{	/*
							 * Si fin d'appui sur "Feu": 
							 */
							ring_detect = FALSE0;		/* Plus de sonnerie */
						}
					}
					#endif
					
					/* ----------------------- */
					/* Attend codes en entr‚e: */
					/* ----------------------- */
					curr_keypress = get_keyboard( pVoie_curr );
					/* printf("\nvoie=%d key=%d \r", pVoie_curr -> no_voie, curr_keypress ); */

					if( curr_keypress != KEY_NONE	)
					{	/*
						 * Affiche touche press‚e: 
						 */
						affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

						switch( curr_keypress )
						{
							case	KEY_ENVOI:
								/*
								 * Si on a appuy‚ sur ENVOI 
								 * D‚but de connexion locale demand‚! : 
								 * Signale d‚but connexion … l'‚cran: 
								 */
								add_textinf( tracking_win, "Connexion Off-Line" );
								
								/*
								 * D‚but de connexion: 
								 */
								register_action( pVoie_curr, START, 0, 0, NULL );		/* Demande START cnx */

								break;
								
							#if ACCEPT_REMOTE
							case	EVT_APPEL:
								/*
								 * D‚tection d'un appel:
								 * Envoi porteuse...: 
								 */
								try_connection( pVoie_curr );

								break;
							#endif
						}
					}
					break;
				}

				#if ACCEPT_REMOTE
				case	CNCT:
				{	/*
				 	 * ------------------------------------------------
					 * Phase d'attente d'‚tablissement de la connexion:
					 * ------------------------------------------------
					 * Attend codes en entr‚e: 
					 */
					curr_keypress = get_keyboard( pVoie_curr );

					/*
					 * Selon code re‡u: 
					 */
					switch( curr_keypress )
					{
						case	KEY_NONE:
						{	/*
							 * S'il ne se passe rien: 
							 * Selon o— on est et dans la proc‚dure de connexion: 
							 */
							switch( pVoie_curr -> action_progress )
							{
								case	APG_CNXSTART:
								case	APG_SPEED:
									if ( clock() >= pVoie_curr -> acq_timeout )
									{	/*
										 * Si on d‚passe le timeout acquitements: 
										 * Signale ‚chec connexion … l'‚cran: 
										 */
										if( pVoie_curr -> action_progress == APG_CNXSTART )
										{
											add_textinf( tracking_win, 
												"    Impossible de fixer la vitesse Modem (Timeout)" );
										}
										else
										{
											add_textinf( tracking_win,
												"    Impossible d'envoyer une porteuse (Timeout)" );
										}

										/*
										 * Reset de la vitesse:
										 */							
										Voie_LocalSpeed( pVoie_curr );

										/*
										 * Init de l'attente d'une nouvelle connexion, passage en SLEEP: 
										 */
										pVoie_curr -> action_progress = APG_NONE;		/* Plus de proc‚dure en cours */
										init_attente( pVoie_curr );

									}
									break;

								case	APG_PORTEUSE:
									if( clock() >= pVoie_curr -> key_timeout )
									{	/*
										 * Si on d‚passe le timeout connexion: 
										 */
		
										/*
										 * Signale ‚chec connexion … l'‚cran: 
										 */
										add_textinf( tracking_win, "    Pas de connexion (Timeout)" );

										/*
										 * D‚connecte le Modem (Coupe la porteuse): 
										 */
										deconnecte_modem( pVoie_curr -> device );
									
										/*
										 * Reset de la vitesse:
										 */							
										Voie_LocalSpeed( pVoie_curr );

										/*
										 * Init de l'attente d'une nouvelle connexion, passage en SLEEP: 
										 */
										pVoie_curr -> action_progress = APG_NONE;		/* Plus de proc‚dure en cours */
										init_attente( pVoie_curr );
		
									}
									break;
							
								default:
									signale( "Action-progress error" );

									/*
									 * Reset de la vitesse:
									 */							
									Voie_LocalSpeed( pVoie_curr );

									/* 
									 * Met la voie en phase d'initialisation: 
									 */
									voie_phase_init( pVoie_curr, FALSE0 );
									action_head = pVoie_curr -> action_head;
							}
							
							break;							
						
						}

						case	ACT_CONNECT:
						{	/*
							 * Si la connexion a ‚t‚ ‚tablie: 
							 */
							int	device = pVoie_curr -> device;

							/*
							 * Signale d‚but connexion … l'‚cran: 
							 */
							add_textinf( tracking_win, "Communication ‚tablie" );

							/*
							 * Signale cnx ds flags: 
							 */
							pVoie_curr -> state .log_modemcnx  = TRUE_1;	/* Modem connect‚ */
							pVoie_curr -> state .phys_modemcnx = TRUE_1;	/* Modem connect‚ */

							/*
							 * Affiche message: 
							 */
							full_cls( device );
							pos( device, 1, 0 );
							str_conout ( device, 
												STUT_CONNECTNAME "\n"
												"Communication ‚tablie" );
						
							/*
							 * Debug info: 
							 */	
							pos( device, 1, 5 );
							sprintf( G_tmp_buffer, 
												"\033FSystem Info:\r\n"
												"Voie \033G%03d\033F\r\n"
												"Port \033G%s\033F\r\n",
												pVoie_curr -> no_voie, 
												G_inst_drv_list[ device_offset( pVoie_curr -> device ) ] .name +2  );
												str_conout ( device, G_tmp_buffer );

							/*
							 * ParamŠtre le terminal: 
							 */
							param_normal( pVoie_curr -> device );


							/*
							 * D‚but de connexion: 
							 */
							register_action( pVoie_curr, START, 0, 0, NULL );		/* Demande START cnx */
							
							break;
						}
						
						case	ECHEC_CONNECT:
						{	/*
							 * Si l'‚tablissement de la connexion a ‚chou‚: 
							 */

							/* Signale ‚chec connexion … l'‚cran: */
							add_textinf( tracking_win, "    Echec connexion" );
						
							/* Init de l'attente d'une nouvelle connexion, passage en SLEEP: */
							init_attente( pVoie_curr );

							break;
						}
						
					}
					break;
				}
				#endif
									
				case	DECO:
				{	/*
					 *---------------------------------
					 * Phase d'attente de d‚connexion: 
					 *---------------------------------
					 * Teste si le modem est d‚j… physiquement d‚connect‚: 
					 */
					if ( !pVoie_curr -> state .phys_modemcnx )
					{	/*
					 	 * On est d‚j… d‚connect‚: 
					 	 */
						curr_keypress = ACT_DISCONNECT;
					}
					else
					{	/* 
						 * S'il faut attendre la d‚co physique: 
						 * Attend codes en entr‚e: 
						 */
						curr_keypress = get_keyboard( pVoie_curr );
					}
					
					/* 
					 * Selon code re‡u: 
					 */
					switch( curr_keypress )
					{
						case	KEY_NONE:
							/* 
							 * S'il ne se passe rien: 
							 */
							if ( clock() >= pVoie_curr -> acq_timeout )
							{	/* 
								 * Si on d‚passe le timeout acquitements: 
								 */

								/* 
								 * Signale ‚chec d‚connexion: 
								 */
								add_textinf( tracking_win, "WARNING: La d‚connexion a ‚chou‚!" );

								/* 
								 * Met la voie en init (sans passer par d'‚ventuelles autres actions): 
								 */
								voie_phase_init( pVoie_curr, FALSE0 );
								action_head = pVoie_curr -> action_head;

							}
							break;
						
						case	ACT_DISCONNECT:
							/* 
							 * Si le modem s'est physiquement d‚connect‚: 
							 * Signale fin de connexion … l'‚cran: 
							 */
							add_textinf( tracking_win, "Connexion interrompue." );
															 
							/*
							 * Reset de la vitesse:
							 */							
							Voie_LocalSpeed( pVoie_curr );

							/* 
							 * Met la voie en init (sans passer par d'‚ventuelles autres actions): 
							 */
							voie_phase_init( pVoie_curr, FALSE0 );
							action_head = pVoie_curr -> action_head;

							break;
					
					}
					break;
				}
				

				case	START:
				{	/*------------------------*/
					/* D‚but d'une connexion: */
					/*------------------------*/
					/*
					 * Met le clavier en minuscules: 
					 */
					param_minitel( pVoie_curr -> device, pVoie_curr -> state .log_modemcnx );
					
					/*
					 * Rentre dans le nouveau dossier: 
					 */		
					curr_datadir = M_arbogroup -> root_dir;	/* Dossier courant */
					break_cnx = enter_dir( pVoie_curr, curr_datadir );		
					if( break_cnx )
					{	/*
					 	 * Impossible de lancer le serv!!
					 	 */
						b_Halt = TRUE_1;
					}
					break;
				}					


				case	WAIT:
				{	/*
					 * ----------------------------------
					 * Phase d'attente d'action connect‚:
					 * ----------------------------------
					 * Teste le clavier du/(des) connect‚(s): 
					 */
					curr_keypress = get_keyboard( pVoie_curr );
					if( curr_keypress == KEY_NONE )
					{
						break;
					}

					/*
					 * Eteind curseur 
					 */
					csr_off( pVoie_curr -> device );
					/*
					 * R‚agit en fonction: 
					 */
					switch( curr_keypress )
					{
						case	ACT_DISCONNECT:
							/* 
							 * D‚connexion physique:
							 * Signale dans flags: 
							 */
							pVoie_curr -> state .log_modemcnx = FALSE0;	/* Modem d‚connect‚ */
							pVoie_curr -> state .phys_modemcnx = FALSE0;	/* Modem d‚connect‚ */
							/* Continue.... */

						case	KEY_FIN:
							/* 
							 * Connexion/Fin: 
							 */
							affiche_touche( pVoie_curr, curr_keypress );		/* Affiche nom de la touche */

							/* 
							 * Fin (Interruption) de la connexion: 
							 */
							break_cnx = TRUE_1;

							break;

						default:
							switch( (pVoie_curr -> arboparams) -> fnct_no )
							{	/*
								 * Selon la fonction de la page arbo: 
								 */

								case	FA_ECRI_MSG:
									/*
									 * Ecriture d'un message 
									 */
									keyaction_ecri_msg( curr_keypress, pVoie_curr );
									break;
								
								case	FA_LECT_MSG:
									/*
									 * Lecture message:
									 */
									LectMsg_KeyAction( curr_keypress, pVoie_curr );
									break;
									
								case	FA_DISP_TEXT:
									/*
									 * Affichage d'un texte: 
									 */
									DispText_KeyAction( curr_keypress, pVoie_curr );
									break;
									
								case	FA_ID:
									/*
									 * Identification:
									 */
									keyaction_Identification( curr_keypress, pVoie_curr ); 
									break;
	
								case	FA_NEW_ACCOUNT:
									/*
									 * Cr‚ation d'un nouveau compte:
									 */
									keyaction_NewAccount( curr_keypress, pVoie_curr ); 
									break;

								case	FA_LIST:
								case	FA_DIRECTORY:
									/*
									 * Liste de messages:
									 */
									ListMsg_KeyAction( curr_keypress, pVoie_curr ); 
									break;

								case	FA_FILESEL:
									/*
									 * S‚lecteur de fichiers:
									 */
									FileSel_KeyAction( curr_keypress, pVoie_curr ); 
									break;
									
								/* case	FA_MENU:			/* Menu */
								/* case	FA_DOWNLOAD:	/* T‚l‚chargement */
								default:						/* Autres fonctions */
									keyaction_std( curr_keypress, pVoie_curr );
							}
					}
					
					/*
					 * Regarde s'il y a des actions en attente:
					 */
					if( action_head == pVoie_curr -> action_tail
						&& GetEditMode( pVoie_curr ) == FIELDEDIT )
					{	/*
						 * Pas de nouvelle action:
						 * On peut rallumer le curseur:
						 */
						csr_on( pVoie_curr -> device );
					}
					break;
				}

				case	JUMP:
				{	/*
					 * -------------------------------------------
					 * Si on est en phase de changement de page:
					 * -------------------------------------------
					 * Nom de la prochaine page:
					 */
					char		*	new_page = (char *) (pVoie_curr -> action[ action_head ] .ptr1);		
					int		jmp_result;
					
					/* 
					 * Saute … la page demand‚e: 
					 * Saut Obligatoire
					 */
					add_textinf( tracking_win, " Saut … la page arbo: " );
					jmp_result = jmp_page( pVoie_curr, new_page , TRUE_1 );	

					/* 
					 * En fonction du r‚sultat: 
					 */
					switch( jmp_result )
					{
						case	RAS0:		
							/* 
							 * OK, rien a signaler:
							 * effectue actions INDISPENSABLES lors du changement de page
							 */
							actions_atArbopgExit( pVoie_curr );

							break;
						
						default:
							/*
							 * Erreur: 
							 */		
							break_cnx = TRUE_1;		/* Interruption de la connexion */
							break;
					}
					break;						
				}
			
				case	DISP:
					/*
					 * -------------------------------------------
					 * Si on est en phase d'affichage sur l'‚cran:
					 * -------------------------------------------
					 * Affiche page VDT de FOND: 
					 */
					break_cnx = affiche_ecran( pVoie_curr, pVoie_curr -> action[ action_head ] .int1 );
					break;		
					
									
				case	ENPG:
					/*
					 * ---------------------------------------------------------
					 * ENTER PAGE: initialisations … l'entr‚e sur une nlle page:
					 * ---------------------------------------------------------
					 * La seule action ayant d‚j… ‚t‚ faite sur la nouvelle page 
					 * aprŠs le JUMP est le DISP initial du fond d'‚cran
					 */
					break_cnx = handle_ENPG( pVoie_curr );
					break;


				case	OPDB:
				{	/*
				 	 * -----------------------------------------------
					 * Si on est en phase d'ouverture base de donn‚es:
					 * -----------------------------------------------
					 */
					int	n_fnct = pVoie_curr -> action[ action_head ] .int1;
					break_cnx = Serv_EnterDataPage( pVoie_curr, DTYP_DATAS, n_fnct );

					if( !break_cnx )
					{
						switch( (pVoie_curr -> arboparams) -> fnct_no )
						{
							case	FA_LECT_MSG:	
								LectMsg_OPDB( pVoie_curr, n_fnct );
								break;
							
							case	FA_LIST:
							case	FA_DIRECTORY:
								ListDB_OPDB( pVoie_curr );
								break;
						}					
					}
						
					break;
				}


				case	OTXT:
					/*
				 	 * ------------------------------------------
					 * Si on est en phase d'ouverture d'un texte:
					 * ------------------------------------------
					 */
					break_cnx = Serv_EnterDataPage( pVoie_curr, DTYP_TEXTS, pVoie_curr -> action[ action_head ] .int1 );
					break;


				case	DDAT:
					/*
					 * ------------------------------------------------------
					 * Si on est en phase d'affichage de donn‚es sur l'‚cran:
					 * ------------------------------------------------------
					 * Selon la fonction de la page arbo: 
					 */
					switch( (pVoie_curr -> arboparams) -> fnct_no )
					{
						case	FA_ECRI_MSG:	
							EcriMsg_DispData( pVoie_curr );
							break;

						case	FA_LECT_MSG:	
							LectMsg_DispData( pVoie_curr );
							break;
							
						case	FA_DISP_TEXT:	
							DispText_DispData( pVoie_curr );
							break;
					
						case	FA_LIST:
						case	FA_DIRECTORY:
							ListDB_DispData( pVoie_curr );
							break;
					
						case	FA_FILESEL:
							FileSel_DispData( pVoie_curr );
							break;
					
						default:
							signale( "Ne sait afficher les data pour ce type de page" );						
					}
					break;
				
	
				case	DREC:
					/*
					 * -------------------------------------------------
					 * Si on est en phase d'affichage d'un nouveau message
					 * -------------------------------------------------
					 */
					switch( (pVoie_curr -> arboparams) -> fnct_no )
					{
						case	FA_LECT_MSG:	
							LectMsg_DispMsg( pVoie_curr );
							break;

						case	FA_FILESEL:	
							FileSel_DispRec( pVoie_curr );
							break;

						default:
							signale( "Ne sait afficher les records pour ce type de page" );						
					}
					break;

				
				case	DPAG:
					/*
					 * -------------------------------------------------
					 * Si on est en phase d'affichage d'une page de MSG ou de texte
					 * -------------------------------------------------
					 */
					switch( (pVoie_curr -> arboparams) -> fnct_no )
					{
						case	FA_LECT_MSG:	
						case	FA_DISP_TEXT:	
							Generic_DispPage( pVoie_curr );
							break;
					
						case	FA_LIST:
						case	FA_DIRECTORY:
							ListDB_DispPage( pVoie_curr );
							break;
					
						case	FA_FILESEL:
							FileSel_DispPage( pVoie_curr );
							break;
					
						default:
							signale( "Ne sait afficher la page pour ce type arbo" );						
					}
					break;

				case	DWLD:
					/*
					 * -----------------------------------------------
					 * Si on est en train de transmettre des fichiers:
					 * -----------------------------------------------
					 */
					if( DownLoad_USLTP( pVoie_curr ) == TRUE_1 )
					{	/*
						 * Signale fin de connexion:
						 */
						break_cnx = TRUE_1;
					}
					break;			

					
				case	EFLD:
					/*
					 * On entre ds un champ:
					 */
					break_cnx = start_fieldedit( pVoie_curr, pVoie_curr -> action[ action_head ] .int1, pVoie_curr -> action[ action_head ] .ptr1 );

					/*
					 * Place curseur: 
					 */
					place_csr( pVoie_curr );

					break;			

				
				case	CPOS:
					/*
					 * ------------------------------------------------------------
					 * S'il faut repositionner le curseur pour continuer l'‚dition:
					 * ------------------------------------------------------------
					 * Positionne curseur: 
					 */
					place_csr( pVoie_curr );

					break;			
				
				
				case	CLRF:
					/*
					 * -----------------------------------------------------------
					 * On a demand‚ un Clear Field sur un certain champ de saisie:
					 * (utilis‚ par exemple, si on attend une NOUVELLE saisie)
					 * -----------------------------------------------------------
					 */
					InField_Clear( pVoie_curr, pVoie_curr -> action[ action_head ] .ptr1 );
					break;


				default:
					ping();
					TRACE1("Action inconnue: %d", curraction);
			}


			if( ! break_cnx )
			{ /*
			 	* V‚rifie qu'on sait quelle action on va effectuer ensuite:
			 	*/			
				if( action_head == pVoie_curr -> action_tail
					&& Action_IsLong( curraction ) == FALSE )
				{	/*
					 * Si on ‚tait sur une action courte et qu'il n'y a pas
					 * d'action suivante, c'est qu'il y a un serieux probleme!
					 */
					add_textinf( pVoie_curr -> wi_params, "ERREUR: Plus aucune action … effectuer!" );
					ping();
					break_cnx = TRUE_1;
				}
			}
		
			/* 
			 * Teste si la connexion a ‚t‚ interrompue:
			 * Sinon, teste s'il faut passer … l'action suivante: 
			 */
			if( break_cnx )
			{	/*
			    * --------------------
				 * Fin d'une connexion:
				 * --------------------
				 * Effectue toutes les actions n‚cessaires
				 * en fin de connexion:
				 */
				actions_atEndCnx( pVoie_curr );
				 
				/*
				 * Teste si on a d‚j… demand‚ la d‚connexion du modem: 
				 */
				if( pVoie_curr -> state .log_modemcnx )
				{	/*
					 * Si on a pas encore d‚connect‚: 
					 * D‚connexion: 
					 */
					deconnecte_modem( pVoie_curr-> device );
					/*
					 * Signale dans state: 
					 */
					pVoie_curr -> state .log_modemcnx = FALSE0;	/* Logiquement, le modem est maintenant d‚connect‚ */
				}

				/* 
				 * Fixe ‚ch‚ance timeout de d‚connexion: 
				 */
				pVoie_curr -> acq_timeout = clock( ) + ACQ_TIMEOUT;
				
				/* 
				 * Met la voie en attente imm‚diate de d‚co physique: 
				 */
				pVoie_curr -> action[ 0 ] .no	= DECO;	/* Action en cours */
				pVoie_curr -> action_head 		= 0;		/* index Action en cours sur la voie courante */
				pVoie_curr -> action_tail 		= 0;		/* Index de la deniere action a effectuer sur la voie courante */
				curraction = DECO;							/* Action en cours */
				action_head = 0;								/* Index action en cours */

				/* 
				 * On remet le flag de fin de cnx … 0 pour la suite (sinon il y aurait d‚connexion en chaine) 
				 */
				break_cnx = FALSE0;														

			}
			else if( action_head != pVoie_curr -> action_tail )
			{	/*
				 *	---------------------------- 
				 * Si on est pas sur la deniŠre action de la tasklist
				 * (auquel cas, il vaut mieux que cette action soit un WAIT
				 *  ou un truc similaire!!!) :
				 * Passage … l'action suivante:
				 *	---------------------------- 
				 */
				if ( action_head == NB_ACTS_MAX-1 )
				{
					action_head = 0;
				}
				else
				{
					action_head++;
				}
				/*
				 * Sauve index action en cours sur la voie courante: 
				 */
				pVoie_curr -> action_head = action_head;
			
				/*
				 * D‚termine prochaine action … ‚x‚cuter: 
				 */
				curraction = pVoie_curr -> action[ action_head ] .no;
				#if	WATCH_CURRACTION
					printf( "\x1BY\x20\x5D%s", M_Tsz_ActionName[ curraction ] );
				#endif
			}
	
			/* 
			 * Contr“le dur‚e de traitement de la voie courante: 
			 */
			curr_time = clock();

			if( curr_time >= curr_timeoverload )
			{	/*
				 * Overload!
				 */
				add_textinf( tracking_win, "Info: TIMESLICE OVERLOAD!" );
			
				/* 
				 * Interrompt le traitement de la voie courante 
				 * et passe … la suivante 
				 */
				break;										/* ################## */
			}

			if( curr_time >= curr_timeslend )
			{
				/* 
				 * Interrompt le traitement de la voie courante 
				 * et passe … la suivante 
				 */
				break;										/* ################## */
			}
			
		}	/* Fin de la boucle d'‚x‚cution des action de LA VOIE COURANTE */			
		while( Action_IsLong( curraction ) == FALSE
				&&	curraction != INIT );	/* ou reinitialisation (c'est pas hyper press‚) */

		/*
		 * ---------------------------
		 * Passage … la voie suivante:
		 * ---------------------------
		 */	
		/* Suggest: on pourrait optimiser en faisant une liste des voies cyclique */
		if ( pVoie_curr -> next != NULL )
		{	/*
			 * S'il y a une voie aprŠs: 
			 */
			pVoie_curr = pVoie_curr -> next;	/* Passe … la voie suivante */
		}
		else
		{	/*
			 * Si c'‚tait la derniŠre voie: 
			 */
			pVoie_curr = voies;					/* Revient … la premiŠre voie */
		}
					
	}	/* Fin de la boucle de gestion des voies par timeslices */
	while( break_serv == FALSE0 );

	/* 
	 * On a choisi d'interrompre le serveur:
	 * D‚connexion des voies qui seraient encore connect‚es: 
	 */
	for( 
		pVoie_curr = voies; 
		pVoie_curr != NULL; 
		pVoie_curr = pVoie_curr -> next )
	{

		/*
		 * Teste si la voie est connect‚e:
		 */
		if( pVoie_curr -> action[ pVoie_curr -> action_head ] .no != SLEEP )
		{	/* 
			 * Si la voie est connect‚e
			 *
			 * PROVISOIRE: Faut t'il d‚connecter?
			 *   et que faire si curraction= CNCT, DECO, INIT... ? (phases critiques)
			 */
			 
			/* printf( "\nPseudo d‚connexion de la voie %d    ", pVoie_curr -> no_voie ); */
			 
			/*
			 * Effectue les actions n‚cessaires lors d'une d‚connexion:
			 */
			actions_atEndCnx( pVoie_curr );
		}	 

		/* 
		 * Met la voie en phase d'initialisation INIT: 
		 */
		voie_phase_init( pVoie_curr, TRUE_1 );
	
	}

	#undef	WATCH_CURRACTION
}

/*
 * Action_IsLong(-)
 *
 * Dit si l'action peut s'effectuer en plusieurs tours de boucle ppale
 *
 * 14.10.95: fplanque: Created
 */
BOOL	Action_IsLong(				/* Out: TRUE_1 si l'action peut s'effectuer en plusieurs tours de boucle ppale */
			int	n_action )		/* In:  Action demand‚e */
{
	switch( n_action )
	{
		case	WAIT:		/* attente action */
		case	DWLD:		/* ou download en cours */
		case	HALT:		/* ou Voie arrˆt‚e: ya rien a faire */
		case	SLEEP:	/* ou attente demande connexion */
		case	CNCT:		/* ou attente cnx ‚tablie */
		case	DECO:		/* ou attente achevement d‚co physique */
			return	TRUE_1;
	}
	
	return	FALSE0;
}

/*
 * actions_atArbopgExit(-)
 *
 * Purpose:
 * --------
 * Effectue certaines actions
 * lors de la sortie d'une page arbo
 * cas lors d'un JUMP ou lors d'une DECO
 *
 * Algorythm:
 * ----------  
 * Si n‚cessaire, effectue les actions suivantes:
 *		- Efface zones de saisie texte courantes
 *		- Release Locks de lecture et oublie record courant
 *
 * Notes:
 * ------
 * ATTENTION: la page arbo signal‚e dans pVoie_curr peut (JUMP) ou non (DECO)
 * d‚j… contenir la page suivante … celle dont on sort. 
 *
 * History:
 * --------
 * 17.05.94: fplanque: Created
 * 21.08.94: fplanque: libŠre maintenant LISTE de INFIELDs
 * 18.12.94: fplanque: appelle maintenant IOFieldList_Destruct()
 * 19.12.94: efface champ de sortie courant
 * 30.01.95: efface tableau de ptrs sur records accessibles
 */
void	actions_atArbopgExit( 
			VOIE *	pVoie_curr )				/* In: Voie concern‚e */
{
	/*
	 *	Efface zones d'‚dition courantes: 
	 */
	IOFieldList_Destruct( pVoie_curr -> pIOField_ListIn );
	pVoie_curr -> pIOField_ListIn = NULL;	/* Plus de liste de champs d'entr‚e */
	pVoie_curr -> pIOField_CurrIn = NULL;
	pVoie_curr -> curr_textline = NULL;	/* Plus de ligne en cours d'‚dition */


	/*
	 * Efface texte formatt‚ courament affich‚:
	 */
	IOFieldList_Destruct( pVoie_curr -> pIOField_CurrOut );
	pVoie_curr -> pIOField_CurrOut = NULL;
	

	/*
	 * Efface tableau de pointeurs vers records accessibles:
	 */
	if( pVoie_curr -> pTCompRec_ptrs != NULL )
	{
		FREE( pVoie_curr -> pTCompRec_ptrs );
		pVoie_curr -> pTCompRec_ptrs	= NULL;
	}
	
	
	/*
	 * ---------------------------------------------------
	 * Release des locks de lecture et d'‚criture dans DB:
	 * ---------------------------------------------------
	 */
	DBInt_ReleaseAllLocks( pVoie_curr );


	/*
	 * Plus de DB ouverte:
	 */
	pVoie_curr -> database = NULL;
						

	/*
	 * Plus de texte ouvert:
	 */
	pVoie_curr -> pDataPage_OpenText = NULL;
	
	
	/*
	 * Efface le directory charg‚ en m‚moire:
	 */
 	Dir_Forget( pVoie_curr -> TpDirEnt, pVoie_curr -> nb_DirEnt );
 	pVoie_curr -> TpDirEnt = NULL;
 	pVoie_curr -> nb_TableEnt = 0;
 	pVoie_curr -> nb_DirEnt = 0;

}


/*
 * handle_ENPG(-)
 *
 * Purpose:
 * --------
 * Traitrement des initialisations ENTER PAGE
 *
 * History:
 * --------
 * 13.11.94: fplanque: Created
 * 27.11.94: R‚‚criture quasi totale avec nouvelles fonctions
 * 02.12.94: essaie tjs de se placer sur le 1er champ de saisie activ‚ de la page
 * 13.04.95: Download
 */
BOOL	handle_ENPG(						/* Out: True_1 s'il faut arrˆter la connexion */
			VOIE	*	pVoie_curr )		/* In:  Voie concern‚e */
{	
	int	n_PgFnct = (pVoie_curr -> arboparams) -> fnct_no;

	/*
	 * Init saisie: 
	 * A priori: pas de champ de saisie/sortie:
	 */
	pVoie_curr -> pIOField_CurrOut = NULL;
	pVoie_curr -> pIOField_CurrIn  = NULL;
	pVoie_curr -> curr_textline 	 = NULL;		/* Pas de ligne buffer en cours d'‚dition */
	/*
	 * pas de champ en cours de lecture:
	 * Init importante pour ne pas planter le display par groupes.
	 */
	pVoie_curr -> pOutputFPar_CurrOut = NULL;
	pVoie_curr -> curr_comprec = NULL;
	/*
	 * Pas encore d'enregistrement cr‚‚ … partir de cette page arbo 
	 */
	pVoie_curr -> nb_records = 0;			

	/*
	 * Cr‚ation de la liste des champs d'‚dition 
	 * de cette page pour cette voie
	 */
	Create_ArboPageInFieldList( pVoie_curr );
	
	/*
	 * R‚cup‚ration des paramŠtres transmis par la page pr‚c‚dente:
	 */
	pVoie_curr -> pDataPage_LockedDB_IN	= pVoie_curr -> pDataPage_LockedDB_OUT;
	pVoie_curr -> pDataPage_LockedDB_OUT= NULL;		/* Pas encore de param pour la page suivante */

	pVoie_curr -> pCompRec_Locked_IN 	= pVoie_curr -> pCompRec_Locked_OUT;
	pVoie_curr -> pCompRec_Locked_OUT 	= NULL;		/* Pas encore de param pour la page suivante */
	if( pVoie_curr -> pCompRec_Locked_IN )
	{	/*
		 * Si on a re‡u un Compact Record en param de la page pr‚c‚dente:
		 * Il faut le mettre dans la liste des readlocks pour ne pas oublier
		 * de le lib‚rer lorsqu'on quitte cette page:
		 */ 
		DBInt_AddLockToList( pVoie_curr, pVoie_curr -> pCompRec_Locked_IN );
	}
	
	/*
	 * Effectue op‚rations n‚cessaires … l'entr‚e sur la page 
	 */
	switch( n_PgFnct )
	{	/*
		 * Selon la fonction de la page arbo: 
		 */
		case	FA_ECRI_MSG:	
			/*
			 * Ouvre base de donn‚es
			 */
			EcriMsg_ENPG( pVoie_curr ); 
			break;

		case	FA_LECT_MSG:
			/*
			 * Lecture message:
			 */
			LectMsg_ENPG( pVoie_curr );
			break;

		case	FA_DISP_TEXT:
			/*
			 * Affichage d'un texte:
			 */
			DispText_ENPG( pVoie_curr );
			break;

		case	FA_ID:
		case	FA_NEW_ACCOUNT:	
			/*
			 * Identification,
			 * creation d'un compte:
			 * Ouvre base de donn‚es
			 */
			register_action( pVoie_curr, OPDB, FB_DIRECTORY, 0, NULL ); 
			break;

		case	FA_LIST:
			/*
			 * Liste des messages d'une rub
			 * (liste d'une DB):
			 */
			ListDB_ENPG( pVoie_curr, FB_RUB );
			break;

		case	FA_DIRECTORY:
			/*
			 * annuaire des comptes
			 * (liste d'une DB):
			 */
			ListDB_ENPG( pVoie_curr, FB_DIRECTORY );
			break;

		case	FA_FILESEL:
			/*
			 * S‚lecteur de fichier:
			 */
			FileSel_ENPG( pVoie_curr );
			break;

		case	FA_DOWNLOAD:
			/*
			 * Download d'un ou plusieurs fichiers:
			 */
			return	DownLoad_ENPG( pVoie_curr );
			
		/* case	FA_MENU: */ 
		/* default: */
	}
	
	if( n_PgFnct != FA_DOWNLOAD )
	{	/*
	 	 * On se place sur le premier champ de saisie disponible:
	 	 * puis place dans l'Etat WAIT
	 	 */
		Move_FocusToFirstInField( pVoie_curr );
	}
	
	return	FALSE0;
}


/*
 * register_action(-)
 *
 * Purpose:
 * --------
 * Enregistre une action a effectuer 
 * dans la pile FIFO de la voie courante
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 05.01.95: accepte paramŠtres
 */
void	register_action( 
			VOIE *	pVoie_curr, 	/* In: Voie concern‚e */
			int 		action,			/* In: No de l'action */
			int		int1,				/* In: Params int */
			ULONG		ulong1,			/* In: Params ULONG */
			void *	ptr1	 )			/* In: Params PTR */
{
	int	action_tail = pVoie_curr -> action_tail;

	/*
	 * Incr‚mente la queue de la pile FIFO: 
	 */
	if ( action_tail == NB_ACTS_MAX-1 )
	{
		action_tail = 0;
	}
	else
	{
		action_tail ++;
	}
	
	if( action_tail + 1 == pVoie_curr -> action_head )
	{	/*
		 * Si on s'est mordu la queue: 
		 */
		signale("Les actions se mordent la queue");
		/*
		 * On ne sauve pas la nlle position!!! 
		 */
	}
	else
	{	/*
		 * Si on peut enregistrer la requete: 
		 * Enregistre l'action dans le tableau:
		 */
		ACTION * pAction	= &( pVoie_curr -> action[ action_tail ] );
		pAction -> no		= action;
		pAction -> int1	= int1;
		pAction -> ulong1	= ulong1;
		pAction -> ptr1	= ptr1;

		/*
		 * Sauve index de la queue: 
		 */
		pVoie_curr -> action_tail = action_tail;
	}

}





/*
 * try_connection(-)
 *
 * Purpose:
 * --------
 * Essaie d'‚tablir une connexion: envoi de porteuse etc...
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
#if ACCEPT_REMOTE
void	try_connection( VOIE * pVoie_curr )
{
	/*
	 * Signale d‚but proc‚dure de connexion … l'‚cran: 
	 */
	add_textinf( pVoie_curr -> wi_params, "  Connexion en cours" );

	/*
	 * Allume le minitel (M2):
	 */
	allume_minitel( pVoie_curr -> device );

	/*
	 * Adapte la vitesse:
	 * Passe en 1200 bps
	 */								
	Voie_LineSpeed( pVoie_curr );
							
	/*
	 * Envoi de porteuse: 
	 */
	envoi_porteuse( pVoie_curr -> device );

	/*
	 * D‚termine heure timeout accord‚e aux acquitements: 
	 */
	pVoie_curr -> acq_timeout = clock( ) + ACQ_TIMEOUT;
	/*
	 * D‚termine heure timeout pour la connexion: 
	 */
	pVoie_curr -> key_timeout = clock( ) + CNCT_TIMEOUT;

	/*
	 * Connexion en cours: 
	 */
	pVoie_curr -> action_progress = APG_CNXSTART;		/* D‚but proc‚dure de connexion */
	register_action( pVoie_curr, CNCT, 0, 0, NULL );	/* Demande d'attendre ACQs de connexion */
}
#endif



/*
 * enter_dir(-)
 *
 * Purpose:
 * --------
 * Entre dans un nouveau dossier arbo
 *
 * History:
 * --------
 * fplanque: Created
 */
int	enter_dir( VOIE *pVoie_curr, DATADIR *new_arbodir )
{
	int	success;
	
	if ( new_arbodir != NULL )
	{	/* 
		 * Si on peut entrer dans le nouveau dossier: 
		 */
		pVoie_curr -> arbodir =  new_arbodir;

		/*
		 * Affiche fonction: 
		 */
		add_textinf( pVoie_curr -> wi_params, " PremiŠre page arbo: " );

		/*
		 * Saute … la premiŠre page: 
		 * Saut obligatoire:
		 */
		success = jmp_page( pVoie_curr, ((new_arbodir -> dir_spec) -> liens_in)[0] .psz_DestPage, TRUE_1 ); 

		return	success;		/* signale succŠs ou ‚chec de l'op‚ration */
	}
	else
	{	/*
		 * Dossier n'existe pas: 
		 */
		ping();
		add_textinf( pVoie_curr -> wi_params, "ERREUR: Dossier vierge!" );

		return	TRUE_1;		/* Break! */
	}

}



/*
 * jmp_page(-)
 *
 * Purpose:
 * --------
 * Saut … une nouvelle page arbo
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 13.11.94: Les initialisations de d‚but de page sont report‚es au curraction ENPG
 * 29.03.95: n'efface plus le curseur, ‡a devrait d‚j… etre fait!
 */
int	jmp_page( 
			VOIE *	pVoie_curr, 
			char *	new_arbo, 
			int 		obligatoire )
{
	/*
	 * Teste si la page est d‚finie: 
	 */
	if( new_arbo != NULL )
	{	/*
		 * Si la page a ‚t‚ d‚finie: 
		 */
		DATAPAGE	*curr_arbopage;		/* Page arbo courante */

		/*
		 * Affiche nom de la page: 
		 */
		complete_textinf( pVoie_curr -> wi_params, new_arbo );

		/*
		 * Cherche l'adresse de la page: 
		 */
		curr_arbopage = page_adr_bynamecmp( pVoie_curr -> arbodir, new_arbo );
		if( curr_arbopage != NULL )
		{	/*
			 * Si on a trouv‚ la page: 
			 * Affichage commentaire: 
			 */
			if ( curr_arbopage -> comment != NULL )
			{	/*
				 * S'il y a un commentaire: 
				 */
				strcpy( G_tmp_buffer, " = "  );
				strcat( G_tmp_buffer, curr_arbopage -> comment );
				complete_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
			}

			/*
			 * Fixe r‚f‚rences ds les paramŠtres de la voie courante: 
			 */
			pVoie_curr -> arbopage = curr_arbopage;	
			pVoie_curr -> arboparams = curr_arbopage -> data.pagearbo;

			/*
			 * Liste des actions … accomplir: 
			 */
			register_action( pVoie_curr, DISP, FE_FOND, 0, NULL );		/* On va afficher */

			register_action( pVoie_curr, ENPG, 0, 0, NULL ); 		/* Initialisation ENTER PAGE */
		
			return	RAS0;			/* OK */
		}
		else
		{	/*
			 * Si page introuv‚e: 
			 */
			ping();
			add_textinf( pVoie_curr -> wi_params, "ERREUR: Page ARBO introuvable!" );
	
			return	ERROR_1;		/* Break! */
		}
	}
	else
	{	/*
		 * Si la page n'est pas d‚finie (NULL ptr): 
		 */
		if( obligatoire )
		{	/*
			 * S'il est obligatoire de se rendre sur cette page: 
			 */
			ping();
			add_textinf( pVoie_curr -> wi_params, "ERREUR: Page ARBO non d‚finie!" );

			return	ERROR_1;		/* Break! */
		}
		else
		{	/*
			 * Pas obligatoire:
			 */
			/*			csr_on( pVoie_curr -> device ); */
			return	ABORT_2;		/* ABORT */
		}
	}
}



/*
 * affiche_ecran(-)
 *
 * Purpose:
 * --------
 * Affiche une page ‚cran sur la voie d‚sir‚e
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 11.12.94: fplanque: Chang‚ affichages; le fait que la fonction n'apparisse pas ds page arbo ne stopppe plus le serveur
 */
int	affiche_ecran( 				/* Out: S'est-il produit une fatal error */
			VOIE *	pVoie_curr, 	/* In:  Voie concern‚e */
			int 		fnct_ecran )	/* In:  Fonction de la page … afficher */
{
	PAGEARBO 		*curr_arboparams = pVoie_curr -> arboparams;
	ARBO_TEXTPAR	*page_ecran = curr_arboparams -> pages_ecran;	/* Ptr sur 1Šre page ‚cran */

	/*
	 * Cherche la page qui nous int‚resse: 
	 */
	while( page_ecran != NULL )
	{
		if ( page_ecran -> fnct_no == fnct_ecran )
		{	/*
			 * On a trouv‚ la fonction recherch‚e: 
			 */
			char		*pecran_nom = page_ecran -> nom;	/* Nom de la page … chercher */
			DATAPAGE	*page_ecran;							/* Adr de la page trouv‚e */

			/*
			 * Teste si on lui a associ‚ une page ‚cran ou si on a pr‚f‚r‚ ne rien afficher: 
			 */
			if ( pecran_nom == NULL )
			{	/*
				 * On a pas voulu afficher de page ‚cran pour cette fonction ‚cran: 
				 */
				return	RAS0;
			}

			/*
			 * On a d‚fini une page-‚cran: 
			 */

			/*
			 * Affiche le nom: 
			 */
			sprintf( G_tmp_buffer, "  Affiche page-‚cran: %s", pecran_nom );
			add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );

			/*
			 * Cherche cette page: 
			 */
			page_ecran = page_adr_bynamecmp( pVoie_curr -> pecrandir, pecran_nom );
			if ( page_ecran != NULL )
			{	/*
				 * On a trouv‚ la page ‚cran: 
				 * Affiche la page: 
				 */
				DATABLOCK * pDataBlock_pecran = page_ecran -> data.dataBlock;
				sconout( pVoie_curr -> device , pDataBlock_pecran -> ul_length, pDataBlock_pecran -> p_block );
				return	RAS0;
			}
			else
			{	/*
				 * Page introuvable: 
				 */
				ping();
				add_textinf( pVoie_curr -> wi_params, "ERREUR: Page-‚cran introuvable!" );

				return	RAS0;
			}
			
		}

		/*
		 * Passe … la fonction/page ‚cran suivante: 
		 */
		page_ecran = page_ecran -> next;
	}
	
	/*
	 * On n'a pas trouv‚ l'entr‚e d‚sir‚e dans la liste des pages ‚cran: 
	 */
	/* ping(); */
	/* add_textinf( pVoie_curr -> wi_params, "WARNING: Fonction ‚cran non pr‚sente ds page!" ); */
	/* return	TRUE_1;		/* Break! */ 
	
	return	RAS0;
}



/*
 * Serv_EnterDataPage(-)
 *
 * Purpose:
 * --------
 * Entre dans une base de donn‚es ou un texte
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 05.12.94: 1ere prise en compte de FB_DIRECTORY
 * 05.01.94: recherche un objet avec une fonction bien pr‚cise
 * 05.01.94: GŠre aussi les textes
 */
int	Serv_EnterDataPage( 
			VOIE 	*	pVoie_curr,		/* In: Voie concern‚e */
			DATATYPE	DataType,		/* In: Type de donn‚es … charger */
			int		n_fnct )			/* In: Fonction Recherch‚e */
{
	PAGEARBO 	 *	curr_arboparams = pVoie_curr -> arboparams;
	ARBO_TEXTPAR *	pTextPar_Data = curr_arboparams -> databases;	/* Ptr sur 1Šre base de donn‚es */
	DATADIR		 *	pDataDir = NULL;
	const char	 * cpsz_Error = NULL;

	switch( DataType )
	{
		case	DTYP_DATAS:
			add_textinf( pVoie_curr -> wi_params, "  Ouvre base de donn‚es: " );
			pDataDir = pVoie_curr -> pDataDir_Datas;
			cpsz_Error =  "ERREUR: Base de donn‚es introuvable!" ;
			break;
		
		case	DTYP_TEXTS:
			add_textinf( pVoie_curr -> wi_params, "  Ouvre texte: " );
			pDataDir = pVoie_curr -> pDataDir_Texts;
			cpsz_Error =  "ERREUR: Texte introuvable!"; 
			break;

		default:
			signale( "Ne sait pas ouvrir ces donn‚es." );
	}
	
	/*
	 * Cherche la DataPage qui nous int‚resse: 
	 */
	while( pTextPar_Data != NULL )
	{
		if( pTextPar_Data -> fnct_no == n_fnct )
		{	/*
			 * On a trouv‚ la fonction recherch‚e: 
			 */
			char	*	psz_DataName = pTextPar_Data -> nom;		/* Nom de la page … chercher */

			/*
			 * Teste si on a associ‚ un fichier de donn‚es: 
			 */
			if( psz_DataName != NULL )
			{	/*
				 * On a d‚fini un objet de donn‚es: 
				 */
				DATAPAGE	*	pDataPage;					/* Adr de la base trouv‚e */

				/*
				 * Affiche le nom: 
				 */
				complete_textinf( pVoie_curr -> wi_params, psz_DataName );

				/*
				 * Cherche cette page: 
				 */
				pDataPage = page_adr_bynamecmp( pDataDir, psz_DataName );

				/*
				 * Sauve ptr sur la datapage trouv‚e:
				 */
				switch( DataType )
				{
					case	DTYP_DATAS:
						pVoie_curr -> database = pDataPage;
						break;
						
					case	DTYP_TEXTS:
						pVoie_curr -> pDataPage_OpenText = pDataPage;
				}

				/*
				 * Teste si on a trouv‚ la page: 
				 */
				if( pDataPage != NULL )
				{	/*
					 * On a trouv‚ la base de donn‚es: 
					 */
					return	RAS0;
				}
			}
			/*
			 * Impossible d'ouvrir:
			 */
			ping();
			add_textinf( pVoie_curr -> wi_params, cpsz_Error );

			return	TRUE_1;		/* Break! */
		}

		/*
		 * Passe … la fonction/page ‚cran suivante: 
		 */
		pTextPar_Data = pTextPar_Data -> next;
	}
	
	/*
	 * On n'a pas trouv‚ la page: 
	 */
	ping();
	add_textinf( pVoie_curr -> wi_params, "SYSERROR: Fonction DB introuvable!" );

	return	TRUE_1;		/* Break! */
}



/*
 * place_csr(-)
 *
 * Purpose:
 * --------
 * Place le curseur sur champ de saisie courant … l'‚cran
 * pour la voie d‚sir‚e
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 21.08.94: on se positionne maintenant dans pIOField_CurrIn
 */
void	place_csr( 
			VOIE *	pVoie_curr )
{
	/*
	 * Variables: 
	 */
	IOFIELD	*	pInField = pVoie_curr -> pIOField_CurrIn;
	int			device	= pVoie_curr -> device;		/* Port utilis‚ */
	int			n_col_text;

	if( pInField == NULL )
	{
		return;
	}
	
	/*
	 * S'il y a un champ d'‚dition courant: 
	 */
	n_col_text = pInField -> FPar.Input -> col_text;

	/*
	 * Positionne le curseur: 
	 */
	pos( device, pVoie_curr -> csr_x, pVoie_curr -> csr_y );

	/*
	 * Fixe couleur texte: 
	 */
	set_tcolor( device, n_col_text  );			/* Couleur texte */
	pVoie_curr -> curr_tcolor = n_col_text;	/* M‚morise couleur texte actuellement utilis‚e */

	/*
	 * Affiche curseur 
	 */
	csr_on( device );			
}



/*
 * affiche_touche(-)
 *
 * Purpose:
 * --------
 * Affichage de la touche press‚e 
 * ou de l'‚vŠnement survenu dans la fenetre LOG
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	affiche_touche( VOIE *pVoie_curr, KEYCODE code_touche )
{
	/* 
	 * Affiche le nom de la touche: 
	 */
	if ( code_touche < ACTIONS )
	{	/* 
		 * S'il s'agit d'une touche: 
		 */
		sprintf( G_tmp_buffer, "  Touche: %s", M_keyname[ code_touche ] );
		add_textinf( pVoie_curr -> wi_params, G_tmp_buffer );
	}
	else
	{	/*
	    * S'il s'agit d'une action/‚vennement: 
	    */
		add_textinf( pVoie_curr -> wi_params, M_keyname[ code_touche ] );
	}
}




/*
 * sys_events(-)
 *
 * Purpose:
 * --------
 * Gestion des actions sysop sur l'ordinateur pdt la gestion du serveur
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
int	sys_events( void )
{
	int	event;	/* EvŠnement qui s'est produit */

	/*
	 * Teste ‚vŠnement GEM: 
	 */
	event=evnt_multi( MU_TIMER | MU_MESAG | MU_BUTTON | MU_KEYBD,
							2, 1, 1,
                     0, 0, 0, 0, 0, 
                     0, 0, 0, 0, 0,
                     G_ev_mgpbuff, 
                     0, 0,
                     &G_mouse_x, &G_mouse_y, &G_mouse_button,
                     &G_kbd_state, &G_kbd_return,
                     &G_mouse_nbc);

	if( event & MU_MESAG ) 
	{	/*
		 * S'il y a un message AES: 
		 */
		int	msg_type= G_ev_mgpbuff[0];	/* Type de message */
		int	wi_handle=-1;			/* Handle de la fenˆtre … traiter */
		WIPARAMS	*wi_params_adr;	/* Adresse des params de la fen concern‚e */

		if ( msg_type>=WM_REDRAW && msg_type<=WM_NEWTOP ) /* Si event concerne une fenˆtre */
		{
			wi_handle= G_ev_mgpbuff[3];	/* Handle de la fenˆtre … traiter */
			/* printf("Received message for window: handle=%d\n", wi_handle); */

			wi_params_adr = wi_params ( wi_handle );  /* Adr de la zone de paramŠtres associ‚e */
			if ( wi_params_adr == NULL )	/* Si la fen concern‚ n'existe pas(plus) */
				msg_type = -1;		/* Annule le message: il ne sera pas reconnu par ce qui suit... */							
		}
			
		switch ( msg_type )
		{

			case MN_SELECTED:
				ping();				/* Action Interdite! */
				break;

			case WM_REDRAW:
				redraw( wi_params_adr, G_ev_mgpbuff[4], G_ev_mgpbuff[5],
					G_ev_mgpbuff[6], G_ev_mgpbuff[7], TAKE_CTRL ); /* Effectue un redraw */
				break;

			case WM_TOPPED:
				if ( wi_params_adr -> type != TYP_TRACK ) /* S'il ne s'agit pas d'une fenˆtre serveur: */
					ping();				/* Action Interdite! */
				else	/* S'il s'agit de la fenˆtre serveur: */
					/* Ceci ne se produira qu'en environnement multitƒche */
					/* ou avec un accessoire (c bien du multi-tache) */
					put_wi_on_top( wi_params_adr );	/* Place fen au premier plan */
				break;

			case WM_CLOSED:
				if ( wi_params_adr -> type != TYP_TRACK ) /* S'il ne s'agit pas de la fenˆtre serveur: */
					ping();				/* Action Interdite! */
				else	/* S'il s'agit de la fenˆtre serveur: */
					return	TRUE_1;			/* BREAK SERV */
				break;
		
			case WM_FULLED:
				msg_fulled( wi_params_adr );
				break;
				
			case WM_ARROWED:
				msg_arrowed( wi_params_adr );
				break;
				
			case WM_VSLID:
				msg_vslid( wi_params_adr );
				break;

			case WM_HSLID:
				msg_hslid( wi_params_adr );
				break;
			
			case WM_SIZED:
				msg_sized( wi_params_adr );
				break;

			case WM_MOVED:
				msg_moved( wi_params_adr );
				break;

			case WM_NEWTOP:
				ping();
				/* Cet ‚vŠnement n'arrive jamais... */
				/* Au cas ou il arriverait, on remet imm‚diatement une fen serveur au 1er plan: */
				put_wi_on_top( G_wi_list_adr );	/* Place fen au premier plan */
				break;
				
		}

	}
	
	if( event & MU_TIMER ) 
	{	/*
		 * EvŠnement Timer:
		 * On ne fait rien:
		 */
	}

	if( event & MU_KEYBD ) 
	{	/*
		 * EvŠnement Keyboard:
		 * On ne fait rien:
		 */
		/* int	n_ScanCode	= G_kbd_return >> 8; */
		/*	char	c_car			= G_kbd_return & 0xFF;			*/

		/* printf("\r Scan=%d car=%c ", n_ScanCode, c_car );	*/
	}

	/*
	 * Pas d'interruption... 
	 */
	return	FALSE0;	/* Continue normalement */

}


