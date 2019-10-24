/*
 * MeinMenu.c
 *
 * S'occupe de g‚rer le menu ppal
 *
 * 20.11.94: Created
 */

 	#include "!OPTIONS.H"				/* Options de compilation */         
	#define	THIS_FILE	"MAINMENU.C v1.00 - 03.95"
 
/*
 * System headers:
 */
	#include	<stdio.h>
	#include <string.h>
	#include	<stdlib.h>					/* header librairie de fnct std */
	#include <aes.h>
	#include	<tos.h>						/* Malloc pour KERMAP */
	#include	<ctype.h>
	#include	<ext.h>
		          
/*
 * Custom headers:
 */
	#include "SPEC_PU.H"
	#include "STUT_ONE.RSC\STUT_3.H"					/* noms des objets ds le ressource */
	#include	"WIN_PU.H"
	#include "ARBKEYPU.H"
	#include "DATPG_PU.H"	
	#include "MAIN_PU.H"	
	#include	"DEBUG_PU.H"	
	#include "SHORT_PU.H"	
	#include "MMENU_PU.H"	
	#include	"OBJCT_PU.H"	
	#include	"SERV_PU.H"	
	#include "TEXT_PU.H"

/*
 * Variables internes publiques:
 */
	OBJECT *	G_menu_adr;					/* Ptr sur le MENU ! */

/*
 * External prototypes:
 */
	extern	void	renommer_selection(
							GRECT		*	pGRect_start );		/* In: d‚but effet graphique d'ouverture */
	extern	void	new_arbo( int type, const GRECT *start_box );
	/* 
	 * Bases: 
	 */
	extern	void	creer_rubrique( GRECT *start_box );


	extern	void	compile_page( GRECT *pGRect_start );
	extern	void	decompile_page( GRECT *pGRect_start );

	extern	void affecte_voies( const GRECT *start_box );

	extern	void	initialiser( void );
	extern	void	sauver_param_inf( void );
	extern	void	charger_param_inf ( void );
	extern	void	set_compat( const GRECT *start_box );
	extern	void	sauver_config_ini( void );
	extern	WIPARAMS	*ouvre_fenetre( int class, int type,
										DATAGROUP *datagroup, DATADIR *datadir, DATAPAGE *datapage,
										const char *titre );
	extern	void	put_wi_on_top( WIPARAMS *wi_params_adr );

/*
 * ------------------------- METHODES ------------------------
 */

/*
 * init_MainMenu(-)
 *
 * Purpose:
 * --------
 * Init des prises s‚rie et des boŒtes de configuration
 *
 * Suggest:
 * --------
 * La d‚tection de support Bconmap doit ˆtre chang‚e:
 * Detecter le type de BIOS avant d'appeller Bconmap.
 *
 * History:
 * --------
 * 20.11.94: fplanque: Created
 */
void	init_MainMenu( void )
{
	if (rsrc_gaddr( R_TREE, MENU, &G_menu_adr) == 0)
		erreur_rsrc();
	Create_KeyMap( G_menu_adr );
}



/*
 * selection_menu(-)
 *
 * Purpose:
 * --------
 * S‚lection d'une option menu
 *
 * History:
 * --------
 * 1993: fplanque: Created
 * aprŠs: ajout de nouvelles entr‚es
 * 20.11.94: Prend no title et Entry en parametre
 * 22.11.94: teste si entry enabled avant d'appeller traitement
 * 25.03.95: chg‚ ttmnt SYSTEMST
 */
void selection_menu(
			int	menu_title,		/* In: Titre de menu s‚lectionn‚ */
			int	menu_entry )	/* In: Entr‚e de menu s‚lectionn‚e */
{
	GRECT	menu_box;				/* Coord du titre menu s‚lectionn‚ */

	/*
	 * V‚rifie si l'option de menu est actuellement disponible
	 * c_a_d non gris‚e
	 */
	if( ! objc_TestEnable( G_menu_adr, menu_entry ) )
	{	/*
	 	 * D‚s‚lection titre, abandon
	 	 */
		menu_tnormal( G_menu_adr, menu_title, 1);
		return;	
	}

	graf_mouse(BUSYBEE, 0);		/* Change curseur souris */

	/*
	 * D‚termine coordonn‚es du titre de menu s‚lectionn‚: 
	 */
	objc_xywh( G_menu_adr, menu_title, &menu_box );

	/*
	 * En fonction de l'entr‚e s‚lectionn‚e 
	 */
	switch( menu_entry )
	{
		case	INFOS:
			apropos( &menu_box );
			break;

   	case	OUVRIR: 
			ouverture();
			break;

		case	FERMER:
			/* Ferme fen sup‚rieure */
			ferme_fenetre( G_wi_list_adr, TRUE_1 );	
			break;

		case	SAUVER:
			/* Sauve contenu fen sup‚rieure ds datapage associ‚e */
			sauver_ram( G_wi_list_adr );
			break;

		case	SAVEAS:
			ping();
			break;
		
		case	SAVEDISK:
			sauver();
			break;

		case	RENAME:
			/*
			 * Renommer le fichier s‚lectionn‚ 
			 */
			renommer_selection( &menu_box );	
			break;

		case	PREMPLAN:
			/*
			 * RamŠne dernier au 1er plan 
			 */
			cycle_window();			
			break;

		case	QUITTER:
			/* Demande conf et tout ‡a... */
			if( main_quitter() == TRUE_1 )
			{
				G_fin=1;						/* Signale qu'on veut quitter le prg */
			}
			break;

	   case	MENNEWLK:
			/*
			 * Cr‚er un nouveau lien dans la fen sup‚rieure: 
			 */
			new_arbo( 0, &menu_box );				
	   	break;

		case	MENNEWPG:
			/* 
			 * Cr‚er une nlle page dans la fen sup‚rieure: 
			 */
			new_arbo( 1, &menu_box );				
	   	break;

		case	MENEWRUB:
			/* 
			 * Cr‚er une nlle rubrique ds fen sup‚rieure: 
			 */
			creer_rubrique( &menu_box );
			break;

		case	MENEWTXT:
			/* 
			 * Cr‚er une nouveau texte ds fen sup‚rieure: 
			 */
			create_newText( &menu_box );
			break;

		case	MENCOMPI:
			/*
			 * Compile contenu de la fenˆtre sup‚rieure:
			 */
			compile_page( &menu_box );
			break;

		case	MENDECMP:
			/*
			 * D‚Compile page ‚cran s‚lectionn‚e:
			 */
			decompile_page( &menu_box );
			break;

		case	STESTLOC:	
			lancer_serv( SMODE_TEST, menu_title );		/* Test du serveur en mode local */
	  		break;

		case	SLANCER:	
			lancer_serv( SMODE_NORMAL, menu_title );	/* Lancement du serveur en mode normal */
	  		break;

		case	SAFFECT:
			affecte_voies( &menu_box );		/* Affectation de voies */
			break;
			
		case	MINISERV:
			initialiser();							/* Initialisation du serveur */			
			break;
			
		case	MLOADINF:
			charger_param_inf();					/* Charger chemins d'accŠs serveur + fichiers indiqu‚s */
			break;

		case	MSAVEINF:
			sauver_param_inf();		/* Sauver les chemins d'accŠs serveur */
			break;
			
		case	PARAMETR:	
			parametrage( &menu_box );
			break;
						
	   case	AFFICHAG:
			/*
			 * ParamŠtres d'affichage de la fen sup‚rieure: 
			 */
			if	( G_wi_list_adr != NULL )	/* S'il y a au - 1 fen ouverte: */
			{
				switch( G_wi_list_adr -> menu_options.affichage )
				{
					case	PARAFF_TEXT:
						/*
						 * Texte 
						 */
						params_texte( &menu_box );				
						break;
						
					default:
						signale("Pas de params d'affichage pour cette fenetre");
				}
			}
	   	break;

		case	MECOMPAT:
   		/* Compatibilit‚: */
			set_compat( &menu_box );
			break;
			
		case	MSAVEINI:
			sauver_config_ini();		/* Sauver configuration */
			break;			
   		
   	case	VIDE: 
   		ouvre_fenetre( CLASS_EMPTY, TYP_EMPTY,
   							NULL,NULL,NULL,
   							" Sans titre " );
	  		break;

		case	DEBUG:
			if ( G_debug_window == NULL )
			{	/*
				 * Si Fenˆtre de d‚bugging pas encore ouverte: 
				 */
	 	 		ouvre_fenetre( CLASS_TEXT, TYP_DEBUG,
	 	 							NULL,NULL,NULL,
	 	 							" Debug Information " );
			}
			else
			{
				put_wi_on_top( G_debug_window );	/* Place fen au premier plan */
			}
	  		break;

			
		case	SYSTEMST:		/* Demande status systŠme: */			
		{
			size_t	freemem = (size_t) Malloc( -1 );
			size_t	scoreleft = coreleft();

			sprintf( G_tmp_buffer, "Freemem=%lu Kb   CoreLeft=%lu Kb", freemem, scoreleft );
			add_textinf( G_debug_window, G_tmp_buffer );
			break;
		}
			
		default:							/* Si on a pas pu traiter la demande */
			signale("Pas de routines associ‚e");
	}


	/*
	 * D‚s‚lection de l'entr‚e de menu s‚lectionn‚e 
	 */ 
	menu_tnormal(G_menu_adr, menu_title, 1);

}




/*
 * sauver_ram(-)
 *
 * Purpose:
 * --------
 * 'Sauvegarde' d'une datapage en ram
 *
 * History:
 * --------
 * 19.06.94: fplanque: Created base on sauver()
 * 14.12.94: prend WIPARAMS* en arg
 */
void sauver_ram(
			WIPARAMS	*	pWiParams )	/* In: fenˆtre dont il faut sauver le contenu */
{
	/*
	 * On va sauver le contenu de la fenˆtre au 1er plan:
	 */
	if( pWiParams	== NULL 
		 || pWiParams -> class != CLASS_DATAPAGE )
	{
		ping();
		return;
	}

	/*
	 * S'il y a une fenˆtre au premier plan
	 */
	switch ( pWiParams -> type )	 /* Selon le type de fenˆtre */
	{
		case	TYP_TEXT:
			/*
			 * Sauve le texte dans la page:
			 */
			save_text2datapage( pWiParams -> content_ptr.textInfo,
										pWiParams -> datapage );
			/*
			 * Signale que la page a ‚t‚ modifi‚e:
			 */
			dataPage_chgSavState( pWiParams -> datapage, SSTATE_MODIFIED, TRUE_1, TRUE_1 );

			/*
			 * Signale que le contenu de la fenˆtre n'a pas ‚t‚ modifi‚
			 * depuis la derniŠre sauvegarde:
			 */
			Wnd_ClearModified( pWiParams );
			break;
			
		default:
			signale("Ne sait pas sauver le contenu de cette fenˆtre" );
	}
}



/*
 * handle_keypress(-)
 *
 * Purpose:
 * --------
 * Traite l'appui sur une touche
 * dans la boucle ppale du prg
 * (Enfin pour l'instant on est limit‚ aux raccourcis claviers)
 *
 * History:
 * --------
 * 20.11.94: fplanque: Created
 * 22.11.94: fplanque: utilisation de KEYTAB (thanks to P. Craponne)
 * 08.01.95: renvoie code de retour
 */
BOOL	handle_keypress(			/* Out: TRUE_1 si reconnu */
			int	n_kbd_state, 	/* In: Etat du clavier lors de l'appui de touche */
			int	n_ScanCode, 	/* In: Scancode de la touche press‚e */
			char	c_car	)			/* In: Code ascii de la touche */
{
	int			n_MenuTitle;
	int			n_MenuEntry;
	KEYTAB	*	pKeyTab;
	
	/* printf( "\r kbd_state:%X  ScanCode:%X  car=%d  ", n_kbd_state, n_ScanCode, (int)c_car ); */

	if( n_kbd_state && (K_CTRL | K_ALT) )
	{	/*
		 * S'il faut retrouver le code ASCII:
		 */
		pKeyTab = Keytbl( (void *) NIL_1, (void *) NIL_1, (void *) NIL_1 );
	
		c_car = toupper( (pKeyTab -> unshift)[ n_ScanCode ] );
	}
	
	/* printf( "ultimately: %d   ", (int)c_car ); */

	n_MenuEntry = Lookup_Shortkey( n_kbd_state, n_ScanCode, c_car, &n_MenuTitle );
	
	if( n_MenuEntry != NIL_1 )
	{	/*
		 * Si raccourci clavier reconnu:
		 * S‚lection titre:
		 */
		menu_tnormal( G_menu_adr, n_MenuTitle, 0);
		
		/*
		 * Traitement associ‚:
		 */
		selection_menu( n_MenuTitle, n_MenuEntry );
		
		return	TRUE_1;
	}
	
	return	FALSE0;
}