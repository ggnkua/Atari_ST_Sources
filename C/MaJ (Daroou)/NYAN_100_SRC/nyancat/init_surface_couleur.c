/* **[NyanCat]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 11/11/2023 * */
/* ***************************** */


//#include "../fonction/coeur/coeur_define.c"

#include "../fonction/graphique/Fcm_create_surface.c"
#include "../fonction/graphique/Fcm_make_sprite_transparent.c"
#include "../fonction/graphique/Fcm_make_sprite_opaque.c"
#include "../fonction/graphique/Fcm_make_mask.c"

#include "appli_error_code.h"
#include "set_palette.c"



/* debug affiche sprite sur ecran */
//#include "../fonction/graphique/Fcmgfx_affiche_mfdb.c"



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
	/* Image de fond                   */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%snyanc_fd.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image nyanc_fd.TGA"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif


		reponse = Fcm_make_sprite_opaque(	&image_tga,
											&surface_fond_ecran,
											&mfdb_fond_ecran,
											my_buffer
										);

		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_fond_ecran, 0, 0 );

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

			sprintf( my_buffer, "%snyancat%1d.tga", chemin_data, (index_sprite+1) );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image NyanCat:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

			reponse = Fcm_make_sprite_transparent(	&image_tga,
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

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_nyancat_sprite[index_sprite], (0+index_sprite*mfdb_nyancat_sprite[index_sprite].fd_w), 200 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_nyancat_mask[index_sprite], (0+index_sprite*mfdb_nyancat_sprite[index_sprite].fd_w), (200+mfdb_nyancat_sprite[index_sprite].fd_h) );

		}
	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);










	/* ------------------------------- */
	/* Arc en ciel UP                  */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sarc_up.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_transparent(	&image_tga,
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

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_arcenciel[ARCENCIEL_UP], 0, 300 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_arcenciel_mask[ARCENCIEL_UP], 200, 300 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);








	/* ------------------------------- */
	/* Arc en ciel Down                */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%sarc_down.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_transparent(	&image_tga,
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

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_arcenciel[ARCENCIEL_DOWN], 0, 300 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_arcenciel_mask[ARCENCIEL_DOWN], 200, 300 );

	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);








	/* ------------------------------- */
	/* Fonte                           */
	/* ------------------------------- */
	{
		int32 reponse;

		sprintf( my_buffer, "%snyan_fnt.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image:"CRLF"chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_transparent(	&image_tga,
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

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_font, 0, 400 );
//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_mask_font, 200, 400 );

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
			sprintf( my_buffer, "%sstar%02d.tga", chemin_data, (index_etoile+1) );

			reponse = Fcm_make_mask(	&image_tga,
										&surface_star_mask[index_etoile],
										&mfdb_star_mask[index_etoile],
										my_buffer,
										0,
										0
									);

			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_star_mask[index_etoile], 0, 500 );

		}
	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);


	return 0L;


}

