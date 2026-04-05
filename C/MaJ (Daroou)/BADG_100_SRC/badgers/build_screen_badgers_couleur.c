/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 04/01/2024 * */
/* ***************************** */


#include "../fonction/graphique/fcm_make_liste_redraw_transparent.c"
#include "../fonction/graphique/fcm_make_liste_redraw_opaque.c"

void build_screen_badgers_couleur( void );





void build_screen_badgers_couleur( void )
{

	static int16 nb_badgers_view=1;



	/* on repart de z‚ro */
	Fcm_nb_liste_restaure_fond=0;


	/* -------------------------------- */
	/* R‚-initialisation de l'animation */
	/* -------------------------------- */
	if( build_screen_restart==TRUE )
	{
		build_screen_restart=FALSE;


		/* On copie l'image de fond dans l'‚cran offscreen */
		vro_cpyfm(global_vdihandle_framebuffer,3,pxy_screen, &mfdb_prairie, &mfdb_framebuffer );


		/* On r‚-affiche tout l'‚cran */
		Fcm_liste_refresh_ecran[0].g_x = 0;
		Fcm_liste_refresh_ecran[0].g_y = 0;
		Fcm_liste_refresh_ecran[0].g_w = SCREEN_WIDTH;
		Fcm_liste_refresh_ecran[0].g_h = SCREEN_HEIGHT;
		Fcm_nb_liste_refresh_ecran=1;


		/* ------------------------------------------------ */
		/* On r‚-initialise tous les paramŠtres des sprites */
		/* ------------------------------------------------ */
		nb_badgers_view=1;

		/* index sprite de depart pour chaque badger */
		index_badgers[0]=0;
		index_badgers[1]=0;
		index_badgers[2]=0;
		index_badgers[3]=9;
		index_badgers[4]=9;
		index_badgers[5]=9;
		index_badgers[6]=8;
		index_badgers[7]=8;
		index_badgers[8]=8;
		index_badgers[9]=7;
		index_badgers[10]=7;
		index_badgers[11]=7;

		return;
	}



	/* ******************************************************************** */
	/* restauration du (des) fond(s)                                        */
	/* ******************************************************************** */
	{
		static int16 pxy_fond_badgers[8]={0,0,0,0,0,0,0,0};


		if( nb_badgers_view < 3 )
		{
			int16 idx_badgers;


			for( idx_badgers=(nb_badgers_view-1); idx_badgers >= 0; idx_badgers-- )
			{

				pxy_fond_badgers[0] = pxy_badgers[idx_badgers][4];
				pxy_fond_badgers[1] = pxy_badgers[idx_badgers][5];
				pxy_fond_badgers[2] = pxy_badgers[idx_badgers][6];
				pxy_fond_badgers[3] = pxy_badgers[idx_badgers][7];

				pxy_fond_badgers[4] = pxy_fond_badgers[0];
				pxy_fond_badgers[5] = pxy_fond_badgers[1];
				pxy_fond_badgers[6] = pxy_fond_badgers[2];
				pxy_fond_badgers[7] = pxy_fond_badgers[3];

				vro_cpyfm(global_vdihandle_framebuffer,3,pxy_fond_badgers, &mfdb_prairie, &mfdb_framebuffer );

				Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_x = pxy_badgers[idx_badgers][4];
				Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_y = pxy_badgers[idx_badgers][5];
				Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_w = pxy_badgers[idx_badgers][6] - pxy_badgers[idx_badgers][4] + 1;
				Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_h = pxy_badgers[idx_badgers][7] - pxy_badgers[idx_badgers][5] + 1;
				Fcm_nb_liste_refresh_ecran++;
			}
		}
		else
		{

			if( nb_badgers_view == 3 )
			{
				pxy_fond_badgers[0] = 0;
				pxy_fond_badgers[1] = SCREEN_HEIGHT - 1;
				pxy_fond_badgers[2] = SCREEN_WIDTH  - 1;
				pxy_fond_badgers[3] = SCREEN_HEIGHT - 1;
				pxy_fond_badgers[4] = 0;
				pxy_fond_badgers[6] = SCREEN_WIDTH  - 1;
				pxy_fond_badgers[7] = SCREEN_HEIGHT - 1;
			}

			pxy_fond_badgers[1] = MIN( pxy_fond_badgers[1], pxy_badgers[nb_badgers_view-1][5] );
			pxy_fond_badgers[5] = pxy_fond_badgers[1];


			vro_cpyfm(global_vdihandle_framebuffer,3,pxy_fond_badgers, &mfdb_prairie, &mfdb_framebuffer );

			Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_x = 0;
			Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_y = pxy_fond_badgers[5];
			Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_w = SCREEN_WIDTH;
			Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran].g_h = SCREEN_HEIGHT - pxy_fond_badgers[5];
			Fcm_nb_liste_refresh_ecran++;
		}
	}



	/* ******************************************************************** */
	/* affichage des badgers                                                */
	/* ******************************************************************** */
	{
		int16 idx_badgers;


		for( idx_badgers=(nb_badgers_view-1); idx_badgers>=0; idx_badgers--)
		{
			int16 id_sprite_badger;


			/* calcul sprite */
			id_sprite_badger=badgers_animation[ index_badgers[idx_badgers] ];


			/* affichage sprite */
			switch( idx_badgers )
			{
				/* sprite 8 et 7 identique */
				case 8:
					vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_badgers[idx_badgers], &mfdb_badgers_mask[7][id_sprite_badger], &mfdb_framebuffer, couleur_mask_vrt );
					vro_cpyfm(global_vdihandle_framebuffer,7,pxy_badgers[idx_badgers], &mfdb_badgers[7][id_sprite_badger], &mfdb_framebuffer );
					break;

				/* sprite 10 et 9 identique */
				case 10:
					vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_badgers[idx_badgers], &mfdb_badgers_mask[9][id_sprite_badger], &mfdb_framebuffer, couleur_mask_vrt );
					vro_cpyfm(global_vdihandle_framebuffer,7,pxy_badgers[idx_badgers], &mfdb_badgers[9][id_sprite_badger], &mfdb_framebuffer );
					break;

				default:
					vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_badgers[idx_badgers], &mfdb_badgers_mask[idx_badgers][id_sprite_badger], &mfdb_framebuffer, couleur_mask_vrt );
					vro_cpyfm(global_vdihandle_framebuffer,7,pxy_badgers[idx_badgers], &mfdb_badgers[idx_badgers][id_sprite_badger], &mfdb_framebuffer );
					break;
			}


			index_badgers[idx_badgers]++;


			if( index_badgers[0] == NB_BADGERS_ANIMATION )
			{
				nb_badgers_view++;

				/* si son coupé, plus de synchro avec la musique, l'animation progresse toute seule */
				if( global_mute_sound==TRUE && nb_badgers_view > NB_BADGERS )
				{
					/* tous les badgers sont affichés, on peut passer a l'animation suivante */
					index_sequence_animation++;
				}

				nb_badgers_view = MIN( nb_badgers_view, NB_BADGERS );
			}


			if( index_badgers[idx_badgers] == NB_BADGERS_ANIMATION )
			{
				index_badgers[idx_badgers]=0;
			}

		}
	}


	return;


}

