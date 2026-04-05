/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 12/11/2023 * */
/* ***************************** */


//#include "../fonction/coeur/coeur_define.c"

//#include "../fonction/graphique/fcm_create_surface.c"
//#include "../fonction/graphique/fcm_make_sprite_transparent.c"
//#include "../fonction/graphique/fcm_make_sprite_opaque.c"
//#include "../fonction/graphique/fcm_make_mask.c"

#include "appli_error_code.h"
#include "set_palette.c"


/* debug affiche sprite sur ecran */
#include "../fonction/graphique/fcmgfx_affiche_mfdb.c"



/* prototype */
int32 init_surface_couleur( void );




/* Fonction */
int32 init_surface_couleur( void )
{

	char       my_buffer[ (TAILLE_CHEMIN_DATA+16) ];	/* nom du fichier */
	s_tga_ldg  image_tga;


	memset( &image_tga, 0, sizeof(s_tga_ldg) );


#ifdef LOG_FILE
sprintf( buf_log, CRLF"# init_surface_couleur()"CRLF );
log_print(FALSE);
#endif

	/* pour le mode 4 bits 16 couleurs */
	if( Fcm_screen.nb_plan==4 && global_utilise_palette==TRUE )
	{
		set_palette( PALETTE_SAVE );
		set_palette( PALETTE_INSTALL );
	}


	/* ---------------------------------------------------------- */
	/* on recherche les couleurs dans la palette  pour TGA_SA.LDG */
	/* ---------------------------------------------------------- */
	{
		int16  idx;
		int16  pixel_idx;
		int16  reponse;
		int16  rgb_in[3];
		uint16 nb_couleur;

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Construction de la palette pour TGA_SA.LDG"CRLF );
log_print(FALSE);
#endif

		nb_couleur = 16;

		if( Fcm_screen.nb_plan >= 8 )
		{
			nb_couleur = 256;
		}

#ifdef LOG_FILE
sprintf( buf_log, "Palette: %d couleurs"CRLF, nb_couleur );
log_print(FALSE);
#endif

		/* on informe a la LDG le nombre de couleur dans la palette */
		image_tga.nb_col_palette = nb_couleur;


		for( idx=0; idx<nb_couleur; idx++ )
		{
			
			reponse = vq_color( vdihandle, idx, 1, rgb_in);

			/* corespondance entre index palette et valeur du pixel */
			pixel_idx = Fcm_screen.palette_to_device[idx];


			if(  reponse != (-1) )
			{
				image_tga.palette[pixel_idx].red   = (rgb_in[0] * 255) / 1000;
				image_tga.palette[pixel_idx].green = (rgb_in[1] * 255) / 1000;
				image_tga.palette[pixel_idx].blue  = (rgb_in[2] * 255) / 1000;
			}
			else
			{
				image_tga.palette[pixel_idx].red   = 999;
				image_tga.palette[pixel_idx].green = 999;
				image_tga.palette[pixel_idx].blue  = 999;
			}

#ifdef LOG_FILE
sprintf( buf_log, "%3d - rouge:%3d vert:%3d bleu:%3d"CRLF, pixel_idx, image_tga.palette[pixel_idx].red, image_tga.palette[pixel_idx].green, image_tga.palette[pixel_idx].blue );
log_print(FALSE);
#endif
		}
	}



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);





	/* --------------------------------------------------------------- */
	/* FrameBuffer                                                     */
	/* --------------------------------------------------------------- */

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation framebuffer"CRLF );
log_print(FALSE);
#endif

	surface_framebuffer.nb_plan          = FCMGFX_SCREEN_NBPLAN;
	surface_framebuffer.width            = SCREEN_WIDTH;
	surface_framebuffer.height           = SCREEN_HEIGHT;
	surface_framebuffer.handle_VDIoffscreen = SURFACE_OPEN_VDI_OFFSCREEN_BITMAP;

	if( Fcm_create_surface(&surface_framebuffer, &mfdb_framebuffer) != TRUE )
	{
		return( APPLI_ERROR_CREATE_SURFACE );
	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);







	/* ------------------------------- */
	/* -           Prairie           - */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sPRAIRIE.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_opaque(	&image_tga,
											&surface_prairie,
											&mfdb_prairie,
											my_buffer
										);
		if( reponse != 0 )
		{
			return(reponse);
		}
//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_prairie, 16, 16 );
//evnt_timer(200);
	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


	/* ------------------------------- */
	/* -          BADGERS            - */
	/* ------------------------------- */
	{
		int16 idx_badgers;
		int16 idx_form_badgers;

		for(idx_badgers=0; idx_badgers<NB_BADGERS; idx_badgers++)
		{
			if( idx_badgers!=8 && idx_badgers!=10)
			{
				for(idx_form_badgers=0; idx_form_badgers<NB_FORME_BAGERS; idx_form_badgers++)
				{
					int32 reponse;

					sprintf( my_buffer, "%sBADGR%1d%1d.TGA", chemin_data, idx_badgers, (idx_form_badgers+1) );

#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif
					reponse = Fcm_make_sprite_transparent(	&image_tga,
															&surface_badgers[idx_badgers][idx_form_badgers],
															&surface_badgers_mask[idx_badgers][idx_form_badgers],
															&mfdb_badgers[idx_badgers][idx_form_badgers],
															&mfdb_badgers_mask[idx_badgers][idx_form_badgers],
															my_buffer,
															0,
															1
														);
					if( reponse != 0 )
					{
						return(reponse);
					}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_badgers_mask[idx_badgers][idx_form_badgers], 16, 16 );
//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_badgers[idx_badgers][idx_form_badgers], 300, 16 );
//evnt_timer(200);
					Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
				}
			}
		}
	}


	/* ------------------------------- */
	/* -           MUSHROOM          - */
	/* ------------------------------- */
	{
		int16 idx_mushroom;

		for( idx_mushroom=0; idx_mushroom<NB_MUSHROOM; idx_mushroom++)
		{
			int32 reponse;

			sprintf( my_buffer, "%sMUSHROM%1d.TGA", chemin_data, (idx_mushroom+1) );

#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif
			reponse = Fcm_make_sprite_opaque(	&image_tga,
												&surface_mushroom[idx_mushroom],
												&mfdb_mushroom[idx_mushroom],
												my_buffer
											);


			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_mushroom[idx_mushroom], 16, 16 );
//evnt_timer(200);
			Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		}
	}



	/* ------------------------------- */
	/* -           ARGH              - */
	/* ------------------------------- */
	{
		int16 idx_argh;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image ARGH"CRLF );
		log_print(FALSE);
		#endif

		for( idx_argh=0; idx_argh<NB_ARGH; idx_argh++)
		{
			int32 reponse;


			sprintf( my_buffer, "%sARGH%1d.TGA", chemin_data, (idx_argh+1) );

			#ifdef LOG_FILE
			sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
			log_print(FALSE);
			#endif


			reponse = Fcm_make_sprite_opaque(	&image_tga,
												&surface_argh[idx_argh],
												&mfdb_argh[idx_argh],
												my_buffer
											);


			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_argh[idx_argh], 16, 16 );
//evnt_timer(200);

			Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		}
	}





	/* ------------------------------- */
	/* -           Desert            - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Desert"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sDESERT.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif


		reponse = Fcm_make_sprite_opaque(	&image_tga,
											&surface_desert,
											&mfdb_desert,
											my_buffer
										);


		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_desert, 16, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}

	/* ------------------------------- */
	/* -           Soleil            - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Soleil"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sSOLEIL.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif


		reponse = Fcm_make_sprite_opaque(	&image_tga,
											&surface_soleil,
											&mfdb_soleil,
											my_buffer
										);


		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_soleil, 16, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}



	/* ------------------------------- */
	/* -           Nuage             - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Nuage"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sNUAGE.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif


		reponse = Fcm_make_sprite_opaque(	&image_tga,
											&surface_nuage,
											&mfdb_nuage,
											my_buffer
										);


		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_nuage, 16, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}




	/* ------------------------------- */
	/* -          Horizon1           - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Horizon1"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sHORIZON1.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif


		reponse = Fcm_make_sprite_opaque(	&image_tga,
											&surface_horizon1,
											&mfdb_horizon1,
											my_buffer
										);


		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_horizon1, 16, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}



	/* ------------------------------- */
	/* -          Horizon2           - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Horizon2"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sHORIZON2.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif


		reponse = Fcm_make_sprite_transparent(	&image_tga,
												&surface_horizon2,
												&surface_horizon2_mask,
												&mfdb_horizon2,
												&mfdb_horizon2_mask,
												my_buffer,
												0,
												1
											);



		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_horizon2, 16, 16 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_horizon2_mask, 300, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}



	/* ------------------------------- */
	/* -           Cactus            - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Cactus"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sCACTUS.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif


		reponse = Fcm_make_sprite_transparent(	&image_tga,
												&surface_cactus,
												&surface_cactus_mask,
												&mfdb_cactus,
												&mfdb_cactus_mask,
												my_buffer,
												0,
												1
											);



		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_cactus, 16, 16 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_cactus_mask, 300, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}







	/* ------------------------------- */
	/* -           Herbe1            - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Herbe1"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sHERBE1.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif



		reponse = Fcm_make_sprite_transparent(	&image_tga,
												&surface_herbe1,
												&surface_herbe1_mask,
												&mfdb_herbe1,
												&mfdb_herbe1_mask,
												my_buffer,
												0,
												1
											);



		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_herbe1, 16, 16 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_herbe1_mask, 300, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}







	/* ------------------------------- */
	/* -           Herbe2            - */
	/* ------------------------------- */
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image Herbe2"CRLF );
		log_print(FALSE);
		#endif



		sprintf( my_buffer, "%sHERBE2.TGA", chemin_data );

		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif


		reponse = Fcm_make_sprite_transparent(	&image_tga,
												&surface_herbe2,
												&surface_herbe2_mask,
												&mfdb_herbe2,
												&mfdb_herbe2_mask,
												my_buffer,
												0,
												1
											);



		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_herbe2, 16, 16 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_herbe2_mask, 300, 16 );
//evnt_timer(200);

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}





	/* ------------------------------- */
	/* -           SNAKE             - */
	/* ------------------------------- */
	{
		int16 idx_snake;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image SNAKE"CRLF );
		log_print(FALSE);
		#endif

		for( idx_snake=0; idx_snake<NB_SNAKE; idx_snake++)
		{
			int32 reponse;


			sprintf( my_buffer, "%sSNAKE%1d.TGA", chemin_data, (idx_snake+1) );

			#ifdef LOG_FILE
			sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
			log_print(FALSE);
			#endif


			reponse = Fcm_make_sprite_transparent(	&image_tga,
													&surface_snake[idx_snake],
													&surface_snake_mask[idx_snake],
													&mfdb_snake[idx_snake],
													&mfdb_snake_mask[idx_snake],
													my_buffer,
													0,
													1
												);


			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_snake[idx_snake], 16, 16 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_snake_mask[idx_snake], 300, 16 );
//evnt_timer(200);

			Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		}
	}









	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);





	return 0L;


}

