/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 13/11/2023 * */
/* ***************************** */



#include "../fonction/graphique/fcm_make_liste_redraw_transparent.c"
#include "../fonction/graphique/fcm_make_liste_redraw_opaque.c"




/* prototype */
void build_screen_snake_mono( void );




/* Fonction */
void build_screen_snake_mono( void )
{
	static int16 view_soleil=TRUE;
	static int16 view_horizon1=TRUE;
	static int16 view_horizon2=TRUE;
	static int16 idx_sprite_snake=0;
	static int16 bascule2=0;
	static int16 bascule4=0;
	static int16 bascule5=0;





	/* ----------------------------------------- */
	/* pour les mouvements 1 frame sur x         */
	/* ----------------------------------------- */
	bascule2++;
	bascule4++;
	bascule5++;




	/* on repart de z‚ro */
	Fcm_nb_liste_restaure_fond=0;



	/* -------------------------------- */
	/* R‚-initialisation de l'animation */
	/* -------------------------------- */
	if( build_screen_restart==TRUE )
	{
		build_screen_restart=FALSE;


		/* On copie l'image de fond dans l'‚cran offscreen */
//		vro_cpyfm(global_vdihandle_framebuffer,3,pxy_screen, &mfdb_desert, &mfdb_framebuffer );
		vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy_screen, &mfdb_desert, &mfdb_framebuffer, couleur_vrt_copy );

		/* On r‚-affiche tout l'‚cran */
		Fcm_liste_refresh_ecran[0].g_x = 0;
		Fcm_liste_refresh_ecran[0].g_y = 0;
		Fcm_liste_refresh_ecran[0].g_w = SCREEN_WIDTH;
		Fcm_liste_refresh_ecran[0].g_h = SCREEN_HEIGHT;
		Fcm_nb_liste_refresh_ecran=1;


		/* On r‚-initialise tous les paramŠtres des sprites */

		bascule2=0;
		bascule4=0;
		bascule5=0;

		soleil_xywh.g_y     = SOLEIL_Y;
		soleil_xywh_old.g_y = SOLEIL_Y;
		view_soleil=TRUE;


		nuage_xywh.g_x     = NUAGE_X;
		nuage_xywh_old.g_x = NUAGE_X;
		nuage_xywh.g_y     = NUAGE_Y;
		nuage_xywh_old.g_y = NUAGE_Y;


		horizon1_xywh.g_y     = HORIZON1_Y;
		horizon1_xywh_old.g_y = HORIZON1_Y;
		view_horizon1=TRUE;


		horizon2_xywh.g_y     = HORIZON2_Y;
		horizon2_xywh_old.g_y = HORIZON2_Y;
		view_horizon2=TRUE;


		cactus_xywh.g_x     = CACTUS_X;
		cactus_xywh_old.g_x = CACTUS_X;
		cactus_xywh.g_y     = CACTUS_Y;
		cactus_xywh_old.g_y = CACTUS_Y;


		herbe1_xywh.g_x     = HERBE1_X;
		herbe1_xywh_old.g_x = HERBE1_X;
		herbe1_xywh.g_y     = HERBE1_Y;
		herbe1_xywh_old.g_y = HERBE1_Y;


		herbe2_xywh.g_x     = HERBE2_X;
		herbe2_xywh_old.g_x = HERBE2_X;
		herbe2_xywh.g_y     = HERBE2_Y;
		herbe2_xywh_old.g_y = HERBE2_Y;


		snake_xywh.g_x     = SNAKE_X;
		snake_xywh_old.g_x = SNAKE_X;
		snake_xywh.g_y     = SNAKE_Y;
		snake_xywh_old.g_y = SNAKE_Y;
		idx_sprite_snake=0;


		return;
	}







	/* **************************************************** */
	/*                                                      */
	/* Etape 1 : on calcul la nouvelle position des sprites */
	/*                                                      */
	/* **************************************************** */



	/* ==================================================== */
	/* Sprite Soleil                                        */
	/* ==================================================== */
	if(view_soleil)
	{
		soleil_xywh.g_y--;

		if( soleil_xywh.g_y == -10 )
		{
			view_soleil=FALSE;
		}
	}



	/* ==================================================== */
	/* Sprite Nuage                                         */
	/* ==================================================== */
	{
		nuage_xywh.g_y--;

		nuage_xywh.g_y = MAX( 35, nuage_xywh.g_y);

		if( bascule4==4 && nuage_xywh.g_y == 35 )
		{
			nuage_xywh.g_x--;
			nuage_xywh.g_x = MAX( (SCREEN_WIDTH-NUAGE_W), nuage_xywh.g_x);
		}
	}



	/* ==================================================== */
	/* Sprite Horizon1                                      */
	/* ==================================================== */
	if(view_horizon1)
	{
		if( bascule2==2 )
		{
			horizon1_xywh.g_y--;
		}

		if( horizon1_xywh.g_y == (HORIZON1_Y-14) )
		{
			view_horizon1=FALSE;
		}
	}



	/* ==================================================== */
	/* Sprite Horizon2                                      */
	/* ==================================================== */
	if(view_horizon2)
	{
		if( bascule2==2 )
		{
			horizon2_xywh.g_y++;
		}

		if( horizon2_xywh.g_y == (HORIZON2_Y+14) )
		{
			view_horizon2=FALSE;
		}
	}



	/* ==================================================== */
	/* Sprite Cactus                                        */
	/* ==================================================== */
	{
		if( bascule2==2 )
		{
			cactus_xywh.g_y++;
		}

		cactus_xywh.g_y = MIN( (CACTUS_Y+14), cactus_xywh.g_y);

		if( bascule5==5 && cactus_xywh.g_y==(CACTUS_Y+14) )
		{
			cactus_xywh.g_x--;
		}

	}




	/* ==================================================== */
	/* Sprite Snake                                         */
	/* ==================================================== */
	{
		static int16 sens=1;
		static int16 bascule=0;


		if( bascule2==2)
		{
			idx_sprite_snake += sens;

			if( idx_sprite_snake==NB_SNAKE )
			{
				if( bascule==1)
				{
					bascule=0;
					idx_sprite_snake -= 2;
					sens=-1;
				}
				else
				{
					idx_sprite_snake = NB_SNAKE-1;
					bascule++;
				}
			}
			if( idx_sprite_snake<0 )
			{
				idx_sprite_snake=1;
				sens=1;
			}
		}

		snake_xywh.g_y++;
		snake_xywh.g_y = MIN( (SNAKE_Y+28), snake_xywh.g_y);

		snake_xywh.g_x += 4;
	}



	/* ==================================================== */
	/* Sprite Herbe1                                        */
	/* ==================================================== */
	{
		herbe1_xywh.g_y += 2;

		herbe1_xywh.g_y = MIN( (SCREEN_HEIGHT-HERBE1_H+56), herbe1_xywh.g_y);

		if( bascule4==4 && herbe1_xywh.g_y==(SCREEN_HEIGHT-HERBE1_H+56) )
		{
			herbe1_xywh.g_x--;
		}

	}



	/* ==================================================== */
	/* Sprite Herbe2                                        */
	/* ==================================================== */
	{
		herbe2_xywh.g_y += 2;

		herbe2_xywh.g_y = MIN( (SCREEN_HEIGHT-HERBE2_H+56), herbe2_xywh.g_y);

		if( bascule4==4 && herbe2_xywh.g_y==(SCREEN_HEIGHT-HERBE2_H+56) )
		{
			herbe2_xywh.g_x--;
		}
	}







	/* ************************************************************* */
	/*                                                               */
	/* Etape 2 : Construction de la liste de restauration des fonds, */
	/*           les coordonn‚es d'affichage des sprites, la liste   */
	/*           des redraws des zones modifi‚es de l'‚cran          */
	/*                                                               */
	/* ************************************************************* */
	{

		if(view_soleil)
		{
			Fcm_make_liste_redraw_opaque( &soleil_xywh, &soleil_xywh_old, pxy_soleil );
			* (&soleil_xywh_old) = * (&soleil_xywh);
		}


		Fcm_make_liste_redraw_opaque( &nuage_xywh, &nuage_xywh_old, pxy_nuage );
		* (&nuage_xywh_old) = * (&nuage_xywh);


		if(view_horizon1)
		{
			Fcm_make_liste_redraw_opaque( &horizon1_xywh, &horizon1_xywh_old, pxy_horizon1 );
			* (&horizon1_xywh_old) = * (&horizon1_xywh);
		}


		if(view_horizon2)
		{
			Fcm_make_liste_redraw_transparent( &horizon2_xywh, &horizon2_xywh_old, pxy_horizon2 );
			* (&horizon2_xywh_old) = * (&horizon2_xywh);
		}


		Fcm_make_liste_redraw_transparent( &cactus_xywh, &cactus_xywh_old, pxy_cactus );
		* (&cactus_xywh_old) = * (&cactus_xywh);


		Fcm_make_liste_redraw_transparent( &snake_xywh, &snake_xywh_old, pxy_snake );
		* (&snake_xywh_old) = * (&snake_xywh);


		Fcm_make_liste_redraw_transparent( &herbe1_xywh, &herbe1_xywh_old, pxy_herbe1 );
		* (&herbe1_xywh_old) = * (&herbe1_xywh);


		Fcm_make_liste_redraw_transparent( &herbe2_xywh, &herbe2_xywh_old, pxy_herbe2 );
		* (&herbe2_xywh_old) = * (&herbe2_xywh);


	}



	/* **************************************************** */
	/*                                                      */
	/* Etape 3 : Restauration des fonds qui ont ‚t‚ alt‚r‚s */
	/*                                                      */
	/* **************************************************** */
	{
		int16 myindex;
		//int16 pxy[8];



		for(myindex=0; myindex<Fcm_nb_liste_restaure_fond; myindex++)
		{

			pxy[0] = Fcm_liste_restaure_fond[myindex].g_x;
			pxy[1] = Fcm_liste_restaure_fond[myindex].g_y;
			pxy[2] = pxy[0] + Fcm_liste_restaure_fond[myindex].g_w - 1;
			pxy[3] = pxy[1] + Fcm_liste_restaure_fond[myindex].g_h - 1;

			pxy[4] = pxy[0];
			pxy[5] = pxy[1];
			pxy[6] = pxy[2];
			pxy[7] = pxy[3];

//			vro_cpyfm(global_vdihandle_framebuffer,3,pxy, &mfdb_desert, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy, &mfdb_desert, &mfdb_framebuffer, couleur_vrt_copy );
		}

	}





	/* **************************************************** */
	/*                                                      */
	/* Etape 4 : Affiche des Sprites                        */
	/*                                                      */
	/* **************************************************** */


	/* ---------------------------------------------- */
	/* pxy_?????[0]==-1 si le sprite est hors ‚cran,  */
	/* et doit donc ne plus etre affich‚.             */
	/* ---------------------------------------------- */


	/* ------------------------------------------ */
	/* Affichage Soleil                           */
	/* ------------------------------------------ */
	if(view_soleil)
	{
/*		if( pxy_soleil[0] != -1 ) */   /* ne sort jamais de l'ecran */
		{
//			vro_cpyfm(global_vdihandle_framebuffer,3,pxy_soleil, &mfdb_soleil, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy_soleil, &mfdb_soleil, &mfdb_framebuffer, couleur_vrt_copy );
		}
	}


	/* ------------------------------------------ */
	/* Affichage Nuage                            */
	/* ------------------------------------------ */
	{ 
/*		if( pxy_nuage[0] != -1 ) */   /* ne sort jamais de l'ecran */
		{
//			vro_cpyfm(global_vdihandle_framebuffer,3,pxy_nuage, &mfdb_nuage, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy_nuage, &mfdb_nuage, &mfdb_framebuffer, couleur_vrt_copy );
		}
	}


	/* ------------------------------------------ */
	/* Affichage Horizon1                         */
	/* ------------------------------------------ */
	if(view_horizon1)
	{
/*		if( pxy_horizon1[0] != -1 ) */   /* ne sort jamais de l'ecran */
		{
//			vro_cpyfm(global_vdihandle_framebuffer,3,pxy_horizon1, &mfdb_horizon1, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer, VRT_COPY_MODE, pxy_horizon1, &mfdb_horizon1, &mfdb_framebuffer, couleur_vrt_copy );
		}
	}


	/* ------------------------------------------ */
	/* Affichage Horizon2                         */
	/* ------------------------------------------ */
	if(view_horizon2)
	{
/*		if( pxy_horizon2[0] != -1 )*/   /* ne sort jamais de l'ecran */
		{
//			vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_horizon2, &mfdb_horizon2_mask, &mfdb_framebuffer, couleur_mask_vrt );
//			vro_cpyfm(global_vdihandle_framebuffer,7,pxy_horizon2, &mfdb_horizon2, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_horizon2, &mfdb_horizon2_mask, &mfdb_framebuffer, couleur_mask_vrt );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_horizon2, &mfdb_horizon2, &mfdb_framebuffer, couleur_mask_vrt );

		}
	}


	/* ------------------------------------------ */
	/* Affichage Cactus                           */
	/* ------------------------------------------ */
	{
		if( pxy_cactus[0] != -1 )
		{
//			vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_cactus, &mfdb_cactus_mask, &mfdb_framebuffer, couleur_mask_vrt );
//			vro_cpyfm(global_vdihandle_framebuffer,7,pxy_cactus, &mfdb_cactus, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_cactus, &mfdb_cactus_mask, &mfdb_framebuffer, couleur_mask_vrt );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_cactus, &mfdb_cactus, &mfdb_framebuffer, couleur_mask_vrt );

		}
	}


	/* ------------------------------------------ */
	/* Affichage Snake                            */
	/* ------------------------------------------ */
	{
		if( pxy_snake[0] != -1 ) 
		{
//			vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_snake, &mfdb_snake_mask[idx_sprite_snake], &mfdb_framebuffer, couleur_mask_vrt );
//			vro_cpyfm(global_vdihandle_framebuffer,7,pxy_snake, &mfdb_snake[idx_sprite_snake], &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_snake, &mfdb_snake_mask[idx_sprite_snake], &mfdb_framebuffer, couleur_mask_vrt );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_snake, &mfdb_snake[idx_sprite_snake], &mfdb_framebuffer, couleur_mask_vrt );

		}
		else
		{
			/* si son coupé, plus de synchro avec la musique, l'animation progresse toute seule */
			if( global_mute_sound==TRUE )
			{
				/* Le serpent est sorti de l'écran, on passe à l'animation suivante */
				index_sequence_animation=0; /* le serpent est la derniere animation, on recommence */
			}
		}
	}


	/* ------------------------------------------ */
	/* Affichage Herbe1                           */
	/* ------------------------------------------ */
	{
		if( pxy_herbe1[0] != -1 ) 
		{
//			vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_herbe1, &mfdb_herbe1_mask, &mfdb_framebuffer, couleur_mask_vrt );
//			vro_cpyfm(global_vdihandle_framebuffer,7,pxy_herbe1, &mfdb_herbe1, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_herbe1, &mfdb_herbe1_mask, &mfdb_framebuffer, couleur_mask_vrt );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_herbe1, &mfdb_herbe1, &mfdb_framebuffer, couleur_mask_vrt );

		}
	}


	/* ------------------------------------------ */
	/* Affichage Herbe2                           */
	/* ------------------------------------------ */
	{
		if( pxy_herbe2[0] != -1 )
		{
//			vrt_cpyfm(global_vdihandle_framebuffer,2,pxy_herbe2, &mfdb_herbe2_mask, &mfdb_framebuffer, couleur_mask_vrt );
//			vro_cpyfm(global_vdihandle_framebuffer,7,pxy_herbe2, &mfdb_herbe2, &mfdb_framebuffer );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_herbe2, &mfdb_herbe2_mask, &mfdb_framebuffer, couleur_mask_vrt );
			vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_herbe2, &mfdb_herbe2, &mfdb_framebuffer, couleur_mask_vrt );

		}
	}






	/* ----------------------------------------- */
	/* pour les mouvements 1 frame sur 2 / sur 4 */
	/* ----------------------------------------- */
	if( bascule2==2 )
	{
		bascule2=0;
	}

	if( bascule4==4 )
	{
		bascule4=0;
	}

	if( bascule5==6 )
	{
		bascule5=0;
	}


	return;


}

