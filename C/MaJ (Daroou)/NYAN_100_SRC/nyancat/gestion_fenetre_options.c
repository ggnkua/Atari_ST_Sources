/* **[Options]****************** */
/* * Module options            * */
/* * 30/12/2016 MaJ 09/05/2024 * */
/* ***************************** */


#include "../fonction/coeur/fcm_gestion_bit_objet.c"
#include "../fonction/coeur/fcm_objet_change.c"
#include "../fonction/coeur/fcm_gestion_objet_bouton.c"
#include "../fonction/coeur/fcm_sauver_config.c"
#include "../fonction/fcm_my_file_select.c"
#include "../fonction/fcm_formate_cheminfichier.c"


#include "set_sound.c"
#include "affiche_error.c"
#include "demande_redemarrage.c"


extern int16 Fcm_image_cache_actif;
extern char  Fcm_chemin_image_cache[FCM_TAILLE_CHEMIN];


/* Prototype */
void gestion_fenetre_options( const int16 controlkey, const int16 touche, const int16 bouton );



/* Fonction */
void gestion_fenetre_options( const int16 controlkey, const int16 touche, const int16 bouton )
{
	OBJECT	*adr_dialogue_option;
	int16	 objet;
	int16	 valeur = 0;
	int16	 commande = 0;


	FCM_LOG_PRINT4("#Fcm_gestion_fenetre_options(%d,%d ($%04x),%d)", controlkey, touche, touche, bouton );


	adr_dialogue_option = Fcm_adr_RTREE[DL_OPTIONS];

	objet = objc_find( adr_dialogue_option, 0, 4, souris.g_x, souris.g_y);


	if( touche )
	{

		if( controlkey == 0 )
		{
			switch( touche & 0xff)
			{
				case 0x0D:	/* return */
					valeur = 1;
					commande = 4;
					break;
			}

			switch( touche & 0xff00)
			{
				case 0x0100:	/* ESCape */
					commande = 5;
					break;
			}
		}


		if( controlkey == K_ALT )
		{
			switch( touche )
			{
				case 0x1700:	/* Alt-i  activer cache */
					commande = 6;
					break;
				case 0x1900:	/* Alt-p  chemin cache */
					commande = 7;
					break;
				case 0x2100:	/* Alt-f  force to monochrome */
					commande = 1;
					break;
				case 0x1000:	/* Alt-a  animation full speed */
				case 0x2f00:	/* Alt-v  animation full speed */
					commande = 2;
					break;
				case 0x2e00:	/* Alt-c  couper son */
					commande = 3;
					break;
				case 0x1F00:	/* Alt-s Sauver */
					commande = 4;
					valeur = 1;
					break;
			}
		}
	}


	if( bouton )
	{
		switch( objet )
		{
			case OPTION_FORCEMONO:
			case CHECK_FORCEMONO:
				commande = 1;
				break;

			case OPTION_MAXFPS:
			case CHECK_MAXFPS:
				commande = 2;
				break;

			case OPTION_MUTESOUND:
			case CHECK_MUTESOUND:
				commande = 3;
				break;

			case OPTION_SAUVER:
				commande = 4;
				break;

			case OPTION_CACHEIMG:
			case CHECK_CACHEIMG:
				commande = 6;
				break;

			case OPTION_PATHCACHE:
				commande = 7;
				break;

			case OPTION_PALETTE:
			case CHECK_PALETTE:
				commande = 8;
				break;

			case OPTION_FRAME_BUF:
			case CHECK_FRAME_BUF:
				commande = 9;
				break;

			case RAM_POPUP_RAM:
				commande = 10;
				break;

			case OPTION_POPUP_PIX:
				commande = 11;
				break;
		}
	}





	/* ------------------------------------ */
	/* CheckBox : Forcer le mode Mono       */
	/* ------------------------------------ */
	if( commande == 1 )
	{
		global_force_mode_mono = FALSE;

		/* On change l'‚tat de notre checkbox... */
		if( Fcm_gestion_bit_objet(adr_dialogue_option, h_win[W_OPTIONS], CHECK_FORCEMONO, OS_SELECTED) != 0 )
		{
			global_force_mode_mono = TRUE;
		}


		if( Fcm_screen.nb_plan >= 4  &&	 (		(global_affichage_mode == AFFICHAGE_MODE_COULEUR  &&  global_force_mode_mono == TRUE)
											||	(global_affichage_mode == AFFICHAGE_MODE_MONO     &&  global_force_mode_mono == FALSE) )  )
		{
			int16 reponse;

			Fcm_affiche_alerte( DATA_MODE_APPLI, ALT_REDEMARRAGE, &reponse );

			FCM_LOG_PRINT1( "#Fcm_affiche_alerte , reponse=%d)", reponse );

			if( reponse == 2 )
			{
				/* l'utilisateur veut redemarrer de suite */
				global_app_restart = TRUE;
				
				buffer_aes[0] = AP_TERM;
				buffer_aes[1] = ap_id;
				buffer_aes[2] = 0;
				buffer_aes[3] = 0;
				appl_write( ap_id, 16, &buffer_aes );
			}
		}
	}




	/* -------------------------------------- */
	/* CheckBox : Vitesse max animation (fps) */
	/* -------------------------------------- */
	if( commande == 2 )
	{
		global_max_fps = FALSE;

		/* On change l'‚tat de notre checkbox... */
		if( Fcm_gestion_bit_objet(adr_dialogue_option, h_win[W_OPTIONS], CHECK_MAXFPS, OS_SELECTED) != 0 )
		{
			global_max_fps = TRUE;
		}
	}




	/* -------------------------------------- */
	/* CheckBox : Couper le son               */
	/* -------------------------------------- */
	if( commande == 3 )
	{
		global_mute_sound = FALSE;

		/* On change l'‚tat de notre checkbox... */
		if( Fcm_gestion_bit_objet(adr_dialogue_option, h_win[W_OPTIONS], CHECK_MUTESOUND, OS_SELECTED) != 0 )
		{
			global_mute_sound = TRUE;
		}

		set_sound();
	}



	/* ------------------------- */
	/* Bouton Sauver les options */
	/* ------------------------- */
	if( commande == 4 )
	{
		/* Si le bouton a ‚t‚ activ‚ au clavier */
		if( valeur )
		{
			Fcm_objet_change( adr_dialogue_option, h_win[W_OPTIONS], OPTION_SAUVER, OS_SELECTED );
			evnt_timer(FCM_BT_PAUSE_DOWN);
			Fcm_objet_change( adr_dialogue_option, h_win[W_OPTIONS], OPTION_SAUVER, 0 );
			evnt_timer(FCM_BT_PAUSE_UP);
		}
		else
		{
			/* Activ‚ avec la souris */
			if( Fcm_gestion_objet_bouton(adr_dialogue_option, h_win[W_OPTIONS], OPTION_SAUVER) != OPTION_SAUVER )
			{
				/* Bouton non valid‚, on quitte */
				return;
			}
		}

		Fcm_sauver_config(TRUE);

		if( valeur == 1  ||  (bouton != 2  &&  valeur == 0) )
		{
			Fcm_fermer_fenetre( W_OPTIONS );
		}
	}



	/* ------------------------- */
	/* Touche ESCape             */
	/* ------------------------- */
	if( commande == 5 )
	{
		Fcm_fermer_fenetre( W_OPTIONS );
	}



	/* -------------------------------------- */
	/* CheckBox : activer le cache            */
	/* -------------------------------------- */
	if( commande == 6 )
	{
		Fcm_image_cache_actif = FALSE;

		/* On change l'‚tat de notre checkbox... */
		if( Fcm_gestion_bit_objet(adr_dialogue_option, h_win[W_OPTIONS], CHECK_CACHEIMG, OS_SELECTED) != 0 )
		{
			Fcm_image_cache_actif = TRUE;
		}
	}



	/* -------------------------------------- */
	/* Box : chemin pour le cache             */
	/* -------------------------------------- */
	if( commande == 7 )
	{
		char fichier[FCM_TAILLE_FICHIER];
		int16 reponse;


		fichier[0] = '\0';

		reponse = Fcm_my_file_select( PRG_FULL_NOM, FCM_TAILLE_CHEMIN, FCM_TAILLE_FICHIER, Fcm_chemin_image_cache, fichier, "*.*" );
		
		if( reponse == TRUE )
		{
			FCM_LOG_PRINT2( "-> Fcm_chemin_image_cache{chemin=%s fichier=%s}", Fcm_chemin_image_cache, fichier );

			{
				char chemin[FCM_TAILLE_CHEMIN];

				//strcpy( chemin, Fcm_chemin_image_cache );
				//snprintf( chemin, FCM_TAILLE_CHEMIN, "%s", Fcm_chemin_image_cache );
				snprintf( chemin, FCM_TAILLE_CHEMIN, Fcm_chemin_image_cache );
				Fcm_formate_cheminfichier( chemin, strlen(adr_dialogue_option[OPTION_PATHCACHE].ob_spec.tedinfo->te_ptext) );
				Fcm_set_rsc_string( DL_OPTIONS, OPTION_PATHCACHE, chemin );
				Fcm_objet_draw( adr_dialogue_option, h_win[W_OPTIONS], OPTION_PATHCACHE, FCM_WU_BLOCK );
			}
		}
		else if( reponse < 0 )
		{
			affiche_error( reponse );
		}
	}



	/* ------------------------------------ */
	/* CheckBox : Utiliser la palette       */
	/* ------------------------------------ */
	if( commande == 8 )
	{
		global_utilise_palette = FALSE;

		/* On change l'‚tat de notre checkbox... */
		if( Fcm_gestion_bit_objet(adr_dialogue_option,  h_win[W_OPTIONS], CHECK_PALETTE, OS_SELECTED) != 0 )
		{
			global_utilise_palette = TRUE;
		}

		demande_redemarrage();
	}



	/* ----------------------------- */
	/* Offscreen pour le framebuffer */
	/* ----------------------------- */
	if( commande == 9 )
	{
		global_vdihandle_framebuffer = vdihandle;
		global_use_VDI_offscreen_for_framebuffer = FALSE;

		/* On change l'‚tat de notre checkbox... */
		if( Fcm_gestion_bit_objet(adr_dialogue_option, h_win[W_OPTIONS], CHECK_FRAME_BUF, OS_SELECTED) != 0 )
		{
			global_vdihandle_framebuffer = global_handleoffscreen_framebuffer;
			global_use_VDI_offscreen_for_framebuffer = TRUE;
		}
	}



	/* ------------------------- */
	/* Pop Up RAM                */
	/* ------------------------- */
	if( commande == 10 )
	{
		objet = Fcm_gestion_pop_up( DL_OPTIONS, RAM_POPUP_RAM, POPUP_RAM);

		/* Mise … jour du popup */
		if( objet != -1  &&  objet != Fcmgfx_CreateSurface_ram_type_select )
		{
			Fcm_set_rsc_string( DL_OPTIONS, RAM_POPUP_RAM, Fcm_adr_RTREE[POPUP_RAM][objet].ob_spec.free_string );
			Fcmgfx_CreateSurface_ram_type_select = (uint16)objet;
			Fcm_objet_draw( adr_dialogue_option, h_win[W_OPTIONS], RAM_POPUP_RAM, FCM_WU_BLOCK );

			demande_redemarrage();
		}
	}




	/* ------------------------- */
	/* Pop Up PIXEL              */
	/* ------------------------- */
	if( commande == 11 )
	{
		objet = Fcm_gestion_pop_up( DL_OPTIONS, OPTION_POPUP_PIX, POPUP_PIXEL);

		/* Mise … jour du popup */
		if( objet != -1  &&  objet != global_pixel_label_actif )
		{
			Fcm_set_rsc_string( DL_OPTIONS, OPTION_POPUP_PIX, Fcm_adr_RTREE[POPUP_PIXEL][objet].ob_spec.free_string );
			global_pixel_label_actif = (uint16)objet;
			Fcm_objet_draw( adr_dialogue_option, h_win[W_OPTIONS], OPTION_POPUP_PIX, FCM_WU_BLOCK );

			switch( Fcm_screen.nb_plan )
			{
				case 8:
					global_pixel_8bits = (uint16)objet;
					break;
				case 16:
					global_pixel_16bits = (uint16)objet;
					break;
				case 24:
					global_pixel_24bits = (uint16)objet;
					break;
				case 32:
					global_pixel_32bits = (uint16)objet;
					break;
			}

			if( objet == POP_PIXEL_AUTO )
			{
				Fcm_screen.pixel_xformat = global_save_pixel_xformat;
			}

			/* redemarrage, si on est pas en mode Mono */
			if( global_force_mode_mono != TRUE )
			{
				demande_redemarrage();
			}
		}
	}


	return;


}

