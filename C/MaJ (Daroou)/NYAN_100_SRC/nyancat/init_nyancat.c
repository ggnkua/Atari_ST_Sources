/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 20/05/2020 * */
/* ***************************** */

#include "appli_error_code.h"
#include "affiche_error.c"


#include "../fonction/ldg/tga_sa_ldg.h"


#include "check_fichier.c"


#include "init_surface_mono.c"
#include "init_surface_couleur.c"

#include "costablex2.h"

#include "build_screen_mono.c"
#include "build_screen_couleur.c"

#include "init_animation.c"


#include "set_offscreen_framebuffer.c"

#include "load_sound.c"




/* prototype */
int32 init_nyancat( void );




/* Fonction */
int32 init_nyancat( void )
{
	int32 reponse;
	int16 flag_render_ok;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_nyancat()"CRLF);
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" global_force_mode_mono=%d"CRLF, global_force_mode_mono);
	log_print(FALSE);
	#endif



	/* Quel mode d'affichage ? on affecte les pointeurs de fonction */
	if( Fcm_screen.nb_plan < 4 || global_force_mode_mono == TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Affichage sprite en MONO"CRLF);
		log_print(FALSE);
		#endif

		/* affichage en mono */
		init_surface = init_surface_mono;
		build_screen = build_screen_mono;

		global_affichage_mode = AFFICHAGE_MODE_MONO;
	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Affichage sprite en COULEUR"CRLF);
		log_print(FALSE);
		#endif

		/* affichage en couleur */
		init_surface = init_surface_couleur;
		build_screen = build_screen_couleur;

		global_affichage_mode = AFFICHAGE_MODE_COULEUR;
	}



	flag_render_ok=TRUE;





	/* mode 256 couleurs ou plus, format des pixels reconnu ? */
	/* par défaut, tous les labels sont en mode AUTO (voir nyancat_global.h) */
	if( global_pixel_label_actif == POP_PIXEL_AUTO )
	{
		/* Mode Auto, si le format des pixels est reconnu, Fcm_screen.pixel_xformat contient le codage du format  */
		/* (voir Fcm_get_screen_info() ), dans le cas contraire, contient (-1) , alors on demande à l'utilisateur */
		/* de selectionner une mire avec les bonnes couleurs RGB                                                  */
		if( global_force_mode_mono==FALSE && (Fcm_screen.nb_plan >= 8 && Fcm_screen.pixel_xformat <= 0) )
		{
			/* on demande l'aide de l'utilisateur pour trouver le format des pixels */
			Fcm_select_pixel_xformat();

			/* on memorise le choix de l'utilisateur */
			switch( Fcm_screen.pixel_xformat )
			{
				case PIXEL_15_FALCON:
					global_pixel_label_actif = POP_PIX_15B_FAL;
					global_pixel_16bits = global_pixel_label_actif;
					break;
				case PIXEL_15_MOTOROLA:
					global_pixel_label_actif = POP_PIX_15B_MOT;
					global_pixel_16bits = global_pixel_label_actif;
					break;
				case PIXEL_15_INTEL:
					global_pixel_label_actif = POP_PIX_15B_INT;
					global_pixel_16bits = global_pixel_label_actif;
					break;
				case PIXEL_16_MOTOROLA:
					global_pixel_label_actif = POP_PIX_16B_MOT;
					global_pixel_16bits = global_pixel_label_actif;
					break;
				case PIXEL_16_INTEL:
					global_pixel_label_actif = POP_PIX_16B_INT;
					global_pixel_16bits = global_pixel_label_actif;
					break;
				case PIXEL_24_MOTOROLA:
					global_pixel_label_actif = POP_PIX_24B_MOT;
					global_pixel_24bits = global_pixel_label_actif;
					break;
				case PIXEL_24_INTEL:
					global_pixel_label_actif = POP_PIX_24B_INT;
					global_pixel_24bits = global_pixel_label_actif;
					break;
				case PIXEL_32_MOTOROLA:
					global_pixel_label_actif = POP_PIX_32B_MOT;
					global_pixel_32bits = global_pixel_label_actif;
					break;
				case PIXEL_32_INTEL:
					global_pixel_label_actif = POP_PIX_32B_INT;
					global_pixel_32bits = global_pixel_label_actif;
					break;
				case PIXEL_8_PACKED:
					global_pixel_label_actif = POP_PIX_8B_PACK;
					global_pixel_8bits = global_pixel_label_actif;
					break;
				case PIXEL_8_PLAN:
					global_pixel_label_actif = POP_PIX_8B_PLAN;
					global_pixel_8bits = global_pixel_label_actif;
					break;
			}
		}
	}
	else
	{
		/* Mode Forcé: choix de l'utilisateur, soit parceque le format n'est pas reconnu, soit */
		/* parceque l'utilisateur a forcé le format via le POP UP pixel du dialogue Options    */

		/* on force le format des pixels avec le choix de l'utilisateur */
		switch( Fcm_screen.nb_plan )
		{
			case 8:
				Fcm_screen.pixel_xformat = PIXEL_8_PACKED;
				if( global_pixel_label_actif == POP_PIX_8B_PLAN )
				{
					Fcm_screen.pixel_xformat = PIXEL_8_PLAN;
				}
				break;

			case 15:
			case 16:
				Fcm_screen.pixel_xformat = PIXEL_15_FALCON;
				if( global_pixel_label_actif == POP_PIX_15B_MOT )
				{
					Fcm_screen.pixel_xformat = PIXEL_15_MOTOROLA;
				}
				if( global_pixel_label_actif == POP_PIX_15B_INT )
				{
					Fcm_screen.pixel_xformat = PIXEL_15_INTEL;
				}
				if( global_pixel_label_actif == POP_PIX_16B_INT )
				{
					Fcm_screen.pixel_xformat = PIXEL_16_INTEL;
				}
				if( global_pixel_label_actif == POP_PIX_16B_MOT )
				{
					Fcm_screen.pixel_xformat = PIXEL_16_MOTOROLA;
				}
				break;

			case 24:
				Fcm_screen.pixel_xformat = PIXEL_24_INTEL;
				if( global_pixel_label_actif == POP_PIX_24B_MOT )
				{
					Fcm_screen.pixel_xformat = PIXEL_24_MOTOROLA;
				}
				break;

			case 32:
				Fcm_screen.pixel_xformat = PIXEL_32_INTEL;
				if( global_pixel_label_actif == POP_PIX_32B_MOT )
				{
					Fcm_screen.pixel_xformat = PIXEL_32_MOTOROLA;
				}
				break;
		}
	}


	/* ---------------------------- */
	/* Couleur pour les masques VDI */
	/* ---------------------------- */
	

	/* couleur pour la fonction vrt_cpyfm() lorsqu'elle affiche un masque pour la fonction vro_cpyfm() */
	couleur_mask_vrt[0] = 0;
	couleur_mask_vrt[1] = 1;

	if(  Fcm_screen.nb_plan>8 && global_affichage_mode==AFFICHAGE_MODE_COULEUR)
	{
		couleur_mask_vrt[0] = 1;
		couleur_mask_vrt[1] = 0;
	}



	/* couleur mask vrt_cpyfm() des étoiles */
	couleur_etoile[0] = G_LBLACK;     /* 9 */
	couleur_etoile[1] = 0;

	if( global_affichage_mode==AFFICHAGE_MODE_MONO )
	{
		couleur_etoile[0] = G_BLACK;  /* 1 */
		couleur_etoile[1] = 0;
	}


	couleur_vrt_copy[0]=1;
	couleur_vrt_copy[1]=0;





	Fcm_fenetre_launch( LH_INIT, LAUNCH_INIT, 16-1 ); /* nombre total d'appel a Fcm_fenetre_launch => bar progression */
	Fcm_fenetre_launch( LH_INIT_NYANCAT, LAUNCH_OPEN, LAUNCH_WAIT_FAST);


	/* ******************************************************** */
	/* * Init Generale                                        * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_VERIF_FICHIER, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


	reponse = check_fichier();

	if( reponse != 0 )
	{
		/* un ou plusieurs fichiers manquant... */
		global_app_restart = FALSE; /* on ne doit pas redemmarer */
		return(reponse);
	}







	/* ******************************************************** */
	/* * Open TGA_SA_LDG                                      * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_OUVRE_TGA_LDG, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

	{
		int16 ldg_tga_version = 0;

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" open_LDG_TGA()"CRLF );
		log_print(FALSE);
		#endif

		if( open_LDG_TGA(&ldg_tga_version) != 0L )
		{
			/* erreur   */
			flag_render_ok     = FALSE;
			global_app_restart = FALSE; /* on ne doit pas redemmarer si erreur de LDG */

			#ifdef LOG_FILE
			sprintf( buf_log, " Erreur !!! TGA_SA.LDG version : $%04x, (%x.%x)"CRLF, ldg_tga_version, (ldg_tga_version>>8), (ldg_tga_version&0xff) );
			log_print(FALSE);
			#endif
		
			return( APPLI_ERROR_OPEN_TGA_LDG );
		}

		#ifdef LOG_FILE
		sprintf( buf_log, " TGA_SA.LDG version : $%04x, (%x.%x)"CRLF, ldg_tga_version, (ldg_tga_version>>8), (ldg_tga_version&0xff) );
		log_print(FALSE);
		#endif

		if( ldg_tga_version < GLOBAL_TGA_SA_VERSION_NEEDED )
		{
			flag_render_ok=FALSE;
			global_app_restart=FALSE; /* on ne doit pas redemmarer si erreur de LDG */

			return( APPLI_ERROR_BAD_TGA_LDG );
		}

	}





	/* ******************************************************** */
	/* * Init Surface                                         * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_INIT_SURFACE1, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

	

	reponse = init_surface();

	if( reponse != 0L )
	{
		flag_render_ok = FALSE;

		if( global_nb_redemarrage_succesif != 0 )
		{
			/* on reboucle sans cesse, on y met fin */
			global_app_restart = FALSE;
		}

		global_nb_redemarrage_succesif++;
		Fcmgfx_CreateSurface_ram_type_select = SURFACE_RAM_TYPE_SELECT_AUTO;

	}
	else
	{
		global_nb_redemarrage_succesif = 0;
	}





	/* ******************************************************** */
	/* * Fermeture TGA_SA.LDG                                 * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_FERME_TGA_LDG, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

	close_LDG_TGA();




	/* ******************************************************** */
	/* * Partie graphique OK ?                                * */
	/* ******************************************************** */
	if( flag_render_ok == FALSE )
	{
		/* erreur, on stoppe l'init et on redemarre eventuellement ... */
		return(reponse);
	}




	/* ******************************************************** */
	/* * Offscreen pour le framebuffer                        * */
	/* ******************************************************** */
	global_vdihandle_framebuffer = vdihandle;

	set_offscreen_framebuffer();

	if( global_use_VDI_offscreen_for_framebuffer==TRUE )
	{
		global_vdihandle_framebuffer = global_handleoffscreen_framebuffer;
	}


	/* ******************************************************** */
	/* * Offscreen pour l'ecran                               * */
	/* ******************************************************** */
	global_vdihandle_ecran = vdihandle; /* VDIhandle de l'application */

	




	/* ******************************************************** */
	/* * Init Sound                                           * */
	/* ******************************************************** */

	global_flag_audio_musique_charger = FALSE;
	global_flag_audio_error = 0;

	global_musique.adresse_start      = 0L;
	global_musique.adresse_end        = 0L;
	global_musique.adresse_pause      = 0L;
	global_musique.adresse_loop_start = 0L;
	global_musique.adresse_loop_end   = 0L;
	global_musique.status        = FCM_MUSIQUE_STATUS_STOP;
	global_musique.play_mode     = FCM_MUSIQUE_PLAYMODE_LOOP;
	global_musique.frequence     = SOUND_FREQUENCE;
	global_musique.stereo        = FCM_MUSIQUE_STEREO;
	global_musique.rez_bit       = SOUND_BIT_SAMPLE;
	global_musique.signe         = FCM_MUSIQUE_SIGNED;

	/* on charge la musique, si systeme sonore compatible Falcon (XBIOS) */
	if( Fcm_systeme.xbios_sound == TRUE )
	{
		Fcm_fenetre_launch( LH_INIT_SOUND, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		reponse = load_sound();

		if( reponse == 0 )
		{
			global_flag_audio_musique_charger = TRUE;
		}
		else
		{
			/* on memorise le code d'erreur */
			global_flag_audio_error = reponse;
			/* on coupe le son */
			global_mute_sound = TRUE;
		}
	}
	else
	{
		/* on memorise l'erreur */
		global_flag_audio_error = APPLI_ERROR_XBIOS_FALCON;
		/* on coupe le son */
		global_mute_sound = TRUE;
	}

	if( global_flag_audio_error != 0 )
	{
		OBJECT	*adr_dialogue_option;
		rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_dialogue_option );

		SET_BIT_W( (adr_dialogue_option+CHECK_MUTESOUND )->ob_state, OS_DISABLED, 1 );
		SET_BIT_W( (adr_dialogue_option+OPTION_MUTESOUND )->ob_state, OS_DISABLED, 1 );
	}


	/* ******************************************************** */
	/* * Execution module termin‚e                            * */
	/* ******************************************************** */


	Fcm_fenetre_launch( LH_INIT_TERMINE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	Fcm_fenetre_launch( LH_INIT_TERMINE, LAUNCH_CLOSE, LAUNCH_WAIT_FAST);



	global_animation_pause = 0;

	/* ------------------------- */
	/* Tableau pour l'appl_write */
	/* ------------------------- */
	tube_gem[0] = 12345;
	tube_gem[1] = ap_id;
	tube_gem[2] = 0;
	tube_gem[3] = 0;
	tube_gem[4] = 0;
	tube_gem[5] = 0;
	tube_gem[6] = 0;
	tube_gem[7] = 0;



	return 0L;


}

