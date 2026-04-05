/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 24/01/2024 * */
/* ***************************** */


void build_screen_mushroom_couleur( void );





void build_screen_mushroom_couleur( void )
{
	static int16 mushroom_view=0;
	static uint32 mushroom_timer=0;



	/* R‚-initialisation de l'animation */
	if( build_screen_restart == TRUE )
	{
		mushroom_view        = 0;
		build_screen_restart = FALSE;
		mushroom_timer       = Fcm_get_timer();
	}



	/* L'animation est une image fixe, une fois affich‚ */
	/* plus besoin de la r‚-afficher                    */ 
	if( mushroom_view == index_sequence_animation )
	{
		/* si son coupé, plus de synchro avec la musique, l'animation progresse toute seule */
		if( global_mute_sound==TRUE && (Fcm_get_timer()-mushroom_timer)>200 )
		{
			/* 1 seconde écoulé, on peut passer a l'animation suivante */
			index_sequence_animation++;
		}

		return;
	}


	/* L'animation a chang‚, on affiche l'image corespondante */
	mushroom_view = index_sequence_animation;


	{
		int16 mushroom_idx;

		switch(index_sequence_animation)
		{
			case 1:
			case 4:
			case 7:
				mushroom_idx=MUSHROOM_IN;
				break;
			default:
				mushroom_idx=MUSHROOM_OUT;
				break;
		}

		/* ----------------------------------------- */
		/* Affichage Mushroom dans l'‚cran offscreen */
		/* ----------------------------------------- */
		vro_cpyfm(global_vdihandle_framebuffer,S_ONLY,pxy_screen, &mfdb_mushroom[mushroom_idx], &mfdb_framebuffer );
	}


	Fcm_liste_refresh_ecran[0].g_x=0;
	Fcm_liste_refresh_ecran[0].g_y=0;
	Fcm_liste_refresh_ecran[0].g_w=SCREEN_WIDTH;
	Fcm_liste_refresh_ecran[0].g_h=SCREEN_HEIGHT;

	Fcm_nb_liste_refresh_ecran=1;


	return;


}

