/* **[Pupul]******************** */
/* *                           * */
/* * 12/08/2014 MaJ 07/11/2023 * */
/* ***************************** */

#include "appli_error_code.h"
#include "affiche_error.c"


#include  "../fonction/ldg/tga_sa_ldg.h"
#include  "../fonction/ldg/mod.h"


#include "check_fichier.c"


#include "init_surface_couleur.c"
#include "init_surface_mono.c"

#include "load_animation.c"

#include "build_screen_couleur.c"
#include "build_screen_mono.c"

#include "init_animation.c"


#include "set_offscreen_framebuffer.c"

#include "init_audio.c"





/* prototype */
int32 init_pupul( void );




/* Fonction */
int32 init_pupul( void )
{
	int32 reponse;
	int16 flag_render_ok;




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_pupul()"CRLF);
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" global_force_mode_mono=%d"CRLF, global_force_mode_mono);
	log_print(FALSE);
	#endif



	/* ******************************************************** */
	/* * handle VDI par defaut                                * */
	/* ******************************************************** */
	global_vdihandle_framebuffer = vdihandle; /* VDIhandle de l'application (coeur) */
	global_vdihandle_ecran       = vdihandle;



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

	global_flag_audio_ok=TRUE; /* passe a FALSE si le fichier audio est absent ( check_fichier() )*/



	/* mode 256 couleurs ou plus, format des pixels reconnu ? */
	/* par défaut, tous les labels sont en mode AUTO (voir pupul_global.h) */
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



	couleur_vrt_copy[0]=1;
	couleur_vrt_copy[1]=0;




	Fcm_fenetre_launch( LH_INIT, LAUNCH_INIT, 38-1 ); /* nombre total d'appel a Fcm_fenetre_launch => bar progression */
	Fcm_fenetre_launch( LH_INIT_PUPUL, LAUNCH_OPEN, LAUNCH_WAIT_FAST);



	/* ******************************************************** */
	/* * Init Generale                                        * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_VERIF_FICHIER, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


	reponse = check_fichier();

	if( reponse != 0 )
	{
		global_app_restart=FALSE; /* on ne doit pas redemmarer si erreur */
		return(reponse);
	}




	/* ******************************************************** */
	/* * Chargement animation                                 * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_CHARGE_ANIM, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


	reponse= load_animation();

	if( reponse != 0 )
	{
		return(reponse);
	}




	/* ******************************************************** */
	/* * Recherche des niveaux de gris                        * */
	/* ******************************************************** */

	Fcm_fenetre_launch( LH_CHERCHE_GRIS, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


	gray_nbindex= Fcm_find_pal_gray_color( gray_index, MAX_GRAY_INDEX, MAX_GRAY_COLOR);

	if( gray_nbindex == 0 )
	{
		/* cela devrait jamais arriver, vu que je conserve la couleur noir et blanc dans la palette */
		gray_index[0]=1;
		gray_nbindex=1;
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
	/* * Offscreen pour le framebuffer ?                      * */
	/* ******************************************************** */
	set_offscreen_framebuffer();

	if( global_use_VDI_offscreen_for_framebuffer==TRUE )
	{
		global_vdihandle_framebuffer = global_handleoffscreen_framebuffer;
	}









	/* ******************************************************** */
	/* * Open MOD.LDG                                         * */
	/* ******************************************************** */

#ifdef LOG_FILE
sprintf( buf_log, CRLF"# Init Sound (global_flag_audio_ok=%d  -  Fcm_systeme.xbios_sound=%d)"CRLF, global_flag_audio_ok, Fcm_systeme.xbios_sound );
log_print(FALSE);
#endif

	global_flag_audio_error = -1;

	/* Si les fichiers audio sont présents (check_fichier()) et si le systeme sonore Xbios est disponible */
	if( global_flag_audio_ok==TRUE && Fcm_systeme.xbios_sound==TRUE )
	{

		Fcm_fenetre_launch(LH_OUVRE_MOD_LDG, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		if( init_LDG_MOD() == TRUE )
		{

			/* ******************************************************** */
			/* * Init Audio                                           * */
			/* ******************************************************** */

			Fcm_fenetre_launch( LH_INIT_AUDIO, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


			if( init_audio() != 0 )
			{
				global_flag_audio_ok=FALSE;

				/* ******************************************************** */
				/* * Fermeture MOD.LDG                                    * */
				/* ******************************************************** */

				Fcm_fenetre_launch( LH_FERME_MOD_LDG, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

				ldg_close( ldg_MOD, ldg_global );
			}
			else
			{
				global_flag_audio_error = 0;
			}

		}
		else
		{
			global_flag_audio_ok=FALSE;
			affiche_error(APPLI_ERROR_OPEN_MOD_LDG);
		}
	}
/*	else
	{
		global_flag_audio_ok = FALSE;
		global_flag_audio_error = -1;
	}*/


#ifdef LOG_FILE
sprintf( buf_log, "global_flag_audio_error=%d"CRLF, global_flag_audio_error );
log_print(FALSE);
#endif


	if( global_flag_audio_error != 0 )
	{
		/* Une erreur niveau audio, on désactive la partie son */
		OBJECT	*adr_dialogue_option;
		rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_dialogue_option );

		SET_BIT_W( (adr_dialogue_option+CHECK_MUTESOUND )->ob_state, OS_SELECTED, 1 );
		SET_BIT_W( (adr_dialogue_option+CHECK_MUTESOUND )->ob_state, OS_DISABLED, 1 );
		SET_BIT_W( (adr_dialogue_option+OPTION_MUTESOUND )->ob_state, OS_DISABLED, 1 );

		global_mute_sound=TRUE;
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

	tube_gem[0]=12345;
	tube_gem[1]=ap_id;
	tube_gem[2]=0;
	tube_gem[3]=0;
	tube_gem[4]=0;
	tube_gem[5]=0;
	tube_gem[6]=0;
	tube_gem[7]=0;




	return 0L;


}

