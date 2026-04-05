/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 11/11/2023 * */
/* ***************************** */


/* debug affiche sprite sur ecran */
//#include "../fonction/graphique/Fcmgfx_affiche_mfdb.c"



/* prototype */
int32 init_surface_mono( void );



/* Fonction */
int32 init_surface_mono( void )
{
	char	my_buffer[ (TAILLE_CHEMIN_DATA+16) ];	/* nom du fichier avec chemin */
	s_tga_ldg  image_tga;


#ifdef LOG_FILE
uint32 timer;
timer=Fcm_get_timer();
#endif



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
sprintf( buf_log, "Palette: 16 couleurs"CRLF );
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





#ifdef LOG_FILE
sprintf( buf_log, CRLF" Cr‚ation FrameBuffer"CRLF );
log_print(FALSE);
#endif


	/* --------------------------------------------------------------- */
	/* FrameBuffer                                                     */
	/* --------------------------------------------------------------- */
	surface_framebuffer.nb_plan          = FCMGFX_SCREEN_NBPLAN;  /* nombre de plan de l'écran */
	surface_framebuffer.width            = SCREEN_WIDTH;
	surface_framebuffer.height           = SCREEN_HEIGHT;
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

		sprintf( my_buffer, "%sMONO\\FOND.TGA", chemin_data );

#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
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

		/* Copie vers le FrameBuffer */
		{
			int16 couleur_fond[2];

			couleur_fond[0] = G_BLACK;
			couleur_fond[1] = G_WHITE;

			pxy[0]= 0;
			pxy[1]= 0;
			pxy[2]= mfdb_framebuffer.fd_w - 1;
			pxy[3]= mfdb_framebuffer.fd_h - 1;
			pxy[4]= 0;
			pxy[5]= 0;
			pxy[6]= pxy[2];
			pxy[7]= pxy[3];

			vrt_cpyfm(vdihandle, MD_REPLACE, pxy, &mfdb_fond_ecran, &mfdb_framebuffer, couleur_fond);
		}

//Fcmgfx_affiche_mfdb_sprite_opaque_mono( &mfdb_fond_ecran, 0, 0 );

	}




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


			sprintf( my_buffer, "%sMONO\\BOING%1d.TGA", chemin_data, (balle+1) );

#ifdef LOG_FILE
sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
log_print(FALSE);
#endif

			reponse = Fcm_make_sprite_transparent_mono(	&image_tga,
														&surface_boing_ball[balle],
														&surface_boing_ball_mask[balle],
														&mfdb_boing_ball[balle],
														&mfdb_boing_ball_mask[balle],
														my_buffer,
														0,
														0
													);

			if( reponse != 0 )
			{
				return(reponse);
			}

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_boing_ball_mask[balle], (0+balle*mfdb_boing_ball[balle].fd_w), 200 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_boing_ball[balle], (0+balle*mfdb_boing_ball[balle].fd_w), (200+mfdb_boing_ball[balle].fd_h) );

//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_boing_ball_mask[balle], (0+balle*mfdb_boing_ball[balle].fd_w), 360 );
//Fcmgfx_affiche_mfdb_sprite_mono( &mfdb_boing_ball[balle], (0+balle*mfdb_boing_ball[balle].fd_w), 360 );


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


		sprintf( my_buffer, "%sMONO\\OMBRE.TGA", chemin_data );


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


//Fcmgfx_affiche_mfdb_sprite_mask( &mfdb_boing_ombre_mask, 16, 500 );

	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



#ifdef LOG_FILE
sprintf( buf_log, CRLF"*****  init_surface_mono en %ld/200"CRLF""CRLF, Fcm_get_timer()-timer );
log_print(FALSE);
#endif


	return 0L;


}

