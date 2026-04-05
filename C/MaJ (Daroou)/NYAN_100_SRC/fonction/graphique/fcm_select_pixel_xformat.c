/* **[Fonction Graphique]******** */
/* *                            * */
/* * 04/05/2015 MaJ 01/03/2024  * */
/* ****************************** */


#include "../ldg/tga_sa_ldg.h"
#include "../coeur/fcm_rescale_def.h"

#include "pixel_format_id.h"

#include "fcm_create_surface.c"
#include "fcm_free_surface.c"



/*
 * Remarque:
 * Le Coeur ne peut pas s'occuper du redraw, car les mires sont
 * affichées par la VDI par dessus le dialogue.
 *
 */


/* prototype des fonctions presente dans ce fichier */
int16 Fcm_select_pixel_xformat( void );
void  Fcm_rescale_fenetre_pixel_xformat( void );
void  Fcm_redraw_fenetre_pixel_xformat( const GRECT *rd, const int16 index_tab_win );
void  Fcm_gestion_fenetre_pixel_xformat( int16 controlkey, int16 touche, int16 bouton );


MFDB  mfdb_mire[5]; /* Global, pour fonction redraw */



int16 Fcm_select_pixel_xformat( void )
{
	SURFACE  surface_mire[5];


//return( APPLI_ERROR_CREATE_SURFACE );
//return( 0 );


	FCM_LOG_PRINT( CRLF"# Fcm_select_pixel_xformat()" );

	/* image de la mire au format TGA type 10 (32x16) */
	uint8 Fcm_pixel_xformat_mire[]={
	0x00,0x00,0x0a,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x20,0x00,0x10,0x00,
	0x10,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,
	0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,
	0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,
	0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,
	0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,
	0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,
	0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,
	0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,
	0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,0x1f,0x00,0x8a,0x00,0x7c,0x89,0xe0,0x03,0x8a,
	0x1f,0x00};


	/* Les infos pour le Coeur */
	win_titre             [ W_DIALTEMP ] = FCM_NO_WIN_TITRE;
	win_widgets           [ W_DIALTEMP ] = NAME|MOVER;
	win_rsc               [ W_DIALTEMP ] = DL_PIXEL_XFORMAT;
	win_rsc_iconify       [ W_DIALTEMP ] = FCM_NO_RSC_DEFINED;
	table_ft_ouvre_fenetre[ W_DIALTEMP ] = FCM_FONCTION_NON_DEFINI;
	table_ft_redraw_win   [ W_DIALTEMP ] = Fcm_redraw_fenetre_pixel_xformat;
	table_ft_gestion_win  [ W_DIALTEMP ] = Fcm_gestion_fenetre_pixel_xformat;


	/* init surface */
	{
		int16 idx;

		for( idx=0; idx<5; idx++ )
		{
			surface_mire[idx].handle_VDIoffscreen = SURFACE_NO_OPEN_VDI_OFFSCREEN_BITMAP;
		}
	}



	/* conversion mire.tga en code C */
	/*{
		#define tailleBUFFER (256)
		char buffer[tailleBUFFER];
		char texte[128];
		int32 taille_fichier;
		int32 handle_fichier;
		char *pt_buffer;
		int16 idx;

		taille_fichier = Fcm_file_size( "MIRE.TGA" );

		if( taille_fichier>0 && taille_fichier<tailleBUFFER )
		{
			Fcm_bload( "MIRE.TGA", buffer, 0, taille_fichier);

			handle_fichier=Fcreate("MIRE.TXT",0);
			strcpy( texte, CRLF"uint8 Fcm_pixel_xformat_mire[]={"CRLF );
			Fwrite( handle_fichier, strlen(texte) , texte );

			pt_buffer = buffer;
			for( idx=0; idx<taille_fichier; idx++ )
			{
				sprintf( texte, "0x%02x,", (uint8)*pt_buffer++ );

				Fwrite( handle_fichier, strlen(texte) , texte );
				if( !((idx+1) % 16) )
				{
					strcpy( texte, CRLF"" );
					Fwrite( handle_fichier, strlen(texte) , texte );
				}
			}

			strcpy( texte, "};"CRLF );
			Fwrite( handle_fichier, strlen(texte) , texte );

			Fclose( handle_fichier );
		}
		else
		{
			printf(CRLF"errrreeeeeuuuuuurrrrrrr !!!!!!"CRLF);
		}
	
		#undef tailleBUFFER
	}*/


 
	/* --------------------------------------------------------------- */
	/* Ouverture de la mire dans les diff‚rents pixels mode            */
	/* --------------------------------------------------------------- */
	{
		int16     ldg_tga_version;
		s_tga_ldg tga_image;


		if( open_LDG_TGA(&ldg_tga_version) != 0L )
		{
			FCM_LOG_PRINT( CRLF"=> ERREUR ouverture TGA_SA.LDG" );

			return( APPLI_ERROR_OPEN_TGA_LDG );
		}

		FCM_LOG_PRINT3( CRLF"=> TGA_SA.LDG version : $%04x, (%d.%d)", ldg_tga_version, (ldg_tga_version>>8), (ldg_tga_version&0xff) );


		/* on recherche les couleurs dans la palette pour le mode 8bits */
		if( Fcm_screen.nb_plan == 8 )
		{
			int16 idx, pixel_idx;
			int16 reponse;
			int16 rgb_in[3];

			tga_image.nb_col_palette=256;

			for( idx=0; idx<256; idx++ )
			{
				reponse = vq_color( vdihandle, idx, 1, rgb_in);

				/* corespondance entre index palette et valeur du pixel */
				pixel_idx = Fcm_screen.palette_to_device[idx];

				if(  reponse != -1 )
				{
					tga_image.palette[pixel_idx].red   = (rgb_in[0] * 255) / 1000;
					tga_image.palette[pixel_idx].green = (rgb_in[1] * 255) / 1000;
					tga_image.palette[pixel_idx].blue  = (rgb_in[2] * 255) / 1000;
				}
				else
				{
					tga_image.palette[pixel_idx].red   = 999;
					tga_image.palette[pixel_idx].green = 999;
					tga_image.palette[pixel_idx].blue  = 999;
				}
			}
		}




		/* --- Ouverture des surfaces Mire --- */
		{
			uint16  pixel_xformat=PIXEL_8_PACKED;

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

			tga_image.format_need = pixel_xformat;
			tga_image.vdi_align16 = TGA_VDI_ALIGN16;
			tga_image.adr_source  = (uint32)Fcm_pixel_xformat_mire;

			/* on determine qu'une seule fois les dimensoins de l'image */
			/* et la taille du buffer RAM pour decoder la Mire TGA      */
			TGA_getinfo( &tga_image );
		}



		switch( Fcm_screen.nb_plan )
		{
			case 8:
				surface_mire[0].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[0].width   = tga_image.frame_width;
				surface_mire[0].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[0].fd_addr;
				tga_image.format_need = PIXEL_8_PACKED;

				TGA_decode( &tga_image );


				surface_mire[1].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[1].width   = tga_image.frame_width;
				surface_mire[1].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[1].fd_addr;
				tga_image.format_need = PIXEL_8_PACKED;

				TGA_decode( &tga_image );
				Conversion_packed_to_plan( &tga_image ); /* 8bits packed to 8bits plan */

				break;




			case 16:
				surface_mire[0].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[0].width   = tga_image.frame_width;
				surface_mire[0].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[0].fd_addr;
				tga_image.format_need = PIXEL_15_FALCON;

				TGA_decode( &tga_image );


				surface_mire[1].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[1].width   = tga_image.frame_width;
				surface_mire[1].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[1].fd_addr;
				tga_image.format_need = PIXEL_15_MOTOROLA;

				TGA_decode( &tga_image );


				surface_mire[2].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[2].width   = tga_image.frame_width;
				surface_mire[2].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[2], &mfdb_mire[2] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[2].fd_addr;
				tga_image.format_need = PIXEL_15_INTEL;

				TGA_decode( &tga_image );



				surface_mire[3].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[3].width   = tga_image.frame_width;
				surface_mire[3].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[3], &mfdb_mire[3] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[3].fd_addr;
				tga_image.format_need = PIXEL_16_MOTOROLA;

				TGA_decode( &tga_image );


				surface_mire[4].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[4].width   = tga_image.frame_width;
				surface_mire[4].height  = tga_image.frame_height;
				if( Fcm_create_surface(&surface_mire[4], &mfdb_mire[4] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}
				tga_image.adr_decode  = (uint32)mfdb_mire[4].fd_addr;
				tga_image.format_need = PIXEL_16_INTEL;

				TGA_decode( &tga_image );

				break;



			case 24:
				surface_mire[0].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[0].width   = tga_image.frame_width;
				surface_mire[0].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[0].fd_addr;
				tga_image.format_need = PIXEL_24_MOTOROLA;

				TGA_decode( &tga_image );


				surface_mire[1].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[1].width   = tga_image.frame_width;
				surface_mire[1].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[1].fd_addr;
				tga_image.format_need = PIXEL_24_INTEL;

				TGA_decode( &tga_image );

				break;




			case 32:
				surface_mire[0].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[0].width   = tga_image.frame_width;
				surface_mire[0].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[0], &mfdb_mire[0] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode  = (uint32)mfdb_mire[0].fd_addr;
				tga_image.format_need = PIXEL_32_MOTOROLA;

				TGA_decode( &tga_image );


				surface_mire[1].nb_plan = FCMGFX_SCREEN_NBPLAN;
				surface_mire[1].width   = tga_image.frame_width;
				surface_mire[1].height  = tga_image.frame_height;

				if( Fcm_create_surface(&surface_mire[1], &mfdb_mire[1] ) != TRUE )
				{
					FCM_LOG_PRINT( CRLF"=> ERREUR Fcm_create_surface" );
					return( APPLI_ERROR_CREATE_SURFACE );
				}

				tga_image.adr_decode = (uint32)mfdb_mire[1].fd_addr;
				tga_image.format_need    = PIXEL_32_INTEL;

				TGA_decode( &tga_image );

				break;
		}


		/* Fermeture de la LDG */
		close_LDG_TGA();
	}




	{
		OBJECT	*adr_formulaire;
		int16    selected_objet = -1;


		/* --------------------------------------------------------------- */
		/* on cache les box de mire inutile                                */
		/* --------------------------------------------------------------- */
		adr_formulaire = Fcm_adr_RTREE[ win_rsc[W_DIALTEMP] ];

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


		{
			int16 idx;
			
			for( idx=PIXEL_XFMT_MIRE1; idx <= PIXEL_XFMT_MIRE5; idx++ )
			{
				adr_formulaire[idx].ob_spec.obspec.framesize = -1;
				adr_formulaire[idx].ob_spec.obspec.framecol  = G_BLACK;
			}
		}


		/* --------------------------------------------------------------- */
		/* On ouvre la fenˆtre                                             */
		/* --------------------------------------------------------------- */

		/* pour que la fenetre soit centr‚ … l'ouverture */
		win_posxywh[W_DIALTEMP][0] = FCM_NO_WINPOS;
		win_posxywh[W_DIALTEMP][1] = FCM_NO_WINPOS;


		Fcm_rescale_fenetre_pixel_xformat();
		Fcm_ouvre_fenetre( W_DIALTEMP, NULL );

		if( h_win[W_DIALTEMP] == FCM_NO_OPEN_WINDOW )
		{
			/* pas de fenetre, on s'embete pas à afficher le dial en mode     */
			/* bloquant, si pas de fenetre, il y en aura pas pour l'applis... */
			return( 0 );
		}


		//Fcm_purge_aes_message();  /* deja present dans Fcm_ouvre_fenetre() */


		/* --------------------------------------------------------------- */
		/* Gestion de la fenˆtre                                           */
		/* --------------------------------------------------------------- */
		do
		{
			int16  event, bouton, nb_click;
			/*int16  controlkey, touche;*/



			event = evnt_multi( MU_TIMER|MU_BUTTON|MU_MESAG,
							FCM_EVENT_MBCLICKS, FCM_EVENT_MBMASK, FCM_EVENT_MBSTATE,
							0,0,0,0,0,
							0,0,0,0,0,
							buffer_aes,50,
							&souris.g_x,&souris.g_y,&bouton,NULL/*&controlkey*/,
							NULL/*&touche*/,&nb_click);

			/* ------------------------------------------------- */
			/*                      MU_MESAG                     */
			/* ================================================= */
			if( event & MU_MESAG )
			{
				Fcm_gestion_message();
			}


			/* ------------------------------------------------- */
			/*                      MU_TIMER                     */
			/* ================================================= */
			if( event & MU_TIMER )
			{
				int16 objet;

				/* ------------------------------------------------- */
				/* Gestion Surcadre Mire de selection                */
				/* ================================================= */
				/* pas mal de code pour un truc qui ne servira que tres peu :-p */
				objet = objc_find( adr_formulaire, 0, 4, souris.g_x, souris.g_y);

				/* objet == -1 si la souris ne se trouve pas sur le dialogue */
				if( objet != -1 )
				{
					if( objet != selected_objet )
					{
						int16 pos_x, pos_y;


						buffer_aes[0]=WM_REDRAW;
						buffer_aes[1]=ap_id;
						buffer_aes[2]=0;
						buffer_aes[3]=h_win[W_DIALTEMP];


						if( selected_objet != -1 )
						{
							/* deselection de l'objet */
							adr_formulaire[selected_objet].ob_spec.obspec.framesize = -1;
							adr_formulaire[selected_objet].ob_spec.obspec.framecol = G_BLACK;
							
							objc_offset( adr_formulaire, selected_objet, &pos_x, &pos_y );

							buffer_aes[4]=pos_x - 4;
							buffer_aes[5]=pos_y - 4;
							buffer_aes[6]=adr_formulaire[selected_objet].ob_width  + 8;
							buffer_aes[7]=adr_formulaire[selected_objet].ob_height + 8;
							appl_write( ap_id, 16, buffer_aes);
							/* on ne peut pas utiliser Fcm_objet_draw() du Coeur car les Mires sont */
							/* affichées par la VDI par dessus les objets Mires */
						}				

						if( objet>=PIXEL_XFMT_MIRE1   &&   objet<=PIXEL_XFMT_MIRE5 )
						{
							/* selection de l'objet */
							adr_formulaire[objet].ob_spec.obspec.framesize = -3;
							adr_formulaire[objet].ob_spec.obspec.framecol = G_YELLOW;

							objc_offset( adr_formulaire, objet, &pos_x, &pos_y );

							buffer_aes[4]=pos_x - 4;
							buffer_aes[5]=pos_y - 4;
							buffer_aes[6]=adr_formulaire[objet].ob_width  + 8;
							buffer_aes[7]=adr_formulaire[objet].ob_height + 8;
							appl_write( ap_id, 16, buffer_aes);

							selected_objet = objet;
						}
						else
						{
							selected_objet = -1;
						}
					}			
				}
			}



			/* ------------------------------------------------- */
			/*                      MU_BUTTON                    */
			/* ================================================= */
			if( event & MU_BUTTON )
			{
				//FCM_CONSOLE_ADD2(" event_multi: bouton=%d", bouton, G_WHITE );
				Fcm_gestion_souris( 0/*controlkey*/, bouton );
			}


		} while( Fcm_screen.pixel_xformat == PIXEL_FORMAT_INCONNU );
	}


	FCM_LOG_PRINT1( CRLF" -=> Fcm_screen.pixel_xformat = %d", Fcm_screen.pixel_xformat );


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
	Fcm_fermer_fenetre(W_DIALTEMP);


	return( 0 );


}





void Fcm_redraw_fenetre_pixel_xformat( const GRECT *rd, const int16 index_tab_win )
{
	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;
	int16   hauteur_bouton;
	int16   largeur_bouton;
	UNUSED(index_tab_win);  /* anti warning */


	/* on cherche les coordonn‚es de travail de la fenˆtre */
	wind_get(h_win[W_DIALTEMP],WF_WORKXYWH,&winx,&winy,&winw,&winh);

	adr_formulaire = Fcm_adr_RTREE[ win_rsc[W_DIALTEMP] ];

	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire->ob_x = winx;
	adr_formulaire->ob_y = winy;

	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );

	/* -1 pour la conversion en tableau VDI */
	hauteur_bouton = adr_formulaire[PIXEL_XFMT_MIRE1].ob_height-1;
	largeur_bouton = adr_formulaire[PIXEL_XFMT_MIRE1].ob_width-1;

	pxy[0]=0;
	pxy[1]=0;
	pxy[2]=largeur_bouton;
	pxy[3]=hauteur_bouton;

	pxy[4]=winx + adr_formulaire[PIXEL_XFMT_MIRE1].ob_x ;
	pxy[5]=winy + adr_formulaire[PIXEL_XFMT_MIRE1].ob_y;
	pxy[6]=pxy[4] + largeur_bouton;
	pxy[7]=pxy[5] + hauteur_bouton;

	vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[0], &Fcm_mfdb_ecran);


	pxy[4]=winx + adr_formulaire[PIXEL_XFMT_MIRE2].ob_x ;
	pxy[5]=winy + adr_formulaire[PIXEL_XFMT_MIRE2].ob_y;
	pxy[6]=pxy[4] + largeur_bouton;
	pxy[7]=pxy[5] + hauteur_bouton;

	vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[1], &Fcm_mfdb_ecran);

	if( Fcm_screen.nb_plan == 16 )
	{
		pxy[4]=winx + adr_formulaire[PIXEL_XFMT_MIRE3].ob_x ;
		pxy[5]=winy + adr_formulaire[PIXEL_XFMT_MIRE3].ob_y;
		pxy[6]=pxy[4] + largeur_bouton;
		pxy[7]=pxy[5] + hauteur_bouton;

		vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[2], &Fcm_mfdb_ecran);


		pxy[4]=winx + adr_formulaire[PIXEL_XFMT_MIRE4].ob_x ;
		pxy[5]=winy + adr_formulaire[PIXEL_XFMT_MIRE4].ob_y;
		pxy[6]=pxy[4] + largeur_bouton;
		pxy[7]=pxy[5] + hauteur_bouton;

		vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[3], &Fcm_mfdb_ecran);


		pxy[4]=winx + adr_formulaire[PIXEL_XFMT_MIRE5].ob_x ;
		pxy[5]=winy + adr_formulaire[PIXEL_XFMT_MIRE5].ob_y;
		pxy[6]=pxy[4] + largeur_bouton;
		pxy[7]=pxy[5] + hauteur_bouton;

		vro_cpyfm(vdihandle,3,pxy,  &mfdb_mire[4], &Fcm_mfdb_ecran);
	}


	return;


}






void Fcm_gestion_fenetre_pixel_xformat( int16 controlkey, int16 touche, int16 bouton )
{
	int16	objet;
	/* anti warning, controlkey & touche sont inutilis‚ ici */
	UNUSED(controlkey);
	UNUSED(touche);

//FCM_CONSOLE_ADD2(" bouton=%d", bouton, G_GREEN );

	if( bouton )
	{
		objet = objc_find( Fcm_adr_RTREE[DL_PIXEL_XFORMAT], 0, 4, souris.g_x, souris.g_y );

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

			/* mire 3-5 affiché qu'en mode 16 bits: 5 formats de pixel possible... */
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





void Fcm_rescale_fenetre_pixel_xformat( void )
{
	OBJECT	*dial;
	int16    form_w;


	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionnés                    */

	FCM_LOG_PRINT("# Fcm_rescale_fenetre_pixel_xformat()");

	dial = Fcm_adr_RTREE[DL_PIXEL_XFORMAT];

	/* On repositionne tous les objets du dialogue */
	dial[PIXEL_LIGNE1].ob_x = FCM_RESCALE_MARGE_GAUCHE;
	dial[PIXEL_LIGNE1].ob_y = FCM_RESCALE_MARGE_HAUT;
	form_w = dial[PIXEL_LIGNE1].ob_x + dial[PIXEL_LIGNE1].ob_width;

	dial[PIXEL_LIGNE2].ob_x = dial[PIXEL_LIGNE1].ob_x;
	dial[PIXEL_LIGNE2].ob_y = dial[PIXEL_LIGNE1].ob_y + dial[PIXEL_LIGNE1].ob_height;
	form_w = MAX( form_w, (dial[PIXEL_LIGNE2].ob_x + dial[PIXEL_LIGNE2].ob_width) );

	dial[PIXEL_LIGNE3].ob_x = dial[PIXEL_LIGNE1].ob_x;
	dial[PIXEL_LIGNE3].ob_y = dial[PIXEL_LIGNE2].ob_y + dial[PIXEL_LIGNE2].ob_height;
	form_w = MAX( form_w, (dial[PIXEL_LIGNE3].ob_x + dial[PIXEL_LIGNE3].ob_width) );



	/* La mire de reference RVB */
	dial[PIXEL_REF_RED].ob_x = dial[PIXEL_LIGNE1].ob_x + FCM_RESCALE_ESPACE;
	dial[PIXEL_REF_RED].ob_y = dial[PIXEL_LIGNE3].ob_y + dial[PIXEL_LIGNE3].ob_height + FCM_RESCALE_INTERLIGNE;
	dial[PIXEL_REF_RED].ob_width = 10;

	dial[PIXEL_REF_GREEN].ob_x = dial[PIXEL_REF_RED].ob_x + dial[PIXEL_REF_RED].ob_width;
	dial[PIXEL_REF_GREEN].ob_y = dial[PIXEL_REF_RED].ob_y;
	dial[PIXEL_REF_GREEN].ob_width = 10;

	dial[PIXEL_REF_BLUE].ob_x = dial[PIXEL_REF_GREEN].ob_x + dial[PIXEL_REF_GREEN].ob_width;
	dial[PIXEL_REF_BLUE].ob_y = dial[PIXEL_REF_RED].ob_y;
	dial[PIXEL_REF_BLUE].ob_width = 10;


	/* note: les objets mires sont redimensionnées lors du decodage des mires TGA */

	dial[PIXEL_XFMT_MIRE1].ob_x = dial[PIXEL_REF_BLUE].ob_x + dial[PIXEL_REF_BLUE].ob_width + (FCM_RESCALE_ESPACE*4);
	dial[PIXEL_XFMT_MIRE1].ob_y = dial[PIXEL_REF_RED].ob_y;
	/* dimenssionnement de la mire1 qui sert a definir la hauteur du dialogue */
	/* au cas ou l'objet est trafiqué dans le RSC */
	dial[PIXEL_XFMT_MIRE1].ob_width=32;
	dial[PIXEL_XFMT_MIRE1].ob_height=16;

	dial[PIXEL_XFMT_MIRE2].ob_x = dial[PIXEL_XFMT_MIRE1].ob_x + dial[PIXEL_XFMT_MIRE1].ob_width + (FCM_RESCALE_ESPACE*2);
	dial[PIXEL_XFMT_MIRE2].ob_y = dial[PIXEL_REF_RED].ob_y;

	dial[PIXEL_XFMT_MIRE3].ob_x = dial[PIXEL_XFMT_MIRE2].ob_x + dial[PIXEL_XFMT_MIRE2].ob_width + (FCM_RESCALE_ESPACE*2);
	dial[PIXEL_XFMT_MIRE3].ob_y = dial[PIXEL_REF_RED].ob_y;

	dial[PIXEL_XFMT_MIRE4].ob_x = dial[PIXEL_XFMT_MIRE3].ob_x + dial[PIXEL_XFMT_MIRE3].ob_width + (FCM_RESCALE_ESPACE*2);
	dial[PIXEL_XFMT_MIRE4].ob_y = dial[PIXEL_REF_RED].ob_y;

	dial[PIXEL_XFMT_MIRE5].ob_x = dial[PIXEL_XFMT_MIRE4].ob_x + dial[PIXEL_XFMT_MIRE4].ob_width + (FCM_RESCALE_ESPACE*2);
	dial[PIXEL_XFMT_MIRE5].ob_y = dial[PIXEL_REF_RED].ob_y;

	form_w = MAX( form_w, (dial[PIXEL_XFMT_MIRE5].ob_x + dial[PIXEL_XFMT_MIRE5].ob_width) );
	
	/* dimension du fond */
	dial[0].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[0].ob_height = dial[PIXEL_XFMT_MIRE1].ob_y + dial[PIXEL_XFMT_MIRE1].ob_height + FCM_RESCALE_MARGE_BAS;


	return;

}

