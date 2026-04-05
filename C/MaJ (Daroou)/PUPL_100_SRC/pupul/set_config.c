/* **[Pupul]******************** */
/* *                           * */
/* * 20/08/2014 MaJ 07/11/2023 * */
/* ***************************** */

#include "../fonction/fcm_formate_cheminfichier.c"

#include "set_popup_ram.c"
#include "set_popup_pixel.c"
#include "set_popup_mod_update.c"
#include "set_popup_mod_frequence.c"


/* Fonction */
void set_config( void )
{


	FCM_LOG_PRINT(" * START set_config() *"CRLF );


	/* --------------------------------------------------------- */
	/* config sp‚cifique … l'application                         */
	/* --------------------------------------------------------- */


	/* ******************************************************* */
	/* * Fenetre Options                                     * */
	/* ******************************************************* */
	{
		OBJECT	*adr_formulaire;

		/* Adresse du dialogue pr‚f‚rence */
		//rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_formulaire );
		adr_formulaire = Fcm_adr_RTREE[DL_OPTIONS];


		/* ---------------------------- */
		/* Activer le cache image       */
		/* ---------------------------- */
		{
			char chemin[FCM_TAILLE_CHEMIN];

			if( strlen(Fcm_chemin_image_cache) == 0 )
			{
				sprintf( Fcm_chemin_image_cache, "%sDATA\\CACHE\\", Fcm_chemin_courant);
			}

			strcpy( chemin, Fcm_chemin_image_cache );
			Fcm_formate_cheminfichier( chemin, strlen(adr_formulaire[OPTION_PATHCACHE].ob_spec.tedinfo->te_ptext)  );
			Fcm_set_rsc_string( DL_OPTIONS, OPTION_PATHCACHE, chemin );


			if( Fcm_image_cache_actif == TRUE )
			{
				/* Cache actif */
				SET_BIT_W( adr_formulaire[CHECK_CACHEIMG].ob_state, OS_SELECTED, 1);
			}
			else
			{
				/* cache inactif */
				SET_BIT_W( adr_formulaire[CHECK_CACHEIMG].ob_state, OS_SELECTED, 0);
			}
		}


		/* ---------------------------- */
		/* Force mode monochrome        */
		/* ---------------------------- */
		{
			if( global_force_mode_mono == TRUE )
			{
				/* Mode mono forcé */
				SET_BIT_W( (adr_formulaire+CHECK_FORCEMONO)->ob_state, OS_SELECTED, 1);
			}
			else
			{
				/* Mode normal */
				SET_BIT_W( (adr_formulaire+CHECK_FORCEMONO)->ob_state, OS_SELECTED, 0);
			}
		}


		/* ---------------------------- */
		/* Vitesse Max Animation        */
		/* ---------------------------- */
		{
			if( global_max_fps == TRUE )
			{
				/* Max FPS */
				SET_BIT_W( adr_formulaire[CHECK_MAXFPS].ob_state, OS_SELECTED, 1);
			}
			else
			{
				/* FPS normal */
				SET_BIT_W( adr_formulaire[CHECK_MAXFPS].ob_state, OS_SELECTED, 0);
			}
		}



		/* ---------------------------- */
		/* Couper le son                */
		/* ---------------------------- */
		{
			if( global_mute_sound == TRUE )
			{
				/* son coupé */
				SET_BIT_W( adr_formulaire[CHECK_MUTESOUND].ob_state, OS_SELECTED, 1);
			}
			else
			{
				/* son actif */
				SET_BIT_W( adr_formulaire[CHECK_MUTESOUND].ob_state, OS_SELECTED, 0);
			}
		}



		/* ---------------------------- */
		/* palette ecran                */
		/* ---------------------------- */
		{
			if( global_utilise_palette==TRUE )
			{
				/* modification de la palette pour que ce soit moins degueulasse ;) en 16 couleurs */
				SET_BIT_W( adr_formulaire[CHECK_PALETTE].ob_state, OS_SELECTED, 1);
			}
			else
			{
				SET_BIT_W( adr_formulaire[CHECK_PALETTE].ob_state, OS_SELECTED, 0);
			}

			/* pas besoin dans les résolutions supérieurs à 256 couleurs, on desactive */
			if( Fcm_screen.nb_plan != 4 || global_force_mode_mono==TRUE )
			{
				SET_BIT_W( adr_formulaire[CHECK_PALETTE].ob_state, OS_DISABLED, 1 );
				SET_BIT_W( adr_formulaire[OPTION_PALETTE].ob_state, OS_DISABLED, 1 );
			}
			else
			{
				SET_BIT_W( adr_formulaire[CHECK_PALETTE].ob_state, OS_DISABLED, 0 );
				SET_BIT_W( adr_formulaire[OPTION_PALETTE].ob_state, OS_DISABLED, 0 );
			}
		}



		/* ---------------------------- */
		/* Offscreen framebuffer        */
		/* ---------------------------- */
		{
			if( global_use_VDI_offscreen_for_framebuffer == TRUE )
			{
				/* handle offscreen pour l'ecran */
				SET_BIT_W( adr_formulaire[CHECK_FRAME_BUF].ob_state, OS_SELECTED, 1);
			}
			else
			{
				/* handle application pour l'ecran */
				SET_BIT_W( adr_formulaire[CHECK_FRAME_BUF].ob_state, OS_SELECTED, 0);
			}

			/* pas d'offscreen possible, on desactive */
			if( global_handleoffscreen_framebuffer == 0 )
			{
				SET_BIT_W( adr_formulaire[CHECK_FRAME_BUF].ob_state, OS_DISABLED, 1 );
				SET_BIT_W( adr_formulaire[OPTION_FRAME_BUF].ob_state, OS_DISABLED, 1 );
			}
		}
	}


	/* ----------------------------- */
	/* Options: Label popup Type RAM */
	/* ----------------------------- */
	set_popup_ram();

	/* ---------------------------- */
	/* Options: Label popup Pixel   */
	/* ---------------------------- */
	set_popup_pixel();

	/* --------------------- */
	/* MOD LDG: update popup */
	/* --------------------- */
	set_popup_mod_update();

	/* --------------------- */
	/* MOD LDG: freq popup   */
	/* --------------------- */
	set_popup_mod_frequence();


	/* ---------------------------------------- */
	/* Titre des fenêtres                       */
	/* ---------------------------------------- */
#ifdef LOG_FILE
	snprintf( fcm_win_titre_texte[W_PUPUL], FCM_WIN_TITRE_MAXSIZE, "%s *Debug*", PRG_FULL_NOM );
#else
	snprintf( fcm_win_titre_texte[W_PUPUL], FCM_WIN_TITRE_MAXSIZE, "%s", PRG_FULL_NOM );
#endif
	fcm_win_info_texte[W_PUPUL] = win_info_texte;

	snprintf( fcm_win_titre_texte[W_MODLDG ], FCM_WIN_TITRE_MAXSIZE, APP_WIN_PREFIX_TITRE" %s", Fcm_adr_RTREE[DL_TITRE_W_APPLI][ win_titre[W_MODLDG] ].ob_spec.free_string);
	snprintf( fcm_win_titre_texte[W_OPTIONS], FCM_WIN_TITRE_MAXSIZE, APP_WIN_PREFIX_TITRE" %s", Fcm_adr_RSTRING[TITRE_OPTIONS] );



	FCM_LOG_PRINT(" * END set_config() **********************************");


	return;


}

