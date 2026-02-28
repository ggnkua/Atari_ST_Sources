/* **[]************************* */
/* *                           * */
/* * 04/05/2015 MaJ 04/05/2015 * */
/* ***************************** */


#include "Fcm_create_surface.c"
#include "Fcm_free_surface.c"


/* prototype */
void Fcm_select_pixel_xformat( void );
void Fcm_ouvre_fenetre_pixel_xformat( void );
void Fcm_redraw_fenetre_pixel_xformat( const GRECT *rd );
void Fcm_gestion_fenetre_pixel_xformat( int16 controlkey, int16 touche, int16 bouton );



MFDB    mfdb_mire[5];
SURFACE surface_mire[5];


uint8 Fcm_pixel_xformat_mire[]={
0x00,0x00,0x0a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
0x00,0x00,0x20,0x00,0x20,0x00,0x10,0x00,0x8a,0xe0,
0x7f,0x89,0x1f,0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,
0x89,0x1f,0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,
0x1f,0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,0x1f,
0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,0x1f,0x7c,
0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,0x1f,0x7c,0x8a,
0xff,0x03,0x8a,0xe0,0x7f,0x89,0x1f,0x7c,0x8a,0xff,
0x03,0x8a,0xe0,0x7f,0x89,0x1f,0x7c,0x8a,0xff,0x03,
0x8a,0xe0,0x7f,0x89,0x1f,0x7c,0x8a,0xff,0x03,0x8a,
0xe0,0x7f,0x89,0x1f,0x7c,0x8a,0xff,0x03,0x8a,0xe0,
0x7f,0x89,0x1f,0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,
0x89,0x1f,0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,
0x1f,0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,0x1f,
0x7c,0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,0x1f,0x7c,
0x8a,0xff,0x03,0x8a,0xe0,0x7f,0x89,0x1f,0x7c,0x8a,
0xff,0x03,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,
0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,
0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,
0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,
0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,
0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,
0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,
0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,
0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,
0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,
0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,
0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,
0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,
0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,
0x89,0xe0,0x03,0x8a,0x1f,0x00};





/* Fonction */
void Fcm_select_pixel_xformat( void )
{



	win_rsc               [ W_LAUNCH ] = DL_PIXEL_XFORMAT;
	win_rsc_iconify       [ W_LAUNCH ] = FCM_NO_WIN_RSC;
	table_ft_ouvre_fenetre[ W_LAUNCH ] = Fcm_ouvre_fenetre_pixel_xformat;
	table_ft_redraw_win   [ W_LAUNCH ] = Fcm_redraw_fenetre_pixel_xformat;
	table_ft_gestion_win  [ W_LAUNCH ] = Fcm_gestion_fenetre_pixel_xformat;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_select_pixel_xformat()"CRLF);
	log_print(FALSE);
	#endif


	/* --------------------------------------------------------------- */
	/* Ouverture de la mire dans les diff‚rents pixels mode            */
	/* --------------------------------------------------------------- */
	{
		int16     ldg_version;
		int16     pixel_xformat=0;
		s_tga_ldg image_tga;


		if( open_LDG_TGA(&ldg_version) != 0L )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"=> ERREUR ouverture TGA_SA.LDG"CRLF );
			log_print(FALSE);
			#endif

			return;
		}

		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"=> TGA_SA.LDG version : %04x, (%d)"CRLF, ldg_version, ldg_version );
		log_print(FALSE);
		#endif


		/* on recherche les couleurs dans la palette pour le mode 8bits */
		if( Fcm_screen.nb_plan == 8 )
		{
			int16 idx, pixel_idx;
			int16 reponse;
			int16 rgb_in[3];

			for( idx=0; idx<256; idx++ )
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
					image_tga.palette[pixel_idx].red   = 0;
					image_tga.palette[pixel_idx].green = 0;
					image_tga.palette[pixel_idx].blue  = 0;
				}
			}
		}




		/* Ouverture du sprite */
		{
/*			int32 reponse;*/

			switch( Fcm_screen.nb_plan )
			{
				case 8:
					pixel_xformat = PIXEL_8_PACKED;
					break;
				case 16:
					pixel_xformat = PIXEL_16_MOTOROLA;
					break;
				case 24:
					pixel_xformat = PIXEL_24_MOTOROLA;
					break;
				case 32:
					pixel_xformat = PIXEL_32_MOTOROLA;
					break;
			}

			image_tga.format_need    = pixel_xformat;
			image_tga.vdi_align16    = TGA_VDI_ALIGN16;
			image_tga.adr_source = (uint32)Fcm_pixel_xformat_mire;

			/*reponse =*/ TGA_getinfo( &image_tga );

/*			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"=> TGA_getinfo() = %ld"CRLF, reponse );
			log_print(FALSE);
			#endif*/





			switch( Fcm_screen.nb_plan )
			{
				case 8:
					surface_mire[0].nb_plan = SCREEN_PLAN;
					surface_mire[0].width   = image_tga.frame_width;
					surface_mire[0].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[0].fd_addr;
					image_tga.format_need    = PIXEL_8_PACKED;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/


					surface_mire[1].nb_plan = SCREEN_PLAN;
					surface_mire[1].width   = image_tga.frame_width;
					surface_mire[1].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[1].fd_addr;
					image_tga.format_need    = PIXEL_8_PACKED;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/

					Conversion_packed_to_plan( &image_tga );

					break;





				case 16:
					surface_mire[0].nb_plan = SCREEN_PLAN;
					surface_mire[0].width   = image_tga.frame_width;
					surface_mire[0].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[0].fd_addr;
					image_tga.format_need    = PIXEL_15_FALCON;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/


					surface_mire[1].nb_plan = SCREEN_PLAN;
					surface_mire[1].width   = image_tga.frame_width;
					surface_mire[1].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[1].fd_addr;
					image_tga.format_need    = PIXEL_15_MOTOROLA;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/


					surface_mire[2].nb_plan = SCREEN_PLAN;
					surface_mire[2].width   = image_tga.frame_width;
					surface_mire[2].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[2], &mfdb_mire[2] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[2].fd_addr;
					image_tga.format_need    = PIXEL_15_INTEL;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/


					surface_mire[3].nb_plan = SCREEN_PLAN;
					surface_mire[3].width   = image_tga.frame_width;
					surface_mire[3].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[3], &mfdb_mire[3] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[3].fd_addr;
					image_tga.format_need    = PIXEL_16_MOTOROLA;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/


					surface_mire[4].nb_plan = SCREEN_PLAN;
					surface_mire[4].width   = image_tga.frame_width;
					surface_mire[4].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[4], &mfdb_mire[4] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[4].fd_addr;
					image_tga.format_need    = PIXEL_16_INTEL;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/

					break;







				case 24:
					surface_mire[0].nb_plan = SCREEN_PLAN;
					surface_mire[0].width   = image_tga.frame_width;
					surface_mire[0].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[0].fd_addr;
					image_tga.format_need    = PIXEL_24_MOTOROLA;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/


					surface_mire[1].nb_plan = SCREEN_PLAN;
					surface_mire[1].width   = image_tga.frame_width;
					surface_mire[1].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[1].fd_addr;
					image_tga.format_need    = PIXEL_24_INTEL;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/

					break;






				case 32:
					surface_mire[0].nb_plan = SCREEN_PLAN;
					surface_mire[0].width   = image_tga.frame_width;
					surface_mire[0].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[0].fd_addr;
					image_tga.format_need    = PIXEL_32_MOTOROLA;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/


					surface_mire[1].nb_plan = SCREEN_PLAN;
					surface_mire[1].width   = image_tga.frame_width;
					surface_mire[1].height  = image_tga.frame_height;
					if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
					{
						#ifdef LOG_FILE
						sprintf( buf_log, CRLF"=> ERREUR Fcm_create_surface"CRLF );
						log_print(FALSE);
						#endif
						return;
					}
					image_tga.adr_decode = (uint32)mfdb_mire[1].fd_addr;
					image_tga.format_need    = PIXEL_32_INTEL;

					/*reponse =*/ TGA_decode( &image_tga );

/*					#ifdef LOG_FILE
					sprintf( buf_log, CRLF"=> TGA_decode() = %ld"CRLF, reponse );
					log_print(FALSE);
					#endif*/

					break;
			}


/*pxy[0]=0;
pxy[1]=0;
pxy[2]=surface_mire[0].width-1;
pxy[3]=surface_mire[0].height-1;
pxy[4]=876;
pxy[5]=84;
pxy[6]=pxy[4]+pxy[2];
pxy[7]=pxy[5]+pxy[3];
vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[0], &Fcm_mfdb_ecran);*/


		}


		/* Fermeture de la LDG */
		close_LDG_TGA();


	}




	/* --------------------------------------------------------------- */
	/* on cache les box de mire inutile                                */
	/* --------------------------------------------------------------- */
	{
		OBJECT	*adr_formulaire;

		rsrc_gaddr( R_TREE, win_rsc[W_LAUNCH], &adr_formulaire );

		switch( Fcm_screen.nb_plan )
		{
			case 8:
			case 24:
			case 32:
				adr_formulaire[PIXEL_XFMT_MIRE3].ob_flags = OF_HIDETREE;
				adr_formulaire[PIXEL_XFMT_MIRE4].ob_flags = OF_HIDETREE;
				adr_formulaire[PIXEL_XFMT_MIRE5].ob_flags = OF_HIDETREE;
				break;
		}
	}




	/* --------------------------------------------------------------- */
	/* On ouvre la fenˆtre                                             */
	/* --------------------------------------------------------------- */
	{
		/* pour que la fenetre soit centr‚ … l'ouverture */
		win_posxywh[W_LAUNCH][0]=FCM_NO_WINPOS;
		win_posxywh[W_LAUNCH][1]=FCM_NO_WINPOS;

		Fcm_ouvre_fenetre_pixel_xformat();
		Fcm_purge_redraw();
	}




	{
		int16	event,bouton,controlkey,touche,nb_click;

	/* --------------------------------------------------------------- */
	/* Gestion de la fenˆtre                                           */
	/* --------------------------------------------------------------- */
	do
	{

/*sprintf( texte, "*** Fcm_screen.pixel_xformat=%d", Fcm_screen.pixel_xformat );
v_gtext(vdihandle,4*8,5*16,texte);*/

		event=evnt_multi(MU_BUTTON|MU_MESAG,
						EVENT_BCLICK,3,0,
 						0,0,0,0,0,
						0,0,0,0,0,
						buffer_aes,1000,
						&souris.g_x,&souris.g_y,&bouton,&controlkey,
						&touche,&nb_click);



/*sprintf( texte, "*** event=%d ($%x) - Buffer_aes[0]=%d($%x) %ld  ***", event, event, buffer_aes[0], buffer_aes[0], Fcm_get_timer() );
v_gtext(vdihandle,4*8,4*16,texte);*/


/*	#ifdef LOG_FILE
	sprintf( buf_log, "# event=%d - Buffer_aes[0]=%d(%x) [1]=%d [2]=%d [3]=%d [4]=%d [5]=%d [6]=%d [7]=%d"CRLF, event, buffer_aes[0],buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3],buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
	log_print(FALSE);
	#endif*/


		/* ------------------------------------------------- */
		/*                      MU_MESAG                     */
		/* ================================================= */
		if( event & MU_MESAG )
		{
			/* Que nous demande l'AES ? */
			switch( buffer_aes[0] )
			{
				case WM_REDRAW:
					/* Il faut redessiner le contenu de la fentre */
					Fcm_gestion_redraw_fenetre();
					break;

				case WM_MOVED:
					/* tremblement de terre, la fenetre bouge :) */
					Fcm_gestion_moved();
					break;

				case WM_BOTTOM:
					/* Oh... pourquoi doit-en se cacher ?  */
					/* on se met a l'arriere plan alors :( */
					Fcm_gestion_bottom();
	 				break;

				case WM_ONTOP:
					/* La fenetre du premier plan d'un autre appli disparait :) */
					/* et c'est nous qui prenons la place de premier :) */
					Fcm_gestion_ontop();
					break;

				case WM_UNTOPPED:
					/* Une autre fenetre nous a pris la premiere place :(     */
					/* l'aes nous previent que ne sommes plus au premier plan */
					Fcm_gestion_untopped();
					break;

				case WM_TOPPED:
					/* Bonne nouvelle... on repasse au premier plan :) */
					Fcm_gestion_topped();
					break;

				case WM_SHADED:
				case WM_UNSHADED:
					/* Le contenu de notre fenetre est cach‚ ou affich‚ */
					Fcm_gestion_shaded();
					break;


				case WM_ICONIFY:
				case WM_ALLICONIFY:
					Fcm_gestion_iconify(controlkey);
	   				break;

				case WM_UNICONIFY:
					Fcm_gestion_uniconify();
	   				break;


				default:
					#ifdef LOG_FILE
					sprintf(texte,"Message AES inconnu: event=%d BUF[0]=%x BUF[1]=%x BUF[2]=%x BUF[3]=%x ",event, buffer_aes[0],buffer_aes[1],buffer_aes[2],buffer_aes[3]);
					v_gtext(vdihandle,4*8,3*16,texte);

					sprintf( buf_log, texte);
					log_print(FALSE);
					sprintf(texte,"BUF[4]=%x BUF[5]=%x BUF[6]=%x BUF[7]=%x "CRLF,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);
					v_gtext(vdihandle,4*8,4*16,texte);
					sprintf( buf_log, texte);
					log_print(FALSE);
					#endif
					break;
			}
		}


		/* ------------------------------------------------- */
		/*                      MU_BUTTON                    */
		/* ================================================= */
		if( event & MU_BUTTON )
		{
			Fcm_gestion_souris( controlkey, bouton );
		}


	} while( Fcm_screen.pixel_xformat==-1 );

	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" -=> Fcm_screen.pixel_xformat = %d"CRLF, Fcm_screen.pixel_xformat );
	log_print(FALSE);
	#endif



	Fcm_free_surface( &surface_mire[0] );
	Fcm_free_surface( &surface_mire[1] );

	if( Fcm_screen.nb_plan==16 )
	{
		Fcm_free_surface( &surface_mire[2] );
		Fcm_free_surface( &surface_mire[3] );
		Fcm_free_surface( &surface_mire[4] );
	}




	/* --------------------------------------------------------------- */
	/* Fermeture de la fenˆtre                                         */
	/* --------------------------------------------------------------- */
	{
		Fcm_fermer_fenetre(W_LAUNCH);
	}




	return;


}














void Fcm_ouvre_fenetre_pixel_xformat( void )
{
	OBJECT	*adr_formulaire;
	int16	x,y,largeur,hauteur;
	int16	winx,winy,winw,winh;
	uint16	win_flag;



	#ifdef LOG_FILE
	sprintf( buf_log, " ~ Fcm_ouvre_fenetre_pixel_xformat(), hwin(%d)=", W_LAUNCH );
	log_print(FALSE);
	#endif



	if( h_win[W_LAUNCH]>0 )
	{
		buffer_aes[0]=WM_TOPPED;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=h_win[W_LAUNCH];
		appl_write( ap_id, 16, &buffer_aes );
	}
	else
	{
		win_flag=NAME|MOVER;

		/* on recherche l'adresse du Formulaire */
		rsrc_gaddr( R_TREE, win_rsc[ W_LAUNCH], &adr_formulaire );

		/* on demande … l'AES de le centrer sur le DeskTop */
		form_center( adr_formulaire, &winx, &winy, &winw, &winh );


		/* Calcul des dimensions de la fenetre en fonction */
		/* de la taille du formulaire                      */
		x       = winx;
		y       = winy;
		largeur = winw;
		hauteur = winh;

		/* on demande … l'AES de nous calculer la taille de la fenˆtre */
		/* en fonction de la zone de travail (taille formulaire)       */
		wind_calc(	0,win_flag,
					x, y, largeur, hauteur, &winx, &winy, &winw, &winh );


		/* Replace la fenetre … sa derniŠre position enregistr‚ */
		Fcm_set_win_position( W_LAUNCH, &winx, &winy );


		/* On demande … l'AES de cr‚er notre fenˆtre */
		h_win[W_LAUNCH]=wind_create(	win_flag,
										winx,winy,winw,winh); 

		if( h_win[W_LAUNCH]>0 )
		{
			/* on m‚morise la position de la fenˆtre */
			win_posxywh[W_LAUNCH][0]=winx;
			win_posxywh[W_LAUNCH][1]=winy;
			win_posxywh[W_LAUNCH][2]=winw;
			win_posxywh[W_LAUNCH][3]=winh;

			#ifdef LOG_FILE
			sprintf( buf_log, "%2d ; w=%3d, h=%3d"CRLF, h_win[W_LAUNCH], winw, winh );
			log_print(FALSE);
			#endif


			/* adresse du dialogue des titres de fenetre */
			rsrc_gaddr( R_TREE, DL_TITRE_FENETRE, &adr_formulaire );

			/* Si la fenˆtre a pu ˆtre cr‚er, on lui donne un nom ... */
			wind_set_str(h_win[W_LAUNCH],WF_NAME,(adr_formulaire+TITRE_PIXEL_XFMT)->ob_spec.free_string);
			/* ... et on demande … l'AES de l'ouvrir */
			wind_open(h_win[W_LAUNCH],winx,winy,winw,winh);


		}
		else
		{
			int16 dummy;

			#ifdef LOG_FILE
			sprintf( buf_log, "‚chec (ERREUR)"CRLF);
			log_print(FALSE);
			#endif

			h_win[W_LAUNCH]=FCM_NO_OPEN_WINDOW;
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, &dummy );

		}
	}


	return;


}







void Fcm_redraw_fenetre_pixel_xformat( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;
	int16   pxy[8];



	/* on cherche les coordonn‚es de travail de la fenˆtre */
	wind_get(h_win[W_LAUNCH],WF_WORKXYWH,&winx,&winy,&winw,&winh);


	rsrc_gaddr( R_TREE, win_rsc[W_LAUNCH], &adr_formulaire );


	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire->ob_x = winx;
	adr_formulaire->ob_y = winy;

	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );



	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=31;
	pxy[3]=31;

	pxy[4]=winx+adr_formulaire[PIXEL_XFMT_MIRE1].ob_x ;
	pxy[5]=winy+adr_formulaire[PIXEL_XFMT_MIRE1].ob_y;
	pxy[6]=pxy[4]+31;
	pxy[7]=pxy[5]+31;

	vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[0], &Fcm_mfdb_ecran);


	pxy[4]=winx+adr_formulaire[PIXEL_XFMT_MIRE2].ob_x ;
	pxy[5]=winy+adr_formulaire[PIXEL_XFMT_MIRE2].ob_y;
	pxy[6]=pxy[4]+31;
	pxy[7]=pxy[5]+31;

	vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[1], &Fcm_mfdb_ecran);

	if( Fcm_screen.nb_plan == 16 )
	{

		pxy[4]=winx+adr_formulaire[PIXEL_XFMT_MIRE3].ob_x ;
		pxy[5]=winy+adr_formulaire[PIXEL_XFMT_MIRE3].ob_y;
		pxy[6]=pxy[4]+31;
		pxy[7]=pxy[5]+31;

		vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[2], &Fcm_mfdb_ecran);


		pxy[4]=winx+adr_formulaire[PIXEL_XFMT_MIRE4].ob_x ;
		pxy[5]=winy+adr_formulaire[PIXEL_XFMT_MIRE4].ob_y;
		pxy[6]=pxy[4]+31;
		pxy[7]=pxy[5]+31;

		vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[3], &Fcm_mfdb_ecran);


		pxy[4]=winx+adr_formulaire[PIXEL_XFMT_MIRE5].ob_x ;
		pxy[5]=winy+adr_formulaire[PIXEL_XFMT_MIRE5].ob_y;
		pxy[6]=pxy[4]+31;
		pxy[7]=pxy[5]+31;

		vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[4], &Fcm_mfdb_ecran);

	}


	return;


}





/* Fonction */
void Fcm_gestion_fenetre_pixel_xformat( int16 controlkey, int16 touche, int16 bouton )
{

	OBJECT	*adr_formulaire;
	WORD	objet;



/*	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_fenetre_pixel_xformat(%d,%d,%d)"CRLF, controlkey,touche,bouton );
	log_print(FALSE);
	#endif*/



	/* anti warning, controlkey & touche sont inutilis‚ ici */
	objet=controlkey=touche;



	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_PIXEL_XFORMAT, &adr_formulaire );

	objet = objc_find(adr_formulaire,0,4,souris.g_x,souris.g_y);




	if( bouton )
	{
		switch( objet )
		{
			case PIXEL_XFMT_MIRE1:
				switch( Fcm_screen.nb_plan )
				{
					case 8:
						Fcm_screen.pixel_xformat=PIXEL_8_PACKED;
						break;
					case 16:
						Fcm_screen.pixel_xformat=PIXEL_15_FALCON;
						break;
					case 24:
						Fcm_screen.pixel_xformat=PIXEL_24_MOTOROLA;
						break;
					case 32:
						Fcm_screen.pixel_xformat=PIXEL_32_MOTOROLA;
						break;
				}
				break;


			case PIXEL_XFMT_MIRE2:
				switch( Fcm_screen.nb_plan )
				{
					case 8:
						Fcm_screen.pixel_xformat=PIXEL_8_PLAN;
						break;
					case 16:
						Fcm_screen.pixel_xformat=PIXEL_15_MOTOROLA;
						break;
					case 24:
						Fcm_screen.pixel_xformat=PIXEL_24_INTEL;
						break;
					case 32:
						Fcm_screen.pixel_xformat=PIXEL_32_INTEL;
						break;
				}
				break;


			case PIXEL_XFMT_MIRE3:
				Fcm_screen.pixel_xformat=PIXEL_15_INTEL;
				break;


			case PIXEL_XFMT_MIRE4:
				Fcm_screen.pixel_xformat=PIXEL_16_MOTOROLA;
				break;


			case PIXEL_XFMT_MIRE5:
				Fcm_screen.pixel_xformat=PIXEL_16_INTEL;
				break;

		}
	}



	return;

}



