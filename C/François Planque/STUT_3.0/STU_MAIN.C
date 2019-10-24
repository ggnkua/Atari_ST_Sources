/*
 * StuMain.c
 *
 * Purpose:
 * --------
 *	Gestion du bureau
 *	- Main()
 *	
 *	Gestion des erreurs
 *	- erreur(): Signale les erreurs fatales	
 *	- erreur_rsrc(): Appelle erreur() avec texte constant
 *
 * Suggest:
 * --------
 * Sortir les fonctions de drag&drop vers un module independant
 * Il y a des variables privées en G_xxxx -> M_xxx
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */

 
 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"STUMAIN.C v1.00 - 02.95"
          

/*
 * System headers:
 */
	#include	<stdio.h>					/* header standard */
	#include	<stdlib.h>					/* header librairie de fnct std */
	#include <string.h>					/* header tt de chaines */
	#include	<aes.h>						/* header AES */
	#include <vdi.h>						/* header VDI */
	#include	<tos.h>						/* Malloc pour ?FREEMEM */
	#include <stdarg.h>					/* Arguments variables */
   

/*
 * Custom headers:
 */
	#include	"SPEC_PU.H"
	#include "S_MALLOC.H"
	#include "AESDEF.H"					/* Defs suppl‚mentaires pour gestion AES */
	#include	"EXFRM_PU.H"
	#include	"PROGR_PU.H"
	#include "ARBKEYPU.H"
	#include "ATREE_PU.H"
	#include "ARBPG_PU.H"
	#include	"CONFG_PU.H"
	#include "DATAGRPS.H"	
	#include "DTDIR_PU.H"	
	#include "DATPG_PU.H"	
	#include "DBSYS_PU.H"
	#include	"DEBUG_PU.H"	
	#include	"DESK_PU.H"
	#include	"FILES_PU.H"
	#include "MAIN_PU.H"	
	#include "MMENU_PU.H"	
	#include	"OBJCT_PU.H"	
	#include	"PGECR_PU.H"
	#include	"RAMSL_PU.H"
	#include	"RTERR_PU.H"
	#include "SRIAL_PU.H"
	#include	"SERV_PU.H"
	#include "STUT_ONE.RSC\STUT_3.H"					/* noms des objets ds le ressource */
	#include	"TEXT_PU.H"
	#include	"ACCENTPU.H"
	#include "VDI_PU.H"
	#include	"WIN_PU.H"
	#include	"WINDR_PU.H"
	#include	"GEMEV_PU.H"
	#include "GEMDIRPU.H"
		
	/* #include	"TOSERROR.H"				/* Def des erreurs TOS: NON UTILISEES */

/*
 * ------------------------ PROTOTYPES -------------------------
 */

/*
 * PRIVate INTernal prototypes:
 */
	static	WIPARAMS	* wi_params ( int handle );
	static	OBJECT	* window_clic( WIPARAMS *wi_params_adr, int mouse_x, int mouse_y );
	static	int	drag_icon( int start_x, int start_y, int new_x, int new_y );
	static	void 	mouvement( int destination );
	static	void	graf_beginmove( OBJECT *srce_tree, OBJECT *srce_adr, int destination, OBJECT *dest_adr );
	static	void	graf_endmove( OBJECT *srce_tree, int source, OBJECT *srce_adr, int destination, OBJECT *dest_adr );
   
/*
 * ------------------------ VARIABLES -------------------------
 */
    
    
/*
 * Public variables: 
 */
	int		G_ap_id;						/* Identification par l'AES */
	unsigned	G_version_aes;				/* Version AES */
	int		G_x_mini, G_y_mini;		/* Coord sup gauche de l'‚cran */
	int		G_w_maxi, G_h_maxi;		/* Taille de l'‚cran de travail */
	int		G_wx_mini, G_wy_mini;	/* Dimensions maximales d'une */
	int		G_ww_maxi, G_wh_maxi;	/* fenˆtre complŠte */
	int		G_n_ScreenW, G_n_ScreenH;	/* Taille ‚cran */
	
	WIPARAMS	*G_wi_list_adr;			/* Adresse de l'arbre de paramŠtres */
	int		G_top_wi_handle;			/* Fenˆtre g‚r‚e par le programme
													la plus en haut, mais pouvant ˆtre
													surpass‚e par un accessoire */
	
	/*
	 * ParamŠtres de la "Fenˆtre" dans laquelle 
	 * se trouve la s‚lection actuelle:
 	 */
	WIPARAMS	*G_selection_adr = NULL;	
	
	int		G_ev_mgpbuff[32];			/* Buffer d'‚venements GEM (normalement, ‡a ne fait que 8 mais bon, ‡a pourrait monter ds prochainesversions AES) */
	int		G_mouse_x,G_mouse_y;		/* Coordonn‚es souris (Evt_multi) */
	int		G_mouse_button;			/* Etat des boutons (Evt_multi) */			
	int		G_kbd_state;				/* Etat des touches sp‚ciales... */
	int		G_kbd_return;				/* Scan code touche... */
	int		G_mouse_nbc;				/* Nombre de cliks ... */
	
	int		G_fin =0;						/* Non nul si G_fin du prg demand‚e */

/*
 * Private variables: 
 */
	/* 
	 * Ressource: 
	 */
	static	OBJECT *	M_apropos_adr;	/* Ptr sur boite d'infos */
	 
 
/*
 * ------------------------ FUNCTIONS -------------------------
 */

/*
 * main(-)
 *
 * Purpose:
 * --------
 * Programme principal
 *
 * History:
 * --------
 * 1992: fplanque: Created
 * 25.05.94: chang‚ l'ordre de traitement des messages: ordre d‚croissant des bits ds ev_mflags
 * 25.05.94: inlus gestion du clavier
 * 13.10.94: invers‚ orde d'appel init VDI et d‚termination taille ‚cran; contr“le d'un taille minimale
 * 02.02.95: init arbo APRES init bureau
 */
int main(void)
{
	int	event;							/* Evenements d‚tect‚s par Evt_multi */

	char * ptr;

   /*
    * Positionnement curseur VT52 en haut de l'‚cran:
    * Passage … la ligne automatique:
    */
	printf("\33Y!#\33v\n"); 

/* #define	DBGBOOT(x)		printf( x ); /* getchar(); */
#define	DBGBOOT(x)

	DBGBOOT( "Boot-Up Debug is Active\n" )

	/*
	 * test du debug des malloc
	 */
	ptr = MALLOC( 10 );
	ptr = REALLOC( ptr, 20 );
	FREE(ptr);

	/*
	 * Init des routines sp‚ciales FP:
	 */
	Special_Init();

	/*
	 * D‚claration du programme … l'AES 
	 */
	G_ap_id=appl_init();
	if (G_ap_id == -1)
		erreur( "[3][L'application courante|"
						"ne peut ˆtre d‚clar‚e|"
						"auprŠs du systŠme|"
						"d'exploitation!]"
						"[Quitter|Continuer]");

	/*
	 * R‚cupŠre version AES: 
	 */
	G_version_aes = _GemParBlk .global[ 0 ];

	/*
	 * Init des fonctions de debug:
	 */
	debug_Construct();

	/*
	 * Transmet nom de l'application … l'AES pour le Menu "DESK" 
	 */
	DBGBOOT( "Transmet nom appli … l'AES\n" )
	if ( G_version_aes >= 0x0400 )
	{	/*
		 * Sous AES 4.0 uniquement: 
		 */
		menu_register( G_ap_id, STUT_REGISTERNAME );
	}
	
	/*
	 * Initialisation "al‚atoire" du GNA 
	 *****************************************************
	 * HYPER-MEGA-IMPORTANT: SI VOUS OUBLIEZ DE FAIRE CA,
	 * LE RESEAU RISQUE DE SE RETROUVER AVEC PLUSIEURS
	 * MESSAGES AYANT LE MEME NUMERO... DEBROUILLEZ VOUS
	 * POUR ETRE SUR QUE VOTRE GNA N'EST PAS INITIALISE A
	 * LA MEME POSITION QUE CHEZ VOTRE VOISIN!!!
	 *****************************************************
	 */
	srand( (unsigned int) clock() ); 

	TRACE0( "Initializing modules..." );
	
	/*
	 * D‚termination de la taille de l'‚cran 
	 */
	wind_get(0 ,WF_WORKXYWH , &G_x_mini, &G_y_mini, &G_w_maxi, &G_h_maxi);
	/*
	 * Contr“le la taille de l'‚cran:
	 */
	if( G_x_mini + G_w_maxi < MIN_WIDTH || G_y_mini + G_h_maxi < MIN_HEIGHT )
	{
		erreur( "[3][|"
						"Stut One ne fonctionne|"
						"que dans les r‚solutions|"
						"sup‚rieures ou ‚gales …:|"
						MIN_RES_STRING  ".]"
						"[ Quitter ]");
	}

	/*
	 * D‚termination de la zone de travail maxi d'une fenˆtre complete: 
	 */
	wind_calc( WC_WORK, COMPLETE, G_x_mini, G_y_mini, G_w_maxi, G_h_maxi,
				 &G_wx_mini, &G_wy_mini, &G_ww_maxi, &G_wh_maxi );
	/*
	 * Taille ‚cran: 
	 * Pas de -1, sinon on a des trucs genre 639 * 399
	 */
	G_n_ScreenW = G_x_mini + G_w_maxi;
	G_n_ScreenH = G_y_mini + G_h_maxi;


	/*
	 * Ouverture d'une station de travail virtuelle VDI sur ‚cran 
	 */
	DBGBOOT( "Init VDI\n" )
	init_vdi();

	/*
	 * Chargement du fichier ressource 
	 */
	DBGBOOT( "Charge RSC\n" )
	Dsetpath( "STUT_ONE.RSC" );
	if( rsrc_load( "STUT_3.RSC" ) == 0)
	{
		erreur("[3][|Le fichier RSC|"
						"ne peut ˆtre charg‚!]"
						"[Quitter|Continuer]");
	}
	DBGBOOT( "Charg‚ RSC\n" )
	Dsetpath( ".." );

	/*
	 * D‚termination des adresses ressource:
	 */
	if( rsrc_gaddr( R_TREE, APROPOS, &M_apropos_adr) == 0)
		erreur_rsrc();
	rsrc_color( M_apropos_adr );		/* Fixe couleurs */
	/*
	 * Fixe nom du logiciel:
	 */
	dlink_teptext( &M_apropos_adr[PRGNAME], STUT_FULLNAME );
	dlink_teptext( &M_apropos_adr[RELEASE], STUT_RELEASEINFO );

	/*
	 * Init traitement des textes:
	 */
	init_text();

	/*
	 * Init gestion des PopUps:
	 */
	PopUp_Init(); 
	 
	/*
	 * Init menu ppal:
	 */
	DBGBOOT( "Init Main Menu\n" )
	init_MainMenu();

	/*
	 * Init prises s‚rie: 
	 */
	DBGBOOT( "Init prises s‚rie\n" )
	init_serial();
	
	/*
	 * Init des op‚rations sur les fichiers: 
	 */
	DBGBOOT( "Init op‚rations sur fichiers\n" )
	init_fsel();

	/*
	 * Chargement des parametres dans STUT_ver.INI: 
	 */
	autoload_ini();
	
	/*
	 * Teste si on a charg‚ l'affectation des voies: 
	 */
	if ( G_voies == NULL )
	{	/* 
		 * Si on a pas charg‚ d'affectation: 
		 * Cr‚ation de voies par d‚faut:
		 */
		init_voies();
	}
	
	/* 
	 * Init manip des donn‚es: 
	 */
	init_datas();

	/*
	 * Init S.G.B.D: 
	 */
	init_dbsystem();

	/*
	 * Init des progress indicators: 
	 */
	init_progress();

	/*
	 * Init du s‚lecteur RAM: 
	 */
	init_ramselect();

	/*
	 * (1) Installation du bureau: 
	 */
	DBGBOOT( "Init Desktop\n" )
	init_desktop();
	/*
	 * (2) Init des ic“nes: 
	 */
	DBGBOOT( "Init Icons\n" )
	init_icons();

	/*
	 * Init de l'arbre arborescence:
	 */
	init_tree();
	 
	/* 
	 * Init des pages & routines arbo: 
	 */
	init_arbo();

	/*
	 * Init des objets servant … cr‚er des run-time-trees: 
	 */
	init_objects();

	/*
	 * Init accents:
	 */
	init_accents();

	/*
	 * Init tt des pages ‚cran:
	 */
	init_PagesEcran();

	/*
	 * Init configuration: 
	 */
	init_config();

	/*
	 * Init dirs:
	 */
	Dirs_Init();

	TRACE0( "Modules' Initialization Completed" );


	/*
	 * Chargement du serveur dans STUT_ver.INF: 
	 */
	autoload_inf();

	/*
	 * Installation du menu 
	 */
	menu_ienable( G_menu_adr, OUVRIR, 0 );	/* Disable */
	menu_ienable( G_menu_adr, FERMER, 0 );	/* Disable */
	if (menu_bar( G_menu_adr, SHOW_MENU ) == 0)	
		erreur_rsrc();
	
	/*
	 * -----------------------
	 * Gestion des ‚vŠnements:
	 * -----------------------
	 */
	do
	{
		graf_mouse( ARROW, 0);				/* Change curseur souris */
		
		event=evnt_multi( MU_MESAG | MU_BUTTON | MU_KEYBD,
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
			 * ------------
		 	 * Message AES:
		 	 * ------------ 
		 	 */

			int	msg_type= G_ev_mgpbuff[0];	/* Type de message */
			int	wi_handle=-1;			/* Handle de la fenˆtre … traiter */
			WIPARAMS	*wi_params_adr;	/* Adresse des params de la fen concern‚e */

			if ( msg_type>=WM_REDRAW && msg_type<=WM_NEWTOP ) /* Si event concerne une fenˆtre */
			{
				wi_handle= G_ev_mgpbuff[3];	/* Handle de la fenˆtre … traiter */

				wi_params_adr = wi_params ( wi_handle );  /* Adr de la zone de paramŠtres associ‚e */
				if ( wi_params_adr == NULL )	
				{	/* Si la fen concern‚ n'existe pas(plus) */
					msg_type = -1;		/* Annule le message: il ne sera pas reconnu par ce qui suit... */							
				}
			}
				
			switch ( msg_type )
			{

				case MN_SELECTED:
					selection_menu( G_ev_mgpbuff[3], G_ev_mgpbuff[4] );
					break;

				case WM_REDRAW:
					redraw( wi_params_adr, G_ev_mgpbuff[4], G_ev_mgpbuff[5],
						G_ev_mgpbuff[6], G_ev_mgpbuff[7], TAKE_CTRL ); /* Effectue un redraw */
					break;

				case WM_TOPPED:
					put_wi_on_top( wi_params_adr );	/* Place fen au premier plan */
					break;

				case WM_CLOSED:
					ferme_fenetre( wi_params_adr, TRUE_1 );
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
					/* Cet ‚vŠnement n'arrive jamais et c'est dommage! */
					put_wi_on_top( wi_params_adr );	/* Place fen au premier plan */
					break;
			}
		}


		if( event & MU_BUTTON )
		{	/*
			 * -------------
			 * Click souris: 
			 * -------------
			 */

			int		wi_handle;			/* Handle de la fenˆtre cliqu‚e */
			OBJECT	*obj_adr = NULL;	/* Pointe sur Objet sur lequel on a cliqu‚ */
			WIPARAMS	*wi_params_adr;	/* Adr des params de la fen ds laquelle on a cliqu‚ */
			
			/* wind_update( BEG_MCTRL );	/* App prend en charge souris */
			/* Pourquoi donc ? */
			/* 15/07/93 En fait c peut etre justifi‚ pour le drag & drop: */
			/* Il ne faudrait pas qu'un fenetre vienne se mettre au premier plan entre */
			/* le moment ou on a cliqu‚ et celui o— on commence le d‚placement! */

			/*
			 * Handle de la fen ds laquelle on a cliqu‚: 
			 */
			wi_handle= wind_find( G_mouse_x, G_mouse_y );
			/*
			 * ParamŠtres associ‚s: 
			 */
			wi_params_adr = wi_params( wi_handle );

			if ( wi_handle == 0)			/* Si on a cliqu‚ sur le bureau */
			{
				obj_adr = window_clic( G_desk_params_adr, G_mouse_x, G_mouse_y );						
			}
			else								/* Si pas cliqu‚ sur le bureau */
			{
				/*
				 * Selon le type de fenˆtre: 
				 */
				switch( wi_params_adr -> type )
				{	/* 
					 * But: d‚tecter les fenˆtres "cliquables" 
					 */
					case	TYP_TREE:
						/*
						 * Fixe la position de l'arbre pour bien interpreter le clic: 
						 */
						fixform_window( wi_params_adr );
					case	TYP_ARBO:
					case	TYP_DIR:
						obj_adr = window_clic( wi_params_adr, G_mouse_x, G_mouse_y );
						break;
				}
			}

			if ( obj_adr != NULL )
			{	/*
				 * Si un objet est s‚lectionn‚: 
				 * Type r‚el sans les bits ‚tendus 
				 */
				int	real_type = (obj_adr -> ob_type) & 0x00FF;

				/*
				 * Selon action utilisateur: 
				 */
				if ( G_mouse_nbc==2 )
				{ 	/* 
					 * Si on a double cliqu‚ 
					 */
					if ( obj_adr -> ob_flags & OUVRABLE  &&  !( obj_adr -> ob_state & DISABLED ) )
					{	/* ...ic“ne ouvrable */
						/* wind_update( END_MCTRL );			/* AES peut reprendre la souris */
						/* Forme souris: */
						graf_mouse( BUSYBEE, NULL );
						/*
						 * "Ouvre ic“ne": 
						 */
						ouverture();						
					}
				}
				else	if ( real_type == G_ICON || real_type == G_IMAGE ) 	/* S'il s'agit d'une ic“ne/image: */
				{	/*
					 * Peut ˆtre un DRAG 
					 */
					int	new_bstate, new_x, new_y;
					int	G_kbd_state, G_kbd_return, G_mouse_nbc;	/* Non utilis‚s */
					int	destination;				/* Objet destination */

					/*
					 * Teste ‚tat des boutons de la souris: 
					 */
						/* Appel de l'AES pdt 1 milliseconde... */
						evnt_multi( MU_TIMER,
										0, 1, 1,			/* 0 Clicks */
										0, 0, 0, 0, 0,
										0, 0, 0, 0, 0,
										G_ev_mgpbuff,
											1, 0,				/* Attend 1 milliseconde! */
										&new_x, &new_y, &new_bstate,
										&G_kbd_state, &G_kbd_return,
										&G_mouse_nbc );

						/* M‚thode de test par le VDI: ‡a fonctionne mais je */  
						/* la soup‡onne de bloquer le GEM … un moment ou un autre */
						/* Je pense qu'il faut ‚viter de m‚langer AES et VDI pour la */
						/* gestion de la souris... peut ˆtre que cel… entraŒne un */
						/* d‚faut de mise … jour des variables internes de l'AES... */
						/* vq_mouse( G_ws_handle, &new_bstate, &new_x, &new_y );*/
						/* printf("Boutons: %d \n", new_bstate); */
						/* 04/08/93: Je pense avoir r‚solu le problŠme, il provenait */
						/* apparemment de la d‚tection d'objets lorsqu'on sortait du bureau */
						/* pour aller dans la barre de menu (‡a renvoyait -1!) */
						/* On devrait pouvoir reprendre la m‚thode VDI, plus rapide? */

						/* 
						 * Teste s'il faut entamer un DRAG: 
						 */
						if ( new_bstate & 1 )
						{	/*
						 	 * Si bouton gauche press‚: */
							/* Selon le type de fenˆtre: */
							switch( wi_params_adr -> type )
							{
								case	TYP_TREE:	/* Arborescence */
									move_arbo( wi_params_adr, G_mouse_x, G_mouse_y );
									break;

								default:
									destination = drag_icon( G_mouse_x, G_mouse_y, new_x, new_y );
									if ( destination != -1 )
										mouvement( destination );
							}
						}
				}
			}
			/* wind_update( END_MCTRL );			/* AES peut reprendre la souris */
		}


		if( event & MU_KEYBD )
		{	/*
			 * ---------------
			 * Action clavier: 
			 * ---------------
			 */
			int	n_ScanCode	= G_kbd_return >> 8;
			char	c_car			= G_kbd_return & 0xFF;			

			if( (G_kbd_state & 0xFFFC) == 0 
				|| ! handle_keypress( G_kbd_state, n_ScanCode, c_car ))
			{	/*
				 * Si Ctrl ou Alt n'‚taient pas press‚s
				 * ou si la combinaison n'a pas ‚t‚ interpr‚t‚e comme raccourci clavier
				 * La pression s'applique … la fenˆtre au top:
				 */
				WIPARAMS * pWiParams_TopWin = G_wi_list_adr;

				if( pWiParams_TopWin != NULL )
				{	/*
					 * Si on a trouv‚ une fenˆtre ouverte (au top):
					 */
					/* On peut v‚rifier que c'est la bonne:
					 * int	n_TopWinHandle;
					 *	wind_get( 0, WF_TOP, &n_TopWinHandle ); 
					 */
					/* printf( "Top win handle=%d ", G_wi_list_adr -> handle ); */
					
					/*
					 * Selon le type de donn‚es dans la fenˆtre:
					 */
					switch( G_wi_list_adr -> type )
					{
						case	TYP_TEXT:
							/*
							 * Traitement de la touche par l'‚diteur:
							 */
							winEdit_ProcessKey( pWiParams_TopWin, G_kbd_state, n_ScanCode, c_car );
							break;
					}
				}
			}
		}


			
		/*
		 * Fin ‚ventuelle de la boucle sans fin: 
		 */
	} while( G_fin == 0 );

	/*
	 * -----------------
	 * Fin du programme:
	 * -----------------
	 * Retrait du menu 
	 */
	if (menu_bar(G_menu_adr,CLEAR_MENU) == 0)	
		erreur_rsrc();

	/*
	 * Referme toutes les fenˆtres 
	 * (normalement c'est d‚j… fait, mais bon.. )
	 */
	while (G_top_wi_handle != 0)		
	{	/*
		 * Tant qu'on a une fenˆtre ouverte 
		 */
		ferme_fenetre( G_wi_list_adr, FALSE0 );		/* On ferme celle du dessus */
	}
	
	/*
	 * Restore prises s‚rie dans leur ‚tat initial: 
	 */
	restore_serial();

	/*
	 * EnlŠve le bureau de l'application: 
	 */
	clear_desktop();

	/*
	 * Effacement du fichier ressource de la m‚moire 
	 */
	if (rsrc_free() == 0)
		erreur("[1][ATTENTION: La m‚moire|du fichier RSC n'a|pas pu ˆtre lib‚r‚e!][Continuer]");

	/*
	 * Ferme station de travail VDI 
	 */
	v_clsvwk( G_ws_handle );

	/*
	 * D‚claration de fin de programme … l'AES 
	 */
	if (appl_exit() == 0)
		erreur("[1][ATTENTION: La d‚claration|de l'application courante|n'a pas pu ˆtre annul‚e!][Continuer]");

	/*
	 * Affiche stats sur l'utilisation de la m‚moire
	 */
	MEMSTAT();

	return	0;
}



/*
 * wi_params(-)
 *
 * Purpose:
 * --------
 * Recherche ParamBlock d'une fenˆtre
 *
 * History:
 * --------
 * fplanque: Created
 */
WIPARAMS* wi_params( int handle )
{
	if ( handle == 0 )
	{	/* Si on demande les params du bureau: */
		return	G_desk_params_adr;
	}
	else
	{	/* SI on veut les params d'un fenˆtre= */
		WIPARAMS	*wi_params_adr;
	
		/* On commence par le haut de la liste */
		wi_params_adr=G_wi_list_adr;
		while ( wi_params_adr != NULL && (wi_params_adr -> handle) != handle )		
		{	/* Tant qu'on pointe pas sur la fen recherch‚e */
			wi_params_adr = wi_params_adr -> next;   /* Nlle fenˆtre … tester */
		}
		return	wi_params_adr;
		/* Il peut arriver qu'on re‡oive un message alors que la fenetre */
		/* a ‚t‚ referm‚e, dans ce cas, cette fonction renvoie un pointeur NULL */
	}
}



/*
 * window_clic(-)
 *
 * Purpose:
 * --------
 * Entreprend action lorsqu'on a cliqu‚ 
 * dans une fenˆtre ou sur le bureau
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 29.08.94: Gestion de l'item menu "D‚compile"
 * 20.09.94: Gestion du menu RENAME; remodelage substanciel; correction bug sur d‚tection TYPE d'une ic“ne ARBO
 * 02.02.95: corrction bug: renvoie maintenant NULL si objet cliqu‚ est disabled
 */
OBJECT * window_clic( 
				WIPARAMS *	wi_params_adr, 
				int 			G_mouse_x, 
				int 			G_mouse_y )
{
	/*
	 * Adr de la fenetre dans laquelle est (plus pour longtemps) s‚lectionn‚e l'ancienne icone: 
	 */
	WIPARAMS	*old_selection_adr = G_selection_adr;

	/*
	 * No de l'ic“ne d‚j… s‚lectionn‚e ds cette "fenˆtre": 
	 */
	int	selected_icon = wi_params_adr -> selected_icon;

	/*
	 * Adresse de l'arbre d'objets test‚: 
	 */
	OBJECT	*tree_adr = wi_params_adr -> draw_ptr .tree;

	/*
	 * Trouve no de l'objet sur lequel on a cliqu‚: 
	 */
	int	object= objc_find( tree_adr, 0, 5, G_mouse_x, G_mouse_y );

	/*
	 * Pointeur sur cet objet: 
	 */
	OBJECT	*obj_adr = &( tree_adr[object] );

	/*
	 * Coordonn‚es zone de travail concern‚e 
	 */
	int	wx, wy, ww, wh;

	/*
	 * V‚rifie qu'on est dans la zone de travail de la fenˆtre et que ce n'est
	 * pas l'AES qui n'a pas r‚agi lorsqu'on clique sur les boutons de la
	 * fenˆtre (‡a arrive... souvent...) 
	 */
	wind_get( wi_params_adr -> handle, WF_WORKXYWH, &wx, &wy, &ww, &wh );
	if ( G_mouse_x < wx || G_mouse_x >= wx+ww || G_mouse_y < wy || G_mouse_y >= wy + wh )
	{
		return NULL;		/* Ce clic est NUL! */
	}

	/*
	 * Cas d'une ic“ne: v‚rifie qu'on est sur l'image ou le texte... 
	 */
	if ( ((obj_adr -> ob_type) & 0x00FF) == G_ICON )
	{
		if ( !ctrl_icon( tree_adr, object, G_mouse_x, G_mouse_y ) )
		{	/*
			 * Si on … seulement cliqu‚ PRES d'une ic“ne: 
			 */
			object = objc_parent( tree_adr, object );
			obj_adr = &( tree_adr[object] );
		}
	}
	
	/*
	 * V‚rifie s'il se passe quelque chose: 
	 * CaD si on ne reclique pas sur la meme ic“ne que celle d‚j… s‚lectionn‚e: 
	 */
	if( object != selected_icon || object == 0 )
	{	/*
		 * Il va se passer quelque chose: d‚selection et/ou s‚lection: 
		 */
		/************************************/			
		/* D‚s‚lection de l'ancienne ic“ne: */
		/************************************/			
		if ( old_selection_adr != NULL )
		{	/*
			 * S'il y a d‚j… une ic“ne s‚lectionn‚e qque part: 
			 */
			OBJECT	*old_tree = old_selection_adr -> draw_ptr.tree;	/* Atbre dans lequel se trouvait l'ancienne ic“ne s‚lectionn‚e */
			int		icon = old_selection_adr -> selected_icon;
			int		start_obj;			/* Objet de d‚but du r‚affichage */

			/* printf( "unsel "); */

			/*
			 * Teste … partir de o— il faut r‚afficher: 
			 */			
			if (	G_cnf_cope_with_ltf == TRUE_1 	/* Si on veut contourner les bugs de let'm fly */
				|| old_tree[icon] .ob_type == G_IMAGE )  /* S'il s'agit d'une IMAGE */
			{	/*
				 * S'il faut r‚afficher l'objet en dessous de celui qui nousint‚resse: 
				 */
				start_obj  = objc_parent( old_tree, icon );	/* On va aussi redessiner le parent sous l'icone */
			}
			else
			{
				start_obj = icon;	/* On ne red‚ssine que l'ic“ne elle mˆme */
			}
		
			/*
			 * R‚affiche ic“ne dans son nouvel ‚tat (d‚s‚lection): 
			 */
			modif_icon( old_selection_adr, start_obj, icon, NORMAL, TAKE_CTRL );	/* D‚s‚lectionne l'ancienne ic“ne */
			old_selection_adr -> selected_icon = 0;		/* Plus d'icone s‚lectionn‚e */
		}

		/*
		 * **********************************
		 * S‚lection d'une nouvelle ic“ne:
		 * **********************************
		 */
		if( obj_adr -> ob_flags & SELECTABLE  &&  !(obj_adr -> ob_state & DISABLED) )
		{	/*
			 * Si objet s‚lectionnable: 
			 */
			int	n_compile = 0;				/* A priori, on ne peut pas d‚compiler l'objet s‚lectionn‚ */
			int	n_rename = 0;				/* A priori, on ne peut pas renommer l'objet s‚lectionn‚ */
			int	start_obj;					/* Objet de d‚but du r‚affichage */

			/* printf( "select "); */

			selected_icon = object;			/* Nouvelle ic“ne active */

			if ( G_cnf_cope_with_ltf == TRUE_1 )
			{	/*
				 * Si on veut contourner les bugs de let'm fly: 
				 */
				start_obj  = objc_parent( tree_adr, selected_icon );	/* On va aussi redessiner le parent sous l'icone */
			}
			else
			{
				start_obj = selected_icon;	/* On ne red‚ssine que l'ic“ne elle mˆme */
			}
		
			/*
			 * Modifie l'ic“ne: 
			 */
			modif_icon( wi_params_adr, start_obj, selected_icon, SELECTED, TAKE_CTRL);	/* S‚lectionne la nouvelle ic“ne: */
			G_selection_adr = wi_params_adr;		/* VAR globale: Nlle "fen" contenant la s‚lection */

			
			/*
			 * Sauvegarde icone selectionn‚e: 
			 */
			wi_params_adr -> selected_icon = selected_icon;

			/*
			 * Disable/enable options du menu OUVRIR, ParamŠtres 
			 * ET Change ligne d'infos de la fenetre:
			 */
			menu_ienable( G_menu_adr, OUVRIR, (obj_adr -> ob_flags & OUVRABLE)? 1:0 );
			menu_ienable( G_menu_adr, PARAMETR, (obj_adr -> ob_flags & PARAM)? 1:0);

			switch( wi_params_adr -> class )
			{
				case	CLASS_DIR:			/* Directory */
				{	/*
					 * Si on a s‚lectionn‚ un objet dans un directory:
					 */
					DATAPAGE	* pDataPage = page_adr_byicno( G_selection_adr -> datadir, selected_icon );
					n_rename = 1;				/* On pourra renommer l'objet en question */

					if( pDataPage != NULL && pDataPage -> DataType == DTYP_PAGES )
					{	/*
						 * Si on a s‚lectionn‚ une page ‚cran:
						 * On pourra la d‚compiler:
						 */
						n_compile = 1;	/* Enable menu D‚compiler */
					}
	
					set_infoline( wi_params_adr, dir_infoline_selection );	/* Modifie ligne d'infos */
				}
					break;

				case	CLASS_TREE:			/* Arborescence */
					if( ((obj_adr -> ob_type) & 0x00FF) == G_ICON )
					{	/*
						 * Si on a s‚lectionn‚ une page et non pas un lien:
						 * On pourra renommer l'objet en question
						 */
						n_rename = 1;				
					}
					/* printf( "infoline..."); */
					set_infoline( wi_params_adr, arbo_infoline_selection );	/* Modifie ligne d'infos */
					/* printf( "ok" ); */
					break;
			}

			menu_ienable( G_menu_adr, RENAME, n_rename);
			menu_ienable( G_menu_adr, MENDECMP, n_compile);

		}
		else 
		{	/*
			 * Si pas d'ic“ne s‚lectionn‚e (juste une D‚s‚lection) 
			 */
			wi_params_adr -> selected_icon = 0;			/* Pas d'ic“ne active */
			G_selection_adr = NULL;							/* VAR globale: Plus de s‚lection */
			menu_ienable( G_menu_adr, OUVRIR, 0);		/* Disable menu OUVRIR */
			menu_ienable( G_menu_adr, RENAME, 0);		/* Disable menu RENOMMER */
			menu_ienable( G_menu_adr, MENDECMP, 0);	/* Disable menu D‚compiler */
			menu_ienable( G_menu_adr, PARAMETR, 0);	/* Disable menu "ParamŠtres" */
		}


		/*
		 * Modifie la ligne d'infos de la fen qui contenait la s‚lection pr‚c‚dente: 
		 */
		if ( 	old_selection_adr != NULL		/* S'il y avait un s‚lection */
			&&	old_selection_adr != G_selection_adr ) /* et dans une autre fen^etre que la nouvelle s‚lection */
		{
			/*
			 * Restaure la ligne d'infos g‚n‚rales: 
			 */
			switch( old_selection_adr -> class )
			{
				case	CLASS_DIR:			/* Directory */
					set_infoline( old_selection_adr, dir_infoline );	/* Modifie ligne d'infos */
					break;

				case	CLASS_TREE:			/* Arborescence */
					set_infoline( old_selection_adr, arbo_infoline );	/* Modifie ligne d'infos */
					break;
			}
		}
	}

	/*
	 * Renvoie l'adresse de l'objet s‚lectionn‚: 
	 */
	if( obj_adr -> ob_flags & SELECTABLE &&  !(obj_adr -> ob_state & DISABLED) )
	{	/*
	 	 * Si objet s‚lectionnable:
	 	 */
		return obj_adr;
	}
	else
	{	/*
		 * Si pas s‚lectionnable:
		 */
		return	NULL;		/* Aucun objet s‚lectionn‚ */			
	}
}




/*
 * ouverture(-)
 *
 * Purpose:
 * --------
 * 'Ouverture' d'une ic“ne
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 22.11.94: teste si selection avant d'agir
 * 12.11.94: Signale SSTATE_MODIFIED pour pages ‚cran et bases de donn‚es
 */
void ouverture( void )
{
	int	selected_object;
	
	if( G_selection_adr == NULL )
	{
		ping();
		return;
	}
	
	/* 
	 * No de l'objet s‚lectionn‚: 
	 */
	selected_object =	G_selection_adr -> selected_icon;

	switch( G_selection_adr -> type )	 /* Selon le type de fenˆtre */
	{
		case	TYP_DESK:
		{
			/*
			 * Num‚ro du datagroup concern‚ par l'ouverture: 
			 */
			DATAGROUP	*datagroup = dgroup_adr_byiconno( selected_object );
			/*
			 * On va se placer dans le Dir ppal du datagroup … ouvrir: 
			 */
			DATADIR		*datadir = datagroup -> root_dir;

			switch ( selected_object )
			{
				case	DSTDISK:
					/*
					 * Cette action permet de charger un texte et
					 * de l'afficher directement! 
					 */
					ouvre_fenetre( CLASS_TEXT, TYP_TEXT,
										NULL, NULL, NULL,
										" Texte " );
					break;

				case	DSTARBO:
					ouvre_fenetre( CLASS_TREE, TYP_TREE,
										datagroup, datadir, NULL,
										" Arborescence " );
					break;
				
				case	DSTPAGES:
					ouvre_fenetre( CLASS_DIR, TYP_DIR,
										datagroup, datadir, NULL,
										" Pages Ecran " );
					break;

				case	DSTDATAS:
					ouvre_fenetre( CLASS_DIR, TYP_DIR,
										datagroup, datadir, NULL,
										" Bases de Donn‚es " );
					break;

				case	DSTTEXTS:
					ouvre_fenetre( CLASS_DIR, TYP_DIR,
										datagroup, datadir, NULL,
										" Textes " );
					break;

				case	DSTPICS:
					ouvre_fenetre( CLASS_DIR, TYP_DIR,
										datagroup, datadir, NULL,
										" Images " );
					break;

				default:							/* Si on a pas pu traiter la demande */
					ping();								/* Emmet un bip */
			}
			break;
		}
			
		case	TYP_ARBO:
		{	/*
			 * Sommaire d'une page arbo:
			 */
			ouverture_menu_arbo( G_selection_adr );
			break;
		}
		
		case	TYP_DIR:
		{	/*
			 * Groupe de donn‚es concern‚: 
			 */
			DATADIR		*	curr_datadir	= G_selection_adr -> datadir;
			DATAGROUP	*	datagroup		= G_selection_adr -> datagroup;
			DATAPAGE		*	datapage			= page_adr_byicno( curr_datadir, selected_object );
			
			switch( datagroup -> DataType )
			{
				case	DTYP_PAGES:
				case	DTYP_DATAS:
				{	/*
					 * Pages ‚cran:
					 * Bases de donn‚es:
					 * Edition du commentaire
					 */
					GRECT	GRect = { 0, 0, 0, 0 };
					if( edit_datapage_comment( datapage, &GRect ) )
					{	/* 
						 * Si on a modifi‚ le commentaire:
						 * Signale que la page a ‚t‚ modifi‚e:
						 */
						dataPage_chgSavState( datapage, SSTATE_MODIFIED, TRUE_1, TRUE_1 );
					}
					break;
				}
				
				case	DTYP_TEXTS:
					ouvre_fenetre( CLASS_DATAPAGE, TYP_TEXT,
										datagroup, curr_datadir, datapage,
										"" );
					break;
	
				case	DTYP_PICS:
					ouvre_fenetre( CLASS_DATAPAGE, TYP_PI3,
										datagroup, curr_datadir, datapage,
										"" );
					break;
					
				default:
					signale("Type de donn‚es de la fenˆtre non reconnu");
			}
			break;
		}
		
		case	TYP_TREE:			
		{	/*
			 * Arborescence 
			 */
			ouverture_page_arbo( G_selection_adr );
			break;
		}
						
		default:
			ping();
	}

	/*
	 * D‚s‚lectionne l'ic“ne qu'on vient d' "ouvrir" : 
	 */
	{
		OBJECT	*tree = G_selection_adr -> draw_ptr.tree;
		int		start_obj;
		/*
		 * Teste … partir de o— il faut r‚afficher: 
		 */
		if (	G_cnf_cope_with_ltf == TRUE_1 	/* Si on veut contourner les bugs de let'm fly */
			|| tree[selected_object] .ob_type == G_IMAGE )  /* S'il s'agit d'une IMAGE */
		{	/*
			 * S'il faut r‚afficher l'objet en dessous 
			 * de celui qui nous int‚resse: 
			 */
			start_obj = objc_parent( tree, selected_object );	/* On va aussi redessiner le parent sous l'icone */
		}
		else
		{
			start_obj = selected_object;	/* On ne red‚ssine que l'ic“ne elle mˆme */
		}
		/*
		 * R‚affiche: 
		 */
		modif_icon( G_selection_adr, start_obj, selected_object, NORMAL, TAKE_CTRL );
		no_selection();			/* Reset des flags */
	}
}



/*
 * sauver(-)
 *
 * Purpose:
 * --------
 * 'Sauvegarde' d'une ic“ne ou du contenu d'une fenˆtre
 * sur le disque
 *
 * Suggest:
 * ------
 * On devrait pouvoir sauver les debug text etc...
 *
 * History:
 * --------
 * 31.05.94: fplanque: Created
 */
void sauver( void )
{
	/*
	 * teste s'il y a une s‚lection:
	 */
	if( G_selection_adr == NULL )
	{	/*
		 * Pas de s‚lection:
		 * On va sauver le contenu de la fenˆtre au 1er plan:
		 */
		if( G_wi_list_adr	!= NULL )
		{	/*
			 * S'il y a une fenˆtre au premier plan
			 */
			switch ( G_wi_list_adr -> type )	 /* Selon le type de fenˆtre */
			{
				case	TYP_TEXT:
					sauve_texte( G_wi_list_adr -> content_ptr.textInfo );
					break;
					
				default:
					signale("Ne sait pas sauver le contenu de cette fenˆtre" );
			}
		}
	}

}


/*
 * parametrage(-)
 *
 * Purpose:
 * --------
 * 'Param‚trage' d'une ic“ne
 *
 * History:
 * --------
 * fplanque: Created
 */
void parametrage ( const GRECT *start_box )
{
	/* No de l'objet s‚lectionn‚: */
		int	selected_object	= 	G_selection_adr -> selected_icon;

	/* printf("Type de fenˆtre: %X ",G_selection_adr -> type); */
	switch ( G_selection_adr -> type )	 /* Selon le type de fenˆtre */
	{
		case	TYP_DESK:
		{
			switch ( selected_object )
			{
				case	DSTTERM:
					/*
					 * Param‚trage Terminla:
					 */
					param_term( start_box );
					break;
				
				default:							/* Si on a pas pu traiter la demande */
					ping();								/* Emmet un bip */
			}
			break;
		}
			
		default:
			ping();
	}

}



/*
 * no_selection(-)
 *
 * Purpose:
 * --------
 * Supprime toute s‚lection d'ic“ne au niveau 
 *	des flags (pas d'affichage)
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	no_selection( void )
{
		menu_ienable( G_menu_adr, OUVRIR, 0);			/* Disable "Ouvrir" */
		menu_ienable( G_menu_adr, RENAME, 0);			/* Disable "Renommer" */
		menu_ienable( G_menu_adr, PARAMETR, 0);		/* Disable "ParamŠtres" */

		G_selection_adr -> selected_icon= 0;			/* Plus d'ic“ne s‚lectionn‚e */
		G_selection_adr = NULL	;							/* Plus de fen o— se trouve select */
}



/*
 * drag_icon(-)
 *
 * Purpose:
 * --------
 * D‚placement d'une ic“ne
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 17.06.94: teste 'OVERLAPPED' plut“t que WF_TOP
 */
int	drag_icon( 
			int start_x, 
			int start_y, 
			int n_new_x, 
			int n_new_y )
{
	int	n_drag_evt;			/* EvŠnement qui s'est d‚clench‚: */
	int	n_new_bstate, n_kbd_state, n_kbd_return, n_mouse_nbc;	/* Non utilis‚s */
	int	i,j;
	int	start_obj=-1, sel_x, sel_y; /* Objet de d‚part avec coordonn‚es */
	int	offset_x , offset_y;
	int	fantome_x, fantome_y;
	int	area_x1, area_y1, area_x2, area_y2;	/* Zone de d‚placement du fant“me */
	int	n_new_handle;					/* Handle de la "fenˆtre" o— se trouve actuellement la souris */
	int	last_spot=-1;				/* Dernier objet que l'on avait "allum‚" */

	/* 
	 * Simule "construction ‚cran" pour empˆcher l'AES de d‚rouler ses menus: 
	 * vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv 
	 */
	start_WINDRAW( NULL );
	/*
	 * Forme souris: 
	 */
	graf_mouse( FLAT_HAND, NULL );	/* Main ouverte */

	/*
	 * Calcule la zone ds laquelle peut se d‚placer le fant“me: 
	 */	
	area_x1 = G_x_mini;
	area_y1 = G_y_mini;
	area_x2 = G_x_mini + G_w_maxi - G_icon_w;
	area_y2 = G_y_mini + G_h_maxi - G_icon_h;

	/* Calcule offset entre ic“ne-start et pointeur de la souris: */
	objc_offset( G_selection_adr -> draw_ptr.tree,
					 G_selection_adr -> selected_icon, &sel_x, &sel_y );
	offset_x = sel_x - start_x;
	offset_y = sel_y - start_y;

	/* Objet de d‚part: (slt si sur desktop) */
	if ( G_selection_adr == G_desk_params_adr )
		start_obj = G_selection_adr -> selected_icon;


	/* Fixe les paramŠtres de dessin VDI: */
	vsl_color( G_ws_handle, RED );					/* Couleur */		
	vswr_mode( G_ws_handle, MD_XOR );				/* Mode XOR */
	vsl_type( G_ws_handle, 7 );						/* Motif utilisateur */
		
	/*
	 * Boucle de mouvement: 
	 */
	do
	{	/*
	 	 * Cherche sur quoi se trouve le pointeur de la souris: 
	 	 */			
		n_new_handle = wind_find( n_new_x, n_new_y );
		if ( n_new_handle == 0)
		{ 	/*
		 	 * Si on est sur le bureau: 
		 	 */
			sensitive_desk( n_new_x, n_new_y, start_obj, &last_spot );
		}
		/*	else	/* Si pas sur desktop: */
		/*	printf("WIN:%d \r",n_new_handle);*/
	
		/*
		 * Coordonn‚es auxquelles il faut dessiner le fant“me: 
		 */
		fantome_x = n_new_x + offset_x;
		if ( fantome_x < area_x1 )
		{
			fantome_x = area_x1;
		}
		else if ( fantome_x > area_x2 )
		{
			fantome_x = area_x2;
		}
		
		fantome_y = n_new_y + offset_y;
		if ( fantome_y < area_y1 )
		{
			fantome_y = area_y1;
		}
		else if ( fantome_y > area_y2 )
		{
			fantome_y = area_y2;
		}
		
		for( i=1, j=0; i<=9; i++ )
		{
			G_pxyarray[ j ]= fantome_x + G_fantome_icone[ j++ ];
			G_pxyarray[ j ]= fantome_y + G_fantome_icone[ j++ ];
		}
		
		/*
		 * Dessin du fant“me de l'ic“ne: 
		 */
		draw_fantom( fantome_x, fantome_y ); 
			
		/*
		 * Attend qu'il se passe qque chose: 
		 */
		n_drag_evt=evnt_multi( MU_BUTTON | MU_M1,
								1, 1, 0,							/* Observe le relachement du bouton gauche */
                        1, n_new_x, n_new_y, 1, 1,		/* Observe tout d‚placement de la souris */ 
                        0, 0, 0, 0, 0,
                        0L, 
                        0, 0,
                        &n_new_x, &n_new_y, &n_new_bstate,
                        &n_kbd_state, &n_kbd_return,
                        &n_mouse_nbc);

		/*
		 * Efface le fant“me de l'ic“ne: 
		 */
		draw_fantom( fantome_x, fantome_y ); 
		
	} while( n_drag_evt != MU_BUTTON );

	/*
	 * Il faut remettre en place certains attributs de dessin: 
	 */
	vswr_mode( G_ws_handle, MD_REPLACE );			/* FIN Mode XOR */

	/*
	 * D‚s‚lectionne l'ic“ne destination: 
	 */
	if ( last_spot != -1 )
	{
		modif_icon( G_desk_params_adr, last_spot, last_spot, NORMAL, CTRL_OK );	/* D‚S‚lectionne */
	}
	
	/*
	 * Fin du drag 
	 */
	graf_mouse(BUSYBEE, 0);			/* Change curseur souris */
	end_WINDRAW();
	/* ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ */

	/*
	 * No de l'objet sur lequel on a tir‚ l'ic“ne de d‚part 
	 * -1 si aucune ou si last=start 
	 */
	return	last_spot;
}



/*
 * mouvement(-)
 *
 * Purpose:
 * --------
 * 'Mouvement' d'une ic“ne vers une autre
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * 19.06.94: gestion des groupes textes & images
 * 09.08.94: plus de redraw apres efface_1page ni aprŠs DataGrp_MergeFile, il devrait dej… etre fait ds subroutine
 * 26.12.94: ectraction du reset datagroup
 */
void mouvement( int destination )
{
	int	resultat = 0;				/* R‚sultat de l'op‚ration */
	int	n_SrcIcon 	= G_selection_adr -> selected_icon; /* Ic“ne de d‚part */

	/* 
	 * Adr ic“nes source & dest: 
	 */
	OBJECT	*srce_tree	= (G_selection_adr -> draw_ptr).tree;
	OBJECT	*srce_adr	= &(G_selection_adr -> draw_ptr).tree[ n_SrcIcon ];
	OBJECT	*dest_adr	= &G_desktop_adr[ destination ];

	switch ( G_selection_adr -> class )	 
	{	
		case	CLASS_DESK:			
			/*
			 * D‚part: Bureau 
			 */
			switch ( n_SrcIcon )
			{
				case	DSTDISK:				
				{	/* 
					 * D‚part: DISQUE 
					 */
					switch ( destination )
					{
						case	DSTARBO:			/* Destination arbo */
						{
							DATAGROUP	*datagroup = dgroup_adr_byiconno( destination );

							if( (datagroup -> root_dir) == NULL )
							{	/* 
								 * Si arbo vierge: ok 
								 */
								graf_beginmove( srce_tree, srce_adr, destination, dest_adr );
								resultat= DataGrp_MergeFile( datagroup );	
							}
							else
							{	/*
							 	 * Si l'arbo est d‚j… occupp‚e: 
							 	 */
								form_alert(1,"[1][|Vous ne pouvez charger|"
														"une arborescence que|"
														"dans un dossier vierge!]"
														"[ Abandon ]");
								resultat = 1;
							}
							break;
						}
						
						case	DSTPAGES:		/* Destination pages ‚cran */
						case	DSTDATAS:		/* Destination Donn‚es */
						case	DSTTEXTS:		/* Destination textes */
						case	DSTPICS:			/* Destination images */
						{
							DATAGROUP	*datagroup = dgroup_adr_byiconno( destination );
						
							graf_beginmove( srce_tree, srce_adr, destination, dest_adr );

							resultat= DataGrp_MergeFile( datagroup );	

							break;
						}
							
					}
					if ( resultat>1 )
					{	/*
					 	 * Si le chargement s'est effectu‚ 
					 	 */
						graf_endmove( srce_tree, n_SrcIcon, srce_adr, destination, dest_adr );
					}				
					break;
				}
				
				case	DSTARBO:					/* D‚part: ARBO */
				case	DSTPAGES:				/* D‚part: PAGES */
				case	DSTDATAS:				/* D‚part: donn‚es */
				case	DSTTEXTS:				/* D‚part: textes */
				case	DSTPICS:					/* D‚part: images */
				{	/*
				 	 * D‚part: un DATAGROUP:
					 * Num‚ro du datagroup concern‚: 
					 */
					DATAGROUP	*datagroup = dgroup_adr_byiconno( n_SrcIcon );
					
					/* 
					 * Etat du groupe: 
					 */
					SSTATE	sstate_dgrp	= dataGroup_getSavState( datagroup );

					/*
					 * Selon la destintaion: 
					 */
					switch ( destination )
					{
						case	DSTTRASH:		
							/* 
							 * Destination: CORBEILLE 
							 * RESET du DataGroup:
							 */
							graf_beginmove( srce_tree, srce_adr, destination, dest_adr );
							if( DataGrp_Reset( datagroup ) )
							{	/*
							 	 * Si on a supprim‚: 
							 	 */
								graf_endmove( srce_tree, n_SrcIcon, srce_adr, destination, dest_adr );
							}
							else
							{	/*
								 * D‚s‚lectionne l'ic“ne (source) qu'on vient de traiter : 
			 					 */
								modif_icon( G_selection_adr, n_SrcIcon, n_SrcIcon, NORMAL, TAKE_CTRL );
							}
							no_selection();
							resultat=1;
							break;
						
						case	DSTDISK:		
						{	/* 
							 * Destination: DISQUE 
							 * Sauvegarde des donn‚es d'un groupe: 
							 * D‚but effet graphique: 
							 */	
							graf_beginmove( srce_tree, srce_adr, destination, dest_adr );
						
							/* 
							 * Si le datagroup n'est pas vierge: 
							 */
							if( sstate_dgrp != SSTATE_EMPTY )
							{	/*
								 * Sauvegarde: 
								 */
								resultat= sauve_DataGroup( dgroup_adr_byiconno( n_SrcIcon ) );	
								
								/* 
								 * Fin effet graphique: 
								 */
								if ( resultat > 0 )
								{
									graf_endmove( srce_tree, n_SrcIcon, srce_adr, destination, dest_adr );
								}
							}

							resultat = 1;
						}
					}			
					break;
				}
			}
			break;

		case	CLASS_DIR:
		{	/*
			 * D‚part: un directory de zone de donn‚es 
			 */
			DATAGROUP *	curr_datagroup = G_selection_adr -> datagroup;
			DATADIR	 *	curr_datadir 	= G_selection_adr -> datadir;
			DATAPAGE	 *	pDataPage		= page_adr_byicno( curr_datadir, n_SrcIcon );
			DATATYPE		data_type		= curr_datagroup -> DataType;		/* Type de donn‚es */

			if( pDataPage == NULL )
			{	/*
			 	 * Si pas de page associ‚e … l'ic“ne:
			 	 */
				signale( "Pas de Datapage associ‚e" );
				break;
			}

			switch ( destination )
			{
				case	DSTDISK:
					{	/*
						 * Sauve page ind‚pendante sur disque:
						 */
						graf_beginmove( srce_tree, srce_adr, destination, dest_adr );
	
						sauve_DataPage( curr_datadir, pDataPage );
	
						resultat=1;
					}
					break;
					
				case	DSTTERM:					/* Destination terminal */
					if ( data_type == DTYP_PAGES )
					{	/* 
						 * S'il s'agit de pages ‚cran: 
						 */
						graf_beginmove( srce_tree, srce_adr, destination, dest_adr );

						visu_page( pDataPage, NULL ); 	/* Visu page */
	
						resultat=1;
					}
					break;

				case	DSTTRASH:				/* Destination poubelle! */
				{
					/*
					 * Effet graphique: 
					 */
					graf_beginmove( srce_tree, srce_adr, destination, dest_adr );

					/* 
					 * Demande conf et efface: 
					 */
					resultat = ( efface_1data( curr_datadir, pDataPage ) )
									? 2 : 1;

					if ( resultat > 1 )
					{	/*
					 	 * Si on a confirm‚ la suppression: 
					 	 */
						/* BoŒte en mouvement: */
							graf_movebox(
								srce_adr -> ob_width, srce_adr -> ob_height, 				/* Dimensions boŒte */
								srce_adr -> ob_x + srce_tree -> ob_x, srce_adr -> ob_y + srce_tree -> ob_y,		/* Coord d‚part */
								dest_adr -> ob_x + G_x_mini, dest_adr -> ob_y + G_y_mini );	/* Coord dest */
		
							/*
							 * Plus d'ic“ne s‚lectionn‚e: 
							 */
							no_selection();

							/*
							 * D‚s‚lectionne destination: 
							 */
							modif_icon( G_desk_params_adr, destination, destination, NORMAL, TAKE_CTRL );

					}
					break;
				}
			}
			break;			
		}
	}


	switch( resultat )
	{
		case 0:			/* Op impossible */
			alert( PERR_IMPOSSIBLE_OP );		/* Op‚ration impossible */
			break;
			
		case 1:			/* No comment on operation */
			/* 
			 *	D‚s‚lectionne destination: 
			 */
			modif_icon( G_desk_params_adr, destination, destination, NORMAL, TAKE_CTRL );
			break;

	}
}



/*
 * graf_beginmove(-)
 *
 * Purpose:
 * --------
 * D‚but d'un mouvement d'ic“ne
 *
 * History:
 * --------
 * 1993: fplanque: Created
 */
void	graf_beginmove( OBJECT *srce_tree, OBJECT *srce_adr, int destination, OBJECT *dest_adr )
{
	/* BoŒte en mouvement: */
		graf_movebox(
			srce_adr -> ob_width, srce_adr -> ob_height, 				/* Dimensions boŒte */
			srce_adr -> ob_x + srce_tree -> ob_x, srce_adr -> ob_y + srce_tree -> ob_y,		/* Coord d‚part */
			dest_adr -> ob_x + G_x_mini, dest_adr -> ob_y + G_y_mini );	/* Coord dest */

	/* S‚lectionne destination: */
			modif_icon( G_desk_params_adr, destination, destination, SELECTED, TAKE_CTRL );
}



/*
 * graf_endmove(-)
 *
 * Purpose:
 * --------
 * Fin d'un mouvement d'ic“ne complet
 *
 * History:
 * --------
 * fplanque: Created
 */
void	graf_endmove( 
			OBJECT *srce_tree, 
			int n_SrcIcon, 
			OBJECT *srce_adr, 
			int destination, 
			OBJECT *dest_adr )
{
	/* D‚s‚lectionne l'ic“ne (n_SrcIcon) qu'on vient de traiter : */
		modif_icon( G_selection_adr, n_SrcIcon, n_SrcIcon, NORMAL, TAKE_CTRL );
		
	/* BoŒte en mouvement: */
		graf_movebox(
			srce_adr -> ob_width, srce_adr -> ob_height, 				/* Dimensions boŒte */
			srce_adr -> ob_x + srce_tree -> ob_x, srce_adr -> ob_y + srce_tree -> ob_y,		/* Coord d‚part */
			dest_adr -> ob_x + G_x_mini, dest_adr -> ob_y + G_y_mini );	/* Coord dest */
				
	/* S‚lectionne ic“ne destination en m‚moire: */
		G_selection_adr = G_desk_params_adr;
		G_selection_adr -> selected_icon = destination;
	/* Disable/enable menu OUVRIR */
		menu_ienable( G_menu_adr, OUVRIR, ( G_desktop_adr[ destination ] .ob_flags & OUVRABLE ));
}




/*
 * apropos(-)
 *
 * Purpose:
 * --------
 * Affichage boite d'infos
 *
 * History:
 * --------
 * 1993:fplanque: Created
 */
void apropos( const GRECT *start_box )
{
	int		exit_obj;					/* Objet de sortie */
	GRECT		form_box;					/* Dimensions du formulaire */
	int		edit = 0;					/* Bidon */

	/* App prend en charge souris */
	WIND_UPDATE_BEG_MCTRL

	open_dialog( M_apropos_adr, start_box, &form_box );
	
	exit_obj=ext_form_do( M_apropos_adr, &edit);	/* Gestion de la boŒte */

	close_dialog( M_apropos_adr, exit_obj, start_box, &form_box );

	/* AES peut reprendre la souris */
	WIND_UPDATE_END_MCTRL
}






/*
 * main_quitter(-)
 *
 * Purpose:
 * --------
 * Appell‚ Lorsque l'utilisateur veut quitter
 * Ferme les fenetres avec demande de confirmation si contenu modifi‚
 * Contr“le si tout est sauv‚ et le cas ‚ch‚ant, demande s'il faut sauver
 * et finalement sauve h‚h‚ :)
 *
 * History:
 * --------
 * 02.10.94: fplanque: Created
 * 07.01.95: ferme les fenetres avant de proposer de sauver les groupes, en effet lors de la fermeture d'une fenetre on peut modifier un groupe!
 */   
BOOL	main_quitter( void )		/* Out: TRUE si on autorise … quitter */
{
	while (G_top_wi_handle != 0)		
	{	/*
		 * Tant qu'on a une fenˆtre ouverte 
		 * On ferme celle du dessus
		 */
		if( ! ferme_fenetre( G_wi_list_adr, TRUE_1 ) )
		{	/*
			 * On ne quitte pas!
			 */
			return	FALSE0;
		}
	}

	if( get_ServSState() == SSTATE_MODIFIED )
	{	/*
		 * Le serveur a ‚t‚ modifi‚ depuis derniŠre sauvegarde:
		 */
		do
		{
			switch( alert( DLG_SAVE_QUIT ) )
			{
				case	1:
					DataGroups_SaveAll();
					break;
	
				case	2:
					return	TRUE_1;
			
				case	3:
					return	FALSE0;
			}

		/*
		 * Si tout n'a pas ‚t‚ sauv‚, on va reposer la question fatidique!
		 */

		} while ( get_ServSState() == SSTATE_MODIFIED );
		
		return	TRUE_1;
	}
	else
	{	/*
		 * Tous les fichiers en RAM sont sauv‚s:
		 */
		if( alert( DLG_QUIT ) == 1 )
		{	
			return	TRUE_1;
		}
	}

	/*
	 * On ne quitte pas!
	 */
	return	FALSE0;
}



