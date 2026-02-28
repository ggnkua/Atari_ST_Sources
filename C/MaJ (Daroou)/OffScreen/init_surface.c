/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 16/12/2015 * */
/* ***************************** */





#include "fonction/coeur/coeur_define.c"

#include "fonction/graphique/Fcm_create_surface.c"
#include "fonction/graphique/Fcm_free_surface.c"
#include "fonction/graphique/Fcm_transfert_surface_to_mfdb.c"
#include "fonction/graphique/Fcm_set_transparence.c"
#include "fonction/graphique/Fcm_create_mask.c"


#include "fonction/graphique/Fcm_make_sprite_transparent.c"
#include "fonction/graphique/Fcm_make_sprite_opaque.c"

#include "offscreen_error_code.h"




/* prototype */
int32 init_surface( void );



/* Fonction */
int32 init_surface( void )
{
	char	my_buffer[ (TAILLE_CHEMIN_DATA+16) ];	/* nom du fichier avec chemin */
	int16   pixel_xformat;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_surface()"CRLF );
	log_print(FALSE);
	#endif



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Construction de la palette pour TGA_SA.LDG"CRLF );
	log_print(FALSE);
	#endif



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



	/* ------------------------------------------------ */
	/* on recherche les couleurs dans la palette        */
	/* ------------------------------------------------ */
	if( Fcm_screen.nb_plan==8 )
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

			#ifdef LOG_FILE
			sprintf( buf_log, "%3d - rouge:%3d vert:%3d bleu:%3d"CRLF, pixel_idx, image_tga.palette[pixel_idx].red, image_tga.palette[pixel_idx].green, image_tga.palette[pixel_idx].blue );
			log_print(FALSE);
			#endif

		}
	}



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);





	pixel_xformat = Fcm_screen.pixel_xformat;

	/*            gestion du mode 8 bit planar            */
	/* On manipule les objets graphiques en 8bits packed  */
	/* et on convertit les r‚sultats en bit plan … la fin */
	if( pixel_xformat == PIXEL_8_PLAN )
	{
		pixel_xformat = PIXEL_8_PACKED;
	}







	/* **************************************************************** */
	/* Ouverture de l'‚cran                                           * */
	/* **************************************************************** */

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" Cr‚ation ‚cran offscreen"CRLF );
	log_print(FALSE);
	#endif

	/* --------------------------------------------------------------- */
	/* Offscreen 1                                                     */
	/* --------------------------------------------------------------- */

	surface_offscreen_vdi.nb_plan = SCREEN_PLAN;
	surface_offscreen_vdi.width   = SCREEN_WIDTH;
	surface_offscreen_vdi.height  = SCREEN_HEIGHT;

	if( Fcm_create_surface(&surface_offscreen_vdi, &mfdb_offscreen_vdi) != TRUE )
	{
		return( OFFSCREEN_ERROR_CREATE_SURFACE );
	}


	offscreenhandle=vdihandle;

	if( surface_offscreen_vdi.handle_offscreen != 0 )
	{
		offscreenhandle = surface_offscreen_vdi.handle_offscreen;
	}



	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);



	/* --------------------------------------------------------------- */
	/* Offscreen Sprite                                                */
	/* --------------------------------------------------------------- */

	surface_sprite_offscreen.nb_plan = SCREEN_PLAN;
	surface_sprite_offscreen.width   = SPRITE_OFFSCREEN_WIDTH;
	surface_sprite_offscreen.height  = SPRITE_OFFSCREEN_HEIGHT;

	if( Fcm_create_surface(&surface_sprite_offscreen, &mfdb_sprite_offscreen) != TRUE )
	{
		return( OFFSCREEN_ERROR_CREATE_SURFACE );
	}

	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);






	/* --------------------------------------------------------------- */
	/* Image de fond                                                   */
	/* --------------------------------------------------------------- */
	{
		int32 reponse;
/*		char texte[255];*/


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
												&surface_fond,
												&mfdb_fond,
												my_buffer
											);

		if( reponse != 0 )
		{
/*			sprintf(texte,"reponse = %ld", reponse );
			v_gtext(vdihandle,78*8,1*16, texte);*/
			return(reponse);
		}


/*		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_fond.fd_w-1;
		pxy[3]=mfdb_fond.fd_h-1;

		pxy[4]=480;
		pxy[5]=20;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];

		vro_cpyfm(vdihandle,3,pxy, &mfdb_fond, &Fcm_mfdb_ecran);
*/
	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);








	/* ------------------------------- */
	/* -             BAR             - */
	/* ------------------------------- */
	{
		int16 bar;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image BAR"CRLF );
		log_print(FALSE);
		#endif

		for( bar=0; bar<NB_BAR; bar++)
		{
			int32 reponse;
/*			char texte[255];*/


			sprintf( my_buffer, "%sBAR%1d.TGA", chemin_data, (bar+1) );

			#ifdef LOG_FILE
			sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
			log_print(FALSE);
			#endif


			reponse = Fcm_make_sprite_opaque	(	&image_tga,
													&surface_bar[bar],
													&mfdb_bar[bar],
													my_buffer
												);


			if( reponse != 0 )
			{
/*				sprintf(texte,"reponse = %ld", reponse );
				v_gtext(vdihandle,78*8,1*16, texte);*/
				return(reponse);
			}

/*			pxy[0]=0;
			pxy[1]=0;
			pxy[2]=mfdb_bar[bar].fd_w-1;
			pxy[3]=mfdb_bar[bar].fd_h-1;
			pxy[4]=10;
			pxy[5]=200;
			pxy[6]=pxy[4]+pxy[2];
			pxy[7]=pxy[5]+pxy[3];
			vro_cpyfm(vdihandle,3,pxy,  &mfdb_bar[bar], &Fcm_mfdb_ecran);


			evnt_timer(200);
*/

			Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);

		}
	}








	/* ------------------------------- */
	/* -             BEE             - */
	/* ------------------------------- */
	{
		int32 reponse;
/*		char texte[255];*/


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cr‚ation image BEE"CRLF );
		log_print(FALSE);
		#endif


		sprintf( my_buffer, "%sBEE.TGA", chemin_data );


		#ifdef LOG_FILE
		sprintf( buf_log, "chemin=%s"CRLF, my_buffer );
		log_print(FALSE);
		#endif

		reponse = Fcm_make_sprite_transparent(	&image_tga,
												&surface_bee,
												&surface_bee_mask,
												&mfdb_bee,
												&mfdb_bee_mask,
												my_buffer,
												0,
												0
											);

		if( reponse != 0 )
		{
/*			sprintf(texte,"reponse = %ld", reponse );
			v_gtext(vdihandle,78*8,1*16, texte);*/
			return(reponse);
		}

/*		pxy[0]=0;
		pxy[1]=0;
		pxy[2]=mfdb_bee.fd_w-1;
		pxy[3]=mfdb_bee.fd_h-1;
		pxy[4]=10;
		pxy[5]=300;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];
		vro_cpyfm(vdihandle,3,pxy,  &mfdb_bee, &Fcm_mfdb_ecran);

		pxy[4]=10;
		pxy[5]=400;
		pxy[6]=pxy[4]+pxy[2];
		pxy[7]=pxy[5]+pxy[3];

		vrt_cpyfm(vdihandle,2,pxy, &mfdb_bee_mask, &Fcm_mfdb_ecran, mask_couleur);
*/

/*			evnt_timer(2000);*/

	}


	Fcm_fenetre_launch( LH_INIT_SURFACE, LAUNCH_UPDATE, LAUNCH_WAIT_FAST);





	return 0L;


}

