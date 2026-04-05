/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 11/11/2023 * */
/* ***************************** */



//#include "../fonction/coeur/coeur_define.c"

#include "../fonction/graphique/Fcm_create_surface.c"
#include "../fonction/graphique/Fcm_make_sprite_transparent_mono.c"
#include "../fonction/graphique/Fcm_make_sprite_opaque_mono.c"
#include "../fonction/graphique/Fcm_make_mask.c"

#include "appli_error_code.h"




/* debug affiche sprite sur ecran */
//#include "../fonction/graphique/Fcmgfx_affiche_mfdb.c"



/* prototype */
int32 init_surface_mono( void );




/* Fonction */
int32 init_surface_mono( void )
{
	char       my_buffer[ (TAILLE_CHEMIN_DATA+16) ];	/* nom du fichier */
	s_tga_ldg  image_tga;


	/* init à 0 de la structure */
	memset( &image_tga, 0, sizeof(s_tga_ldg) );



#ifdef LOG_FILE
sprintf( buf_log, CRLF"# init_surface_mono()"CRLF );
log_print(FALSE);
#endif




#ifdef LOG_FILE
sprintf( buf_log, CRLF" Construction de la palette pour TGA_SA.LDG"CRLF );
log_print(FALSE);
#endif

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

#ifdef LOG_FILE
sprintf( buf_log, "Palette: 16 couleurs"CRLF);
log_print(FALSE);
#endif


	/* on informe a la LDG le nombre de couleur dans la palette */
	image_tga.nb_col_palette = 16;

	/* --------------------------------------------------- */
	/* on definit une pallette pour le decodage des images */
	/* la palette sert juste a differencier la couleur de  */
	/* transparence, les sprites etant en mono             */
	/* --------------------------------------------------- */
	{
		image_tga.palette[0].red   = 255;
		image_tga.palette[0].green = 255;
		image_tga.palette[0].blue  = 255;

		image_tga.palette[1].red   = 0;
		image_tga.palette[1].green = 0;
		image_tga.palette[1].blue  = 0;

		image_tga.palette[2].red   = 255;
		image_tga.palette[2].green = 0;
		image_tga.palette[2].blue  = 0;

		image_tga.palette[3].red   = 0;
		image_tga.palette[3].green = 255;
		image_tga.palette[3].blue  = 0;

		image_tga.palette[4].red   = 0;
		image_tga.palette[4].green = 0;
		image_tga.palette[4].blue  = 255;

		image_tga.palette[5].red   = 255;
		image_tga.palette[5].green = 255;
		image_tga.palette[5].blue  = 0;

		image_tga.palette[6].red   = 0;
		image_tga.palette[6].green = 255;
		image_tga.palette[6].blue  = 255;

		image_tga.palette[7].red   = 255;
		image_tga.palette[7].green = 0;
		image_tga.palette[7].blue  = 255;

		image_tga.palette[8].red   = 127;
		image_tga.palette[8].green = 127;
		image_tga.palette[8].blue  = 127;

		image_tga.palette[9].red   = 127;
		image_tga.palette[9].green = 0;
		image_tga.palette[9].blue  = 0;

		image_tga.palette[10].red   = 0;
		image_tga.palette[10].green = 127;
		image_tga.palette[10].blue  = 0;

		image_tga.palette[11].red   = 0;
		image_tga.palette[11].green = 0;
		image_tga.palette[11].blue  = 127;

		image_tga.palette[12].red   = 127;
		image_tga.palette[12].green = 127;
		image_tga.palette[12].blue  = 0;

		image_tga.palette[13].red   = 127;
		image_tga.palette[13].green = 0;
		image_tga.palette[13].blue  = 127;

		image_tga.palette[14].red   = 0;
		image_tga.palette[14].green = 127;
		image_tga.palette[14].blue  = 127;

		image_tga.palette[15].red   = 64;
		image_tga.palette[15].green = 64;
		image_tga.palette[15].blue  = 64;
	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);







	/* --------------------------------------------------------------- */
	/* FrameBuffer                                                     */
	/* --------------------------------------------------------------- */

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation FrameBuffer"CRLF );
log_print(FALSE);
#endif

	surface_framebuffer.nb_plan          = FCMGFX_SCREEN_NBPLAN;  /* nombre de plan de l'écran */
	surface_framebuffer.width            = SCREEN_WIDTH;
	surface_framebuffer.height           = SCREEN_HEIGHT;
	surface_framebuffer.handle_VDIoffscreen = SURFACE_OPEN_VDI_OFFSCREEN_BITMAP;

	if( Fcm_create_surface(&surface_framebuffer, &mfdb_framebuffer) != TRUE )
	{
		return( APPLI_ERROR_CREATE_SURFACE );
	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);








	/* ------------------------------- */
	/* Image de fond                   */
	/* ------------------------------- */
	{
		int32 reponse;

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image de fond"CRLF );
log_print(FALSE);
#endif

		sprintf( my_buffer, "%sMONO\\nyanc_fd.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image nyanc_fd.TGA"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_opaque_mono	(	&image_tga,
													&surface_fond_ecran,
													&mfdb_fond_ecran,
													my_buffer
												);

		if( reponse != 0 )
		{
			return(reponse);
		}


//Fcmgfx_affiche_mfdb_sprite_opaque_mono( &mfdb_fond_ecran, 0, 0 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);









	/* --------------------------------- */
	/* NyanCat                           */
	/* --------------------------------- */
	{
		int16 index_sprite;

		for( index_sprite=0; index_sprite<NB_NYANCAT; index_sprite++)
		{
			int32 reponse;

			sprintf( my_buffer, "%sMONO\\nyancat%1d.tga", chemin_data, (index_sprite+1) );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image NyanCat:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

			reponse = Fcm_make_sprite_transparent_mono	(	&image_tga,
															&surface_nyancat_sprite[index_sprite],
															&surface_nyancat_mask[index_sprite],
															&mfdb_nyancat_sprite[index_sprite],
															&mfdb_nyancat_mask[index_sprite],
															my_buffer,
															0,
															1
														);

			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_nyancat_mask[index_sprite], (0+index_sprite*mfdb_nyancat_sprite[index_sprite].fd_w), 200 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_nyancat_sprite[index_sprite], (0+index_sprite*mfdb_nyancat_sprite[index_sprite].fd_w), 300 );

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_nyancat_mask[index_sprite], (0+index_sprite*mfdb_nyancat_sprite[index_sprite].fd_w), 400 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_nyancat_sprite[index_sprite], (0+index_sprite*mfdb_nyancat_sprite[index_sprite].fd_w), 400 );

		}
	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);









	/* ------------------------------- */
	/* Arc en ciel UP                  */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\arc_up.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_transparent_mono	(	&image_tga,
														&surface_arcenciel[ARCENCIEL_UP],
														&surface_arcenciel_mask[ARCENCIEL_UP],
														&mfdb_arcenciel[ARCENCIEL_UP],
														&mfdb_arcenciel_mask[ARCENCIEL_UP],
														my_buffer,
														0,
														0
													);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_arcenciel_mask[ARCENCIEL_UP], 0, 500 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_arcenciel[ARCENCIEL_UP], 200, 500 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);









	/* ------------------------------- */
	/* Arc en ciel Down                */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\arc_down.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_transparent_mono	(	&image_tga,
														&surface_arcenciel[ARCENCIEL_DOWN],
														&surface_arcenciel_mask[ARCENCIEL_DOWN],
														&mfdb_arcenciel[ARCENCIEL_DOWN],
														&mfdb_arcenciel_mask[ARCENCIEL_DOWN],
														my_buffer,
														20,
														0
													);


		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_arcenciel_mask[ARCENCIEL_DOWN], 0, 600 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_arcenciel[ARCENCIEL_DOWN], 200, 600 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);









	/* ------------------------------- */
	/* Fonte                           */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\nyan_fnt.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_transparent_mono	(	&image_tga,
														&surface_font,
														&surface_mask_font,
														&mfdb_font,
														&mfdb_mask_font,
														my_buffer,
														0,
														0
													);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_mask_font, 0, 700 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_font, 200, 700 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);










	/* ------------------------------- */
	/* etoiles                         */
	/* ------------------------------- */
	{
		int16 index_etoile;
		int32 reponse;

		for( index_etoile=0; index_etoile<NB_STAR; index_etoile++ )
		{
			sprintf( my_buffer, "%sMONO\\star%02d.tga", chemin_data, (index_etoile+1) );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

			reponse = Fcm_make_mask(	&image_tga,
										&surface_star_mask[index_etoile],
										&mfdb_star_mask[index_etoile],
										my_buffer,
										0,
										0
									);

			if( reponse != 0 )
			{
				#ifdef LOG_FILE
				sprintf( buf_log, CRLF" reponse=%ld"CRLF, reponse );
				log_print(FALSE);
				#endif
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_star_mask[index_etoile], 16, 740 );

		}
	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


	return 0L;


}

