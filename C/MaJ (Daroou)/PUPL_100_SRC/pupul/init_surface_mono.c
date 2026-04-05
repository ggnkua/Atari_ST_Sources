/* **[Pupul]******************** */
/* *                           * */
/* * 09/11/2023 MaJ 09/11/2023 * */
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

	char   my_buffer[ (TAILLE_CHEMIN_DATA+16) ];	/* nom du fichier */
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
	/* Image de fond                   */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\fond.tga", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image fond.tga"CRLF"chemin=%s"CRLF, my_buffer );
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
	/* Demons                            */
	/* --------------------------------- */
	{
		int16 index_sprite;

		for( index_sprite=0; index_sprite<NB_SPRITE_DEMONS; index_sprite++)
		{
			int32 reponse;

			sprintf( my_buffer, "%sMONO\\demon_0%1d.tga", chemin_data, (index_sprite+1) );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image demons:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

			reponse = Fcm_make_sprite_transparent_mono(	&image_tga,
														&surface_demons_sprite[index_sprite],
														&surface_demons_mask[index_sprite],
														&mfdb_demons_sprite[index_sprite],
														&mfdb_demons_mask[index_sprite],
														my_buffer,
														0,
														0
													);

			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_demons_mask[index_sprite], (0+index_sprite*40), 200 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_demons_sprite[index_sprite], (0+index_sprite*40), 224 );

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_demons_mask[index_sprite], (0+index_sprite*40), 250 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_demons_sprite[index_sprite], (0+index_sprite*40), 250 );

		}
	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);





	/* ------------------------------- */
	/* Equinox logo                    */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\equinox.tga", chemin_data );

		reponse = Fcm_make_mask(	&image_tga,
									&surface_logo_equinox_mask,
									&mfdb_logo_equinox_mask,
									my_buffer,
									0,
									0
								);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_logo_equinox_mask, 160, 260 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);







	/* ------------------------------- */
	/* -      Renaissance logo       - */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\renaissa.tga", chemin_data );

		reponse = Fcm_make_mask(	&image_tga,
									&surface_logo_renaissance_mask,
									&mfdb_logo_renaissance_mask,
									my_buffer,
									0,
									0
								);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_logo_renaissance_mask, 0, 260 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);






	/* ------------------------------- */
	/* -            Fonte            - */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\pupulfnt.tga", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_transparent_mono(	&image_tga,
													&surface_fonte_texte,
													&surface_fonte_texte_mask,
													&mfdb_fonte_texte,
													&mfdb_fonte_texte_mask,
													my_buffer,
													0,
													0
												);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_fonte_texte_mask, 0, 400 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_fonte_texte, 0, 430 );

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_fonte_texte_mask, 0, 460 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_fonte_texte, 0, 460 );

		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}





	/* ------------------------------- */
	/* -      Fond scrolltext        - */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\fondtext.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_opaque_mono(	&image_tga,
												&surface_fond_scrolltext,
												&mfdb_fond_scrolltext,
												my_buffer
											);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque_mono( &mfdb_fond_scrolltext, 0, 460 );


		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}





	/* --------------------------------- */
	/* -      Barre scrolltext         - */
	/* --------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sMONO\\bar_red.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_opaque_mono(	&image_tga,
												&surface_barre_scrolltext,
												&mfdb_barre_scrolltext,
												my_buffer
											);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque_mono( &mfdb_barre_scrolltext, 0, 500 );


		Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);
	}






	/* --------------------------------- */
	/*      Damier                       */
	/* --------------------------------- */
	{
		int16 damier;
		int32 reponse;


		for( damier=0; damier<NB_DAMIER; damier++)
		{

			sprintf( my_buffer, "%sMONO\\damier%02d.TGA", chemin_data, (18-damier) );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

			reponse = Fcm_make_sprite_opaque_mono(	&image_tga,
													&surface_damier[damier],
													&mfdb_damier[damier],
													my_buffer
												);

			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_opaque_mono( &mfdb_damier[damier], 0, 520 );

			Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		}
	}


	return 0L;


}

