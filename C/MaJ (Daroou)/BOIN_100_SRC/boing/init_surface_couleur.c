/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 11/11/2023 * */
/* ***************************** */


#include "set_palette.c"


/* debug affiche sprite sur ecran */
//#include "../fonction/graphique/Fcmgfx_affiche_mfdb.c"




/* prototype */
int32 init_surface_couleur( void );




/* Fonction */
int32 init_surface_couleur( void )
{
	char	my_buffer[ (TAILLE_CHEMIN_DATA+16) ];	/* nom du fichier avec chemin */
	s_tga_ldg  image_tga;


#ifdef LOG_FILE
uint32 timer;
timer=Fcm_get_timer();
#endif


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



#ifdef LOG_FILE
sprintf( buf_log, CRLF" Construction de la palette pour TGA_SA.LDG"CRLF );
log_print(FALSE);
#endif



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



	/* ------------------------------------------------ */
	/* on recherche les couleurs dans la palette        */
	/* ------------------------------------------------ */
	{
		int16 idx, pixel_idx;
		int16 reponse;
		int16 rgb_in[3];
		uint16 nb_couleur;
		
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




	/* **************************************************************** */
	/* Ouverture de l'‚cran                                           * */
	/* **************************************************************** */

#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation FrameBuffer"CRLF );
log_print(FALSE);
#endif

	/* --------------------------------------------------------------- */
	/* FrameBuffer                                                     */
	/* --------------------------------------------------------------- */

	surface_framebuffer.nb_plan = FCMGFX_SCREEN_NBPLAN;
	surface_framebuffer.width   = SCREEN_WIDTH;
	surface_framebuffer.height  = SCREEN_HEIGHT;
	surface_framebuffer.handle_VDIoffscreen = SURFACE_OPEN_VDI_OFFSCREEN_BITMAP;

	if( Fcm_create_surface(&surface_framebuffer, &mfdb_framebuffer) != TRUE )
	{
		return( APPLI_ERROR_CREATE_SURFACE );
	}



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



	/* --------------------------------------------------------------- */
	/* Image de fond                                                   */
	/* --------------------------------------------------------------- */
	{
		int32 reponse;


#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image de fond"CRLF );
log_print(FALSE);
#endif


		sprintf( my_buffer, "%sFOND.TGA", chemin_data );


#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_sprite_opaque	(	&image_tga,
												&surface_fond_ecran,
												&mfdb_fond_ecran,
												my_buffer
											);

		if( reponse != 0 )
		{
			return(reponse);
		}

		/* Copie vers le frame buffer */
		{
			pxy[0]=0;
			pxy[1]=0;
			pxy[2]=mfdb_framebuffer.fd_w-1;
			pxy[3]=mfdb_framebuffer.fd_h-1;
			pxy[4]=0;
			pxy[5]=0;
			pxy[6]=pxy[2];
			pxy[7]=pxy[3];
			
			vro_cpyfm(vdihandle,3,pxy, &mfdb_fond_ecran, &mfdb_framebuffer );
		}

//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_fond_ecran, 0, 0 );

	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);








	/* ------------------------------- */
	/* -            BOING            - */
	/* ------------------------------- */
	{
		int16 balle;


#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image boing"CRLF );
log_print(FALSE);
#endif

		for( balle=0; balle<NB_BOING_BALL; balle++)
		{
			int32 reponse;


			sprintf( my_buffer, "%sBOING%1d.TGA", chemin_data, (balle+1) );

#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

			reponse = Fcm_make_sprite_transparent(	&image_tga,
													&surface_boing_ball[balle],
													&surface_boing_ball_mask[balle],
													&mfdb_boing_ball[balle],
													&mfdb_boing_ball_mask[balle],
													my_buffer,
													0,
													1
												);

			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_boing_ball_mask[balle], (0+balle*mfdb_boing_ball[balle].fd_w), (200) );
//Fcmgfx_affiche_mfdb_sprite_opaque( &mfdb_boing_ball[balle], (0+balle*mfdb_boing_ball[balle].fd_w), (200+mfdb_boing_ball[balle].fd_h) );


			Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		}
	}








	/* ------------------------------- */
	/* -         OMBRE BOING         - */
	/* ------------------------------- */
	{
		int32 reponse;


#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation image ombre"CRLF );
log_print(FALSE);
#endif


		sprintf( my_buffer, "%sOMBRE.TGA", chemin_data );


#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

		reponse = Fcm_make_mask(	&image_tga,
									&surface_boing_ombre_mask,
									&mfdb_boing_ombre_mask,
									my_buffer,
									0,
									0
								);


		if( reponse != 0 )
		{
			return(reponse);
		}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_boing_ombre_mask, 16, 360 );

	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



#ifdef LOG_FILE
sprintf( buf_log, CRLF"*****  init_surface_couleur en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
log_print(FALSE);
#endif


	return 0L;


}

